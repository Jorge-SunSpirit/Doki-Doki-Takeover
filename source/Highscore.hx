package;

using StringTools;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();
	public static var songAccuracies:Map<String, Float> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songCombos:Map<String, String> = new Map<String, String>();
	public static var songAccuracies:Map<String, Float> = new Map<String, Float>();
	#end

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = PlayState.mirrormode ? formatSongSave(song, diff) : formatSong(song, diff);

		if (!PlayState.toggleBotplay && !PlayState.practiceModeToggled && !SaveData.randomMode)
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score)
					setScore(daSong, score);
			}
			else
				setScore(daSong, score);
		}
		else
			trace('Botplay/Practice or Random Mode detected, score saving is disabled.');
	}

	public static function saveCombo(song:String, combo:String, ?diff:Int = 0):Void
	{
		var daSong:String = PlayState.mirrormode ? formatSongSave(song, diff) : formatSong(song, diff);
		var finalCombo:String = combo.split(')')[0].replace('(', '');

		if (!PlayState.toggleBotplay && !PlayState.practiceModeToggled && !SaveData.randomMode)
		{
			if (songCombos.exists(daSong))
			{
				if (getComboInt(songCombos.get(daSong)) < getComboInt(finalCombo))
					setCombo(daSong, finalCombo);
			}
			else
				setCombo(daSong, finalCombo);
		}
	}

	public static function saveAccuracy(song:String, accuracy:Float = 0, ?diff:Int = 0):Void
	{
		var daSong:String = PlayState.mirrormode ? formatSongSave(song, diff) : formatSong(song, diff);

		if (!PlayState.toggleBotplay && !PlayState.practiceModeToggled && !SaveData.randomMode)
		{
			if (songAccuracies.exists(daSong))
			{
				if (songAccuracies.get(daSong) < accuracy)
					setAccuracy(daSong, accuracy);
			}
			else
				setAccuracy(daSong, accuracy);
		}
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		if (!SaveData.botplay && !PlayState.practiceModeToggled && !SaveData.randomMode)
		{
			var daWeek:String = formatSong('week' + week, diff);

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSongSave() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		SaveData.songScores = songScores;
		SaveData.save();
	}

	static function setCombo(song:String, combo:String):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songCombos.set(song, combo);
		SaveData.songCombos = songCombos;
		SaveData.save();
	}

	static function setAccuracy(song:String, accuracy:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songAccuracies.set(song, accuracy);
		SaveData.songAccuracies = songAccuracies;
		SaveData.save();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song.toLowerCase();

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';

		return daSong;
	}

	public static function formatSongSave(song:String, diff:Int):String
	{
		var daSong:String = song.toLowerCase();

		if (diff == 0)
			daSong += '-easy';
		else if (diff == 2)
			daSong += '-hard';

		if (PlayState.mirrormode)
			daSong += '-mirror';

		return daSong;
	}

	static function getComboInt(combo:String):Int
	{
		switch (combo)
		{
			case 'SDCB':
				return 1;
			case 'FC':
				return 2;
			case 'GFC':
				return 3;
			case 'SFC':
				return 4;
			default:
				return 0;
		}
	}

	public static function getScore(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSongSave(song, diff)))
			setScore(formatSongSave(song, diff), 0);

		return songScores.get(formatSongSave(song, diff));
	}

	public static function getScoreBase(song:String, diff:Int):Int
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getMirrorScore(song:String, diff:Int):Int
	{
		diff = 1;

		if (!songScores.exists(formatSong(song, diff) + '-mirror'))
			setScore(formatSong(song, diff) + '-mirror', 0);

		return songScores.get(formatSong(song, diff) + '-mirror');
	}

	public static function getCombo(song:String, diff:Int):String
	{
		if (!songCombos.exists(formatSongSave(song, diff)))
			setCombo(formatSongSave(song, diff), '');

		return songCombos.get(formatSongSave(song, diff));
	}

	public static function getAccuracy(song:String, diff:Int):Float
	{
		if (!songAccuracies.exists(formatSongSave(song, diff)))
			setAccuracy(formatSongSave(song, diff), 0);

		return songAccuracies.get(formatSongSave(song, diff));
	}

	// These unlock functions will only check for regular mode to prevent dumb issues
	public static function getAccuracyUnlock(song:String, diff:Int):Float
	{
		diff = 1;

		if (!songAccuracies.exists(formatSong(song, diff)))
			setAccuracy(formatSong(song, diff), 0);

		return songAccuracies.get(formatSong(song, diff));
	}

	public static function getComboUnlock(song:String, diff:Int, ifFC:Bool = true):Bool
	{
		if (!songCombos.exists(formatSongSave(song, diff)))
			setCombo(formatSongSave(song, diff), '');

		if (ifFC)
			return songCombos.get(formatSong(song, diff)).contains('FC');
		else
			return (songCombos.get(formatSong(song, diff)) != '' && songCombos.get(formatSong(song, diff)) != 'N/A');
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		if (!songScores.exists(formatSongSave('week' + week, diff)))
			setScore(formatSongSave('week' + week, diff), 0);

		return songScores.get(formatSongSave('week' + week, diff));
	}

	public static function load():Void
	{
		if (SaveData.songScores != null)
			songScores = SaveData.songScores;

		if (SaveData.songCombos != null)
			songCombos = SaveData.songCombos;

		if (SaveData.songAccuracies != null)
			songAccuracies = SaveData.songAccuracies;
	}
}
