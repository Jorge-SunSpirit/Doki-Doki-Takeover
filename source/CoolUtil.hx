package;

import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import openfl.utils.Assets;
#if FEATURE_FILESYSTEM
import sys.io.Process;
#end

using StringTools;

class CoolUtil
{
	public static var programList:Array<String> = [
		'obs',
		'bdcam',
		'fraps',
		'xsplit', // TIL c# program
		'hycam2', // hueh
		'twitchstudio' // why
	];

	public static function difficultyString(diff:Int):String
	{
		var difficultyArray:Array<String> = [
			LangUtil.getString('cmnEasy'),
			LangUtil.getString('cmnNormal'),
			LangUtil.getString('cmnHard')
		];

		return difficultyArray[diff];
	}

	public static function internalDifficultyString(diff:Int):String
	{
		var difficultyArray:Array<String> = ['Easy', 'Normal', 'Hard'];
		return difficultyArray[diff];
	}

	public static function getWeekName(data:Dynamic):String
	{
		switch (data)
		{
			case 0 | 'prologue':
				return 'Prologue';
			case 1 | 'sayori':
				return 'Sayori';
			case 2 | 'natsuki':
				return 'Natsuki';
			case 3 | 'yuri':
				return 'Yuri';
			case 4 | 'monika':
				return 'Monika';
			case 5 | 'festival':
				return 'Festival';
			case 6 | 'encore':
				return 'Encore';
			case 7 | 'protag':
				return 'Protag';
			case 8 | 'side':
				return 'Side';
		}

		return null;
	}

	public static function isRecording():Bool
	{
		#if FEATURE_OBS
		var isOBS:Bool = false;

		try
		{
			#if windows
			var taskList:Process = new Process('tasklist');
			#elseif (linux || macos)
			var taskList:Process = new Process('ps --no-headers');
			#end
			var readableList:String = taskList.stdout.readAll().toString().toLowerCase();

			for (i in 0...programList.length)
			{
				if (readableList.contains(programList[i]))
					isOBS = true;
			}

			taskList.close();
			readableList = '';
		}
		catch (e)
		{
			// If for some reason the game crashes when trying to run Process, just force OBS on
			// in case this happens when they're streaming.
			isOBS = true;
		}

		return isOBS;
		#else
		return false;
		#end
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	public static function coolText(path:String):String
	{
		var daList:String = OpenFlAssets.getText(path).trim();
		return daList;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = OpenFlAssets.getText(path).trim().split('\n');

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

	public static function getFPSCap():Int
	{
		return Std.int(openfl.Lib.current.stage.frameRate);
	}

	public static function setFPSCap(cap:Int):Void
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public static function getUsername():String
	{
		#if FEATURE_OBS
		if (SaveData.selfAware)
		{
			#if windows
			return Sys.environment()["USERNAME"].trim();
			#elseif (linux || macos)
			return Sys.environment()["USER"].trim();
			#else
			return coolText(Paths.txt('data/name', 'preload'));
			#end
		}
		else
		{
			return coolText(Paths.txt('data/name', 'preload'));
		}
		#elseif FEATURE_GAMEJOLT
		if (SaveData.selfAware && !GameJoltAPI.getUserInfo(true).toLowerCase().contains('no user'))
			return GameJoltAPI.getUserInfo(true).trim();
		else
			return coolText(Paths.txt('data/name', 'preload'));
		#else
		return coolText(Paths.txt('data/name', 'preload'));
		#end
	}

	public static function openURL(url:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [url]);
		#else
		FlxG.openURL(url);
		#end
	}

	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		precacheSoundFile(Paths.sound(sound, library));
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void
	{
		precacheSoundFile(Paths.music(sound, library));
	}

	public static function precacheInst(sound:String):Void
	{
		precacheSoundFile(Paths.inst(sound));
	}

	public static function precacheVoices(sound:String, ?prefix:String = '', ?suffix:String = ''):Void
	{
		precacheSoundFile(Paths.voices(sound, prefix, suffix));
	}

	private static function precacheSoundFile(file:Dynamic):Void
	{
		#if !hl
		if (Assets.exists(file, SOUND) || Assets.exists(file, MUSIC))
			Assets.getSound(file, true);
		#end
	}

	public static function calcSectionLength(multiplier:Float = 1.0):Float
	{
		return (Conductor.stepCrochet / (64 / multiplier)) / Conductor.playbackSpeed;
	}
}
