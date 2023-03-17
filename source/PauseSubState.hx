package;

import openfl.Lib;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

using StringTools;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxText>;

	var menuItems:Array<String>;
	var pauseOG:Array<String> = [
		"Resume",
		"Restart Song",
		//"Change Difficulty",
		"Practice Mode",
		"Exit to Menu"
	];
	var difficultyChoices:Array<String> = ["Easy", "Normal", "Hard", "Back"];
	var curSelected:Int = 0;

	var curCharacter:Int = 0;
	var deathInfo:Array<String> = ["Deleted", "Blue balled", "Pastad"];

	var pauseMusic:FlxSound;

	var levelInfo:FlxText;
	var levelDifficulty:FlxText;
	var deathText:FlxText;
	var practiceText:FlxText;
	var speedText:FlxText;
	var globalSongOffset:FlxText;
	var perSongOffset:FlxText;

	var canPress:Bool = true;

	var bg:FlxSprite;
	var logo:FlxSprite;
	var logoBl:FlxSprite;

	var pauseArt:FlxSprite;

	var isLibitina:Bool = false;
	var isVallHallA:Bool = false;

	var itmColor:FlxColor = 0xFFFF7CFF;
	var selColor:FlxColor = 0xFFFFCFFF;

	/*
	private var curPos:Float = 0;
	private var curBPM:Float = 0;
	*/

	public function new(?forcePauseArt:String)
	{
		FlxG.mouse.visible = true;
		super();

		isLibitina = PlayState.SONG.song.toLowerCase() == 'libitina';
		isVallHallA = PlayState.SONG.song.toLowerCase() == 'drinks on me';

		var curPlayer:String = SaveData.mirrorMode ? PlayState.SONG.player2 : PlayState.SONG.player1;

		if (curPlayer.contains('bf'))
			curCharacter = 1;
		else if (curPlayer.contains('senpai'))
			curCharacter = 2;
		else
			curCharacter = 0;

		if (PlayState.isStoryMode)
			pauseOG = ["Resume", "Restart Song", "Exit to Menu"];
		else if (PlayState.SONG.song.toLowerCase().startsWith('epiphany')
			|| DokiFreeplayState.singleDiff.contains(PlayState.SONG.song.toLowerCase()))
			pauseOG = ["Resume", "Restart Song", "Practice Mode", "Exit to Menu"];

		menuItems = pauseOG;

		/*
		curPos = Conductor.songPosition;
		curBPM = Conductor.bpm;
		Conductor.changeBPM(124);
		*/

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('disco'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play();

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var pauseImg:String = (PlayState.hasMetadata && PlayState.metadata.song.pause != null) ? PlayState.metadata.song.pause : "fumo";
		if (forcePauseArt != null && forcePauseArt != '')
			pauseImg = forcePauseArt;
		pauseArt = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('pause/$pauseImg'));
		pauseArt.antialiasing = SaveData.globalAntialiasing;
		add(pauseArt);

		if (isLibitina)
			pauseArt.x = -pauseArt.width;

		FlxTween.tween(pauseArt, {x: FlxG.width - pauseArt.width}, 1.2, {
			ease: FlxEase.quartInOut,
			startDelay: 0.2
		});
	
		levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += (PlayState.hasMetadata ? PlayState.metadata.song.name : PlayState.SONG.song);
		levelInfo.antialiasing = SaveData.globalAntialiasing;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(LangUtil.getFont(), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelInfo.borderSize = 1.25;
		levelInfo.y += LangUtil.getFontOffset();
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text = CoolUtil.difficultyString(PlayState.storyDifficulty);
		levelDifficulty.antialiasing = SaveData.globalAntialiasing;
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(LangUtil.getFont(), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		levelDifficulty.borderSize = 1.25;
		levelDifficulty.y += LangUtil.getFontOffset();
		levelDifficulty.updateHitbox();

		//if (!PlayState.SONG.song.toLowerCase().startsWith('epiphany') && !DokiFreeplayState.singleDiff.contains(PlayState.SONG.song.toLowerCase()))
		//	add(levelDifficulty);

		// + 64
		deathText = new FlxText(20, 15 + 32, 0, LangUtil.getString(deathInfo[curCharacter].toLowerCase(), 'pause') + ': ', 32);
		deathText.text += PlayState.deathCounter;
		deathText.antialiasing = SaveData.globalAntialiasing;
		deathText.scrollFactor.set();
		deathText.setFormat(LangUtil.getFont(), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		deathText.borderSize = 1.25;
		deathText.y += LangUtil.getFontOffset();
		deathText.updateHitbox();

		if (PlayState.SONG.song.toLowerCase() != 'credits')
			add(deathText);

		// + 96
		practiceText = new FlxText(20, 15 + 64, 0, LangUtil.getString('cmnPractice'), 32);
		practiceText.visible = PlayState.practiceMode;
		practiceText.antialiasing = SaveData.globalAntialiasing;
		practiceText.scrollFactor.set();
		practiceText.setFormat(LangUtil.getFont(), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		practiceText.borderSize = 1.25;
		practiceText.y += LangUtil.getFontOffset();
		practiceText.updateHitbox();
		add(practiceText);

		speedText = new FlxText(410, 15, 0, '${LangUtil.getString('cmnSpeed')}: ${Conductor.playbackSpeed}x (CTRL + Left/Right)', 32);
		speedText.visible = PlayState.practiceMode;
		speedText.antialiasing = SaveData.globalAntialiasing;
		speedText.scrollFactor.set();
		speedText.setFormat(LangUtil.getFont(), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		speedText.borderSize = 1.25;
		speedText.y += LangUtil.getFontOffset();
		speedText.updateHitbox();
		add(speedText);

		levelInfo.alpha = 0;
		levelDifficulty.alpha = 0;
		deathText.alpha = 0;
		practiceText.alpha = 0;
		speedText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		deathText.x = FlxG.width - (deathText.width + 20);
		practiceText.x = FlxG.width - (practiceText.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20 + LangUtil.getFontOffset()}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(deathText, {alpha: 1, y: deathText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(practiceText, {alpha: 1, y: practiceText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		FlxTween.tween(speedText, {alpha: 1, y: speedText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});

		if (isLibitina && PlayState.isStoryMode)
		{
			pauseArt.visible = false;
			levelInfo.visible = false;
		}

		logo = new FlxSprite(-260, 0).loadGraphic(Paths.image('Credits_LeftSide'));
		logo.antialiasing = SaveData.globalAntialiasing;
		add(logo);

		FlxTween.tween(logo, {x: -60}, 1.2, {
			ease: FlxEase.elasticOut
		});

		logoBl = new FlxSprite(-160, -40);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = SaveData.globalAntialiasing;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, true);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);

		FlxTween.tween(logoBl, {x: 40}, 1.2, {
			ease: FlxEase.elasticOut
		});

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		var textX:Int = 50;
		if (isVallHallA) textX += 25;

		for (i in 0...menuItems.length)
		{
			var songText:FlxText = new FlxText(-350, 370 + (i * 50), 0, LangUtil.getString(menuItems[i].toLowerCase(), 'pause'));
			songText.setFormat(LangUtil.getFont('riffic'), 27, FlxColor.WHITE, LEFT);
			songText.antialiasing = SaveData.globalAntialiasing;
			songText.setBorderStyle(OUTLINE, itmColor, 2);
			songText.ID = i;
			grpMenuShit.add(songText);

			FlxTween.tween(songText, {x: textX}, 1.2 + (i * 0.2), {
				ease: FlxEase.elasticOut
			});
		}

		globalSongOffset = new FlxText(5, FlxG.height - 42, 0, LangUtil.getString('cmnOffset') + ': ${SaveData.offset} ms', 12);
		globalSongOffset.alpha = 0;
		globalSongOffset.antialiasing = SaveData.globalAntialiasing;
		globalSongOffset.scrollFactor.set();
		globalSongOffset.setFormat(LangUtil.getFont(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		globalSongOffset.y += LangUtil.getFontOffset();
		add(globalSongOffset);

		FlxTween.tween(globalSongOffset, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});

		perSongOffset = new FlxText(5, FlxG.height - 22, 0, LangUtil.getString('cmnAddOffset', 'data', '${PlayState.perSongOffset} ms'), 12);
		perSongOffset.alpha = 0;
		perSongOffset.antialiasing = SaveData.globalAntialiasing;
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat(LangUtil.getFont(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		perSongOffset.y += LangUtil.getFontOffset();
		add(perSongOffset);

		FlxTween.tween(perSongOffset, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});

		if (isLibitina)
		{
			pauseMusic.pause();

			itmColor = 0xFF8BA9F0;

			logoBl.visible = false;
			logo.loadGraphic(Paths.image('LibitinaPause'));

			grpMenuShit.forEach(function(txt:FlxText)
			{
				txt.setBorderStyle(OUTLINE, FlxColor.WHITE, 1.25);

				if (txt.ID == curSelected)
					txt.setFormat(LangUtil.getFont('dos'), 27, FlxColor.WHITE, LEFT);
				else
					txt.setFormat(LangUtil.getFont('dos'), 27, itmColor, LEFT);
			});
		}
		else if (isVallHallA)
		{
			itmColor = 0xFFFF3A89;

			logoBl.visible = false;
			logo.loadGraphic(Paths.image('Va11Pause'));
			logo.antialiasing = false;

			speedText.x += 60;

			grpMenuShit.forEach(function(txt:FlxText)
			{
				//txt.x += 25;
				txt.y -= 75;

				txt.setBorderStyle(OUTLINE, FlxColor.BLACK, 0);
				txt.antialiasing = false;

				if (txt.ID == curSelected)
					txt.setFormat(LangUtil.getFont('waifu'), 32, itmColor, LEFT);
				else
					txt.setFormat(LangUtil.getFont('waifu'), 32, FlxColor.WHITE, LEFT);
			});
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		/*
		if (pauseMusic != null && canPress)
			Conductor.songPosition = pauseMusic.time;
		*/

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;
		else if (pauseMusic.volume > 0.5)
			pauseMusic.volume = 0.5;

		// sometimes having autopause disabled will keep playing the song, idk why
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.pause();

		if (PlayState.vocals != null && PlayState.vocals.playing)
			PlayState.vocals.pause();

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var leftP = FlxG.keys.pressed.SHIFT ? controls.LEFT : controls.LEFT_P;
		var rightP = FlxG.keys.pressed.SHIFT ? controls.RIGHT : controls.RIGHT_P;
		var accepted = controls.ACCEPT;
		var reset = controls.RESET;

		if (upP)
			changeSelection(-1);
		else if (downP)
			changeSelection(1);

		if (!FlxG.keys.pressed.CONTROL)
		{
			if (reset)
				changeOffset(0, true);
			else if (leftP)
				changeOffset(-1);
			else if (rightP)
				changeOffset(1);
		}

		if (FlxG.keys.pressed.CONTROL && PlayState.practiceMode)
		{
			if (leftP)
			{
				Conductor.playbackSpeed -= 0.05;

				if (Conductor.playbackSpeed < 0.25)
					Conductor.playbackSpeed = 0.25;

				Conductor.playbackSpeed = FlxMath.roundDecimal(Conductor.playbackSpeed, 2);

				speedText.text = '${LangUtil.getString('cmnSpeed')}: ${Conductor.playbackSpeed}x';
			}

			if (rightP)
			{
				Conductor.playbackSpeed += 0.05;

				if (Conductor.playbackSpeed > 3)
					Conductor.playbackSpeed = 3;

				Conductor.playbackSpeed = FlxMath.roundDecimal(Conductor.playbackSpeed, 2);

				speedText.text = '${LangUtil.getString('cmnSpeed')}: ${Conductor.playbackSpeed}x';
			}

			if (reset)
			{
				Conductor.playbackSpeed = 1;
				speedText.text = '${LangUtil.getString('cmnSpeed')}: ${Conductor.playbackSpeed}x';
			}
		}

		if (!PlayState.practiceMode && SaveData.songSpeed == 1)
			Conductor.playbackSpeed = 1;

		if (accepted && canPress)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					closeMenu();
				case "Restart Song":
					MusicBeatState.resetState();
				case "Change Difficulty":
					menuItems = difficultyChoices;
					regenMenu();
				case "Practice Mode":
					PlayState.practiceMode = !PlayState.practiceMode;
					practiceText.visible = PlayState.practiceMode;
					speedText.visible = PlayState.practiceMode;
				case "Exit to Menu":
					PlayState.sectionStart = false;
					PlayState.mirrormode = false;
					PlayState.chartingMode = false;
					PlayState.practiceMode = false;
					PlayState.practiceModeToggled = false;
					PlayState.showCutscene = true;
					PlayState.deathCounter = 0;
					Conductor.playbackSpeed = 1;
					PlayState.toggleBotplay = false;
					PlayState.ForceDisableDialogue = false;

					if (PlayState.isStoryMode)
						MusicBeatState.switchState(new DokiStoryState());
					else
						MusicBeatState.switchState(new DokiFreeplayState());
				case "Easy" | "Normal" | "Hard":
					try
					{
						PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.SONG.song, curSelected),
							PlayState.SONG.song.toLowerCase());
						PlayState.storyDifficulty = curSelected;
					}
					catch (e)
					{
						PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.SONG.song, 2),
							PlayState.SONG.song.toLowerCase());
						PlayState.storyDifficulty = 2;
					}
					MusicBeatState.resetState();
				case "Back":
					menuItems = pauseOG;
					regenMenu();
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();
		FlxG.mouse.visible = false;
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		grpMenuShit.forEach(function(txt:FlxText)
		{
			if (isLibitina)
			{
				if (txt.ID == curSelected)
					txt.setFormat(LangUtil.getFont('dos'), 27, FlxColor.WHITE, LEFT);
				else
					txt.setFormat(LangUtil.getFont('dos'), 27, itmColor, LEFT);
			}
			else if (isVallHallA)
			{
				if (txt.ID == curSelected)
					txt.setFormat(LangUtil.getFont('waifu'), 32, itmColor, LEFT);
				else
					txt.setFormat(LangUtil.getFont('waifu'), 32, FlxColor.WHITE, LEFT);
			}
			else
			{
				if (txt.ID == curSelected)
					txt.setBorderStyle(OUTLINE, selColor, 2);
				else
					txt.setBorderStyle(OUTLINE, itmColor, 2);
			}
		});
	}

	function changeOffset(change:Float = 0, force:Bool = false):Void
	{
		if (force)
			PlayState.perSongOffset = change;
		else
			PlayState.perSongOffset += change;

		PlayState.perSongOffset = Std.int(PlayState.perSongOffset);

		SaveData.setSongOffset(PlayState.SONG.song, PlayState.perSongOffset);
		perSongOffset.text = LangUtil.getString('cmnAddOffset', 'data', '${PlayState.perSongOffset} ms'); 
	}

	function closeMenu()
	{
		//Tweens!
		FlxG.sound.play(Paths.sound('confirmMenu'));
		canPress = false;

		FlxTween.cancelTweensOf(pauseArt);

		FlxTween.cancelTweensOf(logo);
		FlxTween.cancelTweensOf(logoBl);
		FlxTween.cancelTweensOf(bg);
		FlxTween.cancelTweensOf(globalSongOffset);
		FlxTween.cancelTweensOf(perSongOffset);

		FlxTween.cancelTweensOf(levelInfo);
		FlxTween.cancelTweensOf(levelDifficulty);
		FlxTween.cancelTweensOf(deathText);
		FlxTween.cancelTweensOf(practiceText);
		FlxTween.cancelTweensOf(speedText);

		for (i in 0...grpMenuShit.length)
		{
			FlxTween.cancelTweensOf(grpMenuShit.members[i]);
			FlxTween.tween(grpMenuShit.members[i], {x: -350}, 0.5, {ease: FlxEase.quartInOut});
		}

		FlxTween.tween(pauseArt, {x: FlxG.width}, 0.7, {ease: FlxEase.quartInOut});

		FlxTween.tween(logo, {x: -500}, 0.7, {ease: FlxEase.quartInOut});
		FlxTween.tween(logoBl, {x: -500}, 0.7, {ease: FlxEase.quartInOut});
		FlxTween.tween(bg, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(globalSongOffset, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(perSongOffset, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});

		FlxTween.tween(levelInfo, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelDifficulty, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(deathText, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(practiceText, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(speedText, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});

		new FlxTimer().start(0.6, function(tmr:FlxTimer)
		{
			/*
			Conductor.songPosition = curPos;
			Conductor.changeBPM(curBPM);
			*/

			close();
		});
	}

	function regenMenu()
	{
		while (grpMenuShit.members.length > 0)
		{
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length)
		{
			var songText:FlxText = new FlxText(50, 370 + (i * 50), 0, LangUtil.getString(menuItems[i].toLowerCase(), 'pause'));
			songText.setFormat(LangUtil.getFont('riffic'), 27, FlxColor.WHITE, LEFT);
			songText.antialiasing = SaveData.globalAntialiasing;
			songText.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			songText.ID = i;
			grpMenuShit.add(songText);
		}

		if (isLibitina)
		{
			grpMenuShit.forEach(function(txt:FlxText)
			{
				txt.setBorderStyle(OUTLINE, FlxColor.WHITE, 1.25);

				if (txt.ID == curSelected)
					txt.setFormat(LangUtil.getFont('dos'), 27, FlxColor.WHITE, LEFT);
				else
					txt.setFormat(LangUtil.getFont('dos'), 27, itmColor, LEFT);
			});
		}
		else if (isVallHallA)
		{
			grpMenuShit.forEach(function(txt:FlxText)
			{
				txt.x += 25;
				txt.y -= 75;

				txt.setBorderStyle(OUTLINE, FlxColor.BLACK, 0);
				txt.antialiasing = false;

				if (txt.ID == curSelected)
					txt.setFormat(LangUtil.getFont('waifu'), 32, itmColor, LEFT);
				else
					txt.setFormat(LangUtil.getFont('waifu'), 32, FlxColor.WHITE, LEFT);
			});
		}

		curSelected = 0;
		changeSelection();
	}

	/*
	override function beatHit()
	{
		super.beatHit();
		logoBl.animation.play('bump', true);
	}
	*/
}
