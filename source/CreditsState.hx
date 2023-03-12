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
import lime.utils.Assets;
import haxe.Json;
import shaders.ColorMaskShader;

#if FEATURE_FILESYSTEM
import Sys;
import sys.FileSystem;
#end

#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
#if FEATURE_GAMEJOLT
import GameJolt.GameJoltAPI;
#end

using StringTools;


typedef CreditsFile ={
	var peeps:Array<Peeps>;
	var listoroles:Array<String>;
}

typedef Peeps = {
	var realName:String;
	var iconName:String;
	var description:String;
	var twitter:String;
	var whichrole:Int;
	var funnyName:String;
	var hiddenType:String;
}

class CreditsState extends MusicBeatState
{
	var backdrop:FlxBackdrop;
	static var backdropX:Float = 0;

	var curSelected:Int = 0;
	static var curPage:Int = 0;
	static var pageFlipped:Bool = false;

	var rolelist:Array<String> = [];
	
	private var grpNames:FlxTypedGroup<FlxText>;
	private var iconArray:Array<FlxSprite> = [];

	var funnyName:FlxText;
	var funnyDesc:FlxText;

	//hueh
	public var bufferArray:Array<Peeps> = [];
	var creditsStuff:Array<Array<Dynamic>> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits", null);
		#end

		if (pageFlipped)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			pageFlipped = false;
		}
		else
		{
			FlxG.sound.playMusic(Paths.music('pixelc'));
			Conductor.changeBPM(90);
		}

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.x = backdropX;
		backdrop.velocity.set(-16, 0);
		backdrop.scale.set(0.2, 0.2);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFF780D48, 0xFF87235D);
		add(backdrop);

		var gradient:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('gradient', 'preload'));
		gradient.antialiasing = SaveData.globalAntialiasing;
		gradient.color = 0xFF46114A;
		add(gradient);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/background'));
		bg.antialiasing = SaveData.globalAntialiasing;
		add(bg);

		var path:String = 'why';
		path = Paths.getPreloadPath('images/credits/credits.json');

		var rawJson = Assets.getText(path);
		var json:CreditsFile = cast Json.parse(rawJson);

		rolelist = json.listoroles;
		bufferArray = json.peeps;

		for (peep in bufferArray)
		{
			if (peep.whichrole == curPage)
			{
				if ((peep.hiddenType == 'drinksonme' && !SaveData.beatVA11HallA)
					|| (peep.hiddenType == 'libitina' && !SaveData.beatLibitina)
					|| (peep.hiddenType == 'libitinabefore' && SaveData.beatLibitina))
					continue;

				creditsStuff.push([peep.realName, peep.iconName, peep.description, peep.twitter, peep.whichrole, peep.funnyName]);
			}
		}

		grpNames = new FlxTypedGroup<FlxText>();
		add(grpNames);

		for (i in 0...creditsStuff.length)
		{
			//Text names
			var nameText:FlxText = new FlxText(252, 196 + (i * 43), 500, creditsStuff[i][0], 9);
			nameText.setFormat(Paths.font("riffic.ttf"), 27, FlxColor.WHITE, FlxTextAlign.LEFT);
			nameText.antialiasing = SaveData.globalAntialiasing;
			nameText.borderStyle = OUTLINE;
			nameText.borderColor = 0xFFEB489C;
			nameText.ID = i;
			grpNames.add(nameText);
		}

		for (i in 0...creditsStuff.length)
		{
			//icons
			var icon:FlxSprite = new FlxSprite(777, 216).loadGraphic(Paths.image('credits/icons/' + creditsStuff[i][1]));

			if (!Paths.fileExists('images/credits/icons/' + creditsStuff[i][1] + '.png', IMAGE))
				icon.loadGraphic(Paths.image('credits/icons/default'));

			iconArray.push(icon);
			icon.antialiasing = SaveData.globalAntialiasing;
			icon.scale.set(1.67, 1.67);
			icon.updateHitbox();
			add(icon);
		}

		funnyName = new FlxText(286, 424, 1180, "", 50);
		funnyName.setFormat(Paths.font("riffic.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF92309E);
		funnyName.scrollFactor.set();
		funnyName.borderSize = 2.4;
		funnyName.antialiasing = SaveData.globalAntialiasing;
		add(funnyName);

		funnyDesc = new FlxText(286, 550, 1180, "", 20);
		funnyDesc.setFormat(Paths.font("riffic.ttf"), 20, 0xFF92309E, CENTER);
		funnyDesc.scrollFactor.set();
		funnyDesc.borderSize = 1;
		funnyDesc.antialiasing = SaveData.globalAntialiasing;
		add(funnyDesc);

		var fg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/overlay'));
		fg.antialiasing = SaveData.globalAntialiasing;
		add(fg);

		var modRoleText:FlxText = new FlxText(50, 60, 1180, rolelist[curPage], 60);
		modRoleText.setFormat(Paths.font("riffic.ttf"), 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF92309E);
		modRoleText.borderSize = 2.4;
		modRoleText.screenCenter(X);
		modRoleText.antialiasing = SaveData.globalAntialiasing;
		add(modRoleText);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		backdropX = backdrop.x;

		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

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

			if (controls.LEFT_P)
			{
				changePage(-1);
			}

			if (controls.RIGHT_P)
			{
				changePage(1);
			}
			
			if (controls.ACCEPT)
			{
				if (creditsStuff[curSelected][0] == 'Jorge - SunSpirit' && FlxG.keys.pressed.G)
				{
					#if FEATURE_GAMEJOLT
					GameJoltAPI.getTrophy(0);
					#end

					CoolUtil.openURL('https://www.youtube.com/watch?v=0MW9Nrg_kZU');
				}
				else if (creditsStuff[curSelected][3] != '')
				{
					CoolUtil.openURL(creditsStuff[curSelected][3]);
				}
			}

			if (controls.BACK)
			{
				curPage = 0;
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;
		var bullShit:Int = 0;

		if (curSelected >= creditsStuff.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = creditsStuff.length - 1;

		trace(curSelected);

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0;
		}
		if (iconArray.length > 0)
			iconArray[curSelected].alpha = 1;

		for (item in grpNames.members)
		{
			item.ID = bullShit - curSelected;
			bullShit++;

			FlxTween.cancelTweensOf(item);

			if (curSelected >= 6 && curSelected <= creditsStuff.length - 4)
				FlxTween.tween(item, {y: 454 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});

			if (curSelected <= 5)
			{
				FlxTween.cancelTweensOf(item);

				if (curSelected == 0)
					FlxTween.tween(item, {y: 196 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});
				if (curSelected == 1)
					FlxTween.tween(item, {y: 239 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});
				if (curSelected == 2)
					FlxTween.tween(item, {y: 282 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});
				if (curSelected == 3)
					FlxTween.tween(item, {y: 325 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});
				if (curSelected == 4)
					FlxTween.tween(item, {y: 368 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});
				if (curSelected == 5)
					FlxTween.tween(item, {y: 411 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});
			}

			if (creditsStuff.length >= 10 && curSelected >= creditsStuff.length - 4)
			{
				FlxTween.cancelTweensOf(item);

				if (curSelected == creditsStuff.length - 4)
					FlxTween.tween(item, {y: 454 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});
				if (curSelected == creditsStuff.length - 3)
					FlxTween.tween(item, {y: 497 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});
				if (curSelected == creditsStuff.length - 2)
					FlxTween.tween(item, {y: 540 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});
				if (curSelected == creditsStuff.length - 1)
					FlxTween.tween(item, {y: 583 + (item.ID * 43)}, 0.5, {ease: FlxEase.circOut});
			}

			item.setBorderStyle(OUTLINE, 0xFFEB489C, 1, 1);

			if (item.ID == 0)
				item.setBorderStyle(OUTLINE, 0xFFFFA7F3, 1, 1);
		}

		if (creditsStuff[curSelected][5] != null)
			funnyName.text = creditsStuff[curSelected][5];
		else
			funnyName.text = creditsStuff[curSelected][0];
		funnyDesc.y = funnyName.y + funnyName.height;
		funnyDesc.text = creditsStuff[curSelected][2];
	}

	function changePage(huh:Int = 0)
	{
		pageFlipped = true;
		curPage += huh;

		if (curPage >= rolelist.length)
			curPage = 0;
		if (curPage < 0)
			curPage = rolelist.length - 1;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		LoadingState.loadAndSwitchState(new CreditsState(), false);
	}
}
