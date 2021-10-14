package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.effects.chainable.FlxGlitchEffect;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];
	public static var isPixel:Bool = false;

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;
	var skipText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var glitch:FlxGlitchEffect;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(isPixel:Bool = false, ?dialogueList:Array<String>)
	{
		super();


		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;
			if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
				{
					hasDialog = true;
					box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-monika');
					box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
					box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				}
			else
				{
					hasDialog = true;
					box.frames = Paths.getSparrowAtlas('dialogue/Text_Boxes','doki');
					box.animation.addByPrefix('normalOpen', 'Doki Dialogue Blank', 24, false);
					box.animation.addByIndices('normal', 'Doki Dialogue Blank', [9], "", 24);
					box.animation.addByPrefix('bf', 'Doki Dialogue BF', 24, false);
					box.animation.addByPrefix('gf', 'Doki Dialogue GF', 24, false);
					box.animation.addByPrefix('monika', 'Doki Dialogue Moni', 24, false);
					box.animation.addByPrefix('natsuki', 'Doki Dialogue Natsu', 24, false);
					box.animation.addByPrefix('sayori', 'Doki Dialogue Sayo', 24, false);
					box.animation.addByPrefix('yuri', 'Doki Dialogue Yuri0', 24, false);
					box.animation.addByPrefix('mc', 'Doki Dialogue Protag', 24, false);
					box.antialiasing = true;
				}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;

			if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
				{
					portraitLeft = new FlxSprite(-20, 40);
					portraitLeft.frames = Paths.getSparrowAtlas('dialogue/monika','monika');
					portraitLeft.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					add(portraitLeft);
					portraitLeft.visible = false;
					portraitRight = new FlxSprite(0, 40);
					portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf','monika');
					portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					add(portraitRight);
					portraitRight.visible = false;
				}
			else
				{
					var posY = 50;

					portraitLeft = new FlxSprite(200, posY);
					portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
					portraitLeft.animation.addByPrefix('sayo', 'sayo', 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * .9));
					portraitLeft.updateHitbox();
					portraitLeft.scrollFactor.set();
					portraitLeft.antialiasing = true;
					add(portraitLeft);
					portraitLeft.visible = false;

					portraitRight = new FlxSprite(600, posY);
					portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue','doki');
					portraitRight.animation.addByPrefix('bf', 'bf', 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * .9));
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					portraitRight.antialiasing = true;
					add(portraitRight);
					portraitRight.visible = false;
				}
		
		box.animation.play('normalOpen');
			if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
				{
					box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
				}
			else
				{
					box.y += 400;
					box.setGraphicSize(Std.int(box.width * 1.2));
				}
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
			portraitLeft.screenCenter(X);

			if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
				{
					dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.8), "", 32);
					dropText.font = LangUtil.getFont('pixel');
					dropText.color = 0xFFD89494;
					add(dropText);

					swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.8), "", 32);
					swagDialogue.font = LangUtil.getFont('pixel');
					swagDialogue.color = 0xFF3F2021;
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.8)];
					add(swagDialogue);
				}
			else
				{
					swagDialogue = new FlxTypeText(220, 520, Std.int(FlxG.width * 0.87), "", 28);
					swagDialogue.font = LangUtil.getFont('aller');
					swagDialogue.color = 0xFFFFFFFF;
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.8)];
					swagDialogue.setBorderStyle(OUTLINE, FlxColor.BLACK, 1, 1);
					swagDialogue.antialiasing = true;
					add(swagDialogue);
				}

		skipText = new FlxText(5, 695, 640, "Press ESCAPE to skip the dialogue.\n", 40);
		skipText.scrollFactor.set(0, 0);
		skipText.font = 'VCR OSD Mono';
		skipText.setFormat(20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skipText.borderSize = 2;
		skipText.borderQuality = 1;
		add(skipText);
		

		dialogue = new Alphabet(0, 80, "", false, true);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	var stopspamming:Bool = false;

	override function update(elapsed:Float)
	{
		if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
			{
				dropText.text = swagDialogue.text;
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

		if (FlxG.keys.justPressed.ESCAPE && !stopspamming)
			{
				stopspamming = true;
				remove(dialogue);
				dialogueStarted = false;
				isEnding = true;
				endinstantly();
			}

		if (FlxG.keys.justPressed.ANY && !FlxG.keys.justPressed.ESCAPE && dialogueStarted == true)
		{
					remove(dialogue);
						
					FlxG.sound.play(Paths.sound('clickText'), 0.8);
					enddialogue();
		}
		
		super.update(elapsed);
	}

	function endinstantly()
		{
			dialogueList.remove(dialogueList[0]);
			isEnding = true;

			if (FlxG.sound.music != null)
				FlxG.sound.music.fadeOut(0.5, 0);

			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				skipText.alpha -= 5 / 5;
				box.alpha -= 1 / 5;
				bgFade.alpha -= 1 / 5 * 0.7;
				portraitLeft.visible = false;
				portraitRight.visible = false;
				swagDialogue.alpha -= 5 / 5;
				if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
					{
							dropText.alpha = swagDialogue.alpha;
					}	
			}, 5);

			new FlxTimer().start(1.2, function(tmr:FlxTimer)
			{
				isPixel = false;
				finishThing();
				kill();
			});
		}

	function enddialogue()
		{
			if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;

						if (FlxG.sound.music != null)
							FlxG.sound.music.fadeOut(0.5, 0);
	
						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							box.alpha -= 1 / 5;
							bgFade.alpha -= 1 / 5 * 0.7;
							portraitLeft.visible = false;
							portraitRight.visible = false;
							swagDialogue.alpha -= 1 / 5;
							if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
								{
									dropText.alpha = swagDialogue.alpha;
								}	
						}, 5);
						
						new FlxTimer().start(1.2, function(tmr:FlxTimer)
						{
							isPixel = false;
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

	function startDialogue():Void
	{
		cleanDialog();

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);
		if (PlayState.SONG.noteStyle == 'pixel' || isPixel)
			{
				switch (curCharacter)
					{
						case 'monika':
							portraitRight.visible = false;
							portraitLeft.visible = false;
							if (!portraitLeft.visible)
							{
								portraitLeft.visible = true;
								portraitLeft.frames = Paths.getSparrowAtlas('dialogue/monika','monika');
								portraitLeft.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
								portraitLeft.animation.play('enter');
							}
						case 'monikahappy':
							portraitRight.visible = false;
							portraitLeft.visible = false;
							if (!portraitLeft.visible)
							{
								portraitLeft.visible = true;
								portraitLeft.frames = Paths.getSparrowAtlas('dialogue/monikahappy','monika');
								portraitLeft.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
								portraitLeft.animation.play('enter');
							}
						case 'monikagasp':
							portraitRight.visible = false;
							portraitLeft.visible = false;
							if (!portraitRight.visible)
							{
								portraitRight.visible = true;
								portraitRight.frames = Paths.getSparrowAtlas('dialogue/monikagasp','monika');
								portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
								portraitRight.animation.play('enter');
							}
							case 'monikagaspleft':
								portraitRight.visible = false;
								portraitLeft.visible = false;
								if (!portraitRight.visible)
								{
									portraitRight.visible = true;
									portraitRight.frames = Paths.getSparrowAtlas('dialogue/monikagaspleft','monika');
									portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
									portraitRight.animation.play('enter');
								}
							case 'monikahmm':
								portraitRight.visible = false;
								portraitLeft.visible = false;
								if (!portraitRight.visible)
									{
										portraitRight.visible = true;
										portraitRight.frames = Paths.getSparrowAtlas('dialogue/monikahmm','monika');
										portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
										portraitRight.animation.play('enter');
									}
							case 'monikauhoh':
								portraitRight.visible = false;
								portraitLeft.visible = false;
								if (!portraitRight.visible)
									{
										portraitRight.visible = true;
										portraitRight.frames = Paths.getSparrowAtlas('dialogue/monikauhohright','monika');
										portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
										portraitRight.animation.play('enter');
									}
						case 'monikauhohleft':
								portraitRight.visible = false;
								portraitLeft.visible = false;
								if (!portraitRight.visible)
									{
										portraitRight.visible = true;
										portraitRight.frames = Paths.getSparrowAtlas('dialogue/monikauhohleft','monika');
										portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
										portraitRight.animation.play('enter');
									}
						case 'monikasad':
							portraitRight.visible = false;
							portraitLeft.visible = false;
							if (!portraitRight.visible)
							{
								portraitRight.visible = true;
								portraitRight.frames = Paths.getSparrowAtlas('dialogue/monikasad','monika');
								portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
								portraitRight.animation.play('enter');
							}
						case 'bf':
							portraitRight.visible = false;
							portraitLeft.visible = false;
							if (!portraitRight.visible)
							{
								portraitRight.visible = true;
								portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf','monika');
								portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
								portraitRight.animation.play('enter');
							}
						case 'bfwhat':
							portraitRight.visible = false;
							portraitLeft.visible = false;
							if (!portraitRight.visible)
							{
								portraitRight.visible = true;
								portraitRight.frames = Paths.getSparrowAtlas('dialogue/bfwhat','monika');
								portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
								portraitRight.animation.play('enter');
							}
						case 'bfangry':
								portraitRight.visible = false;
								portraitLeft.visible = false;
								if (!portraitRight.visible)
								{
									portraitRight.visible = true;
									portraitRight.frames = Paths.getSparrowAtlas('dialogue/bfangry','monika');
									portraitRight.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
									portraitRight.animation.play('enter');
								}
						case 'senpai':
							portraitRight.visible = false;
							portraitLeft.visible = false;
							if (!portraitLeft.visible)
							{
								portraitLeft.visible = true;
								portraitLeft.frames = Paths.getSparrowAtlas('dialogue/senpai','monika');
								portraitLeft.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
								portraitLeft.animation.play('enter');
							}
						case 'senpaihappy':
							portraitRight.visible = false;
							portraitLeft.visible = false;
							if (!portraitLeft.visible)
							{
								portraitLeft.visible = true;
								portraitLeft.frames = Paths.getSparrowAtlas('dialogue/senpaihappy','monika');
								portraitLeft.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
								portraitLeft.animation.play('enter');
							}
						case 'senpaihmm':
							portraitRight.visible = false;
							portraitLeft.visible = false;
							if (!portraitLeft.visible)
							{
								portraitLeft.visible = true;
								portraitLeft.frames = Paths.getSparrowAtlas('dialogue/senpaihmm','monika');
								portraitLeft.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
								portraitLeft.animation.play('enter');
							}
						case 'whodis':
							portraitRight.visible = false;
							portraitLeft.visible = false;
							if (!portraitLeft.visible)
							{
								portraitLeft.visible = true;
								portraitLeft.frames = Paths.getSparrowAtlas('dialogue/whodis','monika');
								portraitLeft.animation.addByPrefix('enter', 'Portrait Enter instance', 24, false);
								portraitLeft.animation.play('enter');
							}
					}
			}
		else
			{
				switch (curCharacter)
				{
					//Yuri animations
					case 'yuri_neutral':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('YuriText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('yuri');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/yuri_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'yurineutral', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'yuri_ehh':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('YuriText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('yuri');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/yuri_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'yuri_ehh', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'yuri_blush':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('YuriText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('yuri');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/yuri_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'yuri_blush', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'yuri_crazy':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('YuriText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('yuri');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/yuri_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'yuri_crazy', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'yuri_smile':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('YuriText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('yuri');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/yuri_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'yuri_smile', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'yuri_ahh':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('YuriText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('yuri');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/yuri_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'yuri_ahh', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					
					//Natsuki animations
					case 'natsuki_neutral':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('NatText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('natsuki');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/nat_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'natneutral', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'natsuki_angy':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('NatText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('natsuki');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/nat_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'nat_angy', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'natsuki_hmmph':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('NatText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('natsuki');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/nat_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'nat_hmmph', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'natsuki_what':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('NatText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('natsuki');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/nat_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'nat_what', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'natsuki_wah':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('NatText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('natsuki');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/nat_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'nat_wah', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					
					//Sayori animations
					case 'sayori_neutral':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('SayoText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('sayori');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'sayoneutral', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'sayori_happ':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('SayoText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('sayori');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'sayo_happ', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'sayori_ehh':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('SayoText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('sayori');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'sayo_ehh', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'sayori_grumpy':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('SayoText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('sayori');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'sayo_grumpy', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'sayori_ooh':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('SayoText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('sayori');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'sayo_ooh', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'sayori_yeah':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('SayoText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('sayori');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'sayo_yeah', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'sayori_concern':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('SayoText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('sayori');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'sayo_concern', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}

					//Monika anims
					case 'monika_neutral':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('MoniText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('monika');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/moni_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'monika_neutral', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'monika_upset':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('MoniText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('monika');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/moni_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'monika_upset', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'monika_eeh':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('MoniText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('monika');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/moni_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'monika_eeh', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'monika_ahh':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('MoniText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('monika');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/moni_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'monika_ahh', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}
					case 'monika_ahaha':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('MoniText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('monika');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/moni_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'monika_ahaha', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = false;
						}

					//MC animations wait I mean senpai
					case 'mc_neutral':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('mc');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/mc_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'mc_neutral', 24, false);
							portraitRight.animation.play('play');
						}
					case 'mc_camera':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('mc');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/mc_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'mc_camera', 24, false);
							portraitRight.animation.play('play');
						}
					case 'mc_happy':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('mc');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/mc_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'mc_happy', 24, false);
							portraitRight.animation.play('play');
						}
					case 'mc_sigh':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('mc');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/mc_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'mc_sigh', 24, false);
							portraitRight.animation.play('play');
						}

					//Boyfriend animations
					case 'bf_neutral':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('BFText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('bf');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'bfneutral', 24, false);
							portraitRight.animation.play('play');
						}
					case 'bf_beep':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('BFText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('bf');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'bfbeep', 24, false);
							portraitRight.animation.play('play');
						}
					case 'bf_yeah':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('BFText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('bf');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'bf_yeah', 24, false);
							portraitRight.animation.play('play');
						}
					case 'bf_yeah_left':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('BFText'), 0.8)];
						portraitLeft.visible = false;
						box.animation.play('bf');
						if (!portraitLeft.visible)
						{
							portraitLeft.visible = true;
							portraitLeft.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue','doki');
							portraitLeft.animation.addByPrefix('play', 'bf_yeah', 24, false);
							portraitLeft.animation.play('play');
							portraitLeft.flipX = true;
						}
					case 'bf_think':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('BFText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('bf');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'bf_think', 24, false);
							portraitRight.animation.play('play');
						}
					case 'bf_scared':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('BFText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('bf');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'bf_scared', 24, false);
							portraitRight.animation.play('play');
						}


					//GF animations
					case 'gf_neutral':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('GFText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('gf');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/gf_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'gfneutral', 24, false);
							portraitRight.animation.play('play');
						}
					case 'gf_giggle':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('GFText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('gf');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/gf_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'gf_giggle', 24, false);
							portraitRight.animation.play('play');
						}
					case 'gf_scared':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('GFText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('gf');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/gf_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'gf_scared', 24, false);
							portraitRight.animation.play('play');
						}
					case 'gf_yeah':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('GFText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('gf');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/gf_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'gf_yeah', 24, false);
							portraitRight.animation.play('play');
						}
					case 'gf_ehh':
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('GFText'), 0.8)];
						portraitRight.visible = false;
						box.animation.play('gf');
						if (!portraitRight.visible)
						{
							portraitRight.visible = true;
							portraitRight.frames = Paths.getSparrowAtlas('dialogue/gf_dialogue','doki');
							portraitRight.animation.addByPrefix('play', 'gf_ehh', 24, false);
							portraitRight.animation.play('play');
						}
					
					//extras
					case 'startmusic':
						FlxG.sound.playMusic(Paths.music(dialogueList[0], 'shared'));
						enddialogue();
					case 'endmusic':
						if (FlxG.sound.music != null)
							FlxG.sound.music.fadeOut(0.5, 0);
						enddialogue();
					case 'glitch':
						//Fuck glitch, I have no idea how to approach this atm

					case 'hideright':
						portraitRight.visible = false;
						enddialogue();

					case 'hideleft':
						portraitLeft.visible = false;
						enddialogue();
						
						
				}
			}
					
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();

	}
}