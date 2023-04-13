package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
#if FEATURE_DISCORD
import Discord.DiscordClient;
import lime.app.Application;
#end
#if FEATURE_GAMEJOLT
import GameJolt.GameJoltAPI;
#end

class Init extends MusicBeatState
{
	var preloadMusic:Array<String> = [
		'freakyMenu',
		'disco',
		'monic',
		'natsc',
		'pixelc',
		'protagc',
		'sayoc',
		'yuric'
	];

	override function create()
	{
		SaveData.init();
		CoolUtil.setFPSCap(SaveData.framerate);
		KeyBinds.gamepad = FlxG.gamepads.lastActive != null;

		if (Main.fpsVar == null)
		{
			Main.tongue = new FireTongueEx();
			Main.tongue.initialize({locale: SaveData.language});
		}

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;

		FlxG.mouse.useSystemCursor = !SaveData.customCursor;

		if (Main.fpsVar != null)
			Main.fpsVar.visible = SaveData.showFPS;

		FlxTransitionableState.skipNextTransOut = true;

		for (music in preloadMusic)
			CoolUtil.precacheMusic(music);

		// Start random seed based off current time.
		Random.resetSeed();

		#if FEATURE_DISCORD
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		#if FEATURE_GAMEJOLT
		GameJoltAPI.connect();
		GameJoltAPI.authDaUser(SaveData.gjUser, SaveData.gjToken);
		#end

		#if FREEPLAY
		MusicBeatState.switchState(new DokiFreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if (!SaveData.saveStarted)
			MusicBeatState.switchState(new FirstBootState());
		else
		{
			FlxTransitionableState.skipNextTransIn = true;

			if (SaveData.cacheSong)
				MusicBeatState.switchState(new CachingState());
			else
				MusicBeatState.switchState(new TitleState());
		}
		#end
	}
}
