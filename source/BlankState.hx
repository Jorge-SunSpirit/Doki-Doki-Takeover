package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class BlankState extends MusicBeatState
{
	override function create()
	{
		var blackscreen:FlxSprite = new FlxSprite(0 , 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackscreen);

		super.create();
	}
}
