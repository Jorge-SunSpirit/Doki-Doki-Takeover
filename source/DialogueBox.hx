package;

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

typedef DialogueFile =
{
	var canSkip:Null<Bool>; //  Determines if this dialogue can be skipped (ex. disabled in obsession ending)
	var initStyle:Null<String>; // Determines what the dialogue style initalizes as
	var startingMusic:Null<String>; // Allows any song to start and fade in like HSC
	var disableBGFade:Null<Bool>; // Self explanitory
	var dialogue:Array<DialogueLine>;
}

typedef DialogueLine =
{
	var isCommand:Null<Bool>; // Either dialogue or command
	var name:Null<String>; // chara name or command name
	var expression:Null<String>; // Exclusive to dialogue
	var string:Null<String>; // used for dialogue or command
	var stringOBS:Null<String>; // used for replacement dialogue when OBS is running
	var key:Null<String>; // used for localized dialogue
	var keyOBS:Null<String>; // used for localized replacement dialogue when OBS is running
	var sound:Null<String>; // Used for the voice clips -- Might be used instead of a seperate command
	var side:Null<String>; // Exclusive to dialogue left or right side or hiding side
	var duration:Null<Float>; // Used for the duration of a cutscene
}

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var prevCharacter:Array<String> = ['monika', 'left'];

	var dialogueData:DialogueFile;

	public static var isOBS:Bool = false;
	var isPixel:Bool = false;
	var isEpiphany:Bool = false;

	var canSkip:Bool = true;
	var canFullSkip:Bool = true;
	var playingCutscene:Bool = false;

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
	
	var currentDialogue:Int = 0;

	public function new(initdialogueData:String)
	{
		super();

		isEpiphany = PlayState.SONG.song.toLowerCase() == 'epiphany';

		var jsonDiaString:String = Assets.getText(Paths.json('dialogue/erb/TestDialogue'));
		if (initdialogueData != null)
			jsonDiaString = initdialogueData;
		
		dialogueData = cast Json.parse(jsonDiaString);

		isPixel = dialogueData.initStyle.toLowerCase() == 'pixel';

		backgroundImage = new FlxSprite();
		backgroundImage.alpha = 0.001;
		insert(0, backgroundImage);

		if (dialogueData.dialogue[currentDialogue].name == 'showbackgroundimage')
		{
			backgroundImage.alpha = 1;
			backgroundImage.loadGraphic(Paths.image('dialogue/bgs/' + dialogueData.dialogue[currentDialogue].string, 'doki'));
		}

		if (!isPixel)
			backgroundImage.antialiasing = SaveData.globalAntialiasing;
		else
			backgroundImage.antialiasing = false;

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFD8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0.0001;
		add(bgFade);

		if (Paths.fileExists('music/' + dialogueData.startingMusic + '.ogg', MUSIC, 'preload'))
		{
			FlxG.sound.playMusic(Paths.music(dialogueData.startingMusic, 'preload'), 0.1);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		}
	
		if (dialogueData.disableBGFade == null || !dialogueData.disableBGFade)
			FlxTween.tween(bgFade, {alpha: 0.7}, 4.98, {ease: FlxEase.linear});

		if (isPixel)
			initDialogueStyle(1);
		else
			initDialogueStyle(0);

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

		if (dialogueData.canSkip != null)
		{
			skipText.visible = dialogueData.canSkip;
			canFullSkip = dialogueData.canSkip;
		}

		blackscreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackscreen.alpha = 0;
		add(blackscreen);

		if (dialogueData.dialogue[currentDialogue].name == 'playcutscene')
		{
			bgFade.visible = false;
			box.visible = false;
			portraitRight.alpha = 0.001;
			portraitLeft.alpha = 0.001;
			swagDialogue.visible = false;
			if (canFullSkip)
				skipText.visible = false;
		}
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

		if (canSkip && !playingCutscene)
		{
			if (PlayerSettings.player1.controls.BACK && !stopspamming && canFullSkip && !playingCutscene && dialogueStarted)
			{
				isEnding = true;
				stopspamming = true;
				endinstantly();
			}
	
			if (PlayerSettings.player1.controls.ACCEPT && dialogueEnded)
			{
				FlxG.sound.play(Paths.sound('clickText'), 0.8);
				enddialogue();
			}
			else if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted)
			{
				swagDialogue.skip();
			}
		}

		super.update(elapsed);
	}

	function endinstantly()
	{
		PlayState.instance.cleanupCutscene();
		canSkip = false;
		isEnding = true;
		swagDialogue.skip();

		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeOut(0.5, 0);

		fadeEverything();

		new FlxTimer().start(1.2, function(tmr:FlxTimer)
		{
			dialogueStarted = false;
			finishThing();
			kill();
		});
	}

	function fadeEverything()
	{
		portraitLeft.alpha = 0.001;
		portraitRight.alpha = 0.001;
		skipText.visible = false;

		if (isPixel)
		{
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				box.alpha -= 1 / 5;
				backgroundImage.alpha -= 1 / 5;
				bgFade.alpha -= 1 / 5 * 0.7;
				swagDialogue.alpha -= 1 / 5;
				portraitLeft.alpha -= 1 / 5;
				portraitRight.alpha -= 1 / 5;
			}, 5);
		}
		else
		{
			FlxTween.tween(box, {alpha: 0}, 1.2, {ease: FlxEase.linear});
			FlxTween.tween(backgroundImage, {alpha: 0}, 1.2, {ease: FlxEase.linear});
			FlxTween.tween(bgFade, {alpha: 0}, 1.2, {ease: FlxEase.linear});
			FlxTween.tween(swagDialogue, {alpha: 0}, 1.2, {ease: FlxEase.linear});
		}
	}

	function enddialogue()
	{
		PlayState.instance.cleanupCutscene();
		canSkip = true;
		if (dialogueData.dialogue[currentDialogue] == null)
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
					finishThing();
					kill();
				});
			}
		}
		else
		{
			startDialogue();
		}
	}

	override function kill()
	{
		isPixel = false;
		isOBS = false;
		super.kill();
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
		'fadein',
		'hidedialogue',
		'hidebgfade',
		'showbgfade',
		'flash',
		'shake',
		'fadecg',
		'swapstyle',
		'styleswap',
		'playcutscene'
	];
	

	function startDialogue():Void
	{
		var curDialogue:DialogueLine = null;//Stealing code from infinite as a test
		var skipEndDialogue:Bool = true;
		do
		{
			curDialogue = dialogueData.dialogue[currentDialogue];
		}
		while (curDialogue == null);

		if (curDialogue.isCommand != null)
			isCommand = curDialogue.isCommand;
		else
			isCommand = false;

		if (curDialogue.name != null)
			curCharacter = curDialogue.name;

		//cleanDialog();
		if (box.visible == false)
		{
			bgFade.visible = true;
			box.visible = true;
			swagDialogue.visible = true;
		}

		// Epiphany username & OBS shit
		var dialogueText:String = curDialogue.string;

		#if FEATURE_LANGUAGE
		if (SaveData.language != 'en-US' && curDialogue.key != null)
			dialogueText = LangUtil.getString(curDialogue.key, 'dialogue');
		#end

		if (isEpiphany)
		{
			if (isOBS && curDialogue.stringOBS != null)
			{
				dialogueText = curDialogue.stringOBS;

				#if FEATURE_LANGUAGE
				if (SaveData.language != 'en-US' && curDialogue.keyOBS != null)
					dialogueText = LangUtil.getString(curDialogue.keyOBS, 'dialogue');
				#end
			}
			else
			{
				dialogueText = StringTools.replace(dialogueText, '{USERNAME}', CoolUtil.getUsername());
			}
		}

		var commandDuration:Null<Float> = curDialogue.duration;

		if (!isCommand || curCharacter == 'autoskip')
		{
			swagDialogue.resetText(dialogueText);
			swagDialogue.start(0.04);
			swagDialogue.completeCallback = function()
			{
				dialogueEnded = true;
			}

			dialogueEnded = false;
		}

		currentDialogue++;

		if (!isCommand && isPixel)
		{
			FlxTween.cancelTweensOf(portraitRight);
			FlxTween.cancelTweensOf(portraitLeft);
			var portrait:FlxSprite;
			portrait = (curDialogue.side == 'right' ? portraitRight : portraitLeft);
			var xthingieorig = (curDialogue.side == 'right' ? 647 : 110);
			var xthingienew = (curDialogue.side == 'right' ? 677 : 80);


			if (Paths.fileExists('images/weeb/dialogue/' + curCharacter.toLowerCase() + '.png', IMAGE, 'week6'))
			{
				if (curCharacter != prevCharacter[0] && curDialogue.side == prevCharacter[1])
				{
					portrait.alpha = 0.001;
					portrait.x = xthingienew;
				}

				if (curDialogue.side == 'right' && curCharacter == 'monika')
					portrait.flipX = false;
				else if (curDialogue.side == 'right')
					portrait.flipX = true;

				portrait.frames = Paths.getSparrowAtlas("weeb/dialogue/" + curCharacter.toLowerCase(), 'week6');
				portrait.animation.addByPrefix('hueh', curCharacter.toLowerCase() + '_' + curDialogue.expression, 24, false);
				if (portrait.animation.getByName('hueh') == null || curDialogue.expression == '')
					portrait.animation.addByPrefix('hueh', curCharacter.toLowerCase() + '_neutral', 24, false);
				portrait.animation.play('hueh');
				
				if (curDialogue.expression != 'gone')
					FlxTween.tween(portrait, {alpha: 1, x: xthingieorig}, 0.2, {ease: FlxEase.linear});
				else
					portrait.alpha = 0.001;

				prevCharacter = [curCharacter, curDialogue.side];
			}


			var startswith:String = '';

			if (curDialogue.expression == 'spirit')
				startswith = 'spirit';
			if (curCharacter.startsWith("monika"))
				startswith = 'monika';

			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0.8)];
			swagDialogue.color = 0xFF3F2021;
			swagDialogue.borderColor = 0xFFD89494;

			switch (startswith)
			{
				case 'spirit':
					swagDialogue.color = 0xFFFFFFFF;
					swagDialogue.borderColor = 0xFF424242;
					if (box.frames != Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil', 'week6'))
					{
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
		else if (!isCommand && !isPixel)
		{
			box.offset.set(-82, -18.9);
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
			if (curCharacter.startsWith("mc") || curCharacter.startsWith("protag"))
				startswith = 'mc';
			if (curCharacter.startsWith("zipper"))
				startswith = 'zipper';
			if (curCharacter.startsWith("all"))
				startswith = 'all';
			
			var portrait:FlxSprite;//Basically make this apply to any of em
			portrait = (curDialogue.side == 'right' ? portraitRight : portraitLeft);
			var dialogueSound:String;

			portrait.alpha = 0.001;
			box.animation.play(startswith);
			if (portrait.alpha < 0.9 && curDialogue.expression != 'gone')
			{
				portrait.alpha = 1;
				if (Paths.fileExists('images/dialogue/portraits/' + curCharacter.toLowerCase() + '_' + curDialogue.expression +'.xml', TEXT, 'doki'))
				{
					portrait.frames = Paths.getSparrowAtlas('dialogue/portraits/' + curCharacter.toLowerCase() + '_' + curDialogue.expression, 'doki');
					portrait.animation.addByPrefix('play', curCharacter.toLowerCase() + '_' + curDialogue.expression, 24, true);
					portrait.animation.play('play');
				}
				else
				{
					if (Paths.fileExists('images/dialogue/portraits/' + curCharacter.toLowerCase() + '_' + curDialogue.expression +'.png', IMAGE, 'doki'))
						portrait.loadGraphic(Paths.image('dialogue/portraits/' + curCharacter.toLowerCase() + '_' + curDialogue.expression, 'doki'));
					else
					{
						trace("Lost the expression " + curDialogue.expression + " Goin neutral");
						portrait.loadGraphic(Paths.image('dialogue/portraits/' + curCharacter.toLowerCase() + '_neutral', 'doki'));
					}
				}
			}

			switch (startswith)
			{
				case 'bf' | 'gf' | 'mc':
					if (curDialogue.side == 'left') portrait.flipX = true;
					else portrait.flipX = false;

					dialogueSound = startswith + 'Text';
					box.animation.play(startswith);
				case 'monika' | 'yuri' | 'sayori' | 'natsuki' | 'zipper': 
					if (curDialogue.side == 'right') portrait.flipX = true;
					else portrait.flipX = false;

					dialogueSound = startswith + 'Text';
					if (curDialogue.expression == 'crazy')
					{
						box.animation.play('yuri_crazy');
						box.offset.set(-55, -12);
					}
					else 
						box.animation.play(startswith);
				case 'all':
					if (curDialogue.side == 'right') portrait.flipX = true; 
					else portrait.flipX = false;
					
					dialogueSound = 'pixelText';
					box.animation.play('blankbox');
				default:
					dialogueSound = 'pixelText';
					box.animation.play('blankbox');
			}
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/' + dialogueSound), 0.8)];

		}

		if (dialogueText == '' && !isCommand)
			enddialogue();

		// Dialogue commands
		switch (curCharacter)
		{
			case 'playsound':
				FlxG.sound.play(Paths.sound(curDialogue.string));
			case 'startmusic':
				FlxG.sound.playMusic(Paths.music(curDialogue.string));
			case 'endmusic':
				if (FlxG.sound.music != null)
					FlxG.sound.music.fadeOut(0.5, 0);
			case 'glitch':
				skipEndDialogue = false;
				canSkip = false;
				if (curDialogue.string.toLowerCase() == 'hidedialogue')
				{
					bgFade.visible = false;
					box.visible = false;
					portraitRight.alpha = 0.001;
					portraitLeft.alpha = 0.001;
					swagDialogue.visible = false;
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0)];
				}
				funnyGlitch();
			case 'autoskip':
				canSkip = false;
				skipEndDialogue = false;
				swagDialogue.completeCallback = enddialogue;
			case 'hideright':
				portraitRight.alpha = 0.001;
			case 'hideleft':
				portraitLeft.alpha = 0.001;
			case 'crash':
				Sys.exit(0);
			case 'showbackgroundimage':
				backgroundImage.loadGraphic(Paths.image('dialogue/bgs/' + curDialogue.string, 'doki'));
				if (commandDuration != null)
					FlxTween.tween(commandDuration, {alpha: 1}, commandDuration, {ease: FlxEase.expoOut});
				else
					backgroundImage.alpha = 1;
			case 'hidebackground':
				if (commandDuration != null)
					FlxTween.tween(commandDuration, {alpha: 0.001}, commandDuration, {ease: FlxEase.expoOut});
				else
					backgroundImage.alpha = 0.001;
			case 'fadeout':
				canSkip = false;
				blackscreen.alpha = 0;
				if (curDialogue.string.toLowerCase() == 'hidedialogue')
				{
					bgFade.visible = false;
					box.visible = false;
					portraitRight.alpha = 0.001;
					portraitLeft.alpha = 0.001;
					swagDialogue.visible = false;
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0)];
					if (canFullSkip)
						skipText.visible = false;
				}

				FlxTween.tween(blackscreen, {alpha: 1}, commandDuration, {
					ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween)
					{
						//blackscreen.alpha = 0; //Might be redundant Undo if it breaks anything
					}
				});
			case 'fadein':
				canSkip = false;
				blackscreen.alpha = 1;

				if (curDialogue.string.toLowerCase() == 'hidedialogue')
				{
					bgFade.visible = false;
					box.visible = false;
					portraitRight.alpha = 0.001;
					portraitLeft.alpha = 0.001;
					swagDialogue.visible = false;
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0)];
					if (canFullSkip)
						skipText.visible = false;
				}

				FlxTween.tween(blackscreen, {alpha: 0}, commandDuration, {
					ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween)
					{
						if (canFullSkip && curDialogue.string.toLowerCase() == 'hidedialogue')
							skipText.visible = true;
					}
				});
			case 'hidedialogue':
				skipEndDialogue = false;
				dialogueEnded = true;
				bgFade.visible = false;
				box.visible = false;
				portraitRight.alpha = 0.001;
				portraitLeft.alpha = 0.001;
				swagDialogue.visible = false;
			case 'hidebgfade':
				bgFade.alpha = 0;
			case 'showbgfade':
				bgFade.alpha = 0.7;
			case 'flash':
				PlayState.camOverlay.fade(0xFFFDC1FF, commandDuration, true, true);
			case 'shake':
				PlayState.camOverlay.shake(0.004, commandDuration);
				skipEndDialogue = false;
				enddialogue();
			case 'fadecg':
				// when one CG is on screen and I need the next one called to fade in over the other
			case 'swapstyle' | 'styleswap'://I'm stupid
				skipEndDialogue = false;
				if (curDialogue.string.toLowerCase() == 'pixel')
					styleSwap('pixel');
				else
					styleSwap('hueh');
			case 'playcutscene':
				dialogueEnded = true;
				bgFade.visible = false;
				box.visible = false;
				portraitRight.alpha = 0.001;
				portraitLeft.alpha = 0.001;
				swagDialogue.visible = false;
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('dialogue/pixelText'), 0)];

				PlayState.instance.playbackCutscene(curDialogue.string.toLowerCase(), commandDuration);

				if (curDialogue.duration != null)
				{
					playingCutscene = true;

					if (canFullSkip)
						skipText.visible = false;

					new FlxTimer().start(commandDuration, function(tmr:FlxTimer)
					{
						playingCutscene = false;

						if (canFullSkip)
							skipText.visible = true;
					});
				}
		}

		if (isCommand && skipEndDialogue)
		{
			if (commandDuration != null && commandDuration > 0 && curCharacter != 'flash')
			{
				new FlxTimer().start(commandDuration, function(tmr:FlxTimer)
				{
					enddialogue();
				});
			}
			else
				enddialogue();
		}
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

		if (!isPixel)
			backgroundImage.antialiasing = SaveData.globalAntialiasing;
		else
			backgroundImage.antialiasing = false;

		enddialogue();
	}

	// For dialogue boxes
	var prefixMap:Map<String, String> = [
		"normalOpen" => "Doki Dialogue Blank",
		"blankbox" => "Doki Dialogue noone",
		"bf" => "Doki Dialogue BF",
		"gf" => "Doki Dialogue GF",
		"monika" => "Doki Dialogue Moni",
		"sayori" => "Doki Dialogue Sayo",
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
				box.frames = Paths.getSparrowAtlas('dialogue/Text_Boxes', 'doki', true);
				for (name in prefixMap.keys())
					box.animation.addByPrefix(name, prefixMap[name], 24, false);
				
				// Special case left here
				box.animation.addByIndices('normal', 'Doki Dialogue Blank', [9], "", 24);
				box.antialiasing = SaveData.globalAntialiasing;

				//Step 2
				var posY = 50;
				portraitLeft = new FlxSprite(150, posY);
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * .9));
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				portraitLeft.antialiasing = SaveData.globalAntialiasing;
				add(portraitLeft);
				portraitLeft.alpha = 0.001;
				portraitRight = new FlxSprite(600, posY);
				portraitRight.setGraphicSize(Std.int(portraitRight.width * .9));
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set();
				portraitRight.antialiasing = SaveData.globalAntialiasing;
				add(portraitRight);
				portraitRight.alpha = 0.001;
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
				switch (dialogueData.dialogue[currentDialogue].name)
				{
					case 'monika':
						box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-monika', 'week6');
						box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
						box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
						box.animation.play('normalOpen');
					default:
						if (dialogueData.dialogue[currentDialogue].expression.toLowerCase() == 'spirit')
						{
							box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil', 'week6');
							box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn instance 1', 24, false);
							box.animation.addByIndices('normal', 'Spirit Textbox spawn instance 1', [10], "", 24);
							box.animation.play('normalOpen');
						}
						else
						{
							box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel', 'week6');
							box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
							box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
							box.animation.play('normalOpen');
						}
				}

				//Step 2 portaits
				portraitLeft = new FlxSprite(110, -4);
				portraitLeft.frames = Paths.getSparrowAtlas('weeb/dialogue/monika', 'week6');
				portraitLeft.animation.addByPrefix('hueh', 'monika_neutral', 24, false);
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				add(portraitLeft);
				portraitLeft.alpha = 0.001;
				
				portraitRight = new FlxSprite(647, -4);
				portraitRight.frames = Paths.getSparrowAtlas('weeb/dialogue/bf', 'week6');
				portraitRight.animation.addByPrefix('hueh', 'bf_neutral', 24, false);
				portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set();
				portraitRight.flipX = true;
				add(portraitRight);
				portraitRight.alpha = 0.001;
				box.animation.play('normalOpen');

				//Scale stuff
				box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
				box.updateHitbox();
				add(box);
				box.screenCenter(X);

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
