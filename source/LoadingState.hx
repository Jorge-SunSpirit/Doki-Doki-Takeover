package;

import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import haxe.io.Path;
#if NO_PRELOAD_ALL
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import shaders.ColorMaskShader;
#end

using StringTools;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	var target:FlxState;
	var stopMusic = false;
	var callbacks:MultiCallback;

	#if NO_PRELOAD_ALL
	var targetShit:Float;
	var backdrop:FlxBackdrop;
	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft = false;

	var loadBar:FlxBar;

	var artwork:FlxSprite;
	var authorText:FlxText;

	var galleryData:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/galleryData'));

	var artworkData:Array<String> = [];
	var authorData:Array<String> = [];
	#end

	function new(target:FlxState, stopMusic:Bool)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
	}

	override function create()
	{
		#if NO_PRELOAD_ALL
		persistentUpdate = persistentDraw = true;

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
		add(backdrop);

		if (!SaveData.beatFestival || PlayState.isStoryMode)
		{
			logo = new FlxSprite(0, 0);
			logo.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
			logo.antialiasing = SaveData.globalAntialiasing;
			logo.setGraphicSize(Std.int(logo.width * 0.8));
			logo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logo.updateHitbox();
	
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
			gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
			gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
			gfDance.antialiasing = SaveData.globalAntialiasing;
			add(gfDance);
			add(logo);
	
			if (PlayState.SONG.song.toLowerCase() == 'your demise' && PlayState.isStoryMode)
				gfDance.visible = false;
		}
		else
		{
			for (i in 0...galleryData.length)
			{
				if (galleryData[i].startsWith('//'))
					continue;

				var data:Array<String> = galleryData[i].split('::');

				artworkData.push(data[0]);
				authorData.push(data[1].replace("\\n", "\n"));
			}

			var randomArtwork:Int = Random.randUInt(0, galleryData.length);

			artwork = new FlxSprite(0, 0).loadGraphic(Paths.image('gallery/${artworkData[randomArtwork]}'));
			artwork.antialiasing = SaveData.globalAntialiasing;
			artwork.setGraphicSize(0, Std.int(FlxG.height * 0.8));
			artwork.updateHitbox();

			if (artwork.width > FlxG.width)
				artwork.setGraphicSize(Std.int(FlxG.width * 0.9));

			artwork.updateHitbox();
			artwork.screenCenter();
			artwork.y -= 50;
			add(artwork);

			authorText = new FlxText(0, 0, 0, '${authorData[randomArtwork]}\n', 8);
			authorText.setFormat(LangUtil.getFont('aller'), 29, 0xFF000000, CENTER);
			authorText.y += LangUtil.getFontOffset('aller');
			authorText.antialiasing = SaveData.globalAntialiasing;
			authorText.screenCenter();
			authorText.y = artwork.y + artwork.height + 15;
			add(authorText);
		}

		loadBar = new FlxBar(0, FlxG.height - 20);
		loadBar.makeGraphic(FlxG.width, 10, 0xFFF03CA2);
		loadBar.screenCenter(X);
		add(loadBar);
		#end

		initSongsManifest().onComplete(function(lib)
		{
			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");
			checkLoadSong(getSongPath());
			if (PlayState.SONG.needsVoices)
				checkLoadSong(getVocalPath());
			checkLibrary("shared");
			checkLibrary("week6");
			checkLibrary("monika");
			checkLibrary("doki");

			FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);
			new FlxTimer().start(1.5, function(_) introComplete());
		});
	}

	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			var library = Assets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			// @:privateAccess
			// library.types.set(symbolPath, SOUND);
			// @:privateAccess
			// library.pathGroups.set(symbolPath, [library.__cacheBreak(symbolPath)]);
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function(_)
			{
				callback();
			});
		}
	}

	function checkLibrary(library:String)
	{
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function(_)
			{
				callback();
			});
		}
	}

	override function beatHit()
	{
		super.beatHit();

		#if NO_PRELOAD_ALL
		if (!SaveData.beatFestival || PlayState.isStoryMode)
		{
			logo.animation.play('bump');

			danceLeft = !danceLeft;
	
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if NO_PRELOAD_ALL
		if (callbacks != null)
		{
			targetShit = FlxMath.remapToRange(callbacks.numRemaining / callbacks.length, 1, 0, 0, 1);
			loadBar.scale.x += 0.5 * (targetShit - loadBar.scale.x);
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		#end
	}

	function onLoad()
	{
		#if NO_PRELOAD_ALL
		loadBar.scale.x = 1;
		#end

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		MusicBeatState.switchState(target);
	}

	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}

	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}

	inline static public function loadAndSwitchState(target:FlxState, isPlayState = true, stopMusic = false)
	{
		MusicBeatState.switchState(getNextState(target, isPlayState, stopMusic));
	}

	static function getNextState(target:FlxState, isPlayState = true, stopMusic = false):FlxState
	{
		if (isPlayState)
		{
			Paths.setCurrentLevel("week6");
			#if NO_PRELOAD_ALL
			var loaded = isSoundLoaded(getSongPath())
				&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()))
				&& isLibraryLoaded("shared");

			if (!loaded)
				return new LoadingState(target, stopMusic);
			#end
		}

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		return target;
	}

	#if NO_PRELOAD_ALL
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}

	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	#end

	override function destroy()
	{
		super.destroy();

		callbacks = null;
	}

	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
				promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;

	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();

	public function new(callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}

	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;

				if (logId != null)
					log('fired $id, $numRemaining remaining');

				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}

	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}

	public function getFired()
		return fired.copy();

	public function getUnfired()
		return [for (id in unfired.keys()) id];
}
