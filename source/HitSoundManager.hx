package;

import flixel.FlxG;
import flixel.sound.FlxSound;

class HitSoundManager
{
	public static var noteHit:Bool = false;

	public static var snap:FlxSound;
	public static var perfect:FlxSound;
	public static var great:FlxSound;
	public static var good:FlxSound;
	public static var tap:FlxSound;

	public static function init():Void
	{
		CoolUtil.precacheSound('hitsound/snap');
		CoolUtil.precacheSound('hitsound/perfect');
		CoolUtil.precacheSound('hitsound/great');
		CoolUtil.precacheSound('hitsound/good');
		CoolUtil.precacheSound('hitsound/tap');

		snap = null;
		perfect = null;
		great = null;
		good = null;
		tap = null;

		snap = new FlxSound().loadEmbedded(Paths.sound('hitsound/snap'));
		snap.volume = SaveData.hitSoundVolume;

		perfect = new FlxSound().loadEmbedded(Paths.sound('hitsound/perfect'));
		perfect.volume = SaveData.hitSoundVolume;
		perfect.onComplete = function():Void
		{
			noteHit = false;
		};

		great = new FlxSound().loadEmbedded(Paths.sound('hitsound/great'));
		great.volume = SaveData.hitSoundVolume;
		great.onComplete = function():Void
		{
			noteHit = false;
		};

		good = new FlxSound().loadEmbedded(Paths.sound('hitsound/good'));
		good.volume = SaveData.hitSoundVolume;
		good.onComplete = function():Void
		{
			noteHit = false;
		};

		tap = new FlxSound().loadEmbedded(Paths.sound('hitsound/tap'));
		tap.volume = SaveData.hitSoundVolume;

		FlxG.sound.list.add(snap);
		FlxG.sound.list.add(perfect);
		FlxG.sound.list.add(great);
		FlxG.sound.list.add(good);
		FlxG.sound.list.add(tap);
	}

	public static function play(rating:String = 'ghost'):Void
	{
		var sfx:FlxSound;

		if (SaveData.judgeHitSound)
		{
			noteHit = true;

			switch (rating)
			{
				case 'sick':
					sfx = perfect;
				case 'good':
					sfx = great;
				case 'bad':
					sfx = good;
				default:
					sfx = tap;
					noteHit = false;
			}
		}
		else
			sfx = snap;

		if (sfx.playing) sfx.stop();
		sfx.play();
	}
}
