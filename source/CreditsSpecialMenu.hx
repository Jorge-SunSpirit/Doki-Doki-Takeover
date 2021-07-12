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

class CreditsSpecialMenu extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var crediticons:FlxTypedGroup<FlxSprite>;
	var fixdiff:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['ash','blantados','Cval','dan','foomfs','kade','lumitic','matt', 'zee'];
	#else
	var optionShit:Array<String> = ['lumi'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	var newInput:Bool = true;
	var logo:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var thank:FlxSprite;
	var backdrop:FlxBackdrop;

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
		
	
		thank = new FlxSprite(-380, -450).loadGraphic(Paths.image('ThanksIcon'));
		thank.setGraphicSize(Std.int(thank.width * 0.5));
		add(thank);
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('credits_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(40, 350  + (i * 35));
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


		crediticons = new FlxTypedGroup<FlxSprite>();


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
				FlxG.switchState(new CreditsMenu());
			}

			if (controls.ACCEPT)
			{
				goToState();
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
				case 'ash':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://gamebanana.com/members/1813477", "&"]);
					#else
					FlxG.openURL('https://gamebanana.com/members/1813477');
					#end
				case 'blantados':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://www.youtube.com/channel/UC4rwJYVeDHxGKnFDhHz88ZQ", "&"]);
					#else
					FlxG.openURL('https://www.youtube.com/channel/UC4rwJYVeDHxGKnFDhHz88ZQ');
					#end
				case 'dan':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://twitter.com/dansalvato", "&"]);
					#else
					FlxG.openURL('https://twitter.com/dansalvato');
					#end
				case 'kade':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://twitter.com/KadeDeveloper", "&"]);
					#else
					FlxG.openURL('https://twitter.com/KadeDeveloper');
					#end
				case 'lumitic':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://twitter.com/PeacefulLuma", "&"]);
					#else
					FlxG.openURL('https://twitter.com/PeacefulLuma');
					#end
				case 'zee':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://twitter.com/Zeexel32", "&"]);
					#else
					FlxG.openURL('https://twitter.com/Zeexel32');
					#end	
				case 'Cval':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://twitter.com/cval_brown", "&"]);
					#else
					FlxG.openURL('https://twitter.com/cval_brown');
					#end
				case 'foomfs':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://twitter.com/foomfs", "&"]);
					#else
					FlxG.openURL('https://twitter.com/foomfs');
					#end
				case 'matt':
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://twitter.com/matt_currency", "&"]);
					#else
					FlxG.openURL('https://twitter.com/matt_currency');
					#end
			}
		}

	function changeItem(huh:Int = 0)
		{
			curSelected += huh;

			if (curSelected >= 9)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = 9 - 1;
				
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
