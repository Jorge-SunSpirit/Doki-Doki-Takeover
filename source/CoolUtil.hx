package;

import lime.utils.Assets;
#if FEATURE_FILESYSTEM
import sys.io.Process;
#end

using StringTools;

class CoolUtil
{
	public static var programList:Array<String> = [
		'obs', // obs64, obs32, streamlabs obs, streamlabs obs32
		'bdcam',
		'fraps',
		'xsplit', // c# program
		'hycam2' // hueh
	];

	public static function difficultyString():String
	{
		var difficultyArray:Array<String> = [LangUtil.getString('cmnEasy'), LangUtil.getString('cmnNormal'), LangUtil.getString('cmnHard')];

		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function isRecording():Bool
	{
		#if FEATURE_FILESYSTEM
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
		return true;
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
