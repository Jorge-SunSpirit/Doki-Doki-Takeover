package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;

#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class DokiStoryState extends MusicBeatState
{
	var scoreText:FlxText;

	var weekData:Array<Dynamic> = [
		['High School Conflict', 'Bara No Yume', 'Your Demise'],
		['Rain Clouds', 'My Confession'],
		['My Sweets', 'Baka'],
		//['Deep Breaths','Obsession'],
		['Obsession'],
		['Reconciliation'],
		['Crucify (Yuri Mix)', 'Beathoven (Natsuki Mix)', "It's Complicated (Sayori Mix)", 'Glitcher (Monika Mix)']
	];

	var curDifficulty:Int = 1;

	var weekNames:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/weekNames', 'preload', true));

	var txtWeekTitle:FlxText;
	var txtTracklist:FlxText;
	var grpWeekText:FlxTypedGroup<MenuItem>;

	var curSelected:Int = 0;
	public static var kadeEngineVer:String = "1.4.2" + nightly;
	public static var nightly:String = "";
	var menuItems:FlxTypedGroup<FlxSprite>;
	var crediticons:FlxTypedGroup<FlxSprite>;
	var fixdiff:FlxTypedGroup<FlxSprite>;

	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;
	var newGaming:FlxText;
	var newGaming2:FlxText;
	var newInput:Bool = true;
	var logo:FlxSprite;
	var songlist:FlxSprite;
	var camFollow:FlxObject;



	var story_moni:FlxSprite;
	var story_sayo:FlxSprite;
	var story_nat:FlxSprite;
	var story_yuri:FlxSprite;
	var story_secret:FlxSprite;
	var story_secret2:FlxSprite;
	var story_cursor:FlxSprite;

	var backdrop:FlxBackdrop;
	var logoBl:FlxSprite;
	var diff:FlxSprite;
	var grpLocks:FlxTypedGroup<FlxSprite>;
	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	public var acceptInput:Bool = true;

	override function create()
	{
		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(102);
		}

		persistentUpdate = persistentDraw = true;

		camFollow = new FlxObject(0, 0, 1, 1);

		add(camFollow);

		add(backdrop = new FlxBackdrop(Paths.image('scrolling_BG')));
		backdrop.velocity.set(-40, -40);

		//-700, =359
		logo = new FlxSprite(-700, -359).loadGraphic(Paths.image('Credits_LeftSide'));
		add(logo);

		songlist = new FlxSprite(-700, -359).loadGraphic(Paths.image('dokistory/song_list_lazy_smile', 'preload', true));
		add(songlist);

		//-600, -400
		logoBl = new FlxSprite(-600, -400);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = true;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		txtWeekTitle = new FlxText(FlxG.width * 0.05, 0, 0, "", 5);
		txtWeekTitle.setFormat(LangUtil.getFont('riffic'), 32, FlxColor.WHITE, CENTER);
		txtWeekTitle.alignment = CENTER;
		txtWeekTitle.scale.set(1.2, 1.2);
		txtWeekTitle.setBorderStyle(OUTLINE, 0xFFF860B0, 2, 1);
		txtWeekTitle.updateHitbox();
		txtWeekTitle.antialiasing = true;
		txtWeekTitle.x -= 30;
		txtWeekTitle.y -= 210;
		add(txtWeekTitle);

		txtTracklist = new FlxText(FlxG.width * 0.01, 50, 0, "", 5);
		txtTracklist.setFormat(LangUtil.getFont('riffic'), 32, FlxColor.WHITE, CENTER);
		txtTracklist.alignment = CENTER;
		txtTracklist.scale.set(.8, .8);
		txtTracklist.setBorderStyle(OUTLINE, 0xFFFFB9DD, 3, 1);
		txtTracklist.updateHitbox();
		txtTracklist.antialiasing = true;
		txtTracklist.y += -0;
		add(txtTracklist);

		diff = new FlxSprite(-30, 200);
		diff.frames = Paths.getSparrowAtlas('dokistory/difficulties', 'preload', true);
		diff.antialiasing = true;
		diff.scale.set(1, 1);
		diff.animation.addByPrefix('easy', 'Easy', 24);
		diff.animation.addByPrefix('normal', 'Normal', 24);
		diff.animation.addByPrefix('hard', 'Hard', 24);
		diff.animation.play('normal');
		diff.updateHitbox();
		diff.visible = false;
		add(diff);

		/*var story_moni:FlxSprite;
		var story_sayo:FlxSprite;
		var story_nat:FlxSprite;
		var story_yuri:FlxSprite;
		var story_secret:FlxSprite;
		var story_secret2:FlxSprite;*/

		//second layer Y is 90

		story_moni = new FlxSprite(-240, -160);
		story_moni.frames = Paths.getSparrowAtlas('dokistory/moni_story');
		story_moni.antialiasing = true;
		story_moni.scale.set(1, 1);
		story_moni.animation.addByPrefix('idle', 'moni_idle', 20);
		story_moni.animation.addByPrefix('selected', 'moni_selected', 24, false);
		story_moni.animation.play('idle');
		story_moni.updateHitbox();
		add(story_moni);

		story_sayo = new FlxSprite(40, -160);
		story_sayo.frames = Paths.getSparrowAtlas('dokistory/sayo_story');
		story_sayo.antialiasing = true;
		story_sayo.scale.set(1, 1);
		story_sayo.animation.addByPrefix('idle', 'sayo_idle', 20);
		story_sayo.animation.addByPrefix('selected', 'sayo_selected', 24, false);
		story_sayo.animation.addByPrefix('locked', 'sayo_Locked', 24, false);
		story_sayo.animation.play('locked');
		story_sayo.updateHitbox();
		add(story_sayo);

		story_nat = new FlxSprite(320, -160);
		story_nat.frames = Paths.getSparrowAtlas('dokistory/nat_story');
		story_nat.antialiasing = true;
		story_nat.scale.set(1, 1);
		story_nat.animation.addByPrefix('idle', 'natsuki_idle', 20);
		story_nat.animation.addByPrefix('selected', 'natsuki_selected', 24, false);
		story_nat.animation.addByPrefix('locked', 'natsuki_Locked', 24, false);
		story_nat.animation.play('locked');
		story_nat.updateHitbox();
		add(story_nat);


		story_yuri = new FlxSprite(-240, 40);
		story_yuri.frames = Paths.getSparrowAtlas('dokistory/yuri_story');
		story_yuri.antialiasing = true;
		story_yuri.scale.set(1, 1);
		story_yuri.animation.addByPrefix('idle', 'yuri_selected', 20);
		story_yuri.animation.addByPrefix('selected', 'yuri_idle', 24, false);
		story_yuri.animation.addByPrefix('locked', 'yuri_Locked', 24, false);
		story_yuri.animation.play('locked');
		story_yuri.updateHitbox();
		add(story_yuri);

		story_secret = new FlxSprite(40, 40);
		story_secret.frames = Paths.getSparrowAtlas('dokistory/secret_story');
		story_secret.antialiasing = true;
		story_secret.scale.set(1, 1);
		story_secret.animation.addByPrefix('idle', 'duster_idle', 20);
		story_secret.animation.addByPrefix('selected', 'duster_selected', 24, false);
		story_secret.animation.addByPrefix('locked', 'blank_locked', 24, false);
		story_secret.animation.play('locked');
		story_secret.updateHitbox();
		add(story_secret);

		story_secret2 = new FlxSprite(320, 40);
		story_secret2.frames = Paths.getSparrowAtlas('dokistory/secret2_story');
		story_secret2.antialiasing = true;
		story_secret2.scale.set(1, 1);
		story_secret2.animation.addByPrefix('idle', 'mc_idle', 20);
		story_secret2.animation.addByPrefix('hidden_idle', 'mc_hiddenidle', 20);
		story_secret2.animation.addByPrefix('selected', 'mc_selected', 24, false);
		story_secret2.animation.addByPrefix('locked', 'blank_locked', 24, false);
		story_secret2.animation.play('locked');
		story_secret2.updateHitbox();
		add(story_secret2);

		story_cursor = new FlxSprite(-240, -110).loadGraphic(Paths.image('dokistory/cursor'));
		add(story_cursor);

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));


		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();
		updateText();
		unlockedweeks();

		super.create();
	}

	var selectedSomethin:Bool = false;
	var diffselect:Bool = false;




	override function update(elapsed:Float)
	{
		#if debug
		switch (curSelected)
			{
				case 0:
					trace("monika");
				case 1:
					trace("sayso");
				case 2:
					trace("nat big forhead");
				case 3:
					trace("yuri on ice");
				case 4:
					trace("recon to the battlefield");
				case 5:
					trace("Festival");
					//trace("expurgation");

			}
		#end

		switch (curSelected)
			{
				case 0:
					story_moni.animation.paused = false;
					story_sayo.animation.paused = true;
					story_nat.animation.paused = true;
					story_yuri.animation.paused = true;
					story_secret.animation.paused = true;
					story_secret2.animation.paused = true;

					story_cursor.x = -240;
					story_cursor.y = -160;
				case 1:
					story_moni.animation.paused = true;
					story_sayo.animation.paused = false;
					story_nat.animation.paused = true;
					story_yuri.animation.paused = true;
					story_secret.animation.paused = true;
					story_secret2.animation.paused = true;

					story_cursor.x = 40;
					story_cursor.y = -160;
				case 2:
					story_moni.animation.paused = true;
					story_sayo.animation.paused = true;
					story_nat.animation.paused = false;
					story_yuri.animation.paused = true;
					story_secret.animation.paused = true;
					story_secret2.animation.paused = true;

					story_cursor.x = 320;
					story_cursor.y = -160;
				case 3:
					story_moni.animation.paused = true;
					story_sayo.animation.paused = true;
					story_nat.animation.paused = true;
					story_yuri.animation.paused = false;
					story_secret.animation.paused = true;
					story_secret2.animation.paused = true;

					story_cursor.x = -240;
					story_cursor.y = 40;
				case 4:
					story_moni.animation.paused = true;
					story_sayo.animation.paused = true;
					story_nat.animation.paused = true;
					story_yuri.animation.paused = true;
					story_secret.animation.paused = false;
					story_secret2.animation.paused = true;

					story_cursor.x = 40;
					story_cursor.y = 40;
				case 5:
					story_moni.animation.paused = true;
					story_sayo.animation.paused = true;
					story_nat.animation.paused = true;
					story_yuri.animation.paused = true;
					story_secret.animation.paused = true;
					story_secret2.animation.paused = false;

					story_cursor.x = 320;
					story_cursor.y = 40;

			}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin && acceptInput)
		{
			switch (diffselect)
				{
					case false:
						{
							if (controls.LEFT_P)
									{
										FlxG.sound.play(Paths.sound('scrollMenu'));
										changeItem(-1);
									}
					
								if (controls.RIGHT_P)
									{
										FlxG.sound.play(Paths.sound('scrollMenu'));
										changeItem(1);
									}
					
								if (controls.UP_P)
									{
										FlxG.sound.play(Paths.sound('scrollMenu'));
										changeItem(-3);
									}
					
								if (controls.DOWN_P)
									{
										FlxG.sound.play(Paths.sound('scrollMenu'));
										changeItem(3);
									}
					
								if (controls.BACK)
									{
										FlxG.sound.play(Paths.sound('cancelMenu'));
										FlxG.switchState(new MainMenuState());
									}
					
								if (controls.ACCEPT)
									{
										switch (curSelected)
											{
												default:
													{
														FlxG.sound.play(Paths.sound('confirmMenu'));
														diff.visible = true;
														diffselect = true;
													}
												case 1:
													{
														if (FlxG.save.data.monibeaten == true)
															{
																FlxG.sound.play(Paths.sound('confirmMenu'));
																diff.visible = true;
																diffselect = true;
															}
													}
												case 2:
													{
														if (FlxG.save.data.sayobeaten == true)
															{
																FlxG.sound.play(Paths.sound('confirmMenu'));
																diff.visible = true;
																diffselect = true;
															}
													}	
												case 3:
													{
														if (FlxG.save.data.natbeaten == true)
															{
																FlxG.sound.play(Paths.sound('confirmMenu'));
																diff.visible = true;
																diffselect = true;
															}
													}
												case 4:
													{
														if (FlxG.save.data.yuribeaten == true)
															{
																FlxG.sound.play(Paths.sound('confirmMenu'));
																diff.visible = true;
																diffselect = true;
															}
													}
												case 5:
													{
														if (FlxG.save.data.extrabeaten == true)
															{
																FlxG.sound.play(Paths.sound('confirmMenu'));
																diff.visible = true;
																diffselect = true;
															}
													}
											}
									}
						}
					case true:
						{
							if (controls.BACK)
								{
									FlxG.sound.play(Paths.sound('cancelMenu'));
									diff.visible = false;
									diffselect = false;
								}
				
							if (controls.LEFT_P)
								{
									FlxG.sound.play(Paths.sound('scrollMenu'));
									changeDiff(-1);
								}
					
							if (controls.RIGHT_P)
								{
									FlxG.sound.play(Paths.sound('scrollMenu'));
									changeDiff(1);
								}
			
							if (controls.ACCEPT)
								{
										selectedSomethin = true;
										FlxG.sound.play(Paths.sound('confirmMenu'));
										goToState();
										
								}
						}
				}
			
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}


	function changeDiff(change:Int = 0):Void
		{
			curDifficulty += change;

			if (curDifficulty < 0)
				curDifficulty = 2;
			if (curDifficulty > 2)
				curDifficulty = 0;

			switch (curDifficulty)
			{
				case 0:
				diff.animation.play('easy');
				case 1:
				diff.animation.play('normal');
				case 2:
				diff.animation.play('hard');
			}
		}


	function goToState()
		{
			if (FlxG.keys.pressed.E && FlxG.keys.pressed.R && FlxG.keys.pressed.B)
				{
					PlayState.storyPlaylist = ['erb'];
					PlayState.storyDifficulty = 1;
				}
				else
					{
						PlayState.storyPlaylist = weekData[curSelected];
						PlayState.storyDifficulty = curDifficulty;
					}
			
			PlayState.isStoryMode = true;
			selectedSomethin = true;
			diffselect = false;


			var diffic = "";

						switch (curDifficulty)
						{
							case 0:
								diffic = '-easy';
							case 2:
								diffic = '-hard';
						}

			switch (curSelected)
			{
				case 0:
					story_moni.animation.play('selected');
				case 1:
					story_sayo.animation.play('selected');
				case 2:
					story_nat.animation.play('selected');
				case 3:
					story_yuri.animation.play('selected');
				case 4:
					story_secret.animation.play('selected');
				case 5:
					if (FlxG.save.data.extra2beaten == true)
						{
						story_secret2.animation.play('selected');
						}

			}

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curSelected;
			PlayState.campaignScore = 0;
			new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					switch (curSelected)
						{
							case 0:
								LoadingState.loadAndSwitchState(new PlayState(), true);
								trace("Monika Week Selected");
							case 1:
								LoadingState.loadAndSwitchState(new PlayState(), true);
								trace("Sayori Selected");
							case 2:
								LoadingState.loadAndSwitchState(new PlayState(), true);
								trace("Natsuki Week Selected");
							case 3:
								LoadingState.loadAndSwitchState(new PlayState(), true);
								trace("Yuri Week Selected");
							case 4:
								LoadingState.loadAndSwitchState(new PlayState(), true);
								trace("monika extra Week Selected");
							case 5:
								LoadingState.loadAndSwitchState(new PlayState(), true);
								//trace("expurgation Week Selected");
								trace("Festival Week Selected");
						}
				});
			
		}


	function changeItem(huh:Int = 0)
		{
			curSelected += huh;

			//attempts to loop back into the bottom row
			if (curSelected == -3)
				curSelected = 3;
			if (curSelected == -2)
				curSelected = 4;
			if (curSelected == -1)
				curSelected = 5;

			//attempts to loop back into the top row
			if (curSelected == 7)
				curSelected = 1;
			if (curSelected == 8)
				curSelected = 2;
			if (curSelected == 9)
				curSelected = 3;

			if (curSelected >= 6)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = 6 - 1;

			updateText();

			switch (curSelected)
			{
				case 1:
					txtWeekTitle.visible = FlxG.save.data.monibeaten;
					txtTracklist.visible = FlxG.save.data.monibeaten;
				case 2:
					txtWeekTitle.visible = FlxG.save.data.sayobeaten;
					txtTracklist.visible = FlxG.save.data.sayobeaten;
				case 3:
					txtWeekTitle.visible = FlxG.save.data.natbeaten;
					txtTracklist.visible = FlxG.save.data.natbeaten;
				case 4:
					txtWeekTitle.visible = FlxG.save.data.yuribeaten;
					txtTracklist.visible = FlxG.save.data.yuribeaten;
				case 5:
					txtWeekTitle.visible = FlxG.save.data.extrabeaten;
					txtTracklist.visible = FlxG.save.data.extra2beaten;
				default:
					txtWeekTitle.visible = true;
					txtTracklist.visible = true;
			}
			
		}

		function unlockedweeks()
		{
			if (FlxG.save.data.monibeaten == true)
			{
				FlxG.save.data.weekUnlocked = 2;
				story_sayo.animation.play('idle');
			}
			if (FlxG.save.data.sayobeaten == true)
			{
				FlxG.save.data.weekUnlocked = 3;
				story_nat.animation.play('idle');
			}
			if (FlxG.save.data.natbeaten == true)
			{
				FlxG.save.data.weekUnlocked = 4;
				story_yuri.animation.play('idle');
			}
			if (FlxG.save.data.yuribeaten == true)
			{
				FlxG.save.data.weekUnlocked = 5;
				story_secret.animation.play('idle');
			}
			if (FlxG.save.data.extrabeaten == true)
			{
				FlxG.save.data.weekUnlocked = 6;
				story_secret2.animation.play('hidden_idle');
			}
			if (FlxG.save.data.extra2beaten == true)
			{
				FlxG.save.data.weekUnlocked = 7;
				story_secret2.animation.play('idle');
			}
		}

		function updateText()
		{
			txtTracklist.text = "\n";
			var stringThing:Array<String> = weekData[curSelected];

			for (i in stringThing)
				txtTracklist.text += "\n" + i.split(" (")[0];

			txtWeekTitle.text = weekNames[curSelected].toUpperCase();
			txtTracklist.text = txtTracklist.text.toUpperCase();

			txtTracklist.screenCenter(X);
			txtTracklist.x -= 1110;

			txtTracklist.text += "\n";

		}

		override function beatHit()
			{
				super.beatHit();
				logoBl.animation.play('bump', true);
			}
	}
