package;

import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;

using StringTools;

class JudgementSubstate extends MusicBeatSubstate
{
	var keyTextDisplay:FlxText;
	var curSelected:Int = 0;

	var judgementText:Array<String> = ["NO", "BAD", "GOOD", "DOKI"];

	var defaultTimings:Array<Float> = [166.67, 135.0, 90.0, 45.0];

	var judgementTimings:Array<Float> = [
		SaveData.shitMs,
		SaveData.badMs,
		SaveData.goodMs,
		SaveData.sickMs
	];

	var blackBox:FlxSprite;
	var infoText:FlxText;

	var acceptInput:Bool = false;

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat(LangUtil.getFont('riffic'), 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFF7CFF);
		keyTextDisplay.y += LangUtil.getFontOffset('riffic');
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 3;
		keyTextDisplay.antialiasing = SaveData.globalAntialiasing;

		blackBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackBox);

		infoText = new FlxText(-10, 580, 1280, LangUtil.getString('descJudgementControls', 'option'), 72);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat(LangUtil.getFont('riffic'), 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFF7CFF);
		infoText.y += LangUtil.getFontOffset('riffic');
		infoText.borderSize = 2;
		infoText.borderQuality = 3;
		infoText.alpha = 0;
		infoText.screenCenter(FlxAxes.X);
		infoText.antialiasing = SaveData.globalAntialiasing;
		add(infoText);
		add(keyTextDisplay);

		blackBox.alpha = 0;
		keyTextDisplay.alpha = 0;

		FlxTween.tween(keyTextDisplay, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0.7}, 1, {
			ease: FlxEase.expoInOut,
			onComplete: function(flx:FlxTween)
			{
				acceptInput = true;
			}
		});

		OptionsState.instance.acceptInput = false;

		textUpdate();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (acceptInput)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
				textUpdate();
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
				textUpdate();
			}

			if (FlxG.keys.pressed.SHIFT)
			{
				if (controls.LEFT)
				{
					judgementTimings[curSelected]--;
					updateJudgement();
				}

				if (controls.RIGHT)
				{
					judgementTimings[curSelected]++;
					updateJudgement();
				}
			}
			else if (FlxG.keys.pressed.CONTROL)
			{
				if (controls.LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					judgementTimings[curSelected] -= 0.1;
					updateJudgement();
				}

				if (controls.RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					judgementTimings[curSelected] += 0.1;
					updateJudgement();
				}
			}
			else if (FlxG.keys.pressed.ALT)
			{
				if (controls.LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					judgementTimings[curSelected] -= 0.01;
					updateJudgement();
				}

				if (controls.RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					judgementTimings[curSelected] += 0.01;
					updateJudgement();
				}
			}
			else
			{
				if (controls.LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					judgementTimings[curSelected]--;
					updateJudgement();
				}

				if (controls.RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					judgementTimings[curSelected]++;
					updateJudgement();
				}
			}

			if (controls.BACK)
				quit();
			else if (controls.RESET)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				reset();
			}
		}

		super.update(elapsed);
	}

	function updateJudgement()
	{
		if (judgementTimings[curSelected] < 0)
			judgementTimings[curSelected] = 0;

		judgementTimings[curSelected] = FlxMath.roundDecimal(judgementTimings[curSelected], 2);

		textUpdate();
	}

	function textUpdate()
	{
		keyTextDisplay.text = "\n\n";

		for (i in 0...judgementText.length)
		{
			var textStart = (i == curSelected) ? "> " : "  ";
			keyTextDisplay.text += textStart + judgementText[i] + ": " + judgementTimings[i] + " ms\n";
		}

		keyTextDisplay.screenCenter();
	}

	function save()
	{
		SaveData.shitMs = judgementTimings[0];
		SaveData.badMs = judgementTimings[1];
		SaveData.goodMs = judgementTimings[2];
		SaveData.sickMs = judgementTimings[3];

		SaveData.save();

		Ratings.timingWindows = [
			SaveData.shitMs,
			SaveData.badMs,
			SaveData.goodMs,
			SaveData.sickMs
		];

		Conductor.safeZoneOffset = Ratings.timingWindows[0];
	}

	function reset()
	{
		if (FlxG.keys.pressed.SHIFT)
		{
			for (i in 0...judgementTimings.length)
			{
				judgementTimings[i] = defaultTimings[i];
			}
		}
		else
			judgementTimings[curSelected] = defaultTimings[curSelected];

		textUpdate();
	}

	function quit()
	{
		save();

		FlxTween.tween(keyTextDisplay, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0}, 1.1, {
			ease: FlxEase.expoInOut,
			onComplete: function(flx:FlxTween)
			{
				OptionsState.instance.acceptInput = true;
				close();
			}
		});
		FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
	}

	function changeItem(_amount:Int = 0)
	{
		curSelected += _amount;

		if (curSelected > 3)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 3;
	}
}
