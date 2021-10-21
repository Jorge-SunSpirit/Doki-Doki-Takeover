package;

import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;

#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
#if FEATURE_FILESYSTEM
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var showCutscene:Bool = true;

	var midsongcutscene:Bool = false;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var yuriGoneCrazy:Bool = false;

	var doof:DialogueBox;
	var doof2:DialogueBox;
	var doof3:DialogueBox;
	var doof4:DialogueBox;
	var doof5:DialogueBox;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;
	
	#if FEATURE_DISCORD
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public static var spirit:Character;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;
	var isPixelUI:Bool = false;

	private var camZooming:Bool = false;
	private var camFocus:Bool = true;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	public static var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;


	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var iconSubtract:Int = 0;
	public var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	public var extra1:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	public var extra2:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	public var extra3:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];
	public var extra4:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var sparkleFG:FlxBackdrop;
	var sparkleBG:FlxBackdrop;
	var pinkOverlay:FlxSprite;
	var bakaOverlay:FlxSprite;
	var vignette:FlxSprite;
	var staticshock:FlxSprite;
	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;
	var oldspace:FlxSprite;
	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	var camend:FlxObject;

	var lights_front:FlxSprite;
	var deskfront:FlxSprite;
	var closet:FlxSprite;
	var clubroom:FlxSprite;
	var lights_back:FlxSprite;
	var banner:FlxSprite;

	var fgTrees:FlxSprite;
	var bgSky:FlxSprite;
	var bgSchool:FlxSprite;
	var bgStreet:FlxSprite;
	var bgTrees:FlxSprite;
	var treeLeaves:FlxSprite;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;
	var space:FlxBackdrop;
	var whiteflash:FlxSprite;
	var blackScreen:FlxSprite;
	var blackScreenBG:FlxSprite;

	var altAnim:String = "";
	var fc:Bool = true;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var camtween:FlxTween;
	var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;
	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;
	public static var cannotDie:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;
	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Float> = [];

	private var executeModchart = false;

	// API stuff
	
	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }


	override public function create()
	{
		instance = this;

		if (SONG.noteStyle != null)
			isPixelUI = SONG.noteStyle.startsWith('pixel');
		
		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		repPresses = 0;
		repReleases = 0;

		#if FEATURE_LUAMODCHART
		executeModchart = FileSystem.exists(Paths.lua(PlayState.SONG.song.toLowerCase()  + "/modchart"));
		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));
		#end
		#if !FEATURE_LUAMODCHART
		executeModchart = false; // FORCE disable for non cpp targets
		#end


		#if FEATURE_DISCORD
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				switch (curSong.toLowerCase())
				{
					case 'your reality':
						storyDifficultyText = "Your Reality";
					default:
						storyDifficultyText = "Normal";
				}
				
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			{	
				switch (storyWeek)
					{
						case 0:
							detailsText = "Story Mode: Monika Week -";
						case 1:
							detailsText = "Story Mode: Sayori Week -";
						case 2:
							detailsText = "Story Mode: Natsuki Week -";
						case 3:
							detailsText = "Story Mode: Yuri Week -";
						case 4:
							detailsText = "Story Mode: ??? -";
						case 5:
							detailsText = "Story Mode: ??? -";
						default:
							detailsText = "Story Mode: Week Monika -";
					}
			}
			else
			{
				detailsText = "Freeplay -";
			}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end


		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		camHUD.zoom = FlxG.save.data.zoom;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		
		whiteflash = new FlxSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		whiteflash.scrollFactor.set();

		blackScreen = new FlxSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackScreen.scrollFactor.set();

		pinkOverlay = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFFF281F2);
		pinkOverlay.alpha = 0.2;
		pinkOverlay.blend = SCREEN;
		pinkOverlay.scrollFactor.set();

		if (SONG.song.toLowerCase() == 'obsession' ||	SONG.song.toLowerCase() == 'my confession')
		{
			whiteflash.cameras = [camHUD];
			blackScreen.cameras = [camHUD];
		}

		blackScreenBG = new FlxSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackScreenBG.alpha = 0;
		blackScreenBG.scrollFactor.set();

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + FlxG.save.data.botplay);
	
		//dialogue shit
		switch (SONG.song.toLowerCase())
		{
			//week 1
		    case 'high school conflict':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/high school conflict/high-school-conflictDialogue', 'preload', true));
				extra3 = CoolUtil.coolTextFile(Paths.txt('data/high school conflict/high-school-conflictEndDialogue', 'preload', true)); 
			case 'bara no yume':
				extra1 = CoolUtil.coolTextFile(Paths.txt('data/bara no yume/bara no yume-Dialogue', 'preload', true));
				extra3 = CoolUtil.coolTextFile(Paths.txt('data/bara no yume/bara no yume-EndDialogue', 'preload', true)); 
			case 'your demise':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/your demise/your-demiseDialogue', 'preload', true));
				extra1 = CoolUtil.coolTextFile(Paths.txt('data/your demise/your-demiseEndDialogue', 'preload', true));
				extra3 = CoolUtil.coolTextFile(Paths.txt('data/your demise/FinalCutsceneDialouge', 'preload', true));
			//hidden week
			case 'erb':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/erb/TestDialogue', 'preload', true));
			
			//sayo week
			case 'rain clouds':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/rain clouds/IntroDialogue', 'preload', true));
			case 'my confession':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/my confession/IntroDialogue', 'preload', true));
				extra3 = CoolUtil.coolTextFile(Paths.txt('data/my confession/EndDialogue', 'preload', true));
			
			//nat week
			case 'baka':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/baka/IntroDialogue', 'preload', true));
				extra3 = CoolUtil.coolTextFile(Paths.txt('data/baka/EndDialogue', 'preload', true));
			case 'my sweets':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/my sweets/introdialogue', 'preload', true));
			
			//Yuri Week
			case 'deep breaths':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/deep breaths/IntroDialogue', 'preload', true));
			case 'obsession':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/obsession/IntroDialogue', 'preload', true));
				extra1 = CoolUtil.coolTextFile(Paths.txt('data/obsession/EndDialogue1', 'preload', true));
				extra4 = CoolUtil.coolTextFile(Paths.txt('data/obsession/EndDialogue2', 'preload', true));
				extra3 = CoolUtil.coolTextFile(Paths.txt('data/obsession/EndDialogue3', 'preload', true));

			//Monika returns?!
			case 'reconciliation':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/reconciliation/IntroDialogue', 'preload', true));
			
			//heck yeah it's the long awaited festival!
			case 'crucify (yuri mix)':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/crucify (yuri mix)/IntroDialogue', 'preload', true));
			case "it's complicated (sayori mix)":
				dialogue = CoolUtil.coolTextFile(Paths.txt("data/it's complicated (sayori mix)/IntroDialogue", 'preload', true));
			case 'glitcher (monika mix)':
				dialogue = CoolUtil.coolTextFile(Paths.txt('data/glitcher (monika mix)/IntroDialogue', 'preload', true));
				extra3 = CoolUtil.coolTextFile(Paths.txt('data/glitcher (monika mix)/EndDialogue', 'preload', true));
			case "beathoven (natsuki mix)":
				dialogue = CoolUtil.coolTextFile(Paths.txt("data/beathoven (natsuki mix)/IntroDialogue", 'preload', true));

			case "epiphany":
				if (showCutscene)
				{
					if (CoolUtil.isRecording())
						dialogue = CoolUtil.coolTextFile(Paths.txt("data/epiphany/IntroDialogue-OBS", 'preload', true));
					else
					{
						DialogueBox.isEpiphany = true;
						HealthIcon.isEpiphany = true;
						iconSubtract = 25;
						dialogue = CoolUtil.coolTextFile(Paths.txt("data/epiphany/IntroDialogue", 'preload', true));
					}
				}
				else
					dialogue = CoolUtil.coolTextFile(Paths.txt("data/epiphany/IntroDialogue", 'preload', true));
		}

		if (!showCutscene && SONG.song.toLowerCase() == 'epiphany' && HealthIcon.isEpiphany && FileSystem.exists(CoolUtil.pfpPath))
			iconSubtract = 25;

		trace(SONG.stage);

		switch(SONG.stage)
		{
			case 'school':
			{
					curStage = 'school';

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky','week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool','week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet','week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack','week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees','week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals','week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					if (SONG.song.toLowerCase() == "bara no yume" || SONG.song.toLowerCase() == "poems n thorns")
					{
						bgGirls = new BackgroundGirls(-600, 190);
						bgGirls.scrollFactor.set(0.9, 0.9);
			
						bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
						bgGirls.updateHitbox();

						if (FlxG.save.data.distractions)
							add(bgGirls);
					}
			}
			case 'schoolEvil':
			{
					curStage = 'schoolEvil';
					defaultCamZoom = 0.9;

					var posX = 50;
					var posY = 200;

					var spaceBG:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF220707);
					add(spaceBG);
					spaceBG.scrollFactor.set();

					//finalebgmybeloved
					oldspace = new FlxSprite(posX, posY).loadGraphic(Paths.image('finalebgmybeloved'));
					oldspace.antialiasing = false;
					oldspace.scale.set(1.65, 1.65);
					oldspace.scrollFactor.set(0.1, 0.1);
					oldspace.alpha = 0;
					add(oldspace);

					space = new FlxBackdrop(Paths.image('FinaleBG_1','monika'), 0.1, 0.1);
					space.velocity.set(-10, 0);
					space.scale.set(1.65, 1.65);
					add(space);

					var bg:FlxSprite = new FlxSprite(70, posY).loadGraphic(Paths.image('FinaleBG_2','monika'));
					bg.antialiasing = false;
					bg.scale.set(2.3, 2.3);
					bg.scrollFactor.set(0.4, 0.6);
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('FinaleFG','monika'));
					stageFront.antialiasing = false;
					stageFront.scale.set(1.5, 1.5);
					stageFront.scrollFactor.set(1, 1);
					add(stageFront);
			}
			case 'dokiclubroom':
				{
					defaultCamZoom = 0.75;
					curStage = 'dokiclubroom';

					var posX = -700;
					var posY = -520;
					
					vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('vignette','doki'));
					vignette.antialiasing = true;
					vignette.scrollFactor.set();
					vignette.alpha = 0;

					if (SONG.song.toLowerCase() != 'obsession')
					{
						vignette.cameras = [camHUD];
						vignette.setGraphicSize(Std.int(vignette.width / FlxG.save.data.zoom));
						vignette.updateHitbox();
						vignette.screenCenter(XY);
					}

					// antialiasing doesn't work on backdrops *sniffles*
					sparkleBG = new FlxBackdrop(Paths.image('clubroom/YuriSparkleBG', 'doki'), 0.1, 0, true, false);
					sparkleBG.velocity.set(-16, 0);
					sparkleBG.visible = false;
					sparkleBG.setGraphicSize(Std.int(sparkleBG.width / defaultCamZoom));
					sparkleBG.updateHitbox();
					sparkleBG.screenCenter(XY);

					sparkleFG = new FlxBackdrop(Paths.image('clubroom/YuriSparkleFG', 'doki'), 0.1, 0, true, false);
					sparkleFG.velocity.set(-48, 0);
					sparkleFG.setGraphicSize(Std.int((sparkleFG.width * 1.2) / defaultCamZoom));
					sparkleFG.updateHitbox();
					sparkleFG.screenCenter(XY);

					bakaOverlay = new FlxSprite(0, 0);
					bakaOverlay.frames = Paths.getSparrowAtlas('clubroom/BakaBGDoodles', 'doki');
					bakaOverlay.antialiasing = true;
					bakaOverlay.animation.addByPrefix('normal', 'Normal Overlay', 24, true);
					bakaOverlay.animation.addByPrefix('party rock is', 'Rock Overlay', 24, true);
					bakaOverlay.animation.play('normal');
					bakaOverlay.scrollFactor.set();
					bakaOverlay.visible = false;
					bakaOverlay.cameras = [camHUD];
					bakaOverlay.setGraphicSize(Std.int(FlxG.width / FlxG.save.data.zoom));
					bakaOverlay.updateHitbox();
					bakaOverlay.screenCenter(XY);

					if (FlxG.save.data.distractions)
						add(bakaOverlay);

					staticshock = new FlxSprite(0, 0);
					staticshock.frames = Paths.getSparrowAtlas('clubroom/staticshock','doki');
					staticshock.antialiasing = true;
					staticshock.animation.addByPrefix('idle', 'hueh', 24, true);
					staticshock.animation.play('idle');
					staticshock.scrollFactor.set();
					staticshock.alpha = .6;
					staticshock.blend = SUBTRACT;
					staticshock.visible = false;
					staticshock.cameras = [camHUD];
					staticshock.setGraphicSize(Std.int(staticshock.width / FlxG.save.data.zoom));
					staticshock.updateHitbox();
					staticshock.screenCenter(XY);

					deskfront = new FlxSprite(posX, posY).loadGraphic(Paths.image('clubroom/DesksFront','doki'));
					deskfront.setGraphicSize(Std.int(deskfront.width * 1.6));
					deskfront.updateHitbox();
					deskfront.antialiasing = true;
					deskfront.scrollFactor.set(1.3, 0.9);

					var closet:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('clubroom/DDLCfarbg','doki'));
					closet.setGraphicSize(Std.int(closet.width * 1.6));
					closet.updateHitbox();
					closet.antialiasing = true;
					closet.scrollFactor.set(0.9, 0.9);
					add(closet);
	
					var clubroom:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('clubroom/DDLCbg','doki'));
					clubroom.setGraphicSize(Std.int(clubroom.width * 1.6));
					clubroom.updateHitbox();
					clubroom.antialiasing = true;
					clubroom.scrollFactor.set(1, 0.9);
					add(clubroom);

					add(sparkleBG);
				}
			
			case 'dokifestival':
				{
					var posX = -700;
					var posY = -520;
					
					vignette = new FlxSprite(posX, posY).loadGraphic(Paths.image('vignette','doki'));
					vignette.scrollFactor.set();
					vignette.x = 0;
					vignette.y = 0;
					vignette.cameras = [camHUD];
					vignette.alpha = 0;

					staticshock = new FlxSprite(posX, posY);
					staticshock.frames = Paths.getSparrowAtlas('clubroom/staticshock','doki');
					staticshock.animation.addByPrefix('idle', 'hueh', 24, true);
					staticshock.animation.play('idle');
					staticshock.scrollFactor.set();
					staticshock.x = 0;
					staticshock.y = 0;
					staticshock.cameras = [camHUD];
					staticshock.alpha = .6;
					staticshock.blend = SUBTRACT;
					staticshock.visible = false;

					defaultCamZoom = 0.75;
					curStage = 'dokifestival';

					lights_front = new FlxSprite(-605, 565);
					lights_front.frames = Paths.getSparrowAtlas('festival/lights_front','doki');
					lights_front.animation.addByPrefix('idle', 'Lights front', 24, true);
					lights_front.animation.play('idle');
					lights_front.setGraphicSize(Std.int(lights_front.width * 1.6));
					lights_front.antialiasing = true;
					lights_front.scrollFactor.set(1.1, 0.9);

					deskfront = new FlxSprite(posX, posY).loadGraphic(Paths.image('festival/DesksFestival','doki'));
					deskfront.setGraphicSize(Std.int(deskfront.width * 1.6));
					deskfront.updateHitbox();
					deskfront.antialiasing = true;
					deskfront.scrollFactor.set(1.3, 0.9);

					var closet:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('festival/FarBack','doki'));
					closet.setGraphicSize(Std.int(closet.width * 1.6));
					closet.updateHitbox();
					closet.antialiasing = true;
					closet.scrollFactor.set(0.9, 0.9);
					add(closet);
	
					var clubroom:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('festival/MainBG','doki'));
					clubroom.setGraphicSize(Std.int(clubroom.width * 1.6));
					clubroom.updateHitbox();
					clubroom.antialiasing = true;
					clubroom.scrollFactor.set(1, 0.9);
					add(clubroom);

					var lights_back:FlxSprite = new FlxSprite(390, 179);
					lights_back.frames = Paths.getSparrowAtlas('festival/lights_back','doki');
					lights_back.animation.addByPrefix('idle', 'lights back', 24, true);
					lights_back.setGraphicSize(Std.int(lights_back.width * 1.6));
					lights_back.animation.play('idle');
					lights_back.antialiasing = true;
					lights_back.scrollFactor.set(1, 0.9);
					add(lights_back);

					var banner:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('festival/FestivalBanner','doki'));
					banner.setGraphicSize(Std.int(banner.width * 1.6));
					banner.updateHitbox();
					banner.antialiasing = true;
					banner.scrollFactor.set(1, 0.9);
					add(banner);

				}
			
			case 'dokiglitcher':
				{
					var posX = -700;
					var posY = -520;
					
					defaultCamZoom = 0.75;
					curStage = 'dokiglitcher';

					lights_front = new FlxSprite(-605, 565);
					lights_front.frames = Paths.getSparrowAtlas('festival/lights_front','doki');
					lights_front.animation.addByPrefix('idle', 'Lights front', 24, true);
					lights_front.animation.play('idle');
					lights_front.setGraphicSize(Std.int(lights_front.width * 1.6));
					lights_front.antialiasing = true;
					lights_front.scrollFactor.set(1.1, 0.9);

					deskfront = new FlxSprite(posX, posY).loadGraphic(Paths.image('festival/DesksFestival','doki'));
					deskfront.setGraphicSize(Std.int(deskfront.width * 1.6));
					deskfront.updateHitbox();
					deskfront.antialiasing = true;
					deskfront.scrollFactor.set(1.3, 0.9);

					closet = new FlxSprite(posX, posY).loadGraphic(Paths.image('festival/FarBack','doki'));
					closet.setGraphicSize(Std.int(closet.width * 1.6));
					closet.updateHitbox();
					closet.antialiasing = true;
					closet.scrollFactor.set(0.9, 0.9);
					add(closet);
	
					clubroom = new FlxSprite(posX, posY).loadGraphic(Paths.image('festival/MainBG','doki'));
					clubroom.setGraphicSize(Std.int(clubroom.width * 1.6));
					clubroom.updateHitbox();
					clubroom.antialiasing = true;
					clubroom.scrollFactor.set(1, 0.9);
					add(clubroom);

					lights_back = new FlxSprite(390, 179);
					lights_back.frames = Paths.getSparrowAtlas('festival/lights_back','doki');
					lights_back.animation.addByPrefix('idle', 'lights back', 24, true);
					lights_back.setGraphicSize(Std.int(lights_back.width * 1.6));
					lights_back.animation.play('idle');
					lights_back.antialiasing = true;
					lights_back.scrollFactor.set(1, 0.9);
					add(lights_back);

					banner = new FlxSprite(posX, posY).loadGraphic(Paths.image('festival/FestivalBanner','doki'));
					banner.setGraphicSize(Std.int(banner.width * 1.6));
					banner.updateHitbox();
					banner.antialiasing = true;
					banner.scrollFactor.set(1, 0.9);
					add(banner);

					//school stuff :(
					
						var repositionShitx = -428;
						var repositionShity = -155;
	
						bgSky = new FlxSprite(repositionShitx, repositionShity + 0).loadGraphic(Paths.image('weeb/weebSky','week6'));
						bgSky.scrollFactor.set(0.1, 0.1);
						add(bgSky);
	
						bgSchool = new FlxSprite(repositionShitx, repositionShity + 0).loadGraphic(Paths.image('weeb/weebSchool','week6'));
						bgSchool.scrollFactor.set(0.6, 0.90);
						add(bgSchool);
	
						bgStreet = new FlxSprite(repositionShitx, repositionShity).loadGraphic(Paths.image('weeb/weebStreet','week6'));
						bgStreet.scrollFactor.set(0.95, 0.95);
						add(bgStreet);
	
						fgTrees = new FlxSprite(repositionShitx + 170, repositionShity + 130).loadGraphic(Paths.image('weeb/weebTreesBack','week6'));
						fgTrees.scrollFactor.set(0.9, 0.9);
						add(fgTrees);
	
						bgTrees = new FlxSprite(repositionShitx - 380, repositionShity + -800);
						var treetex = Paths.getPackerAtlas('weeb/weebTrees','week6');
						bgTrees.frames = treetex;
						bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
						bgTrees.animation.play('treeLoop');
						bgTrees.scrollFactor.set(0.85, 0.85);
						add(bgTrees);
	
						treeLeaves = new FlxSprite(repositionShitx, repositionShity + -40);
						treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals','week6');
						treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
						treeLeaves.animation.play('leaves');
						treeLeaves.scrollFactor.set(0.85, 0.85);
						add(treeLeaves);
	
						var widShit = Std.int(bgSky.width * 7);
	
						bgSky.setGraphicSize(widShit);
						bgSchool.setGraphicSize(widShit);
						bgStreet.setGraphicSize(widShit);
						bgTrees.setGraphicSize(Std.int(widShit * 1.4));
						fgTrees.setGraphicSize(Std.int(widShit * 0.8));
						treeLeaves.setGraphicSize(widShit);
	
						fgTrees.updateHitbox();
						bgSky.updateHitbox();
						bgSchool.updateHitbox();
						bgStreet.updateHitbox();
						bgTrees.updateHitbox();
						treeLeaves.updateHitbox();

						fgTrees.visible = false;
						bgSky.visible = false;
						bgSchool.visible = false;
						bgStreet.visible = false;
						bgTrees.visible = false;
						treeLeaves.visible = false;

						lights_front.visible = true;
						deskfront.visible = true;
						closet.visible = true;
						clubroom.visible = true;
						lights_back.visible = true;
						banner.visible = true;
	

				}
			case 'clubroomevil':
				{
						curStage = 'clubroomevil';

						defaultCamZoom = 0.8;
						var scale = 1;
						var posX = -250;
						var posY = -167;

						space = new FlxBackdrop(Paths.image('bigmonika/Sky', 'doki'), 0.1, 0.1);
						space.velocity.set(-10, 0);
						//space.scale.set(1.65, 1.65);
						add(space);

						var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('bigmonika/BG', 'doki'));
						bg.antialiasing = true;
						//bg.scale.set(2.3, 2.3);
						bg.scrollFactor.set(0.4, 0.6);
						add(bg);

						var stageFront:FlxSprite = new FlxSprite(-332, -77).loadGraphic(Paths.image('bigmonika/FG', 'doki'));
						stageFront.antialiasing = true;
						//stageFront.scale.set(1.5, 1.5);
						stageFront.scrollFactor.set(1, 1);
						add(stageFront);
				}
			default:
			{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					add(stageCurtains);
			}
		}
		var gfVersion:String = 'gf';



		switch (SONG.gfVersion)
		{
			case 'gf-car':
				gfVersion = 'gf-car';
			case 'gf-christmas':
				gfVersion = 'gf-christmas';
			case 'gf-pixel':
				gfVersion = 'gf-pixel';
			case 'gf-doki':
				gfVersion = 'gf-doki';
			case 'nogf-pixel':
				gfVersion = 'nogf-pixel';
			case 'gf-realdoki':
				gfVersion = 'gf-realdoki';
			default:
				gfVersion = 'gf';
		}

		#if !FEATURE_CACHING
		if (SONG.song.toLowerCase().startsWith('glitcher') && FlxG.save.data.distractions)
		#else
		if (SONG.song.toLowerCase().startsWith('glitcher') && FlxG.save.data.distractions && !FlxG.save.data.cacheCharacters)
		#end
		{
			trace('preloading pixel characters since caching is disabled');
			dad = new Character(100, 100, 'monika');
			boyfriend = new Boyfriend(770, 450, 'bf-pixel');
			gf = new Character(400, 130, 'gf-pixel');
			remove(boyfriend);
			remove(dad);
			remove(gf);
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		if (SONG.song.toLowerCase() == 'dual demise')
			spirit = new Character(100, 100, 'spirit');

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case 'dad':
				camPos.x += 400;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'monika':
				dad.x += 150;
				dad.y += 360;
				if (SONG.song.toLowerCase() == 'glitcher (monika mix)')
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y + 200);
				else
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'duet':
				dad.x += 150;
				dad.y += 380;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'monika-angry':
				dad.x += 15;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'natsuki':
				camPos.x += 400;
				dad.y += 175;
			case 'sayori':
				camPos.x += 400;
				dad.y += 110;
			case 'yuri':
				camPos.x += 400;
				dad.y += 80;
			case 'yuri-crazy':
				camPos.x += 400;
				dad.y += 80;
			case 'monika-real':
				camPos.x += 400;
				dad.y += 60;
			case 'bigmonika':
				dad.x += 0;
				dad.y += 0;
				camPos.set(dad.getGraphicMidpoint().x - 100, dad.getGraphicMidpoint().y - 200);
			}


		
		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;
				if(FlxG.save.data.distractions){
					resetFastCar();
					add(fastCar);
				}

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				if (spirit != null)
				{
					spirit.x = -150;
					spirit.y = 250;
				}
				dad.y -= 69;
				dad.x += 300;
				boyfriend.x += 200;
				boyfriend.y += 260;
				gf.x += 180;
				gf.y += 1000;
			case 'dokifestival' | 'dokiglitcher' | 'dokiclubroom':
				{
					dad.y -= 0;
					dad.x += 0;
					boyfriend.x += 0;
					boyfriend.y += 0;
					gf.x += 0;
					gf.y += 0;	
				}
			case 'clubroomevil':
				dad.x = 16;
				dad.y = -139; 
				boyfriend.x = 16;
				boyfriend.y = -139; 
				gf.y = 2000;

		}

		add(gf);

		// <3 layering
		if (SONG.song.toLowerCase() == 'obsession')
			add(blackScreenBG);

		add(dad);
		add(boyfriend);

		if (SONG.song.toLowerCase() == "dual demise")
			{
				trace('am I here? Probably');
				var evilTrail = new FlxTrail(spirit, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
				add(spirit);
			}

		// Shitty layering but whatev it works LOL
		//thanks ninja muffin :)
			if (curStage == 'dokiclubroom' || curStage == 'dokifestival'|| curStage == 'dokiglitcher')
				{
					add(deskfront);
					if (curStage == 'dokifestival' || curStage == 'dokiglitcher')
						{
							boyfriend.color = 0x828282;
							dad.color = 0x828282;
							gf.color = 0x828282;
							add(lights_front);
						}
				}

		
		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses',repPresses);
			FlxG.watch.addQuick('rep releases',repReleases);
			
			FlxG.save.data.botplay = true;
			FlxG.save.data.scrollSpeed = rep.replay.noteSpeed;
			FlxG.save.data.downscroll = rep.replay.isDownscroll;
			// FlxG.watch.addQuick('Queued',inputsQueued);
		}

		doof = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		doof2 = new DialogueBox(false, extra1);
		doof2.scrollFactor.set();
		doof2.finishThing = postdialoguecutscene;

		//DOOF3 is used for pixel dialogue
		doof3 = new DialogueBox(true, extra3);
		doof3.scrollFactor.set();
		doof3.finishThing = endSong;

		doof4 = new DialogueBox(false, extra3);
		doof4.scrollFactor.set();
		doof4.finishThing = endSong;

		//DOOF5 is post dialogue cutscene except Pixel
		doof5 = new DialogueBox(true, extra4);
		doof5.scrollFactor.set();
		doof5.finishThing = obsessionending;


		Conductor.songPosition = -5000;
		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		laneunderlayOpponent = new FlxSprite(70, 0).makeGraphic(500, FlxG.height * 2, FlxColor.BLACK);
		laneunderlayOpponent.alpha = 1 - FlxG.save.data.laneTransparency;
		laneunderlayOpponent.scrollFactor.set();
		laneunderlayOpponent.screenCenter(Y);
		laneunderlayOpponent.visible = false;

		laneunderlay = new FlxSprite(70 + (FlxG.width / 2), 0).makeGraphic(500, FlxG.height * 2, FlxColor.BLACK);
		laneunderlay.alpha = 1 - FlxG.save.data.laneTransparency;
		laneunderlay.scrollFactor.set();
		laneunderlay.screenCenter(Y);
		laneunderlay.visible = false;

		if (FlxG.save.data.laneUnderlay)
		{
			add(laneunderlayOpponent);
			add(laneunderlay);
		}

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
			{
				songPosBG = new FlxSprite(0, 10).makeGraphic(600, 20, FlxColor.BLACK);
				if (FlxG.save.data.downscroll)
					songPosBG.y = FlxG.height * 0.9 + 45; 
				songPosBG.screenCenter(X);
				songPosBG.scrollFactor.set();
				songPosBG.cameras = [camHUD];
				add(songPosBG);
				
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, 90000);
				songPosBar.scrollFactor.set();
				songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
				songPosBar.cameras = [camHUD];
				add(songPosBar);
	
				var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
				if (FlxG.save.data.downscroll)
					songName.y -= 3;
				songName.screenCenter(X);
				songName.setFormat(LangUtil.getFont(), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				songName.scrollFactor.set();
				songName.antialiasing = !isPixelUI;
				songName.cameras = [camHUD];
				add(songName);
			}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).makeGraphic(600, 20, FlxColor.BLACK);
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50,0,SONG.song + " " + (storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy") + (Main.watermarks ? " - KE " + MainMenuState.kadeEngineVer : ""), 16);
		kadeEngineWatermark.setFormat(LangUtil.getFont(), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		//add(kadeEngineWatermark);

		if (FlxG.save.data.downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(0, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.setFormat(LangUtil.getFont(), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.antialiasing = !isPixelUI;

		replayTxt = new FlxText(0, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(LangUtil.getFont(), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		replayTxt.antialiasing = !isPixelUI;
		replayTxt.screenCenter(X);
		if (loadRep) add(replayTxt);

		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(0, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "BOTPLAY", 20);
		botPlayState.setFormat(LangUtil.getFont(), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.antialiasing = !isPixelUI;
		botPlayState.screenCenter(X);
		if (FlxG.save.data.botplay && !loadRep) add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP1.y += iconSubtract;

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		// layering due to 'player' icon
		add(scoreTxt);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		replayTxt.cameras = [camHUD];
		botPlayState.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		doof.cameras = [camHUD];
		doof2.cameras = [camHUD];
		doof3.cameras = [camHUD];
		doof4.cameras = [camHUD];
		doof5.cameras = [camHUD];
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];

		if (curStage == 'dokiclubroom' || curStage == 'dokifestival')
			add(staticshock);

		startingSong = true;
		
		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				//setting up intro dialogue for songs
				case 'high school conflict':
					introcutscene(doof);
				case 'bara no yume':
					introcutscene(doof2);
				case 'your demise':
					if (showCutscene)
						introcutscene(doof);
					else
						DarkStart(doof);
				case 'erb':
					introcutscene(doof);
				
				//addin stuff for dokis
				case 'baka':
					introcutscene(doof);
				case 'my sweets':
					introcutscene(doof);
				
				case 'rain clouds':
					introcutscene(doof);
				case 'my confession':
					introcutscene(doof);

				
				case 'deep breaths':
					introcutscene(doof);
				case 'obsession':
					introcutscene(doof);
				
				case 'reconciliation':
					introcutscene(doof);

				case 'beathoven (natsuki mix)':
					introcutscene(doof);
				case 'crucify (yuri mix)':
					introcutscene(doof);
				case "it's complicated (sayori mix)":
					introcutscene(doof);
				case 'glitcher (monika mix)':
					introcutscene(doof);
				
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case 'dual demise':
					dualdemisecountdown();
				case 'your demise':
					DarkStart(doof);
				case 'epiphany':
					#if FEATURE_ICON
					iconP1.changeIcon('player');
					#end
					if (showCutscene)
						funnyephiphinya(doof);
					else
						epipdarkstart(doof);
				default:
					startCountdown();
			}
		}

		if (!loadRep)
			rep = new Replay("na");

		super.create();
	}
	
	function dualdemisecountdown(?dialogueBox:DialogueBox):Void
		{
			iconP2.changeIcon('dual-demise');
			startCountdown();
		}

	function DarkStart(?dialogueBox:DialogueBox):Void
		{
			add(whiteflash);
			add(blackScreen);
			remove(gf);
			startCountdown();
		}
	
	function epipdarkstart(?dialogueBox:DialogueBox):Void
		{
			remove(gf);
			remove(boyfriend);
			startCountdown();
		}

	function funnyephiphinya(?dialogueBox:DialogueBox):Void
		{
			remove(gf);
			remove(boyfriend);
			healthBar.visible = false;
			healthBarBG.visible = false;
			iconP1.visible = false;
			iconP2.visible = false;
			scoreTxt.visible = false;
			new FlxTimer().start(1.2, function(godlike:FlxTimer)
			{
				if (dialogueBox != null)
				{
					inCutscene = true;
					add(dialogueBox);
				}
				else
					startCountdown();
			});
		}
		
	function endcutscene(?dialogueBox:DialogueBox):Void
		{
			switch (curSong.toLowerCase())
			{
				case 'my confession' | 'baka':
					vocals.pause();
					FlxG.sound.music.pause();
					inCutscene = true;
					camZooming = false;
					startedCountdown = false;
					generatedMusic = false;
					canPause = false;
					vocals.stop();
					vocals.volume = 0;


					add(blackScreen);
					blackScreen.alpha = 0.1;
					FlxTween.tween(blackScreen, {alpha: 1}, 5, {ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween)
						{
							remove(strumLineNotes);
							remove(scoreTxt);
							remove(replayTxt);
							remove(botPlayState);
							remove(healthBarBG);
							remove(healthBar);
							remove(iconP1);
							remove(iconP2);
							remove(kadeEngineWatermark);
							remove(songPosBG);
							remove(songPosBar);
							remove(songName);
							remove(laneunderlayOpponent);
							remove(laneunderlay);
							
							//todo make this per song instead of all songs when images are done
							var imageBG:FlxSprite= new FlxSprite(0, 0);
							switch (curSong.toLowerCase())
								{
									case 'my confession':
										imageBG.loadGraphic(Paths.image('dialogue/bgs/ending1','doki'));
									case 'baka':
										imageBG.loadGraphic(Paths.image('dialogue/bgs/ending2','doki'));
								}
							imageBG.antialiasing = false;
							imageBG.scrollFactor.set();
							imageBG.cameras = [camHUD];
							imageBG.setGraphicSize(Std.int(imageBG.width / FlxG.save.data.zoom));
							imageBG.updateHitbox();
							imageBG.screenCenter(XY);
							add(imageBG);

							
							FlxTween.tween(blackScreen, {alpha: 0}, 5, {ease: FlxEase.expoOut,
							onComplete: function(twn:FlxTween)
								{
									if (dialogueBox != null)
										{
											camFollow.setPosition(dad.getMidpoint().x + 50, boyfriend.getMidpoint().y - 300);
											add(dialogueBox);
										}
									else
										{
											endSong();
										}
								}});
						}
					});
				default:
					vocals.pause();
					remove(strumLineNotes);
					remove(scoreTxt);
					remove(replayTxt);
					remove(botPlayState);
					remove(healthBarBG);
					remove(healthBar);
					remove(iconP1);
					remove(iconP2);
					remove(kadeEngineWatermark);
					remove(songPosBG);
					remove(songPosBar);
					remove(songName);
					remove(laneunderlayOpponent);
					remove(laneunderlay);
					FlxG.sound.music.pause();
					inCutscene = true;
					camZooming = false;
					startedCountdown = false;
					generatedMusic = false;
					canPause = false;
					vocals.stop();
					vocals.volume = 0;
					
					if (dialogueBox != null)
						{
							camFollow.setPosition(dad.getMidpoint().x + 50, boyfriend.getMidpoint().y - 300);
							add(dialogueBox);
						}
					else
						{
							endSong();
						}

			}	
			trace(inCutscene);
		}

		function obsessionending():Void
			{
				//Currently this is tupid and renders over the pixel dialogue box atm. Either me or M&M can fix this tomorrow 10/07/2021

				if (!loadRep)
					rep.SaveReplay(saveNotes);
				else
				{
					FlxG.save.data.botplay = false;
					FlxG.save.data.scrollSpeed = 1;
					FlxG.save.data.downscroll = false;
				}
				if (FlxG.save.data.fpsCap > 290)
					(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end
				if (SONG.validScore)
					{
						#if !switch
						Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
						#end
					}
				if (SONG.validScore)
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.flush();
				FlxG.save.data.yuribeaten = true;
				campaignScore += Math.round(songScore);
				
				//Do what ever idk
				remove(blackScreen);

				//Play animation for monika's magical girl transformation into HD here

				endcutscene(doof4);
			}
	
		function postdialoguecutscene():Void
			{
				switch(curSong.toLowerCase())
					{
						case "obsession":
							{
								var imageBG:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('dialogue/bgs/ending3','doki'));
								imageBG.antialiasing = true;
								imageBG.scrollFactor.set();
								imageBG.setGraphicSize(Std.int(imageBG.width / defaultCamZoom));
								imageBG.updateHitbox();
								imageBG.screenCenter(XY);
								add(imageBG);

								add(blackScreen);
								blackScreen.alpha = 1;

								FlxTween.tween(blackScreen, {alpha: 0}, 3, {ease: FlxEase.expoOut,
								onComplete: function(twn:FlxTween)
									{
										endcutscene(doof5);
									}});
							}
						case "your demise":
							{
								camZooming = false;
								inCutscene = true;
								startedCountdown = false;
								generatedMusic = false;
								canPause = false;
								FlxG.sound.music.pause();
								vocals.pause();
								vocals.stop();
								FlxG.sound.music.stop();
								remove(strumLineNotes);
								remove(scoreTxt);
								remove(replayTxt);
								remove(botPlayState);
								remove(healthBarBG);
								remove(healthBar);
								remove(iconP1);
								remove(iconP2);
								remove(kadeEngineWatermark);
								remove(songPosBG);
								remove(songPosBar);
								remove(songName);
								remove(laneunderlayOpponent);
								remove(laneunderlay);
								camHUD.visible = false;
								var endsceneone:FlxSprite = new FlxSprite();
								endsceneone.frames = Paths.getSparrowAtlas('cutscene/End1','monika');
								endsceneone.animation.addByPrefix('idle', 'Endscene', 24, false);
								endsceneone.setGraphicSize(Std.int(endsceneone.width * 1.12));
								endsceneone.scrollFactor.set();
								endsceneone.updateHitbox();
								endsceneone.screenCenter();
	
								var endscenetwo:FlxSprite = new FlxSprite();
								endscenetwo.frames = Paths.getSparrowAtlas('cutscene/monikasenpaistanding','monika');
								endscenetwo.animation.addByPrefix('idle', 'Endscenetwo', 24, false);
								endscenetwo.setGraphicSize(Std.int(endscenetwo.width * 1.12));
								endscenetwo.scrollFactor.set();
								endscenetwo.updateHitbox();
								endscenetwo.screenCenter();
	
								paused = true;
	
								FlxG.sound.playMusic(Paths.music('cutscene_jargon_shmargon'), 0);
								FlxG.sound.music.fadeIn(.5, 0, 0.8);
								FlxG.camera.fade(FlxColor.WHITE, 0, false);
								camHUD.visible = false;
								add(endsceneone);
								endsceneone.animation.play('idle');
								FlxG.camera.fade(FlxColor.WHITE, 1, true, function(){}, true);
	
								new FlxTimer().start(2.2, function(swagTimer:FlxTimer)
									{
										FlxG.sound.play(Paths.sound('dah'));
									});
	
								new FlxTimer().start(3.8, function(swagTimer:FlxTimer)
									{
										FlxG.camera.fade(FlxColor.BLACK, 2, false);
										new FlxTimer().start(2.2, function(swagTimer:FlxTimer)
											{
												remove(endsceneone);
												
												new FlxTimer().start(3, function(swagTimer:FlxTimer)
													{
														add(endscenetwo);
														endscenetwo.animation.play('idle');
														FlxG.camera.fade(FlxColor.BLACK, 3, true, function()
															{
																camHUD.visible = true;
																camFollow.setPosition(dad.getMidpoint().x + 100, boyfriend.getMidpoint().y - 250);
																endcutscene(doof4);
	
														}, true);
													});
											});
									});
							}
	
						case "bara no yume":
							dad.playAnim('cutscenetransition');
							new FlxTimer().start(1.2, function(godlike:FlxTimer)
							{
								dad.dance();
								startCountdown();
							});
					}
			}


			function introcutscene(?dialogueBox:DialogueBox):Void
				{
					var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					black.scrollFactor.set();


		
					switch (SONG.song.toLowerCase())
						{
							case "your demise":
								{
									remove(gf);
									add(whiteflash);
									add(blackScreen);
		
									new FlxTimer().start(1.2, function(godlike:FlxTimer)
										{
											if (dialogueBox != null)
												{
													inCutscene = true;
													add(dialogueBox);
												}
												else
													startCountdown();
										});
								}
		
							case "bara no yume":
								{
									FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
									dad.playAnim('cutsceneidle');
									remove(black);
		
									new FlxTimer().start(1.2, function(godlike:FlxTimer)
										{
											if (dialogueBox != null)
												{
													inCutscene = true;
													add(dialogueBox);
												}
												else
													startCountdown();
										});
								}
		
		
							case "high school conflict":
								{
									add(black);
									FlxG.sound.playMusic(Paths.music('Lunchbox', 'week6'), 0);
									FlxG.sound.music.fadeIn(1, 0, 0.8);
									new FlxTimer().start(0.3, function(tmr:FlxTimer)
										{
											black.alpha -= 0.1;
		
											if (black.alpha > 0)
											{
												tmr.reset(0.3);
											}
											else
											{
											if (dialogueBox != null)
												{
													inCutscene = true;
													add(dialogueBox);
												}
												else
													startCountdown();
											}	
										});
								}
							default:
								{
									remove(black);
									new FlxTimer().start(1.2, function(godlike:FlxTimer)
										{
											if (dialogueBox != null)
												{
													inCutscene = true;
													add(dialogueBox);
												}
												else
													startCountdown();
										});
								}
						}
						
				}
	

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];

	#if FEATURE_LUAMODCHART
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		midsongcutscene = true;
		
		showCutscene = false;
		inCutscene = false;

		if (curSong.toLowerCase() == 'epiphany')
		{
			healthBar.visible = true;
			healthBarBG.visible = true;
			iconP1.visible = true;
			iconP2.visible = true;
			scoreTxt.visible = true;
		}

		generateStaticArrows(0, SONG.noteStyle);
		generateStaticArrows(1, SONG.noteStyle);

		if (FlxG.save.data.middleScroll)
		{
			laneunderlayOpponent.alpha = 0;
			laneunderlay.screenCenter(X);
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start',[PlayState.SONG.song]);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (FlxG.save.data.gfCountdown && gf.curCharacter == 'gf-realdoki') {}
			else if (swagCounter % gfSpeed == 0)
				gf.dance();

			if (swagCounter % 2 == 0)
			{
				if (!boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance();
				dad.dance();
				if (curSong.toLowerCase() == 'dual demise')
					spirit.dance();
			}
			else if (dad.curCharacter == 'sayori')
				dad.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/demise-date'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			var glitchSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
					glitchSuffix = '-glitch';
				}
			}

			switch (swagCounter)

			{
				case 0:
					if (curStage.startsWith('schoolEvil'))
						FlxG.sound.play(Paths.sound('intro3' + glitchSuffix), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);

					if (FlxG.save.data.gfCountdown && gf.curCharacter == 'gf-realdoki')
						gf.playAnim('countdownThree');
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.cameras = [camHUD];
					
					if (!curStage.startsWith('school'))
					{
						ready.setGraphicSize(Std.int(ready.width * 0.7));
						ready.antialiasing = true;
					}
					else
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom * 0.7));
					
					ready.updateHitbox();
					ready.screenCenter();
					add(ready);

					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});

					if (curStage.startsWith('schoolEvil'))
						FlxG.sound.play(Paths.sound('intro2' + glitchSuffix), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);

					if (FlxG.save.data.gfCountdown && gf.curCharacter == 'gf-realdoki')
						gf.playAnim('countdownTwo');
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();
					set.cameras = [camHUD];

					if (!curStage.startsWith('school'))
					{
						set.setGraphicSize(Std.int(set.width * 0.7));
						set.antialiasing = true;
					}
					else
						set.setGraphicSize(Std.int(set.width * daPixelZoom * 0.7));

					set.updateHitbox();
					set.screenCenter();
					add(set);

					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});

					if (curStage.startsWith('schoolEvil'))
						FlxG.sound.play(Paths.sound('intro1' + glitchSuffix), 0.6);
					else
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);

					if (FlxG.save.data.gfCountdown && gf.curCharacter == 'gf-realdoki')
						gf.playAnim('countdownOne');
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();
					go.cameras = [camHUD];

					if (!curStage.startsWith('school'))
					{
						go.setGraphicSize(Std.int(go.width * 0.7));
						go.antialiasing = true;
					}
					else
						go.setGraphicSize(Std.int(go.width * daPixelZoom * 0.7));

					go.updateHitbox();
					go.screenCenter();
					add(go);

					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});

					if (curStage.startsWith('schoolEvil'))
						FlxG.sound.play(Paths.sound('introGo' + glitchSuffix), 0.6);
					else
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);

					if (FlxG.save.data.gfCountdown && gf.curCharacter == 'gf-realdoki')
						gf.playAnim('countdownGo');
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 4);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	var songStarted = false;

	function startSong():Void
	{
		midsongcutscene == true;
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		FlxG.sound.music.onComplete = songOutro;
		vocals.play();

		// have them all dance when the song starts
		gf.dance();
		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.dance();
		if (!dad.animation.curAnim.name.startsWith("sing"))
			dad.dance();
		if (curSong.toLowerCase() == 'dual demise' && !spirit.animation.curAnim.name.startsWith("sing"))
			spirit.dance();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		/*
		// Song check real quick
		switch(curSong)
		{
			case 'Bopeebo' | 'Philly' | 'Blammed' | 'Cocoa' | 'Eggnog': allowedToHeadbang = true;
			default: allowedToHeadbang = false;
		}
		*/
		
		#if FEATURE_DISCORD
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if FEATURE_FILESYSTEM
			var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';
			for(file in sys.FileSystem.readDirectory(songPath))
			{
				var path = haxe.io.Path.join([songPath, file]);
				if(!sys.FileSystem.isDirectory(path))
				{
					if(path.endsWith('.offset'))
					{
						trace('Found offset file: ' + path);
						songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
						break;
					}else {
						trace('Offset file not found. Creating one @: ' + songPath);
						sys.io.File.saveContent(songPath + songOffset + '.offset', '');
					}
				}
			}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var noteStyle:String = SONG.noteStyle;

			if (section.altAnim && curStage == "dokiglitcher" && FlxG.save.data.distractions)
				noteStyle = 'pixel';

			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				
				var daType = songNotes[3];
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, daType, noteStyle);
				swagNote.sustainLength = songNotes[2];
				
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, daType, noteStyle);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int, noteStyle:String, tweenIn:Bool = true):Void
	{
		if (FlxG.save.data.laneUnderlay)
		{
			laneunderlayOpponent.visible = true;
			laneunderlay.visible = true;
		}

		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (noteStyle)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode && tweenIn)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				if (!FlxG.save.data.middleScroll || executeModchart || player == 1)
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					if (FlxG.save.data.middleScroll)
						babyArrow.visible = false;
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			switch (noteStyle)
			{
				case 'pixel':
					babyArrow.x += 101;
				default:
					babyArrow.x += 98;
			}
			babyArrow.x += ((FlxG.width / 2) * player);

			if (FlxG.save.data.middleScroll && !executeModchart)
				babyArrow.x -= 320;
			
			cpuStrums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if FEATURE_DISCORD
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if FEATURE_DISCORD
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if FEATURE_DISCORD
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	override public function update(elapsed:Float)
	{

		#if !debug
		perfectMode = false;
		#end

		if (FlxG.save.data.botplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos',Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom',FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (i in luaWiggles)
			{
				trace('wiggle le gaming');
				i.update(elapsed);
			}

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle','float');

			if (luaModchart.getVar("showOnlyStrums",'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible",'bool');
			var p2 = luaModchart.getVar("strumLine2Visible",'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}

		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length-1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE && !HealthIcon.isEpiphany)
			iconP1.swapOldIcon();

		scoreTxt.screenCenter(X);

		if (FlxG.keys.pressed.O && FlxG.keys.pressed.P && curStage == 'schoolEvil')
		{
			oldspace.alpha = 1;
			remove(space);
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		if (FlxG.save.data.accuracyDisplay)
			scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);
		else
			scoreTxt.text = LangUtil.getString('cmnScore') + ':' + songScore;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.5))
			{
				FlxTransitionableState.skipNextTransOut = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}


		if (FlxG.keys.justPressed.SEVEN)
		{
			#if FEATURE_DISCORD
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width - (iconSubtract * 2), 0.5)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.5)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset + iconSubtract);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.O && curStage == 'dokiglitcher')
			gopixel();
		if (FlxG.keys.justPressed.P && curStage == 'dokiglitcher')
			becomefumo();

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// Go 10 seconds into the future, credit: Shadow Mario#9396
		if (FlxG.keys.justPressed.THREE && songStarted)
		{
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length) 
			{
				usedTimeTravel = true;
				if (!cannotDie)
					trace("TIME TRAVELLED! BOYFRIEND IS NOW IMMORTAL");
				cannotDie = true;

				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime - 500 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.25, function(tmr:FlxTimer)
				{
					usedTimeTravel = false;
				});
			}
		}

		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
			{
				FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			/*
			// Make sure Girlfriend cheers only for certain songs
			if(allowedToHeadbang)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if(gf.animation.curAnim.name == 'danceLeft' || gf.animation.curAnim.name == 'danceRight' || gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch(curSong)
					{
						case 'Philly':
						{
							// General duration of the song
							if(curBeat < 250)
							{
								// Beats to skip or to stop GF from cheering
								if(curBeat != 184 && curBeat != 216)
								{
									if(curBeat % 16 == 8)
									{
										// Just a garantee that it'll trigger just once
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Bopeebo':
						{
							// Where it starts || where it ends
							if(curBeat > 5 && curBeat < 130)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
						case 'Blammed':
						{
							if(curBeat > 30 && curBeat < 190)
							{
								if(curBeat < 90 || curBeat > 128)
								{
									if(curBeat % 4 == 2)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Cocoa':
						{
							if(curBeat < 170)
							{
								if(curBeat < 65 || curBeat > 130 && curBeat < 145)
								{
									if(curBeat % 16 == 15)
									{
										if(!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}else triggeredAlready = false;
								}
							}
						}
						case 'Eggnog':
						{
							if(curBeat > 10 && curBeat != 111 && curBeat < 220)
							{
								if(curBeat % 8 == 7)
								{
									if(!triggeredAlready)
									{
										gf.playAnim('cheer');
										triggeredAlready = true;
									}
								}else triggeredAlready = false;
							}
						}
					}
				}
			}
			*/
			
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.setVar("mustHit",PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (camFocus)
			{
				if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
					{
						var offsetX = 0;
						var offsetY = 0;
						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
						{
							offsetX = luaModchart.getVar("followXOffset", "float");
							offsetY = luaModchart.getVar("followYOffset", "float");
						}
						#end
		
						camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
		
						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							luaModchart.executeState('playerTwoTurn', []);
						#end
		
						switch (dad.curCharacter)
						{
							case 'mom':
								camFollow.y = dad.getMidpoint().y;
							case 'senpai' | 'senpai-angry' | 'monika':
								camFollow.y = dad.getMidpoint().y - 430;
								camFollow.x = dad.getMidpoint().x - 100;
							case 'duet':
								camFollow.y = dad.getMidpoint().y - 400;
								camFollow.x = dad.getMidpoint().x + 0;
							case 'monika-angry':
								if (SONG.song.toLowerCase() == 'dual demise' && SONG.notes[Math.floor(curStep / 16)].altAnim)
								{
									camFollow.y = spirit.getMidpoint().y;
									camFollow.x = spirit.getMidpoint().x + 250;
								}
								else
								{
									camFollow.y = dad.getMidpoint().y - 390;
									camFollow.x = dad.getMidpoint().x - 350;
								}
							case 'bigmonika':
								camFollow.y = dad.getMidpoint().y - 75;
								camFollow.x = dad.getMidpoint().x;
						}
					}
		
					if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
					{
						var offsetX = 0;
						var offsetY = 0;
						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
						{
							offsetX = luaModchart.getVar("followXOffset", "float");
							offsetY = luaModchart.getVar("followYOffset", "float");
						}
						#end
		
						camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
		
						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							luaModchart.executeState('playerOneTurn', []);
						#end
		
						switch (curStage)
						{
							case 'limo':
								camFollow.x = boyfriend.getMidpoint().x - 300;
							case 'mall':
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'school':
								switch (curSong.toLowerCase())
								{
									case "your reality":
										camFollow.x = boyfriend.getMidpoint().x - 500;
										camFollow.y = boyfriend.getMidpoint().y - 600;
									case "bara no yume":
										camFollow.x = boyfriend.getMidpoint().x - 300;
										camFollow.y = boyfriend.getMidpoint().y - 200;
									default:
										camFollow.x = boyfriend.getMidpoint().x - 200;
										camFollow.y = boyfriend.getMidpoint().y - 200;
								}
							case 'schoolEvil':
								camFollow.x = boyfriend.getMidpoint().x - 200;
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'dokiclubroom':
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'dokifestival':
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'dokiglitcher':
								if (boyfriend.curCharacter == 'bf-pixel')
								{
									camFollow.x = boyfriend.getMidpoint().x - 200;
									camFollow.y = boyfriend.getMidpoint().y - 200;
								}
								else
									camFollow.y = boyfriend.getMidpoint().y - 200;
						}
					}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// i thought this was cute
		if (curSong.toLowerCase() == 'rain clouds')
		{
			switch (curBeat)
			{
				case 0:
					gfSpeed = 2;
				case 16:
					gfSpeed = 1;
			}
		}

		if (health <= 0 && !cannotDie)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if FEATURE_DISCORD
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
 		if (FlxG.save.data.resetButton)
		{
			if (songStarted && FlxG.keys.justPressed.R)
				{
					boyfriend.stunned = true;

					persistentUpdate = false;
					persistentDraw = false;
					paused = true;
		
					vocals.stop();
					FlxG.sound.music.stop();
		
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
					#if FEATURE_DISCORD
					// Game Over doesn't get his own variable because it's only used here
					DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
					#end
		
					// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				}
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{	

					// instead of doing stupid y > FlxG.height
					// we be men and actually calculate the time :)
					if (daNote.tooLate)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
					
					if (!daNote.modifiedByLua)
					{
						if (FlxG.save.data.downscroll)
						{
							if (daNote.mustPress)
								daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
							else
								daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
							if(daNote.isSustainNote)
							{
								// Remember = minus makes notes go up, plus makes them go down
								if(daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
									daNote.y += daNote.prevNote.height;
								else
									daNote.y += daNote.height / 2;

								// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
								if(!FlxG.save.data.botplay)
								{
									if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
										swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.y = daNote.frameHeight - swagRect.height;

										daNote.clipRect = swagRect;
									}
								}else {
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}else
						{
							if (daNote.mustPress)
								daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
							else
								daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2));
							if(daNote.isSustainNote)
							{
								daNote.y -= daNote.height / 2;

								if(!FlxG.save.data.botplay)
								{
									if((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;

										daNote.clipRect = swagRect;
									}
								}else {
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
						}
					}
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;

						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								{
									switch (curSong.toLowerCase())
										{
											case "dual demise":
												{
													switch (Math.abs(daNote.noteData))
													{
														case 2:
															spirit.playAnim('singUP', true);
														case 3:
															spirit.playAnim('singRIGHT', true);
														case 4:
															spirit.playAnim('idle', true);
														case 1:
															spirit.playAnim('singDOWN', true);
														case 0:
															spirit.playAnim('singLEFT', true);
													}

													if (dad.animation.curAnim.name.startsWith('sing'))
														dad.dance();
												}
											default:
												altAnim = '-alt';
										}
								}
						}

						if (daNote.noteType == 1)
							{
								switch (curSong.toLowerCase())
									{
										case "dual demise":
												{
													switch (Math.abs(daNote.noteData))
													{
														case 2:
															spirit.playAnim('singUP', true);
														case 3:
															spirit.playAnim('singRIGHT', true);
														case 4:
															spirit.playAnim('idle', true);
														case 1:
															spirit.playAnim('singDOWN', true);
														case 0:
															spirit.playAnim('singLEFT', true);
													}

													if (dad.animation.curAnim.name.startsWith('sing'))
														dad.dance();
												}
										default:
											altAnim = '-alt';
									}
							}
						
						switch (daNote.noteType)
							{
								case 1:
									{
										if (curSong.toLowerCase() != "dual demise")
										{
											switch (Math.abs(daNote.noteData))
											{
												case 2:
													dad.playAnim('singUP' + altAnim, true);
												case 3:
													dad.playAnim('singRIGHT' + altAnim, true);
												case 4:
													dad.playAnim('idle' + altAnim, true);
												case 1:
													dad.playAnim('singDOWN' + altAnim, true);
												case 0:
													dad.playAnim('singLEFT' + altAnim, true);
											}
										}
									}
								case 2:
									{
										if (curSong.toLowerCase() == "obsession" && !yuriGoneCrazy)
										{
											switch (Math.abs(daNote.noteData))
											{
												case 2:
													dad.playAnim('singUP' + altAnim, true);
												case 3:
													dad.playAnim('singRIGHT' + altAnim, true);
												case 4:
													dad.playAnim('idle' + altAnim, true);
												case 1:
													dad.playAnim('singDOWN' + altAnim, true);
												case 0:
													dad.playAnim('singLEFT' + altAnim, true);
											}
										}
									}
								default:
									if (curSong.toLowerCase() != "dual demise" || (curSong.toLowerCase() == "dual demise" && !SONG.notes[Math.floor(curStep / 16)].altAnim))
										{
											switch (Math.abs(daNote.noteData))
											{
												case 2:
													dad.playAnim('singUP' + altAnim, true);
												case 3:
													dad.playAnim('singRIGHT' + altAnim, true);
												case 4:
													dad.playAnim('idle' + altAnim, true);
												case 1:
													dad.playAnim('singDOWN' + altAnim, true);
												case 0:
													dad.playAnim('singLEFT' + altAnim, true);
											}
										}
							}
								
						cpuStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
							if (spr.animation.curAnim.name == 'confirm' && !isPixelUI)
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
						});
	
						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						dad.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.active = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}

					if (daNote.mustPress && !daNote.modifiedByLua)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}

					if (!daNote.mustPress && FlxG.save.data.middleScroll && !executeModchart)
						daNote.alpha = 0;

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if ((daNote.mustPress && daNote.tooLate && !FlxG.save.data.downscroll || daNote.mustPress && daNote.tooLate && FlxG.save.data.downscroll) && daNote.mustPress)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
								{
									daNote.kill();
									notes.remove(daNote, true);
									daNote.destroy();
								}
						}
						else
						{
							if (daNote.noteType == 2)
								{
									vocals.volume = 1;
								}
							else
								{
									health -= 0.075;
									vocals.volume = 0;
									if (theFunne)
										noteMiss(daNote.noteData, daNote);
								}
						}
	
						daNote.active = false;
						daNote.visible = false;
	
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}

		cpuStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (!inCutscene)
			keyShit();


		#if debug
		if (FlxG.keys.justPressed.TWO)
			songOutro();
		#end
	}

	function songOutro():Void
		{
			midsongcutscene = false;
			FlxG.sound.music.volume = 0;
			vocals.volume = 0;
			canPause = false;

			if (isStoryMode)
			{
				switch (curSong.toLowerCase())
				{
					case 'high school conflict':
						endcutscene(doof4);
					case 'bara no yume':
						endcutscene(doof4);
					case 'your demise':
						endcutscene(doof2);
					case 'my confession':
						DialogueBox.isPixel = true;
						endcutscene(doof3);
					case 'baka':
						DialogueBox.isPixel = true;
						endcutscene(doof3);
					case 'obsession':
						FlxG.save.data.yuribeaten = true;
						remove(whiteflash);
						staticshock.visible = false;
						endcutscene(doof2);
					case 'glitcher (monika mix)':
						endcutscene(doof4);
					default:
						endSong();
				}
			}
			else
				{
					switch (curSong.toLowerCase())
					{
						default:
							endSong();
					}
				}
				
		}

	function endSong():Void
	{
		midsongcutscene = false;

		if (!loadRep)
			rep.SaveReplay(saveNotes);
		else
		{
			FlxG.save.data.botplay = false;
			FlxG.save.data.scrollSpeed = 1;
			FlxG.save.data.downscroll = false;
		}

		if (HealthIcon.isEpiphany)
			HealthIcon.isEpiphany = false;

		if (FlxG.save.data.fpsCap > 290)
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					switch (PlayState.storyWeek)
						{
							case 0:
							FlxG.save.data.monibeaten = true;
							case 1:
							FlxG.save.data.sayobeaten = true;
							case 2:
							FlxG.save.data.natbeaten = true;
							case 4:
							FlxG.save.data.extrabeaten = true;
							case 5:
								{
									FlxG.save.data.extra2beaten = true;
									if (storyDifficulty == 2)
										{
											FlxG.save.data.unlockepip = true;
										}
								}
						}

					DokiStoryState.showPopUp = true;
					DokiStoryState.popupWeek = PlayState.storyWeek;

					showCutscene = true;
					FlxG.switchState(new DokiStoryState());

					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

					FlxG.save.flush();
				}
				else
				{
					var difficulty:String = "";

					if (storyDifficulty == 0)
						difficulty = '-easy';

					if (storyDifficulty == 2)
						difficulty = '-hard';

					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);
					showCutscene = true;

					/*
					if (SONG.song.toLowerCase() == 'eggnog')
						{
							var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
								-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
							blackShit.scrollFactor.set();
							add(blackShit);
							camHUD.visible = false;
		
							FlxG.sound.play(Paths.sound('Lights_Shut_off'));
						}
					*/
					
					switch (SONG.song.toLowerCase())
					{
						case 'bara no yume':
							{
								FlxTransitionableState.skipNextTransIn = true;
								FlxTransitionableState.skipNextTransOut = true;
								prevCamFollow = camFollow;
								PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
								FlxG.sound.music.stop();
								camHUD.visible = false;
								var schoolFakeout:FlxSprite = new FlxSprite(400, 200);
								schoolFakeout.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool','week6');
								schoolFakeout.animation.addByPrefix('idle', 'background 2', 24);
								schoolFakeout.animation.play('idle');
								schoolFakeout.scrollFactor.set(0.8, 0.9);
								schoolFakeout.scale.set(6, 6);
								add(schoolFakeout);
								FlxG.sound.play(Paths.sound('awhellnaw'));	// THEY ON THAT SPUNCHBOB SHIT

								new FlxTimer().start(1.3, function(timer:FlxTimer) {
									#if FEATURE_WEBM
									trace('cutscene successful');
									LoadingState.loadAndSwitchState(new VideoState('assets/videos/monika/fakeout.webm', new PlayState()));
									trace('huh what is this?');
									#else
									LoadingState.loadAndSwitchState(new PlayState());
									#end
								});
							}
						default:
							{
								//use this as a template for endsong webm :)
								FlxTransitionableState.skipNextTransIn = true;
								FlxTransitionableState.skipNextTransOut = true;
								prevCamFollow = camFollow;

								PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
								FlxG.sound.music.stop();

								showCutscene = true;
								LoadingState.loadAndSwitchState(new PlayState());
							}
						
					}

					
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				showCutscene = true;
				FlxG.switchState(new DokiFreeplayState());
			}
		}
	}


	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	var pixelShitPart1:String = '';
	var pixelShitPart2:String = '';

	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
			//
	
			var rating:FlxSprite = new FlxSprite();
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			var daRating = daNote.rating;

			switch(daNote.noteType)
				{
					case 2:
						switch(daRating)
							{
								case 'shit' | 'bad' | 'good' | 'sick':
									if (curSong.toLowerCase() == 'epiphany')
										{
											if (FlxG.random.bool(5))
												GameOverSubstate.crashdeath = true;
										}
									health -= 100;
							}
					default:
						{
							switch(daRating)
								{
									case 'shit':
										score = -300;
										combo = 0;
										misses++;
										health -= 0.2;
										ss = false;
										shits++;
										if (FlxG.save.data.accuracyMod == 0)
											totalNotesHit -= 1;
									case 'bad':
										daRating = 'bad';
										score = 0;
										health -= 0.06;
										ss = false;
										bads++;
										if (FlxG.save.data.accuracyMod == 0)
											totalNotesHit += 0.50;
									case 'good':
										daRating = 'good';
										score = 200;
										ss = false;
										goods++;
										if (health < 2)
											health += 0.04;
										if (FlxG.save.data.accuracyMod == 0)
											totalNotesHit += 0.75;
									case 'sick':
										if (health < 2)
											health += 0.1;
										if (FlxG.save.data.accuracyMod == 0)
											totalNotesHit += 1;
										sicks++;
								}
						}
				}

			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad')
				{
	
	
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */
	
			if (isPixelUI)
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}
			else
			{
				pixelShitPart1 = '';
				pixelShitPart2 = '';
			}
	
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			
			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			
			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if(FlxG.save.data.botplay) msTiming = 0;							   

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;
			currentTimingShown.antialiasing = !isPixelUI;

			if (msTiming >= 0.03 && offsetTesting)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;
				

				
				offsetTest = HelperFunctions.truncateFloat(total / hits.length,2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!FlxG.save.data.botplay && FlxG.save.data.accuracyDisplay)
				add(currentTimingShown);
			
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if(!FlxG.save.data.botplay) add(rating);
	
			if (!isPixelUI)
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
	
			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!isPixelUI)
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				if (combo >= 10 || combo == 0)
					add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */
	
			coolText.text = Std.string(seperatedScore);
			// add(coolText);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
	
			curSection += 1;
			}
		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	

		private function keyShit():Void // I've invested in emma stocks
			{
				// control arrays, order L D R U
				var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
				var pressArray:Array<Bool> = [
					controls.LEFT_P,
					controls.DOWN_P,
					controls.UP_P,
					controls.RIGHT_P
				];
				var releaseArray:Array<Bool> = [
					controls.LEFT_R,
					controls.DOWN_R,
					controls.UP_R,
					controls.RIGHT_R
				];
		 
				// Prevent player input if botplay is on
				if (FlxG.save.data.botplay)
				{
					holdArray = [false, false, false, false];
					pressArray = [false, false, false, false];
					releaseArray = [false, false, false, false];
				} 
				// HOLDS, check for sustain notes
				if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
							goodNoteHit(daNote);
					});
				}
		 
				// PRESSES, check for note hits
				if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
				{
					boyfriend.holdTimer = 0;
		 
					var possibleNotes:Array<Note> = []; // notes that can be hit
					var directionList:Array<Int> = []; // directions that can be hit
					var dumbNotes:Array<Note> = []; // notes to kill later
		 
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						{
							if (directionList.contains(daNote.noteData))
							{
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
									{ // if it's the same note twice at < 10ms distance, just delete it
										// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
										dumbNotes.push(daNote);
										break;
									}
									else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
									{ // if daNote is earlier than existing note (coolNote), replace
										possibleNotes.remove(coolNote);
										possibleNotes.push(daNote);
										break;
									}
								}
							}
							else
							{
								possibleNotes.push(daNote);
								directionList.push(daNote.noteData);
							}
						}
					});
		 
					for (note in dumbNotes)
					{
						FlxG.log.add("killing dumb ass note at " + note.strumTime);
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
		 
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		 
					var dontCheck = false;

					for (i in 0...pressArray.length)
					{
						if (pressArray[i] && !directionList.contains(i))
							dontCheck = true;
					}

					if (perfectMode)
						goodNoteHit(possibleNotes[0]);
					else if (possibleNotes.length > 0 && !dontCheck)
					{
						if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								{ // if a direction is hit that shouldn't be
									if (pressArray[shit] && !directionList.contains(shit))
										noteMiss(shit, null);
								}
						}
						for (coolNote in possibleNotes)
						{
							if (pressArray[coolNote.noteData])
							{
								if (mashViolations != 0)
									mashViolations--;
								scoreTxt.color = FlxColor.WHITE;
								goodNoteHit(coolNote);
							}
						}
					}
					else if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								if (pressArray[shit])
									noteMiss(shit, null);
						}

					if (dontCheck && possibleNotes.length > 0 && FlxG.save.data.ghost && !FlxG.save.data.botplay)
					{
						if (mashViolations > 4)
						{
							trace('mash violations ' + mashViolations);
							scoreTxt.color = FlxColor.RED;
							noteMiss(0,null);
						}
						else
							mashViolations++;
					}

				}
				
				notes.forEachAlive(function(daNote:Note)
				{
					if (FlxG.save.data.downscroll && daNote.y > strumLine.y ||
					!FlxG.save.data.downscroll && daNote.y < strumLine.y)
					{
						// Force good note hit regardless if it's too late to hit it or not as a fail safe
						if( FlxG.save.data.botplay && daNote.canBeHit && daNote.mustPress ||
						FlxG.save.data.botplay && daNote.tooLate && daNote.mustPress)
						{
							if (loadRep)
							{
								//trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
								if (rep.replay.songNotes.contains(HelperFunctions.truncateFloat(daNote.strumTime, 2)))
								{
									if (daNote.noteType != 2)
									{
										goodNoteHit(daNote);
										boyfriend.holdTimer = daNote.sustainLength;
									}
									
								}
							}
							else
							{
								if (daNote.noteType != 2)
								{
									goodNoteHit(daNote);
									boyfriend.holdTimer = daNote.sustainLength;
								}
							}
						}
					}
				});
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 0.004 && (!holdArray.contains(true) || FlxG.save.data.botplay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance();
				}
		 
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!holdArray[spr.ID])
						spr.animation.play('static');
		 
					if (spr.animation.curAnim.name == 'confirm' && !isPixelUI)
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
			}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad') && !gf.animation.curAnim.name.startsWith('necksnap'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			//var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			//var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end


			updateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
	
			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	*/
	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			note.rating = Ratings.CalculateRating(noteDiff);

			/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
			} */
			
			if (controlArray[note.noteData])
			{
				goodNoteHit(note, (mashing > getKeyPresses(note)));
				
				/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false);*/

			}
		}

		function goodNoteHit(note:Note, resetMashViolation = true):Void
			{

				if (mashing != 0)
					mashing = 0;

				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				// add newest note to front of notesHitArray
				// the oldest notes are at the end and are removed first
				if (!note.isSustainNote)
					notesHitArray.unshift(Date.now());

				if (!resetMashViolation && mashViolations >= 1)
					mashViolations--;

				if (mashViolations < 0)
					mashViolations = 0;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						combo += 1;
						popUpScore(note);
					}
					else
						totalNotesHit += 1;
	

					switch (note.noteData)
					{
						case 2:
							boyfriend.playAnim('singUP', true);
						case 3:
							boyfriend.playAnim('singRIGHT', true);
						case 1:
							boyfriend.playAnim('singDOWN', true);
						case 0:
							boyfriend.playAnim('singLEFT', true);
					}
		
					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
						luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
					#end


					if(!loadRep && note.mustPress)
						saveNotes.push(HelperFunctions.truncateFloat(note.strumTime, 2));
					
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});
					
					note.wasGoodHit = true;
					vocals.volume = 1;
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
			}
		

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if(FlxG.save.data.distractions){
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if(FlxG.save.data.distractions){
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if(FlxG.save.data.distractions){
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if(FlxG.save.data.distractions){
			if (trainSound.time >= 4700)
				{
					startedMoving = true;
					gf.playAnim('hairBlow');
				}
		
				if (startedMoving)
				{
					phillyTrain.x -= 400;
		
					if (phillyTrain.x < -2000 && !trainFinishing)
					{
						phillyTrain.x = -1150;
						trainCars -= 1;
		
						if (trainCars <= 0)
							trainFinishing = true;
					}
		
					if (phillyTrain.x < -4000 && trainFinishing)
						trainReset();
				}
		}

	}

	function trainReset():Void
	{
		if(FlxG.save.data.distractions){
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep',curStep);
			luaModchart.executeState('stepHit',[curStep]);
		}
		#end

		if (midsongcutscene)
			{
				if (curSong.toLowerCase() == 'my confession')
					{
						switch (curStep)
						{
							case 480:
								camZooming = false;
								camFocus = false;
								camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y - 100);
								gf.playAnim('countdownThree');
								camtween = FlxTween.tween(FlxG.camera, {zoom: 1}, 1, {ease: FlxEase.expoOut});
							case 484:
								camtween.cancel();
								gf.playAnim('countdownTwo');
								camtween = FlxTween.tween(FlxG.camera, {zoom: 1.2}, 1, {ease: FlxEase.expoOut});
							case 488:
								camtween.cancel();
								gf.playAnim('countdownOne');
								camtween = FlxTween.tween(FlxG.camera, {zoom: 1.4}, 1, {ease: FlxEase.expoOut});
							case 492:
								camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
								camtween.cancel();
								gf.playAnim('countdownGo');
								camtween = FlxTween.tween(FlxG.camera, {zoom: 0.75}, 1, {ease: FlxEase.expoOut});
							case 496:
								gf.dance();
								camZooming = true;
								camFocus = true;
							
							case 752:
								camZooming = false;
								staticshock.visible = true;
								add(vignette);
								FlxTween.tween(FlxG.camera, {zoom: 2}, 1, {
									ease: FlxEase.expoOut
								});
								new FlxTimer().start(0, function(tmr:FlxTimer)
									{
										vignette.alpha += 1 / 5;
									}, 5);
								dad.playAnim('nara');
							
							case 768:
								staticshock.visible = false;
								FlxTween.tween(FlxG.camera, {zoom: 0.75}, 0.2, {
									ease: FlxEase.expoOut
								});
								new FlxTimer().start(0, function(tmr:FlxTimer)
									{
										vignette.alpha -= 1 / 5;
									}, 5);
							case 774:
								camZooming = true;

						}
					}

				if (curSong.toLowerCase() == 'deep breaths')
					{
						switch (curStep)
							{
								case 138:
									{
										dad.playAnim('breath');
									}
								case 148:
									FlxG.sound.play(Paths.sound('exhale'));
							}
					}
		
				if (curSong.toLowerCase() == 'your demise')
					{
						switch (curStep)
						{
							case 132:
								boyfriend.visible = true;
								dad.visible = true;
								remove(blackScreen);
		
								new FlxTimer().start(0.03, function(tmr:FlxTimer)
									{
										whiteflash.alpha -= 0.15;
										if (whiteflash.alpha > 0)
											tmr.reset(0.03);
										else
											remove(whiteflash);
									});
							
							case 889:
								FlxG.camera.fade(FlxColor.BLACK, 2, false);
						}
					}
				if (curSong.toLowerCase().startsWith('glitcher') && FlxG.save.data.distractions)
					{
						switch (curStep)
							{
								case 576 | 1087 | 1359 | 1391 | 1423 | 1455:
									gopixel();
								case 832 | 1343 | 1375 | 1407 | 1439 | 1471:
									becomefumo();
							}
					}
			}

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if FEATURE_DISCORD
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), "Acc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC,true,  songLength - Conductor.songPosition);
		#end

	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		#if FEATURE_LUAMODCHART
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat',curBeat);
			luaModchart.executeState('beatHit',[curBeat]);
		}
		#end

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM TO ' + SONG.notes[Math.floor(curStep / 16)].bpm);
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			if (curBeat % 2 == 0)
			{
				if (!boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.dance();
				if (!dad.animation.curAnim.name.startsWith('sing'))
					dad.dance(SONG.notes[Math.floor(curStep / 16)].altAnim);
				if (curSong.toLowerCase() == 'dual demise' && !spirit.animation.curAnim.name.startsWith('sing'))
					spirit.dance();
			}
			else if (dad.curCharacter == 'sayori' && !dad.animation.curAnim.name.startsWith('sing') && curBeat % gfSpeed == 0)
				dad.dance(SONG.notes[Math.floor(curStep / 16)].altAnim);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (curSong.toLowerCase() == 'my sweets' && curBeat >= 512 && curBeat < 640 && camZooming && FlxG.camera.zoom < 1.35)
		{
			trace('hey am i working');
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (!gf.animation.curAnim.name.startsWith('countdown') && !gf.animation.curAnim.name.startsWith('neck') && curBeat % gfSpeed == 0)
		{
			//when the code don't work https://i.imgur.com/wHYhTSC.png
			gf.dance();
		}

		if (midsongcutscene)
		{
			if (curSong.toLowerCase() == 'baka' && FlxG.save.data.distractions)
			{
				switch (curBeat)
				{
					case 16:
						bakaOverlay.visible = true;
						bakaOverlay.alpha = 0;
						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							bakaOverlay.alpha += 0.1;

							if (bakaOverlay.alpha < 1)
								tmr.reset(0.2);
						});
					case 32:
						bakaOverlay.animation.play('party rock is', true);
						defaultCamZoom = 1.2;
						camGame.shake(0.002, (Conductor.stepCrochet / 32));
					case 40:
						camFocus = false;
						camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
					case 48:
						camFocus = true;
						defaultCamZoom = 0.75;
					case 112 | 264:
						bakaOverlay.alpha = 1;
						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							bakaOverlay.alpha -= 0.1;

							if (bakaOverlay.alpha > 0)
								tmr.reset(0.2);
						});
					case 144:
						bakaOverlay.animation.play('normal', true);
						bakaOverlay.alpha = 0;
						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							bakaOverlay.alpha += 0.1;

							if (bakaOverlay.alpha < 1)
								tmr.reset(0.2);
						});
					case 176:
						bakaOverlay.animation.play('party rock is', true);
				}
			}

			if (curSong.toLowerCase() == 'deep breaths' && FlxG.save.data.distractions)
			{
				switch (curBeat)
				{
					case 104:
						sparkleBG.visible = true;
						add(sparkleFG);
						add(pinkOverlay);
					case 200:
						sparkleBG.alpha = 1;
						sparkleFG.alpha = 1;
						pinkOverlay.alpha = 0.2;
						new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							sparkleBG.alpha -= 0.1;
							sparkleFG.alpha -= 0.1;
							pinkOverlay.alpha -= 0.02;

							if (sparkleBG.alpha > 0 && sparkleFG.alpha > 0 && bakaOverlay.alpha > 0)
								tmr.reset(0.2);
						});
					case 232:
						sparkleBG.alpha = 1;
						sparkleFG.alpha = 1;
						pinkOverlay.alpha = 0.2;
					case 288:
						sparkleBG.alpha = 1;
						sparkleFG.alpha = 1;
						pinkOverlay.alpha = 0.2;
						new FlxTimer().start(0.35, function(tmr:FlxTimer)
						{
							sparkleBG.alpha -= 0.1;
							sparkleFG.alpha -= 0.1;
							pinkOverlay.alpha -= 0.02;

							if (sparkleBG.alpha > 0 && sparkleFG.alpha > 0 && bakaOverlay.alpha > 0)
								tmr.reset(0.35);
						});
				}
			}

			if (curSong.toLowerCase() == 'obsession')
			{
				switch (curBeat)
				{
					case 119:
						camZooming = false;
						FlxTween.tween(FlxG.camera, {zoom: 1.5}, 10, {ease: FlxEase.linear});
						staticshock.visible = true;
						staticshock.alpha = 0;
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							staticshock.alpha += 0.1;

							if (staticshock.alpha < 1)
								tmr.reset(1);
						});
					case 134:
						add(whiteflash);
						add(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Shut_off'), 0.7);
					case 136:
						// shit gets serious
						yuriGoCrazy();
					case 140:
						remove(blackScreen);
						staticshock.alpha = 0.1;

						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							whiteflash.alpha -= 0.15;

							if (whiteflash.alpha > 0.15)
								tmr.reset(0.1);
						});
						// case what ever when Yuri right before yuri laughing, do an abrupt cut to black if you could
				}
			}

			if (curSong.toLowerCase() == 'epiphany')
			{
				switch (curBeat)
				{
					case 776:
						dad.playAnim('lastNOTE');
					case 788:
						new FlxTimer().start(0.05, function(tmr:FlxTimer)
						{
							iconP2.alpha -= 0.15;

							if (iconP2.alpha > 0)
								tmr.reset(0.05);
							else
								iconP2.visible = false;
						});
					case 790:
						FlxG.camera.fade(FlxColor.BLACK, .7, false);
				}
			}
		}

		if (curSong.toLowerCase() == "bara no yume" || curSong.toLowerCase() == "poems n thorns")
			bgGirls.dance();
	}

	function yuriGoCrazy()
	{
		yuriGoneCrazy = true;
		// visual setup
		defaultCamZoom = 1.3;
		camZooming = true;
		camFocus = false;
		blackScreenBG.alpha = 0.8;
		remove(deskfront);
		// character setup
		var olddadx = PlayState.dad.x;
		var olddady = PlayState.dad.y;
		health = 1;
		gf.playAnim('necksnap', true);
		boyfriend.x = dad.y + 135;
		boyfriend.y -= 50;
		remove(boyfriend);
		remove(dad);
		dad = new Character(olddadx, olddady, 'yuri-crazy');
		add(dad);
		add(boyfriend);
		iconP2.changeIcon('yuri-crazy');
		// vignette + camera setup
		add(vignette);
		vignette.alpha = 0.6;
		camFollow.setPosition((dad.getMidpoint().x + boyfriend.getMidpoint().x) / 1.8, dad.getMidpoint().y - 50);
	}

	function gopixel()
		{
			//gf pixel x 675 y 402
			//bf pixel x 911 y 610
			//monika pixel x 351 y 436

			defaultCamZoom = 1;
			remove(boyfriend);
			remove(dad);
			remove(gf);
			dad = new Character(351, 436, 'monika');
			boyfriend = new Boyfriend(911, 610, 'bf-pixel');
			gf = new Character(675, 402, 'gf-pixel');

			iconP1.changeIcon('bf-pixel');
			iconP2.changeIcon('monika');

			if (FlxG.save.data.songPosition)
				songName.antialiasing = false;

			scoreTxt.antialiasing = false;
			replayTxt.antialiasing = false;
			botPlayState.antialiasing = false;

			add(gf);
			add(boyfriend);
			add(dad);

			// thank u bbpanzu/Sunday mod!
			isPixelUI = true;
			remove(strumLineNotes);
			strumLineNotes = new FlxTypedGroup<FlxSprite>();
			strumLineNotes.cameras = [camHUD];
			add(strumLineNotes);

			generateStaticArrows(0, 'pixel', false);
			generateStaticArrows(1, 'pixel', false);

			fgTrees.visible = true;
			bgSky.visible = true;
			bgSchool.visible = true;
			bgStreet.visible = true;
			bgTrees.visible = true;
			treeLeaves.visible = true;

			lights_front.visible = false;
			deskfront.visible = false;
			closet.visible = false;
			clubroom.visible = false;
			lights_back.visible = false;
			banner.visible = false;
		}
	function becomefumo()
		{
			//gf x 400 y 130
			//bf x 770 y 450
			//dad x 100 y 160
			defaultCamZoom = 0.75;
			remove(boyfriend);
			remove(dad);
			remove(gf);
			dad = new Character(100, 160, SONG.player2);
			boyfriend = new Boyfriend(770, 450, SONG.player1);
			gf = new Character(400, 130, SONG.gfVersion);

			iconP1.changeIcon(SONG.player1);
			iconP2.changeIcon(SONG.player2);

			boyfriend.color = 0x828282;
			dad.color = 0x828282;
			gf.color = 0x828282;

			if (FlxG.save.data.songPosition)
				songName.antialiasing = true;

			scoreTxt.antialiasing = true;
			replayTxt.antialiasing = true;
			botPlayState.antialiasing = true;

			add(gf);
			add(boyfriend);
			add(dad);

			isPixelUI = false;
			remove(strumLineNotes);
			strumLineNotes = new FlxTypedGroup<FlxSprite>();
			strumLineNotes.cameras = [camHUD];
			add(strumLineNotes);

			generateStaticArrows(0, SONG.noteStyle, false);
			generateStaticArrows(1, SONG.noteStyle, false);

			fgTrees.visible = false;
			bgSky.visible = false;
			bgSchool.visible = false;
			bgStreet.visible = false;
			bgTrees.visible = false;
			treeLeaves.visible = false;

			lights_front.visible = true;
			deskfront.visible = true;
			closet.visible = true;
			clubroom.visible = true;
			lights_back.visible = true;
			banner.visible = true;
		}

	var curLight:Int = 0;
}
