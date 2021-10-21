package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class PopupMessage extends MusicBeatSubstate
{
	var background:FlxSprite;
	var box:FlxSprite;

	var offsetX:Float = (FlxG.width / 2);
	var offsetY:Float = (FlxG.height / 2);

	var grpText:FlxTypedGroup<FlxText>;

	public function new(popupText:String, ?isGlitched:Bool = false)
	{
		super();

		var popupTextLines:Array<String> = popupText.trim().split('{NL}');

		DokiStoryState.instance.acceptInput = false;

		// FlxG.sound.play(Paths.sound('scrollMenu'));

		background = new FlxSprite(-offsetX, -offsetY).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		background.alpha = 0.5;
		add(background);

		box = new FlxSprite(0, 0);
		box.frames = Paths.getSparrowAtlas('dokistory/popup', 'preload');
		box.animation.addByPrefix('normal', 'normal');
		box.animation.addByPrefix('glitch', 'glitch');
		box.animation.play('normal');
		box.antialiasing = true;
		box.screenCenter(XY);
		box.x -= offsetX;
		box.y -= offsetY;
		box.offset.set(-71);
		add(box);

		if (isGlitched)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			box.animation.play('glitch');
			box.offset.set(0);
		}

		grpText = new FlxTypedGroup<FlxText>();
		add(grpText);

		for (i in 0...popupTextLines.length)
		{
			var text:FlxText = new FlxText(0, box.y + 76 + (i * 38), box.frameWidth * 0.95, popupTextLines[i]);
			text.setFormat(LangUtil.getFont('aller'), 32, FlxColor.BLACK, FlxTextAlign.CENTER);
			text.screenCenter(X);
			text.x -= offsetX;
			text.antialiasing = true;
			grpText.add(text);
		}
	}

	override function update(elapsed:Float)
	{
        if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			DokiStoryState.showPopUp = false;

			if (DokiStoryState.secondaryPopUp)
			{
				DokiStoryState.popupWeek = 0;
				DokiStoryState.secondaryPopUp = false;
			}
			else if (DokiStoryState.popupWeek == 1 || DokiStoryState.popupWeek == 5)
				DokiStoryState.secondaryPopUp = true;

			if (!FlxG.sound.music.playing)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(102);
			}

			switch (DokiStoryState.popupWeek)
			{
				default:
					FlxG.save.data.monipopup = true;
				case 1:
					FlxG.save.data.sayopopup = true;
				case 2:
					FlxG.save.data.natpopup = true;
				case 4:
					FlxG.save.data.extra1popup = true;
				case 5:
					FlxG.save.data.extra2popup = true;
			}

			if (FlxG.save.data.yuribeaten)
				FlxG.save.data.yuripopup = true;

			DokiStoryState.instance.acceptInput = true;
			close();
		}

		super.update(elapsed);
	}
}
