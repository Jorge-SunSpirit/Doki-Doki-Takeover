package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class GitarooPause extends MusicBeatState
{
	var replayButton:FlxSprite;
	var cancelButton:FlxSprite;

	var replaySelect:Bool = false;

	public function new():Void
	{
		super();
	}

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pauseAlt/pauseBG'));
		add(bg);

		var bf:FlxSprite = new FlxSprite(0, 30);
		bf.frames = Paths.getSparrowAtlas('pauseAlt/bfLol');
		bf.animation.addByPrefix('lol', "funnyThing", 13);
		bf.animation.play('lol');
		bf.antialiasing = SaveData.globalAntialiasing;
		add(bf);
		bf.screenCenter(X);

		replayButton = new FlxSprite(FlxG.width * 0.28, FlxG.height * 0.7);
		replayButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		replayButton.animation.addByPrefix('selected', 'bluereplay', 0, false);
		replayButton.animation.appendByPrefix('selected', 'yellowreplay');
		replayButton.animation.play('selected');
		replayButton.antialiasing = SaveData.globalAntialiasing;
		add(replayButton);

		cancelButton = new FlxSprite(FlxG.width * 0.58, replayButton.y);
		cancelButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		cancelButton.animation.addByPrefix('selected', 'bluecancel', 0, false);
		cancelButton.animation.appendByPrefix('selected', 'cancelyellow');
		cancelButton.animation.play('selected');
		cancelButton.antialiasing = SaveData.globalAntialiasing;
		add(cancelButton);

		changeThing();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.LEFT_P || controls.RIGHT_P)
			changeThing();

		if (controls.ACCEPT)
		{
			if (replaySelect)
				MusicBeatState.switchState(new PlayState());
			else
			{
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
		}

		super.update(elapsed);
	}

	function changeThing():Void
	{
		replaySelect = !replaySelect;

		if (replaySelect)
		{
			cancelButton.animation.curAnim.curFrame = 0;
			replayButton.animation.curAnim.curFrame = 1;
		}
		else
		{
			cancelButton.animation.curAnim.curFrame = 1;
			replayButton.animation.curAnim.curFrame = 0;
		}
	}
}
