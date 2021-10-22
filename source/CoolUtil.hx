package;

import openfl.display.BitmapData;
import lime.utils.Assets;
import flixel.graphics.FlxGraphic;
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
		'hycam2' // hueh
	];

	public static var pfpPath:String = '';
	public static var grabbedPfp:Bool = false;

	public static function difficultyString():String
	{
		var difficultyArray:Array<String> = [LangUtil.getString('cmnEasy'), LangUtil.getString('cmnNormal'), LangUtil.getString('cmnHard')];

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

	public static function grabUserIcon():FlxGraphic
	{
		#if FEATURE_ICON
		if (!grabbedPfp)
		{
			if (FileSystem.exists(Sys.getEnv("localappdata") + '\\Microsoft\\Windows\\AccountPicture\\UserImage.jpg'))
				pfpPath = Sys.getEnv("localappdata") + '\\Microsoft\\Windows\\AccountPicture\\UserImage.jpg';
			grabbedPfp = true;
		}

		if (FileSystem.exists(pfpPath))
		{
			var avatar = BitmapData.fromFile(pfpPath);
			return FlxGraphic.fromBitmapData(avatar);
		}
		else
			return Paths.loadImage('icons/icon-bf', 'shared');
		#else
		return Paths.loadImage('icons/icon-bf', 'shared');
		#end
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
}
