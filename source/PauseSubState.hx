package;

import openfl.Lib;
#if FEATURE_LUAMODCHART
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String>;
	var pauseOG:Array<String> = [
		"Resume",
		"Restart Song",
		"Change Difficulty",
		"Toggle Practice Mode",
		"Exit to menu"
	];
	var difficultyChoices:Array<String> = ["EASY", "NORMAL", "HARD", "BACK"];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var perSongOffset:FlxText;

	var offsetChanged:Bool = false;
	var startOffset:Float = PlayState.songOffset;

	public function new(x:Float, y:Float)
	{
		super();

		if (PlayState.isStoryMode || PlayState.SONG.song.toLowerCase() == 'epiphany')
			pauseOG = ["Resume", "Restart Song", "Exit to menu"];

		menuItems = pauseOG;

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('disco'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play();

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.antialiasing = true;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(LangUtil.getFont(), 32);
		levelInfo.y += LangUtil.getFontOffset();
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.antialiasing = true;
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(LangUtil.getFont(), 32);
		levelDifficulty.y += LangUtil.getFontOffset();
		levelDifficulty.updateHitbox();

		if (PlayState.SONG.song.toLowerCase() != 'epiphany')
			add(levelDifficulty);

		var deathText:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		deathText.text += "Blue balled: " + PlayState.deathCounter;
		deathText.antialiasing = true;
		deathText.scrollFactor.set();
		deathText.setFormat(LangUtil.getFont(), 32);
		deathText.y += LangUtil.getFontOffset();
		deathText.updateHitbox();
		add(deathText);

		practiceText = new FlxText(20, 15 + 96, 0, "PRACTICE MODE", 32);
		practiceText.visible = PlayState.practiceMode;
		practiceText.antialiasing = true;
		practiceText.scrollFactor.set();
		practiceText.setFormat(LangUtil.getFont(), 32);
		practiceText.y += LangUtil.getFontOffset();
		practiceText.updateHitbox();
		add(practiceText);

		levelInfo.alpha = 0;
		levelDifficulty.alpha = 0;
		deathText.alpha = 0;
		practiceText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		deathText.x = FlxG.width - (deathText.width + 20);
		practiceText.x = FlxG.width - (practiceText.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(deathText, {alpha: 1, y: deathText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(practiceText, {alpha: 1, y: practiceText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		perSongOffset = new FlxText(5, FlxG.height
			- 18, 0,
			LangUtil.getString('cmnAddOffset')
			+ ': '
			+ PlayState.songOffset
			+ ' - '
			+ LangUtil.getString('cmnDesc')
			+ ' - '
			+ LangUtil.getString('descAddOffset'),
			12);
		perSongOffset.antialiasing = true;
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat(LangUtil.getFont(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		perSongOffset.y += LangUtil.getFontOffset();

		#if FEATURE_FILESYSTEM
		add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var rightP = controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var oldOffset:Float = 0;
		var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';

		if (upP)
			changeSelection(-1);
		else if (downP)
			changeSelection(1);

		#if FEATURE_FILESYSTEM
		else if (leftP)
		{
			oldOffset = PlayState.songOffset;
			PlayState.songOffset -= 1;
			sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
			perSongOffset.text = LangUtil.getString('cmnAddOffset') + ': ' + PlayState.songOffset + ' - ' + LangUtil.getString('cmnDesc') + ' - '
				+ LangUtil.getString('descAddOffset');

			// Prevent loop from happening every single time the offset changes
			if (!offsetChanged)
			{
				if (PlayState.isStoryMode || PlayState.SONG.song.toLowerCase() == 'epiphany')
					pauseOG = ["Restart Song", "Exit to menu"];
				else
					pauseOG = ["Restart Song", "Change Difficulty", "Toggle Practice Mode", "Exit to menu"];

				menuItems = pauseOG;
				regenMenu();
				offsetChanged = true;
			}
			else if (PlayState.songOffset == startOffset)
			{
				if (PlayState.isStoryMode || PlayState.SONG.song.toLowerCase() == 'epiphany')
					pauseOG = ["Resume", "Restart Song", "Exit to menu"];
				else
					pauseOG = [
						"Resume",
						"Restart Song",
						"Change Difficulty",
						"Toggle Practice Mode",
						"Exit to menu"
					];

				menuItems = pauseOG;
				regenMenu();
				offsetChanged = false;
			}
		}
		else if (rightP)
		{
			oldOffset = PlayState.songOffset;
			PlayState.songOffset += 1;
			sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
			perSongOffset.text = LangUtil.getString('cmnAddOffset') + ': ' + PlayState.songOffset + ' - ' + LangUtil.getString('cmnDesc') + ' - '
				+ LangUtil.getString('descAddOffset');
			if (!offsetChanged)
			{
				if (PlayState.isStoryMode || PlayState.SONG.song.toLowerCase() == 'epiphany')
					pauseOG = ["Restart Song", "Exit to menu"];
				else
					pauseOG = ["Restart Song", "Change Difficulty", "Toggle Practice Mode", "Exit to menu"];

				menuItems = pauseOG;
				regenMenu();
				offsetChanged = true;
			}
			else if (PlayState.songOffset == startOffset)
			{
				if (PlayState.isStoryMode || PlayState.SONG.song.toLowerCase() == 'epiphany')
					pauseOG = ["Resume", "Restart Song", "Exit to menu"];
				else
					pauseOG = [
						"Resume",
						"Restart Song",
						"Change Difficulty",
						"Toggle Practice Mode",
						"Exit to menu"
					];

				menuItems = pauseOG;
				regenMenu();
				offsetChanged = false;
			}
		}
		#end

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Change Difficulty":
					menuItems = difficultyChoices;
					regenMenu();
				case "Toggle Practice Mode":
					PlayState.practiceMode = !PlayState.practiceMode;
					practiceText.visible = PlayState.practiceMode;
				case "Exit to menu":
					PlayState.practiceMode = false;
					PlayState.showCutscene = true;
					if (PlayState.loadRep)
					{
						FlxG.save.data.botplay = false;
						FlxG.save.data.scrollSpeed = 1;
						FlxG.save.data.downscroll = false;
					}
					PlayState.loadRep = false;
					#if FEATURE_LUAMODCHART
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end
					if (FlxG.save.data.fpsCap > 290)
						(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

					if (PlayState.isStoryMode)
						FlxG.switchState(new DokiStoryState());
					else
						FlxG.switchState(new DokiFreeplayState());
				case "EASY" | "NORMAL" | "HARD":
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.SONG.song.toLowerCase(), curSelected),
						PlayState.SONG.song.toLowerCase());
					PlayState.storyDifficulty = curSelected;
					FlxG.resetState();
				case "BACK":
					menuItems = pauseOG;
					regenMenu();
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function regenMenu()
	{
		while (grpMenuShit.members.length > 0)
		{
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		curSelected = 0;
		changeSelection();
	}
}
