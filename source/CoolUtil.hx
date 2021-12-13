package;

import flixel.FlxG;
import openfl.display.BitmapData;
import lime.utils.Assets;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
#if FEATURE_FILESYSTEM
import sys.io.Process;
import sys.FileSystem;
#end

using StringTools;

class CoolUtil
{
	public static var programList:Array<String> = [
		'obs32',
		'obs64',
		'streamlabs obs',
		'bdcam',
		'fraps',
		'xsplit', // TIL c# program
		'hycam2', // hueh
		'twitchstudio' // why
	];

	public static function difficultyString():String
	{
		var difficultyArray:Array<String> = [
			LangUtil.getString('cmnEasy'),
			LangUtil.getString('cmnNormal'),
			LangUtil.getString('cmnHard')
		];

		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function isRecording():Bool
	{
		#if FEATURE_OBS
		var taskList:Process = new Process('tasklist', []);
		var readableList:String = taskList.stdout.readAll().toString().toLowerCase();
		var isOBS:Bool = false;

		for (i in 0...programList.length)
		{
			if (readableList.contains(programList[i]))
				isOBS = true;
		}

		taskList.close();
		readableList = '';

		return isOBS;
		#else
		return false;
		#end
	}

	public static function coolText(path:String):String
	{
		var daList:String = Assets.getText(path).trim();
		return daList;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function coolStringFile(path:String):Array<String>
	{
		var daList:Array<String> = path.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function camLerpShit(ease:Float):Float
	{
		return FlxG.elapsed / (1 / 60) * ease;
	}

	public static function coolLerp(a:Float, b:Float, ratio:Float):Float
	{
		return a + camLerpShit(ratio) * (b - a);
	}

	public static function crash()
	{
		#if FEATURE_FILESYSTEM
		Sys.exit(0);
		#else
		FlxTransitionableState.skipNextTransOut = true;
		FlxTransitionableState.skipNextTransIn = true;
		FlxG.switchState(new CrashState());
		#end
	}
}
