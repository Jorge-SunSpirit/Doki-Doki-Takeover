package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import shaders.ColorMaskShader;

class FirstBootState extends MusicBeatState
{
	var textMenuItems:Array<String> = [];
	var localeList:Array<String> = [];

	var selectedsomething:Bool = false;

	var curSelected:Int = 0;

	var backdrop:FlxBackdrop;
	var gradient:FlxSprite;
	var funnynote:FlxSprite;

	var grpOptionsTexts:FlxTypedGroup<FlxText>;

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-16, 0);
		backdrop.scale.set(0.2, 0.2);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFF780D48, 0xFF87235D);
		backdrop.alpha = 0.001;
		add(backdrop);

		gradient = new FlxSprite(0, 0).loadGraphic(Paths.image('gradient', 'preload'));
		gradient.antialiasing = SaveData.globalAntialiasing;
		gradient.color = 0xFF46114A;
		gradient.alpha = 0.001;
		add(gradient);

		#if FEATURE_LANGUAGE
		backdrop.alpha = 1;
		gradient.alpha = 1;

		localeList = CoolUtil.coolTextFile(Paths.txt('locales/sort', 'preload'));

		for (i in 0...localeList.length)
			textMenuItems.push(Main.tongue.getIndexString(Language, localeList[i]));

		grpOptionsTexts = new FlxTypedGroup<FlxText>();
		add(grpOptionsTexts);

		for (i in 0...textMenuItems.length)
		{
			var optionText:FlxText = new FlxText(0, 50 + (i * 50), 0, textMenuItems[i]);
			optionText.setFormat(LangUtil.getFont('riffic'), 32, FlxColor.WHITE, CENTER);
			optionText.y += LangUtil.getFontOffset('riffic');
			optionText.screenCenter(X);
			optionText.antialiasing = SaveData.globalAntialiasing;
			optionText.ID = i;
			grpOptionsTexts.add(optionText);
		}
		#else
		FlxTween.tween(backdrop, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		FlxTween.tween(gradient, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});

		selectedSomethin = true;
		bringinthenote();
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT && selectedSomethin && !selectedsomething)
		{
			FlxG.sound.play(Paths.sound('exitOS', 'preload'));

			FlxTween.tween(funnynote, {"scale.x": 0, "scale.y": 0, alpha: 0}, 0.5, {ease: FlxEase.quadOut});
			FlxTween.tween(backdrop, {alpha: 0}, 1, {ease: FlxEase.quadOut});
			FlxTween.tween(gradient, {alpha: 0}, 1, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween)
				{
					funnynote.kill();
					SaveData.saveStarted = true;
					SaveData.save();
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					MusicBeatState.switchState(new TitleState());
				}
			});
		}

		#if FEATURE_LANGUAGE
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
				if (txt.ID == curSelected)
					txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
				else
					txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
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
						FlxTween.tween(txt, {alpha: 0}, 1, {
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
								new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									bringinthenote();
								});
							});
						}
						else
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									bringinthenote();
								});
							});
						}
					}
				});
			}
		}
		#end
	}

	function bringinthenote()
	{
		FlxG.sound.play(Paths.sound('openOS', 'preload'));

		funnynote = new FlxSprite(0, 0).loadGraphic(Paths.image('WelcomeBack', 'preload', true));
		funnynote.antialiasing = SaveData.globalAntialiasing;
		funnynote.screenCenter();
		funnynote.scale.set();
		add(funnynote);

		FlxTween.tween(funnynote, {alpha: 1}, 0.3, {ease: FlxEase.quadOut});
		FlxTween.tween(funnynote, {"scale.x": 1}, 0.15, {ease: FlxEase.quadOut});

		FlxTween.tween(funnynote, {"scale.y": 1}, 0.5, {
			ease: FlxEase.quadOut,
			onComplete: function(twn:FlxTween)
			{
				selectedsomething = false;
			}
		});
	}
}
