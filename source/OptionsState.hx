package;

import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import shaders.ColorMaskShader;

class OptionsState extends MusicBeatState
{
	public static var instance:OptionsState;

	var backdrop:FlxBackdrop;
	var logo:FlxSprite;
	var logoBl:FlxSprite;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory(LangUtil.getString('catGameplay', 'option'), [
			new KeyBindingsOption(LangUtil.getString('descKeyBindings', 'option'), controls),
			new DownscrollOption(LangUtil.getString('descDownscroll', 'option')),
			new LaneUnderlayOption(LangUtil.getString('descLaneUnderway', 'option')),
			new MiddleScrollOption(LangUtil.getString('descMiddleScroll', 'option')),
			new GhostTapOption(LangUtil.getString('descGhostTap', 'option')),
			new Judgement(LangUtil.getString('descJudgement', 'option')),
			new ScrollSpeedOption(LangUtil.getString('descScroll', 'option')),
			new ResetButtonOption(LangUtil.getString('descReset', 'option')),
			new BotPlay(LangUtil.getString('descBotplay', 'option')),
			new HitSoundOption(LangUtil.getString('descHitSound', 'option')),
			new HitSoundJudgements(LangUtil.getString('descHitSoundJudge', 'option')),
			new AutoPause(LangUtil.getString('descAutoPause', 'option'))
		]),
		new OptionCategory(LangUtil.getString('catAppearance', 'option'), [
			new FPSOption(LangUtil.getString('descFPSCount', 'option')),
			#if html5
			new AntiAliasing(LangUtil.getString('descAntialiasing', 'option')),
			#end
			new Shaders(LangUtil.getString('descShaders', 'option')),
			new CustomCursor(LangUtil.getString('descCursor', 'option')),
			new FlashingLightsOption(LangUtil.getString('descFlashing', 'option')),
			new AccuracyOption(LangUtil.getString('descAccuracy', 'option')),
			new NPSDisplayOption(LangUtil.getString('descNPS', 'option')),
			new SongPositionOption(LangUtil.getString('descPosition', 'option')),
			new NoteSplashToggle(LangUtil.getString('descNoteSplash', 'option')),
			new EarlyLateOption(LangUtil.getString('descEarlyLate', 'option')),
			new JudgementCounter(LangUtil.getString('descJudgeCount', 'option')),
			new RatingToggle(LangUtil.getString('descRatingToggle', 'option')),
			new CustomizeGameplay(LangUtil.getString('descCustomize', 'option'))
		]),
		#if !html5
		new OptionCategory(LangUtil.getString('catPerformance', 'option'), [
			new FPSCapOption(LangUtil.getString('descFPSCap', 'option')),
			new AntiAliasing(LangUtil.getString('descAntialiasing', 'option')),
			new GPUTextures(LangUtil.getString('descGPUTextures', 'option')),
			#if FEATURE_CACHING
			new CharaCacheOption(LangUtil.getString('descCacheCharacter', 'option')),
			new SongCacheOption(LangUtil.getString('descCacheSong', 'option')),
			new CacheState(LangUtil.getString('descCache', 'option')),
			#end
		]),
		#end
		new OptionCategory(LangUtil.getString('catSave', 'option'), [
			#if FEATURE_LANGUAGE
			new LanguageSelection(LangUtil.getString('descLanguage', 'option')),
			#end
			#if FEATURE_OBS
			new SelfAwareness('...'),
			#end
			#if FEATURE_GAMEJOLT
			new GameJolt(LangUtil.getString('descGameJolt', 'option')),
			#end
			#if FEATURE_UNLOCK
			new UnlockAll("Unlocks everything that's offered in this game. Does not unlock costumes with requirements."),
			#end
			new ResetScore(LangUtil.getString('descScoreReset', 'option')),
			new ResetStory(LangUtil.getString('descStoryReset', 'option')),
			new ResetSave(LangUtil.getString('descSaveReset', 'option'))
		])
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<FlxText>;

	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;

	override function create()
	{
		instance = this;

		persistentUpdate = persistentDraw = true;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(120);
		}

		if (SaveData.beatEpiphany)
		{
			options.push(new OptionCategory(LangUtil.getString('catUnlock', 'option'), [
				new GFCountdownOption(LangUtil.getString('descGFCountdown', 'option')),
				// new VideoDub(LangUtil.getString('descVideoDub', 'option')),
				new BadEnd(LangUtil.getString('descBadEnd', 'option'))
			]));
		}
		else if (SaveData.beatSayori)
		{
			options.push(new OptionCategory(LangUtil.getString('catUnlock', 'option'), [
				new GFCountdownOption(LangUtil.getString('descGFCountdown', 'option'))
			]));
		}

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
		add(backdrop);

		logo = new FlxSprite(-60, 0).loadGraphic(Paths.image('Credits_LeftSide'));
		logo.antialiasing = SaveData.globalAntialiasing;
		add(logo);

		logoBl = new FlxSprite(40, -40);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = SaveData.globalAntialiasing;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);

		grpControls = new FlxTypedGroup<FlxText>();
		add(grpControls);

		generateOptions();

		currentDescription = LangUtil.getString('cmnCategory');

		versionShit = new FlxText(5, FlxG.height + 40, 0, LangUtil.getString('cmnOffset') + ': ${SaveData.offset} ms | ' + currentDescription, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(LangUtil.getFont(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.antialiasing = SaveData.globalAntialiasing;

		blackBorder = new FlxSprite(0, FlxG.height + 40).makeGraphic(FlxG.width, Std.int(versionShit.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);
		add(versionShit);

		FlxTween.tween(versionShit, {y: FlxG.height - 22 + LangUtil.getFontOffset()}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 22}, 2, {ease: FlxEase.elasticInOut});

		changeSelection();

		super.create();
	}

	var isCat:Bool = false;

	override function update(elapsed:Float)
	{
		if (acceptInput)
		{
			if (controls.BACK && !isCat)
			{
				acceptInput = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				SaveData.save();
				MusicBeatState.switchState(new MainMenuState());
			}
			else if (controls.BACK)
			{
				isCat = false;
				generateOptions();
				changeSelection(curSelected);
			}

			if (controls.UP_P)
				changeSelection(-1);

			if (controls.DOWN_P)
				changeSelection(1);

			changeValue(FlxG.keys.pressed.SHIFT ? controls.LEFT : controls.LEFT_P, FlxG.keys.pressed.SHIFT ? controls.RIGHT : controls.RIGHT_P);

			if (controls.RESET)
			{
				SaveData.offset = 0;
				changeSelection();
			}

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press())
					{
						grpControls.remove(grpControls.members[curSelected]);
						var ctrl:FlxText = new FlxText(460, (45 * curSelected) + 20, 0, currentSelectedCat.getOptions()[curSelected].getDisplay());
						ctrl.setFormat(LangUtil.getFont('riffic'), 36, FlxColor.WHITE, CENTER);
						ctrl.y += LangUtil.getFontOffset('riffic');

						if (ctrl.text == 'BAD ENDING')
							ctrl.setBorderStyle(OUTLINE, 0xFF444444, 2);
						else
							ctrl.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);

						ctrl.antialiasing = SaveData.globalAntialiasing;
						ctrl.ID = curSelected;
						grpControls.add(ctrl);
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					generateOptions();
				}

				changeSelection();
			}
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	function generateOptions()
	{
		var data:Array<Dynamic> = isCat ? currentSelectedCat.getOptions() : options;

		grpControls.clear();

		for (i in 0...data.length)
		{
			var name:String = isCat ? currentSelectedCat.getOptions()[i].getDisplay() : options[i].getName();

			var controlLabel:FlxText = new FlxText(460, (45 * i) + 20, 0, name);
			controlLabel.setFormat(LangUtil.getFont('riffic'), 36, FlxColor.WHITE, CENTER);
			controlLabel.y += LangUtil.getFontOffset('riffic');

			if (controlLabel.text == 'BAD ENDING')
				controlLabel.setBorderStyle(OUTLINE, 0xFF444444, 2);
			else
				controlLabel.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);

			controlLabel.antialiasing = SaveData.globalAntialiasing;
			controlLabel.ID = i;
			grpControls.add(controlLabel);
		}

		curSelected = 0;
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"));

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isCat)
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
		else
			currentDescription = LangUtil.getString('cmnCategory');

		if (isCat && currentSelectedCat.getOptions()[curSelected].getAccept())
			versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + ' | ' + currentDescription;
		else
			versionShit.text = LangUtil.getString('cmnOffset') + ': ${SaveData.offset} ms | ' + currentDescription;

		grpControls.forEach(function(txt:FlxText)
		{
			if (txt.text == 'BAD ENDING')
			{
				if (txt.ID == curSelected)
					txt.setBorderStyle(OUTLINE, 0xFFFF0513, 2);
				else
					txt.setBorderStyle(OUTLINE, 0xFF444444, 2);
			}
			else
			{
				if (txt.ID == curSelected)
					txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
				else
					txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			}
		});
	}

	function changeValue(left:Bool = false, right:Bool = false)
	{
		var changedValue = left || right;

		if (isCat && currentSelectedCat.getOptions()[curSelected].getAccept())
		{
			if (left)
				currentSelectedCat.getOptions()[curSelected].left();
			if (right)
				currentSelectedCat.getOptions()[curSelected].right();

			if (changedValue)
				versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + ' | ' + currentDescription;
		}
		else
		{
			if (left)
				SaveData.offset --;
			if (right)
				SaveData.offset ++;

			SaveData.offset = Std.int(SaveData.offset);

			if (changedValue)
				versionShit.text = LangUtil.getString('cmnOffset') + ': ${SaveData.offset} ms | ' + currentDescription;
		}
	}

	override function beatHit()
	{
		super.beatHit();
		logoBl.animation.play('bump', true);
	}
}
