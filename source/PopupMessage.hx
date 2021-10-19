package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class PopupMessage extends MusicBeatSubstate
{
	var background:FlxSprite;
	var boxOutline:FlxSprite;
	var box:FlxSprite;
    var text:FlxText;
    var okay:FlxText;

	public function new(popupText:String)
	{
		super();

		FlxG.sound.play(Paths.sound('scrollMenu'));

		background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		background.alpha = 0.5;
		add(background);

		// this needs to be an actual sprite for the glitched variant
        boxOutline = new FlxSprite(0, 0).makeGraphic(626, 320, 0xFFF5BEDA);
		boxOutline.screenCenter(XY);
		add(boxOutline);

		box = new FlxSprite(0, 0).makeGraphic(612, 308, 0xFFFBE5EE);
        box.screenCenter(XY);
		add(box);

		text = new FlxText(0, 0, 1280, popupText, 72);
		text.scrollFactor.set(0, 0);
		text.setFormat(LangUtil.getFont('aller'), 42, FlxColor.BLACK, FlxTextAlign.CENTER);
        text.screenCenter(X);
		text.antialiasing = true;
		add(text);

		okay = new FlxText(0, 0, 1280, "OK", 72);
		okay.scrollFactor.set(0, 0);
		okay.setFormat(LangUtil.getFont('riffic'), 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, 0xFFB75798);
        okay.screenCenter(X);
		okay.antialiasing = true;
		add(okay);
	}

	override function update(elapsed:Float)
	{
		/*
		if (DokiStoryState.instance.acceptInput)
			DokiStoryState.instance.acceptInput = false;
		*/

        if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			// DokiStoryState.instance.acceptInput = true;
			close();
		}

		super.update(elapsed);
	}
}
