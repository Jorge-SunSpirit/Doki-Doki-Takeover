package old;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.math.FlxMatrix;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.utils.Assets as OpenFlAssets;
import openfl.geom.Point;
import openfl.filters.ShaderFilter;
import shaders.StaticShader;
import haxe.Json;
import lime.utils.Assets;
#if FEATURE_GAMEJOLT
import GameJolt.GameJoltAPI;
#end

using StringTools;

typedef PixelCharacterData = 
{
	var name:String;
	var portraitLeft:Bool;
	var atlas:String;
}

typedef PixelCharacterJSON =
{
	var characters:Array<PixelCharacterData>;
}

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	public static var isPixel:Bool = false;
	public static var isEpiphany:Bool = false;

	var canSkip:Bool = true;
	var canFullSkip:Bool = true;

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var skipText:FlxText;

	public var finishThing:Void->Void;

	var backgroundImage:FlxSprite;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var blackscreen:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var pixelCharJSON:PixelCharacterJSON;

	public function new(isPixel:Bool = false, ?dialogueList:Array<String>)
	{
		super();

		var jsonString:String = Assets.getText(Paths.json('dialogueCharacters'));

		try {
			pixelCharJSON = cast Json.parse(jsonString);
		} catch (ex) {
			trace("Couldn't find that file. What a blunder!");
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFD8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;

		if (PlayState.SONG.song.toLowerCase() != 'epiphany')
			add(bgFade);

		if (isPixel)
		{
			new FlxTimer().start(0.83, function(tmr:FlxTimer)
			{
				bgFade.alpha += (1 / 5) * 0.7;
			}, 5);

			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}
		else
		{
			FlxTween.tween(bgFade, {alpha: 0.7}, 4.98, {ease: FlxEase.linear});
		}


		if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
		{
			initDialogueStyle(1);
		}
		else
		{
			initDialogueStyle(0);
		}

		this.dialogueList = dialogueList;

		backgroundImage = new FlxSprite();
		backgroundImage.x = 0;
		backgroundImage.y = 0;
		backgroundImage.antialiasing = !isPixel;
		backgroundImage.visible = false;
		insert(0, backgroundImage);

		if (dialogueList == null)
			return;


		skipText = new FlxText(5, 695, 640, LangUtil.getString('cmnDialogueSkip'), 40);
		skipText.scrollFactor.set(0, 0);
		skipText.setFormat(LangUtil.getFont(), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skipText.y += LangUtil.getFontOffset();
		skipText.borderSize = 2;
		skipText.borderQuality = 1;
		skipText.antialiasing = SaveData.globalAntialiasing;
		add(skipText);

		if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
			skipText.font = LangUtil.getFont('vcr');

		blackscreen = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), FlxColor.BLACK);
		blackscreen.scrollFactor.set();
		blackscreen.alpha = 0;
		dialogue = new Alphabet(0, 80, "", false, true);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	var stopspamming:Bool = false;

	var iTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (staticlol != null && SaveData.shaders)
		{
			iTime += elapsed;
			staticlol.iTime.value = [iTime];
		}

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (PlayerSettings.player1.controls.BACK && !stopspamming && canSkip && canFullSkip && dialogueStarted)
		{
			isEnding = true;
			stopspamming = true;
			remove(dialogue);
			endinstantly();
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueEnded && canSkip)
		{
			remove(dialogue);

			FlxG.sound.play(Paths.sound('clickText'), 0.8);
			enddialogue();
		}
		else if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted && canSkip)
			swagDialogue.skip();

		super.update(elapsed);
	}

	function endinstantly()
	{
		canSkip = false;
		isEnding = true;
		swagDialogue.skip();
		dialogueList.remove(dialogueList[0]);

		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut(0.5, 0);

		fadeEverything();

		new FlxTimer().start(1.2, function(tmr:FlxTimer)
		{
			if (!PlayState.isPixelUI) isPixel = false;
			isEpiphany = false;
			dialogueStarted = false;
			finishThing();
			kill();
		});
	}

	function fadeEverything()
	{
		portraitLeft.visible = false;
		portraitRight.visible = false;
		skipText.visible = false;

		if (isPixel)
		{
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				box.alpha -= 1 / 5;
				bgFade.alpha -= 1 / 5 * 0.7;
				swagDialogue.alpha -= 1 / 5;
			}, 5);
		}
		else
		{
			FlxTween.tween(box, {alpha: 0}, 1.2, {ease: FlxEase.linear});
			FlxTween.tween(bgFade, {alpha: 0}, 1.2, {ease: FlxEase.linear});
			FlxTween.tween(swagDialogue, {alpha: 0}, 1.2, {ease: FlxEase.linear});
		}
	}

	function enddialogue()
	{
		canSkip = true;
		if (dialogueList[1] == null && dialogueList[0] != null)
		{
			if (!isEnding)
			{
				canSkip = false;
				isEnding = true;

				if (FlxG.sound.music != null)
					FlxG.sound.music.fadeOut(0.5, 0);

				fadeEverything();

				new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					if (!PlayState.isPixelUI) isPixel = false;
					isEpiphany = false;
					finishThing();
					kill();
				});
			}
		}
		else
		{
			dialogueList.remove(dialogueList[0]);
			startDialogue();
		}
	}

	var isEnding:Bool = false;
	var isCommand:Bool = false;

	var commands:Array<String> = [
		'playsound',
		'startmusic',
		'endmusic',
		'glitch',
		'autoskip',
		'hideright',
		'hideleft',
		'crash',
		'showbackgroundimage',
		'hidebackground',
		'fadeout',
		'disableskip',
		'hidedialogue',
		'hidebgfade',
		'flash',
		'shake',
		'fadein',
		'swapstyle',
		'styleswap'
	];

	function startDialogue():Void
	{
		isCommand = false;
		cleanDialog();
		if (box.visible == false)
		{
			bgFade.visible = true;
			box.visible = true;
		}

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04);
		swagDialogue.completeCallback = function()
		{
			dialogueEnded = true;
		}

		dialogueEnded = false;

		if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
		{
			portraitRight.visible = false;
			portraitLeft.visible = false;

			// Go through each character in the json array
			for (char in pixelCharJSON.characters)
			{
				// Once found, go through data checks
				if (char.name == curCharacter)
				{
					// Check to see if portrait is left or right
					if (char.portraitLeft)
					{
						portraitLeft.visible = true;
						portraitLeft.frames = Paths.getSparrowAtlas(char.atlas, 'week6');
						portraitLeft.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
						portraitLeft.animation.play('enter');
					}
					else
					{
						portraitRight.visible = true;
						portraitRight.frames = Paths.getSparrowAtlas(char.atlas, 'week6');
						portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
						portraitRight.animation.play('enter');
					}
					// Break the for loop so as not to hog runtime
					break;
				}
			}

			var startswith:String = '';

			if (curCharacter.startsWith("spirit"))
				startswith = 'spirit';
			if (curCharacter.startsWith("monika"))
				startswith = 'monika';

			swagDialogue.color = 0xFF3F2021;
			swagDialogue.borderColor = 0xFFD89494;

			if (!commands.contains(curCharacter))
			{
				switch (startswith)
				{
					case 'spirit':
						if (box.frames != Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel', 'week6'))
						{
							swagDialogue.color = 0xFFFFFFFF;
							swagDialogue.borderColor = 0xFF424242;
							box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil', 'week6');
							box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn instance 1', 24, false);
							box.animation.addByIndices('normal', 'Spirit Textbox spawn instance 1', [10], "", 24);
							box.animation.play('normalOpen');
						}
					case 'monika':
						if (box.frames != Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-monika', 'week6'))
						{
							box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-monika', 'week6');
							box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
							box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
							box.animation.play('normalOpen');
						}
					default:
						if (box.frames != Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel', 'week6'))
						{
							box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel', 'week6');
							box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
							box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
							box.animation.play('normalOpen');
						}
				}
			}

		}
		else
		{
			box.offset.set(-82, -18.9);

			switch (curCharacter)
			{
				// Boyfriend animations
				case 'bf_yeah_left':
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bfText'), 0.8)];
					portraitLeft.visible = false;
					box.animation.play('bf');
					if (!portraitLeft.visible)
					{
						portraitLeft.visible = true;
						portraitLeft.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue', 'doki');
						portraitLeft.animation.addByPrefix('play', 'bf_yeah', 24, false);
						portraitLeft.animation.play('play');
						portraitLeft.flipX = true;
					}
				case 'bf_think':
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/bfText'), 0.8)];
					portraitRight.visible = false;
					box.animation.play('bf');
					if (!portraitRight.visible)
					{
						portraitRight.visible = true;
						portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue', 'doki');
						portraitRight.animation.addByPrefix('play', 'bf_think', 24, false);
						portraitRight.animation.play('play');
					}


				// all of em
				case 'all_neutral':
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0.8)];
					portraitLeft.visible = false;
					box.animation.play('blankbox');
					if (!portraitLeft.visible)
					{
						portraitLeft.visible = true;
						portraitLeft.frames = Paths.getSparrowAtlas('dialogue/all_dialogue', 'doki');
						portraitLeft.animation.addByPrefix('play', 'all_neutral', 24, false);
						portraitLeft.animation.play('play');
						portraitLeft.flipX = false;
					}
				case 'all_gasp':
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0.8)];
					portraitLeft.visible = false;
					box.animation.play('blankbox');
					if (!portraitLeft.visible)
					{
						portraitLeft.visible = true;
						portraitLeft.frames = Paths.getSparrowAtlas('dialogue/all_dialogue', 'doki');
						portraitLeft.animation.addByPrefix('play', 'all_gasp', 24, false);
						portraitLeft.animation.play('play');
						portraitLeft.flipX = false;
					}
				
				default:
					//Literally cleaned up a bunch of code with this stupid method. I'm glad but I wish I thought of this earlier
					var startswith:String = '';

					if (curCharacter.startsWith("bf"))
						startswith = 'bf';
					if (curCharacter.startsWith("sayori"))
						startswith = 'sayori';
					if (curCharacter.startsWith("monika"))
						startswith = 'monika';
					if (curCharacter.startsWith("natsuki"))
						startswith = 'natsuki';
					if (curCharacter.startsWith("yuri"))
						startswith = 'yuri';
					if (curCharacter.startsWith("gf"))
						startswith = 'gf';
					if (curCharacter.startsWith("mc"))
						startswith = 'mc';
					if (curCharacter.startsWith("zipper"))
						startswith = 'zipper';
					
					switch (startswith)
					{
						case 'bf' | 'gf' | 'mc':
							swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/' + startswith + 'Text'), 0.8)];
							portraitRight.visible = false;
							box.animation.play(startswith);
							if (!portraitRight.visible && !curCharacter.endsWith("_gone"))
							{
								portraitRight.visible = true;
								portraitRight.frames = Paths.getSparrowAtlas('dialogue/' + startswith + '_dialogue', 'doki');
								portraitRight.animation.addByPrefix('play', curCharacter, 24, true);
								portraitRight.animation.play('play');
							}
						case 'monika' | 'yuri' | 'sayori' | 'natsuki' | 'zipper': 
							swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/' + startswith + 'Text'), 0.8)];
							portraitLeft.visible = false;

							if (curCharacter.endsWith('_crazy'))
							{
								box.animation.play(curCharacter);
								box.offset.set(-55, -12);
							}
							else
								box.animation.play(startswith);
							
							if (!portraitLeft.visible && !curCharacter.endsWith("_gone"))
							{
								portraitLeft.visible = true;
								portraitLeft.frames = Paths.getSparrowAtlas('dialogue/' + startswith + '_dialogue', 'doki');
								portraitLeft.animation.addByPrefix('play', curCharacter, 24, true);
								portraitLeft.animation.play('play');
								portraitLeft.flipX = false;
							}
						default:
							if (!commands.contains(curCharacter))
								swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0.8)];

							if (curCharacter.endsWith("left"))
							{
								box.animation.play('blankbox');
								portraitLeft.visible = false;
								if (!portraitLeft.visible)
									portraitLeft.flipX = false;
							}
							if (curCharacter.endsWith("right"))
							{
								box.animation.play('blankbox');
								portraitRight.visible = false;
							}
					}
			}
		}

		// Dialogue commands
		switch (curCharacter)
		{
			case 'playsound':
				FlxG.sound.play(Paths.sound(dialogueList[0]));
				enddialogue();
			case 'startmusic':
				FlxG.sound.playMusic(Paths.music(dialogueList[0]));
				enddialogue();
			case 'endmusic':
				if (FlxG.sound.music != null)
					FlxG.sound.music.fadeOut(0.5, 0);
				enddialogue();
			case 'glitch':
				canSkip = false;
				isCommand = true;
				funnyGlitch();
			case 'autoskip':
				canSkip = false;
				swagDialogue.completeCallback = enddialogue;
			case 'hideright':
				portraitRight.visible = false;
				enddialogue();
			case 'hideleft':
				portraitLeft.visible = false;
				enddialogue();
			case 'crash':
				Sys.exit(0);
			case 'showbackgroundimage':
				backgroundImage.loadGraphic(Paths.image('dialogue/bgs/' + dialogueList[0], 'doki'));
				enddialogue();
				backgroundImage.visible = true;
			case 'hidebackground':
				enddialogue();
				backgroundImage.visible = false;
			case 'fadeout':
				canSkip = false;
				add(blackscreen);
				blackscreen.alpha = 0;
				FlxTween.tween(blackscreen, {alpha: 1}, 5, {
					ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween)
					{
						trace("Did I work?");
						endinstantly();
					}
				});
			case 'disableskip':
				skipText.visible = false;
				canFullSkip = false;
				enddialogue();
			case 'hidedialogue':
				dialogueEnded = true;
				bgFade.visible = false;
				box.visible = false;
				portraitRight.visible = false;
				portraitLeft.visible = false;
			case 'hidebgfade':
				bgFade.alpha = 0;
			case 'flash':
				// change color to off-white, also change duration
				// might need to do timer for this
				PlayState.camOverlay.fade(FlxColor.WHITE, 1.5, true, true);
			case 'shake':
				PlayState.camOverlay.shake(0.004, 0.5);
			case 'fadein':
				// when one CG is on screen and I need the next one called to fade in over the other
			case 'swapstyle' | 'styleswap'://I'm stupid
				if (dialogueList[0].toLowerCase() == 'pixel')
					styleSwap('pixel');
				else
					styleSwap('hueh');
		}

		if (dialogueList[0] == '' && !isCommand && curCharacter != 'hidedialogue')
			enddialogue();
	}

	function cleanDialog():Void
	{
		if (dialogueList[0].startsWith('//'))
			dialogueList.remove(dialogueList[0]);

		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];

		dialogueList[0] = StringTools.replace(dialogueList[0].substr(splitName[1].length + 2).trim(), '{USERNAME}', (isEpiphany ? CoolUtil.getUsername() : 'User'));
	}

	var staticlol:StaticShader;

	function funnyGlitch():Void
	{
		if (SaveData.shaders)
		{
			staticlol = new StaticShader();
			PlayState.camOverlay.filters = [new ShaderFilter(staticlol)];
		}

		FlxG.sound.play(Paths.sound('glitchin'));

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			if (SaveData.shaders)
			{
				PlayState.camOverlay.filters = [];
				staticlol = null;
			}

			enddialogue();
		});
	}

	function styleSwap(style:String = 'normal')
	{
		remove(box);
		remove(portraitLeft);
		remove(portraitRight);
		remove(swagDialogue);
		switch (style)
		{
			default: //Normal cause ya know
				skipText.font = LangUtil.getFont();
				isPixel = false;
				initDialogueStyle(0);
			case 'pixel':
				skipText.font = LangUtil.getFont('vcr');
				isPixel = true;
				initDialogueStyle(1);
		}
		backgroundImage.antialiasing = !isPixel;
		enddialogue();
	}

	// For dialogue boxes
	var prefixMap:Map<String, String> = [
		"normalOpen" => "Doki Dialogue Blank",
		"blankbox" => "Doki Dialogue noone",
		"bf" => "Doki Dialogue BF",
		"gf" => "Doki Dialogue GF",
		"monika" => "Doki Dialogue Moni",
		"natsuki" => "Doki Dialogue Natsu",
		"yuri" => "Doki Dialogue Yuri0",
		"yuri_crazy" => "Doki Dialogue Yuri Glitch",
		"mc" => "Doki Dialogue Protag",
		"zipper" => "Doki Dialogue Zipper"
	];

	function initDialogueStyle(style:Int = 0)
	{
		switch(style)
		{
			default: //Normal will be default, important

				box = new FlxSprite(-20, 45);
				box.frames = Paths.getSparrowAtlas('dialogue/Text_Boxes', 'preload', true);
				for (name in prefixMap.keys())
					box.animation.addByPrefix(name, prefixMap[name], 24, false);
				
				// Special case left here
				box.animation.addByIndices('normal', 'Doki Dialogue Blank', [9], "", 24);
				box.antialiasing = SaveData.globalAntialiasing;

				//Step 2
				var posY = 50;
				portraitLeft = new FlxSprite(200, posY);
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * .9));
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				portraitLeft.antialiasing = SaveData.globalAntialiasing;
				add(portraitLeft);
				portraitLeft.visible = false;
				portraitRight = new FlxSprite(600, posY);
				portraitRight.setGraphicSize(Std.int(portraitRight.width * .9));
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set();
				portraitRight.antialiasing = SaveData.globalAntialiasing;
				add(portraitRight);
				portraitRight.visible = false;
				box.animation.play('normalOpen');

				box.y += 400;
				box.setGraphicSize(Std.int(box.width * 1.2));
				box.updateHitbox();
				add(box);
				box.screenCenter(X);

				swagDialogue = new FlxTypeText(220, 520, Std.int(box.width * 0.85), "", 28);
				swagDialogue.font = LangUtil.getFont('aller');
				swagDialogue.y += LangUtil.getFontOffset('aller');
				swagDialogue.color = 0xFFFFFFFF;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0.8)];
				swagDialogue.setBorderStyle(OUTLINE, FlxColor.BLACK, 1, 1);
				swagDialogue.antialiasing = SaveData.globalAntialiasing;
				add(swagDialogue);

			case 1:	//Pixel
				//Step 1 add box
				box = new FlxSprite(-20, 45);
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-monika');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);

				//Step 2 portaits
				portraitLeft = new FlxSprite(-20, 40);
				portraitLeft.frames = Paths.getSparrowAtlas('dialogue/monika', 'week6');
				portraitLeft.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				add(portraitLeft);
				portraitLeft.visible = false;
				
				portraitRight = new FlxSprite(0, 40);
				portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf', 'week6');
				portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
				portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set();
				add(portraitRight);
				portraitRight.visible = false;
				box.animation.play('normalOpen');

				//Scale stuff
				box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
				box.updateHitbox();
				add(box);
				box.screenCenter(X);
				portraitLeft.screenCenter(X);

				swagDialogue = new FlxTypeText(240, 500, Std.int(box.width * 0.6), "", 42);
				swagDialogue.font = LangUtil.getFont('pixel');
				swagDialogue.borderStyle = SHADOW;
				swagDialogue.color = 0xFF3F2021;
				swagDialogue.borderColor = 0xFFD89494;
				swagDialogue.borderSize = 2;
				swagDialogue.shadowOffset.set(2, 2);
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0.8)];
				add(swagDialogue);

		}
	}
}
