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

class ThankyouState extends MusicBeatState
{
	var textMenuItems:Array<String> = [];
	var localeList:Array<String> = [];

	var selectedsomething:Bool = true;

	var curSelected:Int = 0;

	var backdrop:FlxBackdrop;
	var funnynote:FlxSprite;

	var grpOptionsTexts:FlxTypedGroup<FlxText>;

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.play(Paths.sound('flip_page', 'preload'));

		funnynote = new FlxSprite(0, 0).loadGraphic(Paths.image('thankyoupoem', 'preload'));
		funnynote.alpha = 0.001;
		funnynote.screenCenter(X);
		add(funnynote);
		FlxTween.tween(funnynote, {alpha: 1}, 1, {
			ease: FlxEase.quadOut,
			onComplete: function(twn:FlxTween)
			{
				selectedsomething = false;
			}
		});

		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			selectedsomething = false;
		});
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT && !selectedsomething)
		{
			selectedsomething = true;
			FlxTween.tween(funnynote, {alpha: 0}, 2, {
				ease: FlxEase.quadOut,
				onComplete: function(twn:FlxTween)
				{
					funnynote.kill();
					FlxG.switchState(new CreditsState());
				}
			});
		}
	}
}