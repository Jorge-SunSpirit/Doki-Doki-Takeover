import flixel.FlxG;
import flixel.util.FlxSave;
import lime.app.Application;

class SaveData
{
	#if (haxe >= "4.0.0")
	public static var songOffsets:Map<String, Float> = new Map();
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();
	public static var songAccuracies:Map<String, Float> = new Map();
	#else
	public static var songOffsets:Map<String, Float> = new Map<String, Float>();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songCombos:Map<String, String> = new Map<String, String>();
	public static var songAccuracies:Map<String, Float> = new Map<String, Float>();
	#end

	public static var language:String = 'en-US';
	public static var customCursor:Null<Bool> = true;
	public static var weekUnlocked:Null<Int> = 1;
	public static var downScroll:Null<Bool> = false;
	public static var coolGameplay:Null<Bool> = false;
	public static var missModeType:Null<Int> = 0;
	public static var accuracyDisplay:Null<Bool> = true;
	public static var offset:Null<Float> = 0;
	public static var songPosition:Null<Bool> = false;
	public static var showFPS:Null<Bool> = false;
	public static var changedHit:Null<Bool> = false;
	public static var changedHitX:Null<Float> = -1;
	public static var changedHitY:Null<Float> = -1;
	public static var framerate:Null<Int> = 60;
	public static var scrollSpeed:Null<Float> = 0.9;
	public static var npsDisplay:Null<Bool> = false;
	public static var ghostTapping:Null<Bool> = true;
	public static var flashing:Null<Bool> = true;
	public static var noReset:Null<Bool> = false;
	public static var botplay:Null<Bool> = false;
	public static var gfCountdown:Null<Bool> = false;
	public static var zoom:Null<Float> = 1;
	public static var middleOpponent:Null<Bool> = false;
	public static var gpuTextures:Null<Bool> = true;
	public static var cacheCharacter:Null<Bool> = false;
	public static var cacheSong:Null<Bool> = false;
	public static var middleScroll:Null<Bool> = false;
	public static var laneUnderlay:Null<Bool> = false;
	public static var laneTransparency:Null<Float> = 0.5;
	public static var selfAware:Null<Bool> = true;
	public static var mirrorMode:Null<Bool> = false;
	public static var randomMode:Null<Bool> = false;
	public static var hitSound:Null<Bool> = false;
	public static var judgeHitSound:Null<Bool> = false;
	public static var hitSoundVolume:Null<Float> = 1;
	public static var noteSplash:Null<Bool> = true;
	public static var earlyLate:Null<Bool> = false;
	public static var autoPause:Null<Bool> = false;
	public static var judgementCounter:Null<Bool> = false;
	public static var showHelp:Null<Bool> = true;
	public static var globalAntialiasing:Null<Bool> = true;
	public static var shitMs:Null<Float> = 166.67;
	public static var badMs:Null<Float> = 135.0;
	public static var goodMs:Null<Float> = 90.0;
	public static var sickMs:Null<Float> = 45.0;
	public static var ratingToggle:Null<Bool> = true;
	public static var shaders:Null<Bool> = true;
	public static var songSpeed:Null<Float> = 1;

	// Costumes
	public static var bfcostume:String = '';
	public static var gfcostume:String = '';
	public static var monikacostume:String = '';
	public static var sayoricostume:String = '';
	public static var natsukicostume:String = '';
	public static var yuricostume:String = '';
	public static var protagcostume:String = '';

	// Unlocks
	public static var saveStarted:Null<Bool> = false;
	public static var beatPrologue:Null<Bool> = false;
	public static var beatSayori:Null<Bool> = false;
	public static var beatNatsuki:Null<Bool> = false;
	public static var beatYuri:Null<Bool> = false;
	public static var beatMonika:Null<Bool> = false;
	public static var beatFestival:Null<Bool> = false;
	public static var beatEncore:Null<Bool> = false;
	public static var beatProtag:Null<Bool> = false;
	public static var beatSide:Null<Bool> = false;
	public static var unlockedEpiphany:Null<Bool> = false;
	public static var beatEpiphany:Null<Bool> = false;
	public static var beatCatfight:Null<Bool> = false;
	public static var beatVA11HallA:Null<Bool> = false;
	public static var beatLibitina:Null<Bool> = false;
	public static var unlockHFCostume:Null<Bool> = false;
	public static var unlockAntipathyCostume:Null<Bool> = false;
	public static var unlockSoftCostume:Null<Bool> = false;
	public static var unlockMrCowCostume:Null<Bool> = false;
	public static var yamMonika:Null<Bool> = false;
	public static var yamSayori:Null<Bool> = false;
	public static var yamNatsuki:Null<Bool> = false;
	public static var yamYuri:Null<Bool> = false;
	public static var yamLoss:Null<Bool> = false;
	public static var sideStatus:Array<String> = [];

	// Popups
	public static var popupPrologue:Null<Bool> = false;
	public static var popupSayori:Null<Bool> = false;
	public static var popupNatsuki:Null<Bool> = false;
	public static var popupYuri:Null<Bool> = false;
	public static var popupMonika:Null<Bool> = false;
	public static var popupFestival:Null<Bool> = false;
	public static var popupEncore:Null<Bool> = false;
	public static var popupProtag:Null<Bool> = false;
	public static var popupSide:Null<Bool> = false;
	public static var popupEpiphany:Null<Bool> = false;
	public static var popupLibitina:Null<Bool> = false;

	// Controls
	public static var upBind:String = 'W';
	public static var downBind:String = 'S';
	public static var leftBind:String = 'A';
	public static var rightBind:String = 'D';
	public static var killBind:String = 'R';

	// Game Jolt
	public static var gjUser:Dynamic = null;
	public static var gjToken:Dynamic = null;

	private static var importantMap:Map<String, Array<String>> =
	[
		"flixelSound" => ["volume"]
	];

	/** Quick Function to Fix Save Files for Flixel 5
		@BeastlyGabi
	**/
	inline public static function getSavePath(folder:String = 'TeamTBD'):String
	{
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}

	public static function init()
	{
		FlxG.save.bind('DokiTakeover', getSavePath());

		// https://github.com/ShadowMario/FNF-PsychEngine/pull/11633
		for (field in Type.getClassFields(SaveData))
		{
			if (Type.typeof(Reflect.field(SaveData, field)) != TFunction)
			{
				if (!importantMap.get("flixelSound").contains(field))
				{
					var defaultValue:Dynamic = Reflect.field(SaveData, field);
					var flxProp:Dynamic = Reflect.field(FlxG.save.data, field);
					Reflect.setField(SaveData, field, (flxProp != null ? flxProp : defaultValue));
				}
			}
		}

		for (flixelS in importantMap.get("flixelSound"))
		{
			var flxProp:Dynamic = Reflect.field(FlxG.save.data, flixelS);

			if (flxProp != null)
				Reflect.setField(FlxG.sound, flixelS, flxProp);
		}

		Ratings.timingWindows = [shitMs, badMs, goodMs, sickMs];
		Conductor.safeZoneOffset = Ratings.timingWindows[0];

		Highscore.load();
		PlayerSettings.init();
	}

	public static function save()
	{
		// ensure that we're saving (hopefully)
		if (FlxG.save.data == null)
			FlxG.save.bind('DokiTakeover', getSavePath());

		for (field in Type.getClassFields(SaveData))
		{
			if (Type.typeof(Reflect.field(SaveData, field)) != TFunction)
				Reflect.setField(FlxG.save.data, field, Reflect.field(SaveData, field));
		}

		for (flixel in importantMap.get("flixelSound"))
			Reflect.setField(FlxG.save.data, flixel, Reflect.field(FlxG.sound, flixel));

		FlxG.save.flush();
	}

	public static function unlockAll(unlock:Bool = true)
	{
		// story mode
		beatPrologue = unlock;
		beatSayori = unlock;
		beatNatsuki = unlock;
		beatYuri = unlock;
		beatMonika = unlock;
		beatFestival = unlock;
		beatEncore = unlock;
		beatProtag = unlock;
		beatSide = unlock;
		unlockedEpiphany = unlock;
		sideStatus = unlock ? ['love n funkin', 'constricted', 'catfight', 'wilted'] : [];
		weekUnlocked = unlock ? 10 : 1;

		// popups
		popupPrologue = unlock;
		popupSayori = unlock;
		popupNatsuki = unlock;
		popupYuri = unlock;
		popupMonika = unlock;
		popupFestival = unlock;
		popupEncore = unlock;
		popupProtag = unlock;
		popupSide = unlock;
		popupEpiphany = unlock;
		popupLibitina = unlock;

		// extra
		beatEpiphany = unlock;
		beatCatfight = unlock;
		beatVA11HallA = unlock;
		beatLibitina = unlock;

		save();
	}

	public static function setSongOffset(song:String, offset:Float):Void
	{
		songOffsets.set(song, offset);
		save();
	}

	public static function getSongOffset(song:String):Float
	{
		if (!songOffsets.exists(song))
			setSongOffset(song, 0);

		return songOffsets.get(song);
	}

	public static function checkAllSongsBeaten(checkLibitina:Bool = false):Bool
	{
		for (i in 0...5)
		{
			var freeplayList = CoolUtil.coolTextFile(Paths.txt('data/freeplay/Page${i + 1}'));

			for (i in 0...freeplayList.length)
			{
				var song:Array<String> = freeplayList[i].split(':');

				if (song[0].toLowerCase() == 'erb') // please don't lock yourself out of libbie
					continue;

				if (song[0].toLowerCase() == 'epiphany') // by request
					continue;

				if (!checkLibitina && song[0].toLowerCase() == 'libitina')
					continue;

				if (Highscore.getScore(song[0], 1) < 1 && Highscore.getMirrorScore(song[0], 1) < 1)
					return false;
			}
		}

		return true;
	}
}
