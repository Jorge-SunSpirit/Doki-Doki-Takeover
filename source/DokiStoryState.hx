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
import io.newgrounds.NG;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class DokiStoryState extends MusicBeatState
{
	
	var scoreText:FlxText;

	var weekData:Array<Dynamic> = [
		['High School Conflict', 'Bara No Yume', 'Your Demise'],
		['erb'],
		['My Sweets'],
		['Obsession'],
		['Reconciliation'],
		['epiphany']
	];
	var curDifficulty:Int = 1;

	var weekNames:Array<String> = [
		"Just Monika",
		"Sayori",
		"Natsuki",
		"Yuri",
		"Monika Extra",
		"???"
	];

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

	var backdrop:FlxBackdrop;
	var logoBl:FlxSprite;
	var diff:FlxSprite;
	var grpLocks:FlxTypedGroup<FlxSprite>;
	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		camFollow = new FlxObject(0, 0, 1, 1);

		add(camFollow);

		add(backdrop = new FlxBackdrop(Paths.image('scrolling_BG')));
		backdrop.velocity.set(-40, -40);

		//-700, =359
		logo = new FlxSprite(-700, -359).loadGraphic(Paths.image('Credits_LeftSide'));
		add(logo);

		songlist = new FlxSprite(-700, -359).loadGraphic(Paths.image('dokistory/song_list_lazy_smile'));
		add(songlist);

		//-600, -400
		logoBl = new FlxSprite(-600, -400);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = true;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		txtWeekTitle = new FlxText(FlxG.width * 0.05, 0, 0, "", 5);
		txtWeekTitle.setFormat("Riffic Free Bold", 32, FlxColor.WHITE, CENTER);
		txtWeekTitle.alignment = CENTER;
		txtWeekTitle.scale.set(1.2, 1.2);
		txtWeekTitle.setBorderStyle(OUTLINE, 0xFFF860B0, 2, 1);
		txtWeekTitle.updateHitbox();
		txtWeekTitle.antialiasing = true;
		txtWeekTitle.x -= 30;
		txtWeekTitle.y -= 210;
		add(txtWeekTitle);

		txtTracklist = new FlxText(FlxG.width * 0.01, 50, 0, "", 5);
		txtTracklist.setFormat("Riffic Free Bold", 32, FlxColor.WHITE, CENTER);
		txtTracklist.alignment = CENTER;
		txtTracklist.scale.set(.8, .8);
		txtTracklist.setBorderStyle(OUTLINE, 0xFFFFB9DD, 3, 1);
		txtTracklist.updateHitbox();
		txtTracklist.antialiasing = true;
		txtTracklist.y += -0;
		add(txtTracklist);

		diff = new FlxSprite(-30, 200);
		diff.frames = Paths.getSparrowAtlas('dokistory/difficulties');
		diff.antialiasing = true;
		diff.scale.set(1, 1);
		diff.animation.addByPrefix('easy', 'Easy', 24);
		diff.animation.addByPrefix('normal', 'Normal', 24);
		diff.animation.addByPrefix('hard', 'Hard', 24);
		diff.animation.play('normal');
		diff.updateHitbox();
		diff.visible = false;
		add(diff);



		

		

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));


		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();
		updateText();

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
					trace("expurgation");

			}
		#end

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
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
										FlxG.sound.play(Paths.sound('confirmMenu'));
										diff.visible = true;
										diffselect = true;
									}
						}
					case true:
						{
							if (controls.BACK)
								{
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
			PlayState.storyPlaylist = weekData[curSelected];
			PlayState.isStoryMode = true;
			selectedSomethin = true;
			diffselect = false;
			PlayState.storyDifficulty = curDifficulty;

			var diffic = "";

						switch (curDifficulty)
						{
							case 0:
								diffic = '-easy';
							case 2:
								diffic = '-hard';
						}

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curSelected;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
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
								trace("expurgation Week Selected");
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
			
		}

		function updateText()
		{
			txtTracklist.text = "\n";
			var stringThing:Array<String> = weekData[curSelected];

			for (i in stringThing)
				txtTracklist.text += "\n" + i;

			txtWeekTitle.text = weekNames[curSelected].toUpperCase();
			txtTracklist.text = txtTracklist.text.toUpperCase();

			txtTracklist.screenCenter(X);
			txtTracklist.x -= 1110;

			txtTracklist.text += "\n";

		}
	}
