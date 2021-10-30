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
#if FEATURE_GAMEJOLT
import GameJolt.GameJoltAPI;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	public static var kadeEngineVer:String = "1.4.2" + nightly;
	public static var nightly:String = "";

	var show:String = "";
	var menuItems:FlxTypedGroup<FlxSprite>;
	var crediticons:FlxTypedGroup<FlxSprite>;
	var fixdiff:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String>;

	public static var firstStart:Bool = true;

	var newGaming:FlxText;
	var newGaming2:FlxText;
	var newInput:Bool = true;
	var logo:FlxSprite;
	var fumo:FlxSprite;
	var menu_character:FlxSprite;
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
		if (FlxG.save.data.extra2beaten)
			optionShit = ['story mode', 'freeplay', 'credits', 'language', 'options'];
		else
			optionShit = ['story mode', 'freeplay', 'language', 'options'];

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(102);
		}

		if (!FlxG.save.data.monibeaten)
			FlxG.save.data.weekUnlocked = 1;

		trace("CURRENT WEEK: " + FlxG.save.data.weekUnlocked);

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80, -80).loadGraphic(Paths.image('menuBG'));
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

		var random = FlxG.random.float(0, 200);
		// show = 'senpai';
		trace(random);
		if (!FlxG.save.data.extrabeaten)
		{
			trace('together1');
			show = 'together1';
		}
		else
		{
			trace('together');
			show = 'together';
		}
		if (random >= 20 && random <= 40)
		{
			trace('yuri');
			show = 'yuri';
		}

		if (random >= 41 && random <= 60)
		{
			trace('natsuki');
			show = 'natsuki';
		}
		if (random >= 61 && random <= 80)
		{
			trace('sayori');
			show = 'sayori';
		}
		if (random >= 81 && random <= 100 && FlxG.save.data.extrabeaten)
		{
			trace('monika');
			show = 'monika';
		}
		if (random >= 81 && random <= 100 && !FlxG.save.data.extrabeaten)
		{
			trace('pixelmonika');
			show = 'pixelmonika';
		}
		if (random >= 101 && random <= 120)
		{
			trace('senpai');
			show = 'senpai';
		}
		if (random >= 121 && random <= 130)
		{
			trace('sunnat');
			show = 'sunnat';
		}
		if (random >= 131 && random <= 140)
		{
			trace('yuritabi');
			show = 'yuritabi';
		}
		if (random >= 141 && random <= 150)
		{
			trace('minusmonikapixel');
			show = 'minusmonikapixel';
		}
		if (random >= 151 && random <= 160 && FlxG.save.data.extrabeaten)
		{
			trace('akimonika');
			show = 'akimonika';
		}
		if (random >= 161 && random <= 170)
		{
			trace('cyrixstatic');
			show = 'cyrixstatic';
		}
		if (random >= 171 && random <= 180)
		{
			trace('zipori');
			show = 'zipori';
		}
		if (random >= 181 && random <= 200 && FlxG.save.data.extra2beaten)
		{
			trace('protag');
			show = 'protag';
		}
		if (random >= 98 && random <= 100)
		{
			trace('fumo');
			show = 'fumo';
		}

		//-700, =359
		logo = new FlxSprite(-900, -359).loadGraphic(Paths.image('Credits_LeftSide'));
		logo.antialiasing = true;
		add(logo);
		if (firstStart)
			FlxTween.tween(logo, {x: -700}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			logo.x = -700;

		//-600, -400
		logoBl = new FlxSprite(-800, -400);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = true;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);
		if (firstStart)
			FlxTween.tween(logoBl, {x: -600}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			logoBl.x = -600;

		/*
			fumo = new FlxSprite(-100, -250).loadGraphic(Paths.image('Fumo'));
			fumo.scale.set(1, 1);
			add(fumo);
		 */

		switch (show)
		{
			case 'fumo':
				menu_character = new FlxSprite(0, -200);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/fumo');
				menu_character.antialiasing = true;
				menu_character.scale.set(1, 1);
				menu_character.animation.addByPrefix('play', 'cirno_fumo', 24, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'senpai':
				menu_character = new FlxSprite(-100, -250);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/Senpai');
				menu_character.antialiasing = true;
				menu_character.scale.set(.9, .9);
				menu_character.animation.addByPrefix('play', 'senpai_microphone', 24);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'sunnat':
				menu_character = new FlxSprite(-300, -100);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/sunnat_menu');
				menu_character.antialiasing = true;
				menu_character.scale.set(.8, .8);
				menu_character.animation.addByPrefix('play', 'sunday right', 24);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'yuritabi':
				menu_character = new FlxSprite(-150, -270);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/tabiandyuri');
				menu_character.antialiasing = true;
				menu_character.scale.set(.77, .77);
				menu_character.animation.addByPrefix('play', 'Tabi Yuri together hueh', 21);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'pixelmonika':
				menu_character = new FlxSprite(-40, -240);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/pixelmonika');
				menu_character.antialiasing = true;
				menu_character.scale.set(.7, .7);
				menu_character.animation.addByPrefix('play', 'Monika_Neutral_gif', 24, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'minusmonikapixel':
				menu_character = new FlxSprite(-40, -280);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/minusmonikapixel');
				menu_character.antialiasing = true;
				menu_character.scale.set(.7, .7);
				menu_character.animation.addByPrefix('play', 'MinusMonika_gif', 24, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'yuri':
				menu_character = new FlxSprite(20, -230);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/yuri');
				menu_character.antialiasing = true;
				menu_character.scale.set(.7, .7);
				menu_character.animation.addByPrefix('play', 'Yuri BG', 24, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'sayori':
				menu_character = new FlxSprite(20, -180);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/sayori');
				menu_character.antialiasing = true;
				menu_character.scale.set(.7, .7);
				menu_character.animation.addByPrefix('play', 'Sayori BG', 24, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'natsuki':
				menu_character = new FlxSprite(0, -140);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/natsuki');
				menu_character.antialiasing = true;
				menu_character.scale.set(.7, .7);
				menu_character.animation.addByPrefix('play', 'Natsu BG', 24, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'monika':
				menu_character = new FlxSprite(-70, -250);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/monika');
				menu_character.antialiasing = true;
				menu_character.scale.set(.7, .7);
				menu_character.animation.addByPrefix('play', 'Moni BG', 24, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'protag':
				menu_character = new FlxSprite(20, -250);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/protag');
				menu_character.antialiasing = true;
				menu_character.scale.set(.7, .7);
				menu_character.animation.addByPrefix('play', 'Protag-kun BG', 24, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'akimonika':
				menu_character = new FlxSprite(-70, -270);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/akihamoniduo');
				menu_character.antialiasing = true;
				menu_character.scale.set(.77, .77);
				menu_character.animation.addByPrefix('play', 'Moni Akiha Menu', 21, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'cyrixstatic':
				menu_character = new FlxSprite(-150, -270);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/cyrixstaticmenu');
				menu_character.antialiasing = true;
				menu_character.scale.set(.77, .77);
				menu_character.animation.addByPrefix('play', 'Cyrix-Static Menu', 21);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'together':
				menu_character = new FlxSprite(-170, -320);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/dokitogether');
				menu_character.antialiasing = true;
				menu_character.scale.set(.7, .7);
				menu_character.animation.addByPrefix('play', 'Doki together club', 21, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'together1':
				menu_character = new FlxSprite(-150, -310);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/dokitogetheralt');
				menu_character.antialiasing = true;
				menu_character.scale.set(.77, .77);
				menu_character.animation.addByPrefix('play', 'Doki together club', 21, false);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
			case 'zipori':
				menu_character = new FlxSprite(-100, -270);
				menu_character.frames = Paths.getSparrowAtlas('menucharacters/sayozip');
				menu_character.antialiasing = true;
				menu_character.scale.set(.8, .8);
				menu_character.animation.addByPrefix('play', 'Sayo Zipper Menu', 24);
				menu_character.updateHitbox();
				menu_character.animation.play('play');
				add(menu_character);
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('credits_assets', 'preload', true);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(-350, 390 + (i * 50));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.scale.set(1.5, 1.5);
			// menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			if (firstStart)
				FlxTween.tween(menuItem, {x: 50}, 1.2 + (i * 0.2), {
					ease: FlxEase.elasticOut,
					onComplete: function(flxTween:FlxTween)
					{
						firstStart = false;
						changeItem();
					}
				});
			else
				menuItem.x = 50;
		}

		var versionShit:FlxText = new FlxText(-350, FlxG.height - 24, 0, "v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.antialiasing = true;
		versionShit.setFormat(LangUtil.getFont('aller'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		if (firstStart)
			FlxTween.tween(versionShit, {x: 5}, 1.2, {
				ease: FlxEase.elasticOut,
				onComplete: function(flxTween:FlxTween)
				{
					firstStart = false;
					changeItem();
				}
			});
		else
			versionShit.x = 5;

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
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

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

			#if debug
			if (FlxG.keys.justPressed.I)
				FlxG.switchState(new MainMenuState());

			if (FlxG.keys.justPressed.O)
			{
				trace('hello');
				FlxG.save.data.monibeaten = true;
				FlxG.save.data.sayobeaten = true;
				FlxG.save.data.natbeaten = true;
				FlxG.save.data.yuribeaten = true;
				FlxG.save.data.extrabeaten = true;
				FlxG.save.data.extra2beaten = true;
				FlxG.save.data.unlockepip = true;
				FlxG.save.data.monipopup = true;
				FlxG.save.data.sayopopup = true;
				FlxG.save.data.natpopup = true;
				FlxG.save.data.yuripopup = true;
				FlxG.save.data.extra1popup = true;
				FlxG.save.data.extra2popup = true;
				FlxG.save.data.weekUnlocked = 7;
			}
			if (FlxG.keys.justPressed.P)
			{
				trace('not beaten :(');
				FlxG.save.data.monibeaten = false;
				FlxG.save.data.sayobeaten = false;
				FlxG.save.data.natbeaten = false;
				FlxG.save.data.yuribeaten = false;
				FlxG.save.data.extrabeaten = false;
				FlxG.save.data.extra2beaten = false;
				FlxG.save.data.gfCountdown = false;
				FlxG.save.data.unlockepip = false;
				FlxG.save.data.monipopup = false;
				FlxG.save.data.sayopopup = false;
				FlxG.save.data.natpopup = false;
				FlxG.save.data.yuripopup = false;
				FlxG.save.data.extra1popup = false;
				FlxG.save.data.extra2popup = false;
				FlxG.save.data.weekUnlocked = 1;
			}
			if (FlxG.keys.justPressed.U)
			{
				FlxG.save.data.weekUnlocked += 1;
				trace('week unlocked now ' + FlxG.save.data.weekUnlocked);
			}
			#end

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

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
		menuItems.forEach(function(spr:FlxSprite)
		{
			// spr.screenCenter(X);
		});
	}

	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new DokiStoryState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new DokiFreeplayState());
				trace("Freeplay Menu Selected");
			case 'credits':
				if (FlxG.keys.pressed.G)
				{
					// Hueh keeping this forever
					#if FEATURE_GAMEJOLT
					GameJoltAPI.getTrophy(151164);
					#end
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://www.youtube.com/watch?v=0MW9Nrg_kZU", "&"]);
					#else
					FlxG.openURL('https://www.youtube.com/watch?v=0MW9Nrg_kZU');
					#end
					FlxG.switchState(new MainMenuState());
				}
				else
				{
					#if FEATURE_WEBM
					FlxG.switchState(new VideoState('assets/videos/credits/credits.webm', new MainMenuState()));
					#else
					FlxG.switchState(new MainMenuState());
					#end
				}
				trace("Credits Menu Selected");
			case 'unlock':
				trace('hello');
				FlxG.save.data.monibeaten = true;
				FlxG.save.data.sayobeaten = true;
				FlxG.save.data.natbeaten = true;
				FlxG.save.data.yuribeaten = true;
				FlxG.save.data.extrabeaten = true;
				FlxG.save.data.extra2beaten = true;
				FlxG.save.data.unlockepip = true;
				FlxG.save.data.monipopup = true;
				FlxG.save.data.sayopopup = true;
				FlxG.save.data.natpopup = true;
				FlxG.save.data.yuripopup = true;
				FlxG.save.data.extra1popup = true;
				FlxG.save.data.extra2popup = true;
				FlxG.save.data.weekUnlocked = 7;
				FlxG.switchState(new DokiFreeplayState());
			case 'options':
				FlxG.switchState(new OptionsMenu());
			case 'language':
				FlxG.switchState(new LangSelectState());
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= optionShit.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = optionShit.length - 1;

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

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);

		if ((show == 'protag' || show == 'fumo' || show == 'together1' || show == 'together' || show == 'akimonika' || show == 'monika' || show == 'yuri'
			|| show == 'natsuki' || show == 'sayori' || show == 'pixelmonika' || show == 'minusmonikapixel')
			&& curBeat % 2 == 0)
			menu_character.animation.play('play', true);
	}
}
