package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import openfl.events.AsyncErrorEvent;
import openfl.events.Event;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
import openfl.net.NetConnection;
import openfl.net.NetStream;

class NetStreamHandler
{
	var video:Video;
	var netStream:NetStream;
	var pauseMusic:Bool;

	public var finishCallback:Void->Void;
	public var stateCallback:FlxState;

	public var canSkip:Bool = true;
	public var skipKeys:Array<FlxKey> = [FlxKey.SPACE];

	public function new()
	{
		// https://www.youtube.com/watch?v=0MW9Nrg_kZU hueh
	}

	public function playVideo(path:String, ?repeat:Bool = false, pauseMusic:Bool = false)
	{
		this.pauseMusic = pauseMusic;

		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.pause();

		video = new Video();

		if (FlxG.stage.stageHeight / 9 < FlxG.stage.stageWidth / 16)
		{
			video.width = FlxG.stage.stageHeight * (16 / 9);
			video.height = FlxG.stage.stageHeight;
		}
		else
		{
			video.width = FlxG.stage.stageWidth;
			video.height = FlxG.stage.stageWidth / (16 / 9);
		}

		FlxG.addChildBelowMouse(video);

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		var netConnection = new NetConnection();
		netConnection.connect(null);

		netStream = new NetStream(netConnection);
		netStream.client = {onMetaData: client_onMetaData};
		netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netStream_onAsyncError);
		netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnection_onNetStatus);
		netStream.play(path);
	}

	function finishVideo()
	{
		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.resume();

		canSkip = true;

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (finishCallback != null)
				finishCallback();
			else if (stateCallback != null)
				LoadingState.loadAndSwitchState(stateCallback);

			netStream.dispose();

			if (FlxG.game.contains(video))
				FlxG.game.removeChild(video);
		});
	}

	var acceptInput:Bool = false;

	function update(e:Event)
	{
		// any better method of doing this? lol
		new FlxTimer().start(0.01, function(tmr:FlxTimer)
		{
			acceptInput = true;
		});

		if (FlxG.keys.anyJustPressed(skipKeys) && canSkip && acceptInput)
		{
			if (FlxG.game.contains(video))
				finishVideo();
		}
	}

	private function client_onMetaData(metaData:Dynamic)
	{
		video.attachNetStream(netStream);

		// video.width = video.videoWidth;
		// video.height = video.videoHeight;
	}

	private function netStream_onAsyncError(event:AsyncErrorEvent):Void
	{
		Debug.logWarn("Error loading video, skipping");

		if (finishCallback != null)
			finishCallback();
		else if (stateCallback != null)
			LoadingState.loadAndSwitchState(stateCallback);
	}

	private function netConnection_onNetStatus(event:NetStatusEvent):Void
	{
		trace(event.toString());

		if (event.info.code == 'NetStream.Play.Complete')
			finishVideo();
	}
}
