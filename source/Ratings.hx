import flixel.FlxG;
import flixel.math.FlxMath;

class Ratings
{
	public static function GenerateLetterRank(accuracy:Float) // used for Highscore and Discord Rich Presence
	{
		var ranking:String = "N/A";

		if (PlayState.breaks == 0 && PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0)
			ranking = "(SFC)"; // Sick Full Combo
		else if (PlayState.breaks == 0 && PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1)
			ranking = "(GFC)"; // Good Full Combo
		else if (PlayState.breaks == 0 && PlayState.misses == 0)
			ranking = "(FC)"; // Full Combo
		else if (PlayState.breaks < 10)
			ranking = "(SDCB)"; // Single Digit Combo Break
		else
			ranking = "(" + LangUtil.getString('cmnClear') + ")"; // Clear

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		if (accuracy == 0)
			ranking = "N/A";

		return ranking;
	}

	public static function GenerateVisualLetterRank(accuracy:Float) // used for scoreTxt in PlayState
	{
		var ranking:String = "?";

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						ranking = "AAAAA";
					case 1:
						ranking = "AAAA:";
					case 2:
						ranking = "AAAA.";
					case 3:
						ranking = "AAAA";
					case 4:
						ranking = "AAA:";
					case 5:
						ranking = "AAA.";
					case 6:
						ranking = "AAA";
					case 7:
						ranking = "AA:";
					case 8:
						ranking = "AA.";
					case 9:
						ranking = "AA";
					case 10:
						ranking = "A:";
					case 11:
						ranking = "A.";
					case 12:
						ranking = "A";
					case 13:
						ranking = "B";
					case 14:
						ranking = "C";
					case 15:
						ranking = "D";
				}
				break;
			}
		}

		ranking += " (" + FlxMath.roundDecimal(accuracy, 2) + "%) - ";

		if (PlayState.breaks == 0 && PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0)
			ranking += "SFC";
		else if (PlayState.breaks == 0 && PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1)
			ranking += "GFC";
		else if (PlayState.breaks == 0 && PlayState.misses == 0)
			ranking += "FC";
		else if (PlayState.breaks < 10)
			ranking += "SDCB";
		else
			ranking += LangUtil.getString('cmnClear');

		if (accuracy == 0)
			ranking = "?";

		return ranking;
	}

	public static var timingWindows = [];

	public static function judgeNote(noteDiff:Float)
	{
		var diff = Math.abs(noteDiff);

		for (index in 0...timingWindows.length)
		{
			var time = timingWindows[index];
			var nextTime = index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1];
			if (diff < time && diff >= nextTime)
			{
				switch (index)
				{
					case 0: // shit
						return "shit";
					case 1: // bad
						return "bad";
					case 2: // good
						return "good";
					case 3: // sick
						return "sick";
				}
			}
		}

		return "good"; // fallback on good rating
	}

	// copied from above lol
	public static function noteAccuracy(noteDiff:Float)
	{
		var diff = Math.abs(noteDiff);

		for (index in 0...timingWindows.length)
		{
			var time = timingWindows[index];
			var nextTime = index + 1 > timingWindows.length - 1 ? 0 : timingWindows[index + 1];
			if (diff < time && diff >= nextTime)
			{
				switch (index)
				{
					case 0: // shit
						return 0.4;
					case 1: // bad
						return 0.7;
					case 2: // good
						return 0.9;
					case 3: // sick
						return 1;
				}
			}
		}

		return 0.9;
	}

	public static function CalculateRanking(score:Int, nps:Int, maxNPS:Int, accuracy:Float):String
	{
		return (SaveData.npsDisplay ? // NPS Toggle
			LangUtil.getString('cmnNPS')
			+ ": "
			+ nps
			+ " ("
			+ LangUtil.getString('cmnMax')
			+ " "
			+ maxNPS
			+ ")"
			+ " | " : "")
			+ // 	NPS
			LangUtil.getString('cmnScore')
			+ ": "
			+ score
			+ // Score
			(SaveData.accuracyDisplay ? // Accuracy Toggle
				" | "
				+ LangUtil.getString('cmnBreaks')
				+ ": "
				+ PlayState.breaks
				+ // 	Misses/Combo Breaks
				" | "
				+ LangUtil.getString('cmnRating')
				+ ": "
				+ GenerateVisualLetterRank(accuracy) : ""); // Letter Rank
	}
}