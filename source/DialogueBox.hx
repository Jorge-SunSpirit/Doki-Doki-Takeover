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

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var expression:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
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
		switch (PlayState.SONG.noteStyle)
			{
				case 'pixel':
					{
						hasDialog = true;
						box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-monika');
						box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
						box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
					}
				case 'normal':
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
						box.antialiasing = true;
					}
			}

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;

		switch (PlayState.SONG.noteStyle)
			{
				case 'pixel':
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
				case 'normal':
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
			}
		
		box.animation.play('normalOpen');
		switch (PlayState.SONG.noteStyle)
			{
				case 'pixel':
					box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
				case 'normal':
					box.y += 400;
					box.setGraphicSize(Std.int(box.width * 1.2));
			}
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		switch (PlayState.SONG.noteStyle)
			{
				case 'default':

				case 'pixel':
					portraitLeft.screenCenter(X);
			}


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		switch (PlayState.SONG.noteStyle)
			{
				case 'pixel':
					{
						dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
						dropText.font = LangUtil.getFont('pixel');
						dropText.color = 0xFFD89494;
						add(dropText);

						swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
						swagDialogue.font = LangUtil.getFont('pixel');
						swagDialogue.color = 0xFF3F2021;
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
						add(swagDialogue);
					}
				case 'normal':
					{
						swagDialogue = new FlxTypeText(220, 520, Std.int(FlxG.width * 0.67), "", 28);
						swagDialogue.font = LangUtil.getFont('aller');
						swagDialogue.color = 0xFFFFFFFF;
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
						swagDialogue.setBorderStyle(OUTLINE, FlxColor.BLACK, 1, 1);
						swagDialogue.antialiasing = true;
						add(swagDialogue);
					}
			}
		

		dialogue = new Alphabet(0, 80, "", false, true);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		switch (PlayState.SONG.noteStyle)
			{
				case 'pixel':
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

		if (FlxG.keys.justPressed.ANY  && dialogueStarted == true)
		{
					remove(dialogue);
						
					FlxG.sound.play(Paths.sound('clickText'), 0.8);
					enddialogue();
		}
		
		super.update(elapsed);
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
							switch (PlayState.SONG.noteStyle)
								{
									case 'pixel':
										dropText.alpha = swagDialogue.alpha;
								}	
						}, 5);
	
						new FlxTimer().start(1.2, function(tmr:FlxTimer)
						{
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
		switch (PlayState.SONG.noteStyle)
			{
				case 'pixel':
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
				case 'normal':
					{
						switch (curCharacter)
						{
							//Yuri animations
							case 'yuri':
								//very much placeholder and I hate it
								portraitLeft.visible = false;
								box.animation.play('yuri');
								if (!portraitLeft.visible)
								{
									portraitLeft.visible = true;
									portraitLeft.frames = Paths.getSparrowAtlas('dialogue/yuri_dialogue','doki');
									portraitLeft.animation.addByPrefix('play', 'yurineutral', 24, false);
									portraitLeft.animation.play('play');
								}
							
							case 'yuri_ehh':
								//very much placeholder and I hate it
								portraitLeft.visible = false;
								box.animation.play('yuri');
								if (!portraitLeft.visible)
								{
									portraitLeft.visible = true;
									portraitLeft.frames = Paths.getSparrowAtlas('dialogue/yuri_dialogue','doki');
									portraitLeft.animation.addByPrefix('play', 'yuri_ehh', 24, false);
									portraitLeft.animation.play('play');
								}
							
							//Natsuki animations
							case 'natsuki':
								//very much placeholder and I hate it
								portraitLeft.visible = false;
								box.animation.play('natsuki');
								if (!portraitLeft.visible)
								{
									portraitLeft.visible = true;
									portraitLeft.frames = Paths.getSparrowAtlas('dialogue/nat_dialogue','doki');
									portraitLeft.animation.addByPrefix('play', 'nat_hmmph', 24, false);
									portraitLeft.animation.play('play');
								}

							case 'natsuki_angy':
								//very much placeholder and I hate it
								portraitLeft.visible = false;
								box.animation.play('natsuki');
								if (!portraitLeft.visible)
								{
									portraitLeft.visible = true;
									portraitLeft.frames = Paths.getSparrowAtlas('dialogue/nat_dialogue','doki');
									portraitLeft.animation.addByPrefix('play', 'nat_angy', 24, false);
									portraitLeft.animation.play('play');
								}

							case 'natsuki_hmmph':
								portraitLeft.visible = false;
								box.animation.play('natsuki');
								if (!portraitLeft.visible)
								{
									portraitLeft.visible = true;
									portraitLeft.frames = Paths.getSparrowAtlas('dialogue/nat_dialogue','doki');
									portraitLeft.animation.addByPrefix('play', 'nat_hmmph', 24, false);
									portraitLeft.animation.play('play');
								}
							
							//Sayori animations
							case 'sayori':
								portraitLeft.visible = false;
								box.animation.play('sayori');
								if (!portraitLeft.visible)
								{
									portraitLeft.visible = true;
									portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
									portraitLeft.animation.addByPrefix('play', 'sayoneutral', 24, false);
									portraitLeft.animation.play('play');
								}
							
							case 'sayori_happ':
								portraitLeft.visible = false;
								box.animation.play('sayori');
								if (!portraitLeft.visible)
								{
									portraitLeft.visible = true;
									portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
									portraitLeft.animation.addByPrefix('play', 'sayo_happ', 24, false);
									portraitLeft.animation.play('play');
								}
							
							case 'sayori_ehh':
								portraitLeft.visible = false;
								box.animation.play('sayori');
								if (!portraitLeft.visible)
								{
									portraitLeft.visible = true;
									portraitLeft.frames = Paths.getSparrowAtlas('dialogue/sayo_dialogue','doki');
									portraitLeft.animation.addByPrefix('play', 'sayo_ehh', 24, false);
									portraitLeft.animation.play('play');
								}

							//Boyfriend animations
							case 'bf':
								portraitRight.visible = false;
								box.animation.play('bf');
								if (!portraitRight.visible)
								{
									portraitRight.visible = true;
									portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue','doki');
									portraitRight.animation.addByPrefix('play', 'bfneutral', 24, false);
									portraitRight.animation.play('play');
								}
							
							case 'bfbeep':
								portraitRight.visible = false;
								box.animation.play('bf');
								if (!portraitRight.visible)
								{
									portraitRight.visible = true;
									portraitRight.frames = Paths.getSparrowAtlas('dialogue/bf_dialogue','doki');
									portraitRight.animation.addByPrefix('play', 'bfbeep', 24, false);
									portraitRight.animation.play('play');
								}


							case 'gf':
								portraitRight.visible = false;
								box.animation.play('gf');
								if (!portraitRight.visible)
								{
									portraitRight.visible = true;
									portraitRight.frames = Paths.getSparrowAtlas('dialogue/gf_dialogue','doki');
									portraitRight.animation.addByPrefix('play', 'gfneutral', 24, false);
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
								

							case 'hideright':
								portraitRight.visible = false;
								enddialogue();

							case 'hideleft':
								portraitLeft.visible = false;
								enddialogue();
								
								
						}
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