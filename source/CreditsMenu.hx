package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
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

class CreditsMenu extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var crediticons:FlxTypedGroup<FlxSprite>;
	var fixdiff:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['fnf', 'dev', 'special', 'git'];
	#else
	var optionShit:Array<String> = ['fnf'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	var newInput:Bool = true;
	var logo:FlxSprite;
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
		DiscordClient.changePresence("in the Credits!", null);
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


		logo = new FlxSprite(-700, -359).loadGraphic(Paths.image('Credits_LeftSide'));
		add(logo);

		logoBl = new FlxSprite(-100, -250);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = true;
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.8));
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('credits_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(40, 390  + (i * 40));
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

			if (controls.BACK)
			{
				FlxG.switchState(new MainMenuState());
			}

			if (controls.ACCEPT)
				{
					if (optionShit[curSelected] == 'fnf')
					{
						goToState();
					}
					else
					{
						if (optionShit[curSelected] == 'git')
							{
								goToState();
							}
						else
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
				case 'fnf':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game", "&"]);
					#else
					FlxG.openURL('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game');
					#end
				case 'dev':
					FlxG.switchState(new CreditDevMenu());
				case 'special':
					FlxG.switchState(new CreditsSpecialMenu());
				case 'git':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://github.com/Jorge-SunSpirit/Monika_Full_Week", "&"]);
					#else
					FlxG.openURL('https://github.com/Jorge-SunSpirit/Monika_Full_Week');
					#end
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
