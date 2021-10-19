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

		//DokiStoryState.instance.acceptInput = false;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		background = new FlxSprite(-offsetX, -offsetY).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		background.alpha = 0.5;
		add(background);

		// this needs to be an actual sprite for the glitched variant
		box = new FlxSprite(0, 0).makeGraphic(612, 308, 0xFFFBE5EE);
		box.screenCenter(XY);
		box.x -= offsetX;
		box.y -= offsetY;
		add(box);

		grpText = new FlxTypedGroup<FlxText>();
		add(grpText);

		for (i in 0...popupTextLines.length)
		{
			var text:FlxText = new FlxText(0, box.y + 50 + (i * 50), box.width * 0.95, popupTextLines[i]);
			text.setFormat(LangUtil.getFont('aller'), 32, FlxColor.BLACK, FlxTextAlign.CENTER);
			text.screenCenter(X);
			text.x -= offsetX;
			text.antialiasing = true;
			text.ID = i;
			grpText.add(text);
		}
	}

	override function update(elapsed:Float)
	{
        if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			//DokiStoryState.instance.acceptInput = true;
			close();
		}

		super.update(elapsed);
	}
}
