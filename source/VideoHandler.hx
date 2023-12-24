#if FEATURE_MP4
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import hxcodec.flixel.FlxVideo;
import openfl.events.KeyboardEvent;

class VideoHandler extends FlxVideo
{
	public var canSkip:Bool = false;
	public var skipKeys:Array<FlxKey> = [];

	public function new():Void
	{
		super();

		onEndReached.add(function()
		{
			dispose();
		});
	}

	override public function play(location:String, shouldLoop:Bool = false):Int
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.mouse.visible = false;
		FlxG.sound.music.stop();

		return super.play(location, shouldLoop);
	}

	override public function dispose():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.mouse.visible = true;
		super.dispose();
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		if (!canSkip)
			return;

		if (skipKeys.contains(event.keyCode))
		{
			canSkip = false;
			onEndReached.dispatch();
		}
	}
}
#end
