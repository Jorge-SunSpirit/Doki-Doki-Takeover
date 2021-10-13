#if FEATURE_CACHING
package;

import openfl.utils.Assets as OpenFlAssets;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxText;
	var disableText:FlxText;
	var kadeLogo:FlxSprite;

	public static var bitmapData:Map<String, FlxGraphic>;

	public static var afterBoot:Bool = false;

	var characters = [];
	var songs = [];
	var music = [];
	var sounds = [];

	override function create()
	{
		FlxG.save.bind('dokitakeover', 'ddtoteam');
		PlayerSettings.init();
		KadeEngineData.initSave();

		LangUtil.localeList = CoolUtil.coolTextFile(Paths.txt('data/textData', 'preload', true));

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0, 0);

		bitmapData = new Map<String, FlxGraphic>();

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300, 0, LangUtil.getString('cmnCaching') + "...");
		text.setFormat(LangUtil.getFont('riffic'), 42, FlxColor.WHITE, FlxTextAlign.CENTER);
		text.alpha = 0;
		text.antialiasing = true;

		disableText = new FlxText(0, 34, 0, LangUtil.getString('descDisableCaching'));
		disableText.setFormat(LangUtil.getFont('aller'), 21, FlxColor.WHITE, FlxTextAlign.CENTER);
		disableText.antialiasing = true;
		disableText.alpha = 0.1;
		disableText.screenCenter(X);

		kadeLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('DokiTakeoverLogo'));
		kadeLogo.x -= kadeLogo.width / 2;
		kadeLogo.y -= kadeLogo.height / 2 + 67;
		text.y -= kadeLogo.height / 2 - 325;
		text.x -= 170;
		kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));
		kadeLogo.antialiasing = true;

		kadeLogo.alpha = 0;

		// TODO: Refactor this to use OpenFlAssets.
		#if FEATURE_FILESYSTEM
		if (FlxG.save.data.cacheCharacters)
		{
			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
				characters.push(i);
			}
		}

		// TODO: Get the audio list from OpenFlAssets.
		if (FlxG.save.data.cacheSongs)
			songs = Paths.listSongsToCache();

		if (FlxG.save.data.cacheMusic)
			music = Paths.listAudioToCache(false);

		if (FlxG.save.data.cacheSounds)
			sounds = Paths.listAudioToCache(true);
		#end

		toBeDone = Lambda.count(characters) + Lambda.count(songs) + Lambda.count(music) + Lambda.count(sounds);

		add(kadeLogo);
		add(text);

		if (!afterBoot)
			add(disableText);

		#if FEATURE_MULTITHREADING
		// update thread
		sys.thread.Thread.create(() ->
		{
			while (!loaded)
			{
				if (toBeDone != 0 && done != toBeDone)
				{
					var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100, 2) / 100;
					kadeLogo.alpha = alpha;
					text.alpha = alpha;
					text.text = LangUtil.getString('cmnCaching') + "... (" + done + "/" + toBeDone + ")";
				}
			}
		});

		// cache thread
		sys.thread.Thread.create(() ->
		{
			cache();
		});
		#else
		while (!loaded)
		{
			if (toBeDone != 0 && done != toBeDone)
			{
				var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100, 2) / 100;
				kadeLogo.alpha = alpha;
				text.alpha = alpha;
				text.text = LangUtil.getString('cmnCaching') + "... (" + done + "/" + toBeDone + ")";
			}
		}

		cache();
		#end

		super.create();
	}

	var calledDone = false;

	override function update(elapsed)
	{
		if (FlxG.keys.justPressed.D && !afterBoot)
		{
			trace('disabled caching for next time');
			FlxG.save.data.cacheCharacters = false;
			FlxG.save.data.cacheSongs = false;
			FlxG.save.data.cacheMusic = false;
			FlxG.save.data.cacheSounds = false;
			remove(disableText);
		}

		super.update(elapsed);
	}

	function cache()
	{
		#if FEATURE_FILESYSTEM
		trace("LOADING: " + toBeDone + " OBJECTS.");

		for (i in characters)
		{
			var replaced = i.replace(".png", "");
			var imagePath = Paths.image('characters/' + replaced, 'shared');
			trace('Caching character graphic $replaced ($imagePath)...');
			var data = OpenFlAssets.getBitmapData(imagePath);
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			bitmapData.set(replaced, graph);
			done++;
		}

        for (i in songs)
		{
			trace('Caching song "$i"...');
			var inst = Paths.inst(i);
			if (Paths.doesSoundAssetExist(inst))
			{
				FlxG.sound.cache(inst);
				trace('Cached inst for song "$i"');
			}
			else
				trace('Failed to cache inst for song "$i"');

			var voices = Paths.voices(i);
			if (Paths.doesSoundAssetExist(voices))
			{
				FlxG.sound.cache(voices);
				trace('Cached voices for song "$i"');
			}
			else
				trace('Failed to cache voices for song "$i"');

			done++;
		}

        for (i in music)
		{
			var replaced = i.replace(".ogg", "");
			trace('Caching music "$replaced"...');
			var music = Paths.music(replaced, 'shared');
			if (Paths.doesSoundAssetExist(music))
			{
				FlxG.sound.cache(music);
				trace('Cached music "$replaced"');
			}
			else
				trace('Failed to cache music "$replaced"');

			done++;
		}

		for (i in sounds)
		{
			var replaced = i.replace(".ogg", "");
			trace('Caching sound "$replaced"...');
			var sound = Paths.sound(replaced, 'shared');
			if (Paths.doesSoundAssetExist(sound))
			{
				FlxG.sound.cache(sound);
				trace('Cached sound "$replaced"');
			}
			else
				trace('Failed to cache sound "$replaced"');

			done++;
		}

		trace("Finished caching!");
		#end

		loaded = true;

		if (afterBoot)
			FlxG.switchState(new MainMenuState());
		else
		{
			afterBoot = true;

			if (!FlxG.save.data.funnyquestionpopup)
				FlxG.switchState(new FirstBootState());
			else
				FlxG.switchState(new TitleState());
		}
	}
}
#end
