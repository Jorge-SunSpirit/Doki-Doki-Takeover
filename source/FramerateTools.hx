package;

import flixel.FlxG;

/**
	A set of functions designed to help with some framerate issues that could occur.
**/
class FramerateTools
{
	public static var baseFramerate:Int = 60;

	/**
		A multiplier based on how many frames that have been rendered in comparison to the base framerate.
	**/
	public static function timeMultiplier():Float
	{
		return (1 / baseFramerate) / FlxG.elapsed;
	}

	/**
		Convert an ease from the base framerate to the current running framerate.
	**/
	public static function easeConvert(ease:Float):Float
	{
		return ease / timeMultiplier();
	}

	/**
		Convert a lerp from the base framerate to the current running framerate.
	**/
	public static function lerpConvert(a:Float, b:Float, ratio:Float):Float
	{
		return a + easeConvert(ratio) * (b - a);
	}

	/**
		Convert a duration (in frames) from the base framerate to the current running framerate.
	**/
	public static function frameConvert(frames:Float):Float
	{
		return 1 / FlxG.elapsed * frames / baseFramerate;
	}
}
