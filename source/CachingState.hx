package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import openfl.utils.Assets as OpenFlAssets;
import shaders.ColorMaskShader;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
#end

using StringTools;

class CachingState extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var backdrop:FlxBackdrop;
	var text:FlxText;
	var disableText:FlxText;
	var ddtoLogo:FlxSprite;
	var loadBar:FlxBar;

	var songs = [];

	override function create()
	{
		persistentUpdate = persistentDraw = true;

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
		add(backdrop);

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300, 0, LangUtil.getString('cmnCaching') + "...");
		text.setFormat(LangUtil.getFont('riffic'), 42, FlxColor.WHITE, FlxTextAlign.CENTER);
		text.y += LangUtil.getFontOffset('riffic');
		text.antialiasing = SaveData.globalAntialiasing;
		text.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);

		disableText = new FlxText(0, 34, 0, LangUtil.getString('cmnDisableCaching'));
		disableText.setFormat(LangUtil.getFont('aller'), 21, FlxColor.BLACK, FlxTextAlign.CENTER);
		disableText.y += LangUtil.getFontOffset('riffic');
		disableText.antialiasing = SaveData.globalAntialiasing;
		disableText.screenCenter(X);

		ddtoLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('DokiTakeoverLogo'));
		ddtoLogo.x -= ddtoLogo.width / 2;
		ddtoLogo.y -= ddtoLogo.height / 2 + 67;
		ddtoLogo.setGraphicSize(Std.int(ddtoLogo.width * 0.6));
		ddtoLogo.antialiasing = SaveData.globalAntialiasing;
		ddtoLogo.screenCenter(X);
		text.y -= ddtoLogo.height / 2 - 325;

		loadBar = new FlxBar(0, FlxG.height - 20);
		loadBar.makeGraphic(FlxG.width, 10, 0xFFF03CA2);
		loadBar.screenCenter(X);
		add(loadBar);

		#if (FEATURE_FILESYSTEM && FEATURE_CACHING)
		if (SaveData.cacheSong)
		{
			for (i in FileSystem.readDirectory(FileSystem.absolutePath('assets/songs')))
			{
				if (FileSystem.isDirectory(FileSystem.absolutePath('assets/songs/$i')))
				{
					for (f in FileSystem.readDirectory(FileSystem.absolutePath('assets/songs/$i')))
					{
						if (!f.endsWith(".ogg"))
							continue;
	
						songs.push('$i/$f');
					}
				}
			}
		}
		#end

		toBeDone = Lambda.count(songs);

		add(ddtoLogo);
		add(text);
		add(disableText);

		#if sys
		// update thread
		sys.thread.Thread.create(() ->
		{
			while (!loaded)
			{
				if (toBeDone != 0 && done != toBeDone)
				{
					loadBar.scale.x = done / toBeDone;
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
		text.text = '${LangUtil.getString('cmnCaching')}...';
		cache();
		#end

		super.create();
	}

	var canSpam:Bool = true;

	override function update(elapsed)
	{
		text.screenCenter(X);

		if (FlxG.keys.justPressed.D && canSpam)
		{
			SaveData.cacheSong = false;
			SaveData.save();

			remove(disableText);
			canSpam = false;
		}

		super.update(elapsed);
	}

	function cache()
	{
		for (i in songs)
		{
			Debug.logTrace('[SONG] Caching ${i.substring(0, i.length - 4)}');

			var path:String = Paths.getPath(i, MUSIC, 'songs');
			var key:String = path.substring(path.indexOf(':') + 1, path.length);

			if (Paths.dumpExclusions.contains(key))
			{
				done++;
				continue;
			}

			Paths.dumpExclusions.push(key);
			Paths.localTrackedAssets.push(key);
			Paths.currentTrackedSounds.set(key, OpenFlAssets.getSound(path));

			done++;
		}

		loadBar.scale.x = 1;
		text.text = LangUtil.getString('cmnCachingFinish');

		loaded = true;

		if (!TitleState.initialized)
		{
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new TitleState());
		}
		else
		{
			MusicBeatState.switchState(new OptionsState());
		}
	}
}
