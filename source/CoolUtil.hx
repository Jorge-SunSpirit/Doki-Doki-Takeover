package;

import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionableState;
import openfl.utils.Assets;
#if FEATURE_FILESYSTEM
import sys.io.Process;
import sys.FileSystem;
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

	/**
		* Check for an existing HaxeFlixel save file.
		*
		* @param   company		The company of the HaxeFlixel title, required for saves before 5.0.0+.
		* @param   title		The title/name of the HaxeFlixel title, required for saves before 5.0.0+.
		* @param   localPath	The path of the save file.
		* @param   name			The name of the save file.
		* @param   newPath		Whether or not the save file is from a HaxeFlixel title that's on 5.0.0+.
	**/
	public static function flixelSaveCheck(company:String, title:String, localPath:String = 'ninjamuffin99', name:String = 'funkin', newPath:Bool = false):Bool
	{
		// before anyone asks, this is copy-pasted from FlxSave
		var invalidChars = ~/[ ~%&\\;:"',<>?#]+/;

		// Avoid checking for .sol files directly in AppData
		if (localPath == "")
		{
			var path = company;

			if (path == null || path == "")
			{
				path = "HaxeFlixel";
			}
			else
			{
				#if html5
				// most chars are fine on browsers
				#else
				path = invalidChars.split(path).join("-");
				#end
			}

			localPath = path;
		}

		var directory = lime.system.System.applicationStorageDirectory;
		var path = '';

		if (newPath)
			path = haxe.io.Path.normalize('$directory/../../../$localPath') + "/";
		else
			path = haxe.io.Path.normalize('$directory/../../../$company/$title/$localPath') + "/";

		name = StringTools.replace(name, "//", "/");
		name = StringTools.replace(name, "//", "/");

		if (StringTools.startsWith(name, "/"))
		{
			name = name.substr(1);
		}

		if (StringTools.endsWith(name, "/"))
		{
			name = name.substring(0, name.length - 1);
		}

		if (name.indexOf("/") > -1)
		{
			var split = name.split("/");
			name = "";

			for (i in 0...(split.length - 1))
			{
				name += "#" + split[i] + "/";
			}

			name += split[split.length - 1];
		}

		return FileSystem.exists(path + name + ".sol");
	}

	/**
		Check for an existing renpy save file.
	**/
	public static function renpySaveCheck(?doki:String = 'DDLC-1454445547'):Bool
	{
		var directory = lime.system.System.applicationStorageDirectory;
		var renpy = 'RenPy';
		var path = '';

		#if linux 
		renpy = '.renpy';
		path = haxe.io.Path.normalize('${Sys.getEnv("HOME")}/$renpy/$doki') + "/";
		#elseif mac
		path = haxe.io.Path.normalize('$directory/../../../../$renpy/$doki') + "/";
		#else
		path = haxe.io.Path.normalize('$directory/../../../$renpy/$doki') + "/";
		#end

		return FileSystem.exists(path + "persistent");
	}

	/**
		Check for an existing Doki Doki Literature Club Plus! save file.
	**/
	public static function ddlcpSaveCheck():Bool
	{
		var path = Sys.getEnv("userprofile") + '\\AppData\\LocalLow\\Team Salvato\\Doki Doki Literature Club Plus\\save_preferences.sav';
		return FileSystem.exists(path);
	}

	public static function getUsername():String
	{
		#if FEATURE_OBS
		if (SaveData.selfAware)
		{
			#if windows
			return Sys.environment()["USERNAME"].trim();
			#elseif linux
			return Sys.environment()["USER"].trim();
			#end
		}
		else
			return coolText(Paths.txt('data/name', 'preload'));
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
