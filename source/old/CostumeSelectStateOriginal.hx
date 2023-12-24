package old;

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
import shaders.ColorMaskShader;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
#if FEATURE_GAMEJOLT
import GameJolt.GameJoltAPI;
#end

using StringTools;

class CostumeSelectStateOriginal extends MusicBeatState
{
	var curSelected:Int = 0;
	var costumeSelected:Int = 0;

	var costumeint:Int = 0;

	var hueh:Int = 0;

	var dad:Character;

	var currentcharacter:FlxText;
	var currentcostume:FlxText;

	var crediticons:FlxTypedGroup<FlxSprite>;
	var fixdiff:FlxTypedGroup<FlxSprite>;

	var character:Array<String> = ['bf-doki', 'gf-realdoki', 'monika', 'sayori', 'natsuki', 'yuri', 'protag'];

	// these are dependent on language because of russian :)
	var visualcharacter:Array<String> = [
		LangUtil.getString('charBF', 'costume'),
		LangUtil.getString('charGF', 'costume'),
		LangUtil.getString('charMoni', 'costume'),
		LangUtil.getString('charSayo', 'costume'),
		LangUtil.getString('charNat', 'costume'),
		LangUtil.getString('charYuri', 'costume'),
		LangUtil.getString('charPro', 'costume')
	];

	var visualcostume:Array<String> = [''];

	private var grpControls:FlxTypedGroup<FlxText>;
	private var grpControlshueh:FlxTypedGroup<FlxText>;

	var newInput:Bool = true;
	var selectingcostume:Bool = false;
	var logo:FlxSprite;

	var flavorBar:FlxSprite;
	var backdrop:FlxBackdrop;
	var logoBl:FlxSprite;
	var grpLocks:FlxTypedGroup<FlxSprite>;
	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var costumeLabel:FlxText;
	var controlLabel:FlxText;
	var flavorText:FlxText;

	var costumes:Array<Dynamic> = [
		// leave the first one blank for default costumes
		['', 'casual', 'minus', 'soft', 'mrcow', 'blueskies', 'holofunk'], // Boyfriend
		['', 'casual', 'minus', 'soft', 'blueskies', 'holofunk', 'tbd'], // Girlfriend
		['', 'casual', 'valentine', 'hex', 'senpai', 'blueskies', 'vigilante'], // Monika
		['', 'casual', 'sleepwear', 'picnic', 'grace', 'zipper', 'blueskies'], // Sayori
		['', 'casual', 'skater', 'kapi', 'sunday', 'hank', 'blueskies'], // Natsuki
		['', 'casual', 'derby', 'picnic', 'taki', 'tabi', 'blueskies'], // Yuri
		['', 'casual', 'hotline', 'blueskies'] // Protag
	];

	// costume unlocks
	var costumeUnlocked:Array<Dynamic> = [
		// Boyfriend
		[
			true, // Uniform, unlocked by default
			true, // Regular, unlocked by default
			true, // Minus, unlocked by default
			SaveData.getSoftSave(), // Soft, save check for Soft Mod
			SaveData.getRenpySave() || SaveData.getDDLCPSave(), // Mr. Cow, save checks for DDLC. If you played this mod and don't have this unlocked then I am extremely dissappointed in you.
			Highscore.getAccuracyUnlock('Your Demise', 2) >= 90, // Blue Skies, 90% Accuracy on Your Demise
			SaveData.unlockHFCostume // HoloFunk, unlocked by clicking on sticker
		],
		// Girlfriend
		[
			true, // Uniform, unlocked by default
			true, // Regular, unlocked by default
			true, // Minus, unlocked by default
			SaveData.getSoftSave(), // Soft Pico, save check for Soft Mod
			Highscore.getMirrorScore('Love n Funkin', 1) > 0, // Blue Skies, play Love n' Funkin' on Mirror Mode
			SaveData.unlockHFCostume, // HoloFunk, unlocked by clicking on sticker
			SaveData.beatLibitina // TBD-tan, beat Libitina
		],
		// Monika
		[
			true, // Uniform, unlocked by default
			true, // Casual, unlocked by default
			Highscore.getScore('Epiphany', 2) > 0, // valentine, unlocks if Epiphany with Lyrics is beaten
			Highscore.getAccuracyUnlock('Glitcher (Monika Mix)', 2) >= 90, // Festival, unlocks if Glitcher (Hard) is 90%+ accuracy
			Highscore.getMirrorScore('Wilted', 1) > 0, // Friends, play Wilted on Mirror Mode
			Highscore.getMirrorScore('Reconciliation', 2) > 0, // Blue Skies, play Reconciliation (Hard) on Mirror Mode
			SaveData.yamMonika // Vigilante, choose Monika on You and Me
		],
		// Sayori
		[
			true, // Uniform, unlocked by default
			true, // Casual, unlocked by default
			SaveData.getBadEndSave(), // Sleep Wear, save check for BAD ENDING
			SaveData.yamSayori, // Picnic, choose Sayori on You and Me
			Highscore.getAccuracyUnlock("It's Complicated (Sayori Mix)", 2) >= 90, // Festival, unlocks if It's Complicated (Hard) is 90%+ accuracy
			Highscore.getAccuracyUnlock('Constricted', 2) >= 90, // Friends, unlocks if Constricted (Hard) is 90%+ accuracy
			Highscore.getMirrorScore('My Confession', 2) > 0 // Blue Skies, play My Confession (Hard) on Mirror Mode
		],
		// Natsuki
		[
			true, // Uniform, unlocked by default
			true, // Casual, unlocked by default
			SaveData.yamNatsuki, // Skater, choose Natsuki on You and Me
			Highscore.getAccuracyUnlock('Beathoven (Natsuki Mix)', 2) >= 90, // Festival, unlocks if Beathoven (Hard) is 90%+ accuracy
			SaveData.getSundaySave(), // Friends, save checks for Sunday
			SaveData.unlockAntipathyCostume, // Antipathy, unlocked by clicking on artwork
			Highscore.getMirrorScore('Baka', 2) > 0 // Blue Skies, play Baka (Hard) on Mirror Mode
		],
		// Yuri
		[
			true, // Uniform, unlocked by default
			true, // Casual, unlocked by default
			Highscore.getMirrorScore('Catfight', 2) > 0, // Derby, pick Yuri on Catfight (Hard)
			SaveData.yamYuri, // Picnic, choose Yuri on You and Me
			Highscore.getAccuracyUnlock('Crucify (Yuri Mix)', 2) >= 90, // Festival, unlocks if Crucify (Hard) is 90%+ accuracy
			SaveData.getTabiSave(), // Friends, save check for Tabi
			Highscore.getMirrorScore('Deep Breaths', 2) > 0 // Blue Skies, play Deep Breaths (Hard) on Mirror Mode
		],
		// Protag
		[
			true, // Uniform, unlocked by default
			true, // Casual, unlocked by default
			SaveData.getFlixelSave('Hotline024', 'Hotline024'), // Hotline, save check for Hotline 024
			SaveData.yamLoss // Blue Skies, fail You and Me by not picking a doki
		]
	];

	var viscostumes:Array<Dynamic> = [
		// Boyfriend
		[
			LangUtil.getString('nameDefault', 'costume'),
			LangUtil.getString('nameRegular', 'costume'),
			LangUtil.getString('nameMinus', 'costume'),
			LangUtil.getString('nameSoft', 'costume'),
			LangUtil.getString('nameCow', 'costume'),
			LangUtil.getString('nameBlueSky', 'costume'),
			LangUtil.getString('nameHoloFunk', 'costume')
		],
		// Girlfriend
		[
			LangUtil.getString('nameDefault', 'costume'),
			LangUtil.getString('nameRegular', 'costume'),
			LangUtil.getString('nameMinus', 'costume'),
			LangUtil.getString('nameSoftPico', 'costume'),
			LangUtil.getString('nameBlueSky', 'costume'),
			LangUtil.getString('nameHoloFunk', 'costume'),
			LangUtil.getString('nameTBD', 'costume')
		],
		// Monika
		[
			LangUtil.getString('nameDefault', 'costume'),
			LangUtil.getString('nameCasual', 'costume'),
			LangUtil.getString('nameValentine', 'costume'),
			LangUtil.getString('nameFestival', 'costume'),
			LangUtil.getString('nameFriends', 'costume'),
			LangUtil.getString('nameBlueSky', 'costume'),
			LangUtil.getString('nameVigilante', 'costume')
		],
		// Sayori
		[
			LangUtil.getString('nameDefault', 'costume'),
			LangUtil.getString('nameCasual', 'costume'),
			LangUtil.getString('nameSleepWear', 'costume'),
			LangUtil.getString('namePicnic', 'costume'),
			LangUtil.getString('nameFestival', 'costume'),
			LangUtil.getString('nameFriends', 'costume'),
			LangUtil.getString('nameBlueSky', 'costume')
		],
		// Natsuki
		[
			LangUtil.getString('nameDefault', 'costume'),
			LangUtil.getString('nameCasual', 'costume'),
			LangUtil.getString('nameSkater', 'costume'),
			LangUtil.getString('nameFestival', 'costume'),
			LangUtil.getString('nameFriends', 'costume'),
			LangUtil.getString('nameHank', 'costume'),
			LangUtil.getString('nameBlueSky', 'costume')
		],
		// Yuri
		[
			LangUtil.getString('nameDefault', 'costume'),
			LangUtil.getString('nameCasual', 'costume'),
			LangUtil.getString('nameDerby', 'costume'),
			LangUtil.getString('namePicnic', 'costume'),
			LangUtil.getString('nameFestival', 'costume'),
			LangUtil.getString('nameFriends', 'costume'),
			LangUtil.getString('nameBlueSky', 'costume')
		],
		// Protag
		[
			LangUtil.getString('nameDefault', 'costume'),
			LangUtil.getString('nameCasual', 'costume'),
			LangUtil.getString('nameHotline', 'costume'),
			LangUtil.getString('nameBlueSky', 'costume')
		]
	];

	var costumesdesc:Array<Dynamic> = [
		// Boyfriend
		[
			LangUtil.getString('descDefault_BF', 'costume'),
			//"Howdy I'm flowey, Flowey the flower! Boy I'm surprised you're here! Right now I'm being used as a placeholder line cause jorge can't think of anything good to say! Even correcting mistakes taht he caqtches while typing this. Hahaha, maybe you should find something better to or write instead of being a dumb IDIOT writing this down :)",
			//Jorge thats mean don't say that :(
			//I needed a long description and flowey took over sorry :(
			//Not cool squidward, dont say that again
			LangUtil.getString('descRegular_BF', 'costume'),
			LangUtil.getString('descMinus_BF', 'costume'),
			LangUtil.getString('descSoft', 'costume'),
			LangUtil.getString('descCow', 'costume'),
			LangUtil.getString('descBlueSky_BF', 'costume'),
			LangUtil.getString('descHoloFunk_BF', 'costume')
		],
		// Girlfriend
		[
			LangUtil.getString('descDefault_GF', 'costume'),
			LangUtil.getString('descRegular_GF', 'costume'),
			LangUtil.getString('descMinusGF', 'costume'),
			LangUtil.getString('descSoftPico', 'costume'),
			LangUtil.getString('descBlueSky_GF', 'costume'),
			LangUtil.getString('descHoloFunk_GF', 'costume'),
			LangUtil.getString('descTBD', 'costume')
		],
		// Monika
		[
			LangUtil.getString('descDefault_MO', 'costume'),
			LangUtil.getString('descCasual_MO', 'costume'),
			LangUtil.getString('descValentine_MO', 'costume'),
			LangUtil.getString('descFestival_MO', 'costume'),
			LangUtil.getString('descFriends_MO', 'costume'),
			LangUtil.getString('descBlueSky_MO', 'costume'),
			LangUtil.getString('descVigilante', 'costume')
		],
		// Sayori
		[
			LangUtil.getString('descDefault_SA', 'costume'),
			LangUtil.getString('descCasual_SA', 'costume'),
			LangUtil.getString('descSleepWear', 'costume'),
			LangUtil.getString('descPicnic_SA', 'costume'),
			LangUtil.getString('descFestival_SA', 'costume'),
			LangUtil.getString('descFriends_SA', 'costume'),
			LangUtil.getString('descBlueSky_SA', 'costume')
		],
		// Natsuki
		[
			LangUtil.getString('descDefault_NA', 'costume'),
			LangUtil.getString('descCasual_NA', 'costume'),
			LangUtil.getString('descSkater_NA', 'costume'),
			LangUtil.getString('descFestival_NA', 'costume'),
			LangUtil.getString('descFriends_NA', 'costume'),
			LangUtil.getString('descHank', 'costume'),
			LangUtil.getString('descBlueSky_NA', 'costume')
		],
		// Yuri
		[
			LangUtil.getString('descDefault_YU', 'costume'),
			LangUtil.getString('descCasual_YU', 'costume'),
			LangUtil.getString('descDerby_YU', 'costume'),
			LangUtil.getString('descPicnic_YU', 'costume'),
			LangUtil.getString('descFestival_YU', 'costume'),
			LangUtil.getString('descFriends_YU', 'costume'),
			LangUtil.getString('descBlueSky_YU', 'costume')
		],
		// Protag
		[
			LangUtil.getString('descDefault_PR', 'costume'),
			LangUtil.getString('descCasual_PR', 'costume'),
			LangUtil.getString('descHotline', 'costume'),
			LangUtil.getString('descBlueSky_PR', 'costume')
		]
	];

	var unlockreq:Array<Dynamic> = [
		// Boyfriend
		[
			"How the hell are you seeing this?! I'm unlocked by default!",
			"How the hell are you seeing this?! I'm unlocked by default!",
			"How the hell are you seeing this?! I'm unlocked by default!",
			LangUtil.getString('unlockSoft', 'costume'),
			LangUtil.getString('unlockCow', 'costume'),
			LangUtil.getString('unlockBlueSkies_BF', 'costume'),
			LangUtil.getString('unlockHoloFunk', 'costume')
		],
		// Girlfriend
		[
			"How the hell are you seeing this?! I'm unlocked by default!",
			"How the hell are you seeing this?! I'm unlocked by default!",
			"How the hell are you seeing this?! I'm unlocked by default!",
			LangUtil.getString('unlockSoft', 'costume'),
			LangUtil.getString('unlockBlueSkies_GF', 'costume'),
			LangUtil.getString('unlockHoloFunk', 'costume'),
			LangUtil.getString('unlockTBD', 'costume')
		],
		// Monika
		[
			"How the hell are you seeing this?! I'm unlocked by default!",
			"How the hell are you seeing this?! I'm unlocked by default!",
			LangUtil.getString('unlockValentine', 'costume'),
			LangUtil.getString('unlockFestival_MO', 'costume'),
			LangUtil.getString('unlockFriends_MO', 'costume'),
			LangUtil.getString('unlockBlueSkies_MO', 'costume'),
			LangUtil.getString('unlockVigilante', 'costume')
		],
		// Sayori
		[
			"How the hell are you seeing this?! I'm unlocked by default!",
			"How the hell are you seeing this?! I'm unlocked by default!",
			LangUtil.getString('unlockSleepWear', 'costume'),
			LangUtil.getString('unlockPicnic_SA', 'costume'),
			LangUtil.getString('unlockFestival_SA', 'costume'),
			LangUtil.getString('unlockFriends_SA', 'costume'),
			LangUtil.getString('unlockBlueSkies_SA', 'costume')
		],
		// Natsuki
		[
			"How the hell are you seeing this?! I'm unlocked by default!",
			"How the hell are you seeing this?! I'm unlocked by default!",
			LangUtil.getString('unlockSkater', 'costume'),
			LangUtil.getString('unlockFestival_NA', 'costume'),
			LangUtil.getString('unlockFriends_NA', 'costume'),
			LangUtil.getString('unlockHank', 'costume'),
			LangUtil.getString('unlockBlueSkies_NA', 'costume')
		],
		// Yuri
		[
			"How the hell are you seeing this?! I'm unlocked by default!",
			"How the hell are you seeing this?! I'm unlocked by default!",
			LangUtil.getString('unlockDerby', 'costume'),
			LangUtil.getString('unlockPicnic_YU', 'costume'),
			LangUtil.getString('unlockFestival_YU', 'costume'),
			LangUtil.getString('unlockFriends_YU', 'costume'),
			LangUtil.getString('unlockBlueSkies_YU', 'costume')
		],
		// Protag
		[
			"How the hell are you seeing this?! I'm unlocked by default!",
			"How the hell are you seeing this?! I'm unlocked by default!",
			LangUtil.getString('unlockHotline', 'costume'),
			LangUtil.getString('unlockBlueSkies_PR', 'costume')
		]
	];

	override function create()
	{
		Character.ingame = false;

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		FlxG.sound.playMusic(Paths.music('disco'), 0.4);
		Conductor.changeBPM(124);

		persistentUpdate = persistentDraw = true;

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
		add(backdrop);

		preloadcharacters();

		flavorBar = new FlxSprite(0, 605).makeGraphic(1280, 63, 0xFFFF8ED0);
		flavorBar.alpha = 0.4;
		flavorBar.screenCenter(X);
		flavorBar.scrollFactor.set();
		flavorBar.visible = false;
		add(flavorBar);

		flavorText = new FlxText(354, 608, 933, "I'm a test, this is for scale!", 40);
		flavorText.scrollFactor.set(0, 0);
		flavorText.setFormat(LangUtil.getFont('riffic'), 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		flavorText.y += LangUtil.getFontOffset();
		flavorText.borderSize = 2;
		flavorText.borderQuality = 1;
		flavorText.antialiasing = SaveData.globalAntialiasing;
		flavorText.visible = false;
		add(flavorText);

		logo = new FlxSprite(-60, 0).loadGraphic(Paths.image('Credits_LeftSide'));
		logo.antialiasing = SaveData.globalAntialiasing;
		add(logo);

		logoBl = new FlxSprite(40, -40);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = SaveData.globalAntialiasing;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);

		grpControls = new FlxTypedGroup<FlxText>();
		add(grpControls);

		for (i in 0...visualcharacter.length)
		{
			controlLabel = new FlxText(60, (40 * i) + 370, 0, visualcharacter[i], 3);
			controlLabel.setFormat(LangUtil.getFont('riffic'), 38, FlxColor.WHITE, LEFT);
			controlLabel.y += LangUtil.getFontOffset('riffic');
			controlLabel.scale.set(0.7, 0.7);
			controlLabel.updateHitbox();
			controlLabel.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			controlLabel.antialiasing = SaveData.globalAntialiasing;
			controlLabel.ID = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (costumeUnlocked[curSelected][costumeSelected])
			flavorText.text = costumesdesc[curSelected][costumeSelected];
		else
			flavorText.text = LangUtil.getString('cmnLock') + ": " + unlockreq[curSelected][costumeSelected];

		if (!selectedSomethin)
		{
			#if debug
			var daChoice:String = character[curSelected];

			if (FlxG.keys.justPressed.F10 && selectingcostume)
			{
				AnimationDebugState.costumeoverride = costumes[curSelected][costumeSelected];
				AnimationDebugState.inGame = false;
				if (daChoice.startsWith('bf'))
					AnimationDebugState.isPlayer = true;

				MusicBeatState.switchState(new AnimationDebugState(daChoice));
			}

			//trace(costumeUnlocked[curSelected][costumeSelected]);
			
			if (FlxG.mouse.pressed && !selectingcostume)
			{
				trace(flavorText.x + " and " + flavorText.y);
				flavorText.x = (FlxG.mouse.x - flavorText.width / 2);
				flavorText.y = (FlxG.mouse.y - flavorText.height);
			}

			if (FlxG.mouse.pressed && selectingcostume)
			{
				trace(dad.x + " and " + dad.y);
				dad.x = (FlxG.mouse.x - dad.width / 2);
				dad.y = (FlxG.mouse.y - dad.height);
			}
			#end

			if (controls.UP_P && !selectingcostume)
			{
				changeItem(-1);
			}

			if (controls.DOWN_P && !selectingcostume)
			{
				changeItem(1);
			}

			if (controls.DOWN_P && selectingcostume)
			{
				changecostume(1, true);
			}

			if (controls.UP_P && selectingcostume)
			{
				changecostume(-1, false);
			}
			if (FlxG.keys.pressed.C && selectingcostume && curSelected == 5)
			{
				if (costumes[curSelected][costumeSelected] == '')
					loadcharacter('yuri-crazy', true, 'hueh'); // I need it to use default so forcing a null costume works :)
				else
					loadcharacter('yuri-crazy', false, costumes[curSelected][costumeSelected]);				
			}
			if (controls.BACK && !selectingcostume)
			{
				selectedSomethin = true;
				SaveData.save();
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new DokiFreeplayState());
			}
			if (controls.BACK && selectingcostume)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				costumeselect(false);
			}
			if (controls.ACCEPT)
				if (!selectingcostume)
					costumeselect(true);
				else
					savecostume();
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	function loadcharacter(char:String, selected:Bool, ?costume:String)
	{
		//I'm pissed, gotta throw this here too cause offsets break due to the costumeoverride being blank
		var charCostume:String = costume;
		if (Character.loadaltcostume && (costume == '' || costume == null))
			switch (char)
			{
				case 'protag':
					charCostume = SaveData.protagcostume;
				case 'monika':
					charCostume = SaveData.monikacostume;
				case "yuri" | "yuri-crazy":
					charCostume = SaveData.yuricostume;
				case 'sayori':
					charCostume = SaveData.sayoricostume;
				case 'natsuki':
					charCostume = SaveData.natsukicostume;
				case 'gf-pixel' | 'gf-realdoki':
					charCostume = SaveData.gfcostume;
				case 'bf-doki':
					charCostume = SaveData.bfcostume;
			}
		var posX:Int = 0;
		var posY:Int = 0;
		switch (curSelected)
		{
			case 6:
				posX = 642;
				posY = 314;
			case 5:
				posX = 612;
				posY = 298;
			case 4:
				posX = 636;
				posY = 279;
			case 3:
				posX = 595;
				posY = 291;
			case 2:
				posX = 500;
				posY = 269;
			case 1:
				posX = 446;
				posY = 4;
			case 0:
				posX = 600;
				posY = 219;	
		}
		Character.isFestival = false;
		Character.loadaltcostume = true;
		remove(dad);
		dad = new Character(posX, posY, char, false, charCostume);
		add(dad);
		dad.scale.set(0.7, 0.7);
		dad.updateHitbox();
		dad.dance();
		dad.x += dad.positionArray[0];
		dad.y += dad.positionArray[1];
		dad.flipX = false;

		if (dad.facing != dad.initFacing)
		{
			dad.facing = FlxObject.RIGHT;
		}

	}

	function costumeselect(goku:Bool)
	{
		var daChoice:String = character[curSelected];

		if (goku)
		{
			flavorText.visible = true;
			flavorBar.visible = true;

			FlxG.sound.play(Paths.sound('confirmMenu'));
			visualcostume = viscostumes[curSelected];
			trace(visualcostume);

			grpControlshueh = new FlxTypedGroup<FlxText>();
			add(grpControlshueh);

			for (i in 0...costumes[curSelected].length)
			{
				hueh = costumes[curSelected].length;

				if (costumeUnlocked[curSelected][i])
					costumeLabel = new FlxText(60, (40 * i) + 370, 0, visualcostume[i], 3);
				else
					costumeLabel = new FlxText(60, (40 * i) + 370, 0, "???", 3);

				costumeLabel.setFormat(LangUtil.getFont('riffic'), 38, FlxColor.WHITE, LEFT);
				costumeLabel.y += LangUtil.getFontOffset('riffic');
				costumeLabel.scale.set(0.7, 0.7);
				costumeLabel.updateHitbox();
				costumeLabel.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
				costumeLabel.antialiasing = SaveData.globalAntialiasing;
				costumeLabel.ID = i;
				grpControlshueh.add(costumeLabel);
			}

			costumeSelected = 0;
			selectingcostume = true;
			grpControls.visible = false;

			changecostume();
		}
		else
		{
			flavorText.visible = false;
			flavorBar.visible = false;
			remove(grpControlshueh);
			costumeSelected = 0;
			selectingcostume = false;
			grpControls.visible = true;
			loadcharacter(daChoice, false);
		}
	}

	inline function preloadcharacters()
	{
		for (i in 0...character.length)
		{
			for (j in 0...costumes[i].length)
			{
				var costume:String = costumes[i][j];

				if (costume == '')
					costume = 'hueh';

				loadcharacter(character[i], false, costume);
			}
		}
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected += huh;

		if (curSelected >= character.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = character.length - 1;
		var daChoice:String = character[curSelected];

		if (!selectingcostume)
			loadcharacter(daChoice, false);

		grpControls.forEach(function(txt:FlxText)
		{
			if (txt.ID == curSelected)
				txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
			else
				txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
		});
	}

	function changecostume(huh:Int = 0, goingforward:Bool = true)
	{
		var daChoice:String = character[curSelected];
		FlxG.sound.play(Paths.sound('scrollMenu'));
		costumeSelected += huh;

		trace(hueh);

		if (costumeSelected >= hueh)
			costumeSelected = 0;
		if (costumeSelected < 0)
			costumeSelected = hueh - 1;

		if (costumes[curSelected][costumeSelected] == '')
			loadcharacter(daChoice, true, 'hueh'); //I need it to use default so forcing a null costume works :)
		else
			loadcharacter(daChoice, true, costumes[curSelected][costumeSelected]);

		if (costumeUnlocked[curSelected][costumeSelected])
			dad.color = 0xFFFFFF;
		else
			dad.color = 0x000000;

		if (grpControlshueh != null)
		{
			grpControlshueh.forEach(function(txt:FlxText)
			{
				if (txt.ID == costumeSelected)
					txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
				else
					txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			});
		}
	}

	function savecostume()
	{
		var daChoice:String = character[curSelected];

		if (costumeUnlocked[curSelected][costumeSelected] #if !PUBLIC_BUILD || FlxG.keys.pressed.F #end)
		{
			switch (curSelected)
			{
				case 6:
					SaveData.protagcostume = costumes[curSelected][costumeSelected];
				case 5:
					SaveData.yuricostume = costumes[curSelected][costumeSelected];
				case 4:
					SaveData.natsukicostume = costumes[curSelected][costumeSelected];

					if (costumeSelected == 0 && FlxG.keys.pressed.B)
						SaveData.natsukicostume = "buff";
				case 3:
					SaveData.sayoricostume = costumes[curSelected][costumeSelected];
				case 2:
					SaveData.monikacostume = costumes[curSelected][costumeSelected];

					if (costumeSelected == 1 && (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT))
						SaveData.monikacostume = "casuallong";
				case 1:
					SaveData.gfcostume = costumes[curSelected][costumeSelected];
					
					if (costumeSelected == 0 && FlxG.keys.pressed.B && SaveData.beatCatfight)
						SaveData.gfcostume = "sayo";
					if (costumeSelected == 1 && (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT))
						SaveData.gfcostume = "christmas";
				default:
					SaveData.bfcostume = costumes[curSelected][costumeSelected];

					// Variations
					if (costumeSelected == 0 && FlxG.keys.pressed.B)
						SaveData.bfcostume = "sutazu";
					if (costumeSelected == 1 && (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT))
						SaveData.bfcostume = "christmas";
					if (costumeSelected == 2 && FlxG.keys.pressed.LEFT)
						SaveData.bfcostume = "minus-yellow";
					if (costumeSelected == 2 && FlxG.keys.pressed.RIGHT)
						SaveData.bfcostume = "minus-mean";
					if (costumeSelected == 3 && (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT))
						SaveData.bfcostume = "soft-classic";
					if (costumeSelected == 6 && (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT))
						SaveData.bfcostume = "aloe-classic";
			}

			SaveData.save();
			loadcharacter(daChoice, true);

			if (daChoice == "natsuki" && costumeSelected == 0 && SaveData.natsukicostume == "buff")
				FlxG.sound.play(Paths.sound('buff'));
			else
				FlxG.sound.play(Paths.sound('confirmMenu'));
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);

		if (curBeat % 2 == 0)
			dad.dance();
		else if (curBeat % 2 != 0 && dad.danceIdle)
			dad.dance();
	}
}
