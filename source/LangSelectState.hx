#if FEATURE_LANGUAGE
package;

import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import shaders.ColorMaskShader;

using StringTools;

class LangSelectState extends MusicBeatState
{
	var textMenuItems:Array<String> = [];
	var localeList:Array<String> = [];

	var curSelected:Int = 0;

	var backdrop:FlxBackdrop;

	var grpOptionsTexts:FlxTypedGroup<FlxText>;

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
		add(backdrop);

		localeList = Main.tongue.locales;

		for (i in 0...localeList.length)
			textMenuItems.push(Main.tongue.getIndexString(Language, localeList[i]));

		grpOptionsTexts = new FlxTypedGroup<FlxText>();
		add(grpOptionsTexts);

		var titleText:FlxText = new FlxText(0, 20, 0, LangUtil.getString('cmnLanguage'));
		titleText.setFormat(LangUtil.getFont('riffic'), 48, FlxColor.WHITE, CENTER);
		titleText.y += LangUtil.getFontOffset('riffic');
		titleText.setBorderStyle(OUTLINE, 0xFFFF7CFF, 3);
		titleText.screenCenter(X);
		titleText.antialiasing = SaveData.globalAntialiasing;
		add(titleText);

		for (i in 0...textMenuItems.length)
		{
			var optionText:FlxText = new FlxText(0, titleText.height + 50 + (i * 50), 0, textMenuItems[i]);
			optionText.setFormat(LangUtil.getFont('riffic'), 32, FlxColor.WHITE, CENTER);
			optionText.y += LangUtil.getFontOffset('riffic');
			optionText.screenCenter(X);
			optionText.antialiasing = SaveData.globalAntialiasing;
			optionText.ID = i;
			grpOptionsTexts.add(optionText);
		}

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!selectedSomethin)
		{
			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new OptionsState());
			}

			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected -= 1;
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				curSelected += 1;
			}

			if (curSelected < 0)
				curSelected = textMenuItems.length - 1;

			if (curSelected >= textMenuItems.length)
				curSelected = 0;

			grpOptionsTexts.forEach(function(txt:FlxText)
			{
				if (txt.ID == curSelected)
					txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
				else
					txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			});

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpOptionsTexts.forEach(function(txt:FlxText)
				{
					if (curSelected != txt.ID)
					{
						FlxTween.tween(txt, {alpha: 0}, 1.3, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								txt.kill();
							}
						});
					}
					else
					{
						SaveData.language = localeList[curSelected];
						trace('Game language set to ${SaveData.language}');
						Main.tongue.initialize({locale: SaveData.language});

						if (SaveData.flashing)
						{
							FlxFlicker.flicker(txt, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								MusicBeatState.switchState(new OptionsState());
							});
						}
						else
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								MusicBeatState.switchState(new OptionsState());
							});
						}
					}
				});
			}
		}
	}
}
#end
