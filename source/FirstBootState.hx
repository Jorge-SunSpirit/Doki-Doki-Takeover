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

class FirstBootState extends MusicBeatState
{
	var textMenuItems:Array<String> = [];
	var localeList:Array<String> = [];

	var selectedsomething:Bool = false;

	var curSelected:Int = 0;

	var backdrop:FlxBackdrop;
	var bg:FlxSprite;
	var funnynote:FlxSprite;

	var grpOptionsTexts:FlxTypedGroup<FlxText>;

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		var languageList:Array<String> = CoolUtil.coolTextFile(Paths.txt('locale/languageList'));

		for (i in 0...languageList.length)
		{
			var data:Array<String> = languageList[i].split(':');
			textMenuItems.push(data[0]);
			localeList.push(data[1]);
		}

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		grpOptionsTexts = new FlxTypedGroup<FlxText>();
		add(grpOptionsTexts);

		for (i in 0...textMenuItems.length)
		{
			var optionText:FlxText = new FlxText(0, 50 + (i * 50), 0, textMenuItems[i]);
			optionText.setFormat(LangUtil.getFont('riffic'), 32, FlxColor.WHITE, CENTER);
			optionText.screenCenter(X);
			optionText.antialiasing = true;
			optionText.ID = i;
			grpOptionsTexts.add(optionText);
		}

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume > 0)
			FlxG.sound.music.volume -= 0.25 * FlxG.elapsed;

		super.update(elapsed);

		if (controls.ACCEPT && selectedSomethin && !selectedsomething)
		{
			FlxTween.tween(funnynote, {alpha: 0}, 2, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween)
				{
					funnynote.kill();
					#if FEATURE_CACHING
					FlxG.switchState(new TitleState());
					#else
					FlxG.switchState(new OutdatedSubState());
					#end
				}
			});
		}

		if (!selectedSomethin)
		{
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
				txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);

				if (txt.ID == curSelected)
					txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
			});

			if (controls.ACCEPT)
			{
				selectedsomething = true;
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				grpOptionsTexts.forEach(function(txt:FlxText)
				{
					if (curSelected != txt.ID)
					{
						FlxTween.tween(bg, {alpha: 0}, 1.3, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
						{
						}});
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
						if (FlxG.save.data.flashing)
						{
							FlxFlicker.flicker(txt, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								FlxG.save.data.language = localeList[curSelected];
								trace('langauge set to ' + FlxG.save.data.language);
								LangUtil.localeList = CoolUtil.coolTextFile(Paths.txt('data/textData', 'preload', true));
								new FlxTimer().start(2, function(tmr:FlxTimer)
								{
									FlxG.sound.play(Paths.sound('flip_page', 'shared'));
									bringinthenote();
								});
							});
						}
						else
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								FlxG.save.data.language = localeList[curSelected];
								trace('langauge set to ' + FlxG.save.data.language);
								LangUtil.localeList = CoolUtil.coolTextFile(Paths.txt('data/textData', 'preload', true));
								new FlxTimer().start(2, function(tmr:FlxTimer)
								{
									FlxG.sound.play(Paths.sound('flip_page', 'shared'));
									bringinthenote();
								});
							});
						}
					}
				});
			}
		}
	}

	function bringinthenote()
	{
		funnynote = new FlxSprite(0, 0).loadGraphic(Paths.image('DDLCIntroWarning', 'preload', true));
		funnynote.alpha = 0;
		funnynote.screenCenter(X);
		add(funnynote);
		FlxTween.tween(funnynote, {alpha: 1}, 1, {
			ease: FlxEase.quadOut,
			onComplete: function(twn:FlxTween)
			{
				selectedsomething = false;
			}
		});
	}
}
