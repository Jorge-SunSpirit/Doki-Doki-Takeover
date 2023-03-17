#if FEATURE_LANGUAGE
package;

import flixel.FlxG;
import flixel.FlxSprite;
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
	var backdrop:FlxBackdrop;

	var curSelected:Int = 0;

	var textMenuItems:Array<String> = [];
	var localeList:Array<String> = [];

	var grpOptionsTexts:FlxTypedGroup<FlxText>;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;

		FlxG.sound.play(Paths.sound('openOS', 'preload'));

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-16, 0);
		backdrop.scale.set(0.2, 0.2);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFF780D48, 0xFF87235D);
		add(backdrop);

		var gradient:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('gradient', 'preload'));
		gradient.antialiasing = SaveData.globalAntialiasing;
		gradient.color = 0xFF46114A;
		add(gradient);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('language/background'));
		bg.antialiasing = SaveData.globalAntialiasing;
		add(bg);

		// Featuring: working around dumb library issues
		// https://github.com/larsiusprime/firetongue/issues/48
		localeList = CoolUtil.coolTextFile(Paths.txt('locales/sort', 'preload'));

		for (i in 0...localeList.length)
			textMenuItems.push(localeList[i]); // Display tags for now since stuff isn't translated.
			//textMenuItems.push(Main.tongue.getIndexString(Language, localeList[i]));

		grpOptionsTexts = new FlxTypedGroup<FlxText>();
		add(grpOptionsTexts);

		for (i in 0...textMenuItems.length)
		{
			var optionText:FlxText = new FlxText(252, 96 + (i * 43), 500, textMenuItems[i]);
			optionText.setFormat(LangUtil.getFont('riffic'), 27, FlxColor.WHITE, LEFT);
			optionText.y += LangUtil.getFontOffset('riffic');
			optionText.borderStyle = OUTLINE;
			optionText.borderColor = 0xFFEB489C;
			optionText.antialiasing = SaveData.globalAntialiasing;
			optionText.ID = i;
			grpOptionsTexts.add(optionText);
		}

		var fg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('language/overlay'));
		fg.antialiasing = SaveData.globalAntialiasing;
		add(fg);

		var titleText:FlxText = new FlxText(200, 6, 0, LangUtil.getString('cmnLanguage'));
		titleText.setFormat(LangUtil.getFont('grotesk'), 18, 0xFF821F8B, CENTER);
		titleText.y += LangUtil.getFontOffset('grotesk');
		titleText.antialiasing = SaveData.globalAntialiasing;
		add(titleText);

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
				FlxG.sound.play(Paths.sound('exitOS'));
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
					txt.setBorderStyle(OUTLINE, 0xFFFFA7F3);
				else
					txt.setBorderStyle(OUTLINE, 0xFFEB489C);
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
								FlxG.sound.play(Paths.sound('exitOS'));
								MusicBeatState.switchState(new OptionsState());
							});
						}
						else
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								FlxG.sound.play(Paths.sound('exitOS'));
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
