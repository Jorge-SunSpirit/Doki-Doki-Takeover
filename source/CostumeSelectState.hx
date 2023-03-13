package;

import Controls.KeyboardScheme;
import haxe.Json;
import lime.utils.Assets;
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

typedef CostumeData =
{
	var data:String;
	var name:String;
	var desc:String;
	var color:String;
	@:optional var unlock:String;
}

typedef CostumeCharacter =
{
	var id:String;
	var charName:String;
	var costumes:Array<CostumeData>;
}

typedef CostumeJSON =
{
	var list:Array<CostumeCharacter>;
}

class CostumeSelectState extends MusicBeatState
{
	var curSelected:Int = 0;
	var costumeSelected:Int = 0;
	var hueh:Int = 0;
	var chara:FlxSprite;
	private var grpControls:FlxTypedGroup<FlxText>;
	private var grpControlshueh:FlxTypedGroup<FlxText>;
	var selectingcostume:Bool = false;
	var logo:FlxSprite;

	var flavorBar:FlxSprite;
	var backdrop:FlxBackdrop;
	var logoBl:FlxSprite;
	var costumeLabel:FlxText;
	var controlLabel:FlxText;
	var flavorText:FlxText;
	var colorShader:ColorMask = new ColorMask(0xFFFDFFFF, 0xFFFDDBF1);

	var colorTween1:FlxSprite = new FlxSprite(-9000, -9000).makeGraphic(1, 1, 0xFFFDFFFF);
	var colorTween2:FlxSprite = new FlxSprite(-9000, -9000).makeGraphic(1, 1, 0xFFFDDBF1);

	var character:Array<String> = ['bf', 'gf', 'monika', 'sayori', 'natsuki', 'yuri', 'protag'];
	// costume unlocks
	var costumeUnlocked:Array<Dynamic> = [
		// Boyfriend
		[
			true, // Uniform, unlocked by default
			true, // Regular, unlocked by default
			true, // Minus, unlocked by default
			CoolUtil.flixelSaveCheck('Disky', 'Soft Mod') || SaveData.unlockSoftCostume, // Soft, save check for Soft Mod or mirror mode It's complicated with festy costume
			CoolUtil.renpySaveCheck() || CoolUtil.ddlcpSaveCheck() || SaveData.unlockMrCowCostume, // Mr. Cow, save checks for DDLC. If you played this mod and don't have this unlocked then I am extremely dissappointed in you.
			Highscore.getAccuracyUnlock('Your Demise', 2) >= 90, // Blue Skies, 90% Accuracy on Your Demise
			SaveData.unlockHFCostume // HoloFunk, unlocked by clicking on sticker
		],
		// Girlfriend
		[
			true, // Uniform, unlocked by default
			true, // Regular, unlocked by default
			true, // Minus, unlocked by default
			CoolUtil.flixelSaveCheck('Disky', 'Soft Mod') || SaveData.unlockSoftCostume, // Soft Pico, save check for Soft Mod or mirror mode It's complicated with festy costume
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
			CoolUtil.flixelSaveCheck('Team TBD', 'DokiTakeover', 'teamtbd', 'badending') || CoolUtil.flixelSaveCheck(null, null, 'TeamTBD', 'BadEnding', true) || Highscore.getMirrorScore('Joyride', 2) > 0, // Sleep Wear, save check for BAD ENDING
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
			CoolUtil.flixelSaveCheck('kadedev', 'Vs Sunday') || CoolUtil.flixelSaveCheck('kadedev', 'Vs Sunday WITH SHADERS') || Highscore.getMirrorScore('Baka', 2) > 0, // Friends, save checks for Sunday
			SaveData.unlockAntipathyCostume, // Antipathy, unlocked by clicking on artwork
			Highscore.getScore('Catfight', 1) > 0 // Blue Skies, pick Natsu on Catfight (Hard)
		],
		// Yuri
		[
			true, // Uniform, unlocked by default
			true, // Casual, unlocked by default
			Highscore.getMirrorScore('Catfight', 2) > 0, // Derby, pick Yuri on Catfight (Hard)
			SaveData.yamYuri, // Picnic, choose Yuri on You and Me
			Highscore.getAccuracyUnlock('Crucify (Yuri Mix)', 2) >= 90, // Festival, unlocks if Crucify (Hard) is 90%+ accuracy
			CoolUtil.flixelSaveCheck('Homskiy', 'Tabi', 'homskiy', 'tabi') || Highscore.getMirrorScore('Obsession', 2) > 0, // Friends, save check for Tabi
			Highscore.getMirrorScore('Shrinking Violet', 2) > 0 // Blue Skies, play Deep Breaths (Hard) on Mirror Mode
		],
		// Protag
		[
			true, // Uniform, unlocked by default
			true, // Casual, unlocked by default
			CoolUtil.flixelSaveCheck('Hotline024', 'Hotline024') || Highscore.getMirrorScore('Deep Breaths', 2) > 0 && Highscore.getMirrorScore('Poems n Thorns', 2) > 0, // Hotline, save check for Hotline 024
			SaveData.yamLoss // Blue Skies, fail You and Me by not picking a doki
		]
	];
	var costumeJSON:CostumeJSON = null;

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

		var costumestring:String = Assets.getText(Paths.json('costumeData'));

		try {
			costumeJSON = cast Json.parse(costumestring);
		} catch (ex) {
			trace("Costume JSON cannot be found. \n" + costumestring);
		}

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = colorShader.shader;
		add(backdrop);

		chara = new FlxSprite(522, 9).loadGraphic(Paths.image('costume/bf', 'preload'));
		chara.antialiasing = SaveData.globalAntialiasing;
		chara.scale.set(0.7, 0.7);
		chara.updateHitbox();
		add(chara);

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

		for (i in 0...costumeJSON.list.length)
		{
			var id:String = LangUtil.getString(costumeJSON.list[i].charName, 'costume');

			controlLabel = new FlxText(60, (40 * i) + 370, 0, id, 3);
			controlLabel.setFormat(LangUtil.getFont('riffic'), 38, FlxColor.WHITE, CENTER);
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
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
			
		if (!selectedSomethin)
		{
			#if debug
			var daChoice:String = character[curSelected];

			var selection = costumeJSON.list[curSelected].costumes[costumeSelected];
			if (FlxG.keys.justPressed.F10 && selectingcostume)
			{
				AnimationDebugState.costumeoverride = selection.data;
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
				trace(chara.x + " and " + chara.y);
				chara.x = (FlxG.mouse.x - chara.width / 2);
				chara.y = (FlxG.mouse.y - chara.height);
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
				
				// Initial bug is that, if you have a selected character, but
				// try to select a locked character, and then hit ESC, the
				// selected character is rendered black
				// This fix should hopefully resolve it.

				if (chara.color == 0x000000)
					chara.color = 0xFFFFFF;
			}
			if (controls.ACCEPT)
				if (!selectingcostume)
					costumeselect(true);
				else
					savecostume();
		}

		colorShader.color1 = colorTween1.color;
		colorShader.color2 = colorTween2.color;
	}

	function loadcharacter(char:String, ?costume:String, ?forceColor:FlxColor = 0xFFFDDBF1)
	{
		//I'm pissed, gotta throw this here too cause offsets break due to the costumeoverride being blank
		//trace(costume);
		var charCostume:String = costume;
		if (charCostume == '' || charCostume == null)
		{
			switch (char)
			{
				case 'protag':
					charCostume = SaveData.protagcostume;
				case 'monika':
					charCostume = SaveData.monikacostume;
				case "yuri":
					charCostume = SaveData.yuricostume;
				case 'sayori':
					charCostume = SaveData.sayoricostume;
				case 'natsuki':
					charCostume = SaveData.natsukicostume;
				case 'gf':
					charCostume = SaveData.gfcostume;
				case 'bf':
					charCostume = SaveData.bfcostume;
			}
		}
		//trace(charCostume);
		Character.isFestival = false;
		var barColor:FlxColor = forceColor;
		if (costumeJSON.list[curSelected].costumes[costumeSelected].color != null && forceColor == 0xFFFDDBF1)
			barColor = FlxColor.fromString(costumeJSON.list[curSelected].costumes[costumeSelected].color);

		FlxTween.cancelTweensOf(colorTween1);
		FlxTween.cancelTweensOf(colorTween2);

		var goku:FlxColor = FlxColor.fromHSB(barColor.hue, barColor.saturation, barColor.brightness * 1.3);

		FlxTween.color(colorTween1, 1, colorShader.color1, goku);
		FlxTween.color(colorTween2, 1, colorShader.color2, barColor);

		if (charCostume != null && charCostume != 'hueh' && charCostume != '')
			chara.loadGraphic(Paths.image('costume/' + char + '-' + charCostume, 'preload'));
		else
			chara.loadGraphic(Paths.image('costume/' + char, 'preload'));

		if (costumeUnlocked[curSelected][costumeSelected])
		{
			// JSON array is always ordered, so should be fine
			flavorText.text = LangUtil.getString(costumeJSON.list[curSelected].costumes[costumeSelected].desc, 'costume');

			// Descriptions for hidden costumes
			switch (char)
			{
				case 'natsuki':
				{
					if (charCostume == 'buff')
						flavorText.text = LangUtil.getString('descBuff_NA', 'costume');
				}
				case 'bf':
				{
					if (charCostume == 'sutazu')
						flavorText.text = LangUtil.getString('descSutazu', 'costume');
				}
				case 'gf':
				{
					if (charCostume == 'sayo')
						flavorText.text = LangUtil.getString('descSayoGF', 'costume');
				}
			}
		}
		else
		{
			var text:String = '';

			// Checking unlock value if its null or not
			if (costumeJSON.list[curSelected].costumes[costumeSelected].unlock != null)
				text = LangUtil.getString(costumeJSON.list[curSelected].costumes[costumeSelected].unlock, 'costume');
			else
				text = "Unlocked by default.";

			flavorText.text = LangUtil.getString('cmnLock') + ": " + text;
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

			var daSelection = costumeJSON.list[curSelected];
			trace(daSelection);

			grpControlshueh = new FlxTypedGroup<FlxText>();
			add(grpControlshueh);

			for (i in 0...daSelection.costumes.length)
			{
				hueh = daSelection.costumes.length;

				if (costumeUnlocked[curSelected][i])
				{
					var label:String = LangUtil.getString(daSelection.costumes[i].name, 'costume');
					costumeLabel = new FlxText(60, (40 * i) + 370, 0, label, 3);
				}
				else
					costumeLabel = new FlxText(60, (40 * i) + 370, 0, "???", 3);

				costumeLabel.setFormat(LangUtil.getFont('riffic'), 38, FlxColor.WHITE, CENTER);
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

			chara.color = 0xFFFFFF;
			loadcharacter(daChoice);
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
		{
			chara.color = 0xFFFFFF;
			loadcharacter(daChoice);
		}

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

		// Checking for data string value
		var selection = costumeJSON.list[curSelected].costumes[costumeSelected];
		if (selection.data == '')
			loadcharacter(daChoice, 'hueh')
		else
			loadcharacter(daChoice, selection.data);

		if (costumeUnlocked[curSelected][costumeSelected])
			chara.color = 0xFFFFFF;
		else
			chara.color = 0x000000;

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
		var colorthingie:FlxColor = 0xFFFDDBF1;

		// For a better way of getting data value
		var selection = costumeJSON.list[curSelected].costumes[costumeSelected];
		if (costumeUnlocked[curSelected][costumeSelected] #if !PUBLIC_BUILD || FlxG.keys.pressed.F #end)
		{
			switch (curSelected)
			{
				case 6:
					SaveData.protagcostume = selection.data;
				case 5:
					SaveData.yuricostume = selection.data;
				case 4:
					SaveData.natsukicostume = selection.data;

					if (costumeSelected == 0 && FlxG.keys.pressed.B)
						SaveData.natsukicostume = "buff";
				case 3:
					SaveData.sayoricostume = selection.data;
				case 2:
					SaveData.monikacostume = selection.data;

					if (costumeSelected == 1 && (controls.LEFT || controls.RIGHT))
						SaveData.monikacostume = "casuallong";
				case 1:
					SaveData.gfcostume = selection.data;
					
					if (costumeSelected == 0 && FlxG.keys.pressed.B && SaveData.beatCatfight)
					{
						colorthingie = 0xFF94D9FA;
						SaveData.gfcostume = "sayo";
					}
						
					if (costumeSelected == 1 && (controls.LEFT || controls.RIGHT))
						SaveData.gfcostume = "christmas";
				default:
					SaveData.bfcostume = selection.data;

					// Variations
					if (costumeSelected == 0 && FlxG.keys.pressed.B)
					{
						colorthingie = 0xFFFFADD7;
						SaveData.bfcostume = "sutazu";
					}
					if (costumeSelected == 1 && (controls.LEFT || controls.RIGHT))
						SaveData.bfcostume = "christmas";
					if (costumeSelected == 2 && controls.LEFT)
					{
						colorthingie = 0xFFF8F4C1;
						SaveData.bfcostume = "minus-yellow";
					}
					if (costumeSelected == 2 && controls.RIGHT)
					{
						colorthingie = 0xFFBFE6FF;
						SaveData.bfcostume = "minus-mean";
					}
					if (costumeSelected == 3 && (controls.LEFT || controls.RIGHT))
						SaveData.bfcostume = "soft-classic";
					if (costumeSelected == 6 && (controls.LEFT || controls.RIGHT))
						SaveData.bfcostume = "aloe-classic";
			}

			SaveData.save();
			chara.color = 0xFFFFFF;
			loadcharacter(daChoice, colorthingie);

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
	}
}
