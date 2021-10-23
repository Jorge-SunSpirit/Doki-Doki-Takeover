package;

import flixel.input.gamepad.FlxGamepad;
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
import lime.utils.Assets;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var backdrop:FlxBackdrop;
	var logo:FlxSprite;
	var logoBl:FlxSprite;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory(LangUtil.getString('catGameplay'), [
			new KeyBindingsOption(LangUtil.getString('descKeyBindings'), controls),
			new DownscrollOption(LangUtil.getString('descDownscroll')),
			new GhostTapOption(LangUtil.getString('descGhostTap')),
			new Judgement(LangUtil.getString('descJudgement')),
			#if desktop new FPSCapOption(LangUtil.getString('descFPSCap')),
			#end
			#if FEATURE_FILESYSTEM
			new ReplayOption(LangUtil.getString('descReplay')),
			#end
			new ScrollSpeedOption(LangUtil.getString('descScroll')),
			new AccuracyDOption(LangUtil.getString('descAccuracyMode')),
			new ResetButtonOption(LangUtil.getString('descReset')),
			new BotPlay(LangUtil.getString('descBotplay')),
			new CustomizeGameplay(LangUtil.getString('descCustomize'))
		]),
		new OptionCategory(LangUtil.getString('catAppearance'), [
			new FPSOption(LangUtil.getString('descFPSCount')), new RainbowFPSOption(LangUtil.getString('descFPSRainbow')),
			new DistractionsAndEffectsOption(LangUtil.getString('descDistract')), new FlashingLightsOption(LangUtil.getString('descFlashing')),
			new AccuracyOption(LangUtil.getString('descAccuracy')), new NPSDisplayOption(LangUtil.getString('descNPS')),
			new LaneUnderlayOption(LangUtil.getString('descLaneUnderway')), new MiddleScrollOption(LangUtil.getString('descMiddleScroll')),
			new SongPositionOption(LangUtil.getString('descPosition')), new WatermarkOption(LangUtil.getString('descWatermark'))]),
		#if FEATURE_CACHING
		new OptionCategory(LangUtil.getString('cmnCaching'), [
			new CharacterCaching(LangUtil.getString('descCharacterCache')),
			new SongCaching(LangUtil.getString('descSongCache')),
			new MusicCaching(LangUtil.getString('descMusicCache')),
			new SoundCaching(LangUtil.getString('descSoundCache')),
			new CachingState(LangUtil.getString('descCaching'))
		]),
		#end
		new OptionCategory(LangUtil.getString('catSave'), [new ResetSave(LangUtil.getString('descSaveReset'))])
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

		if (FlxG.save.data.sayobeaten)
		{
			options.push(new OptionCategory(LangUtil.getString('catUnlock'), [new GFCountdownOption(LangUtil.getString('descGFCountdown')),]));
		}

		add(backdrop = new FlxBackdrop(Paths.image('scrolling_BG')));
		backdrop.velocity.set(-40, -40);

		logo = new FlxSprite(-60, 0).loadGraphic(Paths.image('Credits_LeftSide'));
		logo.antialiasing = true;
		add(logo);

		logoBl = new FlxSprite(40, -41);
		logoBl.frames = Paths.getSparrowAtlas('DDLCStart_Screen_Assets');
		logoBl.antialiasing = true;
		logoBl.scale.set(0.5, 0.5);
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		add(logoBl);

		grpControls = new FlxTypedGroup<FlxText>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:FlxText = new FlxText(460, (50 * i) + 20, 0, options[i].getName());
			controlLabel.setFormat(LangUtil.getFont('riffic'), 38, FlxColor.WHITE, CENTER);
			controlLabel.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			controlLabel.ID = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "N/A";

		versionShit = new FlxText(5, FlxG.height
			+ 40, 0,
			LangUtil.getString('cmnOffset')
			+ ': '
			+ HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)
			+ ' - '
			+ LangUtil.getString('cmnDesc')
			+ ' - '
			+ currentDescription,
			12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(LangUtil.getFont(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height + 40).makeGraphic((Std.int(versionShit.width + 900)), Std.int(versionShit.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionShit);

		FlxTween.tween(versionShit, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

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
				FlxG.switchState(new MainMenuState());
			}
			else if (controls.BACK)
			{
				isCat = false;
				grpControls.clear();
				for (i in 0...options.length)
				{
					var controlLabel:FlxText = new FlxText(460, (50 * i) + 20, 0, options[i].getName());
					controlLabel.setFormat(LangUtil.getFont('riffic'), 38, FlxColor.WHITE, CENTER);
					controlLabel.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
					controlLabel.ID = i;
					grpControls.add(controlLabel);
					// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
				}

				curSelected = 0;

				changeSelection(curSelected);
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(1);
				}
			}

			if (FlxG.keys.justPressed.UP)
				changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN)
				changeSelection(1);

			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.pressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
							currentSelectedCat.getOptions()[curSelected].right();
						if (FlxG.keys.justPressed.LEFT)
							currentSelectedCat.getOptions()[curSelected].left();
					}
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.RIGHT)
							FlxG.save.data.offset += 0.1;
						else if (FlxG.keys.justPressed.LEFT)
							FlxG.save.data.offset -= 0.1;
					}
					else if (FlxG.keys.pressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.pressed.LEFT)
						FlxG.save.data.offset -= 0.1;

					versionShit.text = LangUtil.getString('cmnOffset') + ': ' + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + ' - '
						+ LangUtil.getString('cmnDesc') + ' - ' + currentDescription;
				}
				if (currentSelectedCat.getOptions()[curSelected].getAccept())
					versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + ' - ' + LangUtil.getString('cmnDesc') + ' - '
						+ currentDescription;
				else
					versionShit.text = LangUtil.getString('cmnOffset') + ': ' + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + ' - '
						+ LangUtil.getString('cmnDesc') + ' - ' + currentDescription;
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					else if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;

				versionShit.text = LangUtil.getString('cmnOffset') + ': ' + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + ' - '
					+ LangUtil.getString('cmnDesc') + ' - ' + currentDescription;
			}

			if (controls.RESET)
				FlxG.save.data.offset = 0;

			if (controls.ACCEPT)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press())
					{
						grpControls.remove(grpControls.members[curSelected]);
						var ctrl:FlxText = new FlxText(460, (50 * curSelected) + 20, 0, currentSelectedCat.getOptions()[curSelected].getDisplay());
						ctrl.setFormat(LangUtil.getFont('riffic'), 38, FlxColor.WHITE, CENTER);
						ctrl.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
						ctrl.ID = curSelected;
						grpControls.add(ctrl);
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					isCat = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
					{
						var controlLabel:FlxText = new FlxText(460, (50 * i) + 20, 0, currentSelectedCat.getOptions()[i].getDisplay());
						controlLabel.setFormat(LangUtil.getFont('riffic'), 38, FlxColor.WHITE, CENTER);
						controlLabel.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
						controlLabel.ID = i;
						grpControls.add(controlLabel);
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					}
					curSelected = 0;
				}

				changeSelection();
			}
		}

		FlxG.save.flush();

		grpControls.forEach(function(txt:FlxText)
		{
			txt.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);

			if (txt.ID == curSelected)
				txt.setBorderStyle(OUTLINE, 0xFFFFCFFF, 2);
		});

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	var isSettingControl:Bool = false;

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
		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
				versionShit.text = currentSelectedCat.getOptions()[curSelected].getValue() + ' - ' + LangUtil.getString('cmnDesc') + ' - ' + currentDescription;
			else
				versionShit.text = LangUtil.getString('cmnOffset') + ': ' + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + ' - '
					+ LangUtil.getString('cmnDesc') + ' - ' + currentDescription;
		}
		else
			versionShit.text = LangUtil.getString('cmnOffset') + ': ' + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + ' - '
				+ LangUtil.getString('cmnDesc') + ' - ' + currentDescription;
	}

	override function beatHit()
	{
		super.beatHit();
		logoBl.animation.play('bump', true);
	}
}
