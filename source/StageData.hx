package;

import openfl.utils.Assets;
import haxe.Json;
import Song;

using StringTools;

typedef StageFile =
{
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
	var hide_girlfriend:Bool;
	
	var forced_camera_position:Bool;
	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_center:Array<Float>;
	var camera_speed:Null<Float>;
}

class StageData
{
	public static var forceNextDirectory:String = null;

	public static function loadDirectory(SONG:SwagSong)
	{
		var stage:String = '';

		if (SONG.stage != null)
		{
			stage = SONG.stage;
		}
		else
		{
			stage = 'stage';
		}

		var stageFile:StageFile = getStageFile(stage);

		if (stageFile == null)
		{ // preventing crashes
			forceNextDirectory = '';
		}
		else
		{
			forceNextDirectory = stageFile.directory;
		}
	}

	public static function getStageFile(stage:String):StageFile
	{
		var rawJson:String = null;
		var path:String = Paths.json('stages/' + stage);

		if (Assets.exists(path))
		{
			rawJson = Assets.getText(path);
		}
		else
		{
			return null;
		}

		try
		{
			return cast Json.parse(rawJson);
		}
		catch (e)
		{
			Main.alertPopup('A stage json ($stage) has failed to load properly, your installation may be corrupt.\n\nPlease try redownloading the mod.');
			Sys.exit(0);

			return null;
		}
	}
}
