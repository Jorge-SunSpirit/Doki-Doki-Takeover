package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
using StringTools;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Character;
	var camFollow:FlxObject;
	var mirrormode:Bool = false;
	var startSong:Bool = false;
	var libbie:Bool = false;

	var daBf:String = '';
	var stageSuffix = '';
	var isBig:Bool = false;

	public static var crashdeath:Bool = false;

	public function new(x:Float, y:Float, goType:Int)
	{
		FlxG.camera.bgColor = FlxColor.BLACK;

		libbie = PlayState.SONG.song.toLowerCase() == 'libitina';

		if (!PlayState.isStoryMode && !libbie && PlayState.SONG.song.toLowerCase() != 'catfight')
			mirrormode = SaveData.mirrorMode;

		switch (goType)
		{
			case 1:
				mirrormode = false;
			case 2:
				mirrormode = true;
			default:
				trace('No forced gameover type found');
		}

		switch (PlayState.SONG.player1)
		{
			case 'playablesenpai':
				stageSuffix = '-pixel';
				daBf = 'playablesenpai';
			default:
				if (mirrormode)
					daBf = PlayState.boyfriend.gameovercharamirror;
				else
					daBf = PlayState.boyfriend.gameoverchara;
		}

		switch (PlayState.dad.curCharacter)
		{
			case 'bigmonika':
				daBf = 'bigmonika-dead';
				isBig = true;
			case 'bigmonika-dress':
				daBf = 'bigmonika-dress';
				isBig = true;
		}

		super();

		Conductor.songPosition = 0;

		if (!libbie)
		{
			bf = new Character(x, y, daBf, !isBig);
			trace(bf == null ? "bf if hella dumb" : "bf has a big forehead");
			add(bf);

			camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
			add(camFollow);

			if (!crashdeath)
			{
				if (!mirrormode)
					FlxG.sound.play(Paths.sound(bf.deathsound));
				else
					FlxG.sound.play(Paths.sound(bf.winsound));
			}
		}
		else
		{
			FlxTween.cancelTweensOf(FlxG.camera);
			FlxG.camera.zoom = 1;
			var blueScreen = new FlxSprite().loadGraphic(Paths.image('LibiGameOver', 'preload', true));
			blueScreen.scrollFactor.set();
			add(blueScreen);
		}


		Conductor.changeBPM(100);
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		if (!libbie)
		{
			switch (daBf)
			{	
				case 'playablesenpai':
					camFollow.setPosition(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y + 50);

					FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.15}, 0.35, {
						ease: FlxEase.quadOut
					});
				case 'playablegf_dead':
					camFollow.setPosition(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y - 170);
			}


			if (!crashdeath)
			{
				if (mirrormode && !daBf.startsWith('bigmonika') && daBf != "playablesenpai")
				{
					if (bf.animOffsets.exists('hey'))
						bf.playAnim('hey');
					else
					{
						bf.playAnim('singUP');
						new FlxTimer().start(1, function(timer:FlxTimer)
						{
							startSong = true;
							FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
						});
					}		
				}
				else
					bf.playAnim('firstDeath');
			}
			else
			{
				FlxG.sound.play(Paths.sound('JarringMonikaSound'));
				bf.playAnim('crashDeath');
			}
		}
	}

	override function destroy()
	{
		FlxG.mouse.visible = true;
		super.destroy();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT && !crashdeath)
		{
			endBullshit();
		}

		if (controls.BACK && !crashdeath)
		{
			FlxG.sound.music.stop();
			PlayState.sectionStart = false;
			PlayState.mirrormode = false;
			PlayState.chartingMode = false;
			PlayState.practiceMode = false;
			PlayState.practiceModeToggled = false;
			PlayState.showCutscene = true;
			PlayState.deathCounter = 0;
			Conductor.playbackSpeed = 1;
			PlayState.toggleBotplay = false;
			PlayState.ForceDisableDialogue = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new DokiStoryState());
			else
				MusicBeatState.switchState(new DokiFreeplayState());
		}
		if (!libbie)
		{
			if (bf.animation.curAnim.name == 'crashDeath' && bf.animation.finished)
			{
				new FlxTimer().start(.5, function(timer:FlxTimer)
				{
					Sys.exit(0);
				});
			}

			if (!daBf.startsWith('bigmonika'))
			{
				if (bf.animation.curAnim.name == 'hey' && bf.animation.curAnim.curFrame == 7)
				{
					FlxG.camera.follow(camFollow, LOCKON, 0.01);
				}
				if (bf.animation.curAnim.name == 'singUP' && bf.animation.curAnim.curFrame == 5)
				{
					FlxG.camera.follow(camFollow, LOCKON, 0.01);
				}

				if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
				{
					FlxG.camera.follow(camFollow, LOCKON, 0.01);
				}
			}

			if ((bf.animation.curAnim.name == 'firstDeath' || bf.animation.curAnim.name == 'hey') && bf.animation.curAnim.finished && !crashdeath && !startSong)
			{
				startSong = true;
				FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			}

			if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && FlxG.sound.music.playing)
			{
				bf.playAnim('deathLoop');
			}
		}
		else
		{
			if (!startSong)
			{
				startSong = true;
				FlxG.sound.playMusic(Paths.music('gameOver-libi'));
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (bf != null && bf.animation.curAnim.name == 'deathLoop' && curBeat % 2 == 0)
			bf.playAnim('deathLoop');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;

			if (!libbie)
			{
				if (!mirrormode)
					bf.playAnim('deathConfirm', true);
				else
				{
					if (PlayState.SONG.player2 == "bigmonika")
						bf.playAnim('deathConfirm', true);
					else
						bf.playAnim('singDOWNmiss', true);
				}

				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));

				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
					{
						LoadingState.loadAndSwitchState(new PlayState());
					});
				});
			}
			else
				LoadingState.loadAndSwitchState(new PlayState());
		}
	}
}
