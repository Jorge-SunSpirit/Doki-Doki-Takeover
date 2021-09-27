package;

import Song.SwagSong;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;

#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class DokiFreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadatatwo> = [];
	var menu_character:FlxSprite;
	var selector:FlxText;
	var curSelected:Int = 0;
	public static var curPage:Int = 0;
	public static var pageFlipped:Bool = false;
	var curDifficulty:Int = 1;
	var goku:Bool = false;
	var diffselect:Bool = false;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var diff:FlxSprite;
	var bg:FlxSprite;

	private var grpSongs:FlxTypedGroup<FlxSprite>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var songData:Map<String,Array<SwagSong>> = [];

	public static function loadDiff(diff:Int, name:String, array:Array<SwagSong>)
		{
			try 
			{
				array.push(Song.loadFromJson(Highscore.formatSong(name, diff), name));
			}
			catch(ex)
			{
				// do nada
			}
		}

	override function create()
	{
		if (pageFlipped)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/Page' + (curPage + 1)));

		for (i in 0...initSonglist.length)
			{
				var data:Array<String> = initSonglist[i].split(':');
				var meta = new SongMetadatatwo(data[0], Std.parseInt(data[2]), data[1]);

				if (!FlxG.save.data.monibeaten && data[0].toLowerCase() == 'your reality')
					continue;
	
				if ((Std.parseInt(data[2]) <= FlxG.save.data.weekUnlocked - 1) || (Std.parseInt(data[2]) == 1))
					songs.push(meta);
	
				var diffs = [];
				loadDiff(0,meta.songName,diffs);
				loadDiff(1,meta.songName,diffs);
				loadDiff(2,meta.songName,diffs);
				songData.set(meta.songName,diffs);
			}

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('freeplay/freeplaybook' + (curPage + 1)));
		bg.antialiasing = true;
		add(bg);
		
		for (i in 0...songs.length)
			{
				var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
				iconArray.push(icon);
				icon.x = 1060;
				icon.y = 550;
				icon.scale.set(1.6, 1.6);
				icon.angle = 30;

				if ((curPage == 1 && !FlxG.save.data.monibeaten) || (curPage == 2 && !FlxG.save.data.extra2beaten))
					{
		
					}
					else
					{
						add(icon);
					}
			}

		grpSongs = new FlxTypedGroup<FlxSprite>();

		if ((curPage == 1 && !FlxG.save.data.monibeaten) || (curPage == 2 && !FlxG.save.data.extra2beaten))
			{

			}
			else
			{
				add(grpSongs);
			}

		menu_character = new FlxSprite(40, 500);
		menu_character.frames = Paths.getSparrowAtlas('freeplay/chibidorks');
		menu_character.antialiasing = true;
		menu_character.animation.addByPrefix('idle', 'FreeplayChibiIdle', 24, false);
		menu_character.animation.addByPrefix('pop_off', 'FreeplayChibiCheer', 24, false);
		menu_character.updateHitbox();
		menu_character.animation.play('idle');

		if (curPage != 3)
			add(menu_character);

		diff = new FlxSprite(453, 580);
		diff.frames = Paths.getSparrowAtlas('dokistory/difficulties', 'preload', true);
		diff.antialiasing = true;
		diff.animation.addByPrefix('easy', 'Easy', 24);
		diff.animation.addByPrefix('normal', 'Normal', 24);
		diff.animation.addByPrefix('hard', 'Hard', 24);
		diff.animation.play('normal');
		diff.updateHitbox();
		diff.visible = false;
		add(diff);

		var tex = Paths.getSparrowAtlas('freeplay/songlist_page_1');

		for (i in 0...songs.length)
		{
			var songText:FlxSprite = new FlxSprite(442, 114  + (i * 47.5));
			if (curPage == 3)
				{
					songText.x = 588;
					songText.y = 390;
				}
			songText.frames = tex;
			songText.antialiasing = true;
			songText.animation.addByPrefix('idle', songs[i].songName + " idle", 24);
			songText.animation.addByPrefix('selected', songs[i].songName + " selected", 24);
			songText.animation.play('idle');
			songText.ID = i;
			grpSongs.add(songText);
		}

		changeItem();

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
		{
			songs.push(new SongMetadatatwo(songName, weekNum, songCharacter));
		}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{

		trace (curPage + "hewwo");

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
		
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if ((curPage == 1 && !FlxG.save.data.monibeaten) || (curPage == 2 && !FlxG.save.data.extra2beaten))
			{

			}
			else
			{
				for (i in 0...iconArray.length)
					{
						iconArray[i].alpha = 0;
					}
				
				if (iconArray.length > 0)
					iconArray[curSelected].alpha = 1;
			}

		if (!selectedSomethin)
		{
			if (controls.UP_P && !diffselect && curPage != 3)
			{
				if ((curPage == 1 && !FlxG.save.data.monibeaten) || (curPage == 2 && !FlxG.save.data.extra2beaten))
					{
		
					}
					else
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(-1);
					}
			}

			if (controls.DOWN_P && !diffselect && curPage != 3)
			{
				if ((curPage == 1 && !FlxG.save.data.monibeaten) || (curPage == 2 && !FlxG.save.data.extra2beaten))
					{
		
					}
					else
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(1);
					}
			}

			if (controls.LEFT_P && !diffselect)
				{
					//FlxG.sound.play(Paths.sound('scrollMenu'));
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					changePage(-1);
					LoadingState.loadAndSwitchState(new DokiFreeplayState());
				}
	
			if (controls.RIGHT_P && !diffselect)
				{
					//FlxG.sound.play(Paths.sound('scrollMenu'));
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					changePage(1);
					LoadingState.loadAndSwitchState(new DokiFreeplayState());
				}


			if (controls.BACK)
				{
					switch (diffselect)
						{
							case true:
								diff.visible = false;
								diffselect = false;
							case false:
								DokiFreeplayState.pageFlipped = false;
								DokiFreeplayState.curPage = 0;
								FlxG.switchState(new MainMenuState());
						}
					
				}

			if (controls.LEFT_P && diffselect)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeDiff(-1);
				}
	
			if (controls.RIGHT_P && diffselect)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeDiff(1);
				}

			if (FlxG.keys.justPressed.SEVEN && diffselect)
					loadSong(true);

			if (controls.ACCEPT && songs[curSelected].songName.toLowerCase() == 'your reality')
				{
					curDifficulty = 1;
					startsong();
				}

			if (controls.ACCEPT && songs[curSelected].songName.toLowerCase() == 'epiphany')
				{
					curDifficulty = 2;
					startsong();
				}

			if (controls.ACCEPT && (songs[curSelected].songName.toLowerCase() != 'your reality' && songs[curSelected].songName.toLowerCase() != 'epiphany'))
				{
					if ((curPage == 1 && !FlxG.save.data.monibeaten) || (curPage == 2 && !FlxG.save.data.extra2beaten))
					{
		
					}
					else
					{
					switch (diffselect)
					{
						case false:
							{
								FlxG.sound.play(Paths.sound('confirmMenu'));
								diff.visible = true;
								diffselect = true;
							}
						case true:
							{
								startsong();
							}
					}
					}
				}
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
		grpSongs.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function startsong()
		{
			DokiFreeplayState.pageFlipped = false;
			DokiFreeplayState.curPage = 0;
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			menu_character.y -= 31;
			menu_character.animation.play('pop_off');
			grpSongs.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 1.3, {
					ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
						spr.kill();
						}
					});
					}
					else
				{
						if (FlxG.save.data.flashing)
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
							loadSong();
						});
						}
					else
					{
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							loadSong();
						});
					}
				}
			});
		}

	function loadSong(isCharting:Bool = false)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
	
			trace(poop);
	
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
	
			if (isCharting)
				LoadingState.loadAndSwitchState(new ChartingState());
			else
				LoadingState.loadAndSwitchState(new PlayState());
		}


	function changeDiff(change:Int = 0):Void
		{
			curDifficulty += change;

			if (curDifficulty < 0)
				curDifficulty = 2;
			if (curDifficulty > 2)
				curDifficulty = 0;

			switch (curDifficulty)
			{
				case 0:
				diff.animation.play('easy');
				case 1:
				diff.animation.play('normal');
				case 2:
				diff.animation.play('hard');
			}
		}

	function changeItem(huh:Int = 0)
		{
			curSelected += huh;

			if (curSelected >= songs.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = songs.length - 1;


			if ((curPage == 1 && !FlxG.save.data.monibeaten) || (curPage == 2 && !FlxG.save.data.extra2beaten))
				{
	
				}
				else
				{
					#if PRELOAD_ALL
					FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);

					var hmm;
					try
					{
						hmm = songData.get(songs[curSelected].songName)[curDifficulty];
						if (hmm != null)
							Conductor.changeBPM(hmm.bpm);
					}
					catch(ex)
					{}
					#end
				}
				
			grpSongs.forEach(function(spr:FlxSprite)
			{
				spr.animation.play('idle');

				if (spr.ID == curSelected)
				{
					spr.animation.play('selected');
				}

				spr.updateHitbox();
			});
		}
	
	function changePage(huh:Int = 0)
		{
			pageFlipped = true;
			curPage += huh;

			if (!FlxG.save.data.unlockepip)
				{
					if (curPage >= 3)
						curPage = 0;
					if (curPage < 0)
						curPage = 3 - 1;
				}
				else
				{
					if (curPage >= 4)
						curPage = 0;
					if (curPage < 0)
						curPage = 4 - 1;
				}
			//updating page stuff here
			
		}
}

	class SongMetadatatwo
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}