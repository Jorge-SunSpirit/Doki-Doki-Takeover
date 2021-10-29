package;

import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import Controls.KeyboardScheme;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;
import flixel.addons.transition.FlxTransitionableState;

class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();

	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";

	public final function getName()
	{
		return _name;
	}

	public function new(catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}

	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;

	public final function getDisplay():String
	{
		return display;
	}

	public final function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getDescription():String
	{
		return description;
	}

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return throw "stub!";
	}

	private function updateDisplay():String
	{
		return throw "stub!";
	}

	public function getValue():String
	{
		return throw "stub!";
	}

	public function left():Bool
	{
		return throw "stub!";
	}

	public function right():Bool
	{
		return throw "stub!";
	}
}

class KeyBindingsOption extends Option
{
	private var controls:Controls;

	public function new(desc:String, controls:Controls)
	{
		super();
		description = desc;
		this.controls = controls;
	}

	public override function press():Bool
	{
		OptionsMenu.instance.openSubState(new KeyBindMenu());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optKeyBindings');
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.downscroll ? LangUtil.getString('optDownscroll') : LangUtil.getString('optUpscroll');
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.ghost ? LangUtil.getString('optGhostTap') : LangUtil.getString('optNoGhostTap');
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('cmnAccuracy') + ' ' + (FlxG.save.data.accuracyDisplay ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optPosition') + ' ' + (FlxG.save.data.songPosition ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.distractions = !FlxG.save.data.distractions;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optDistract') + ' ' + (FlxG.save.data.distractions ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class ResetButtonOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optReset') + ' ' + (FlxG.save.data.resetButton ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optFlashing') + ' ' + (FlxG.save.data.flashing ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class Judgement extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optJudgement');
	}

	override function getValue():String
	{
		return LangUtil.getString('descCurJudgement')
			+ ': '
			+ Conductor.safeFrames
			+ " - SIK: "
			+ HelperFunctions.truncateFloat(45 * Conductor.timeScale, 0)
			+ "ms GD: "
			+ HelperFunctions.truncateFloat(90 * Conductor.timeScale, 0)
			+ "ms BD: "
			+ HelperFunctions.truncateFloat(135 * Conductor.timeScale, 0)
			+ "ms NO: "
			+ HelperFunctions.truncateFloat(155 * Conductor.timeScale, 0)
			+ "ms TOTAL: "
			+ HelperFunctions.truncateFloat(Conductor.safeZoneOffset, 0)
			+ "ms";
	}

	override function left():Bool
	{
		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}

	override function right():Bool
	{
		if (Conductor.safeFrames == 20)
			return false;

		Conductor.safeFrames += 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast(Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return return LangUtil.getString('optFPSCount') + ' ' + (FlxG.save.data.fps ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optFPSCap');
	}

	override function getValue():String
	{
		return LangUtil.getString('descCurFPSCap')
			+ ': '
			+ FlxG.save.data.fpsCap
			+ (FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? 'Hz (' + LangUtil.getString('descRefreshRate') + ')' : "");
	}

	override function right():Bool
	{
		if (FlxG.save.data.fpsCap >= 290)
		{
			FlxG.save.data.fpsCap = 290;
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function left():Bool
	{
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
				(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}
}

class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optScroll');
	}

	override function getValue():String
	{
		return LangUtil.getString('descCurScroll') + ': ' + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed, 1);
	}

	override function right():Bool
	{
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 10)
			FlxG.save.data.scrollSpeed = 10;
		return true;
	}

	override function left():Bool
	{
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 10)
			FlxG.save.data.scrollSpeed = 10;
		return true;
	}
}

class RainbowFPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.fpsRain = !FlxG.save.data.fpsRain;
		(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.WHITE);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optFPSRainbow') + ' ' + (FlxG.save.data.fpsRain ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class NPSDisplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.npsDisplay = !FlxG.save.data.npsDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optNPS') + ' ' + (FlxG.save.data.npsDisplay ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

#if FEATURE_FILESYSTEM
class ReplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new LoadReplayState());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optReplay');
	}
}
#end

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optAccuracyMode')
			+ ' '
			+ (FlxG.save.data.accuracyMod == 0 ? LangUtil.getString('optAMAccurate') : LangUtil.getString('optAMComplex'));
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optCustomize');
	}
}

class WatermarkOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		Main.watermarks = !Main.watermarks;
		FlxG.save.data.watermark = Main.watermarks;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optWatermark') + ' ' + (Main.watermarks ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return LangUtil.getString('cmnBotplay') + ' ' + (FlxG.save.data.botplay ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
}

class GFCountdownOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.gfCountdown = !FlxG.save.data.gfCountdown;
		trace('Girlfriend Countdown: ' + FlxG.save.data.gfCountdown);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return LangUtil.getString('optGFCountdown') + ' ' + (FlxG.save.data.gfCountdown ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
}

#if FEATURE_CACHING
class CharacterCaching extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cacheCharacters = !FlxG.save.data.cacheCharacters;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optCharacterCache') + ' ' + (FlxG.save.data.cacheCharacters ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class SongCaching extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cacheSongs = !FlxG.save.data.cacheSongs;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optSongCache') + ' ' + (FlxG.save.data.cacheSongs ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class MusicCaching extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cacheMusic = !FlxG.save.data.cacheMusic;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optMusicCache') + ' ' + (FlxG.save.data.cacheMusic ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class SoundCaching extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.cacheSounds = !FlxG.save.data.cacheSounds;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optSoundCache') + ' ' + (FlxG.save.data.cacheSounds ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}

class CachingState extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new Caching());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optCaching');
	}
}
#end

class MiddleScrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.middleScroll = !FlxG.save.data.middleScroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.middleScroll ? LangUtil.getString('optMiddleScrollOn') : LangUtil.getString('optMiddleScrollOff'));
	}
}

class LaneUnderlayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		FlxG.save.data.laneUnderlay = !FlxG.save.data.laneUnderlay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return (FlxG.save.data.laneUnderlay ? LangUtil.getString('optLaneUnderwayOn') : LangUtil.getString('optLaneUnderwayOff'));
	}

	override function right():Bool
	{
		FlxG.save.data.laneTransparency += 0.1;

		if (FlxG.save.data.laneTransparency < 0)
			FlxG.save.data.laneTransparency = 0;

		if (FlxG.save.data.laneTransparency > 1)
			FlxG.save.data.laneTransparency = 1;
		return true;
	}

	override function getValue():String
	{
		return LangUtil.getString('descLaneUnderwayControl') + ': ' + HelperFunctions.truncateFloat(FlxG.save.data.laneTransparency, 1);
	}

	override function left():Bool
	{
		FlxG.save.data.laneTransparency -= 0.1;

		if (FlxG.save.data.laneTransparency < 0)
			FlxG.save.data.laneTransparency = 0;

		if (FlxG.save.data.laneTransparency > 1)
			FlxG.save.data.laneTransparency = 1;

		return true;
	}
}

class ResetSave extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}

		FlxG.save.data.language = null;
		FlxG.save.data.weekUnlocked = null;
		FlxG.save.data.newInput = null;
		FlxG.save.data.downscroll = null;
		FlxG.save.data.dfjk = null;
		FlxG.save.data.accuracyDisplay = null;
		FlxG.save.data.offset = null;
		FlxG.save.data.songPosition = null;
		FlxG.save.data.fps = null;
		FlxG.save.data.changedHit = null;
		FlxG.save.data.fpsRain = null;
		FlxG.save.data.fpsCap = null;
		FlxG.save.data.scrollSpeed = null;
		FlxG.save.data.npsDisplay = null;
		FlxG.save.data.frames = null;
		FlxG.save.data.accuracyMod = null;
		FlxG.save.data.watermark = null;
		FlxG.save.data.ghost = null;
		FlxG.save.data.distractions = null;
		FlxG.save.data.flashing = null;
		FlxG.save.data.resetButton = null;
		FlxG.save.data.botplay = null;
		FlxG.save.data.gfCountdown = null;
		FlxG.save.data.zoom = null;
		FlxG.save.data.cacheCharacters = null;
		FlxG.save.data.cacheSongs = null;
		FlxG.save.data.cacheMusic = null;
		FlxG.save.data.cacheSounds = null;
		FlxG.save.data.middleScroll = null;
		FlxG.save.data.laneUnderlay = null;
		FlxG.save.data.laneTransparency = null;
		FlxG.save.data.monibeaten = null;
		FlxG.save.data.sayobeaten = null;
		FlxG.save.data.natbeaten = null;
		FlxG.save.data.yuribeaten = null;
		FlxG.save.data.extrabeaten = null;
		FlxG.save.data.extra2beaten = null;
		FlxG.save.data.gfCountdown = null;
		FlxG.save.data.unlockepip = null;
		FlxG.save.data.monipopup = null;
		FlxG.save.data.sayopopup = null;
		FlxG.save.data.natpopup = null;
		FlxG.save.data.yuripopup = null;
		FlxG.save.data.extra1popup = null;
		FlxG.save.data.extra2popup = null;
		FlxG.save.data.funnyquestionpopup = null;
		FlxG.save.data.upBind = null;
		FlxG.save.data.downBind = null;
		FlxG.save.data.leftBind = null;
		FlxG.save.data.rightBind = null;
		FlxG.save.data.gpupBind = null;
		FlxG.save.data.gpdownBind = null;
		FlxG.save.data.gpleftBind = null;
		FlxG.save.data.gprightBind = null;
		FlxG.save.data.songScores = null;
		for (key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}

		FlxG.save.flush();

		#if FEATURE_FILESYSTEM
		Sys.exit(0);
		#else
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		FlxTransitionableState.skipNextTransOut = true;
		FlxTransitionableState.skipNextTransIn = true;
		FlxG.switchState(new CrashState());
		#end

		confirm = false;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? LangUtil.getString('optSaveResetConfirm') : LangUtil.getString('optSaveReset');
	}
}

#if FEATURE_OBS
class SelfAwareness extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.selfAware = !FlxG.save.data.selfAware;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optSelfAware') + ' ' + (FlxG.save.data.selfAware ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff'));
	}
}
#end

#if FEATURE_GAMEJOLT
class GameJolt extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new GameJolt.GameJoltLogin());
		return false;
	}

	private override function updateDisplay():String
	{
		return LangUtil.getString('optGameJolt');
	}
}
#end
