package;

import Section.SwagSection;
import haxe.Json;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var offset:Float;
	var numofchar:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var player3:String;
	var player4:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var offset:Float = 0;
	public var numofchar:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var player3:String = 'bf';
	public var player4:String = 'bf';
	public var gfVersion:String = 'gf';
	public var noteStyle:String = 'normal';
	public var stage:String = 'stage';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = OpenFlAssets.getText(Paths.json('songs/${folder.toLowerCase()}/${jsonInput.toLowerCase()}')).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		return cast Json.parse(rawJson).song;
	}
}

typedef SwagMetadata =
{
	var song:SwagMetadataInfo;
}

typedef SwagMetadataInfo =
{
	var name:String;
	var artist:String;
	var artist_encore:String;
	var icon:String;
	var pause:String;
	var playManually:Bool;
	var allowCountDown:Bool;
	var freeplayDialogue:Bool;
	var introDialogue:String;
	var introDialogueBeat:String; // use for stuff like Epiphany's encore
	var introDialogueAlt:String; // use for stuff like Epiphany's lyric
	var endDialogue:String;
}
