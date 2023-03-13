package;

import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = "ogg";

	public static var dumpExclusions:Array<String> = [
		'assets/images/Credits_LeftSide.png',
		'assets/images/cursor.png',
		'assets/images/DDLCStart_Screen_Assets.png',
		'assets/images/scrollingBG.png',
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/music/disco.$SOUND_EXT'
	];

	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				// get rid of it
				var obj = currentTrackedAssets.get(key);

				@:privateAccess
				if (obj != null)
				{
					if (currentTrackedTextures.exists(key))
					{
						var texture = currentTrackedTextures.get(key);
						texture.dispose();
						texture = null;
						currentTrackedTextures.remove(key);
					}

					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}

		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	public static function clearStoredMemory()
	{
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);

			if (obj != null && !currentTrackedAssets.exists(key) && !dumpExclusions.contains(key))
			{
				if (currentTrackedTextures.exists(key))
				{
					var texture = currentTrackedTextures.get(key);
					texture.dispose();
					texture = null;
					currentTrackedTextures.remove(key);
				}

				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
				currentTrackedAssets.remove(key);
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				// trace('test: ' + dumpExclusions, key);
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}

		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		openfl.Assets.cache.clear("songs");
	}

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		var returnPath = '$library:assets/$library/$file';
		return returnPath;
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vs', TEXT, library);
	}

	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.fs', TEXT, library);
	}

	inline static public function video(key:String, ?library:String)
	{
		return getPath('videos/$key.mp4', BINARY, library);
	}

	static public function sound(key:String, ?library:String):Dynamic
	{
		#if html5
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
		#else
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
		#end
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Dynamic
	{
		#if html5
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
		#else
		var file:Sound = returnSound('music', key, library);
		return file;
		#end
	}

	inline static public function voices(song:String, ?prefix:String = '', ?suffix:String = ''):Any
	{
		#if html5
		return 'songs:assets/songs/${song.toLowerCase()}/${prefix}Voices${suffix}.$SOUND_EXT';
		#else
		var songKey:String = '${song.toLowerCase()}/${prefix}Voices${suffix}';
		var voices = returnSound('songs', songKey);
		return voices;
		#end
	}

	inline static public function inst(song:String):Any
	{
		#if html5
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		#else
		var songKey:String = '${song.toLowerCase()}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
		#end
	}

	inline static public function image(key:String, ?library:String):FlxGraphic
	{
		var returnAsset:FlxGraphic = returnGraphic(key, library);
		return returnAsset;
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?library:String)
	{
		if (OpenFlAssets.exists(Paths.getPath(key, type, library)))
			return true;

		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		var imageLoaded:FlxGraphic = returnGraphic(key);

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		var imageLoaded:FlxGraphic = returnGraphic(key);

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), file('images/$key.txt', library));
	}

	// completely rewritten asset loading? fuck!
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];

	public static function returnGraphic(key:String, ?library:String)
	{
		var path:String = getPath('images/$key.png', IMAGE, library);

		if (OpenFlAssets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var newBitmap:BitmapData = OpenFlAssets.getBitmapData(path);

				var newGraphic:FlxGraphic;

				if (SaveData.gpuTextures)
				{
					var newTexture:Texture = FlxG.stage.context3D.createTexture(newBitmap.width, newBitmap.height, BGRA, false);
					newTexture.uploadFromBitmapData(newBitmap);
					currentTrackedTextures.set(path, newTexture);
					newBitmap.dispose();
					newBitmap.disposeImage();
					newBitmap = null;
					newGraphic = FlxG.bitmap.add(BitmapData.fromTexture(newTexture), false, path);
				}
				else
				{
					newGraphic = FlxG.bitmap.add(path, false, path);
				}

				newGraphic.persist = true;
				currentTrackedAssets.set(path, newGraphic);
			}

			if (!localTrackedAssets.contains(path))
				localTrackedAssets.push(path);

			return currentTrackedAssets.get(path);
		}
		else
		{
			trace('"$key" returned null');
			return null;
		}
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function returnSound(path:String, key:String, ?library:String)
	{
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);

		if (!currentTrackedSounds.exists(gottenPath))
		{
			if (OpenFlAssets.exists(getPath('$path/$key.$SOUND_EXT', SOUND, library)))
				currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(getPath('$path/$key.$SOUND_EXT', SOUND, library)));
			else
				currentTrackedSounds.set(gottenPath, Sound.fromFile('./' + gottenPath));
		}

		if (!localTrackedAssets.contains(gottenPath))
			localTrackedAssets.push(gottenPath);

		return currentTrackedSounds.get(gottenPath);
	}
}
