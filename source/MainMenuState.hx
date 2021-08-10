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

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	public static var kadeEngineVer:String = "1.4.2" + nightly;
	public static var nightly:String = "";
	var menuItems:FlxTypedGroup<FlxSprite>;
	var crediticons:FlxTypedGroup<FlxSprite>;
	var fixdiff:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'credits', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;
	var newGaming:FlxText;
	var newGaming2:FlxText;
	var newInput:Bool = true;
	var logo:FlxSprite;
	var fumo:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var backdrop:FlxBackdrop;
	var logoBl:FlxSprite;
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
		
		var bg:FlxSprite = new FlxSprite(-80,-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0.10;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		

		camFollow = new FlxObject(0, 0, 1, 1);

		add(camFollow);


		add(backdrop = new FlxBackdrop(Paths.image('scrolling_BG')));
		backdrop.velocity.set(-40, -40);


		//-700, =359
		logo = new FlxSprite(-900, -359).loadGraphic(Paths.image('Credits_LeftSide'));
		add(logo);
		if (firstStart)
			FlxTween.tween(logo,{x: -700},1.2 ,{ease: FlxEase.elasticOut, onComplete: function(flxTween:FlxTween) 
				{ 
					finishedFunnyMove = true; 
					changeItem();
				}});
		else
			logo.x = -700;

		//-600, -400
		logoBl = new FlxSprite(-800, -400);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = true;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);
		if (firstStart)
			FlxTween.tween(logoBl,{x: -600},1.2 ,{ease: FlxEase.elasticOut, onComplete: function(flxTween:FlxTween) 
				{ 
					finishedFunnyMove = true; 
					changeItem();
				}});
		else
			logoBl.x = -600;

		fumo = new FlxSprite(-100, -250).loadGraphic(Paths.image('Fumo'));
		fumo.scale.set(1, 1);
		add(fumo);
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('credits_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(-350, 390  + (i * 50));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.scale.set(1.5, 1.5);
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			if (firstStart)
				FlxTween.tween(menuItem,{x: 50},1.2 + (i * 0.2) ,{ease: FlxEase.elasticOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuItem.x = 50;
		}



		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));


		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;




	override function update(elapsed:Float)
	{
		
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (FlxG.keys.justPressed.O)
				{
					#if debug
					trace('hello');
					FlxG.save.data.monibeaten = true;
					FlxG.save.data.sayobeaten = true;
					FlxG.save.data.natbeaten = true;
					FlxG.save.data.yuribeaten = true;
					FlxG.save.data.extrabeaten = true;
					#end
				}
			if (FlxG.keys.justPressed.P)
				{
					#if debug
					trace('not beaten :(');
					FlxG.save.data.monibeaten = false;
					FlxG.save.data.sayobeaten = false;
					FlxG.save.data.natbeaten = false;
					FlxG.save.data.yuribeaten = false;
					FlxG.save.data.extrabeaten = false;
					#end
				}

			if (controls.ACCEPT)
				{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
		
						menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
								FlxTween.tween(spr, {alpha: 0}, 1.3, {
								ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
									spr.kill();
									}
								});
								}
								else
							{
									if (FlxG.save.data.flashing)
								{
									FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
										{
										goToState();
									});
									}
								else
								{
									new FlxTimer().start(1, function(tmr:FlxTimer)
									{
										goToState();
									});
								}
							}
						});
				}
		}
		super.update(elapsed);
		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function goToState()
		{
			var daChoice:String = optionShit[curSelected];
	
			switch (daChoice)
				{
					case 'story mode':
						FlxG.switchState(new DokiStoryState());
						//FlxG.switchState(new StoryMenuState());
						trace("Story Menu Selected");
					case 'freeplay':
						FlxG.switchState(new FreeplayState());

						trace("Freeplay Menu Selected");
					case 'credits':
						FlxG.switchState(new CreditsMenu());

						trace("Credits Menu Selected");
					case 'options':
						FlxG.switchState(new OptionsMenu());
				}
		}


	function changeItem(huh:Int = 0)
		{
			curSelected += huh;

			if (curSelected >= 4)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = 4 - 1;
				
			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.animation.play('idle');

				if (spr.ID == curSelected)
				{
					spr.animation.play('selected');
				}

				spr.updateHitbox();
			});
		}
	}
