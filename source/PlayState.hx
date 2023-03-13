package;

import openfl.events.KeyboardEvent;
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
import Song.SwagMetadata;
import Song.SwagSong;
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
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
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
import flixel.util.FlxSpriteUtil;
import flixel.group.FlxSpriteGroup;
import shaders.*;
import StageData;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
#if FEATURE_FILESYSTEM
import Sys;
import sys.FileSystem;
#end
#if FEATURE_GAMEJOLT
import GameJolt.GameJoltAPI;
#end
#if FEATURE_MP4
import hxcodec.VideoHandler as NetStreamHandler;
import hxcodec.VideoSprite;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X:Float = 49;
	public static var STRUM_X_MIDDLESCROLL:Float = -272; // adjusted for pixel atm

	public static var instance:PlayState = null;

	public static var chartingMode:Bool = false;

	public static var practiceMode:Bool = false;
	public static var practiceModeToggled:Bool = false;
	public static var showCutscene:Bool = true;
	public static var deathCounter:Int = 0;
	public static var toggleBotplay:Bool = false;
	public static var ForceDisableDialogue:Bool = false;

	var midsongcutscene:Bool = false;

	private var constantScroll:Bool = false;
	public var songSpeed(default, set):Float = 1;
	public var noteKillOffset:Float = 350;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;

	private var positionBar:Bool = false;
	private var positionDisplay:PositionDisplay = null;

	private var lyrics:FlxText;
	private var hasLyrics:Bool = false;
	private var lyricData:Array<Dynamic> = [];

	// Cleaner dialogue shit
	var introDialogue:String;
	var endDialogue:String;
	var introDoof:DialogueBox = null;
	var endDoof:DialogueBox = null;

	var yuriGoneCrazy:Bool = false;

	var songLength:Float = 0;
	var songTimeLeft:Float = 0;

	var storyDifficultyText:String = "";

	#if FEATURE_DISCORD
	// Discord RPC variables
	var iconRPC:String = "";
	var detailsText:String = "";
	var songLengthDiscord:Float = 0;
	#end

	public static var vocals:FlxSound;

	var pixelc:FlxSound;

	public static var extrachar1:Character;
	public static var extrachar2:Character;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Character;


	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;
	public var hideGirlfriend:Bool = false;

	#if (haxe >= "4.0.0")
	public var preloadMap:Map<String, Character> = new Map();
	#else
	public var preloadMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var preloadGroup:FlxSpriteGroup;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	public static var strumLineNotes:FlxTypedGroup<StrumNote>;
	public static var opponentStrums:FlxTypedGroup<StrumNote>;
	public static var playerStrums:FlxTypedGroup<StrumNote>;
	private var curStyle:String = 'normal';

	var grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

	public static var isPixelUI:Bool = false;

	private var camZooming:Bool = false;
	private var camFocus:Bool = true;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var misses:Int = 0;
	public static var breaks:Int = 0;

	private var earlys:Int = 0;
	private var lates:Int = 0;
	private var maxCombo:Int = 0;

	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var vocalsFinished:Bool = false;

	private var boyfriendFuckingDead:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	public var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var camGame2:FlxCamera;
	public static var camOverlay:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var forceCam:Bool = false;
	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var centerCameraOffset:Array<Float> = null;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var forcedPause:String = '';

	var bgDokis:FlxSpriteGroup;

	var sparkleFG:FlxBackdrop;
	var sparkleBG:FlxBackdrop;
	var pinkOverlay:FlxSprite;
	var bakaOverlay:FlxSprite;
	var vignette:FlxSprite;
	var staticshock:FlxSprite;
	var staticcredits:FlxSprite;
	var oldspace:BGSprite;
	var popup:FlxSprite;

	public static var mirrormode:Bool = false;
	var scorePop:Bool = true;
	public var middleScroll:Bool = false;
	public var coolgameplay:Bool = false;
	var hueh231:FlxSprite;
	var randommode:Bool = false;
	public static var isYuri:Bool = false;
	var encoreTime:Int = 0;

	var lights_front:BGSprite;
	var deskfront:BGSprite;
	var clubmainlight:BGSprite;
	var lightoverlay:BGSprite;
	var stage_front:BGSprite;
	var closet:BGSprite;
	var clubroom:BGSprite;
	var sunshine:BGSprite;
	var zippergoo:FlxSprite;
	var spotlight:BGSprite;
	var lights_back:BGSprite;
	var banner:BGSprite;
	var floatshit:Float = 0;
	var floatshit2:Float = 0.1;

	var deskOverlay:BGSprite;

	// Howdy I hate this :)
	var monika:BGSprite;
	var sayori:BGSprite;
	var yuri:BGSprite;
	var natsuki:BGSprite;
	var protag:BGSprite;

	var bg:BGSprite;
	var stageFront:BGSprite;
	var treeLeaves:BGSprite;
	var redStatic:BGSprite;
	var evilbg:BGSprite;

	var stageVER:Int = 0;

	var fgTrees:FlxSprite;
	var bgSky:FlxSprite;
	var bgSchool:FlxSprite;
	var bgStreet:FlxSprite;
	var bgTrees:FlxSprite;
	var glitchy:PixelShader = new PixelShader();
	var bloomlol:BloomShader = new BloomShader();
	var staticlol:StaticShader = new StaticShader();
	var staticlol2:StaticShader = new StaticShader();
	var fishy:FishEyeShader = new FishEyeShader();
	var warpy:WarpShader = new WarpShader();
	var inverty:InvertShader = new InvertShader();
	var glitchlol:GlitchShader = new GlitchShader();
	var glitchlol2:GlitchShader = new GlitchShader();

	var barads:BGSprite;
	var danaBop:BGSprite;
	var anaThingie:BGSprite;
	var dorth:BGSprite;
	var alma:BGSprite;
	var dorthDanced:Bool = false;
	var funnTextGroup:FlxTypedGroup<FlxText>;

	var imageBG:FlxSprite;

	var galleryData:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/stickerData', 'preload'));
	var stickerData:Array<String> = [];
	var stickerSprites:FlxSpriteGroup;
	var senpaiBox:BGSprite;
	var p1Box:BGSprite;
	var p2Box:BGSprite;
	var senpaiBoxtop:BGSprite;
	var p1Boxtop:BGSprite;
	var p2Boxtop:BGSprite;
	var cursorDDTO:BGSprite;
	var creditsBG:FlxBackdrop;
	var wiltedwindow:FlxSprite;
	var wiltedhey:BGSprite;
	var wiltedhey_senpai:BGSprite;
	var wiltedHmph:BGSprite;
	var wiltbg:FlxSprite;

	var space:FlxBackdrop;
	var clouds:FlxBackdrop;
	var fancyclouds:FlxBackdrop;
	var encoreborder:BGSprite;
	var blackbarTop:BGSprite;
	var blackbarBottom:BGSprite;
	var waitin:BGSprite;
	var whiteflash:FlxSprite;
	var blackScreen:FlxSprite;
	var blackScreenBG:FlxSprite;
	var blackScreentwo:FlxSprite;
	var dokiBackdrop:FlxBackdrop;
	var windowlight:BGSprite;
	var lightontopofall:BGSprite;
	var funnytext:FlxTypeText;
	var happyEnding:Bool = false;


	//CGs are here
	var cg1:BGSprite;
	var cg2:BGSprite;

	var cg2Light:BGSprite;
	var cg2Moni:BGSprite;
	var cg2Sayo:BGSprite;
	var cg2Yuri:BGSprite;
	var cg2Natsu:BGSprite;
	var cg2BG:BGSprite;
	var cg2Group:FlxSpriteGroup;

	var poemVideo:VideoSprite;
	var sideWindow:BGSprite;
	var dokiData:Array<Float> = [];

	// HOLY LIBITINA
	var rainBG:VideoSprite;
	var deskBG1:BGSprite;
	var deskBG2:BGSprite;
	var deskBG2Overlay:BGSprite;
	var extractPopup:BGSprite;
	var libHando:BGSprite;
	var testVM:VideoSprite;
	var libiWindow:BGSprite;
	var libAwaken:BGSprite;
	var ghostBG:FlxBackdrop;
	var eyeBG:BGSprite;
	var eyeMidwayBG:BGSprite;
	var eyeShadow:BGSprite;
	var infoBG:BGSprite;
	var infoBG2:BGSprite;
	var crackBG:VideoSprite;
	var libFinaleBG:BGSprite;
	var libGhost:BGSprite;
	var libParty:BGSprite;
	var libRockIs:BGSprite;
	var libFinale:BGSprite;
	var libFinaleEyes:BGSprite;
	var libFinaleOverlay:BGSprite;
	var libVignette:BGSprite;
	var grpPopups = new FlxTypedGroup<BGSprite>();

	var altAnim:String = "";
	var fc:Bool = true;

	var isintro:Bool = true;
	var incutsceneforendingsmh:Bool = false;

	var bgGirls:BackgroundGirls;
	var practiceScore:Int = 0;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var scoreTxtTween:FlxTween;
	var judgementCounter:FlxText;

	public static var metadata:SwagMetadata;
	public static var hasMetadata:Bool = false;

	var metadataDisplay:MetadataDisplay = null;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;
	var defaultHudZoom:Float = SaveData.zoom;

	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;
	var zoomStuff:Bool = true;

	// BotPlay text
	private var canShowPracticeTxt:Bool = true;
	private var practiceTxt:FlxText;
	private var botPlayState:FlxText;
	private var botplaySine:Float = 0;

	private var keysArray:Array<Dynamic>;

	// use this to prevent conflicts with easter eggs
	private var keysStringArray:Array<String> = [
		SaveData.leftBind,
		SaveData.downBind,
		SaveData.upBind,
		SaveData.rightBind
	];

	// API stuff
	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	// FPS Plus charting state stuff
	public static var sectionStart:Bool = false;
	public static var sectionStartPoint:Int = 0;
	public static var sectionStartTime:Float = 0;

	override public function create()
	{
		Paths.clearStoredMemory();

		instance = this;

		keysArray = [
			[FlxKey.fromString(SaveData.leftBind), FlxKey.LEFT],
			[FlxKey.fromString(SaveData.downBind), FlxKey.DOWN],
			[FlxKey.fromString(SaveData.upBind), FlxKey.UP],
			[FlxKey.fromString(SaveData.rightBind), FlxKey.RIGHT]
		];

		Character.ingame = true;
		Character.isFestival = false;

		// null the metadata because it's public static (thanks pause)
		if (metadata != null)
			metadata = null;

		// read the metadata
		try
		{
			metadata = cast Json.parse(Assets.getText(Paths.json('songs/${SONG.song.toLowerCase()}/meta')));
			hasMetadata = true;
		}
		catch (e)
		{
			hasMetadata = false;
			trace('[${SONG.song}] Metadata either doesn\'t exist or contains an error!');
		}

		// set the pixel ui to false??  stuipd ???
		isPixelUI = false;

		if (SONG.noteStyle != null)
		{
			curStyle = SONG.noteStyle;
			isPixelUI = SONG.noteStyle.startsWith('pixel');
		}
		else
		{
			curStyle = isPixelUI ? 'pixel' : 'normal';
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;
		breaks = 0;

		if (isStoryMode)
		{
			chartingMode = false;
			practiceMode = false;
			Conductor.playbackSpeed = 1;
			practiceModeToggled = false;
		}
		else
		{
			if (SONG.song.toLowerCase() != 'libitina')
				mirrormode = SaveData.mirrorMode;

			if (!practiceMode)
				Conductor.playbackSpeed = SaveData.songSpeed;

			randommode = SaveData.randomMode;
		}

		positionBar = SaveData.songPosition;
		middleScroll = SaveData.middleScroll;
		coolgameplay = SaveData.coolGameplay;
		perSongOffset = SaveData.getSongOffset(SONG.song);
		constantScroll = SaveData.scrollSpeed >= 1;

		if (SONG.song.toLowerCase() == 'takeover medley')
			middleScroll = true;

		if (SONG.song.toLowerCase() == 'catfight')
			mirrormode = isYuri;

		if (!isStoryMode)
			toggleBotplay = SaveData.botplay;

		// Making difficulty text for Discord Rich Presence/Song Position Bar.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = LangUtil.getString('cmnEasy');

			case 1:
				if (DokiFreeplayState.singleDiff.contains(SONG.song.toLowerCase()))
					storyDifficultyText = "";
				else
					storyDifficultyText = LangUtil.getString('cmnNormal'); 

			case 2:
				storyDifficultyText = LangUtil.getString('cmnHard');
		}

		#if FEATURE_DISCORD
		iconRPC = SONG.player2;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			detailsText = 'Story Mode (${LangUtil.getString('week${storyWeek + 1}', 'story')})';
		else
			detailsText = 'Freeplay';

		updateDiscordPresence();
		#end

		camGame = new FlxCamera();
		camGame2 = new FlxCamera();
		camHUD = new FlxCamera();
		camOverlay = new FlxCamera();
		camGame.bgColor = FlxColor.BLACK;
		camGame2.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camOverlay.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camGame2);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOverlay);

		camHUD.zoom = defaultHudZoom;

		var tempNoteSplash = new NoteSplash(0, 0, 0, curStyle);
		grpNoteSplashes.add(tempNoteSplash);
		tempNoteSplash.alpha = 0.001;

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOverlay;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('erb', 'erb');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		whiteflash = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		whiteflash.scrollFactor.set();

		blackScreen = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackScreen.scrollFactor.set();

		pinkOverlay = new FlxSprite(-FlxG.width * FlxG.camera.zoom, -FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFFF281F2);
		pinkOverlay.alpha = 0.2;
		pinkOverlay.blend = SCREEN;
		pinkOverlay.scrollFactor.set();

		if (SONG.song.toLowerCase() == 'obsession' || SONG.song.toLowerCase() == 'my confession')
		{
			whiteflash.cameras = [camHUD];
			blackScreen.cameras = [camHUD];
		}

		blackScreenBG = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackScreenBG.alpha = 0.0001;
		blackScreenBG.scrollFactor.set();

		blackScreentwo = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackScreentwo.scrollFactor.set();

		// set up dialogue
		if (isStoryMode || metadata.song.freeplayDialogue)
		{
			if (metadata.song.introDialogue != null && showCutscene)
			{
				introDialogue = metadata.song.introDialogue;
	
				if (SONG.song.toLowerCase() == 'epiphany')
				{
					if (storyDifficulty != 2)
					{
						DialogueBox.isOBS = CoolUtil.isRecording();

						if (SaveData.beatEpiphany)
							introDialogue = metadata.song.introDialogueBeat;
					}
					else
					{
						introDialogue = metadata.song.introDialogueAlt;
					}
				}
	
				try
				{
					introDoof = new DialogueBox(Assets.getText(Paths.json('dialogue/${SONG.song.toLowerCase()}/$introDialogue')));
					introDoof.scrollFactor.set();
				}
				catch (e)
				{
					trace('[${SONG.song}] "$introDialogue" either doesn\'t exist or contains an error!');
				}
			}
	
			if (metadata.song.endDialogue != null)
			{
				endDialogue = metadata.song.endDialogue;
	
				try
				{
					endDoof = new DialogueBox(Assets.getText(Paths.json('dialogue/${SONG.song.toLowerCase()}/$endDialogue')));
					endDoof.scrollFactor.set();
				}
				catch (e)
				{
					endDoof = null;
					trace('[${SONG.song}] "$endDialogue" either doesn\'t exist or contains an error!');
				}
			}
		}

		curStage = SONG.stage;

		var stageData:StageFile = StageData.getStageFile(curStage);

		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 450],
				girlfriend: [400, 130],
				opponent: [100, 450],
				hide_girlfriend: false,

				forced_camera_position: false,
				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_center: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		//isPixelStage = stageData.isPixelStage; // we have isPixelUI instead lol
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		hideGirlfriend = stageData.hide_girlfriend;

		if (stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		forceCam = stageData.forced_camera_position;
		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null) // Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		centerCameraOffset = stageData.camera_center; //Repurposing this for Center cam sorry Michael
		if (centerCameraOffset == null)
			centerCameraOffset = [0, 0];

		// initializing the bg dokis here
		if (curStage.startsWith('doki'))
		{
			bgDokis = new FlxSpriteGroup();

			monika = new BGSprite('bgdoki/monika', 'doki', 320, 173, 1, 0.9, ['idle', 'Moni BG']);
			monika.setGraphicSize(Std.int(monika.width * 0.7));
			monika.updateHitbox();

			sayori = new BGSprite('bgdoki/sayori', 'doki', -49, 247, 1, 0.9, ['idle', 'Sayori BG']);
			sayori.setGraphicSize(Std.int(sayori.width * 0.7));
			sayori.updateHitbox();

			natsuki = new BGSprite('bgdoki/natsuki', 'doki', 1247, 303, 1, 0.9, ['idle', 'Natsu BG']);
			natsuki.setGraphicSize(Std.int(natsuki.width * 0.7));
			natsuki.updateHitbox();

			protag = new BGSprite('bgdoki/protag', 'doki', 150, 152, 1, 0.9, ['idle', 'Protag-kun BG']);
			protag.setGraphicSize(Std.int(protag.width * 0.7));
			protag.updateHitbox();

			yuri = new BGSprite('bgdoki/yuri', 'doki', 1044, 178, 1, 0.9, ['idle', 'Yuri BG']);
			yuri.setGraphicSize(Std.int(yuri.width * 0.7));
			yuri.updateHitbox();
		}

		preloadGroup = new FlxSpriteGroup(100, 100);

		switch (curStage)
		{
			case 'school':
				{
					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					treeLeaves = new BGSprite('weeb/petals', 'week6', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.antialiasing = false;
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
						add(bgGirls);
					}

					evilbg = new BGSprite('weeb/animatedEvilSchool', 'week6', 400, 200, 0.8, 0.9, ['background 2'], true);
					evilbg.scale.set(6, 6);
					evilbg.antialiasing = false;
					evilbg.visible = false;
					add(evilbg);
				}
			case 'schoolEvilEX':
				{
					oldspace = new BGSprite('finalebgmybeloved', 'shared', 50, 200, 0.1, 0.1);
					oldspace.setGraphicSize(Std.int(oldspace.width * 1.65));
					oldspace.alpha = 0;
					add(oldspace);

					space = new FlxBackdrop(Paths.image('weeb/FinaleBG_1', 'week6'));
					space.scrollFactor.set(0.1, 0.1);
					space.velocity.set(-10, 0);
					space.scale.set(1.65, 1.65);
					add(space);

					bg = new BGSprite('weeb/FinaleBG_2', 'week6', 100, 200, 0.4, 0.6);
					bg.scale.set(2.3, 2.3);
					add(bg);

					stageFront = new BGSprite('weeb/FinaleFG', 'week6', 50, 200, 1, 1);
					stageFront.antialiasing = false;
					stageFront.scale.set(1.5, 1.5);
					add(stageFront);

					treeLeaves = new BGSprite('weeb/petals', 'week6', 700, 325, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.scale.set(6, 6);
					treeLeaves.antialiasing = false;
					add(treeLeaves);

					stageFront.visible = false;
					bg.visible = false;
					space.visible = false;
					treeLeaves.visible = false;

					evilbg = new BGSprite('weeb/animatedEvilSchool', 'week6', 400, 200, 0.8, 0.9, ['background 2'], true);
					evilbg.scale.set(6, 6);
					evilbg.antialiasing = false;
					add(evilbg);
				}
			case 'schoolEvil':
				{
					// finalebgmybeloved
					oldspace = new BGSprite('finalebgmybeloved', 'shared', 50, 200, 0.1, 0.1);
					oldspace.setGraphicSize(Std.int(oldspace.width * 1.65));
					oldspace.alpha = 0;
					add(oldspace);

					space = new FlxBackdrop(Paths.image('weeb/FinaleBG_1', 'week6'));
					space.scrollFactor.set(0.1, 0.1);
					space.velocity.set(-10, 0);
					space.scale.set(1.65, 1.65);
					add(space);

					bg = new BGSprite('weeb/FinaleBG_2', 'week6', 100, 200, 0.4, 0.6);
					bg.scale.set(2.3, 2.3);
					add(bg);

					stageFront = new BGSprite('weeb/FinaleFG', 'week6', 50, 200, 1, 1);
					stageFront.antialiasing = false;
					stageFront.scale.set(1.5, 1.5);
					add(stageFront);
				}
			
			case 'credits':
				{
					camGame.bgColor = FlxColor.WHITE;

					dokiBackdrop = new FlxBackdrop(Paths.image('scrollingBG'));
					dokiBackdrop.scrollFactor.set(0.1, 0.1);
					dokiBackdrop.velocity.set(-10, 0);
					dokiBackdrop.antialiasing = SaveData.globalAntialiasing;
					dokiBackdrop.alpha = 0.3;
					dokiBackdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
					add(dokiBackdrop);

					creditsBG = new FlxBackdrop(Paths.image('credits/pocBackground', 'doki'));
					creditsBG.scrollFactor.set(0.1, 0.1);
					creditsBG.velocity.set(-50, 0);
					add(creditsBG);

					var scanline:FlxBackdrop = new FlxBackdrop(Paths.image('credits/scanlines', 'doki'));
					scanline.scrollFactor.set(0.1, 0.1);
					scanline.velocity.set(0, 20);
					add(scanline);

					var gradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/gradent', 'doki'));
					gradient.antialiasing = SaveData.globalAntialiasing;
					gradient.scrollFactor.set(0.1, 0.1);
					gradient.screenCenter();
					gradient.setGraphicSize(Std.int(gradient.width * 2.6));
					add(gradient);

					if (SaveData.shaders)
					{
						var funnyShader:FishEyeShader = new FishEyeShader();
						camGame.setFilters([new ShaderFilter(funnyShader)]);
					}

					var boxY:Int = 10;
					//senpai
					senpaiBox = new BGSprite('credits/window_bottom_senpai', 'doki', 190, 1060, 1, 1);
					senpaiBox.scale.set(1.25, 1.25);
					senpaiBox.updateHitbox();
					senpaiBox.cameras = [camGame2];
					add(senpaiBox);

					senpaiBoxtop = new BGSprite('credits/window_top', 'doki', 180, 1050, 1, 1);
					senpaiBoxtop.scale.set(1.25, 1.25);
					senpaiBoxtop.updateHitbox();
					senpaiBoxtop.cameras = [camGame2];
					add(senpaiBoxtop);

					//p2
					p2Box = new BGSprite('credits/window_bottom', 'doki', -255, boxY, 1, 1);
					p2Box.scale.set(1.25, 1.25);
					p2Box.updateHitbox();
					p2Box.cameras = [camGame2];

					p2Boxtop = new BGSprite('credits/window_top', 'doki', -265, boxY, 1, 1);
					p2Boxtop.scale.set(1.25, 1.25);
					p2Boxtop.updateHitbox();
					p2Boxtop.cameras = [camGame2];

					//p1
					p1Box = new BGSprite('credits/window_bottom_funkin', 'doki', 665, boxY, 1, 1);
					p1Box.scale.set(1.25, 1.25);
					p1Box.updateHitbox();
					p1Box.cameras = [camGame2];

					p1Boxtop = new BGSprite('credits/window_top', 'doki', 655, boxY, 1, 1);
					p1Boxtop.scale.set(1.25, 1.25);
					p1Boxtop.updateHitbox();
					p1Boxtop.cameras = [camGame2];

					// cursor
					cursorDDTO = new BGSprite('credits/Arrow', 'doki', 500, 1060, 1, 1);
					cursorDDTO.scale.set(0.4, 0.4);
					cursorDDTO.updateHitbox();
					cursorDDTO.scale.set(1, 1);
					cursorDDTO.cameras = [camGame2];

					staticcredits = new FlxSprite(0, 0);
					staticcredits.frames = Paths.getSparrowAtlas('credits/HomeStatic', 'doki');
					staticcredits.antialiasing = SaveData.globalAntialiasing;
					staticcredits.animation.addByPrefix('idle', 'HomeStatic', 24, true);
					staticcredits.animation.play('idle');
					staticcredits.scrollFactor.set();
					staticcredits.alpha = 0.001;
					staticcredits.blend = MULTIPLY;
					staticcredits.cameras = [camGame2];
					staticcredits.setGraphicSize(Std.int(staticcredits.width / defaultHudZoom));
					staticcredits.updateHitbox();
					staticcredits.screenCenter();

					//camFollow.y = -930;
					cg1 = new BGSprite('credits/DokiTakeoverLogo', 'doki', 0, 0, 0, 0);
					cg1.alpha = 1;
					cg1.cameras = [camGame2];
					cg1.screenCenter();
					cg2 = new BGSprite('credits/thanksforplaying', 'doki', 0, 0, 0, 0);
					cg2.alpha = 0.001;
					cg2.cameras = [camGame2];
					

				}
			case 'wilted':
				{
					defaultCamZoom = 0.7;
					
					camGame.bgColor = FlxColor.WHITE;

					dokiBackdrop = new FlxBackdrop(Paths.image('scrollingBG'));
					dokiBackdrop.scrollFactor.set(0.1, 0.1);
					dokiBackdrop.velocity.set(-10, 0);
					dokiBackdrop.antialiasing = SaveData.globalAntialiasing;
					dokiBackdrop.alpha = 0.3;
					dokiBackdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
					add(dokiBackdrop);

					creditsBG = new FlxBackdrop(Paths.image('credits/pocBackground', 'doki'));
					creditsBG.scrollFactor.set(0.1, 0.1);
					creditsBG.velocity.set(-50, 0);
					add(creditsBG);

					var scanline:FlxBackdrop = new FlxBackdrop(Paths.image('credits/scanlines', 'doki'));
					scanline.scrollFactor.set(0.1, 0.1);
					scanline.velocity.set(0, 20);
					add(scanline);
					
					var gradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/gradent', 'doki'));
					gradient.antialiasing = SaveData.globalAntialiasing;
					gradient.scrollFactor.set(0.1, 0.1);
					gradient.screenCenter();
					gradient.setGraphicSize(Std.int(gradient.width * 1.6));
					add(gradient);

					if (SaveData.shaders)
					{
						var funnyShader:FishEyeShader = new FishEyeShader();
						camGame.setFilters([new ShaderFilter(funnyShader)]);
					}

					wiltedwindow = new FlxSprite().loadGraphic(Paths.image('wilt/p1', 'doki'));
					wiltedwindow.antialiasing = SaveData.globalAntialiasing;
					wiltedwindow.scrollFactor.set(1, 1);
					wiltedwindow.cameras = [camGame2];
					wiltedwindow.scale.set(1.25, 1.25);
					wiltedwindow.updateHitbox();
					wiltedwindow.screenCenter();

					wiltbg = new FlxSprite().loadGraphic(Paths.image('wilt/bg', 'doki'));
					wiltbg.antialiasing = SaveData.globalAntialiasing;
					wiltbg.scrollFactor.set(0.85, 1);
					wiltbg.cameras = [camGame2];
					wiltbg.scale.set(1.25, 1.25);
					wiltbg.updateHitbox();
					wiltbg.screenCenter();
					add(wiltbg);

					wiltedhey_senpai = new BGSprite('wilt/hoii_senpai', 'doki', wiltedwindow.x, wiltedwindow.y, 1, 1, ['Hey_Senpai'], false);
					wiltedhey_senpai.alpha = 0.001;
					wiltedhey_senpai.scale.set(1.25, 1.25);
					wiltedhey_senpai.updateHitbox();
					wiltedhey_senpai.cameras = [camGame2];

					wiltedhey = new BGSprite('wilt/hoii', 'doki', 415, -150, 1, 1, ['Hey'], false);
					wiltedhey.alpha = 0.001;
					wiltedhey.scale.set(1.25, 1.25);
					wiltedhey.updateHitbox();
					wiltedhey.cameras = [camGame2];

					wiltedHmph = new BGSprite('wilt/hmhphph', 'doki', -257, -167, 1, 1, ['Hmph'], false);
					wiltedHmph.alpha = 0.001;
					wiltedHmph.scale.set(1.25, 1.25);
					wiltedHmph.updateHitbox();
					wiltedHmph.cameras = [camGame2];
					
				}
			case 'va11halla':
				{
					var repositionShit = -200;

					var bgVa11halla:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('va11halla/barbg', 'doki'));
					bgVa11halla.scrollFactor.set(1, 1);
					add(bgVa11halla);

					//anaThingie
					anaThingie = new BGSprite('va11halla/anna', 'doki', repositionShit, 0, 1, 1, ['idle', 'anna_idle']);
					anaThingie.animation.addByPrefix('static', 'anna_static', 24, false);
					anaThingie.animation.play('idle');
					anaThingie.scale.set(6, 6);
					anaThingie.antialiasing = false;
					anaThingie.updateHitbox();
					add(anaThingie);

					danaBop = new BGSprite('va11halla/dana', 'doki', 617, 72, 1, 1, ['idle', 'dana']);
					danaBop.scale.set(6, 6);
					danaBop.antialiasing = false;
					danaBop.visible = false;
					danaBop.updateHitbox();
					add(danaBop);

					var bg2Va11halla:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('va11halla/barbg2', 'doki'));
					bg2Va11halla.scrollFactor.set(1, 1);
					add(bg2Va11halla);

					barads = new BGSprite('va11halla/BarAds', 'doki', 1195, 165, 1, 1, ['BarAdvert'], true);
					barads.scale.set(6, 6);
					barads.antialiasing = false;
					add(barads);

					dorth = new BGSprite('va11halla/dorth', 'doki', -163, 242, 1, 1, ['danceLeft', 'dortohy_left']);
					dorth.animation.addByPrefix('danceRight', 'dortohy_right', 24, false);
					dorth.scale.set(6, 6);
					dorth.antialiasing = false;
					dorth.visible = false;
					dorth.updateHitbox();

					alma = new BGSprite('va11halla/alma', 'doki', 975, 61, 1, 1, ['idle', 'alma']);
					alma.scale.set(6, 6);
					alma.antialiasing = false;
					alma.updateHitbox();
					alma.visible = false;
					add(alma);

					var widShit = Std.int(bgVa11halla.width * 6);

					bgVa11halla.setGraphicSize(widShit);
					bg2Va11halla.setGraphicSize(widShit);

					bgVa11halla.updateHitbox();
					bg2Va11halla.updateHitbox();
				}
			case 'dokiclubroom':
				{
					vignette = new FlxSprite(0, 0).loadGraphic(Paths.image('vignette', 'doki'));
					vignette.antialiasing = SaveData.globalAntialiasing;
					vignette.scrollFactor.set();
					vignette.alpha = 0;

					if (SONG.song.toLowerCase() != 'obsession')
					{
						vignette.cameras = [camHUD];
						vignette.setGraphicSize(Std.int(vignette.width / defaultHudZoom));
						vignette.updateHitbox();
						vignette.screenCenter();
					}

					sparkleBG = new FlxBackdrop(Paths.image('clubroom/YuriSparkleBG', 'doki'));
					sparkleBG.scrollFactor.set(0.1, 0);
					sparkleBG.velocity.set(-16, 0);
					sparkleBG.visible = false;
					sparkleBG.setGraphicSize(Std.int(sparkleBG.width / defaultCamZoom));
					sparkleBG.updateHitbox();
					sparkleBG.screenCenter();
					sparkleBG.antialiasing = SaveData.globalAntialiasing;

					sparkleFG = new FlxBackdrop(Paths.image('clubroom/YuriSparkleFG', 'doki'));
					sparkleFG.scrollFactor.set(0.1, 0);
					sparkleFG.velocity.set(-48, 0);
					sparkleFG.setGraphicSize(Std.int((sparkleFG.width * 1.2) / defaultCamZoom));
					sparkleFG.updateHitbox();
					sparkleFG.screenCenter();
					sparkleFG.antialiasing = SaveData.globalAntialiasing;

					zippergoo = new FlxSprite(0, 0).loadGraphic(Paths.image('zippergoo', 'doki'));
					zippergoo.antialiasing = SaveData.globalAntialiasing;
					zippergoo.scrollFactor.set();
					zippergoo.cameras = [camHUD];
					zippergoo.setGraphicSize(Std.int(FlxG.width / defaultHudZoom));
					zippergoo.updateHitbox();
					zippergoo.screenCenter();
					zippergoo.alpha = 0;

					staticshock = new FlxSprite(0, 0);
					staticshock.frames = Paths.getSparrowAtlas('clubroom/staticshock', 'doki');
					staticshock.antialiasing = SaveData.globalAntialiasing;
					staticshock.animation.addByPrefix('idle', 'hueh', 24, true);
					staticshock.animation.play('idle');
					staticshock.scrollFactor.set();
					staticshock.alpha = 0.6;
					staticshock.blend = SUBTRACT;
					staticshock.visible = false;
					staticshock.cameras = [camOverlay];
					staticshock.updateHitbox();
					staticshock.screenCenter();

					clubmainlight = new BGSprite('clubroom/clublights', 'doki', -700, -520, 1, 1);
					clubmainlight.setGraphicSize(Std.int(clubmainlight.width * 1.6));
					clubmainlight.updateHitbox();
					clubmainlight.blend = SCREEN;
					add(clubmainlight);

					deskfront = new BGSprite('clubroom/DesksFront', 'doki', -700, -520, 1.3, 1);
					deskfront.setGraphicSize(Std.int(deskfront.width * 1.6));
					deskfront.updateHitbox();

					closet = new BGSprite('clubroom/DDLCfarbg', 'doki', -700, -520, 0.9, 1);
					closet.setGraphicSize(Std.int(closet.width * 1.6));
					closet.updateHitbox();
					add(closet);

					clubroom = new BGSprite('clubroom/DDLCbg', 'doki', -700, -520, 1, 1);
					clubroom.setGraphicSize(Std.int(clubroom.width * 1.6));
					clubroom.updateHitbox();
					add(clubroom);

					add(bgDokis);

					if (SONG.song.toLowerCase() == 'neet')
					{
						bgDokis.alpha = 0.001;
						add(blackScreenBG);
					}

					spotlight = new BGSprite('clubroom/NEETspotlight', 'doki', -700, -520, 1, 0.9);
					spotlight.setGraphicSize(Std.int(spotlight.width * 1.6));
					spotlight.alpha = 0.001;
					spotlight.blend = SCREEN;
					spotlight.updateHitbox();
					add(spotlight);

					add(sparkleBG);
				}
			case 'dokifestival':
				{
					Character.isFestival = true;

					vignette = new FlxSprite(-700, -520).loadGraphic(Paths.image('vignette', 'doki'));
					vignette.scrollFactor.set();
					vignette.x = 0;
					vignette.y = 0;
					vignette.cameras = [camHUD];
					vignette.alpha = 0;

					staticshock = new FlxSprite(-700, -520);
					staticshock.frames = Paths.getSparrowAtlas('clubroom/staticshock', 'doki');
					staticshock.animation.addByPrefix('idle', 'hueh', 24, true);
					staticshock.animation.play('idle');
					staticshock.scrollFactor.set();
					staticshock.x = 0;
					staticshock.y = 0;
					staticshock.cameras = [camOverlay];
					staticshock.alpha = 0.6;
					staticshock.blend = SUBTRACT;
					staticshock.visible = false;

					lights_front = new BGSprite('festival/lights_front', 'doki', -605, 565, 1.1, 0.9, ['idle', 'Lights front'], true);
					lights_front.setGraphicSize(Std.int(lights_front.width * 1.6));

					deskfront = new BGSprite('festival/DesksFestival', 'doki', -700, -520, 1.3, 0.9);
					deskfront.setGraphicSize(Std.int(deskfront.width * 1.6));
					deskfront.updateHitbox();

					closet = new BGSprite('festival/FarBack', 'doki', -700, -520, 0.9, 0.9);
					closet.setGraphicSize(Std.int(closet.width * 1.6));
					closet.updateHitbox();
					add(closet);

					clubroom = new BGSprite('festival/MainBG', 'doki', -700, -520, 1, 0.9);
					clubroom.setGraphicSize(Std.int(clubroom.width * 1.6));
					clubroom.updateHitbox();
					add(clubroom);

					lights_back = new BGSprite('festival/lights_back', 'doki', 390, 179, 1, 0.9, ['idle', 'lights back'], true);
					lights_back.setGraphicSize(Std.int(lights_back.width * 1.6));
					add(lights_back);

					banner = new BGSprite('festival/FestivalBanner', 'doki', -700, -520, 1, 0.9);
					banner.setGraphicSize(Std.int(banner.width * 1.6));
					banner.updateHitbox();
					add(banner);

					add(bgDokis);
				}

			case 'dokiglitcher':
				{
					Character.isFestival = true;

					lights_front = new BGSprite('festival/lights_front', 'doki', -605, 565, 1.1, 0.9, ['idle', 'Lights front'], true);
					lights_front.setGraphicSize(Std.int(lights_front.width * 1.6));

					deskfront = new BGSprite('festival/DesksFestival', 'doki', -700, -520, 1.3, 0.9);
					deskfront.setGraphicSize(Std.int(deskfront.width * 1.6));
					deskfront.updateHitbox();

					closet = new BGSprite('festival/FarBack', 'doki', -700, -520, 0.9, 0.9);
					closet.setGraphicSize(Std.int(closet.width * 1.6));
					closet.updateHitbox();
					add(closet);

					clubroom = new BGSprite('festival/MainBG', 'doki', -700, -520, 1, 0.9);
					clubroom.setGraphicSize(Std.int(clubroom.width * 1.6));
					clubroom.updateHitbox();
					add(clubroom);

					lights_back = new BGSprite('festival/lights_back', 'doki', 390, 179, 1, 0.9, ['idle', 'lights back'], true);
					lights_back.setGraphicSize(Std.int(lights_back.width * 1.6));
					add(lights_back);

					add(bgDokis);

					banner = new BGSprite('festival/FestivalBanner', 'doki', -700, -520, 1, 0.9);
					banner.setGraphicSize(Std.int(banner.width * 1.6));
					banner.updateHitbox();
					add(banner);

					// school stuff :(
					var repositionShitx = -428;
					var repositionShity = -155;

					bgSky = new FlxSprite(repositionShitx, repositionShity).loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					bgSchool = new FlxSprite(repositionShitx, repositionShity).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					bgStreet = new FlxSprite(repositionShitx, repositionShity).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					fgTrees = new FlxSprite(repositionShitx + 170, repositionShity + 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					bgTrees = new FlxSprite(repositionShitx - 380, repositionShity + -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					treeLeaves = new BGSprite('weeb/petals', 'week6', -200, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.antialiasing = false;
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
					space = new FlxBackdrop(Paths.image('bigmonika/Sky', 'doki'));
					space.scrollFactor.set(0.1, 0.1);
					space.velocity.set(-7, 0);
					space.antialiasing = SaveData.globalAntialiasing;
					space.scale.set(0.7, 0.7);
					add(space);

					clouds = new FlxBackdrop(Paths.image('bigmonika/Clouds', 'doki'));
					clouds.scrollFactor.set(0.1, 0.1);
					clouds.velocity.set(-13, 0);
					clouds.antialiasing = SaveData.globalAntialiasing;
					clouds.scale.set(0.7, 0.7);
					add(clouds);

					fancyclouds = new FlxBackdrop(Paths.image('bigmonika/mask', 'doki'));
					fancyclouds.scrollFactor.set(0.1, 0.1);
					fancyclouds.velocity.set(-13, 0);
					fancyclouds.antialiasing = SaveData.globalAntialiasing;
					fancyclouds.scale.set(0.7, 0.7);
					fancyclouds.alpha = 1;
					add(fancyclouds);

					var bg:BGSprite = new BGSprite('bigmonika/BG', 'doki', -250, -167, 0.4, 0.6);
					add(bg);

					windowlight = new BGSprite('bigmonika/WindowLight', 'doki', -250, -167, 0.4, 0.6);
					add(windowlight);

					lightontopofall = new BGSprite('bigmonika/lights', 'doki', -250, -167, 0.4, 0.6);
					lightontopofall.cameras = [camGame2];
					lightontopofall.blend = SCREEN;
			
					dokiBackdrop = new FlxBackdrop(Paths.image('scrollingBG'));
					dokiBackdrop.velocity.set(-40, -40);
					dokiBackdrop.antialiasing = SaveData.globalAntialiasing;
					dokiBackdrop.visible = false;
					dokiBackdrop.alpha = 0.001;
					dokiBackdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
					dokiBackdrop.cameras = [camGame2];
					add(dokiBackdrop);

					var bg:BGSprite = new BGSprite('bigmonika/FG', 'doki', -328, -115);
					bg.cameras = [camGame2];
					add(bg);

					popup = new FlxSprite(312, 432);
					popup.frames = Paths.getSparrowAtlas('bigmonika/bigika_delete', 'doki');
					popup.animation.addByPrefix('idle', "PopUpAnim", 24, false);
					popup.animation.play('idle', true);
					popup.antialiasing = SaveData.globalAntialiasing;
					popup.scrollFactor.set(1, 1);
					popup.cameras = [camGame2];
					popup.alpha = 0.001;
				}
			case 'musicroom':
				{
					stage_front = new BGSprite('musicroom/Music_Room_FG', 'doki', -250, -100, 1.2, 1);
					stage_front.setGraphicSize(Std.int(stage_front.width * 1.5));
					stage_front.updateHitbox();

					clubroom = new BGSprite('musicroom/Music_Room', 'doki', -250, -100, 1, 1);
					clubroom.setGraphicSize(Std.int(clubroom.width * 1.5));
					clubroom.updateHitbox();
					add(clubroom);

					if (SONG.song.toLowerCase() == 'love n funkin')
						clubroom.loadGraphic(Paths.image('musicroom/Music_RoomLNF', 'doki'));

					sparkleBG = new FlxBackdrop(Paths.image('clubroom/YuriSparkleBG', 'doki'));
					sparkleBG.scrollFactor.set(0.1, 0);
					sparkleBG.velocity.set(-16, 0);
					sparkleBG.visible = false;
					sparkleBG.setGraphicSize(Std.int(sparkleBG.width / defaultCamZoom));
					sparkleBG.updateHitbox();
					sparkleBG.screenCenter();
					sparkleBG.antialiasing = SaveData.globalAntialiasing;
					add(sparkleBG);

					sparkleFG = new FlxBackdrop(Paths.image('clubroom/YuriSparkleFG', 'doki'));
					sparkleFG.scrollFactor.set(0.1, 0);
					sparkleFG.velocity.set(-48, 0);
					sparkleFG.setGraphicSize(Std.int((sparkleFG.width * 1.2) / defaultCamZoom));
					sparkleFG.updateHitbox();
					sparkleFG.screenCenter();
					sparkleFG.antialiasing = SaveData.globalAntialiasing;

					lightoverlay = new BGSprite('musicroom/Music_RoomLight', 'doki', -250, -100, 1.1, 0.9);
					lightoverlay.setGraphicSize(Std.int(lightoverlay.width * 1.5));
					lightoverlay.updateHitbox();
					lightoverlay.blend = ADD;

					// love n' funkin'
					poemVideo = new VideoSprite();
					poemVideo.playVideo(Paths.video('lnf'), true);
					poemVideo.bitmap.canSkip = false;
					poemVideo.scrollFactor.set();
					poemVideo.setGraphicSize(Std.int(poemVideo.width / defaultCamZoom));
					poemVideo.updateHitbox();
					poemVideo.antialiasing = SaveData.globalAntialiasing;
					poemVideo.cameras = [camGame2];
					poemVideo.alpha = 0.001;

					sideWindow = new BGSprite('notepad/SideWindow', 'doki', 0, 0, 0, 0);
					sideWindow.setGraphicSize(Std.int(sideWindow.width / defaultCamZoom));
					sideWindow.updateHitbox();
					sideWindow.y = FlxG.height - sideWindow.height;
					sideWindow.cameras = [camGame2];
					sideWindow.alpha = 0.001;
				}
			case 'libitina':
				{
					if (SaveData.shaders)
					{
						fishy.preset = 1;
						camGame.setFilters([new ShaderFilter(fishy)]);
					}

					rainBG = new VideoSprite();
					rainBG.playVideo(Paths.video('rain'), true);
					rainBG.bitmap.canSkip = false;
					rainBG.scrollFactor.set();
					rainBG.setGraphicSize(Std.int(rainBG.width / defaultCamZoom));
					rainBG.updateHitbox();
					rainBG.antialiasing = SaveData.globalAntialiasing;
					rainBG.cameras = [camGame2];
					add(rainBG);

					deskBG1 = new BGSprite('libitina/outrodesk', 'doki', 0, 0, 0, 0); // preload
					deskBG1.loadGraphic(Paths.image('libitina/introdesk', 'doki'));
					deskBG1.setGraphicSize(Std.int(FlxG.width / defaultCamZoom));
					deskBG1.updateHitbox();
					deskBG1.cameras = [camGame2];
					add(deskBG1);

					deskBG2 = new BGSprite('libitina/outroscreen', 'doki', 0, 0, 0, 0); // preload
					deskBG2.loadGraphic(Paths.image('libitina/introscreen', 'doki'));
					deskBG2.setGraphicSize(Std.int(FlxG.width / defaultCamZoom));
					deskBG2.updateHitbox();
					deskBG2.cameras = [camGame2];
					deskBG2.alpha = 0.001;
					add(deskBG2);

					cursorDDTO = new BGSprite('libitina/mousecursor', 'doki', 800, 730, 0, 0);
					cursorDDTO.setGraphicSize(Std.int(cursorDDTO.width / defaultCamZoom));
					cursorDDTO.updateHitbox();
					cursorDDTO.cameras = [camGame2];
					cursorDDTO.alpha = 0.001;
					add(cursorDDTO);

					extractPopup = new BGSprite('libitina/extracting', 'doki', 0, 0, 0, 0);
					extractPopup.setGraphicSize(Std.int(extractPopup.width / defaultCamZoom));
					extractPopup.updateHitbox();
					extractPopup.screenCenter();
					extractPopup.cameras = [camGame2];
					extractPopup.alpha = 0.001;
					add(extractPopup);

					testVM = new VideoSprite();
					testVM.playVideo(Paths.video('testvm'), true);
					testVM.bitmap.canSkip = false;
					testVM.scrollFactor.set();
					testVM.setGraphicSize(Std.int(testVM.width / defaultCamZoom));
					testVM.updateHitbox();
					testVM.antialiasing = SaveData.globalAntialiasing;
					testVM.alpha = 0.001;
					add(testVM);

					libiWindow = new BGSprite('libitina/granted', 'doki', 0, 0, 0, 0); // preload
					libiWindow.loadGraphic(Paths.image('libitina/bigwindow', 'doki'));
					libiWindow.setGraphicSize(Std.int(libiWindow.width / defaultCamZoom));
					libiWindow.updateHitbox();
					libiWindow.screenCenter();
					libiWindow.cameras = [camGame2];
					libiWindow.alpha = 0.001;
					add(libiWindow);

					libHando = new BGSprite('libitina/Hando', 'doki', 0, 0, 0.3, 0.3, ['idle', 'HandoAnim']);
					libHando.setGraphicSize(Std.int((libHando.width * 1.5) / defaultCamZoom));
					libHando.updateHitbox();
					libHando.screenCenter();
					libHando.cameras = [camGame2];
					libHando.alpha = 0.001;
					add(libHando);

					deskBG2Overlay = new BGSprite('libitina/lightoverlay', 'doki', 0, 0, 0, 0);
					deskBG2Overlay.setGraphicSize(Std.int((FlxG.width * 1.2) / defaultCamZoom));
					deskBG2Overlay.updateHitbox();
					deskBG2Overlay.screenCenter();
					deskBG2Overlay.cameras = [camOverlay];
					deskBG2Overlay.alpha = 0.001;
					add(deskBG2Overlay);

					libAwaken = new BGSprite('libitina/SheAwakens', 'doki', 0, 0, 0, 0, ['idle', 'SheAwakens']);
					libAwaken.setGraphicSize(Std.int((libAwaken.width * 1.1) / defaultCamZoom));
					libAwaken.updateHitbox();
					libAwaken.screenCenter();
					libAwaken.cameras = [camGame2];
					libAwaken.alpha = 0.001;
					add(libAwaken);

					ghostBG = new FlxBackdrop(Paths.image('libitina/ghostbg', 'doki'));
					ghostBG.setPosition(0, -200);
					ghostBG.scrollFactor.set(0.3, 0.3);
					ghostBG.velocity.set(-40, 0);
					ghostBG.setGraphicSize(Std.int((FlxG.width * 1.5) / defaultCamZoom));
					ghostBG.updateHitbox();
					ghostBG.antialiasing = SaveData.globalAntialiasing;
					ghostBG.alpha = 0.001;
					add(ghostBG);

					eyeBG = new BGSprite('libitina/eyebg', 'doki', 0, 0, 0, 0);
					eyeBG.setGraphicSize(Std.int(FlxG.width / defaultCamZoom));
					eyeBG.updateHitbox();
					eyeBG.screenCenter();
					eyeBG.alpha = 0.001;
					add(eyeBG);

					eyeMidwayBG = new BGSprite('libitina/EyeMidwayBG', 'doki', 0, 0, 0.3, 0.3, ['idle', 'MidwayBG'], true);
					eyeMidwayBG.setGraphicSize(Std.int((FlxG.width * 1.1) / defaultCamZoom));
					eyeMidwayBG.updateHitbox();
					eyeMidwayBG.screenCenter();
					eyeMidwayBG.cameras = [camGame2];

					eyeShadow = new BGSprite('libitina/EyeShadow', 'doki', 0, 0, 0, 0);
					eyeShadow.setGraphicSize(Std.int(FlxG.width / defaultCamZoom));
					eyeShadow.updateHitbox();
					eyeShadow.screenCenter();
					eyeShadow.cameras = [camGame2];

					infoBG = new BGSprite('libitina/InfoMidwayBG', 'doki', 0, 0, 0.3, 0.3, ['idle', 'InfoBG'], true);
					infoBG.setGraphicSize(Std.int((FlxG.width * 1.1) / defaultCamZoom));
					infoBG.updateHitbox();
					infoBG.screenCenter();
					infoBG.alpha = 0.001;
					add(infoBG);

					infoBG2 = new BGSprite('libitina/InfoMidwayBGInvert', 'doki', 0, 0, 0.3, 0.3, ['idle', 'InfoBG'], true);
					infoBG2.setGraphicSize(Std.int((FlxG.width * 1.1) / defaultCamZoom));
					infoBG2.updateHitbox();
					infoBG2.screenCenter();
					infoBG2.alpha = 0.001;
					add(infoBG2);

					crackBG = new VideoSprite(-10, -10);
					crackBG.playVideo(Paths.video('crackBG'), true);
					crackBG.bitmap.canSkip = false;
					crackBG.scrollFactor.set(0.3, 0.3);
					crackBG.setGraphicSize(Std.int(crackBG.width / defaultCamZoom));
					crackBG.updateHitbox();
					crackBG.antialiasing = SaveData.globalAntialiasing;
					crackBG.alpha = 0.001;
					add(crackBG);

					staticshock = new FlxSprite();
					staticshock.frames = Paths.getSparrowAtlas('HomeStatic', 'doki');
					staticshock.antialiasing = SaveData.globalAntialiasing;
					staticshock.animation.addByPrefix('idle', 'HomeStatic', 24, true);
					staticshock.animation.play('idle');
					staticshock.scrollFactor.set();
					staticshock.setGraphicSize(Std.int(FlxG.width / defaultCamZoom));
					staticshock.updateHitbox();
					staticshock.screenCenter();
					staticshock.cameras = [camGame2];
					staticshock.alpha = 0.001;

					libFinaleBG = new BGSprite('libitina/finale/FinaleBG', 'doki', 0, 0, 0, 0);
					libFinaleBG.setGraphicSize(Std.int(libFinaleBG.width / defaultCamZoom));
					libFinaleBG.updateHitbox();
					libFinaleBG.cameras = [camGame2];
					libFinaleBG.alpha = 0.001;
					add(libFinaleBG);

					libGhost = new BGSprite('libitina/finale/LibiFinaleDramatic', 'doki', 160, 710, 0.3, 0.3, ['idle', 'LibiFinale'], true);
					libGhost.setGraphicSize(Std.int(libGhost.width / defaultCamZoom));
					libGhost.updateHitbox();
					libGhost.cameras = [camGame2];
					libGhost.alpha = 0.001;
					add(libGhost);

					libParty = new BGSprite('libitina/finale/GOONS1', 'doki', -80, -460, 0, 0);
					libParty.setGraphicSize(Std.int(libParty.width / defaultCamZoom));
					libParty.updateHitbox();
					libParty.cameras = [camGame2];
					libParty.alpha = 0.001;
					add(libParty);

					libRockIs = new BGSprite('libitina/finale/GOONS2', 'doki', 140, -460, 0, 0);
					libRockIs.setGraphicSize(Std.int(libRockIs.width / defaultCamZoom));
					libRockIs.updateHitbox();
					libRockIs.cameras = [camGame2];
					libRockIs.alpha = 0.001;
					add(libRockIs);

					libFinale = new BGSprite('libitina/finale/Finale4', 'doki', 0, 0, 0, 0); // preload
					libFinale.loadGraphic(Paths.image('libitina/finale/Finale3', 'doki')); // preload
					libFinale.loadGraphic(Paths.image('libitina/finale/Finale2', 'doki'));
					libFinale.setGraphicSize(Std.int(FlxG.width / defaultCamZoom));
					libFinale.updateHitbox();
					libFinale.cameras = [camGame2];
					libFinale.alpha = 0.001;
					add(libFinale);

					libFinaleEyes = new BGSprite('libitina/finale/ShesWatching', 'doki', 0, 0, 0, 0, ['idle', 'ShesWatching'], true);
					libFinaleEyes.setGraphicSize(Std.int(FlxG.width / defaultCamZoom));
					libFinaleEyes.updateHitbox();
					libFinaleEyes.screenCenter();
					libFinaleEyes.alpha = 0.001;
					add(libFinaleEyes);

					libFinaleOverlay = new BGSprite('libitina/finale/ShesWatching', 'doki', 0, 0, 0, 0, ['idle', 'ShesWatching'], true);
					libFinaleOverlay.setGraphicSize(Std.int(FlxG.width / defaultCamZoom));
					libFinaleOverlay.updateHitbox();
					libFinaleOverlay.cameras = [camGame2];
					libFinaleOverlay.alpha = 0.001;
					add(libFinaleOverlay);

					libVignette = new BGSprite('libitina/vignetteend', 'doki', 0, 0, 0, 0); // preload
					libVignette.loadGraphic(Paths.image('libitina/vignette', 'doki'));
					libVignette.setGraphicSize(Std.int(libVignette.width / defaultCamZoom));
					libVignette.updateHitbox();
					libVignette.cameras = [camGame2];

					add(grpPopups);
				}
			case 'stage':
				{
					var bg:BGSprite = new BGSprite('stageback', 'preload', -600, -200, 0.9, 0.9);
					add(bg);

					var stageFront:BGSprite = new BGSprite('stagefront', 'preload', -650, 600, 0.9, 0.9);
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					add(stageFront);

					var stageLight:BGSprite = new BGSprite('stage_light', 'preload', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);

					var stageLight2:BGSprite = new BGSprite('stage_light', 'preload', 1225, -100, 0.9, 0.9);
					stageLight2.setGraphicSize(Std.int(stageLight2.width * 1.1));
					stageLight2.updateHitbox();
					stageLight2.flipX = true;
					add(stageLight2);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', 'preload', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
			case 'youandme':
				{
					//In the sky is 579X and -3404Y for the start of the song


					var posX:Int = -155;
					var posY:Int = -795;
					var scale:Float = 1.2;

					var sky:BGSprite = new BGSprite('ynm/skybox', 'doki', posX, posY, 0.2, 0.2);
					sky.setGraphicSize(Std.int(sky.width * scale));
					sky.updateHitbox();
					add(sky);

					var bg3:BGSprite = new BGSprite('ynm/bg3', 'doki', posX, posY, 0.5, 0.5);
					bg3.setGraphicSize(Std.int(bg3.width * scale));
					bg3.updateHitbox();
					add(bg3);

					var bg2:BGSprite = new BGSprite('ynm/bg2', 'doki', posX, posY, 0.8, 0.8);
					bg2.setGraphicSize(Std.int(bg2.width * scale));
					bg2.updateHitbox();
					add(bg2);

					bg = new BGSprite('ynm/bg', 'doki', posX, posY, 0.9, 0.9);
					bg.setGraphicSize(Std.int(bg.width * scale));
					bg.updateHitbox();
					add(bg);

					dokiBackdrop = new FlxBackdrop(Paths.image('scrollingBG'));
					dokiBackdrop.velocity.set(-40, -40);
					dokiBackdrop.antialiasing = SaveData.globalAntialiasing;
					dokiBackdrop.alpha = 0.001;
					dokiBackdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
					add(dokiBackdrop);

					funnytext = new FlxTypeText(50, 255, 1250, "", 90);
					funnytext.font = 'Journal';
					funnytext.alignment = FlxTextAlign.LEFT;
					funnytext.setBorderStyle(OUTLINE, FlxColor.BLACK, 0.3, 0.3);
					funnytext.antialiasing = SaveData.globalAntialiasing;
					funnytext.cameras = [camGame2];
					funnytext.scrollFactor.set(0, 0);
					add(funnytext);

					//Preload cards justincase
					var charList:Array<String> = ['Yuri', 'Sayori', 'Monika', 'Natsuki'];
					for (i in 0...charList.length)
					{
						var funnyx:Int = 69;

						var funnySprite:FlxSprite = new FlxSprite(funnyx + (i * 294), 164);
						funnySprite.frames = Paths.getSparrowAtlas('extraui/' + charList[i] + 'Card', 'preload');
						switch (charList[i])
						{
							case 'Natsuki':
								funnySprite.animation.addByPrefix('pop', 'NatCardAnim', 30, false);
							case 'Monika':
								funnySprite.animation.addByPrefix('pop', 'MonikaCardAnim', 30, false);
							case 'Sayori':
								funnySprite.animation.addByPrefix('pop', 'SayoCardAnim', 30, false);
							case 'Yuri':
								funnySprite.animation.addByPrefix('pop', 'YuriCardAnim', 30, false);
						}
						funnySprite.ID = i;
						funnySprite.alpha = 0.001;
						funnySprite.animation.play('pop');
						funnySprite.antialiasing = SaveData.globalAntialiasing;
						add(funnySprite);
						funnySprite.cameras = [camHUD];
					}

				}
		}

		//Underversal stage stuff I guess

		redStatic = new BGSprite('HomeStatic', 'doki', 0, 0, 1, 1, ['HomeStatic'], true);
		redStatic.cameras = [camHUD];
		redStatic.setGraphicSize(FlxG.width, FlxG.height);
		redStatic.screenCenter();
		redStatic.alpha = 0.0001;
		add(redStatic);

		bakaOverlay = new FlxSprite(0, 0);
		bakaOverlay.frames = Paths.getSparrowAtlas('clubroom/BakaBGDoodles', 'doki');
		bakaOverlay.antialiasing = SaveData.globalAntialiasing;
		bakaOverlay.animation.addByPrefix('normal', 'Normal Overlay', 24, true);
		bakaOverlay.animation.addByPrefix('party rock is', 'Rock Overlay', 24, true);
		bakaOverlay.animation.play('normal');
		bakaOverlay.scrollFactor.set();
		bakaOverlay.visible = false;
		bakaOverlay.alpha = 0;
		bakaOverlay.cameras = [camHUD];
		bakaOverlay.setGraphicSize(Std.int(FlxG.width / defaultHudZoom));
		bakaOverlay.updateHitbox();
		bakaOverlay.screenCenter();
		add(bakaOverlay);

		if (SONG.song.toLowerCase() != 'takeover medley')
			Character.loadaltcostume = !isStoryMode && SaveData.beatProtag;
		else
			Character.loadaltcostume = true;

		// managing the bg dokis here
		if (bgDokis != null)
		{
			if (SONG.song.toLowerCase() != 'obsession')
			{
				if (Character.isFestival)
				{
					var club:Array<BGSprite> = [monika, sayori, natsuki, protag, yuri];
					for (member in club)
						member.color = 0x828282;
				}

				if (!SONG.player1.startsWith('monika') && !SONG.player2.startsWith('monika') && (SONG.song.toLowerCase() == 'neet' || curStage != 'dokiclubroom'))
					bgDokis.add(monika);

				if (!SONG.player1.startsWith('sayori') && !SONG.player2.startsWith('sayori') && SONG.gfVersion != 'sayo-speaker')
					{
						if (isStoryMode || Character.loadaltcostume && SONG.gfVersion == 'gf-realdoki' && SaveData.gfcostume != "sayo")
							bgDokis.add(sayori);
					}
				if (!SONG.player1.startsWith('natsuki') && !SONG.player2.startsWith('natsuki'))
					bgDokis.add(natsuki);

				if (curStage != 'dokiclubroom' && !SONG.player1.startsWith('protag') && !SONG.player2.startsWith('protag'))
					bgDokis.add(protag);

				if (!SONG.player1.startsWith('yuri') && !SONG.player2.startsWith('yuri'))
					bgDokis.add(yuri);
			}
			else if (SONG.song.toLowerCase() == 'obsession' && isStoryMode && showCutscene && !ForceDisableDialogue)
			{
				if (!SONG.player1.startsWith('sayori') && !SONG.player2.startsWith('sayori') && SONG.gfVersion != 'sayo-speaker')
				{
					if (isStoryMode || Character.loadaltcostume && SONG.gfVersion == 'gf-realdoki' && SaveData.gfcostume != "sayo")
						bgDokis.add(sayori);
				}

				if (!SONG.player1.startsWith('natsuki') && !SONG.player2.startsWith('natsuki'))
					bgDokis.add(natsuki);
			}

			if (curStage == 'dokiclubroom')
			{
				switch (SONG.player2)
				{
					case "sayori":
						{
							yuri.setPosition(-74, 176);
							natsuki.setPosition(1088, 275);
						}
					case "natsuki":
						{
							sayori.setPosition(1050, 250);
							yuri.setPosition(130, 176);
							
						}
					case "yuri" | "yuri-crazy":
						{
							sayori.setPosition(-49, 247);
							natsuki.setPosition(1044, 290);
						}
					case "monika":
						{
							sayori.setPosition(134, 246);
							yuri.setPosition(-74, 176);
							natsuki.setPosition(1044, 290);
							
						}
					case "protag":
						{
							sayori.setPosition(-49, 247);
							yuri.setPosition(379, 176);
							natsuki.setPosition(1044, 290);
							monika.setPosition(1207, 173);
						}	
				}
			}
			else
			{
				switch (SONG.player2)
				{
					case "natsuki":
						{
							sayori.setPosition(-49, 247);
							yuri.setPosition(1044, 178);
							protag.setPosition(379, 152);
							monika.setPosition(1207, 173);
						}
					case "yuri" | "yuri-crazy":
						{
							sayori.setPosition(-49, 247);
							natsuki.setPosition(1044, 290);
							protag.setPosition(379, 152);
							monika.setPosition(1207, 173);
						}
					case "sayori":
						{
							yuri.setPosition(-74, 176);
							natsuki.setPosition(1044, 290);
							protag.setPosition(379, 152);
							monika.setPosition(1207, 173);
						}
					case "monika":
						{
							sayori.setPosition(-49, 247);
							yuri.setPosition(1044, 178);
							natsuki.setPosition(1247, 303);
							protag.setPosition(150, 152);
						}
				}
			}
		}

		for (i in 1...4)
		{
			CoolUtil.precacheSound('missnote' + i);
		}

		switch (SONG.song.toLowerCase())
		{
			case 'deep breaths':
				CoolUtil.precacheSound('exhale');
			case 'obsession':
				CoolUtil.precacheSound('Lights_Shut_off');
				addCharacterToList("yuri-crazy");
			case 'glitcher (monika mix)':
				addCharacterToList("monika");
				addCharacterToList("pixelbf-new");
				addCharacterToList("gf-pixel");
			case 'epiphany':
				addCharacterToList("bigmonika-dead");
				if (storyDifficulty == 2)
					CoolUtil.precacheVoices(SONG.song, '', '_Lyrics');
			case 'neet':
				CoolUtil.precacheSound('spotlight');
			case 'you and me':
				addCharacterToList("yuri");
				addCharacterToList("sayori");
				addCharacterToList("natsuki");
				addCharacterToList("monika");
				addCharacterToList("protag");
				CoolUtil.precacheVoices(SONG.song, '', '_Monika');
				CoolUtil.precacheVoices(SONG.song, '', '_Natsuki');
				CoolUtil.precacheVoices(SONG.song, '', '_Sayori');
				CoolUtil.precacheVoices(SONG.song, '', '_Yuri');
			case 'wilted':
				addCharacterToList("senpai-angynonpixel");
				addCharacterToList("senpai-nonpixel");
				addCharacterToList("monika-pixelnew");
			case 'takeover medley':
				addCharacterToList("monika", 'casual');
				addCharacterToList("monika-pixelnew");
				addCharacterToList("yuri", 'casual');
				addCharacterToList("sayori", 'casual');
				addCharacterToList("natsuki", 'casual');
				addCharacterToList("protag", 'casual');
			case 'libitina':
				libPopup(-42069, -42069, 0, 'Binary', '', 0, false);
				libPopup(-42069, -42069, 0, 'Error', '', 0, false);
				libPopup(-42069, -42069, 0, 'Unauthorized', '', 0, false);
				libPopup(-42069, -42069, 0, 'Unknown', '', 0, false);
				libPopup(-42069, -42069, 0, 'Unspecified', '', 0, false);

				libPopup(-42069, -42069, 0, 'Access', 'red', 0, false);
				libPopup(-42069, -42069, 0, 'Corrupted', 'red', 0, false);

				addCharacterToList("ghost-sketch");
				addCharacterToList("ghost");
		}

		// REPOSITIONING PER STAGE

		addcharacter("", 2);

		// <3 layering
		if (SONG.song.toLowerCase() == 'obsession')
			add(blackScreenBG);

		if (SONG.numofchar >= 4)
		{
			addcharacter("", 4);
			trace('am I here? Probably');
		}

		addcharacter("", 1);
		addcharacter("", 0);

		if (SONG.numofchar >= 3)
		{
			if (SONG.song.toLowerCase() == 'takeover medley')
				addcharacter("", 3, false, 'casual');
			else
				addcharacter("", 3);
			trace('am I here? Probably');
		}
		

		add(preloadGroup);

		if (SONG.song.toLowerCase() == 'obsession')
		{
			add(blackScreentwo);
			blackScreentwo.visible = false;
		}

		switch (curStage)
		{
			case 'va11halla':
				add(dorth);
				whiteflash.cameras = [camGame2];
				whiteflash.makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFFFDC1FF);
				whiteflash.alpha = 0.0001;
				add(whiteflash);
			case 'credits':
				boyfriend.cameras = [camGame2];
				gf.cameras = [camGame2];
				dad.cameras = [camGame2];

				insert(members.indexOf(dad) - 1, p2Box);
				insert(members.indexOf(extrachar1) + 1, p2Boxtop);
				insert(members.indexOf(boyfriend) - 1, p1Box);
				add(p1Boxtop);
				add(cursorDDTO);
				add(staticcredits);
				add(cg1);
				cg2.setGraphicSize(Std.int(cg2.width / defaultCamZoom));
				cg2.updateHitbox();
				cg2.screenCenter();
				add(cg2);
			case 'wilted':
				add(wiltedwindow);
				boyfriend.cameras = [camGame2];
				gf.cameras = [camGame2];
				dad.cameras = [camGame2];
				boyfriend.scrollFactor.set(0.9, 1);
				gf.scrollFactor.set(0.9, 1);
				dad.scrollFactor.set(0.9, 1);
				add(wiltedhey_senpai);
				add(wiltedhey);
				add(wiltedHmph);
			case 'clubroomevil':
				boyfriend.cameras = [camGame2];
				gf.cameras = [camGame2];
				dad.cameras = [camGame2];
				addcharacter("", 0, false, 'hueh');
				add(lightontopofall);
				add(popup);
			case 'musicroom':
				//Funny CGs here
				//Main Moniker
				//CG2 zoomed in on Moni
				//CG2 with all of em zoomed out and paralaxing
				cg1 = new BGSprite('musicroom/CG/cg1', 'doki', 0, 0, 0, 0);
				cg1.alpha = 0.001;
				cg1.cameras = [camHUD];
				cg1.setGraphicSize(Std.int(cg1.width * 0.7));//Smallest 0.67
				cg1.updateHitbox();
				cg1.screenCenter();
				add(cg1);

				//Tween to -954x
				cg2 = new BGSprite('musicroom/CG/cg2', 'doki', -914, -347, 0, 0);
				cg2.alpha = 0.001;
				cg2.cameras = [camHUD];
				add(cg2);

				//I'm not sorry
				cg2Group = new FlxSpriteGroup();
				cg2Group.cameras = [camGame2];
				cg2Group.scrollFactor.set();
				cg2Group.alpha = 0.001;
				add(cg2Group);

				cg2BG = new BGSprite('musicroom/CG/bigone/cg2BG', 'doki', 0, 0, 0, 0);
				cg2BG.ID = 4;
				cg2Group.add(cg2BG);
				cg2Yuri = new BGSprite('musicroom/CG/bigone/cg2Yuri', 'doki', 0, 0, 0, 0);
				cg2Yuri.ID = 3;
				cg2Group.add(cg2Yuri);
				cg2Sayo = new BGSprite('musicroom/CG/bigone/cg2Sayo', 'doki', 0, 0, 0, 0);
				cg2Sayo.ID = 2;
				cg2Group.add(cg2Sayo);
				cg2Natsu = new BGSprite('musicroom/CG/bigone/cg2Natsu', 'doki', 0, 0, 0, 0);
				cg2Natsu.ID = 1;
				cg2Group.add(cg2Natsu);
				cg2Moni = new BGSprite('musicroom/CG/bigone/cg2Moni', 'doki', 0, 0, 0, 0);
				cg2Moni.ID = 0;
				cg2Group.add(cg2Moni);

				cg2Light = new BGSprite('musicroom/CG/bigone/cg2Light', 'doki', 0, 0, 0, 0);
				cg2Light.alpha = 0.001;
				cg2Light.setGraphicSize(Std.int(cg2Light.width / FlxG.camera.zoom));
				cg2Light.updateHitbox();
				cg2Light.screenCenter();
				cg2Light.cameras = [camHUD];
				add(cg2Light);


				whiteflash.makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
				whiteflash.alpha = 0.0001;
				whiteflash.cameras = [camHUD];
				add(whiteflash);
		}

		funnTextGroup = new FlxTypedGroup<FlxText>();
		funnTextGroup.cameras = [camHUD];
		add(funnTextGroup);

		sunshine = new BGSprite('musicroom/SayoSunshine', 'doki', 0, 0, 1, 1);
		sunshine.alpha = 0.001;
		sunshine.cameras = [camHUD];
		add(sunshine);

		encoreborder = new BGSprite('ENCOREBORDER', 'doki', 0, 0, 1, 1);
		encoreborder.alpha = 0.001;
		encoreborder.cameras = [camHUD];
		add(encoreborder);

		waitin = new BGSprite('extraui/lol', 'preload', 153, 720, 0, 0);
		waitin.cameras = [camHUD];
		waitin.alpha = 0.001;
		add(waitin);

		blackbarTop = new BGSprite('TightBars', 'shared', 0, -102, 0, 0);
		blackbarTop.alpha = 0.001;
		blackbarTop.cameras = [camHUD];
		add(blackbarTop);
		blackbarBottom = new BGSprite('TightBars', 'shared', 0, 822, 0, 0);
		blackbarBottom.alpha = 0.001;
		blackbarBottom.cameras = [camHUD];
		add(blackbarBottom);
			

		// Shitty layering but whatev it works LOL
		// thanks ninja muffin :)
		if (curStage == 'dokiclubroom' || curStage == 'dokifestival' || curStage == 'dokiglitcher')
		{
			add(deskfront);

			if (curStage == 'dokifestival' || curStage == 'dokiglitcher')
				add(lights_front);
		}

		if (curStage == 'dokiclubroom')
			add(clubmainlight);

		if (SaveData.shaders)
		{
			if (curStage == 'dokifestival')
			{
				bloomlol = new BloomShader(0.1, 0.005, 0.8, 7.0);
				camGame.setFilters([new ShaderFilter(bloomlol)]);
			}

			if (curStage == 'dokiglitcher')
			{
				bloomlol = new BloomShader(0.1, 0.005, 0.8, 7.0);
				glitchy = new PixelShader();
				camGame.setFilters([new ShaderFilter(glitchy), new ShaderFilter(bloomlol)]);
			}

			if (curStage == 'clubroomevil')
			{
				bloomlol = new BloomShader(0.1, 0.005, 0.95, 8.0);
				camGame.setFilters([new ShaderFilter(bloomlol)]);
			}
		}

		//Stickers (Making them universal for now because why not)
		stickerSprites = new FlxSpriteGroup();
		stickerSprites.cameras = [camHUD];
		stickerSprites.alpha = 0.001;
		add(stickerSprites);

		var funX:Int;
		var funY:Int;
		for (i in 0...galleryData.length)
		{
			if (galleryData[i].startsWith('//'))
				continue;
			var data:Array<String> = galleryData[i].split('::');
			stickerData.push(data[0]);
		}

		for (i in 0...4)
		{
			switch (i)
			{
				default:
					funX = 0;
					funY = 0;
				case 1:
					funX = 1025;
					funY = 0;
				case 2:
					funX = 0;
					funY = 465;
				case 3:
					funX = 1025;
					funY = 465;
			}
			var sticker:BGSprite = new BGSprite('stickies/' + stickerData[0], 'preload', funX, funY, 0, 0);
			sticker.scale.set(0.85, 0.85);
			sticker.updateHitbox();
			stickerSprites.add(sticker);
		}
		
		if (curStage == 'musicroom')
		{
			add(stage_front);
			add(lightoverlay);
		}

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (SaveData.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		laneunderlayOpponent = new FlxSprite(70, 0).makeGraphic(500, FlxG.height * 2, FlxColor.BLACK);
		laneunderlayOpponent.alpha = SaveData.laneTransparency;
		laneunderlayOpponent.scrollFactor.set();
		laneunderlayOpponent.screenCenter(Y);
		laneunderlayOpponent.visible = false;

		laneunderlay = new FlxSprite(70 + (FlxG.width / 2), 0).makeGraphic(500, FlxG.height * 2, FlxColor.BLACK);
		laneunderlay.alpha = SaveData.laneTransparency;
		laneunderlay.scrollFactor.set();
		laneunderlay.screenCenter(Y);
		laneunderlay.visible = false;

		if (SaveData.laneUnderlay)
		{
			add(laneunderlayOpponent);
			add(laneunderlay);
		}

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StrumNote>();
		opponentStrums = new FlxTypedGroup<StrumNote>();

		add(grpNoteSplashes);

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		moveCamera('centered');

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		camGame2.follow(camFollow, LOCKON, 0.04);
		camGame2.zoom = defaultCamZoom;
		camGame2.focusOn(camFollow.getPosition());

		healthBarBG = new FlxSprite(0, FlxG.height * 0.89).loadGraphic(Paths.image('healthBar'));

		switch (SONG.song.toLowerCase())
		{
			default:
				if (SaveData.downScroll)
					healthBarBG.y = FlxG.height * 0.11;
			case 'takeover medley':
				if (SaveData.downScroll)
					healthBarBG.y = FlxG.height * -0.05;
			case 'libitina':
				if (SaveData.downScroll)
					healthBarBG.y = FlxG.height * 0.025;
				else
					healthBarBG.y = FlxG.height * 0.9;
		}

		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
		healthBar.fillDirection = mirrormode ? LEFT_TO_RIGHT : RIGHT_TO_LEFT;
		healthBar.scrollFactor.set();

		if (mirrormode)
			healthBar.createFilledBar(boyfriend.barColor, dad.barColor);
		else
			healthBar.createFilledBar(dad.barColor, boyfriend.barColor);

		add(healthBar);

		scoreTxt = new FlxText(0, healthBarBG.y + 48, 0, "", 20);
		scoreTxt.setFormat(LangUtil.getFont(), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.y += LangUtil.getFontOffset();
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		if (SaveData.globalAntialiasing) scoreTxt.antialiasing = !isPixelUI;
		scoreTxt.text = Ratings.CalculateRanking((practiceMode ? practiceScore : songScore), nps, maxNPS, accuracy);

		switch (SONG.song.toLowerCase())
		{
			case 'libitina':
				scoreTxt.y -= 15;
		}

		// lyics
		try
		{
			var lyricFile = CoolUtil.coolTextFile(Paths.txt('data/songs/${SONG.song.toLowerCase()}/lyrics'));

			for (i in 0...lyricFile.length)
			{
				var data:Array<String> = lyricFile[i].split('::');
				lyricData.push([Std.parseInt(data[0]), data[1]]);
			}

			hasLyrics = true;
		}
		catch (e)
		{
			hasLyrics = false;
		}

		if (hasLyrics)
		{
			lyrics = new FlxText();
			lyrics.setFormat(LangUtil.getFont('grotesk'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			lyrics.screenCenter(X);
			lyrics.y = (FlxG.height * 0.72) + LangUtil.getFontOffset('grotesk');
			lyrics.borderSize = 1.25;
			lyrics.antialiasing = SaveData.globalAntialiasing;
			lyrics.cameras = [camHUD];
			add(lyrics);
		}

		judgementCounter = new FlxText(20, 0, 0, "", 20);
		judgementCounter.setFormat(LangUtil.getFont(), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();

		if (SaveData.globalAntialiasing)
			judgementCounter.antialiasing = !isPixelUI;

		if (SaveData.judgementCounter)
		{
			judgementCounter.text = 'Doki: ${sicks}\nGood: ${goods}\nOk: ${bads}\nNo: ${shits}\nMiss: ${misses}\n';
			if (SaveData.earlyLate) judgementCounter.text += '\nEarly: ${earlys}\nLate: ${lates}\n';
			judgementCounter.text += '\n${LangUtil.getString('cmnMax')}: ${maxCombo}\n';
			add(judgementCounter);
		}

		judgementCounter.screenCenter(Y);
		judgementCounter.y += LangUtil.getFontOffset() + 20;

		botPlayState = new FlxText(0, strumLine.y + 30, 0, LangUtil.getString('cmnBotplay').toUpperCase(), 32);
		botPlayState.setFormat(LangUtil.getFont('riffic'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.y += LangUtil.getFontOffset();
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 1.25;
		if (SaveData.globalAntialiasing)
			botPlayState.antialiasing = !isPixelUI;
		botPlayState.screenCenter(X);
		if (toggleBotplay)
			add(botPlayState);

		practiceTxt = new FlxText(0, strumLine.y + 30, 0, LangUtil.getString('cmnPractice').toUpperCase(), 32);
		practiceTxt.setFormat(LangUtil.getFont('riffic'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		practiceTxt.y += LangUtil.getFontOffset();
		practiceTxt.scrollFactor.set();
		practiceTxt.borderSize = 1.25;
		if (SaveData.globalAntialiasing)
			practiceTxt.antialiasing = !isPixelUI;
		practiceTxt.screenCenter(X);
		if (!toggleBotplay)
			add(practiceTxt);

		if (isPixelUI)
		{
			scoreTxt.font = LangUtil.getFont('vcr');
			judgementCounter.font = LangUtil.getFont('vcr');
			botPlayState.font = LangUtil.getFont('vcr');
			practiceTxt.font = LangUtil.getFont('vcr');

			judgementCounter.screenCenter(Y);
			judgementCounter.y += LangUtil.getFontOffset() + 20;
		}

		trace(boyfriend.healthIcon);
		trace(dad.healthIcon);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		add(iconP2);

		// layering due to icons
		add(scoreTxt);

		var name:String = (hasMetadata ? metadata.song.name : SONG.song);
		var icon:String = (hasMetadata ? metadata.song.icon : 'pen');
		var encoreCredits:String = (storyDifficulty == 2 ? metadata.song.artist_encore : metadata.song.artist);
		var artist:String = (hasMetadata ? encoreCredits + '\n' : '');

		metadataDisplay = new MetadataDisplay(name, icon, artist);
		add(metadataDisplay);

		positionDisplay = new PositionDisplay(name, boyfriend, dad, songLength);

		if (positionBar)
			insert(members.indexOf(healthBar), positionDisplay);

		positionDisplay.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botPlayState.cameras = [camHUD];
		practiceTxt.cameras = [camHUD];
		laneunderlayOpponent.cameras = [camHUD];
		laneunderlay.cameras = [camHUD];
		judgementCounter.cameras = [camHUD];

		metadataDisplay.cameras = [camOverlay];

		if (curStage == 'dokiclubroom' || curStage == 'dokifestival')
			add(staticshock);

		startingSong = true;
		isintro = true;
		if (showCutscene && !ForceDisableDialogue)
		{
			if (isStoryMode)
			{
				switch (curSong.toLowerCase())
				{
					default:
						if (introDoof != null)
							introcutscene();
						else
							startCountdown();

					case 'crucify (yuri mix)':
						preintrocutscene();

					case 'hot air balloon':
						customstart();
					case 'shrinking violet':
						customstart();
					case 'joyride':
						customstart();

					case 'our harmony':
						customstart();

					case 'you and me':
						customstart();

					case 'love n funkin':
						customstart();

					case 'constricted':
						customstart();

					case 'wilted':
						customstart();

					case 'takeover medley':
						customstart();

					case 'libitina':
						customstart();

					case 'drinks on me':
						customstart();
				}
			}
			else
			{
				switch (curSong.toLowerCase())
				{
					case 'dual demise' | 'your demise' | 'epiphany' | 'wilted' | 'you and me' | 'libitina' | 'takeover medley' | 'drinks on me' | 'our harmony' | 'love n funkin' | 'constricted':
						customstart();
					default:
						startCountdown();
				}
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case 'dual demise' | 'your demise' | 'epiphany' | 'wilted' | 'you and me' | 'libitina' | 'takeover medley' | 'drinks on me' | 'our harmony' | 'love n funkin' | 'constricted':
					customstart();
				default:
					startCountdown();
			}
		}

		// This allows arrow keys to be detected by flixel. See https://github.com/HaxeFlixel/flixel/issues/2190
		FlxG.keys.preventDefaultKeys = [];

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		if (SaveData.hitSound) HitSoundManager.init();
		FlxG.mouse.visible = false;
		super.create();

		CustomFadeTransition.nextCamera = camOverlay;

		Paths.clearUnusedMemory();
	}

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			var ratio:Float = value / songSpeed; // funny word huh
			for (note in notes)
			{
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	override function destroy()
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		FlxG.mouse.visible = true;
		super.destroy();
	}

	function customstart():Void
	{
		var dialogueBox:DialogueBox = introDoof;

		if (dialogueBox != null)
		{
			dialogueBox.cameras = [camOverlay];
			dialogueBox.finishThing = startCountdown;
		}

		switch (curSong.toLowerCase())
		{
			case 'hot air balloon' | 'shrinking violet' | 'joyride':
				if (isStoryMode && showCutscene)
				{
					dad.alpha = 0.001;
					introcutscene();
				}
				else
				{
					startCountdown();
				}
			case 'our harmony':
				iconP2.changeIcon('our-harmony');
				if (isStoryMode && showCutscene)
					introcutscene();
				else
					startCountdown();
			case 'constricted':
				bgDokis.visible = false;

				if (isStoryMode && showCutscene)
				{
					add(blackScreen);
					introcutscene();
				}
				else
					startCountdown();
			case 'love n funkin':
				boyfriend.x += 230;
				gf.x += 85;
				gf.y += 320;

				dad.x -= 5;
				if (extrachar1 != null) extrachar1.x -= 5;
				if (extrachar2 != null) extrachar2.x += 5;

				add(poemVideo);
				add(sideWindow);

				if (isStoryMode && showCutscene)
				{
					add(blackScreen);
					introcutscene();
				}
				else
					startCountdown();
			case 'libitina':
				/*
				songName.font = LangUtil.getFont('dos');
				scoreTxt.font = LangUtil.getFont('dos');
				judgementCounter.font = LangUtil.getFont('dos');
				botPlayState.font = LangUtil.getFont('dos');
				practiceTxt.font = LangUtil.getFont('dos');
				*/

				boyfriend.alpha = 0.001;

				blackScreen.cameras = [camOverlay];
				add(blackScreen);
				
				camHUD.alpha = 0.001;
				iconP1.alpha = 0.001;
				healthBar.alpha = 0.001;
				healthBarBG.alpha = 0.001;
				scoreTxt.alpha = 0.001;

				if (SaveData.judgementCounter)
					judgementCounter.alpha = 0.001;

				laneunderlay.alpha = 0.001;
				laneunderlayOpponent.alpha = 0.001;

				scorePop = false;
				if (isStoryMode && showCutscene)
				{
					#if (FEATURE_MP4 || FEATURE_VIDEO)
					var video:NetStreamHandler = new NetStreamHandler();
					video.canSkip = SaveData.beatLibitina;
					video.skipKeys = [FlxKey.ENTER];
					video.playVideo(Paths.video('metaintro'), false, true);
					video.finishCallback = function()
					{
						startCountdown();
					}
					#else
					startCountdown();
					#end
				}
				else
				{
					startCountdown();
				}
			case 'drinks on me':
				// move jill behind gf
				remove(dad);
				insert(members.indexOf(gf), dad);

				//Was being layered under the entire hud for some reason
				iconP2.alpha = 0.001;
				iconP1.alpha = 0.001;
				healthBar.alpha = 0.001;
				healthBarBG.alpha = 0.001;
				scoreTxt.alpha = 0.001;

				add(blackScreen);
				blackScreen.cameras = [camHUD];
				blackScreen.alpha = 1;
				cg1 = new BGSprite('va11halla/intro1', 'doki', 0, 0, 0, 0);
				cg1.antialiasing = false;
				cg1.alpha = 0.001;
				cg1.cameras = [camHUD];
				cg1.screenCenter();
				add(cg1);
				cg2 = new BGSprite('va11halla/intro2', 'doki', 0, 0, 0, 0);
				cg2.antialiasing = false;
				cg2.alpha = 0.001;
				cg2.cameras = [camHUD];
				add(cg2);

				startCountdown();
			case 'you and me':
				add(whiteflash);
				whiteflash.cameras = [camHUD];
				whiteflash.alpha = 1;
				cameraSpeed = 10;
				iconP2.alpha = 0.001;
				dad.alpha = 0.001;

				iconP1.alpha = 0.001;
				healthBar.alpha = 0.001;
				healthBarBG.alpha = 0.001;
				scoreTxt.alpha = 0.001;

				if (SaveData.judgementCounter)
					judgementCounter.alpha = 0.001;

				laneunderlay.alpha = 0.001;
				laneunderlayOpponent.alpha = 0.001;

				camFollow.x = 589;
				camFollow.y = -3004;
				camFocus = false;
				startCountdown();
			case 'takeover medley':
				dad.visible = false;
				healthBarBG.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				extrachar1.alpha = 0.001;
				camFocus = false;
				camHUD.alpha = 0.001;
				moveCamera("centered");
				camFollow.y = -930;
				add(blackScreen);
				blackScreen.cameras = [camGame2];
				blackScreen.alpha = 1;
				whiteflash.makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
				whiteflash.alpha = 0.0001;
				whiteflash.cameras = [camGame2];
				add(whiteflash);

				
				startCountdown();
			case 'wilted':
				add(whiteflash);
				whiteflash.cameras = [camGame2];
				whiteflash.alpha = 1;
				remove(gf);

				if (isStoryMode && showCutscene)
				{
					camHUD.visible = false;
					new FlxTimer().start(1.2, function(godlike:FlxTimer)
					{
						if (dialogueBox != null)
						{
							inCutscene = true;
							add(dialogueBox);
						}
						else
						{
							startCountdown();
						}
					});
				}
				else
				{
					startCountdown();
				}
			case 'dual demise':
				iconP2.changeIcon('dual-demise');
				startCountdown();
			case 'your demise':
				add(blackScreen);
				blackScreen.alpha = 0.0001;
				startCountdown();
			case 'epiphany':
				if (storyDifficulty == 2)
					addcharacter("bigmonika-dress", 1);
				else
					lyrics.visible = false;

				dad.cameras = [camGame2];

				remove(gf);
				remove(boyfriend);
				
				if (showCutscene && !ForceDisableDialogue)
				{
					remove(gf);
					remove(boyfriend);
					camHUD.visible = false;
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
				else
					startCountdown();
			default:
				startCountdown();
		}
	}

	function endcutscene():Void
	{
		var dialogueBox:DialogueBox = endDoof;

		if (dialogueBox != null)
		{
			dialogueBox.cameras = [camOverlay];
			dialogueBox.finishThing = endSong;
		}

		vocals.pause();
		FlxG.sound.music.pause();
		inCutscene = true;
		camZooming = false;
		startedCountdown = false;
		generatedMusic = false;
		canPause = false;
		vocals.stop();
		vocals.volume = 0;

		switch (curSong.toLowerCase())
		{
			case 'my confession':
				add(blackScreen);
				blackScreen.cameras = [camOverlay];
				blackScreen.alpha = 0.1;
				FlxTween.tween(blackScreen, {alpha: 1}, 4, {
					ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween)
					{
						camHUD.visible = false;
						var imageBG:FlxSprite = new FlxSprite(0, 0);
						imageBG.loadGraphic(Paths.image('dialogue/bgs/ending1', 'doki'));
						imageBG.antialiasing = false;
						imageBG.scrollFactor.set();
						imageBG.setGraphicSize(Std.int(imageBG.width / FlxG.camera.zoom));
						imageBG.updateHitbox();
						imageBG.screenCenter();
						add(imageBG);

						FlxTween.tween(blackScreen, {alpha: 0}, 4, {
							ease: FlxEase.expoOut,
							onComplete: function(twn:FlxTween)
							{
								if (dialogueBox != null)
								{
									moveCamera("centered");
									add(dialogueBox);
								}
								else
								{
									endSong();
								}
							}
						});
					}
				});
			case 'baka':
				add(blackScreen);
				blackScreen.cameras = [camOverlay];
				blackScreen.alpha = 0.1;
				FlxTween.tween(blackScreen, {alpha: 1}, 4, {
					ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween)
					{
						camHUD.visible = false;
						var imageBG:FlxSprite = new FlxSprite(0, 0);
						imageBG.loadGraphic(Paths.image('dialogue/bgs/ending2', 'doki'));
						imageBG.antialiasing = false;
						imageBG.scrollFactor.set();
						imageBG.setGraphicSize(Std.int(imageBG.width / FlxG.camera.zoom));
						imageBG.updateHitbox();
						imageBG.screenCenter();
						add(imageBG);

						FlxTween.tween(blackScreen, {alpha: 0}, 4, {
							ease: FlxEase.expoOut,
							onComplete: function(twn:FlxTween)
							{
								if (dialogueBox != null)
								{
									moveCamera("centered");
									add(dialogueBox);
								}
								else
								{
									endSong();
								}
							}
						});
					}
				});
			case 'our harmony':
				for (item in cg2Group.members)
					FlxTween.cancelTweensOf(item);

				camHUD.visible = false;

				if (dialogueBox != null)
				{
					moveCamera("centered");
					add(dialogueBox);
				}
				else
				{
					endSong();
				}
			case 'you and me':
				camHUD.visible = false;

				FlxG.camera.fade(FlxColor.BLACK, CoolUtil.calcSectionLength(), false, function() {
					if (dialogueBox != null)
					{
						moveCamera("centered");
						add(dialogueBox);
					}
					else
					{
						endSong();
					}
				});
			default:
				camHUD.visible = false;

				if (dialogueBox != null)
				{
					moveCamera("centered");
					add(dialogueBox);
				}
				else
				{
					endSong();
				}
		}
		trace(inCutscene);
	}

	var curCutscene:String = '';
	var endsceneone:FlxSprite;
	var monikatransformer:FlxSprite;

	public function playbackCutscene(id:String, length:Float):Void
	{
		switch (id)
		{
			case 'fakeout':
			{
				var schoolFakeout:FlxSprite = new FlxSprite(400, 200);
				schoolFakeout.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
				schoolFakeout.animation.addByPrefix('idle', 'background 2', 24);
				schoolFakeout.animation.play('idle');
				schoolFakeout.scrollFactor.set(0.8, 0.9);
				schoolFakeout.scale.set(6, 6);
				add(schoolFakeout);
				FlxG.sound.play(Paths.sound('awhellnaw')); // THEY ON THAT SPUNCHBOB SHIT

				new FlxTimer().start(1.3, function(timer:FlxTimer)
				{
					new FlxTimer().start(0.5, function(timer:FlxTimer)
					{
						blackScreentwo.alpha = 1;
						blackScreentwo.visible = true;
						add(blackScreentwo);
					});

					#if (FEATURE_MP4 || FEATURE_VIDEO)
					var video:NetStreamHandler = new NetStreamHandler();
					video.canSkip = SaveData.beatPrologue;
					video.skipKeys = [FlxKey.ENTER];
					video.playVideo(Paths.video('monika'), false, true);
					video.finishCallback = function()
					{
						endSong();
					}
					#else
					endSong();
					#end
				});
			}
			case 'pixelend':
			{
				endsceneone = new FlxSprite();
				endsceneone.frames = Paths.getSparrowAtlas('weeb/cutscene/End1', 'week6');
				endsceneone.animation.addByPrefix('idle', 'Endscene', 24, false);
				endsceneone.scrollFactor.set();
				endsceneone.setGraphicSize(Std.int(FlxG.width / FlxG.camera.zoom) + 6, Std.int(FlxG.height / FlxG.camera.zoom));
				endsceneone.updateHitbox();
				endsceneone.screenCenter();
				endsceneone.x += 3;
				endsceneone.animation.play('idle');
				add(endsceneone);

				new FlxTimer().start(2.2, function(swagTimer:FlxTimer)
				{
					FlxG.sound.play(Paths.sound('dah'));
				});
			}
			case 'dokiexit':
			{
				blackScreen.cameras = [camOverlay];
				blackScreen.alpha = 0;
				add(blackScreen);

				FlxTween.tween(blackScreen, {alpha: 1}, 2, {
					ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween)
					{
						bgDokis.visible = false;
						FlxTween.tween(blackScreen, {alpha: 0}, 4, {ease: FlxEase.expoInOut});
					}
				});
			}
			case 'monikatransform':
			{
				#if (FEATURE_MP4 || FEATURE_VIDEO)
				var video:NetStreamHandler = new NetStreamHandler();
				video.canSkip = false;
				video.playVideo(Paths.video('monikacodin'));
				#end
			}
			case 'senpaitransform':
			{
				#if (FEATURE_MP4 || FEATURE_VIDEO)
				var video:NetStreamHandler = new NetStreamHandler();
				video.canSkip = false;
				video.playVideo(Paths.video('senpaicodin'));
				#end
			}
			case 'youregoingtophilly':
			{
				#if (FEATURE_MP4 || FEATURE_VIDEO)
				var video:NetStreamHandler = new NetStreamHandler();
				video.canSkip = false;
				video.playVideo(Paths.video('youregoingtophilly'));
				#end
			}
			case 'wiltedbgin':
			{
				//Maybe play a sound effect here idk
				whiteflash.makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				whiteflash.alpha = 0.001;
				FlxTween.tween(whiteflash, {alpha: 1}, length, {ease: FlxEase.sineOut});
			}
			case 'wiltedbgout':
			{
				//Maybe play a sound effect here idk
				wiltswap(0, true);
				whiteflash.makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
				whiteflash.alpha = 1;
				FlxTween.tween(whiteflash, {alpha: 0.001}, length, {ease: FlxEase.sineOut});
			}
			case 'fadetoblack':
			{
				FlxG.camera.fade(FlxColor.BLACK, length, false);
			}
			case 'showdad':
			{
				dad.alpha = 1;
			}
		}

		curCutscene = id;
	}

	public function cleanupCutscene():Void
	{
		switch (curCutscene)
		{
			case 'pixelend':
			{
				remove(endsceneone);
			}
			case 'monikatransform':
			{
				remove(blackScreentwo);
				remove(monikatransformer);
			}
		}

		curCutscene = '';
	}

	function obsessionending():Void
	{
		endingSong = true;
		camHUD.visible = false;

		if (toggleBotplay)
			toggleBotplay = false;

		campaignScore += Math.round(songScore);

		Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
		Highscore.saveCombo(SONG.song, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
		Highscore.saveAccuracy(SONG.song, accuracy, storyDifficulty);
		Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

		SaveData.beatYuri = true;
		SaveData.save();
	}

	function preintrocutscene():Void
	{
		var dialogueBox:DialogueBox = introDoof;

		if (dialogueBox != null)
		{
			dialogueBox.cameras = [camOverlay];
			dialogueBox.finishThing = startCountdown;
		}

		camHUD.visible = false;
		switch (SONG.song.toLowerCase())
		{
			case "crucify (yuri mix)":
				imageBG = new FlxSprite().loadGraphic(Paths.image('dialogue/bgs/festivalbeginning', 'doki'));
				imageBG.antialiasing = SaveData.globalAntialiasing;
				imageBG.cameras = [camOverlay];
				add(imageBG);
		}

		new FlxTimer().start(1.5, function(godlike:FlxTimer)
		{
			if (dialogueBox != null)
			{
				inCutscene = true;
				add(dialogueBox);

				new FlxTimer().start(1.1, function(tmr:FlxTimer)
				{
					remove(imageBG);
				});
			}
			else
			{
				remove(imageBG);
				startCountdown();
			}
		});
	}

	function introcutscene():Void
	{
		var dialogueBox:DialogueBox = introDoof;

		if (dialogueBox != null)
		{
			dialogueBox.cameras = [camOverlay];
			dialogueBox.finishThing = startCountdown;
		}

		camHUD.visible = false;

		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();

		moveCamera('centered');

		switch (SONG.song.toLowerCase())
		{
			case "your demise":
				{
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
					//dad.playAnim('cutsceneidle'); //disabled until further notice

					new FlxTimer().start(1.2, function(godlike:FlxTimer)
					{
						if (dialogueBox != null)
						{
							inCutscene = true;
							/* disabled until further notice
							dialogueBox.finishThing = function()
							{
								dad.playAnim('cutscenetransition');
								new FlxTimer().start(1.2, function(godlike:FlxTimer)
								{
									dad.dance(isAltAnimSection());
									startCountdown();
								});
							};
							*/
							add(dialogueBox);
						}
						else
							startCountdown();
					});
				}

			case "high school conflict":
				{
					add(black);
					new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						black.alpha -= 0.1;

						if (black.alpha > 0)
							tmr.reset(0.3);
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
			case "constricted":
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

	function startCountdown():Void
	{
		camHUD.visible = true;

		if (camHUD.alpha != 0 && inCutscene && !isPixelUI)
		{
			camHUD.alpha = 0;
			FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.linear});
		}

		midsongcutscene = true;
		incutsceneforendingsmh = false;
		showCutscene = false;
		inCutscene = false;

		generateStaticArrows(0, SONG.noteStyle);
		generateStaticArrows(1, SONG.noteStyle);

		switch (curSong.toLowerCase())
		{
			case 'hot air balloon' | 'shrinking violet' | 'joyride':
				dad.alpha = 1;
			case 'catfight':
				var who:String;
				var anim:String;
				who = (isYuri ? 'catfightYuriPopup' : 'catfightNatPopup');
				anim = (isYuri ? 'PopUpYuri' : 'PopUpNatsuki');
				var catpopup:BGSprite = new BGSprite('extraui/' + who, 'preload', 400, 400, 1, 1, ['idle', anim]);
				catpopup.setGraphicSize(Std.int(catpopup.width * 0.7));
				catpopup.updateHitbox();
				add(catpopup);
			case 'wilted':
				wiltswap(0, true);
			case 'love n funkin' | 'constricted':
				if (blackScreen != null)
					FlxTween.tween(blackScreen, {alpha: 0.001}, CoolUtil.calcSectionLength(0.25), {ease: FlxEase.sineOut});
		}

		if (coolgameplay && !isStoryMode)
		{
			hueh231 = new FlxSprite();
			hueh231.frames = Paths.getSparrowAtlas('coolgameplay/coolgameplay', 'doki');
			hueh231.animation.addByPrefix('idle', 'Symbol', 24, true);
			hueh231.animation.play('idle');
			hueh231.antialiasing = SaveData.globalAntialiasing;
			hueh231.scrollFactor.set();
			hueh231.setGraphicSize(Std.int(hueh231.width / FlxG.camera.zoom));
			hueh231.updateHitbox();
			hueh231.screenCenter();
			hueh231.cameras = [camGame2];
			add(hueh231);
		}

		if (middleScroll)
		{
			laneunderlayOpponent.alpha = 0;
			laneunderlay.screenCenter(X);
		}

		startedCountdown = true;

		var allowCountdown:Bool = true;
		
		if (hasMetadata && metadata.song.allowCountDown == false)
			allowCountdown = metadata.song.allowCountDown;

		if (!allowCountdown)
		{
			Conductor.songPosition = -CoolUtil.calcSectionLength(0.25) * 1000;
			startTimer = new FlxTimer().start(CoolUtil.calcSectionLength(0.25), function(tmr:FlxTimer)
			{
				if (SONG.song.toLowerCase() == 'catfight')
					gf.playAnim('gone');
				else
					gf.dance();

				if (boyfriend.danceIdle && !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.dance(isAltAnimSection());

				if (dad.danceIdle && !dad.animation.curAnim.name.endsWith('miss'))
					dad.dance(isAltAnimSection());

				if (SONG.numofchar >= 3)
				{
					if (extrachar1.danceIdle)
						extrachar1.dance(isAltAnimSection());
				}
				if (SONG.numofchar >= 4)
				{
					if (extrachar2.danceIdle)
						extrachar2.dance(isAltAnimSection());
				}

				if (metadataDisplay != null)
				{
					if ((hasMetadata && !metadata.song.playManually) || !hasMetadata)
						metadataDisplay.tweenIn();
				}
				else
					trace('uhhhh that metadata display is null');

				new FlxTimer().start(CoolUtil.calcSectionLength() + 3, function(tmr:FlxTimer)
				{
					if (metadataDisplay != null)
					{
						if ((hasMetadata && !metadata.song.playManually) || !hasMetadata)
							metadataDisplay.tweenOut();
					}
					else
						trace('metadata display is still null my dude');
				});
			});
		}
		else
		{
			Conductor.songPosition = -(Conductor.crochet * 5) / Conductor.playbackSpeed;

			var swagCounter:Int = 0;
			startTimer = new FlxTimer().start(Conductor.crochet / 1000 * (1 / Conductor.playbackSpeed), function(tmr:FlxTimer)
			{
				if (SaveData.gfCountdown && gf.curCharacter == 'gf-realdoki')
				{
				}
				else if (swagCounter % gfSpeed == 0)
				{
					if (SONG.song.toLowerCase() == 'catfight')
						gf.playAnim('gone');
					else
						gf.dance();
				}

				if (swagCounter % 2 == 0)
				{
					if (!boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance(isAltAnimSection());

					if (!dad.animation.curAnim.name.endsWith('miss'))
						dad.dance(isAltAnimSection());

					if (SONG.numofchar >= 3 && !extrachar1.animation.curAnim.name.endsWith('miss'))
						extrachar1.dance(isAltAnimSection());

					if (SONG.numofchar >= 4 && !extrachar2.animation.curAnim.name.endsWith('miss'))
						extrachar2.dance(isAltAnimSection());

					if (curStage.startsWith('doki'))
					{
						if (monika != null)
							monika.dance(true);
						if (protag != null)
							protag.dance(true);
						sayori.dance(true);
						natsuki.dance(true);
						yuri.dance(true);
					}
				}
				else if (swagCounter % 2 != 0)
				{
					if (boyfriend.danceIdle && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance(isAltAnimSection());

					if (dad.danceIdle && !dad.animation.curAnim.name.endsWith('miss'))
						dad.dance(isAltAnimSection());

					if (SONG.numofchar >= 3)
					{
						if (extrachar1.danceIdle && !extrachar1.animation.curAnim.name.endsWith('miss'))
							extrachar1.dance(isAltAnimSection());
					}
					if (SONG.numofchar >= 4)
					{
						if (extrachar2.danceIdle && !extrachar2.animation.curAnim.name.endsWith('miss'))
							extrachar2.dance(isAltAnimSection());
					}
				}

				if (curSong.toLowerCase() == "bara no yume" || curSong.toLowerCase() == "poems n thorns")
					bgGirls.dance();

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', "set", "go"]);
				introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
				introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/demise-date']);
				introAssets.set('schoolEvilEX', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/demise-date']);

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
						if (metadataDisplay != null)
						{
							if ((hasMetadata && !metadata.song.playManually) || !hasMetadata)
								metadataDisplay.tweenIn();
						}
						else
							trace('uhhhh that metadata display is null');

						if (curStage.startsWith('schoolEvil') || curStage.startsWith('schoolEvilEX'))
							FlxG.sound.play(Paths.sound('intro3' + glitchSuffix), 0.6);
						else
							FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);

						if (SaveData.gfCountdown && gf.curCharacter == 'gf-realdoki')
							gf.playAnim('countdownThree');
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.cameras = [camHUD];

						if (!curStage.startsWith('school'))
						{
							ready.setGraphicSize(Std.int(ready.width * 0.6));
							ready.antialiasing = SaveData.globalAntialiasing;
						}
						else
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

						ready.updateHitbox();
						ready.screenCenter();
						add(ready);

						FlxTween.tween(ready, {alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});

						if (curStage.startsWith('schoolEvil') || curStage.startsWith('schoolEvilEX'))
							FlxG.sound.play(Paths.sound('intro2' + glitchSuffix), 0.6);
						else
							FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);

						if (SaveData.gfCountdown && gf.curCharacter == 'gf-realdoki')
							gf.playAnim('countdownTwo');
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();
						set.cameras = [camHUD];

						if (!curStage.startsWith('school'))
						{
							set.setGraphicSize(Std.int(set.width * 0.6));
							set.antialiasing = SaveData.globalAntialiasing;
						}
						else
							set.setGraphicSize(Std.int(set.width * daPixelZoom));

						set.updateHitbox();
						set.screenCenter();
						add(set);

						FlxTween.tween(set, {alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});

						if (curStage.startsWith('schoolEvil') || curStage.startsWith('schoolEvilEX'))
							FlxG.sound.play(Paths.sound('intro1' + glitchSuffix), 0.6);
						else
							FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);

						if (SaveData.gfCountdown && gf.curCharacter == 'gf-realdoki')
							gf.playAnim('countdownOne');
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();
						go.cameras = [camHUD];

						if (!curStage.startsWith('school'))
						{
							go.setGraphicSize(Std.int(go.width * 0.6));
							go.antialiasing = SaveData.globalAntialiasing;
						}
						else
							go.setGraphicSize(Std.int(go.width * daPixelZoom));

						go.updateHitbox();
						go.screenCenter();
						add(go);

						FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});

						if (curStage.startsWith('schoolEvil') || curStage.startsWith('schoolEvilEX'))
							FlxG.sound.play(Paths.sound('introGo' + glitchSuffix), 0.6);
						else
							FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);

						if (SaveData.gfCountdown && gf.curCharacter == 'gf-realdoki')
							gf.playAnim('countdownGo');
					case 4:
						new FlxTimer().start(3, function(tmr:FlxTimer)
						{
							if (metadataDisplay != null)
							{
								if ((hasMetadata && !metadata.song.playManually) || !hasMetadata)
									metadataDisplay.tweenOut();
							}
							else
								trace('metadata display is still null my dude');
						});

						if (SaveData.gfCountdown && gf.curCharacter == 'gf-realdoki')
							gf.dance();
				}

				swagCounter += 1;
			}, 5);
		}
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	var songStarted = false;

	function startSong():Void
	{
		incutsceneforendingsmh = false;

		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;

		FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
		FlxG.sound.music.pitch = Conductor.playbackSpeed;
		FlxG.sound.music.onComplete = songOutro;

		vocals.play();
		vocals.pitch = Conductor.playbackSpeed;
		vocals.onComplete = function()
		{
			vocalsFinished = true;
		}

		if (curSong.toLowerCase() == 'epiphany' && storyDifficulty == 2)
			changeVocalTrack('', '_Lyrics');

		if (paused)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// jump past the empty start that only exists for camera syncing
		if (curSong.toLowerCase() == 'poems n thorns')
		{
			var length:Float = CoolUtil.calcSectionLength(0.5) * 1000;

			FlxG.sound.music.time = length;
			Conductor.songPosition = length;
			vocals.time = length;
		}

		if (sectionStart)
		{
			zoomStuff = false;
			FlxG.sound.music.time = sectionStartTime;
			Conductor.songPosition = sectionStartTime;
			vocals.time = sectionStartTime;
		}

		if ((hasMetadata && !metadata.song.playManually) || !hasMetadata || !isStoryMode)
			positionDisplay.tweenIn();

		#if FEATURE_DISCORD
		updateDiscordPresence();
		#end
	}

	private function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		if (constantScroll)
			songSpeed = SaveData.scrollSpeed;
		else
			songSpeed = SONG.speed;

		curSong = songData.song;

		// FLAVOR RAVE GO
		switch (curSong.toLowerCase())
		{
			case 'our harmony' | 'you and me':
				happyEnding = true;
		}

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		var tempMusic:FlxSound = new FlxSound().loadEmbedded(Paths.inst(SONG.song));

		// Song duration in a float, useful for the time left feature
		songLength = tempMusic.length / 1000;
		#if FEATURE_DISCORD
		songLengthDiscord = tempMusic.length;
		#end

		tempMusic.destroy();

		notes = new FlxTypedGroup<Note>();
		add(notes);

		generateNotes();
		generatedMusic = true;
	}

	function generateNotes(?addon:String)
	{
		var songData;
		//Kinda winging it
		if (addon == null)
			songData = SONG;
		else
		{
			var extraNotes:SwagSong = Song.loadFromJson(addon, SONG.song);
			songData = extraNotes;
		}

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			if (sectionStart && daBeats < sectionStartPoint)
			{
				daBeats++;
				continue;
			}

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int((randommode ? FlxG.random.int(0, 7) : songNotes[1]) % 4);

				var gottaHitNote:Bool = (mirrormode ? !section.mustHitSection : section.mustHitSection);

				if (songNotes[1] > 3)
					gottaHitNote = (mirrormode ? section.mustHitSection : !section.mustHitSection);

				if (randommode && songNotes[3] == 2)
					continue;

				if (SONG.song.toLowerCase() == 'catfight' && gottaHitNote && songNotes[3] == 6)
					continue;

				var noteStyle:String = SONG.noteStyle;

				if (section.noteSwap)
				{
					if (curStage == "dokiglitcher"
						|| (curStage == "wilted" && (gottaHitNote && !mirrormode || !gottaHitNote && mirrormode)))
					{
						noteStyle = "pixel";
					}
				}
				else if (curStage == "wilted" && (gottaHitNote && mirrormode || !gottaHitNote && !mirrormode))
				{
					noteStyle = "pixel";
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, songNotes[3], noteStyle);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if (floorSus > 0)
				{
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime
							+ (Conductor.stepCrochet * susNote)
							+ (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData,
							oldNote, true, songNotes[3], noteStyle);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
							sustainNote.x += FlxG.width / 2; // general offset
						else if (middleScroll)
						{
							sustainNote.x += 310;

							if (daNoteData > 1) // Up and Right
								sustainNote.x += FlxG.width / 2 + 20;
						}
					}
				}

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2; // general offset
				else if (middleScroll)
				{
					swagNote.x += 310;

					if (daNoteData > 1) // Up and Right
						swagNote.x += FlxG.width / 2 + 20;
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int, noteStyle:String, tweenIn:Bool = true, middlescroll:Bool = false):Void
	{
		if (SaveData.laneUnderlay)
		{
			laneunderlayOpponent.visible = true;
			laneunderlay.visible = true;
		}

		var TRUE_STRUM_X:Float = STRUM_X;
		var TRUE_STRUM_X_MIDDLESCROLL:Float = STRUM_X_MIDDLESCROLL;

		if (noteStyle == 'pixel')
		{
			TRUE_STRUM_X += 2;
			TRUE_STRUM_X_MIDDLESCROLL += 3;
		}

		if (!middlescroll)
		{
			middlescroll = middleScroll;
		}

		for (i in 0...4)
		{
			var targetAlpha:Float = 1;

			if (player < 1 && middlescroll)
				targetAlpha = SaveData.middleOpponent ? 0.35 : 0;

			var babyArrow:StrumNote = new StrumNote(middlescroll ? TRUE_STRUM_X_MIDDLESCROLL : TRUE_STRUM_X, strumLine.y, i, player, noteStyle);
			babyArrow.downScroll = SaveData.downScroll;

			if (tweenIn)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				if (SONG.song.toLowerCase() != 'you and me' && SONG.song.toLowerCase() != 'libitina' && SONG.song.toLowerCase() != 'drinks on me')
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
				babyArrow.alpha = targetAlpha;

			if (player == 1)
			{
				if (mirrormode && !middlescroll)
					opponentStrums.add(babyArrow);
				else
					playerStrums.add(babyArrow);
			}
			else
			{
				if (middlescroll)
				{
					babyArrow.x += 310;

					// Up and Right
					if (i > 1)
						babyArrow.x += FlxG.width / 2 + 20;
				}

				if (mirrormode && !middlescroll)
					playerStrums.add(babyArrow);
				else
					opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
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

			for (video in members)
			{
				var video:Dynamic = video;
				var video:VideoSprite = video;

				if (video != null && video is VideoSprite)
					video.bitmap.pause();
			}

			#if FEATURE_DISCORD
			updateDiscordPresence('Paused');
			#end

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong && !endingSong && !inCutscene)
			{
				FlxG.sound.music.time = Conductor.songPosition - songOffset;
				resyncVocals();
			}

			for (video in members)
			{
				var video:Dynamic = video;
				var video:VideoSprite = video;

				if (video != null && video is VideoSprite)
					video.bitmap.resume();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;

			paused = false;

			persistentUpdate = true;
			persistentDraw = true;

			if (!SaveData.npsDisplay)
				scoreTxt.text = Ratings.CalculateRanking((practiceMode ? practiceScore : songScore), nps, maxNPS, accuracy);

			#if FEATURE_DISCORD
			updateDiscordPresence();
			#end
		}

		super.closeSubState();
	}

	#if FEATURE_DISCORD
	function updateDiscordPresence(?detailText:String)
	{
		if (detailText == null)
			detailText = detailsText;

		DiscordClient.changePresence(detailsText, hasMetadata ? metadata.song.name : SONG.song);
	}
	#end

	public function addCharacterToList(newCharacter:String, ?costume:String = 'hueh')
	{
		if (!preloadMap.exists(newCharacter))
		{
			var newBoyfriend:Character;
			if (costume == 'hueh')
				newBoyfriend = new Character(0, 0, newCharacter, false);
			else
				newBoyfriend = new Character(0, 0, newCharacter, false, costume);
			preloadMap.set(newCharacter, newBoyfriend);
			preloadGroup.add(newBoyfriend);
			newBoyfriend.alpha = 0.00001;
			newBoyfriend.cameras = [camHUD];
		}
	}

	function addcharacter(newCharacter:String, type:Int, ?trail:Bool, ?costume:String)
	{
		switch (type)
		{
			case 0:
				// Player 1
				if (newCharacter == "")
					newCharacter = SONG.player1;

				switch (newCharacter)
				{
					case 'spirit':
						trail = true;
					case 'monika-pixelnew':
					{
						if (curStage == 'schoolEvilEX')
							trail = true;
					}			
				}

				remove(boyfriend);
				
				boyfriend = new Character(BF_X, BF_Y, newCharacter, !mirrormode, costume);
				boyfriend.x += boyfriend.positionArray[0];
				boyfriend.y += boyfriend.positionArray[1];

				if (trail)
				{
					var evilTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
					add(evilTrail);
					add(boyfriend);
				}
				else
					add(boyfriend);

				if (iconP1 != null)
					iconP1.changeIcon(boyfriend.healthIcon);

				switch (curStage)
				{
					case 'wilted':
						boyfriend.x += 150;
						boyfriend.y -= 80;
						boyfriend.cameras = [camGame2];

						if (newCharacter == 'monika-pixelnew')
						{
							boyfriend.x += 205;
							boyfriend.y -= 75;
						}
					case 'credits':
						boyfriend.cameras = [camGame2];
					case 'school':
						boyfriend.x += 200;
						boyfriend.y += 220;
					case 'schoolEvil':
						boyfriend.x += 200;
						boyfriend.y += 260;
					case 'schoolEvilEX':
						if (stageVER == 0)
						{
							boyfriend.x += 200;
							boyfriend.y += 220;
						}
						else 
						{
							boyfriend.x += 200;
							boyfriend.y += 260;
						}
					case 'dokifestival' | 'dokiglitcher' | 'dokiclubroom':
						if (isPixelUI)
						{
							boyfriend.x += 141;
							boyfriend.y += 160;
						}
					// Leaving this here just incase but if left unused it can be removed
					case 'clubroomevil':
						boyfriend.x = 190;
						boyfriend.y = -135;
					default:
				}
			// Monika i hate you sometimes :(
			if (newCharacter == 'monika' && SaveData.monikacostume == 'casuallong' && !isStoryMode)
				boyfriend.x += 120;
			
			addCharacterToList(boyfriend.gameoverchara);
			boyfriend.dance();
			case 1:
				// Player 2
				if (newCharacter == "")
					newCharacter = SONG.player2;

				switch (newCharacter)
				{
					case 'spirit':
						trail = true;
				}

				remove(dad);
				dad = new Character(DAD_X, DAD_Y, newCharacter, mirrormode, costume);
				dad.x += dad.positionArray[0];
				dad.y += dad.positionArray[1];

				if (trail)
				{
					var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
					add(evilTrail);
					add(dad);
				}
				else
					add(dad);

				if (iconP2 != null)
					iconP2.changeIcon(dad.healthIcon);

				switch (newCharacter) //Most likely gonna remove this and reposition every character again
				{
					case 'gf':
						dad.setPosition(gf.x, gf.y);
						gf.visible = false;
					case 'dad':
					case 'senpai' | 'senpai-angry' | 'monika-pixelnew':
						dad.x += 150;
						dad.y += 10;

					if (curStage == 'wilted')
						dad.y -= 100;
					if (curStage == 'credits')
						dad.y -= 50;
					
					case 'duet':
						dad.x += 150;
						dad.y += 30;
					case 'monika-angry':
						dad.x += 15;
						dad.y += 10;
					case 'spirit':
						dad.x -= 150;
						dad.y -= 250;
					case 'senpai-nonpixel' | 'senpai-angynonpixel':
						dad.x -= 50;
						dad.y -= 35;
					case 'monika':
						if (curStage == 'credits')
							dad.x -= 50;
					case 'natsuki':
						if (curStage == 'credits')
							dad.x += 25;
					case 'protag':
						if (curStage == 'credits')
						{	
							dad.x += 50;
							dad.y += 25;
						}
				}
				switch (curStage)
				{
					case 'wilted':
						dad.x -= 150;
						dad.y -= 65;
						dad.cameras = [camGame2];
					case 'credits':
						dad.cameras = [camGame2];
					case 'school':
					case 'schoolEvilEX':
						if (stageVER == 1)
						{
							dad.y -= 69;
							dad.x += 300;
						}
					case 'schoolEvil':
						dad.y -= 69;
						dad.x += 300;
					case 'dokifestival' | 'dokiglitcher' | 'dokiclubroom':
						if (isPixelUI)
						{
							dad.x += 156;
							dad.y -= 74;
						}
					// Leaving this here just incase but if left unused it can be removed
					case 'clubroomevil' | 'libitina':
						dad.x = 340;
						dad.y = -139;
					case 'youandme':
						dad.y -= 35;
				}
				dad.dance(isAltAnimSection());
			case 2:
				// Girlfriend
				if (newCharacter == "")
					newCharacter = SONG.gfVersion;

				remove(gf);

				if (SONG.player2.startsWith('sayori') && (SONG.gfVersion == 'gf-realdoki' && SaveData.gfcostume == "sayo"))
					costume = 'hueh';

				gf = new Character(GF_X, GF_Y, newCharacter, mirrormode, costume);
				gf.x += gf.positionArray[0];
				gf.y += gf.positionArray[1];
				if (!hideGirlfriend) add(gf);

				if (SONG.song.toLowerCase() == 'catfight')
					gf.playAnim('gone');

				switch (curStage)
				{
					case 'school':
						gf.scrollFactor.set(0.95, 0.95);
						gf.x += 180;
						gf.y += 300;
					case 'dokifestival' | 'dokiglitcher' | 'dokiclubroom' | 'credits':
						if (curStage == 'credits')
							gf.cameras = [camGame2];

						if (isPixelUI)
						{
							gf.x += 275;
							gf.y += 272;
						}
					// hueh
					case 'clubroomevil':
						gf.y = 2000;

				}
				if (SONG.song.toLowerCase() == 'catfight')
					gf.playAnim('gone');
				else
					gf.dance();
			case 3:
				// Player 3 which is me ripping my hair out :)

				remove(extrachar1);
				if (newCharacter == "")
					newCharacter = SONG.player3;

				switch (newCharacter)
				{
					case 'spirit':
						trail = true;
					case 'pixelnew-pixel':
						{
							if (curStage == 'schoolEvilEX')
								trail = true;
						}
				}

				extrachar1 = new Character(-100, 450, newCharacter, mirrormode, costume);
				extrachar1.x += extrachar1.positionArray[0];
				extrachar1.y += extrachar1.positionArray[1];

				if (trail)
				{
					var evilTrail = new FlxTrail(extrachar1, null, 4, 24, 0.3, 0.069);
					add(evilTrail);
					add(extrachar1);
				}
				else
					add(extrachar1);

				switch (curStage)
				{
					case 'school':
						extrachar1.x += 100;
					case 'schoolEvil':
						extrachar1.x = -150;
						extrachar1.y = 250;
					case 'credits':
						extrachar1.setPosition(DAD_X + extrachar1.positionArray[0], DAD_Y + extrachar1.positionArray[1]);
						extrachar1.cameras = [camGame2];
				}
				extrachar1.dance();
			case 4:
				// Player 4 which is me ripping my hair out :)

				remove(extrachar2);
				if (newCharacter == "")
					newCharacter = SONG.player4;

				switch (newCharacter)
				{
					case 'spirit':
						trail = true;
					case 'pixelnew-pixel':
						{
							if (curStage == 'schoolEvilEX')
								trail = true;
						}
				}

				extrachar2 = new Character(300, 450, newCharacter, mirrormode, costume);
				extrachar2.x += extrachar2.positionArray[0];
				extrachar2.y += extrachar2.positionArray[1];

				if (trail)
				{
					var evilTrail = new FlxTrail(extrachar2, null, 4, 24, 0.3, 0.069);
					add(evilTrail);
					add(extrachar2);
				}
				else
					add(extrachar2);

				switch (curStage)
				{
					case 'schoolEvil':
						if (SONG.numofchar >= 4)
						{
							extrachar2.x = -150;
							extrachar2.y = 250;
						}
				}
				extrachar2.dance();
		}

		if (healthBar != null)
		{
			if (mirrormode)
				healthBar.createFilledBar(boyfriend.barColor, dad.barColor);
			else
				healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
	
			healthBar.updateFilledBar();
		}

		if (positionDisplay != null)
			positionDisplay.songPosBar.createGradientBar([FlxColor.TRANSPARENT], [boyfriend.barColor, dad.barColor]);
	}

	override public function onFocus():Void
	{
		if (!boyfriendFuckingDead)
		{
			persistentUpdate = !paused;
			persistentDraw = true;
		}

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (FlxG.autoPause && !boyfriendFuckingDead)
		{
			persistentUpdate = false;
			persistentDraw = true;
		}

		if (!FlxG.autoPause && !paused && startedCountdown && !boyfriendFuckingDead && canPause && !toggleBotplay)
			pauseState(false);

		super.onFocus();
	}

	function changeVocalTrack(?prefix:String = '', ?suffix:String = '')
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}

		vocals = null;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song, prefix, suffix));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		resyncVocals();
	}

	function resyncVocals():Void
	{
		if (_exiting)
			return;

		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time + songOffset;
		FlxG.sound.music.pitch = Conductor.playbackSpeed;

		if (vocalsFinished)
			return;

		vocals.time = FlxG.sound.music.time;
		vocals.play();
		vocals.pitch = Conductor.playbackSpeed;
	}

	// change speed of animations based off playback speed
	function animationTimescale(timescale:Float)
	{
		switch (curSong.toLowerCase())
		{
			case 'my confession':
				if (dad.animation.curAnim.name == 'nara')
					dad.animation.curAnim.frameRate = 24 * timescale;
			case 'my sweets':
				if (dad.animation.curAnim.name == 'hmmph')
					dad.animation.curAnim.frameRate = 24 * timescale;
			case 'deep breaths':
				if (dad.animation.curAnim.name == 'breath')
					dad.animation.curAnim.frameRate = 24 * timescale;
			case 'epiphany':
				popup.animation.curAnim.frameRate = 24 * timescale;

				if (dad.animation.curAnim.name.startsWith('lastNOTE'))
					dad.animation.curAnim.frameRate = 24 * timescale;
		}

		for (video in members)
		{
			var video:Dynamic = video;
			var video:VideoSprite = video;

			if (video != null && video is VideoSprite)
				video.bitmap.rate = Conductor.playbackSpeed;
		}
	}

	public static var perSongOffset:Float = 0;
	var songOffset:Float = 0;

	private var prevMusicTime:Float = 0;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	var iTime:Float = 0;

	override public function update(elapsed:Float)
	{
		if (SaveData.shaders)
		{
			iTime += elapsed;

			if (warpy != null)
				warpy.iTime.value = [iTime / 2];

			if (staticlol != null)
				staticlol.iTime.value = [iTime];

			if (staticlol2 != null)
				staticlol2.iTime.value = [iTime];

			if (glitchlol != null)
				glitchlol.time.value = [iTime];

			if (glitchlol2 != null)
				glitchlol2.time.value = [iTime];
		}

		songOffset = SONG.offset + SaveData.offset + perSongOffset;

		if (isStoryMode)
			Conductor.playbackSpeed = 1;
		else if (!practiceMode)
			Conductor.playbackSpeed = SaveData.songSpeed;

		FlxG.sound.music.pitch = Conductor.playbackSpeed;

		if (vocals != null)
			vocals.pitch = Conductor.playbackSpeed;

		// do this BEFORE super.update() so songPosition is accurate
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
			var musicTime:Float = FlxG.sound.music.time + songOffset;

			if (musicTime == prevMusicTime)
			{
				Conductor.songPosition += FlxG.elapsed * 1000 * Conductor.playbackSpeed;
			}
			else
			{
				Conductor.songPosition = musicTime;
				prevMusicTime = Conductor.songPosition;
			}

			positionDisplay.songPositionBar = Conductor.songPosition / 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}

				if (SaveData.songPosition)
				{
					if ((FlxG.sound.music.length - FlxG.sound.music.time) < 0)
						songTimeLeft = 0
					else
						songTimeLeft = Math.abs(FlxG.sound.music.time - FlxG.sound.music.length) / 1000;

					positionDisplay.songText.text = (hasMetadata ? metadata.song.name : SONG.song)
						+ (Conductor.playbackSpeed != 1 ? ' (${Conductor.playbackSpeed}x)' : '')
						+ ' ('
						+ FlxStringUtil.formatTime(songTimeLeft / Conductor.playbackSpeed)
						+ ')';
				}
			}
		}

		FlxG.watch.addQuick("Current BPM", Conductor.bpm);
		FlxG.watch.addQuick("Current Section", Std.int(curBeat / 4));
		FlxG.watch.addQuick("Current Beat", curBeat);
		FlxG.watch.addQuick("Current Step", curStep);
		FlxG.watch.addQuick('Playback Speed', '${Conductor.playbackSpeed}x');
		FlxG.watch.addQuick("Note Speed", songSpeed);
		FlxG.watch.addQuick('Song Time', '${FlxStringUtil.formatTime(FlxG.sound.music.time / 1000, true)} (${Std.int(FlxG.sound.music.time)})');
		FlxG.watch.addQuick('Time Left', '${FlxStringUtil.formatTime(Math.abs(FlxG.sound.music.time - FlxG.sound.music.length) / 1000, true)} (${Std.int(Math.abs(FlxG.sound.music.time - FlxG.sound.music.length))})');
		FlxG.watch.addQuick('Song Offset', '$songOffset ms');

		super.update(elapsed);

		#if debug
		if (FlxG.keys.pressed.CONTROL && (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L))
		{
			camFocus = false;
			trace(camFollow.x + " X " + camFollow.y + ' y');
			// Camera positioning and velocity changes
			if (FlxG.keys.pressed.I)
			{
				if (FlxG.keys.pressed.SHIFT)
					camFollow.y += -50;
				else
					camFollow.y += -10;
			}
			else if (FlxG.keys.pressed.K)
			{
				if (FlxG.keys.pressed.SHIFT)
					camFollow.y += 50;
				else
					camFollow.y += 10;
			}

			if (FlxG.keys.pressed.J)
			{
				if (FlxG.keys.pressed.SHIFT)
					camFollow.x += -50;
				else
					camFollow.x += -10;
			}
			else if (FlxG.keys.pressed.L)
			{
				if (FlxG.keys.pressed.SHIFT)
					camFollow.x += 50;
				else
					camFollow.x += 10;
			}
		}

		if (FlxG.keys.pressed.CONTROL && (FlxG.keys.pressed.U || FlxG.keys.pressed.O))
		{
			camZooming = true;
			if (FlxG.keys.pressed.O)
				defaultCamZoom += 0.01;
			if (FlxG.keys.pressed.U)
				defaultCamZoom -= 0.01;
		}

		// Reposition stuff
		var dbgItem = crackBG;

		if (dbgItem != null
			&& FlxG.keys.pressed.SHIFT
			&& !FlxG.keys.pressed.CONTROL
			&& (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L))
		{
			if (FlxG.keys.pressed.I)
				dbgItem.y += -1;
			else if (FlxG.keys.pressed.K)
				dbgItem.y += 1;
			if (FlxG.keys.pressed.J)
				dbgItem.x += -1;
			else if (FlxG.keys.pressed.L)
				dbgItem.x += 1;
			trace(dbgItem.x + " X " + dbgItem.y + ' y');
		}

		if (dad != null && FlxG.keys.justPressed.NUMPADFIVE)
			oneMore();

		if (FlxG.keys.justPressed.O && curStage == 'dokiglitcher')
			gopixel();
		if (FlxG.keys.justPressed.P && curStage == 'dokiglitcher')
			becomefumo();

		if (FlxG.keys.justPressed.P && curStage == 'dokiclubroom' && SONG.song.toLowerCase() == 'obsession')
			yuriGoCrazy();

		if (FlxG.keys.justPressed.NUMPADPLUS && encoreTime < 5)
			encoreTime += 1;

		if (FlxG.keys.justPressed.NUMPADPLUS && encoreTime > 3)
		{
			if (stickerSprites != null && stickerSprites.alpha > 0.001)
				stickerSprites.alpha = 0.001;
		}

		if (FlxG.keys.justPressed.NUMPADPLUS && encoreTime > 4)
			encoreTime = 0;

		if (FlxG.keys.justPressed.O && curStage == 'schoolEvilEX')
			evilswap(0);
		if (FlxG.keys.justPressed.P && curStage == 'schoolEvilEX')
			evilswap(1);

		if (FlxG.keys.justPressed.O && curStage == 'wilted')
			wiltswap(0);
		if (FlxG.keys.justPressed.P && curStage == 'wilted')
			wiltswap(1);

		if (FlxG.keys.justPressed.O && curStage == 'school')
			glitchySchool(0);
		if (FlxG.keys.justPressed.P && curStage == 'school')
			glitchySchool(1);

		if (FlxG.keys.justPressed.F10)
		{
			AnimationDebugState.inGame = true;
			AnimationDebugState.isPlayer = true;
			MusicBeatState.switchState(new AnimationDebugState(SONG.player1));

			songStarted = false;
			sectionStart = false;
			stopMusic();
		}

		if (FlxG.keys.justPressed.F11)
		{
			AnimationDebugState.inGame = true;
			AnimationDebugState.isPlayer = false;
			MusicBeatState.switchState(new AnimationDebugState(SONG.player2));

			songStarted = false;
			sectionStart = false;
			stopMusic();
		}

		if (FlxG.keys.justPressed.F12)
		{
			AnimationDebugState.inGame = true;
			AnimationDebugState.isPlayer = false;
			MusicBeatState.switchState(new AnimationDebugState(SONG.gfVersion));

			songStarted = false;
			sectionStart = false;
			stopMusic();
		}

		// Go 10 seconds into the future, credit: Shadow Mario#9396
		if (FlxG.keys.justPressed.TWO && songStarted)
		{
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length)
			{
				zoomStuff = false;
				usedTimeTravel = true;
				practiceMode = true;

				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime + 800 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				for (i in 0...unspawnNotes.length)
				{
					var daNote:Note = unspawnNotes[0];
					if (daNote.strumTime + 800 >= Conductor.songPosition)
					{
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition - songOffset;
				resyncVocals();

				new FlxTimer().start(0.25, function(tmr:FlxTimer)
				{
					zoomStuff = true;
					usedTimeTravel = false;
				});
			}
		}

		if (FlxG.keys.justPressed.F1)
			songOutro();
		#end

		// Used for the dance func in Character update
		altSection = isAltAnimSection();

		if (!isStoryMode)
			animationTimescale(Conductor.playbackSpeed);

		if (curStage == 'clubroomevil')
		{
			// GO HERE DUMMY
			floatshit += 0.007 / FramerateTools.timeMultiplier();
			floatshit2 += 0.007 / FramerateTools.timeMultiplier();
			fancyclouds.alpha += Math.sin(floatshit) / FramerateTools.timeMultiplier() / 5;
			windowlight.alpha += Math.sin(floatshit2) / FramerateTools.timeMultiplier() / 5;
			lightontopofall.alpha += Math.sin(floatshit2) / FramerateTools.timeMultiplier() / 5;
		}

		if (practiceMode && !practiceModeToggled)
			practiceModeToggled = true;

		if (!zoomStuff && sectionStart)
		{
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				zoomStuff = true;
			});
		}

		FlxG.camera.followLerp = FramerateTools.easeConvert(0.04 * cameraSpeed);
		camGame2.followLerp = FlxG.camera.followLerp;

		if (positionBar)
			positionDisplay.songText.screenCenter(X);

		if (toggleBotplay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		if (SaveData.npsDisplay)
		{
			var balls = notesHitArray.length - 1;
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

		if (FlxG.keys.justPressed.NINE)
		{
			if (mirrormode)
				iconP2.swapOldIcon();
			else
				iconP1.swapOldIcon();
		}

		if (canShowPracticeTxt)
			practiceTxt.visible = practiceMode;

		scoreTxt.screenCenter(X);

		// prevent this easter egg from triggering if they keys are bound
		if ((!keysStringArray.contains('O') && !keysStringArray.contains('P')) && FlxG.keys.pressed.O && FlxG.keys.pressed.P && curStage.startsWith('schoolEvil'))
		{
			oldspace.alpha = 1;
			space.alpha = 0;
		}

		if (botPlayState.visible || practiceTxt.visible)
		{
			botplaySine += 180 * elapsed;
			botPlayState.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
			practiceTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		// constantly update if NPS display is enabled (is this gonna hurt performance?)
		if (SaveData.npsDisplay)
			scoreTxt.text = Ratings.CalculateRanking((practiceMode ? practiceScore : songScore), nps, maxNPS, accuracy);

		if (controls.PAUSE && startedCountdown && canPause)
			pauseState();

		if (FlxG.keys.justPressed.F7 #if !debug && SaveData.unlockedEpiphany #end)
		{
			#if FEATURE_DISCORD
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			MusicBeatState.switchState(new ChartingState());
			sectionStart = false;
		}

		
		if (zoomStuff)
		{
			var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			iconP1.scale.set(mult, mult);
			
			var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			iconP2.scale.set(mult, mult);
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		if (!endingSong)
		{
			if (!mirrormode)
			{
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
			}
			else
			{
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
			}

			if (health > 2)
				health = 2;
			if (health < 0)
				health = 0;

			if (epipEnding)
			{
				if (!mirrormode)
				{				
					if (healthBar.percent > 90)
						iconP1.animation.curAnim.curFrame = 2;
					else if (healthBar.percent < 20)
						iconP1.animation.curAnim.curFrame = 1;
					else
						iconP1.animation.curAnim.curFrame = 0;
				}
				else
				{
					if (healthBar.percent < 10)
						iconP1.animation.curAnim.curFrame = 2;
					else if (healthBar.percent > 80)
						iconP1.animation.curAnim.curFrame = 1;
					else
						iconP1.animation.curAnim.curFrame = 0;
				}

				if (!SaveData.beatEpiphany)
					iconP2.animation.curAnim.curFrame = 1;
				else
					iconP2.animation.curAnim.curFrame = 0;
			}
			else
			{
				if (!mirrormode)
				{
					if (healthBar.percent < 10)
					{
						iconP1.animation.curAnim.curFrame = 1;
						iconP2.animation.curAnim.curFrame = happyEnding ? 1 : 2;
					}
					else if (healthBar.percent < 20)
					{
						iconP1.animation.curAnim.curFrame = 1;
						iconP2.animation.curAnim.curFrame = 0;
					}
					else if (healthBar.percent > 90)
					{
						iconP1.animation.curAnim.curFrame = 2;
						iconP2.animation.curAnim.curFrame = happyEnding ? 2 : 1;
					}
					else if (healthBar.percent > 80)
					{
						iconP1.animation.curAnim.curFrame = 0;
						iconP2.animation.curAnim.curFrame = happyEnding ? 2 : 1;
					}
					else
					{
						iconP1.animation.curAnim.curFrame = 0;
						iconP2.animation.curAnim.curFrame = 0;
					}
				}
				else
				{
					if (healthBar.percent < 10)
					{
						iconP2.animation.curAnim.curFrame = 1;
						iconP1.animation.curAnim.curFrame = happyEnding ? 1 : 2; 
					}
					else if (healthBar.percent < 20)
					{
						iconP2.animation.curAnim.curFrame = 1;
						iconP1.animation.curAnim.curFrame = 0;
					}
					else if (healthBar.percent > 90)
					{
						iconP2.animation.curAnim.curFrame = 2;
						iconP1.animation.curAnim.curFrame = happyEnding ? 2 : 1;
					}
					else if (healthBar.percent > 80)
					{
						iconP2.animation.curAnim.curFrame = 0;
						iconP1.animation.curAnim.curFrame = happyEnding ? 2 : 1;
					}
					else
					{
						iconP2.animation.curAnim.curFrame = 0;
						iconP1.animation.curAnim.curFrame = 0;
					}
				}
			}
		}

		if (zoomStuff && camZooming)
		{
			FlxG.camera.zoom = defaultCamZoom + 0.95 * (FlxG.camera.zoom - defaultCamZoom);
			camGame2.zoom = defaultCamZoom + 0.95 * (FlxG.camera.zoom - defaultCamZoom);
			camHUD.zoom = defaultHudZoom + 0.95 * (camHUD.zoom - defaultHudZoom);
		}

		// i thought this was cute
		if (songStarted)
		{
			switch (curSong.toLowerCase())
			{
				case 'rain clouds':
					switch (curBeat)
					{
						case 0:
							gfSpeed = 2;
						case 16:
							gfSpeed = 1;
					}
				case 'glitcher (monika mix)':
					if (SaveData.shaders)
						glitchy.data.strength.value = [glitchy.upFloat];
			}
		}

		if (SONG.song.toLowerCase() != 'takeover medley')
		{
			if ((health <= 0 && !practiceMode) || (!SaveData.noReset && startedCountdown && controls.RESET && !endingSong))
				killPlayer();
		}

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;
			var songSpeedMod:Float = songSpeed / Conductor.playbackSpeed;
			if (songSpeedMod < 1)
				time /= songSpeedMod;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			var songSpeedMod:Float = songSpeed / Conductor.playbackSpeed;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if (!daNote.mustPress)
					strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;
				var strumVisible:Bool = strumGroup.members[daNote.noteData].visible;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) // Downscroll
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeedMod);
				else 
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeedMod);

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if (daNote.copyAlpha)
					daNote.alpha = strumAlpha;

				if (daNote.copyVisible)
					daNote.visible = strumVisible;

				if (daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if (daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					// Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if (strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end'))
						{
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeedMod + (46 * (songSpeedMod - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeedMod;
							if (daNote.noteStyle == 'pixel')
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * daPixelZoom;
							else
								daNote.y -= 19;
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeedMod - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeedMod - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					opponentNoteHit(daNote);

				if (daNote.mustPress && toggleBotplay && (mirrormode || (!mirrormode && daNote.noteType != 2)))
				{
					if (daNote.isSustainNote)
					{
						if (daNote.canBeHit)
							goodNoteHit(daNote);
					}
					else if (daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress))
						goodNoteHit(daNote);
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if (strumGroup.members[daNote.noteData].sustainReduce
					&& daNote.isSustainNote
					&& (daNote.mustPress || !daNote.ignoreNote)
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var scaleY:Float = daNote.scale.y * Conductor.playbackSpeed;
					if (strumScroll)
					{
						if (daNote.y - daNote.offset.y * scaleY + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * scaleY <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !toggleBotplay && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit) && (mirrormode || (!mirrormode && daNote.noteType != 2)))
						noteMiss(daNote);

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene && !paused)
		{
			if (!toggleBotplay)
				keyShit();
			else
			{
				if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * (boyfriend.singDuration / Conductor.playbackSpeed) && !mirrormode)
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.dance(isAltAnimSection());
				}

				if (dad.holdTimer > Conductor.stepCrochet * 0.001 * (dad.singDuration / Conductor.playbackSpeed) && mirrormode)
				{
					if (dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss'))
						dad.dance(isAltAnimSection());
				}

				if (SONG.numofchar >= 3 && extrachar1.holdTimer > Conductor.stepCrochet * 0.001 * (extrachar1.singDuration / Conductor.playbackSpeed) && mirrormode)
				{
					if (extrachar1.animation.curAnim.name.startsWith('sing') && !extrachar1.animation.curAnim.name.endsWith('miss'))
						extrachar1.dance(isAltAnimSection());
				}

				if (SONG.numofchar >= 4 && extrachar2.holdTimer > Conductor.stepCrochet * 0.001 * (extrachar2.singDuration / Conductor.playbackSpeed) && mirrormode)
				{
					if (extrachar2.animation.curAnim.name.startsWith('sing') && !extrachar2.animation.curAnim.name.endsWith('miss'))
						extrachar2.dance(isAltAnimSection());
				}
			}
		}
	}

	function songOutro():Void
	{
		isintro = false;
		midsongcutscene = false;
		canPause = false;

		stopMusic();

		if (!incutsceneforendingsmh)
		{
			incutsceneforendingsmh = true;
			if (isStoryMode && !ForceDisableDialogue)
			{
				switch (curSong.toLowerCase())
				{
					default:
						if (endDoof != null)
							endcutscene();
						else
							endSong();

					case 'obsession':
						remove(whiteflash);
						staticshock.visible = false;
						obsessionending();
						endcutscene();
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
	}

	function endSong():Void
	{
		positionDisplay.visible = false;
		endingSong = true;
		sectionStart = false;
		practiceMode = false;
		showCutscene = true;
		deathCounter = 0;
		Conductor.playbackSpeed = 1;

		midsongcutscene = false;
		
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
		Highscore.saveCombo(SONG.song, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
		Highscore.saveAccuracy(SONG.song, accuracy, storyDifficulty);
		
		// outside of story stuff -- Obv if you beat it in story mode, it don't matter
		if (!toggleBotplay && !practiceModeToggled)
		{
			switch (curSong.toLowerCase())
			{
				case 'epiphany':
					if (!SaveData.beatEpiphany)
					{
						SaveData.beatEpiphany = true;
						DokiFreeplayState.showPopUp = true;
						DokiFreeplayState.popupType = curSong;
					}
				case 'catfight':
					if (!SaveData.beatCatfight)
						SaveData.beatCatfight = true;
				case 'drinks on me':
					if (!SaveData.beatVA11HallA)
						SaveData.beatVA11HallA = true;
				case 'libitina':	
					if (!SaveData.beatLibitina)
					{
						SaveData.beatLibitina = true;
						#if FEATURE_GAMEJOLT
						GameJoltAPI.getTrophy(0);
						#end
					}
				case "it's complicated (sayori mix)":
					if (!SaveData.unlockSoftCostume && !isStoryMode && mirrormode && SaveData.sayoricostume == 'grace')
						SaveData.unlockSoftCostume = true;
				case 'our harmony':
					if (!SaveData.unlockMrCowCostume && !isStoryMode && SaveData.sayoricostume == 'casual' && SaveData.natsukicostume == 'casual' && SaveData.yuricostume == 'casual' && SaveData.monikacostume == 'casual')
						SaveData.unlockMrCowCostume = true;
			}
		}

		if (toggleBotplay)
			toggleBotplay = false;

		mirrormode = false;

		if (isStoryMode)
		{
			campaignScore += Math.round(songScore);

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				switch (storyWeek)
				{
					case 0:
						SaveData.beatPrologue = true;
					case 1:
						SaveData.beatSayori = true;
					case 2:
						SaveData.beatNatsuki = true;
					case 3:
						SaveData.beatYuri = true;
					case 4:
						SaveData.beatMonika = true;
					case 5:
						SaveData.beatFestival = true;
						SaveData.unlockedEpiphany = true;
					case 6:
						SaveData.beatEncore = true;
					case 7:
						SaveData.beatProtag = true;
					case 8:
						if (!SaveData.sideStatus.contains(curSong.toLowerCase()) && !SaveData.beatSide)
						{
							SaveData.sideStatus.push(curSong.toLowerCase());

							if (SaveData.sideStatus.length >= 4)
								SaveData.beatSide = true;
						}
				}

				DokiStoryState.showPopUp = true;
				DokiStoryState.popupType = CoolUtil.getWeekName(storyWeek);

				if (!SaveData.beatSide && storyWeek == 8)
					DokiStoryState.showPopUp = false;

				if (FlxTransitionableState.skipNextTransIn)
					CustomFadeTransition.nextCamera = null;

				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				SaveData.save();

				switch (curSong.toLowerCase())
				{
					default:
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						Conductor.changeBPM(120);
						MusicBeatState.switchState(new DokiStoryState());
					case 'obsession':
						Sys.exit(0);
					case 'libitina':
						MusicBeatState.switchState(new ThankyouState());
				}
			}
			else
			{
				switchSong();
			}
		}
		else
		{
			practiceModeToggled = false;

			if (chartingMode)
			{
				MusicBeatState.switchState(new ChartingState());
				chartingMode = false;
			}
			else
			{
				SaveData.save();

				if (FlxTransitionableState.skipNextTransIn)
					CustomFadeTransition.nextCamera = null;

				MusicBeatState.switchState(new DokiFreeplayState());
			}
		}
	}

	private function switchSong():Void
	{
		var poop:String = Highscore.formatSong(storyPlaylist[0], storyDifficulty);

		trace('NEXT SONG: ' + poop);

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		prevCamFollow = camFollow;

		try
		{
			SONG = Song.loadFromJson(poop, storyPlaylist[0].toLowerCase());
		}
		catch (e)
		{
			poop = Highscore.formatSong(storyPlaylist[0], 1);
			SONG = Song.loadFromJson(poop, storyPlaylist[0].toLowerCase());
		}
		
		FlxG.sound.music.stop();

		LoadingState.loadAndSwitchState(new PlayState());
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var currentTimingShown:FlxText = null;

	var pixelShitPart1:String = '';
	var pixelShitPart2:String = '';

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float;

		if (daNote != null)
			noteDiff = -(daNote.strumTime - Conductor.songPosition);
		else
			noteDiff = Conductor.safeZoneOffset; // Assumed SHIT if no note was given

		vocals.volume = 1;

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		totalNotesHit += Ratings.noteAccuracy(noteDiff);

		var daRating = Ratings.judgeNote(noteDiff);

		if (daRating != 'sick' && SaveData.missModeType == 2)
			health -= 100;

		switch (daNote.noteType)
		{
			case 2:
				if (!mirrormode)
				{
					health -= 100;

					if (curSong.toLowerCase() == 'epiphany' && !practiceMode)
						GameOverSubstate.crashdeath = FlxG.random.bool(5);
				}
			default:
				{
					switch (daRating)
					{
						case 'shit':
							score = -300;
							combo = 0;
							breaks++;
							health -= 0.1;
							ss = false;
							shits++;
						case 'bad':
							daRating = 'bad';
							score = 0;
							health -= 0.06;
							ss = false;
							bads++;
						case 'good':
							daRating = 'good';
							score = 200;
							ss = false;
							goods++;
							if (health < 2)
								health += 0.04;
						case 'sick':
							if (health < 2)
								health += 0.1;
							sicks++;
					}
				}
		}

		if (daRating == 'sick' && SaveData.noteSplash)
		{
			//Testing, this fixes the double note splash issue with it spawning 2 note splashes one being normal and the other being pixel
			var daNoteSplash:NoteSplash = new NoteSplash(daNote.noteData, daNote.x, strumLine.y, curStyle);
			// var daNoteSplash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			//daNoteSplash.setupNoteSplash(daNote.x, strumLine.y, daNote.noteData);
			grpNoteSplashes.add(daNoteSplash);
		}

		if (SaveData.hitSound)
			HitSoundManager.play(daRating);

		if (!practiceMode)
			songScore += Math.round(score);
		else
			practiceScore += Math.round(score);

		// Psych score zoom
		if (scoreTxtTween != null)
			scoreTxtTween.cancel();

		scoreTxt.scale.x = 1.075;
		scoreTxt.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween)
			{
				scoreTxtTween = null;
			}
		});

		if (isPixelUI || curStyle == 'pixel')
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

		if (SaveData.changedHit)
		{
			rating.x = SaveData.changedHitX;
			rating.y = SaveData.changedHitY;
		}
		else
		{
			rating.x = 569;
			rating.y = 540;

			// rating.screenCenter();
			// rating.y -= 50;
			// rating.x = (FlxG.width * 0.55) - 125;
		}

		rating.acceleration.y = 550;
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.velocity.y -= FlxG.random.int(140, 175);

		if (SaveData.earlyLate)
		{
			if (currentTimingShown != null)
			{
				remove(currentTimingShown);
				currentTimingShown = null;
			}

			if (daRating != 'sick')
			{
				currentTimingShown = new FlxText(0, 0, 0, "EXACT");
				currentTimingShown.setFormat(LangUtil.getFont('riffic'), 28);

				if (noteDiff > 0)
				{
					currentTimingShown.text = "LATE";
					currentTimingShown.color = FlxColor.RED;
					lates++;
				}
				else if (noteDiff < 0)
				{
					currentTimingShown.text = "EARLY";
					currentTimingShown.color = FlxColor.CYAN;
					earlys++;
				}

				currentTimingShown.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
				currentTimingShown.antialiasing = SaveData.globalAntialiasing && (!isPixelUI && curStyle != 'pixel');

				if (isPixelUI || curStyle == 'pixel')
					currentTimingShown.font = LangUtil.getFont('vcr');

				currentTimingShown.screenCenter();
				currentTimingShown.x = rating.x + 100;
				currentTimingShown.y = rating.y + 75;

				// these aren't applying for some reason
				// currentTimingShown.acceleration.y = 550;
				// currentTimingShown.velocity.x -= FlxG.random.int(0, 10);
				// currentTimingShown.velocity.y -= FlxG.random.int(140, 175);

				currentTimingShown.updateHitbox();
				currentTimingShown.cameras = [camHUD];

				FlxTween.tween(currentTimingShown, {alpha: 0}, 0.2, {startDelay: Conductor.crochet * 0.002});

				if (SaveData.ratingToggle)
					insert(members.indexOf(strumLineNotes), currentTimingShown);
			}
		}

		if (scorePop)
		{
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = rating.x;
		comboSpr.y = rating.y + 100;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		comboSpr.velocity.y -= 150;

		if (SaveData.ratingToggle)
			insert(members.indexOf(strumLineNotes), rating);

		if (!isPixelUI && curStyle != 'pixel')
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = SaveData.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = SaveData.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		comboSpr.cameras = [camHUD];
		rating.cameras = [camHUD];

		var seperatedScore:Array<Int> = [];

		var comboSplit:Array<String> = (combo + "").split('');

		// make sure we have 3 digits to display (looks weird otherwise lol)
		if (comboSplit.length == 1)
		{
			seperatedScore.push(0);
			seperatedScore.push(0);
		}
		else if (comboSplit.length == 2)
			seperatedScore.push(0);

		for (i in 0...comboSplit.length)
		{
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = rating.x + (45 * daLoop) - 50;
			numScore.y = rating.y + 100;
			numScore.cameras = [camHUD];

			if (!isPixelUI && curStyle != 'pixel')
			{
				numScore.antialiasing = SaveData.globalAntialiasing;
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

			if (combo >= 2 && SaveData.ratingToggle)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.002,
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				}
			});

			daLoop++;
		}

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.002,
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
			}
		});

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.002,
			onComplete: function(tween:FlxTween)
			{
				rating.destroy();
			}
		});
		}

		curSection += 1;
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (!toggleBotplay && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || (!FlxG.keys.checkStatus(eventKey, PRESSED) && KeyBinds.gamepad)))
		{
			if (!boyfriend.stunned && generatedMusic && !endingSong)
			{
				// more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time + songOffset;

				var canMiss:Bool = !SaveData.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				// var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if (daNote.noteData == key)
							sortedNotesList.push(daNote);

						if (mirrormode || (!mirrormode && daNote.noteType != 2))
							canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0)
				{
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes)
						{
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
							{
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							}
							else
								notesStopped = true;
						}

						if (!notesStopped)
						{
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				}
				else if (canMiss)
					noteMissPress(key);

				// more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if (spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
		}
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (!toggleBotplay && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if (spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	private function keyShit():Void
	{
		// order is Left, Down, Up, Right
		var holdArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var pressArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
		var releaseArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];

		if (pressArray.contains(true) && SaveData.hitSound && !HitSoundManager.noteHit && !endingSong)
			HitSoundManager.play();

		if (!boyfriend.stunned && generatedMusic && !endingSong)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && holdArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					goodNoteHit(daNote);
			});
		}

		if (KeyBinds.gamepad && !FlxG.keys.pressed.ANY)
		{
			if (pressArray.contains(true))
			{
				for (i in 0...pressArray.length)
				{
					if (pressArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}

			if (releaseArray.contains(true))
			{
				for (i in 0...releaseArray.length)
				{
					if (releaseArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * (boyfriend.singDuration / Conductor.playbackSpeed) && !holdArray.contains(true) && !mirrormode)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance(isAltAnimSection());
		}

		if (dad.holdTimer > Conductor.stepCrochet * 0.001 * (dad.singDuration / Conductor.playbackSpeed) && !holdArray.contains(true) && mirrormode)
		{
			if (dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss'))
				dad.dance(isAltAnimSection());
		}
		if (SONG.numofchar >= 3 && extrachar1.holdTimer > Conductor.stepCrochet * 0.001 * (extrachar1.singDuration / Conductor.playbackSpeed) && !holdArray.contains(true) && mirrormode)
		{
			if (extrachar1.animation.curAnim.name.startsWith('sing') && !extrachar1.animation.curAnim.name.endsWith('miss'))
				extrachar1.dance(isAltAnimSection());
		}
		if (SONG.numofchar >= 4 && extrachar2.holdTimer > Conductor.stepCrochet * 0.001 * (extrachar2.singDuration / Conductor.playbackSpeed) && !holdArray.contains(true) && mirrormode)
		{
			if (extrachar2.animation.curAnim.name.startsWith('sing') && !extrachar2.animation.curAnim.name.endsWith('miss'))
				extrachar2.dance(isAltAnimSection());
		}

	}

	function changeOpponentIcon(char:Character):Void
	{
		iconP2.changeIcon(char.healthIcon);

		if (healthBar != null)
		{
			if (mirrormode)
				healthBar.createFilledBar(boyfriend.barColor, char.barColor);
			else
				healthBar.createFilledBar(char.barColor, boyfriend.barColor);

			healthBar.updateFilledBar();
		}

		if (positionDisplay != null)
			positionDisplay.songPosBar.createGradientBar([FlxColor.TRANSPARENT], [boyfriend.barColor, char.barColor]);
	}

	function noteMiss(daNote:Note):Void
	{
		// Dupe note remove
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& daNote.mustPress
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 1)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		if (daNote.noteType == 2)
		{
			if (mirrormode)
			{
				if (SaveData.missModeType >= 1)
				health -= 100;
				else
				health -= 0.5;
			}
				
			
		}
		else
		{
			if (SaveData.missModeType >= 1)
				health -= 100;
			else
				health -= 0.04;
		}

		if (combo > 5 && gf.animOffsets.exists('sad') && !gf.animation.curAnim.name.startsWith('necksnap'))
			gf.playAnim('sad');

		combo = 0;
		totalNotesHit -= 1;
		misses++;
		breaks++;

		if (!practiceMode)
			songScore -= 10;

		updateAccuracy();

		var char:Character = boyfriend;
		var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss';

		if (mirrormode)
		{
			if (daNote != null)
			{
				switch (daNote.noteType)
				{
					default:
						char = dad;
					case 3:
						if (SONG.numofchar >= 3)
							char = extrachar1;
						else
							char = gf;
					case 4:
						if (SONG.numofchar >= 4)
							char = extrachar2;
						else
							char = gf;
					case 6:
						char = gf;
				}
			}
			else
				char = dad;

			if (curSong.toLowerCase() == 'love n funkin' && iconP2.char != char.healthIcon)
				changeOpponentIcon(char);
		}
		else if (daNote != null && daNote.noteType == 6)
			char = gf;

		if (mirrormode && daNote != null)
		{
			if (daNote.noteType == 5)
			{
				extrachar2.playAnim(animToPlay, true);
				extrachar1.playAnim(animToPlay, true);
				dad.playAnim(animToPlay, true);
			}
			else if (curSong.toLowerCase() == 'takeover medley')
			{
				char.playAnim(animToPlay, true);
				extrachar1.playAnim(animToPlay, true);
			}
			else
				char.playAnim(animToPlay, true);
		}
		else
			char.playAnim(animToPlay, true);

		vocals.volume = 0;
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
	}

	function noteMissPress(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			if (SaveData.ghostTapping)
				return;

			if (SaveData.missModeType >= 1)
				health -= 100;
			else
				health -= 0.04;

			if (combo > 5 && gf.animOffsets.exists('sad') && !gf.animation.curAnim.name.startsWith('necksnap'))
				gf.playAnim('sad');

			combo = 0;
			totalNotesHit -= 1;
			misses++;
			breaks++;

			if (!practiceMode)
				songScore -= 10;

			updateAccuracy();

			var char:Character = boyfriend;
			if (mirrormode) char = dad;

			var animToPlay:String = singAnimations[Std.int(Math.abs(direction))] + 'miss';

			char.playAnim(animToPlay, true);

			vocals.volume = 0;
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		camZooming = true;

		var altAnim:String = "";

		if (isAltAnimSection() || note.noteType == 1)
			altAnim = '-alt';

		var char:Character = dad;
		if (mirrormode) char = boyfriend;
		var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;

		if (!mirrormode)
		{
			if (note != null)
			{
				switch (note.noteType)
				{
					default:
						char = dad;
					case 3:
						if (SONG.numofchar >= 3)
							char = extrachar1;
						else
							char = gf;
					case 4:
						if (SONG.numofchar >= 4)
							char = extrachar2;
						else
							char = gf;
					case 6:
						char = gf;
				}
			}
			else
				char = dad;

			if (curSong.toLowerCase() == 'love n funkin' && iconP2.char != char.healthIcon)
				changeOpponentIcon(char);
		}
		else if (note != null && note.noteType == 6)
			char = gf;

		switch (note.noteType)
		{
			case 5:
				if (SONG.numofchar >= 4 && SONG.numofchar >= 3)
				{
					if (mirrormode)
						char.playAnim(animToPlay, true);
					else
					{
						dad.playAnim(animToPlay, true);
						extrachar1.playAnim(animToPlay, true);
						extrachar2.playAnim(animToPlay, true);
					}
				}

			case 2:
				if (curSong.toLowerCase() == "obsession" && !yuriGoneCrazy)
					char.playAnim(animToPlay, true);

			default:
				if (note != null)
				{
					if (!mirrormode && curSong.toLowerCase() == 'takeover medley')
					{
						extrachar1.playAnim(animToPlay, true);
						char.playAnim(animToPlay, true);
					}
					else
						char.playAnim(animToPlay, true);
				}
		}

		char.holdTimer = 0;

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;

		if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
			time += 0.15;

		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			// add newest note to front, the oldest ones are at the end and are removed first
			if (!note.isSustainNote && SaveData.npsDisplay)
				notesHitArray.unshift(Date.now());

			if (toggleBotplay && note.ignoreNote)
				return;

			if (!note.isSustainNote)
			{
				combo++;
				if (combo > 9999) combo = 9999;
				if (combo > maxCombo) maxCombo = combo;

				popUpScore(note);
			}

			var altAnim:String = "";

			if (isAltAnimSection() || note.noteType == 1)
				altAnim = '-alt';
			

			var char:Character = boyfriend;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

			if (!mirrormode)
			{
				if (note != null && note.noteType == 6)
					char = gf;

				char.playAnim(animToPlay + altAnim, true);
				char.holdTimer = 0;
			}
			else
			{
				if (note != null)
				{
					switch (note.noteType)
					{
						default:
							char = dad;
						case 3:
							if (SONG.numofchar >= 3)
								char = extrachar1;
							else
								char = gf;
						case 4:
							if (SONG.numofchar >= 4)
								char = extrachar2;
							else
								char = gf;
						case 6:
							char = gf;
					}
				}
				else
					char = dad;

				if (curSong.toLowerCase() == 'love n funkin' && iconP2.char != char.healthIcon)
					changeOpponentIcon(char);

				switch (note.noteType)
				{
					case 5:
						if (SONG.numofchar >= 4 && SONG.numofchar >= 3)
						{
							if (mirrormode)
								char.playAnim(animToPlay + altAnim, true);
							else
							{
								dad.playAnim(animToPlay, true);
								extrachar1.playAnim(animToPlay + altAnim, true);
								extrachar2.playAnim(animToPlay + altAnim, true);
							}
						}

					case 2:
						if (curSong.toLowerCase() == "obsession" && !yuriGoneCrazy)
							char.playAnim(animToPlay + altAnim, true);

					default:
						if (mirrormode && curSong.toLowerCase() == 'takeover medley')
						{
							extrachar1.playAnim(animToPlay, true);
							char.playAnim(animToPlay + altAnim, true);
						}
						else
							char.playAnim(animToPlay + altAnim, true);

						
				}

				char.holdTimer = 0; 
			}

			if (toggleBotplay)
			{
				var time:Float = 0.15;

				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
					time += 0.15;

				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			}
			else
			{
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
						spr.playAnim('confirm', true);
				});
			}

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
				updateAccuracy();
			}
		}
	}

	inline function stopMusic()
	{
		vocalsFinished = true;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (vocals != null)
			vocals.stop();
	}

	function killPlayer(forceType:Int = 0)
	{
		if (curStage == "credits" || curStage == "wilted" || curStage == 'clubroomevil' || curStage == 'libitina')
			camGame.filtersEnabled = false;

		boyfriendFuckingDead = true;
		boyfriend.stunned = true;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;

		stopMusic();

		deathCounter += 1;
		var gaCharacter:Character = boyfriend;

		//Feel free to optimize this but this should work as is
		if (curSong.toLowerCase() == 'catfight' && mirrormode || curSong.toLowerCase() == 'epiphany' && storyDifficulty == 2)
			gaCharacter = dad;

		if (boyfriend.curCharacter == 'monika' && SaveData.monikacostume == 'casuallong' && !isStoryMode && !mirrormode)
				boyfriend.x -= 120;

		mirrormode = false;
		if (boyfriend.gameoverchara == 'gameover-generic' && !mirrormode)
			openSubState(new GameOverSubstate(gaCharacter.getScreenPosition().x, gaCharacter.getScreenPosition().y - gaCharacter.positionArray[1] - 20, forceType));
		else
			openSubState(new GameOverSubstate(gaCharacter.getScreenPosition().x, gaCharacter.getScreenPosition().y, forceType));

		#if FEATURE_DISCORD
		updateDiscordPresence('Game Over');
		#end
	}

	override function stepHit()
	{
		if (!startingSong && !endingSong && !inCutscene && !vocalsFinished)
		{
			var vocalOffset:Float = Math.abs(vocals.time - FlxG.sound.music.time);

			if (vocalOffset > 15)
				resyncVocals();
		}

		super.stepHit();

		if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null && !endingSong && camFocus)
			moveCameraSection(Std.int(curStep / 16));

		if (midsongcutscene)
		{
			switch (curSong.toLowerCase())
			{
				case 'crucify (yuri mix)':
					switch (curStep)
					{
						case 128:
							metadataDisplay.tweenIn();
							positionDisplay.tweenIn();
						case 224:
							metadataDisplay.tweenOut();
					}
				case 'beathoven (natsuki mix)':
					switch (curStep)
					{
						case 192:
							metadataDisplay.tweenIn();
							positionDisplay.tweenIn();
						case 304:
							metadataDisplay.tweenOut();
					}
				case "it's complicated (sayori mix)":
					switch (curStep)
					{
						case 260:
							metadataDisplay.tweenIn();
							positionDisplay.tweenIn();
						case 384:
							metadataDisplay.tweenOut();
					}
				case 'glitcher (monika mix)':
					switch (curStep)
					{
						case 64:
							metadataDisplay.tweenIn();
							positionDisplay.tweenIn();
						case 192:
							metadataDisplay.tweenOut();
						case 566 | 816 | 1072 | 1328: // Start glitch
							glitchy.upFloat = 0.0;
							FlxTween.tween(glitchy, {upFloat: 2.7}, CoolUtil.calcSectionLength(), {ease: FlxEase.quadOut});
						case 576 | 1088: // End Glitch to pixel
							gopixel();
							FlxTween.cancelTweensOf(glitchy);
							glitchy.upFloat = 2.7;
							FlxTween.tween(glitchy, {upFloat: 0.0}, CoolUtil.calcSectionLength(0.7), {ease: FlxEase.quadOut});
						case 832 | 1343: // End Glitch except back to normal
							becomefumo();
							FlxTween.cancelTweensOf(glitchy);
							glitchy.upFloat = 2.7;
							FlxTween.tween(glitchy, {upFloat: 0.0}, CoolUtil.calcSectionLength(0.7), {ease: FlxEase.quadOut});
						case 1360 | 1392 | 1424 | 1456:
							gopixel();
						case 1376 | 1408 | 1440 | 1472:
							becomefumo();
					}
				case 'obsession':
					if (!sectionStart)
					{
						switch (curStep)
						{
							case 432 | 448 | 464:
								if (!constantScroll)
									songSpeed -= 0.05;
							case 480:
								if (!constantScroll)
									songSpeed -= 0.05;

								staticshock.visible = true;
								staticshock.alpha = 0;
								FlxTween.tween(FlxG.camera, {zoom: 1.5}, (Conductor.stepCrochet / 14) / Conductor.playbackSpeed, {ease: FlxEase.linear});
								FlxTween.tween(staticshock, {alpha: 1}, (Conductor.stepCrochet / 14) / Conductor.playbackSpeed, {
									ease: FlxEase.linear,
									onComplete: function(tween:FlxTween)
									{
										staticshock.alpha = 0.1;
									}
								});
							case 544:
								if (!constantScroll)
									songSpeed -= 0.1;

								add(whiteflash);
								add(blackScreen);
								FlxG.sound.play(Paths.sound('Lights_Shut_off'), 0.7);
							case 552:
								// shit gets serious
								yuriGoCrazy();
							case 568:
								remove(blackScreen);
								FlxTween.tween(whiteflash, {alpha: 0.15}, CoolUtil.calcSectionLength(0.75), {ease: FlxEase.sineOut});
							case 848:
								blackScreentwo.visible = true;
						}
					}
				case 'bara no yume':
					switch (curStep)
					{
						case 1360:
							glitchySchool(1);
						case 1552:
							glitchySchool(0);
					}
				case 'my confession':
					switch (curStep)
					{
						case 480:
							camZooming = false;
							camFocus = false;
							camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y - 100);
							gf.playAnim('countdownThree');
							FlxTween.tween(FlxG.camera, {zoom: 1}, CoolUtil.calcSectionLength(0.2));
						case 484:
							gf.playAnim('countdownTwo');
							FlxTween.tween(FlxG.camera, {zoom: 1.2}, CoolUtil.calcSectionLength(0.2));
						case 488:
							gf.playAnim('countdownOne');
							FlxTween.tween(FlxG.camera, {zoom: 1.4}, CoolUtil.calcSectionLength(0.2));
						case 492:
							camFocus = true;
							camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
							gf.playAnim('countdownGo');
							camZooming = true;
						case 496:
							gf.dance();
						case 749:
							if (SaveData.sayoricostume == 'grace')
							{
								dad.playAnim('nara');
								dad.specialAnim = true;
							}
						case 752:
							if (SaveData.sayoricostume != 'grace')
							{
								dad.playAnim('nara');
								dad.specialAnim = true;
							}

							sayonara();
						case 768:
							FlxG.camera.zoom = 0.75;
							staticshock.visible = false;
							vignette.alpha = 0;
						case 774:
							camZooming = true;
					}
				case 'catfight':
					switch (curStep)
					{
						case 608:
							defaultCamZoom = 0.8;
						case 624:
							defaultCamZoom = 0.85;
						case 640:
							if (!constantScroll)
								songSpeed += 0.1;

							defaultCamZoom = 0.9;
						case 1120:
							defaultCamZoom = 0.95;
						case 1136:
							if (!constantScroll)
								songSpeed += 0.1;

							gf.playAnim('popout');
							defaultCamZoom = 1;
						case 1150:
							camFocus = false;
							camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y - 125);
							defaultCamZoom = 1.6;
						case 1169:
							gf.playAnim('scared');
							camFocus = true;
							defaultCamZoom = 1.05;
						case 1195:
							gf.dance();
						case 1568:
							if (!constantScroll)
								songSpeed += 0.05;

							defaultCamZoom = 1.1;
						case 1696:
							if (!constantScroll)
								songSpeed += 0.05;

							defaultCamZoom = 1.15;
						case 1824:
							if (!constantScroll)
								songSpeed += 0.05;

							defaultCamZoom = 1.2;
					}
				case 'your demise':
					switch (curStep)
					{
						case 1:
							if (blackScreen != null) FlxTween.tween(blackScreen, {alpha: 0.001}, CoolUtil.calcSectionLength(0.1), {ease: FlxEase.sineOut});
						case 264:
							blackScreen.alpha = 1;
						case 328:
							blackScreen.alpha = 0.001;
							evilswap(1);
						case 585:
							defaultCamZoom = 1.3;
							evilswap(2);
						case 616:
							defaultCamZoom = 1;
						case 648:
							defaultCamZoom = 1.3;
						case 680:
							defaultCamZoom = 1;
						case 712:
							defaultCamZoom = 1.3;
						case 744:
							defaultCamZoom = 1;
						case 776:
							defaultCamZoom = 1.3;
						case 808:
							defaultCamZoom = 1;
						case 840:
							evilswap(0);
						case 1608:
							defaultCamZoom = 1.3;
						case 1640:
							defaultCamZoom = 1;
							evilswap(1);
						case 1864:
							FlxTween.tween(blackScreen, {alpha: 1}, CoolUtil.calcSectionLength(1.5), {ease: FlxEase.sineOut});
					}
				case 'hot air balloon':
					switch (curStep)
					{
						case 1024:
							defaultCamZoom = 1.35;
							bakaOverlay.visible = true;
							FlxTween.tween(bakaOverlay, {alpha: 1}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineIn});
						case 1280:
							defaultCamZoom = 1;
							FlxTween.tween(bakaOverlay, {alpha: 0}, CoolUtil.calcSectionLength(2), {ease: FlxEase.sineOut});
					}
				case 'shrinking violet':
					switch (curStep)
					{
						case 784:
							defaultCamZoom = 1.3;
							sparkleBG.visible = true;
							add(sparkleFG);
							add(pinkOverlay);
						case 1024:
							defaultCamZoom = 1;
						case 1040:
							FlxTween.tween(sparkleBG, {alpha: 0}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(sparkleFG, {alpha: 0}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(pinkOverlay, {alpha: 0}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
					}
				case 'titular (mc mix)':
					switch (curStep)
					{
						case 730:
							defaultCamZoom = 1;
							oneMore();
						case 736:
							defaultCamZoom = 0.75;
					}
				case 'constricted':
					switch (curStep)
					{
						case 624:
							FlxTween.tween(zippergoo, {alpha: 1}, CoolUtil.calcSectionLength(0.1), {ease: FlxEase.sineOut});
							add(zippergoo);
							vignette.alpha = 0.2;
							add(vignette);
							camFocus = false;
							camFollow.setPosition(dad.getMidpoint().x, dad.getMidpoint().y);
							FlxTween.tween(FlxG.camera, {zoom: 1.5}, CoolUtil.calcSectionLength());
							camGame.shake(0.01, CoolUtil.calcSectionLength());
						case 639: // 640 is too late
							camFocus = true;
						// defaultCamZoom = 0.75;
						case 1024:
							FlxTween.tween(zippergoo, {alpha: 0.01}, CoolUtil.calcSectionLength(2), {ease: FlxEase.sineOut});
							FlxTween.tween(vignette, {alpha: 0.01}, CoolUtil.calcSectionLength(2), {ease: FlxEase.sineOut});
					}
				case 'deep breaths':
					switch (curStep)
					{
						case 138:
							dad.playAnim('breath');
							dad.specialAnim = true;
						case 148:
							FlxG.sound.play(Paths.sound('exhale'));
					}
				case 'wilted':
					switch (curStep)
					{
						case 16:
							if (whiteflash.alpha == 1)
							{
								whiteflash.makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
								whiteflash.alpha = 1;
								FlxTween.tween(whiteflash, {alpha: 0.001}, CoolUtil.calcSectionLength(0.1), {ease: FlxEase.sineOut});
							}
						case 512:
							glitchEffect();
						case 516:
							glitchEffect();
							addcharacter("senpai-angry", 1);
						case 520:
							glitchEffect();
							wiltedwindow.loadGraphic(Paths.image('wilt/p2', 'doki'));
							wiltedwindow.cameras = [camGame2];
						case 656:
							defaultCamZoom = 0.8;
							wiltswap(1);
						case 708:
							defaultCamZoom = 0.7;
						case 841:
							dad.playAnim('swap');
						case 848:
							addcharacter("senpai-angynonpixel", 1);
						case 912:
							wiltedhey.alpha = 1;
							wiltedhey.animation.play('Hey');
							wiltedhey_senpai.alpha = 1;
							wiltedhey_senpai.animation.play('Hey_Senpai');
						case 929:
							remove(wiltedhey_senpai);
							remove(wiltedhey);
						case 928:
							wiltswap(0);
							addcharacter("senpai-angry", 1);
						case 1056:
							// Start final thing
							wiltedHmph.alpha = 1;
							wiltedHmph.animation.play('Hmph');
						case 1064:
							wiltbg.visible = false;
							wiltedwindow.visible = false;
							dad.visible = false;
							boyfriend.visible = false;
						case 1100:
							// Fade to black
							whiteflash.makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
							whiteflash.alpha = 0.01;
							FlxTween.tween(whiteflash, {alpha: 1}, CoolUtil.calcSectionLength(0.7), {ease: FlxEase.sineOut});
					}
				case 'joyride':
					switch (curStep)
					{
						case 126:
							encoreTime = 2;
							defaultCamZoom = 1.3;
						case 254:
							encoreTime = 0;
							defaultCamZoom = 1.6;
						case 270 | 780:
							encoreTime = 2;
							defaultCamZoom = 1;
						case 512:
							encoreTime = 0;
						case 768:
							defaultCamZoom = 1.6;
						case 1024:
							encoreTime = 0;
					}
				case 'our harmony':
					switch (curStep)
					{
						case 2420:
							lyrics.y += 80;

							scorePop = false;
							FlxTween.tween(healthBarBG, {alpha: 0}, 2, {ease: FlxEase.sineIn});
							FlxTween.tween(healthBar, {alpha: 0}, 2, {ease: FlxEase.sineIn});
							FlxTween.tween(iconP1, {alpha: 0}, 2, {ease: FlxEase.sineIn});
							FlxTween.tween(iconP2, {alpha: 0}, 2, {ease: FlxEase.sineIn});
							FlxTween.tween(scoreTxt, {alpha: 0}, 2, {ease: FlxEase.sineIn});

							FlxTween.tween(laneunderlay, {alpha: 0}, 2, {ease: FlxEase.sineIn});
							FlxTween.tween(laneunderlayOpponent, {alpha: 0}, 2, {ease: FlxEase.sineIn});

							if (positionBar)
								positionDisplay.tweenOut(2);

							if (SaveData.judgementCounter)
								FlxTween.tween(judgementCounter, {alpha: 0}, 2, {ease: FlxEase.sineIn});

							FlxTween.tween(whiteflash, {alpha: 1}, 2, {ease: FlxEase.sineIn});
						case 2432:
							for (i in 0...4)
							{
								FlxTween.tween(opponentStrums.members[i], {y: opponentStrums.members[i].y - 10, alpha: 0}, 1,
									{ease: FlxEase.circOut, startDelay: 0.5 + (0.1 * i)});
								FlxTween.tween(playerStrums.members[i], {y: playerStrums.members[i].y - 10, alpha: 0}, 1,
									{ease: FlxEase.circOut, startDelay: 0.5 + (0.1 * i)});
							}
						case 2448:
							if (hueh231 != null)
								hueh231.visible = false;

							canShowPracticeTxt = false;
							botPlayState.visible = false;
							practiceTxt.visible = false;

							cg1.alpha = 1;
							vocals.volume = 1;
							FlxTween.tween(cg1, {"scale.x": 0.67, "scale.y": 0.67}, 5, {ease: FlxEase.sineIn});
							camZooming = false;
							FlxG.camera.zoom = defaultCamZoom;
							camHUD.zoom = defaultCamZoom;
						case 2456:
							FlxTween.tween(whiteflash, {alpha: 0}, 2, {ease: FlxEase.sineIn});
						case 2568:
							FlxTween.tween(whiteflash, {alpha: 1}, 0.57, {ease: FlxEase.sineIn});
						case 2578:
							cg1.alpha = 0;
							cg2.alpha = 1;
							FlxTween.tween(whiteflash, {alpha: 0}, 1, {ease: FlxEase.sineIn});
							FlxTween.tween(cg2, {x: -954}, 9, {ease: FlxEase.sineIn});
						case 2590:
						// end here
						case 2674:
							FlxTween.tween(whiteflash, {alpha: 1}, 1, {ease: FlxEase.sineIn});
						case 2694:
							cg2.alpha = 0;
							cg2Group.alpha = 1;

							for (item in cg2Group.members)
								FlxTween.tween(item, {x: -250}, 17 + (1 * item.ID), {ease: FlxEase.sineIn});

							FlxTween.tween(whiteflash, {alpha: 0}, 1, {ease: FlxEase.sineIn});
						// Fade out
						case 2702:
							// End here
					}
				case 'neet':
					switch (curStep)
					{
						case 384:
							gf.alpha = 0.001;
							deskfront.alpha = 0.001;
							blackScreenBG.alpha = 0.98;
							spotlight.alpha = 1;
							FlxG.sound.play(Paths.sound('spotlight'));
							camFocus = false;
							moveCamera('centered');
							camFollow.x = 554;
							defaultCamZoom = 1.05;
						case 512:
							gf.alpha = 1;
							deskfront.alpha = 1;
							bgDokis.alpha = 1;
							spotlight.alpha = 0;
							blackScreenBG.alpha = 0;
							camFocus = true;
							defaultCamZoom = 0.75;
					}
				case 'takeover medley':
					switch (curStep)
					{
						case 1:
							FlxTween.tween(whiteflash, {alpha: 1}, 2.6, {
								ease: FlxEase.sineOut,
								onComplete: function(tween:FlxTween)
								{
									blackScreen.visible = false;
									FlxTween.tween(whiteflash, {alpha: 0}, 1, {ease: FlxEase.sineOut});
								}
							});
						case 20:
							positionDisplay.tweenIn();
							metadataDisplay.tweenIn();
						case 48:
							FlxTween.tween(cg1, {alpha: 0.001}, 1, {
								ease: FlxEase.sineOut,
								onComplete: function(tween:FlxTween)
								{
									cg1.loadGraphic(Paths.image('credits/CreditsShit2', 'doki'));
									cg1.screenCenter();
								}
							});
						case 54:
							metadataDisplay.tweenOut();
							FlxTween.tween(camHUD, {alpha: 1}, 2, {ease: FlxEase.sineOut});
							FlxTween.tween(camFollow, {y: 460}, 2, {ease: FlxEase.sineOut});
						case 76:
							forcedPause = 'monika';
							summmonStickies(true, 8);
							creditsCharSwap("monika-pixelnew", true);
						case 208 | 464 | 592 | 720 | 848 | 976 | 1104 | 1300 | 1744 | 1880 | 2008 | 2072 | 2136 | 2200:
							summmonStickies(true, 8);
						case 239:
							defaultCamZoom = 0.5;
							moveCamera('centered');
							forcedPause = 'senpai';
							camFollow.y += 50;
							// Worst thing known to man right now

							FlxTween.tween(p2Box, {x: p2Box.x - 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(p2Boxtop, {x: p2Boxtop.x - 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(dad, {x: dad.x - 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});

							FlxTween.tween(p1Box, {x: p1Box.x + 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(p1Boxtop, {x: p1Boxtop.x + 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(boyfriend, {x: boyfriend.x + 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});

							cursorDDTO.setPosition(500, 1060);
							FlxTween.tween(senpaiBox, {y: senpaiBox.y - 900}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(senpaiBoxtop, {y: senpaiBoxtop.y - 900}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(cursorDDTO, {y: cursorDDTO.y - 900 + 10}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(gf, {y: gf.y - 900}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
						case 336:
							summmonStickies(true, 8);
							addcharacter("senpai-angry", 2);
							gf.y -= 900;
						case 440:
							FlxTween.tween(senpaiBox, {y: senpaiBox.y - 1200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(senpaiBoxtop, {y: senpaiBoxtop.y - 1200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(cursorDDTO, {y: cursorDDTO.y - 1200 + 10}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(gf, {y: gf.y - 1200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
						case 447:
							moveCamera('centered');
							defaultCamZoom = 0.7;

							FlxTween.tween(p2Box, {x: p2Box.x + 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(p2Boxtop, {x: p2Boxtop.x + 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(dad, {x: dad.x + 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});

							FlxTween.tween(p1Box, {x: p1Box.x - 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(p1Boxtop, {x: p1Boxtop.x - 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
							FlxTween.tween(boyfriend, {x: boyfriend.x - 200}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
						case 460:
							forcedPause = 'sayori';
							creditsCharSwap("sayori");
							senpaiBox.visible = false;
							senpaiBoxtop.visible = false;
							gf.visible = false;
						case 844:
							forcedPause = 'natsuki';
							creditsCharSwap("natsuki");
						case 1228:
							forcedPause = 'yuri';
							creditsCharSwap("yuri");
							summmonStickies(true, 8);
						case 1392:
							FlxTween.tween(staticcredits, {alpha: 1}, CoolUtil.calcSectionLength(5), {ease: FlxEase.sineOut});
							FlxTween.tween(dad, {alpha: 0}, 5, {ease: FlxEase.sineOut});
							FlxTween.tween(extrachar1, {alpha: 1}, 5, {ease: FlxEase.sineOut});
						case 1488:
							staticcredits.alpha = 0.0001;
							dad.alpha = 1;
							extrachar1.alpha = 0;
							creditsCharSwap("yuri");
							summmonStickies(true, 8);
						case 1616:
							forcedPause = 'protag';
							creditsCharSwap("protag");
							summmonStickies(true, 8);
						case 66 | 450 | 834 | 1218 | 1606 | 1866:
							prepareCharSwap();
						case 1876:
							forcedPause = 'monika';
							creditsCharSwap("monika");
							cursorDDTO.visible = false;
						case 2240:
							FlxTween.tween(camHUD, {alpha: 0}, 5, {ease: FlxEase.sineOut});
							FlxTween.tween(camFollow, {y: -930}, 5, {ease: FlxEase.sineOut});
						case 2264:
							camZooming = false;
						case 2280:
							FlxTween.tween(cg1, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
						case 2322:
							FlxTween.tween(cg1, {alpha: 0.001}, 1, {
								ease: FlxEase.sineOut,
								onComplete: function(tween:FlxTween)
								{
									cg1.loadGraphic(Paths.image('credits/DokiTakeoverLogo', 'doki'));
									cg1.screenCenter();
								}
							});
						case 2330:
							FlxTween.tween(cg1, {alpha: 1}, 0.5, {ease: FlxEase.sineOut});
						case 2358:
							FlxTween.tween(cg2, {alpha: 1}, 1, {ease: FlxEase.sineOut});
					}
				case 'drinks on me':
					switch (curStep)
					{
						case 2:
							FlxTween.tween(cg1, {alpha: 1}, 2.5, {ease: FlxEase.sineIn});
						case 50:
							FlxTween.tween(cg1, {alpha: 0}, 1.2, {ease: FlxEase.sineIn});
						case 62:
							FlxTween.tween(cg2, {alpha: 1}, 2.5, {ease: FlxEase.sineIn});
						case 100: // lazy
							remove(blackScreen);
							iconP2.alpha = 1;
							iconP1.alpha = 1;
							healthBar.alpha = 1;
							healthBarBG.alpha = 1;
							scoreTxt.alpha = 1;
						case 111:
							positionDisplay.tweenIn();
							metadataDisplay.tweenIn();
							FlxTween.tween(cg2, {alpha: 0}, 1.2, {ease: FlxEase.sineIn});
							for (i in 0...4)
							{
								FlxTween.tween(playerStrums.members[i], {y: playerStrums.members[i].y + 10, alpha: 1}, 1,
									{ease: FlxEase.circOut, startDelay: 0.6 + (0.2 * i)});
								FlxTween.tween(opponentStrums.members[i], {y: opponentStrums.members[i].y + 10, alpha: 1}, 1,
									{ease: FlxEase.circOut, startDelay: 0.6 + (0.2 * i)});
							}

						case 160:
							metadataDisplay.tweenOut();
						case 512:
							whiteflash.alpha = 1;
							FlxTween.tween(whiteflash, {alpha: 0.001}, CoolUtil.calcSectionLength(0.2), {ease: FlxEase.sineOut});
							danaBop.visible = true;
							defaultCamZoom = 1;
						case 752:
							defaultCamZoom = 1.4;
						case 768:
							whiteflash.alpha = 1;
							FlxTween.tween(whiteflash, {alpha: 0.001}, CoolUtil.calcSectionLength(0.2), {ease: FlxEase.sineOut});
							defaultCamZoom = 0.85;
							dorth.visible = true;
							alma.visible = true;
						case 1008: // wow they're singing together
							var placement:Float = 320;

							// Not middle scroll and not mirror mode
							// unless you really want mirror mode.
							// i want mirror mode!
							if (!middleScroll)
							{
								var player = mirrormode ? opponentStrums : playerStrums;
								var oppo = mirrormode ? playerStrums : opponentStrums;

								var playerAlpha = mirrormode ? 0 : 1;
								var oppoAlpha = mirrormode ? 1 : 0;

								var playerLay = mirrormode ? laneunderlayOpponent : laneunderlay;
								var oppoLay = mirrormode ? laneunderlay : laneunderlayOpponent;

								var playerLayAlpha = mirrormode ? 0 : SaveData.laneTransparency;
								var oppoLayAlpha = mirrormode ? SaveData.laneTransparency : 0;

								for (i in 0...4)
								{
									FlxTween.tween(player.members[i], {x: player.members[i].x - placement, alpha: playerAlpha}, 2.5,
										{ease: FlxEase.smootherStepInOut});
									FlxTween.tween(oppo.members[i], {x: oppo.members[i].x + placement, alpha: oppoAlpha}, 2.5,
										{ease: FlxEase.smootherStepInOut});
								}

								FlxTween.tween(playerLay, {x: playerLay.x - placement, alpha: playerLayAlpha}, 1.5,
									{ease: FlxEase.smootherStepInOut});
								FlxTween.tween(oppoLay, {x: oppoLay.x + placement, alpha: oppoLayAlpha}, 1.5,
									{ease: FlxEase.smootherStepInOut});
							}
						case 1020:
							encoreTime = 4;
						case 1144: // singing their own sections now
							// Reverse placement
							var placement:Float = -320;

							if (!middleScroll)
							{
								var player = mirrormode ? opponentStrums : playerStrums;
								var oppo = mirrormode ? playerStrums : opponentStrums;

								var playerLay = mirrormode ? laneunderlayOpponent : laneunderlay;
								var oppoLay = mirrormode ? laneunderlay : laneunderlayOpponent;

								for (i in 0...4)
								{
									FlxTween.tween(player.members[i], {x: player.members[i].x - placement, alpha: 1}, 1.5,
										{ease: FlxEase.smootherStepInOut});
									FlxTween.tween(oppo.members[i], {x: oppo.members[i].x + placement, alpha: 1}, 1.5,
										{ease: FlxEase.smootherStepInOut});
								}

								FlxTween.tween(playerLay, {x: playerLay.x - placement, alpha: SaveData.laneTransparency}, 1.5,
									{ease: FlxEase.smootherStepInOut});
								FlxTween.tween(oppoLay, {x: oppoLay.x + placement, alpha: SaveData.laneTransparency}, 1.5,
									{ease: FlxEase.smootherStepInOut});
							}
						case 1276:
							encoreTime = 0;
						case 1280:
							whiteflash.alpha = 1;
							FlxTween.tween(whiteflash, {alpha: 0.001}, CoolUtil.calcSectionLength(0.2), {ease: FlxEase.sineOut});
							dorth.visible = false;
							alma.visible = false;
							danaBop.visible = false;
						case 1412:
							anaThingie.animation.play('static');
					}
				case 'you and me':
					switch (curStep)
					{
						case 1:
							cameraSpeed = 1;
							camFocus = false;
						case 14:
							FlxTween.tween(camFollow, {y: -3404, x: 589}, 15, {ease: FlxEase.linear});
						case 16:
							FlxTween.tween(whiteflash, {alpha: 0.001}, 3, {ease: FlxEase.sineOut});
						case 19:
							funnytext.resetText("A few days passed since Boyfriend and Girlfriend’s\nlast visit to the club.");
							funnytext.start(0.04);
						case 84:
							funnytext.resetText("The Literature Club returned to its original 5 members.");
							funnytext.start(0.04);
						case 141:
							funnytext.resetText("The days continued as normal, with club meetings\nfilled with stories, sweets, and singing.");
							funnytext.start(0.04);
						case 208:
							funnytext.resetText("Things were going well, especially for a certain someone- ");
							funnytext.start(0.04);
						case 252:
							FlxTween.tween(funnytext, {alpha: 0}, 0.5, {ease: FlxEase.sineIn});
						case 240:
							if (SaveData.judgementCounter)
								FlxTween.tween(judgementCounter, {alpha: 1}, 0.5, {ease: FlxEase.sineIn});

							if (mirrormode && middleScroll)
							{
								// do nothing!
							}
							else
							{
								FlxTween.tween(laneunderlay, {alpha: SaveData.laneTransparency}, 0.5, {ease: FlxEase.sineIn});
							}

							FlxTween.tween(iconP1, {alpha: 1}, 0.5, {ease: FlxEase.sineIn});
							FlxTween.tween(healthBar, {alpha: 1}, 0.5, {ease: FlxEase.sineIn});
							FlxTween.tween(healthBarBG, {alpha: 1}, 0.5, {ease: FlxEase.sineIn});
							FlxTween.tween(scoreTxt, {alpha: 1}, 0.5, {ease: FlxEase.sineIn});
							camZooming = true;

							var targetAlpha:Float = 1;

							if (mirrormode && middleScroll)
								targetAlpha = SaveData.middleOpponent ? 0.35 : 0;

							var whichStrums:FlxTypedGroup<StrumNote> = (mirrormode ? opponentStrums : playerStrums);

							for (i in 0...4)
							{
								FlxTween.tween(whichStrums.members[i], {y: whichStrums.members[i].y + 10, alpha: targetAlpha}, 1,
									{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
							}
						case 248:
							blackBars(true);
							FlxTween.tween(camFollow, {y: 326}, 3, {
								ease: FlxEase.linear,
								onComplete: function(twn:FlxTween)
								{
									camFocus = true;
								}
							});
						case 336:
							if (mirrormode)
								bringInThingie();
						case 520:
							defaultCamZoom = 1.1;
						case 784:
							FlxTween.tween(dokiBackdrop, {alpha: 1}, CoolUtil.calcSectionLength(0.5), {
								ease: FlxEase.sineIn,
								onComplete: function(tween:FlxTween)
								{
									defaultCamZoom = 1.1;
								}
							});
						case 1068:
							defaultCamZoom = 0.9;
							FlxTween.tween(dokiBackdrop, {alpha: 0}, 3, {ease: FlxEase.sineIn});
						case 1122:
							blackBars(false);
							camFocus = false;
							FlxTween.tween(camFollow, {y: -3404, x: 589}, 5, {ease: FlxEase.linear});
						case 1134:
							FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.sineOut});
						case 1156:
							canPause = false;
							openSubState(new DokiCards(!isStoryMode));
						case 1246:
							var targetAlpha:Float = 1;

							if (!mirrormode && middleScroll)
								targetAlpha = SaveData.middleOpponent ? 0.35 : 0;

							var whichStrums:FlxTypedGroup<StrumNote> = (mirrormode ? playerStrums : opponentStrums);

							for (i in 0...4)
							{
								FlxTween.tween(whichStrums.members[i], {y: whichStrums.members[i].y + 10, alpha: targetAlpha}, 1,
									{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
							}

							if (!middleScroll)
								FlxTween.tween(laneunderlayOpponent, {alpha: SaveData.laneTransparency}, 0.5, {ease: FlxEase.sineIn});
							else if (mirrormode && middleScroll)
								FlxTween.tween(laneunderlay, {alpha: SaveData.laneTransparency}, 0.5, {ease: FlxEase.sineIn});
						case 1252:
							blackBars(true);
							FlxTween.tween(camFollow, {y: 326}, 3, {
								ease: FlxEase.linear,
								onComplete: function(twn:FlxTween)
								{
									camFocus = true;
								}
							});
						case 1776:
							defaultCamZoom = 1;
						case 1904:
							FlxTween.tween(dokiBackdrop, {alpha: 1}, CoolUtil.calcSectionLength(0.5), {ease: FlxEase.sineIn});
							defaultCamZoom = 0.9;
						case 2160:
							blackBars(false);
							FlxTween.tween(dokiBackdrop, {alpha: 0}, 3, {ease: FlxEase.sineIn});
						case 2638:
							camFocus = false;
							FlxTween.tween(camFollow, {y: -3404, x: 589}, 5, {ease: FlxEase.linear});
							FlxTween.tween(camHUD, {alpha: 0}, 2, {ease: FlxEase.sineOut});
					}
				case 'love n funkin':
					// Jorge please don't kill me ~M&M
					switch (curStep)
					{
						case 383:
							poemVideo.bitmap.time = 0;
						case 384:
							dokiData = [
								extrachar2.x,
								extrachar2.y,
								extrachar2.scrollFactor.x,
								extrachar2.scrollFactor.y,
								extrachar2.scale.x,
								extrachar2.scale.y,
								members.indexOf(extrachar2)
							];

							remove(extrachar2);
							insert(members.indexOf(sideWindow) + 1, extrachar2);
							extrachar2.setPosition(6, 200);
							extrachar2.scrollFactor.set();
							extrachar2.scale.set(0.8, 0.8);
							extrachar2.updateHitbox();
							extrachar2.cameras = [camGame2];
							extrachar2.dance();
							
							camZooming = false;
							camGame2.fade(FlxColor.WHITE, 0.5, true);
							poemVideo.alpha = 1;
							sideWindow.alpha = 1;
						case 504:
							FlxTween.tween(extrachar2, {x: -extrachar2.width * 1.5}, CoolUtil.calcSectionLength(0.25), {ease: FlxEase.sineInOut});
						case 508:
							FlxTween.cancelTweensOf(extrachar2);
							remove(extrachar2);
							insert(Std.int(dokiData[6]), extrachar2);
							extrachar2.setPosition(dokiData[0], dokiData[1]);
							extrachar2.scrollFactor.set(dokiData[2], dokiData[3]);
							extrachar2.scale.set(dokiData[4], dokiData[5]);
							extrachar2.updateHitbox();
							extrachar2.cameras = [camGame];
							extrachar2.dance();

							dokiData = [
								gf.x,
								gf.y,
								gf.scrollFactor.x,
								gf.scrollFactor.y,
								gf.scale.x,
								gf.scale.y,
								members.indexOf(gf)
							];

							remove(gf);
							insert(members.indexOf(sideWindow) + 1, gf);
							gf.setPosition(-gf.width * 1.5, 170);
							gf.scrollFactor.set();
							gf.scale.set(0.72, 0.72);
							gf.updateHitbox();
							gf.cameras = [camGame2];
							gf.dance();
							FlxTween.tween(gf, {x: -75}, CoolUtil.calcSectionLength(0.25), {ease: FlxEase.sineInOut});
						case 640:
							remove(gf);
							insert(Std.int(dokiData[6]), gf);
							gf.setPosition(dokiData[0], dokiData[1]);
							gf.scrollFactor.set(dokiData[2], dokiData[3]);
							gf.scale.set(dokiData[4], dokiData[5]);
							gf.updateHitbox();
							gf.cameras = [camGame];
							gf.dance();
							
							camZooming = true;
							camGame2.fade(FlxColor.WHITE, 0.5, true);
							poemVideo.alpha = 0.001;
							sideWindow.alpha = 0.001;
					}
				case 'libitina':
					switch (curStep)
					{
						case 16:
							FlxTween.tween(blackScreen, {alpha: 0.001}, CoolUtil.calcSectionLength(2), {ease: FlxEase.sineOut});
						case 68:
							FlxTween.tween(deskBG2, {alpha: 1}, CoolUtil.calcSectionLength(0.25), {
								ease: FlxEase.sineIn,
								onComplete: function(tween:FlxTween)
								{
									deskBG1.alpha = 0.001;
									rainBG.alpha = 0.001;
								}
							});
						case 72:
							FlxTween.tween(FlxG.camera, {zoom: 1.5}, CoolUtil.calcSectionLength(2.25), {ease: FlxEase.quadIn});
							FlxTween.tween(camGame2, {zoom: 1.5}, CoolUtil.calcSectionLength(2.25), {ease: FlxEase.quadIn});
							defaultCamZoom = 1.5;
						case 94:
							cursorDDTO.alpha = 1;
							FlxTween.tween(cursorDDTO, {x: 660, y: 400}, CoolUtil.calcSectionLength(0.9), {ease: FlxEase.quadOut});
						case 110:
							cursorDDTO.scale.set(0.9, 0.9);
						case 111:
							cursorDDTO.scale.set(1, 1);
						case 112:
							extractPopup.alpha = 1;
							extractPopup.scale.set();
							FlxTween.tween(extractPopup, {"scale.x": 1, "scale.y": 1}, 0.2, {ease: FlxEase.quadOut});
						case 114:
							FlxTween.tween(cursorDDTO, {alpha: 0.001}, 0.3, {ease: FlxEase.sineIn});
						case 120:
							FlxTween.tween(deskBG2, {alpha: 0.001}, CoolUtil.calcSectionLength(0.3125), {ease: FlxEase.sineIn});
						case 126:
							libShader();
						case 127:
							testVM.bitmap.time = 0;
						case 128:
							libShader(false);
							FlxG.camera.zoom = 1;
							camGame2.zoom = 1;
							defaultCamZoom = 1;

							camGame2.fade(FlxColor.WHITE, 0.2, true);
							deskBG2.alpha = 0.001;
							extractPopup.alpha = 0.001;
							testVM.alpha = 1;
							deskBG2Overlay.alpha = 0.15;
							camHUD.alpha = 1;
						case 160 | 224 | 288 | 480 | 576 | 688 | 800 | 896 | 1024:
							libPopup(526, FlxG.random.int(88, 442), FlxG.random.float(0.9, 1.1), FlxG.random.float(0, 2));
							libPopup(808, FlxG.random.int(88, 442), FlxG.random.float(0.9, 1.1), FlxG.random.float(0, 2));
							libPopup(184, FlxG.random.int(88, 442), FlxG.random.float(0.9, 1.1), FlxG.random.float(0, 2));
						case 352:
							libiWindow.alpha = 1;
							libiWindow.scale.set();
							FlxTween.tween(libiWindow, {"scale.x": 1.1, "scale.y": 1.1}, 0.2, {ease: FlxEase.quadOut});
						case 364:
							libHando.alpha = 1;
							libHando.animation.play('idle', true);
						case 368:
							if (SaveData.judgementCounter)
								FlxTween.tween(judgementCounter, {alpha: 1}, 0.5, {ease: FlxEase.sineIn});

							FlxTween.tween(laneunderlay, {alpha: SaveData.laneTransparency}, 0.5, {ease: FlxEase.sineIn});

							FlxTween.tween(iconP1, {alpha: 1}, 0.5, {ease: FlxEase.sineIn});
							FlxTween.tween(healthBar, {alpha: 1}, 0.5, {ease: FlxEase.sineIn});
							FlxTween.tween(healthBarBG, {alpha: 1}, 0.5, {ease: FlxEase.sineIn});
							FlxTween.tween(scoreTxt, {alpha: 1}, 0.5, {ease: FlxEase.sineIn});

							for (i in 0...4)
							{
								FlxTween.tween(playerStrums.members[i], {y: playerStrums.members[i].y + 10, alpha: 1}, 1,
									{ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
							}
						case 384:
							libHando.alpha = 0.001;
							camGame2.fade(FlxColor.WHITE, 0.2, true);
							libiWindow.scale.set(1, 1);
							boyfriend.setPosition(170, -50);
							boyfriend.cameras = [camGame2];
							boyfriend.alpha = 1;
							camZooming = true;

							remove(grpPopups);
							insert(members.indexOf(boyfriend) + 1, grpPopups);
						case 520 | 1169 | 1181 | 1186 | 1197 | 1568 | 1968 | 2800 | 2864 | 2928:
							libShader();
						case 544 | 1172 | 1184 | 1189 | 1576 | 2816 | 2880 | 2944 | 3666:
							libShader(false);
						case 624:
							testVM.alpha = 0.001;
							libiWindow.alpha = 0.001;
							boyfriend.alpha = 0.001;
							deskBG2Overlay.alpha = 0.001;
							grpPopups.visible = false;
							libAwaken.alpha = 1;
							libAwaken.animation.play('idle', true);
						case 640:
							if (!constantScroll)
								songSpeed += 0.2;

							testVM.alpha = 1;
							boyfriend.alpha = 1;
							deskBG2Overlay.alpha = 0.15;
							grpPopups.visible = true;
							libAwaken.alpha = 0.001;
							camGame2.fade(FlxColor.WHITE, 0.2, true);
							addcharacter('ghost-sketch', 0);
							boyfriend.cameras = [camGame2];

							remove(grpPopups);
							insert(members.indexOf(boyfriend) + 1, grpPopups);

							add(libVignette);
						case 1152:
							FlxTween.tween(testVM, {alpha: 0.001}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
						case 1200:
							libShader(false);
							FlxTween.tween(deskBG2Overlay, {alpha: 0.001}, CoolUtil.calcSectionLength(), {ease: FlxEase.linear});
							camGame2.fade(FlxColor.WHITE, CoolUtil.calcSectionLength(), false);
						case 1216:
							if (SaveData.shaders)
							{
								fishy.preset = 0;
								camGame.setFilters([new ShaderFilter(warpy), new ShaderFilter(fishy)]);
							}

							addcharacter('ghost', 0);
							boyfriend.cameras = [camGame2];

							ghostBG.alpha = 1;
							camGame2.fade(FlxColor.WHITE, 0.2, true);
							noteCam = true;

							remove(grpPopups);
							insert(members.indexOf(boyfriend) + 1, grpPopups);

							remove(libVignette);
							add(libVignette);
						case 1712:
							ghostBG.alpha = 0.001;
							libVignette.alpha = 0.001;
							staticshock.alpha = 1;
							add(staticshock);
						case 1728:
							if (SaveData.shaders)
								camGame.setFilters([new ShaderFilter(fishy)]);

							eyeBG.alpha = 1;
							insert(members.indexOf(boyfriend) + 1, eyeShadow);
							insert(members.indexOf(libVignette), eyeMidwayBG);

							libVignette.alpha = 1;
							staticshock.alpha = 0.001;
						case 1984:
							libShader(false);
							camGame2.fade(FlxColor.WHITE, 0.2, true);
							boyfriend.shader = inverty; // this doesn't have shader check on purpose
							libFinaleOverlay.alpha = 0.001;
							eyeBG.alpha = 0.001;
							eyeShadow.alpha = 0.001;
							eyeMidwayBG.alpha = 0.001;
							infoBG.alpha = 1;
						case 2240:
							camGame2.fade(FlxColor.WHITE, 0.2, true);
							boyfriend.shader = null; // this doesn't have shader check on purpose
							infoBG.alpha = 0.001;
							infoBG2.alpha = 1;
						case 2480:
							camGame2.fade(FlxColor.BLACK, 0, false);
						case 2495:
							crackBG.bitmap.time = 0;
						case 2496:
							camGame2.fade(FlxColor.WHITE, 0.2, true);
							infoBG2.alpha = 0.001;
							crackBG.alpha = 1;
							libVignette.loadGraphic(Paths.image('libitina/vignetteend', 'doki'));
						case 2752 | 2817 | 2881 | 2945 | 2960 | 2972 | 2974 | 2976 | 2978 | 2980 | 2981 | 2982 | 2983 | 2984 | 2985 | 2986 | 2987 | 2988 | 2889 | 2890 | 2891 | 2892 | 2893:
							// this looks so fucking ugly
							libPopup(FlxG.random.int(386, 666), FlxG.random.int(68, 482), FlxG.random.float(0.95, 1.25), '', 'red', FlxG.random.float(0, 1));
							libPopup(FlxG.random.int(668, 948), FlxG.random.int(68, 482), FlxG.random.float(0.95, 1.25), '', 'red', FlxG.random.float(0, 1));
							libPopup(FlxG.random.int(44, 324), FlxG.random.int(68, 482), FlxG.random.float(0.95, 1.25), '', 'red', FlxG.random.float(0, 1));
						case 2994:
							libiWindow.loadGraphic(Paths.image('libitina/granted', 'doki'));
							libiWindow.screenCenter();
							libiWindow.alpha = 1;
							libiWindow.scale.set();
							FlxTween.tween(libiWindow, {"scale.x": 1, "scale.y": 1}, 0.2, {ease: FlxEase.quadOut});

							remove(libiWindow);
							insert(members.indexOf(boyfriend) + 69, libiWindow);
						case 3008:
							camGame2.fade(FlxColor.WHITE, 0, false);
							boyfriend.alpha = 0.001;
							crackBG.alpha = 0.001;
							libiWindow.alpha = 0.001;

							noteCam = false;
							camZooming = false;
							FlxG.camera.zoom = defaultCamZoom;
							camGame2.zoom = defaultCamZoom;
							camHUD.zoom = defaultHudZoom;

							libVignette.loadGraphic(Paths.image('libitina/vignette', 'doki'));
							libFinaleBG.alpha = 1;
							libGhost.alpha = 1;

							remove(grpPopups);
						case 3020:
							camGame2.fade(FlxColor.WHITE, CoolUtil.calcSectionLength(2), true);
						case 3040:
							if (!constantScroll)
								songSpeed /= 2;
						case 3060:
							FlxTween.tween(libFinaleBG, {y: libFinaleBG.y - 560}, CoolUtil.calcSectionLength(6), {ease: FlxEase.sineInOut});
							FlxTween.tween(libGhost, {y: libGhost.y - 580}, CoolUtil.calcSectionLength(5), {ease: FlxEase.sineInOut, startDelay: CoolUtil.calcSectionLength(1.1)});
						case 3584:
							camGame2.fade(FlxColor.WHITE, 0.2, true);
							libParty.alpha = 1;
							libRockIs.alpha = 1;
						case 3624:
							FlxTween.tween(libFinale, {alpha: 1}, CoolUtil.calcSectionLength(0.35), {
								ease: FlxEase.sineIn,
								onComplete: function(tween:FlxTween)
								{
									libFinaleBG.alpha = 0.001;
									libGhost.alpha = 0.001;
									libParty.alpha = 0.001;
									libRockIs.alpha = 0.001;
								}
							});
						case 3646 | 3682 | 3688 | 3710:
							libShader(true, false);
						case 3648:
							// I would've used the switch case but then it wouldn't run the loadGraphic stuff
							libShader(false);
							libFinale.loadGraphic(Paths.image('libitina/finale/Finale3', 'doki'));
						case 3664:
							libShader(true, false);
							libFinaleOverlay.alpha = 1;
						case 3684:
							libShader(false);
							libFinale.loadGraphic(Paths.image('libitina/finale/Finale4', 'doki'));
						case 3692:
							libShader(false);

							libFinaleOverlay.setGraphicSize(Std.int(FlxG.width * 0.86 / defaultCamZoom));
							libFinaleOverlay.screenCenter();

							deskBG2.loadGraphic(Paths.image('libitina/outroscreen', 'doki'));
							camHUD.alpha = 0.001;
							libFinale.alpha = 0.001;
							deskBG2.alpha = 1;
						case 3711:
							rainBG.bitmap.time = 0;
						case 3712:
							camGame2.zoom = 1.4;
							FlxTween.tween(camGame2, {zoom: 1}, CoolUtil.calcSectionLength(2.5), {ease: FlxEase.sineInOut});

							libShader(false);
							metadataDisplay.tweenIn();
							deskBG1.loadGraphic(Paths.image('libitina/outrodesk', 'doki'));
							deskBG1.alpha = 1;
							rainBG.alpha = 1;
							deskBG2.alpha = 0.001;
							libFinaleOverlay.alpha = 0.001;
						case 3760:
							camGame2.fade(FlxColor.WHITE, 0.3, true);
							metadataDisplay.visible = false;
							camHUD.alpha = 0.001;
							deskBG1.alpha = 0.001;
							rainBG.alpha = 0.001;
					}
			}
		}

		// have lyrics fade in and out if possible
		if (hasLyrics && lyrics != null)
		{
			for (i in 0...lyricData.length)
			{
				if (curStep == lyricData[i][0])
				{
					lyrics.text = lyricData[i][1];
					lyrics.screenCenter(X);
				}
			}
		}
	}

	var libPopupTypes:Array<Array<String>> = [
		[
			"Binary",
			"Error",
			"Unauthorized",
			"Unknown",
			"Unspecified"
		],
		[
			"Access",
			"Corrupted"
		]
	];

	function libPopup(X:Float = 0, Y:Float = 0, Scale:Float = 1, Type:String = 'Unspecified', Style:String = '', ?Delay:Float = 0, ?Random:Bool = true)
	{
		if (Random)
		{
			var popupArray:Array<String> = libPopupTypes[Style == 'red' ? 1 : 0];

			// Randomize the types, while excluding whatever was the past type
			// so as not to repeat the same type
			curDokiLight = FlxG.random.int(0, popupArray.length - 1, [pastDokiLight]);
			pastDokiLight = curDokiLight;

			Type = popupArray[curDokiLight];
		}

		new FlxTimer().start(Delay, function(tmr:FlxTimer)
		{
			var eye:BGSprite = new BGSprite('libitina/popups$Style/$Type', 'doki', X, Y, 0, 0, ['idle', 'PopupAnim']);
			eye.scale.set(Scale, Scale);
			eye.cameras = [camGame2];
			grpPopups.add(eye);

			new FlxTimer().start(3.4, function(tmr:FlxTimer)
			{
				grpPopups.remove(eye);
				eye.destroy();
			});
		});
	}

	function libShader(show:Bool = true, old:Bool = false)
	{
		var shader = old ? staticlol : glitchlol;
		var shader2 = old ? staticlol2 : glitchlol2;

		if (SaveData.shaders)
		{
			if (show)
			{
				camGame.setFilters([new ShaderFilter(fishy), new ShaderFilter(shader)]);
				camGame2.setFilters([new ShaderFilter(shader2)]);
			}
			else
			{
				camGame.setFilters([new ShaderFilter(fishy)]);
				camGame2.setFilters(null);
			}
		}
	}

	var epipEnding:Bool = false;
	var curDokiLight:Int = 0;
	var pastDokiLight:Int = 1;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
			notes.sort(FlxSort.byY, SaveData.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM TO ' + SONG.notes[Math.floor(curStep / 16)].bpm);
			}
		}

		if (zoomStuff
			&& generatedMusic
			&& SONG.notes[Std.int(curStep / 16)] != null
			&& !endingSong
			&& SONG.notes[Std.int(curStep / 16)].milfZoom
			&& camZooming
			&& FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (zoomStuff && camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curStage.startsWith('doki') && curBeat % 2 == 0)
		{
			if (monika != null)
				monika.dance(true);
			if (protag != null)
				protag.dance(true);
			
			sayori.dance(true);
			natsuki.dance(true);
			yuri.dance(true);
		}

		if (curStage == 'va11halla')
		{
			if (curBeat % 2 == 0)
			{
				danaBop.dance(true);
				alma.dance(true);
			}
				

			dorthDanced = !dorthDanced;

			if (dorthDanced && curBeat % gfSpeed == 0)
				dorth.animation.play('danceLeft');
			else
				dorth.animation.play('danceRight');
		}

		switch (encoreTime)
		{
			default:
			case 1 | 2:
				if (curBeat % 2 == 0)
				{
					// Hi Tioder :)
					// Set colors to an array
					var dokiLights:Array<Int> = [0xff95E0FA, 0xff8CD465, 0xffFC95D3, 0xff9E72D2];

					// Randomize the colors, while excluding whatever was the past light
					// so as not to repeat the same color
					curDokiLight = FlxG.random.int(0, dokiLights.length - 1, [pastDokiLight]);
					pastDokiLight = curDokiLight;

					var funnyFlash:BGSprite = encoreborder;

					if (encoreTime == 2) // Can turn into a switch if need be
						funnyFlash = sunshine;

					FlxTween.cancelTweensOf(funnyFlash);
					funnyFlash.color = dokiLights[curDokiLight];
					funnyFlash.alpha = 1;
					FlxTween.tween(funnyFlash, {alpha: 0.001}, 1, {startDelay: 0.5});
				}
			case 3:
				if (curBeat % 4 == 0 && stickerSprites != null)
					summmonStickies();
			case 4:
				if (curBeat % 2 == 0)
					niconicoLights();
				
		}

		if (zoomStuff)
		{
			iconP1.scale.set(1.2, 1.2);
			iconP2.scale.set(1.2, 1.2);
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (songStarted && !endingSong)
		{
			if (curBeat % 2 == 0)
			{
				if (!boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.dance(isAltAnimSection());
				if (!dad.animation.curAnim.name.startsWith('sing'))
					dad.dance(isAltAnimSection());

				if (SONG.numofchar >= 3)
				{
					if (!extrachar1.animation.curAnim.name.startsWith('sing'))
						extrachar1.dance(isAltAnimSection());
				}

				if (SONG.numofchar >= 4)
				{
					if (!extrachar2.animation.curAnim.name.startsWith('sing'))
						extrachar2.dance(isAltAnimSection());
				}
			}
			else if (curBeat % 2 != 0)
			{
				if (boyfriend.danceIdle && !boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.dance(isAltAnimSection());

				if (dad.danceIdle && !dad.animation.curAnim.name.startsWith('sing'))
					dad.dance(isAltAnimSection());

				if (SONG.numofchar >= 3)
				{
					if (!extrachar1.animation.curAnim.name.startsWith('sing'))
						extrachar1.dance(isAltAnimSection());
				}

				if (SONG.numofchar >= 4)
				{
					if (!extrachar2.animation.curAnim.name.startsWith('sing'))
						extrachar2.dance(isAltAnimSection());
				}
			}

			// when the code don't work https://i.imgur.com/wHYhTSC.png
			if ((!gf.animation.curAnim.name.startsWith('countdown')
				&& !gf.animation.curAnim.name.startsWith('neck')
				&& !gf.animation.curAnim.name.startsWith('sing')
				&& !gf.animation.curAnim.name.startsWith('popup')
				&& !gf.animation.curAnim.name.startsWith('scared')
				|| mirrormode
				&& gf.animation.curAnim.name.startsWith('sing')
				&& gf.animation.curAnim.finished)
				&& curBeat % gfSpeed == 0)
			{
				if (curSong.toLowerCase() == 'catfight' && curStep <= 1136) // No I'm not sorry
					gf.playAnim('gone');
				else
					gf.dance();
			}
				
		}

		if (midsongcutscene)
		{
			if (curSong.toLowerCase() == 'my sweets')
			{
				switch (curBeat)
				{
					case 260:
						dad.playAnim('hmmph');
						dad.specialAnim = true;
				}
			}

			if (curSong.toLowerCase() == 'baka' && !sectionStart)
			{
				switch (curBeat)
				{
					case 16:
						bakaOverlay.visible = true;
						FlxTween.tween(bakaOverlay, {alpha: 1}, CoolUtil.calcSectionLength(2), {ease: FlxEase.sineIn});
					case 32:
						bakaOverlay.animation.play('party rock is', true);
						defaultCamZoom = 1.2;
						camGame.shake(0.002, CoolUtil.calcSectionLength(2));
					case 40:
						camFocus = false;
						camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
					case 48:
						camFocus = true;
						FlxTween.tween(FlxG.camera, {zoom: 0.75}, CoolUtil.calcSectionLength(), {
							ease: FlxEase.sineOut,
							onComplete: function(tween:FlxTween)
							{
								defaultCamZoom = 0.75;
							}
						});
					case 112 | 264:
						FlxTween.tween(bakaOverlay, {alpha: 0}, CoolUtil.calcSectionLength(2), {ease: FlxEase.sineOut});
					case 144:
						bakaOverlay.animation.play('normal', true);
						FlxTween.tween(bakaOverlay, {alpha: 1}, CoolUtil.calcSectionLength(2), {ease: FlxEase.sineIn});
					case 176:
						bakaOverlay.animation.play('party rock is', true);
				}
			}

			if (curSong.toLowerCase() == 'deep breaths' && !sectionStart)
			{
				switch (curBeat)
				{
					case 104:
						sparkleBG.visible = true;
						add(sparkleFG);
						add(pinkOverlay);
					case 200:
						FlxTween.tween(sparkleBG, {alpha: 0}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
						FlxTween.tween(sparkleFG, {alpha: 0}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
						FlxTween.tween(pinkOverlay, {alpha: 0}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineOut});
					case 232:
						sparkleBG.alpha = 1;
						sparkleFG.alpha = 1;
						pinkOverlay.alpha = 0.2;
					case 288:
						FlxTween.tween(sparkleBG, {alpha: 0}, CoolUtil.calcSectionLength(2), {ease: FlxEase.sineOut});
						FlxTween.tween(sparkleFG, {alpha: 0}, CoolUtil.calcSectionLength(2), {ease: FlxEase.sineOut});
						FlxTween.tween(pinkOverlay, {alpha: 0}, CoolUtil.calcSectionLength(2), {ease: FlxEase.sineOut});
				}
			}

			if (curSong.toLowerCase() == 'epiphany')
			{
				switch (curBeat)
				{
					case 1:
						camZooming = true;
					case 4:
						FlxTween.tween(FlxG.camera, {zoom: 0.94}, CoolUtil.calcSectionLength(), {
							ease: FlxEase.sineOut,
							onComplete: function(tween:FlxTween)
							{
								defaultCamZoom = 0.9;
							}
						});
					case 72:
						FlxTween.tween(FlxG.camera, {zoom: 0.8}, CoolUtil.calcSectionLength(), {
							ease: FlxEase.sineOut,
							onComplete: function(tween:FlxTween)
							{
								defaultCamZoom = 0.8;
							}
						});
					case 580:
						FlxTween.tween(FlxG.camera, {zoom: 1}, CoolUtil.calcSectionLength(), {
							ease: FlxEase.sineOut,
							onComplete: function(tween:FlxTween)
							{
								defaultCamZoom = 1.1;
							}
						});
					case 585:
						dokiBackdrop.visible = true;
						FlxTween.tween(dokiBackdrop, {alpha: 1}, CoolUtil.calcSectionLength(), {ease: FlxEase.sineIn});
					case 648:
						FlxTween.tween(FlxG.camera, {zoom: 0.9}, CoolUtil.calcSectionLength(), {
							ease: FlxEase.sineOut,
							onComplete: function(tween:FlxTween)
							{
								defaultCamZoom = 0.9;
							}
						});

						FlxTween.tween(dokiBackdrop, {alpha: 0}, CoolUtil.calcSectionLength(0.5), {ease: FlxEase.sineOut});
						popup.alpha = 1;
						popup.animation.play('idle', true);
					case 776:
						dad.playAnim('lastNOTE_start');
						dad.specialAnim = true;
					case 780:
						if (storyDifficulty != 2)
						{
							if (SaveData.beatEpiphany)
								dad.playAnim('lastNOTE_retry');
							else
								dad.playAnim('lastNOTE_end');
						}
						dad.specialAnim = true;
					case 783:
						if (storyDifficulty == 2)
						{
							dad.playAnim('lastNOTE_end');
							dad.specialAnim = true;
						}
					case 785:
						epipEnding = true;
					case 788:
						FlxTween.tween(iconP2, {alpha: 0}, CoolUtil.calcSectionLength(0.25), {ease: FlxEase.sineOut});

						var moniStrums:FlxTypedGroup<StrumNote> = opponentStrums;
						if (mirrormode) moniStrums = playerStrums;

						for (i in 0...4)
						{
							FlxTween.tween(moniStrums.members[i], {alpha: 0}, CoolUtil.calcSectionLength(0.25), {ease: FlxEase.sineOut});
						}

						if (SaveData.laneUnderlay)
						{
							var moniUnderway:FlxSprite = laneunderlayOpponent;
							if (mirrormode && middleScroll) moniUnderway = laneunderlay;

							FlxTween.tween(moniUnderway, {alpha: 0}, CoolUtil.calcSectionLength(0.25), {ease: FlxEase.sineOut});
						}
					case 790:
						camGame2.fade(FlxColor.BLACK, 0.7 / Conductor.playbackSpeed, false);
				}
			}
		}

		if (curSong.toLowerCase() == "bara no yume" || curSong.toLowerCase() == "poems n thorns")
			bgGirls.dance();
	}

	function penorFunction()
	{
		// my penor ~ Awoofle was here
		trace('penor');
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;

		if (isDad)
			spr = opponentStrums.members[id];
		else
			spr = playerStrums.members[id];

		if (spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);

		if (!SaveData.npsDisplay)
			scoreTxt.text = Ratings.CalculateRanking((practiceMode ? practiceScore : songScore), nps, maxNPS, accuracy);

		if (SaveData.judgementCounter)
		{
			judgementCounter.text = 'Doki: ${sicks}\nGood: ${goods}\nOk: ${bads}\nNo: ${shits}\nMiss: ${misses}\n';
			if (SaveData.earlyLate) judgementCounter.text += '\nEarly: ${earlys}\nLate: ${lates}\n';
			judgementCounter.text += '\n${LangUtil.getString('cmnMax')}: ${maxCombo}\n';
		}
	}

	function moveCameraSection(?id:Int = 0):Void
	{
		if (SONG.notes[id] == null)
			return;

		if (!SONG.notes[Std.int(curStep / 16)].mustHitSection && !SONG.notes[Std.int(curStep / 16)].centeredcamera)
			moveCamera("dad");
		if (SONG.notes[Std.int(curStep / 16)].mustHitSection && !SONG.notes[Std.int(curStep / 16)].centeredcamera)
			moveCamera("bf");
		if (SONG.notes[Std.int(curStep / 16)].centeredcamera)
			moveCamera("centered");
	}

	public function moveCamera(camfocus:String)
	{
		switch (camfocus)
		{
			case "dad":
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

				switch (dad.curCharacter)
				{
					case 'monika-pixel' | 'monika-pixelnew':
						if (SONG.song.toLowerCase() == 'glitcher (monika mix)')
						{
							camFollow.x = dad.getMidpoint().x - 100;
							camFollow.y = dad.getMidpoint().y - 390;
						}
						else
						{
							camFollow.x = dad.getMidpoint().x - 25;
							camFollow.y = dad.getMidpoint().y - 430;
						}
					case 'senpai' | 'senpai-angry' | 'playablesenpai':
						camFollow.x = dad.getMidpoint().x - 100;
						camFollow.y = dad.getMidpoint().y - 430;
					case 'duet' | 'duetnew':
						camFollow.x = dad.getMidpoint().x;
						camFollow.y = dad.getMidpoint().y - 400;
					case 'monika-angryold':
						camFollow.x = dad.getMidpoint().x - 350;
						camFollow.y = dad.getMidpoint().y - 390;
					case 'monika-angry':
						camFollow.x = dad.getMidpoint().x - 250;
						camFollow.y = dad.getMidpoint().y - 300;
					case 'bigmonika' | 'bigmonika-dead':
						camFollow.x = 600;
						camFollow.y = 300;
					case 'monika':
						camFollow.y += 50;
					case 'bf' | 'bf-doki':
						switch (curStage)
						{
							case 'dokiclubroom' | 'dokifestival' | 'dokiglitcher' | 'credits':
								camFollow.y = dad.getMidpoint().y - 200;
						}
					case 'zipper':
						camFollow.y += 50;
					case 'protag':
						camFollow.y -= 0;
					case 'yuri':
						switch (curStage)
						{
							case 'musicroom':
								camFollow.x += 10;
						}
				}
				switch (curStage)
				{
					case 'clubroomevil' | 'libitina':
						camFollow.x = 600;
						camFollow.y = 300;
					case 'wilted':
						camFollow.x = 565;
						camFollow.y = 360;
					default:
						if (forceCam)
						{
							camFollow.x = opponentCameraOffset[0];
							camFollow.y = opponentCameraOffset[1];
						}
						else
						{
							camFollow.x += opponentCameraOffset[0];
							camFollow.y += opponentCameraOffset[1];
						}
						// fuck you, hard codes your cam positions
				}

				camFollow.x += camNoteX;
				camFollow.y += camNoteY;

				noteCamera(dad, false);
			case "bf":
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (SONG.player1)
				{
					case 'playablegf':
						if (curStage == 'musicroom')
						{							
							camFollow.x = 966;
							camFollow.y = 543;
						}
					case 'sayori' | 'natsuki' | 'yuri' | 'yuri-crazy':
					// they don't get cam adjustment
					case 'monika':
						camFollow.y += 50;
					case 'senpai' | 'senpai-angry' | 'playablesenpai':
						camFollow.x = boyfriend.getMidpoint().x - 500;
						camFollow.y = boyfriend.getMidpoint().y - 430;
					case 'bigmonika' | 'bigmonika-dead':
						camFollow.x = 600;
						camFollow.y = 300;
					default:
						switch (curStage)
						{
							case 'school':
								switch (curSong.toLowerCase())
								{
									case "bara no yume":
										camFollow.x = boyfriend.getMidpoint().x - 500;
										camFollow.y = boyfriend.getMidpoint().y - 300;
									default:
										camFollow.x = boyfriend.getMidpoint().x - 400;
										camFollow.y = boyfriend.getMidpoint().y - 300;
								}
							case 'schoolEvilEX':
								if (stageVER == 1)
								{
									camFollow.x = 814;
									camFollow.y = 664;
								}
								else
								{
									camFollow.x = 765;
									camFollow.y = 592;
								}
							case 'dokiclubroom' | 'dokifestival' | 'credits':
								camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'dokiglitcher':
								if (boyfriend.curCharacter == 'bf-pixel' || boyfriend.curCharacter == 'pixelbf-new') // pixelbf-new
								{
									camFollow.x = boyfriend.getMidpoint().x - 400;
									camFollow.y = boyfriend.getMidpoint().y - 300;
								}
								else camFollow.y = boyfriend.getMidpoint().y - 200;
							case 'clubroomevil' | 'libitina':
								camFollow.x = 600;
								camFollow.y = 300;
							case 'wilted':
								camFollow.x = 730;
								camFollow.y = 360;
						}
				}
				switch (curStage)
				{
					case 'wilted':
						camFollow.x = 720;
						camFollow.y = 360;
					default:
						if (forceCam)
						{
							camFollow.x = boyfriendCameraOffset[0];
							camFollow.y = boyfriendCameraOffset[1];
						}
						else
						{
							camFollow.x += boyfriendCameraOffset[0];
							camFollow.y += boyfriendCameraOffset[1];
						}
						// fuck you, hard codes your cam positions
				}

				camFollow.x += camNoteX;
				camFollow.y += camNoteY;

				noteCamera(boyfriend, true);
			case "centered":
				switch (curStage)
				{
					case 'schoolEvilEX':
						if (stageVER == 1)
						{
							camFollow.x = 714;
							camFollow.y = 604;
						}
						else
						{
							camFollow.x = 645;
							camFollow.y = 542;
						}
					case 'school':
						camFollow.x = 642;
						camFollow.y = 571;
					case 'dokiclubroom' | 'dokifestival' | 'dokiglitcher':
						switch (defaultCamZoom)
						{
							case 1:
								camFollow.x = 584;
								camFollow.y = 434;
							case 1.05 | 1.1 | 1.15 | 1.2:
								camFollow.x = 664;
								camFollow.y = 434;
							default:
								camFollow.x = 664;
								camFollow.y = 454;
						}
					case 'clubroomevil':
						camFollow.x = 600;
						camFollow.y = 300;
					case 'musicroom':
						camFollow.x = 716;
						camFollow.y = 413;
					default:
						camFollow.x = 640;
						camFollow.y = 360;
						if (forceCam)
						{
							if (centerCameraOffset[0] != 0)
								camFollow.x = centerCameraOffset[0];
							if (centerCameraOffset[1] != 0)
								camFollow.y = centerCameraOffset[1];
						}
						else
						{
							camFollow.x = 640 + centerCameraOffset[0];
							camFollow.y = 360 + centerCameraOffset[1];
						}
				}
		}
	}

	// Thank you Holofunk dev team. Y'all the greatest
	var noteCam:Bool = false;

	public var camNoteX:Float = 0;
	public var camNoteY:Float = 0;

	private function noteCamera(focusedChar:Character, mustHit:Bool)
	{
		if (noteCam)
		{
			var camNoteExtend:Float = 15; // How powerful the camnote stuff is
			if ((focusedChar == boyfriend && mustHit) || (focusedChar == dad && !mustHit))
			{
				camNoteX = 0;
				if (focusedChar.animation.curAnim.name.startsWith('singLEFT'))
					camNoteX -= camNoteExtend;
				if (focusedChar.animation.curAnim.name.startsWith('singRIGHT'))
					camNoteX += camNoteExtend;
				if (focusedChar.animation.curAnim.name.startsWith('idle'))
					camNoteX = 0;

				camNoteY = 0;
				if (focusedChar.animation.curAnim.name.startsWith('singDOWN'))
					camNoteY += camNoteExtend;
				if (focusedChar.animation.curAnim.name.startsWith('singUP'))
					camNoteY -= camNoteExtend;
				if (focusedChar.animation.curAnim.name.startsWith('idle'))
					camNoteY = 0;
			}
		}
	}

	public static var altSection:Bool = false;

	function isAltAnimSection():Bool
	{
		if (SONG.notes[Math.floor(curStep / 16)] != null)
			return SONG.notes[Math.floor(curStep / 16)].altAnim;
		else
			return false;
	}

	function summmonStickies(?fadeOut:Bool, ?startDelayDur:Float = 0.5)
	{
		stickerSprites.alpha = 1;
		for (item in stickerSprites.members)
		{
			if (stickerData.length <= 0)
				trace('We somehow ran out of stickers!');

			var rand:Int = FlxG.random.int(0, stickerData.length - 1);
			var stike:String = stickerData[rand];

			if (stickerData[rand] == null && rand >= stickerData.length)
			{
				rand -= 1;
				stike = stickerData[rand];
			}
				

			if (stike != null)
				trace('This Sticker exists ' + stike);
			else //FIX FOUND
				trace('This Sticker doesnt exists ' + stickerData.length + ' which number' + rand);

			item.loadGraphic(Paths.image('stickies/' + stike, 'preload'));
			stickerData.remove(stike);
			item.scale.set(1, 1);
			FlxTween.tween(item, {"scale.x": 0.85, "scale.y": 0.85}, 0.1, {});
		}
		if (fadeOut)
			FlxTween.tween(stickerSprites, {alpha: 0.001}, 1, {startDelay: startDelayDur});
	}

	function niconicoLights()
	{
		trace("It's happenin!");
		var nicoText:Array<String> = CoolUtil.coolTextFile(Paths.txt("data/nicoText"));

		if (Date.now().getDay() != 5)
			nicoText.push("it's not even friday...");
		// else https://youtu.be/SaNmV7Sx5_M

		var randomText:String = nicoText[FlxG.random.int(0, nicoText.length - 1)];
		trace(randomText);
		var funnyText:FlxText = new FlxText(0, 0, 0, randomText, 50);
		funnyText.scrollFactor.set();
		funnyText.setFormat('CyberpunkWaifus', 50, FlxColor.WHITE);
		funnyText.setPosition(FlxG.width + funnyText.width, FlxG.random.float(0, 650));
		funnyText.antialiasing = false;
		funnTextGroup.add(funnyText);
		FlxTween.tween(funnyText, {x: -funnyText.width / defaultCamZoom}, FlxG.random.float(4, 12), {
			ease: FlxEase.linear, 
			onComplete: function(tween:FlxTween)
			{
				funnTextGroup.remove(funnyText);
			}
		});
	}

	function yuriGoCrazy()
	{
		// yooo she gon da crazyy
		yuriGoneCrazy = true;

		// visual setup
		defaultCamZoom = 1.4;
		camZooming = true;
		camFocus = false;
		blackScreenBG.alpha = 0.8;
		remove(deskfront);

		// character setup
		gf.playAnim('necksnap', true);
		addcharacter("yuri-crazy", 1);
		boyfriend.x = dad.x + 250;

		// vignette + camera setup
		add(vignette);
		vignette.alpha = 0.6;
		camFollow.setPosition((dad.getMidpoint().x + boyfriend.getMidpoint().x) / 1.8, dad.getMidpoint().y - 50);
	}

	function gopixel()
	{
		//camGame.filtersEnabled = false;
		bloomlol.data.funthreshhold.value = [1.0];
		isPixelUI = true;
		defaultCamZoom = 1.05;

		positionDisplay.songText.font = LangUtil.getFont('vcr');
		scoreTxt.font = LangUtil.getFont('vcr');
		judgementCounter.font = LangUtil.getFont('vcr');
		botPlayState.font = LangUtil.getFont('vcr');
		practiceTxt.font = LangUtil.getFont('vcr');

		judgementCounter.screenCenter(Y);
		judgementCounter.y += LangUtil.getFontOffset() + 20;

		Character.isFestival = false;

		addcharacter("gf-pixel", 2);
		addcharacter("monika-pixelnew", 1);
		addcharacter("pixelbf-new", 0);

		positionDisplay.songText.antialiasing = false;
		scoreTxt.antialiasing = false;
		botPlayState.antialiasing = false;
		practiceTxt.antialiasing = false;
		judgementCounter.antialiasing = false;


		bgDokis.visible = false;

		// thank u vs sunday code! (credits to bbpanzu)
		remove(strumLineNotes);
		strumLineNotes = new FlxTypedGroup<StrumNote>();
		strumLineNotes.cameras = [camHUD];
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StrumNote>();
		opponentStrums = new FlxTypedGroup<StrumNote>();

		curStyle = 'pixel';
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
		//camGame.filtersEnabled = true;
		bloomlol.data.funthreshhold.value = [0.8];
		isPixelUI = false;

		positionDisplay.songText.font = LangUtil.getFont();
		scoreTxt.font = LangUtil.getFont();
		judgementCounter.font = LangUtil.getFont();
		botPlayState.font = LangUtil.getFont('riffic');
		practiceTxt.font = LangUtil.getFont('riffic');

		judgementCounter.screenCenter(Y);
		judgementCounter.y += LangUtil.getFontOffset() + 20;

		Character.isFestival = true;

		addcharacter("", 2);
		addcharacter("", 1);
		addcharacter("", 0);

		defaultCamZoom = 0.75;

		bgDokis.visible = true;

		positionDisplay.songText.antialiasing = SaveData.globalAntialiasing;
		scoreTxt.antialiasing = SaveData.globalAntialiasing;
		botPlayState.antialiasing = SaveData.globalAntialiasing;
		practiceTxt.antialiasing = SaveData.globalAntialiasing;
		judgementCounter.antialiasing = SaveData.globalAntialiasing;

		remove(strumLineNotes);
		strumLineNotes = new FlxTypedGroup<StrumNote>();
		strumLineNotes.cameras = [camHUD];
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StrumNote>();
		opponentStrums = new FlxTypedGroup<StrumNote>();

		curStyle = SONG.noteStyle;
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

	function creditsCharSwap(chara:String, ?unhide:Bool)
	{
		var funnycostume:String = 'casual';
		if (unhide)
			dad.visible = true;

		switch (chara)
		{
			case 'sayori'|'natsuki'|'yuri'|'protag':
				p2Box.loadGraphic(Paths.image('credits/window_bottom_' + chara, 'doki'));
			case 'monika' | 'monika-pixelnew':
				p2Box.loadGraphic(Paths.image('credits/window_bottom_monika', 'doki'));
			default:
				p2Box.loadGraphic(Paths.image('credits/window_bottom', 'doki'));
		}

		if (chara == 'monika-pixelnew')
			funnycostume = 'hueh';

		addcharacter(chara, 1, false, funnycostume);
		var boxFlash:FlxSprite = new FlxSprite(p2Box.x, p2Box.y).makeGraphic(745, 864, FlxColor.WHITE);
		boxFlash.alpha = 1;
		boxFlash.cameras = [camGame2];
		insert(members.indexOf(p2Boxtop) - 1, boxFlash);
		FlxTween.tween(boxFlash, {alpha: 0.001}, CoolUtil.calcSectionLength(0.1), {ease: FlxEase.sineOut});
		cursorDDTO.loadGraphic(Paths.image('credits/Arrow', 'doki'));
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			FlxTween.tween(cursorDDTO, {x: cursorDDTO.x - 120, y: cursorDDTO.y - 700}, CoolUtil.calcSectionLength(0.5), {ease: FlxEase.sineInOut});
		});
	}

	function prepareCharSwap()
	{
		cursorDDTO.loadGraphic(Paths.image('credits/Arrow_HOLD', 'doki'));
		cursorDDTO.setPosition(1300, 1080);
		FlxTween.tween(cursorDDTO, {x: 205, y: 415}, CoolUtil.calcSectionLength(0.6), {ease: FlxEase.sineOut});
	}

	function reloadCreditsStickers()
	{
		trace('Reloading Stickers');
		for (i in 0...galleryData.length)
		{
			if (galleryData[i].startsWith('//'))
				continue;
			var data:Array<String> = galleryData[i].split('::');
			stickerData.push(data[0]);
				
		}
	}

	function glitchEffect(?forcenonShader:Bool = false) //Might aswell make it universal
	{
		if (SaveData.shaders && !forcenonShader)
		{
			camGame2.setFilters([new ShaderFilter(staticlol)]);
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				camGame2.setFilters([]);
			});
		}
		else
		{
			FlxTween.cancelTweensOf(redStatic);
			redStatic.alpha = 1;
			FlxTween.tween(redStatic, {alpha: 0.0001}, 0.2, {ease: FlxEase.linear});		
		}
	}

	function wiltswap(swaper:Int, ?skipFlash:Bool = false)
	{
		remove(strumLineNotes);
		strumLineNotes = new FlxTypedGroup<StrumNote>();
		strumLineNotes.cameras = [camHUD];
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StrumNote>();
		opponentStrums = new FlxTypedGroup<StrumNote>();

		if (skipFlash == false)
		{
			whiteflash.alpha = 1;
			FlxTween.tween(whiteflash, {alpha: 0.001}, CoolUtil.calcSectionLength(0.1), {ease: FlxEase.sineOut});
		}
		
		switch (swaper)
		{
			case 0:
				wiltbg.loadGraphic(Paths.image('wilt/bg', 'doki'));
				addcharacter("senpai", 1);
				addcharacter("monika", 0);
				curStyle = mirrormode ? 'pixel' : SONG.noteStyle;
				generateStaticArrows(1, SONG.noteStyle, false);
				generateStaticArrows(0, 'pixel', false);
			case 1:
				wiltbg.loadGraphic(Paths.image('wilt/bg2', 'doki'));
				addcharacter("senpai-nonpixel", 1);
				addcharacter("monika-pixelnew", 0);
				curStyle = mirrormode ? SONG.noteStyle : 'pixel';
				generateStaticArrows(1, 'pixel', false);
				generateStaticArrows(0, SONG.noteStyle, false);
		}
	}

	function glitchySchool(BGswap:Int)
	{
		glitchEffect(true);
		switch (BGswap)
		{
			case 0:
				evilbg.visible = false;
			case 1:
				evilbg.visible = true;
		}
	}

	function evilswap(BGswap:Int)
	{
		switch (BGswap)
		{	
			case 0:
				FlxTween.cancelTweensOf(redStatic);
				redStatic.alpha = 1;
				FlxTween.tween(redStatic, {alpha: 0.0001}, 0.2, {ease: FlxEase.linear, onComplete: function(twn:FlxTween){}});


				stageVER = 0;
				addcharacter("monika-pixelnew", 1);
				addcharacter("", 0);
				defaultCamZoom = 1.05;
				evilbg.visible = true;
				treeLeaves.visible = false;
				stageFront.visible = false;
				bg.visible = false;
				space.visible = false;
				oldspace.visible = false;
			case 1:
				FlxTween.cancelTweensOf(redStatic);
				redStatic.alpha = 1;
				FlxTween.tween(redStatic, {alpha: 0.0001}, 0.2, {ease: FlxEase.linear, onComplete: function(twn:FlxTween){}});

				stageVER = 1;
				addcharacter("monika-angry", 1);
				addcharacter("", 0);
				defaultCamZoom = 0.9;
				evilbg.visible = false;
				treeLeaves.visible = false;
				stageFront.visible = true;
				bg.visible = true;
				space.visible = true;
				oldspace.visible = true;
			case 2:
				treeLeaves.visible = true;
		}
	}

	function oneMore()
	{
		var dadMidPoint:FlxPoint = dad.getGraphicMidpoint();
		var funnyX:Float = dadMidPoint.x - 120;
		var funnyY:Float = dadMidPoint.y - 120;
		var funnyglow:BGSprite = new BGSprite('dumb/glwo', 'shared', funnyX, funnyY, 1, 1);
		funnyglow.alpha = 0.001;
		funnyglow.scale.set(2,2);
		add(funnyglow);
		var ring:BGSprite = new BGSprite('dumb/ring', 'shared', funnyX, funnyY, 1, 1);
		ring.scale.set(2,2);
		add(ring);
		var onemore:BGSprite = new BGSprite('dumb/onemore', 'shared', funnyX, funnyY, 1, 1);
		onemore.alpha = 0.001;
		onemore.scale.set(2, 2);
		add(onemore);
		funnyglow.cameras = [camGame2];
		ring.cameras = [camGame2];
		onemore.cameras = [camGame2];


		FlxTween.tween(funnyglow, {'scale.x': 2.2, 'scale.y': 2.2, alpha: 0.7}, 0.25, {
			ease: FlxEase.circOut,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(funnyglow, {'scale.x': 3, 'scale.y': 3, alpha: 0}, 0.25, {
					ease: FlxEase.circOut,
					onComplete: function(twn:FlxTween)
					{
						funnyglow.destroy();
					}
				});
			}
		});
		FlxTween.tween(ring, {'scale.x': 4, 'scale.y': 4, alpha: 0}, 0.5, {ease: FlxEase.circOut,
			onComplete: function(twn:FlxTween)
			{
				ring.destroy();
			}
		});
		FlxTween.tween(onemore, {'scale.x': 2.2, 'scale.y': 2.2, alpha: 1}, 0.5, {
			ease: FlxEase.circOut,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(onemore, {'scale.x': 3, 'scale.y': 3, alpha: 0}, 0.25, {
					ease: FlxEase.circOut,
					onComplete: function(twn:FlxTween)
					{
						onemore.destroy();
					}
				});
			}
		});
	}

	function sayonara()
	{
		camZooming = false;
		staticshock.visible = true;
		add(vignette);
		FlxTween.tween(FlxG.camera, {zoom: 2}, CoolUtil.calcSectionLength(0.1));
		vignette.alpha = 0.2;
	}

	public function cardSelected(who:String)
	{
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			canPause = true;
			trace(who);
			switch(who)
			{
				case 'yuri':
					if (!toggleBotplay && !practiceModeToggled) SaveData.yamYuri = true;
					addcharacter("yuri", 1);
					generateNotes(SONG.song + '-yuri');
					changeVocalTrack('', '_Yuri');
				case 'natsuki':
					if (!toggleBotplay && !practiceModeToggled) SaveData.yamNatsuki = true;
					addcharacter("natsuki", 1);
					generateNotes(SONG.song + '-natsuki');
					changeVocalTrack('', '_Natsuki');
				case 'sayori':
					if (!toggleBotplay && !practiceModeToggled) SaveData.yamSayori = true;
					addcharacter("sayori", 1);
					generateNotes(SONG.song + '-sayori');
					changeVocalTrack('', '_Sayori');
				case 'monika':
					if (!toggleBotplay && !practiceModeToggled) SaveData.yamMonika = true;
					addcharacter("monika", 1);
					generateNotes(SONG.song + '-monika');
					changeVocalTrack('', '_Monika');
				default:
					if (!toggleBotplay && !practiceModeToggled) SaveData.yamLoss = true;
					killPlayer(1);
			}
			SaveData.save();
			FlxTween.tween(iconP2, {alpha: 1}, 1, {ease: FlxEase.linear});
		});
	}

	function blackBars(inorout:Bool)
	{
		if (inorout)
		{
			blackbarTop.alpha = 1;
			blackbarBottom.alpha = 1;

			FlxTween.tween(blackbarBottom, {y: 628}, 1.2, {ease: FlxEase.sineOut});
			FlxTween.tween(blackbarTop, {y: 0}, 1.2, {ease: FlxEase.sineOut});
		}
		else
		{
			FlxTween.tween(blackbarBottom, {y: 822}, 1.2, {ease: FlxEase.sineIn});
			FlxTween.tween(blackbarTop, {y: -102}, 1.2, {ease: FlxEase.sineIn});

			new FlxTimer().start(1.2, function(tmr:FlxTimer)
			{
				blackbarTop.alpha = 0.001;
				blackbarBottom.alpha = 0.001;
			});
		}
	}

	function bringInThingie()
	{
		trace('plz wok for me <3');
		if (middleScroll)
			waitin.screenCenter(X);

		waitin.alpha = 1;
		FlxTween.tween(waitin, {y: 367}, 1.2, {
			ease: FlxEase.quadOut,
			onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(waitin, {y: 981}, 1.2, {ease: FlxEase.quadIn, startDelay: 3});
			}
		});
	}

	function pauseState(canGitaroo:Bool = true)
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		if (FlxG.random.bool(0.5) && canGitaroo)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxTransitionableState.skipNextTransIn = true;
			MusicBeatState.switchState(new GitarooPause());
		}
		else
			openSubState(new PauseSubState(forcedPause));
	}
}

/* Hi :)
Wc    ckkkkkkkkkc     ,xkkkkkkkxkxxkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkx; 
Wc   ,dkkkkkkkkk:     .:xkkkkkkkdcokkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkc.
Wc   :kkkkkkkkkl.  ..   :xkkkkkko,ckkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkx;
Wc   'dkkkkkkkkc. 'kx'   :xkkkkkd'.lkkkkkkkkkkkkkkkkxxkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkx;
Wk.   :kkkkkkkx:  ;0Xk,   ,okkkkxc..lxkkkkkkkkkkkkxx:,lxkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkx;
MWl   ckkkkkkkl.  ;0XX0o.  .lxkkkd;..lkkkkkkkkkkkkkx, .:xkkkkkkkkkkkkkkkkkkkkkkkkkkdldkkkkkkkkkkkkx;
MMK;  'okkkkkkc.  ;0XXXXx,   'lxkkx;..:dkkkkkkkkkkkx,   'lxkkkkkkkkkkkkkkkkkkkkkkkd,.ckkkkkkkkkkkkx;
MMWk.  ckkkkkkc.  ;0KOOOOOd.   'coxd:..,oxkkkkkkkkkx,     'lxkkkkkkkkkkkkkkkkkkkkkd..ckkkkkkkkkkkkx;
MMMNl  'okkkkkc.  .;'....';.     .'lxl. .;oxkkkkkkkx,       'lxkkkkkkkkkkkkkkkkkkkd..:xkkkkkkkkkkkx;
MMMMK;  ;xkkkkc.   .        .'.     'cc,. .;oxkkkkkx,   cd'   'coxkkkkkkkkkkkkkkkkd. .lkkkkkkkkkkkd'
MMMMWk. .:xkko'  .:.        .kXk;     .':,. .;oxkkkx,   :0Kd,   ..;lxkkkkkkkkkkkkkd. .lkkkkkkkkkkx; 
MMMMMWk.  .cl'  .kd.         ,0MNOo,     ...  .,coxxl.  .dNX0xl'    .,coxkkkkkkkkkd.  ;xkkkkkkkkkx; 
MMMMMMWk.   .   ;KO'         'OMMMMNOo,          .';:.   :0XXXX0dc,.   ...,ccoxxxkxc. .lkkkkkkkkkc. 
MMMMMMWk.       .'cd;       .kWMMMMMMMNOd'               .dXKxl;'''.         ....;c;.  :xkkkkkkkx;  
MMMMMWk.     ,do;. ..       .,;lxxkXMMMMMx. 'c;,,.        .:,.,;'         ..           .;dkkkkkkc. .
MMMMWk.     :0NXX0kl;;;;;;;;;;;;,. ,okXNKc .;lox0Oxxxl;;;,. .dNK;         .lOOko:;.      .cdkkko'  ;
MMMMK;     :0XXXXXXXKKKKKKKKKKKXKOd:. .'..,;;;'..l0KXXXXN0,.oNNo.          oWMMMMWKko:;.   .;cd;  .o
MMMXc     'kNXXXXXXXXXKKKKKXXXXXXXXXd. .:kKKKKOo..,dXXXXX0;.;xOo.         ,OXXWMMMMMMMWKkl;.  .  .cx
MMXc     .oXNXXXXXXXXXXXXXXXXXXXXXXNk. .xKK0000Kxdk0XXXXXXOo;',,.          ...:oOXWMMMMMMMNO;    ;xk
MXc      :0XXXXXXXXXXXXXXXKKXXXXXXXX0l. .lkk0KXXXXXXXXXXXXXNX0OOxlcccccccccc:,....:oOWMMMMMK:   ,dkk
Xc      .xNXXXXXXXXXXXXXXXd:dOKXXXXXXXko;',,:dOXXXXXXXXXXXXXXXXXXXNXKKKKKKKKK0OOo,. .;clccl,   ,dxkk
:  .;.  .xNXXXXXXXXXXXXXXXKd;.,:cdkOKXXNX00000KXXXXXXXXXXXXXXXXXXXXXXXKKKOOKKXKXXKOo,......   ,dkkkk
  .:o'  .xNXXXXXXXXXXXXXXXXXKxl,.'..,:;cdkkkk0XXXXXXXXXXXXXXXXXXKOkkko:;;;dXXXXXXXXXK0KKKk,  .okkkkk
 .:xd'  .xNXXXXXXXXXXXXXXXXXXXXKKk'          .,;;;;;;;;;;;;;;;;;'.   ..';xKXXXXXXXXXXXXXO;  .cxkkkkk
 ;xkd;  .lKXXXXXXXXXXXXXXXXXXXXXXO'        ..........      .''''';looxKKXXXXXXXXXXXXXXXO;  .cxkkkkkk
.oxxko.  .xNXXXXXXXXXXXXXXXXXXXXXKx,     .';:;;;;;;'.   .cx0XXKXXXXXXXXXXXXXXXXXXXXXXX0;  ,dkkklcxkk
oxkxkd;  .lKXXXXXXXXXXXXXXXXXXXXXXXKkl;.         .,,,cdx0XXXXXXXXXXXXXXXXXXXXXXXXXXXKx,  ,dkkkd:cxkk
kkxxxkd;  .lKXXXXXXXXXXXXXXXXXXXXXXXXXX0kxxxxxxxxOXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXKo.  ,dkkkk:;dkkk
xxkxookd;  .lKXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXKd.  ,dkkkkd,,dkkk
kxxl;lkkd;  .l0XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXKd.  ,dkkkkkc.'dkkk
kxl;lkkxkd;   ,OXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXKd.  ,dkkkkkd,.:xkkk
xl'ckkkkxo;    .o0XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXd.  'dkkkkkx: 'dkkkk
l.,dkxkxl.       .l0XXXXXXXXKKXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXd.  'dkkkkkkl. ,dkkkk
'.lkxxkd'   .'.    .:ok0XX0o',lOXXXXXXXXKOkk0XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX0l. .,dkkkkkkd' .okkkkk
 ;xxdll,               .::. .  ,xKXXXXNO:. ..;o0XXXXXXXXXXXXXXXXXXXXXXXXX0ko:.  .cxkkkkkkx:  ,dkkkkk
.;;'.      .............. .cOx. .lxOKKx,   ..  .;ok0XXXXXXOxxxxxOKXXX0ko:.     .cxkkkkkkx:. ,dkkkkkk
     ..,;;:odddddddolcccc;lOXNk.   .''. ;oxO0l.....;c:;;;,.     .,;;;.        .oxkkkkkkx:. .okkkkkkk
.,::ldddxxxxxdxxxdxdlc;;xkxoodxl.      cXNxcdxocccccc;.     ........          'ldkkkkkx:. .cxkkkkkkk
ddxxxxxxxxddxxxxxdxdol;dNWW0l:llc'   .lXNklclldkOkkdlc.    'lddddddl;',,,,'.    'okkkko.  ;dkkkkkkkk
*/
