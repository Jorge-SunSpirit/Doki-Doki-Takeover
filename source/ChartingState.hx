package;

import flash.geom.Rectangle;
import openfl.media.SoundChannel;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.io.Bytes;
import lime.utils.Assets;
import lime.media.AudioBuffer;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import sys.FileSystem;

using StringTools;

@:access(flixel.sound.FlxSound._sound)
@:access(openfl.media.Sound.__buffer)

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	var timeOld:Float = 0;

	public static var lastSection:Int = 0;
	public static var lastSong:String = 'ERB';

	var bpmTxt:FlxText;

	var player1DropDown:FlxUIDropDownMenu;
	var player2DropDown:FlxUIDropDownMenu;
	var player3DropDown:FlxUIDropDownMenu;
	var player4DropDown:FlxUIDropDownMenu;
	var gfDropDown:FlxUIDropDownMenu;
	var stageDropDown:FlxUIDropDownMenu;
	var styleDropDown:FlxUIDropDownMenu;
	var diffList:Array<String> = ["-easy", "", "-hard"];
	var diffDropFinal:String = "";
	var bfClick:FlxUICheckBox;
	var opClick:FlxUICheckBox;
	var metronome:FlxUICheckBox;
	var speedTransfer:FlxUICheckBox;
	var gotoSectionStepper:FlxUINumericStepper;

	// var halfSpeedCheck:FlxUICheckBox;
	var strumLine:FlxSprite;
	var curSong:String = 'ERB';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	// Purple, Blue, Green, Red
	// var strumColors:Array<FlxColor> = [0xFFC24B99, 0xFF00FFFF, 0xFF12FA05, 0xFFF9393F];
	var strumColors:Array<FlxColor> = [0xFFB997F9, 0xFF8EEFFF, 0xFFC1FF7F, 0xFFFFA8EF];

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	// var TRIPLE_GRID_SIZE:Float = 40 * 4/3;
	var dummyArrow:FlxSprite;
	var holding:Bool;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;
	var gridBG2:FlxSprite;
	var gridBGTriple:FlxSprite;
	var gridBGOverlay:FlxSprite;
	var waveformSprite:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;
	var songSpeed:Float = 1.0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var leftIconBack:FlxSprite;
	var rightIconBack:FlxSprite;

	var justChanged:Bool;

	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	private var blockPressWhileTypingOnStepper:Array<FlxUINumericStepper> = [];
	private var blockPressWhileScrolling:Array<FlxUIDropDownMenu> = [];

	override function create()
	{
		FlxG.camera.bgColor = FlxColor.BLACK;

		var controlInfo = new FlxText(10, 50, 0,
			"LEFT CLICK - Place/Delete Notes\nCTRL + LEFT CLICK - Select notes\n\n1 - Alt Anim Note\n2 - Note of Markov\n3 - Player 3 Anims\n4 - Player 4 Anims\n5 - All opponents sing together\n6 - Girlfriend Anims\n\nSHIFT - Unlock cursor from grid\nALT - Triplets\nCTRL - 1/32 Notes\nSHIFT + CTRL - 1/64 Notes\n\nTAB - Place notes on both sides\nHJKL - Place notes during\n                       playback\n\nR - Top of section\nSHIFT + R - Song start\n\nENTER - Test chart\nCTRL + ENTER - Test chart from\n                         current section",
			14);
		controlInfo.scrollFactor.set();
		add(controlInfo);

		#if cpp
		controlInfo.text += "\n\nCTRL + A/D - Change song speed\nCTRL + R - Reset speed\n";
		#end

		var credits = new FlxText(1000, 660, 0, "Original chart editor from\nFPS Plus, credit goes to Rozebud", 12);
		credits.scrollFactor.set();
		add(credits);

		var gridBG2Length = 4;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16, true, 0xFFE7E7E7, 0xFFC5C5C5);

		gridBGTriple = FlxGridOverlay.create(GRID_SIZE, Std.int(GRID_SIZE * 4 / 3), GRID_SIZE * 8, GRID_SIZE * 16, true, 0xFFE7E7E7, 0xFFC5C5C5);
		gridBGTriple.visible = false;

		gridBG2 = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16 * gridBG2Length, true, 0xFF515151, 0xFF3D3D3D);

		gridBGOverlay = FlxGridOverlay.create(GRID_SIZE * 4, GRID_SIZE * 4, GRID_SIZE * 8, GRID_SIZE * 16 * gridBG2Length, true, 0xFFFFFFFF, 0xFFB5A5CE);
		gridBGOverlay.blend = "multiply";

		add(gridBG2);
		add(gridBG);
		add(gridBGTriple);
		add(gridBGOverlay);

		waveformSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x00FFFFFF);
		add(waveformSprite);

		leftIcon = new HealthIcon('bf', false, false);
		rightIcon = new HealthIcon('dad', false, false);

		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(Std.int(leftIcon.width / 2));
		rightIcon.setGraphicSize(Std.int(rightIcon.width / 2));

		leftIcon.updateHitbox();
		rightIcon.updateHitbox();

		leftIcon.setPosition(GRID_SIZE + 10, -75);
		rightIcon.setPosition(GRID_SIZE * 5.2, -75);

		leftIconBack = new FlxSprite(leftIcon.x - 2.5, leftIcon.y - 2.5).makeGraphic(75, 75, 0xFF00AAFF);
		rightIconBack = new FlxSprite(rightIcon.x - 2.5, rightIcon.y - 2.5).makeGraphic(75, 75, 0xFF00AAFF);

		add(leftIconBack);
		add(rightIconBack);
		add(leftIcon);
		add(rightIcon);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG2.height), FlxColor.BLACK);
		add(gridBlackLine);

		for (i in 1...gridBG2Length)
		{
			var gridSectionLine:FlxSprite = new FlxSprite(gridBG.x, gridBG.y + (gridBG.height * i)).makeGraphic(Std.int(gridBG2.width), 2, FlxColor.BLACK);
			add(gridSectionLine);
		}

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150.0,
				offset: 0.0,
				numofchar: 2,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				player3: 'bf',
				player4: 'bf',
				gfVersion: 'gf',
				noteStyle: 'normal',
				stage: 'stage',
				speed: 1.0
			};
		}

		for (x in _song.notes)
		{
			if (!x.changeBPM)
				x.bpm = 0;
		}

		// FlxG.save.bind(_song.song.replace(" ", "-"), "Chart Editor Autosaves");

		tempBpm = _song.bpm;

		if (_song.song == lastSong)
			curSection = lastSection;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4, FlxColor.WHITE);
		add(strumLine);

		FlxG.camera.follow(strumLine);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Tools", label: 'Tools'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + 30;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addToolsUI();
		updateHeads();

		add(curRenderedNotes);
		add(curRenderedSustains);

		for (i in 0..._song.notes.length)
		{
			removeDuplicates(i);
		}

		super.create();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		blockPressWhileTypingOn.push(UI_songTitle);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 30, null, null, "Has vocals", 100);
		check_voices.checked = _song.needsVoices;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var saveGenericButton:FlxButton = new FlxButton(110, saveButton.y + 30, "Save Generic", function()
		{
			saveGenericLevel();
		});

		var savePrettyButton:FlxButton = new FlxButton(110, saveGenericButton.y + 30, "Save Pretty", function()
		{
			savePrettyLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var fullreset:FlxButton = new FlxButton(10, 150, "Full Blank", function()
		{
			var song_name = _song.song;

			PlayState.SONG = {
				song: song_name,
				notes: [],
				bpm: 120.0,
				offset: 0.0,
				numofchar: 2,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				player3: 'bf',
				player4: 'bf',
				gfVersion: 'gf',
				noteStyle: 'normal',
				stage: 'stage',
				speed: 1.0
			};

			MusicBeatState.resetState();
		});

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 70, 0.1, 1, 0.1, 25, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		blockPressWhileTypingOnStepper.push(stepperSpeed);

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 50, 1, 1, 1, 1000, 3);
		stepperBPM.value = _song.bpm;
		stepperBPM.name = 'song_bpm';
		blockPressWhileTypingOnStepper.push(stepperBPM);

		var stepperOffset:FlxUINumericStepper = new FlxUINumericStepper(110, 50, 1, 0, -1000, 1000, 2);
		stepperOffset.value = _song.offset;
		stepperOffset.name = 'song_offset';
		blockPressWhileTypingOnStepper.push(stepperOffset);

		var stepperNumofChar:FlxUINumericStepper = new FlxUINumericStepper(10, 220, 1, 2, 2, 4, 2);
		stepperNumofChar.value = _song.numofchar;
		stepperNumofChar.name = 'song_numofchar';
		blockPressWhileTypingOnStepper.push(stepperNumofChar);

		var charDirectory:String = Paths.getPreloadPath('data/characters/');
		var characters:Array<String> = [];

		if (FileSystem.exists(charDirectory))
		{
			for (file in FileSystem.readDirectory(charDirectory))
			{
				var path = haxe.io.Path.join([charDirectory, file]);

				if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
				{
					var charToCheck:String = file.substr(0, file.length - 5);

					if (!charToCheck.endsWith('-dead'))
					{
						characters.push(charToCheck);
					}
				}
			}
		}

		var stageDirectory:String = Paths.getPreloadPath('data/stages/');
		var stages:Array<String> = [];

		if (FileSystem.exists(stageDirectory))
		{
			for (file in FileSystem.readDirectory(stageDirectory))
			{
				var path = haxe.io.Path.join([stageDirectory, file]);

				if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
				{
					stages.push(file.substr(0, file.length - 5));
				}
			}
		}

		var styles:Array<String> = CoolUtil.coolTextFile(Paths.txt("data/noteStyleList"));

		player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player1DropDown.selectedLabel = _song.player1;
		blockPressWhileScrolling.push(player1DropDown);

		player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
			updateHeads();
		});

		player2DropDown.selectedLabel = _song.player2;
		blockPressWhileScrolling.push(player2DropDown);

		player3DropDown = new FlxUIDropDownMenu(10, 130, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player3 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player3DropDown.selectedLabel = _song.player3;
		blockPressWhileScrolling.push(player3DropDown);

		player4DropDown = new FlxUIDropDownMenu(140, 130, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player4 = characters[Std.parseInt(character)];
			updateHeads();
		});

		player4DropDown.selectedLabel = _song.player4;
		blockPressWhileScrolling.push(player4DropDown);

		var diffDrop:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, 190, FlxUIDropDownMenu.makeStrIdLabelArray(["Easy", "Normal", "Hard"], true),
			function(diff:String)
			{
				diffDropFinal = diffList[Std.parseInt(diff)];
				PlayState.storyDifficulty = Std.parseInt(diff);
			});
		diffDropFinal = diffList[PlayState.storyDifficulty];
		blockPressWhileScrolling.push(diffDrop);

		gfDropDown = new FlxUIDropDownMenu(10, 160, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.gfVersion = characters[Std.parseInt(character)];
		});
		gfDropDown.selectedLabel = _song.gfVersion;
		blockPressWhileScrolling.push(gfDropDown);

		stageDropDown = new FlxUIDropDownMenu(140, 160, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(selStage:String)
		{
			_song.stage = stages[Std.parseInt(selStage)];
		});
		stageDropDown.selectedLabel = _song.stage;
		blockPressWhileScrolling.push(stageDropDown);

		styleDropDown = new FlxUIDropDownMenu(140, 190, FlxUIDropDownMenu.makeStrIdLabelArray(styles, true), function(selStyle:String)
		{
			_song.noteStyle = styles[Std.parseInt(selStyle)];
		});
		styleDropDown.selectedLabel = _song.noteStyle;
		blockPressWhileScrolling.push(styleDropDown);

		diffDrop.selectedLabel = CoolUtil.internalDifficultyString(PlayState.storyDifficulty);

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";

		tab_group_song.add(UI_songTitle);
		tab_group_song.add(check_voices);
		tab_group_song.add(saveButton);
		//tab_group_song.add(saveGenericButton);
		//tab_group_song.add(savePrettyButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(new FlxText(stepperOffset.x - 2, stepperOffset.y - 14, 0, 'Offset: (ms)'));
		tab_group_song.add(stepperOffset);
		tab_group_song.add(stepperNumofChar);
		tab_group_song.add(stepperSpeed);
		//tab_group_song.add(diffDrop);
		tab_group_song.add(new FlxText(styleDropDown.x, styleDropDown.y - 12, 0, 'Note Style:'));
		tab_group_song.add(new FlxText(gfDropDown.x, gfDropDown.y - 12, 0, 'Girlfriend:'));
		tab_group_song.add(new FlxText(stageDropDown.x, stageDropDown.y - 12, 0, 'Stage:'));
		tab_group_song.add(new FlxText(player3DropDown.x, player3DropDown.y - 12, 0, 'Player 3:'));
		tab_group_song.add(new FlxText(player4DropDown.x, player4DropDown.y - 12, 0, 'Player 4:'));
		tab_group_song.add(new FlxText(player1DropDown.x, player1DropDown.y - 12, 0, 'Player 1:'));
		tab_group_song.add(new FlxText(player2DropDown.x, player2DropDown.y - 12, 0, 'Player 2:'));
		tab_group_song.add(styleDropDown);
		tab_group_song.add(gfDropDown);
		tab_group_song.add(stageDropDown);
		tab_group_song.add(player3DropDown);
		tab_group_song.add(player4DropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();
	}

	function addToolsUI():Void
	{
		gotoSectionStepper = new FlxUINumericStepper(10, 400, 1, 0, 0, 999, 0);
		gotoSectionStepper.name = 'gotoSection';
		blockPressWhileTypingOnStepper.push(gotoSectionStepper);

		var gotoSectionButton:FlxButton = new FlxButton(gotoSectionStepper.x, gotoSectionStepper.y + 20, "Go to Section", function()
		{
			changeSection(Std.int(gotoSectionStepper.value), true);
			gotoSectionStepper.value = 0;
		});

		var check_mute_inst = new FlxUICheckBox(10, 10, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		bfClick = new FlxUICheckBox(10, 30, null, null, "BF Note Click", 100);
		bfClick.checked = false;

		opClick = new FlxUICheckBox(10, 50, null, null, "Opp Note Click", 100);
		opClick.checked = false;

		metronome = new FlxUICheckBox(10, 70, null, null, "Metronome", 100);
		metronome.checked = false;

		speedTransfer = new FlxUICheckBox(10, 90, null, null, "Transfer Speed to PlayState", 100);
		speedTransfer.checked = false;

		var tab_group_tools = new FlxUI(null, UI_box);
		tab_group_tools.name = "Tools";

		tab_group_tools.add(gotoSectionStepper);
		tab_group_tools.add(gotoSectionButton);
		tab_group_tools.add(check_mute_inst);
		tab_group_tools.add(bfClick);
		tab_group_tools.add(opClick);
		tab_group_tools.add(metronome);
		tab_group_tools.add(speedTransfer);

		UI_box.addGroup(tab_group_tools);
		UI_box.scrollFactor.set();
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_centeredcamera:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;
	var check_milfZoom:FlxUICheckBox;
	var check_noteSwap:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";
		blockPressWhileTypingOnStepper.push(stepperLength);

		stepperSectionBPM = new FlxUINumericStepper(10, 110, 1, Conductor.bpm, 0, 1000, 3);
		stepperSectionBPM.value = _song.notes[0].bpm;
		stepperSectionBPM.name = 'section_bpm';
		blockPressWhileTypingOnStepper.push(stepperSectionBPM);

		check_changeBPM = new FlxUICheckBox(10, 90, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		if (check_changeBPM.checked)
			stepperSectionBPM.value = _song.notes[curSection].bpm;
		else
			stepperSectionBPM.value = Conductor.bpm;

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);
		blockPressWhileTypingOnStepper.push(stepperCopy);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var clearSectionOppButton:FlxButton = new FlxButton(110, 150, "Clear Opp", clearSectionOpp);

		var clearSectionBFButton:FlxButton = new FlxButton(210, 150, "Clear BF", clearSectionBF);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", swapSections);

		var blankButton:FlxButton = new FlxButton(10, 300, "Full Clear", function()
		{
			for (x in 0..._song.notes.length)
			{
				_song.notes[x].sectionNotes = [];
			}

			updateGrid();
		});

		// Flips BF Notes
		var bSideButton:FlxButton = new FlxButton(10, 200, "Flip BF Notes", function()
		{
			var flipTable:Array<Int> = [3, 2, 1, 0, 7, 6, 5, 4];

			// [noteStrum, noteData, noteSus]
			for (x in _song.notes[curSection].sectionNotes)
			{
				if (_song.notes[curSection].mustHitSection)
				{
					if (x[1] < 4)
						x[1] = flipTable[x[1]];
				}
				else
				{
					if (x[1] > 3)
						x[1] = flipTable[x[1]];
				}
			}

			updateGrid();
		});

		// Flips Opponent Notes
		var bSideButton2:FlxButton = new FlxButton(10, 220, "Flip Opp Notes", function()
		{
			var flipTable:Array<Int> = [3, 2, 1, 0, 7, 6, 5, 4];

			// [noteStrum, noteData, noteSus]
			for (x in _song.notes[curSection].sectionNotes)
			{
				if (_song.notes[curSection].mustHitSection)
				{
					if (x[1] > 3)
						x[1] = flipTable[x[1]];
				}
				else
				{
					if (x[1] < 4)
						x[1] = flipTable[x[1]];
				}
			}

			updateGrid();
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Focus Camera on Boyfriend", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = _song.notes[0].mustHitSection;
		// _song.needsVoices = check_mustHit.checked;

		check_centeredcamera = new FlxUICheckBox(10, 60, null, null, "Focus Camera between P1 and P2", 100);
		check_centeredcamera.name = 'check_centercam';
		check_centeredcamera.checked = _song.notes[0].centeredcamera;


		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_milfZoom = new FlxUICheckBox(10, check_altAnim.y + 20, null, null, "M.I.L.F Zoom", 100);
		check_milfZoom.name = 'check_milfZoom';

		check_noteSwap = new FlxUICheckBox(10, check_milfZoom.y + 20, null, null, "Note Texture Swap", 100);
		check_noteSwap.name = 'check_noteSwap';

		// tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_centeredcamera);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_milfZoom);
		tab_group_section.add(check_noteSwap);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(clearSectionOppButton);
		tab_group_section.add(clearSectionBFButton);
		tab_group_section.add(swapSection);
		tab_group_section.add(blankButton);
		tab_group_section.add(bSideButton);
		tab_group_section.add(bSideButton2);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16 * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		blockPressWhileTypingOnStepper.push(stepperSusLength);

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong));

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.play();
		vocals.pause();
		vocals.time = FlxG.sound.music.time;

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};

		updateWaveform();
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);
		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Focus Camera on Boyfriend':
					_song.notes[curSection].mustHitSection = check.checked;
					updateHeads();
					swapSections();
				case 'Focus Camera between P1 and P2':
					_song.notes[curSection].centeredcamera = check.checked;
					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
				case "M.I.L.F Zoom":
					_song.notes[curSection].milfZoom = check.checked;
				case "Note Texture Swap":
					_song.notes[curSection].noteSwap = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = nums.value;
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(nums.value);
			}
			else if (wname == 'song_offset')
			{
				_song.offset = nums.value;
				updateWaveform();
			}
			else if (wname == 'song_numofchar')
			{
				_song.numofchar = nums.value;
			}
			else if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				updateGrid();
				autosaveSong();
			}
			else if (wname == 'section_bpm')
			{
				Conductor.mapBPMChanges(_song);
				_song.notes[curSection].bpm = nums.value;
				updateGrid();
				autosaveSong();
			}
			else if (wname == 'check_changeBPM')
			{
				Conductor.mapBPMChanges(_song);
				_song.notes[curSection].bpm = nums.value;
				updateGrid();
				autosaveSong();
			}
		}
	}

	var updatedSection:Bool = false;

	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var colorSine:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time + _song.offset;
			FlxG.sound.music.pitch = songSpeed;
		}

		if (vocals.playing)
		{
			vocals.volume = (_song.needsVoices ? 1 : 0);
			vocals.pitch = songSpeed;
		}

		_song.song = typingShit.text;

		strumLine.y = getYfromStrum(Conductor.songPosition - sectionStartTime());

		curRenderedNotes.forEachAlive(function(note:Note)
		{
			note.alpha = 1;

			// This is a little buggy since it's being put onto the FPS+ charting state (which doesn't swap based on mustHitSection)
			if (curSelectedNote != null)
			{
				var noteDataToCheck:Int = note.noteData;
				if (noteDataToCheck > -1 && note.mustPress != _song.notes[curSection].mustHitSection)
					noteDataToCheck += 4;

				if (curSelectedNote[0] == note.strumTime
					&& ((curSelectedNote[2] == null && noteDataToCheck < 0)
						|| (curSelectedNote[2] != null && curSelectedNote[1] == noteDataToCheck)))
				{
					colorSine += elapsed;
					var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
					// Alpha can't be 100% or the color won't be updated for some reason
					note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999);
				}
			}
		});

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEachAlive(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
							selectNote(note);
						else
							deleteNote(note);
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					addNote(getStrumTime(dummyArrow.y) + sectionStartTime(), Math.floor(FlxG.mouse.x / GRID_SIZE));
					holding = true;
				}
			}
		}

		if (holding && FlxG.mouse.pressed)
			setNoteSustain((getStrumTime(dummyArrow.y) + sectionStartTime()) - curSelectedNote[0]);
		else
			holding = false;

		if (curSection * 16 != curStep && curStep % 16 == 0 && FlxG.sound.music.playing)
		{
			if (curSection * 16 > curStep)
			{
				changeSection(curSection - 1, false);
			}
			else if (curSection * 16 < curStep)
			{
				changeSection(curSection + 1, false);
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;

			if (FlxG.keys.pressed.CONTROL && FlxG.keys.pressed.SHIFT)
				dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / 4)) * (GRID_SIZE / 4);
			else if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else if (FlxG.keys.pressed.ALT)
				dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE * 4 / 3)) * (GRID_SIZE * 4 / 3);
			else if (FlxG.keys.pressed.CONTROL)
				dummyArrow.y = Math.floor(FlxG.mouse.y / (GRID_SIZE / 2)) * (GRID_SIZE / 2);
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn)
		{
			if (inputText.hasFocus)
			{
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}

		if (!blockInput)
		{
			for (stepper in blockPressWhileTypingOnStepper)
			{
				@:privateAccess
				var leText:Dynamic = stepper.text_field;
				var leText:FlxUIInputText = leText;
				if (leText.hasFocus)
				{
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					FlxG.sound.volumeUpKeys = [];
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
			for (dropDownMenu in blockPressWhileScrolling)
			{
				if (dropDownMenu.dropPanel.visible)
				{
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
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

				lastSection = 0;
				lastSong = 'ERB';

				FlxG.sound.music.stop();
				vocals.stop();
				LoadingState.loadAndSwitchState(new DokiFreeplayState());
			}

			if (FlxG.keys.justPressed.ENTER)
			{
				lastSection = curSection;
				lastSong = _song.song;

				PlayState.SONG = _song;
				PlayState.isStoryMode = false;
				PlayState.chartingMode = true;
				PlayState.practiceMode = true;
				PlayState.sectionStart = false;
				FlxG.sound.music.stop();
				vocals.stop();

				if (speedTransfer.checked)
				{
					Conductor.playbackSpeed = songSpeed;
					if (songSpeed < 0.25)
						Conductor.playbackSpeed = 0.25;
					if (songSpeed > 3)
						Conductor.playbackSpeed = 3;
				}

				if (FlxG.keys.pressed.CONTROL && curSection > 0)
				{
					PlayState.sectionStart = true;
					changeSection(curSection, true);
					PlayState.sectionStartPoint = curSection;
					PlayState.sectionStartTime = FlxG.sound.music.time - (sectionHasBfNotes(curSection) ? Conductor.crochet : 0);
				}

				LoadingState.loadAndSwitchState(new PlayState());
			}

			if (FlxG.keys.justPressed.E)
				changeNoteSustain(Conductor.stepCrochet);

			if (FlxG.keys.justPressed.Q)
				changeNoteSustain(-Conductor.stepCrochet);

			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.CONTROL)
					songSpeed = 1;
				else if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				var wheelSpin = FlxG.mouse.wheel;

				FlxG.sound.music.pause();
				vocals.pause();

				if (wheelSpin > 0 && strumLine.y < gridBG.y)
					wheelSpin = 0;

				if (wheelSpin < 0 && strumLine.y > gridBG2.y + gridBG2.height)
					wheelSpin = 0;

				FlxG.sound.music.time -= (wheelSpin * Conductor.stepCrochet * 0.4);

				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 1000 * FlxG.elapsed;

					if ((FlxG.keys.pressed.W || FlxG.keys.pressed.UP) && strumLine.y > gridBG.y)
					{
						FlxG.sound.music.time -= daTime;
					}
					else if (strumLine.y < gridBG2.y + gridBG2.height)
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 2500 * FlxG.elapsed;

					if ((FlxG.keys.pressed.W || FlxG.keys.pressed.UP) && strumLine.y > gridBG.y)
					{
						FlxG.sound.music.time -= daTime;
					}
					else if (strumLine.y < gridBG2.y + gridBG2.height)
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}

			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (FlxG.keys.justPressed.RIGHT)
				changeSection(curSection + shiftThing);
			if (FlxG.keys.justPressed.LEFT)
				changeSection(curSection - shiftThing);

			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.D)
					songSpeed += 0.1;
				else if (FlxG.keys.justPressed.A)
					songSpeed -= 0.1;

				if (songSpeed > 3)
					songSpeed = 3;
				if (songSpeed <= 0.01)
					songSpeed = 0.1;
			}

			// || FlxG.keys.justPressed.X  || FlxG.keys.justPressed.C || FlxG.keys.justPressed.V
			if (FlxG.sound.music.playing)
			{
				if (FlxG.keys.justPressed.H)
					addNote(getStrumTime(Math.floor((strumLine.y + strumLine.height) / GRID_SIZE) * GRID_SIZE) + sectionStartTime(),
						0 + (_song.notes[curSection].mustHitSection ? 4 : 0));

				if (FlxG.keys.justPressed.J)
					addNote(getStrumTime(Math.floor((strumLine.y + strumLine.height) / GRID_SIZE) * GRID_SIZE) + sectionStartTime(),
						1 + (_song.notes[curSection].mustHitSection ? 4 : 0));

				if (FlxG.keys.justPressed.K)
					addNote(getStrumTime(Math.floor((strumLine.y + strumLine.height) / GRID_SIZE) * GRID_SIZE) + sectionStartTime(),
						2 + (_song.notes[curSection].mustHitSection ? 4 : 0));

				if (FlxG.keys.justPressed.L)
					addNote(getStrumTime(Math.floor((strumLine.y + strumLine.height) / GRID_SIZE) * GRID_SIZE) + sectionStartTime(),
						3 + (_song.notes[curSection].mustHitSection ? 4 : 0));
			}
		}
		else if (FlxG.keys.justPressed.ENTER)
		{
			for (i in 0...blockPressWhileTypingOn.length)
			{
				if (blockPressWhileTypingOn[i].hasFocus)
					blockPressWhileTypingOn[i].hasFocus = false;
			}
		}

		_song.bpm = tempBpm;

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ "\t/"
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nBeat: "
			+ curBeat
			+ "\nStep: "
			+ curStep;

		#if cpp
		bpmTxt.text += "\nSpeed: " + songSpeed + "\n";
		#end

		if ((bfClick.checked || opClick.checked) && !justChanged)
		{
			curRenderedNotes.forEach(function(x:Note)
			{
				if (x.absoluteNumber < 4 && _song.notes[curSection].mustHitSection)
					x.editorBFNote = true;
				else if (x.absoluteNumber > 3 && !_song.notes[curSection].mustHitSection)
					x.editorBFNote = true;

				if (x.y < strumLine.y && !x.playedEditorClick && FlxG.sound.music.playing && x.noteType != 2)
				{
					if (x.editorBFNote && bfClick.checked)
						FlxG.sound.play(Paths.sound("hitsound/charting/bf"), 0.8);
					else if (!x.editorBFNote && opClick.checked)
						FlxG.sound.play(Paths.sound("hitsound/charting/dad"), 0.8);
				}

				if (x.y > strumLine.y && x.alpha != 0.4)
					x.playedEditorClick = false;

				if (x.y < strumLine.y && x.alpha != 0.4)
					x.playedEditorClick = true;
			});
		}

		justChanged = false;

		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function setNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] = value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		justChanged = true;

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			// removeDuplicates(curSection);

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		removeDuplicates(curSection);

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_centeredcamera.checked = sec.centeredcamera;
		check_altAnim.checked = sec.altAnim;
		check_milfZoom.checked = sec.milfZoom;
		check_noteSwap.checked = sec.noteSwap;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		leftIcon.changeIcon(player2DropDown.selectedLabel);
		rightIcon.changeIcon(player1DropDown.selectedLabel);

		if (_song.notes[curSection].mustHitSection)
		{
			leftIconBack.alpha = 0;
			rightIconBack.alpha = 1;
		}
		else
		{
			leftIconBack.alpha = 1;
			rightIconBack.alpha = 0;
		}

		if (_song.notes[curSection].centeredcamera)
		{
			leftIconBack.alpha = 1;
			rightIconBack.alpha = 1;
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		for (i in 0...4)
		{
			if (_song.notes[curSection + i] != null)
				addNotesToRender(curSection, i);
		}

		updateWaveform();
	}

	private function addNotesToRender(curSec:Int, ?secOffset:Int = 0)
	{
		var section:Array<Dynamic> = _song.notes[curSec + secOffset].sectionNotes;
		var noteAdjust:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7];

		if (_song.notes[curSec + secOffset].mustHitSection)
		{
			noteAdjust = [4, 5, 6, 7, 0, 1, 2, 3];
		}

		for (i in section)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var daType = i[3];

			// var note:Note = new Note(daStrumTime, daNoteInfo % 4, true);
			var note:Note = new Note(daStrumTime, daNoteInfo % 4, null, false, daType);
			note.absoluteNumber = daNoteInfo;
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();

			note.x = Math.floor(noteAdjust[daNoteInfo] * GRID_SIZE);

			note.y = (getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
			note.y += GRID_SIZE * 16 * secOffset;

			if (secOffset != 0)
				note.alpha = 0.4;

			/* 			if (curSelectedNote != null)
				{
					if (daStrumTime == curSelectedNote[0] && daNoteInfo == curSelectedNote[1] && daSus == curSelectedNote[2])
					{
						note.glow();
					}
			}*/

			if (note.noteType == 1)
				note.color = 0x828282;
			if (note.noteType == 3)
				note.color = 0x7F0000;
			if (note.noteType == 4)
				note.color = 0x0000FF;
			if (note.noteType == 5)
				note.color = 0x7F00FF;
			if (note.noteType == 6)
				note.color = 0x1DADBB;

			curRenderedNotes.add(note);

			if (daSus > 1)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2) - 4,
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)),
					strumColors[daNoteInfo % 4]);
				if (secOffset != 0)
					sustainVis.alpha = 0.4;
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			centeredcamera: false,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			milfZoom: false,
			noteSwap: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		for (x in _song.notes[curSection].sectionNotes)
		{
			if (approxEqual(x[0], note.strumTime, 3) && x[1] == note.absoluteNumber && approxEqual(x[2], note.sustainLength, 3))
			{
				curSelectedNote = x;
				break;
			}
		}

		// curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (approxEqual(i[0], note.strumTime, 3) && i[1] == note.absoluteNumber)
				_song.notes[curSection].sectionNotes.remove(i);
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSectionBF():Void
	{
		var newSectionNotes:Array<Dynamic> = [];

		if (_song.notes[curSection].mustHitSection)
		{
			for (x in _song.notes[curSection].sectionNotes)
			{
				if (x[1] > 3)
					newSectionNotes.push(x);
			}
		}
		else
		{
			for (x in _song.notes[curSection].sectionNotes)
			{
				if (x[1] < 4)
					newSectionNotes.push(x);
			}
		}

		_song.notes[curSection].sectionNotes = newSectionNotes;

		updateGrid();
	}

	function clearSectionOpp():Void
	{
		var newSectionNotes:Array<Dynamic> = [];

		if (_song.notes[curSection].mustHitSection)
		{
			for (x in _song.notes[curSection].sectionNotes)
			{
				if (x[1] < 4)
					newSectionNotes.push(x);
			}
		}
		else
		{
			for (x in _song.notes[curSection].sectionNotes)
			{
				if (x[1] > 3)
					newSectionNotes.push(x);
			}
		}

		_song.notes[curSection].sectionNotes = newSectionNotes;

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote(_noteStrum:Float, _noteData:Int, ?skipSectionCheck:Bool = false):Void
	{
		var noteAdjust:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7];

		if (_song.notes[curSection].mustHitSection)
		{
			noteAdjust = [4, 5, 6, 7, 0, 1, 2, 3];
		}

		var noteData = noteAdjust[_noteData];
		var noteStrum = _noteStrum;
		var noteSus = 0;
		var noteType = 0;

		if (FlxG.keys.pressed.ONE)
			noteType = 1; // Alt Note
		else if (FlxG.keys.pressed.TWO)
			noteType = 2; // Note of Markov
		else if (FlxG.keys.pressed.THREE)
			noteType = 3; // Player 3 anims
		else if (FlxG.keys.pressed.FOUR)
			noteType = 4; // Player 4 anims
		else if (FlxG.keys.pressed.FIVE)
			noteType = 5; // Everyone sings together
		else if (FlxG.keys.pressed.SIX)
			noteType = 6; // Girlfriend anim

		if (!skipSectionCheck)
		{
			while (noteStrum < sectionStartTime())
			{
				noteStrum++;
			}
		}

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteType]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.TAB)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteType]);
		}

		removeDuplicates(curSection, curSelectedNote);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	var waveformPrinted:Bool = true;
	var wavData:Array<Array<Array<Float>>> = [[[0], [0]], [[0], [0]]];

	// https://github.com/ShadowMario/FNF-PsychEngine/blob/4c4045247c470a2181a3947c565e53965ed2a4fd/source/editors/ChartingState.hx#L2170
	function updateWaveform()
	{
		#if desktop
		if (waveformPrinted)
		{
			waveformSprite.makeGraphic(Std.int(GRID_SIZE * 8), Std.int(gridBG.height), 0x00FFFFFF);
			waveformSprite.pixels.fillRect(new Rectangle(0, 0, gridBG.width, gridBG.height), 0x00FFFFFF);
		}
		waveformPrinted = false;

		wavData[0][0] = [];
		wavData[0][1] = [];
		wavData[1][0] = [];
		wavData[1][1] = [];

		var steps:Int = 16;
		var st:Float = sectionStartTime() + _song.offset;
		var et:Float = st + (Conductor.stepCrochet * steps);

		var sound:FlxSound = vocals;
		if (sound != null && sound._sound != null && sound._sound.__buffer != null)
		{
			var bytes:Bytes = sound._sound.__buffer.data.toBytes();
			wavData = waveformData(sound._sound.__buffer, bytes, st, et, 1, wavData, Std.int(gridBG.height));
		}

		// Draws
		var gSize:Int = Std.int(GRID_SIZE * 8);
		var hSize:Int = Std.int(gSize / 2);

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var size:Float = 1;

		var leftLength:Int = (wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length);

		var rightLength:Int = (wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length);

		var length:Int = leftLength > rightLength ? leftLength : rightLength;

		var index:Int;
		for (i in 0...length)
		{
			index = i;

			lmin = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			lmax = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			rmin = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			rmax = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			waveformSprite.pixels.fillRect(new Rectangle(hSize - (lmin + rmin), i * size, (lmin + rmin) + (lmax + rmax), size), FlxColor.BLUE);
		}

		waveformPrinted = true;
		#end
	}

	function waveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>,
			?steps:Float):Array<Array<Array<Float>>>
	{
		#if (lime_cffi && !macro)
		if (buffer == null || buffer.data == null)
			return [[[0], [0]], [[0], [0]]];

		var khz:Float = (buffer.sampleRate / 1000);
		var channels:Int = buffer.channels;

		var index:Int = Std.int(time * khz);

		var samples:Float = ((endTime - time) * khz);

		if (steps == null)
			steps = 1280;

		var samplesPerRow:Float = samples / steps;
		var samplesPerRowI:Int = Std.int(samplesPerRow);

		var gotIndex:Int = 0;

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var rows:Float = 0;

		var simpleSample:Bool = true; // samples > 17200;
		var v1:Bool = false;

		if (array == null)
			array = [[[0], [0]], [[0], [0]]];

		while (index < (bytes.length - 1))
		{
			if (index >= 0)
			{
				var byte:Int = bytes.getUInt16(index * channels * 2);

				if (byte > 65535 / 2)
					byte -= 65535;

				var sample:Float = (byte / 65535);

				if (sample > 0)
				{
					if (sample > lmax)
						lmax = sample;
				}
				else if (sample < 0)
				{
					if (sample < lmin)
						lmin = sample;
				}

				if (channels >= 2)
				{
					byte = bytes.getUInt16((index * channels * 2) + 2);

					if (byte > 65535 / 2)
						byte -= 65535;

					sample = (byte / 65535);

					if (sample > 0)
					{
						if (sample > rmax)
							rmax = sample;
					}
					else if (sample < 0)
					{
						if (sample < rmin)
							rmin = sample;
					}
				}
			}

			v1 = samplesPerRowI > 0 ? (index % samplesPerRowI == 0) : false;
			while (simpleSample ? v1 : rows >= samplesPerRow)
			{
				v1 = false;
				rows -= samplesPerRow;

				gotIndex++;

				var lRMin:Float = Math.abs(lmin) * multiply;
				var lRMax:Float = lmax * multiply;

				var rRMin:Float = Math.abs(rmin) * multiply;
				var rRMax:Float = rmax * multiply;

				if (gotIndex > array[0][0].length)
					array[0][0].push(lRMin);
				else
					array[0][0][gotIndex - 1] = array[0][0][gotIndex - 1] + lRMin;

				if (gotIndex > array[0][1].length)
					array[0][1].push(lRMax);
				else
					array[0][1][gotIndex - 1] = array[0][1][gotIndex - 1] + lRMax;

				if (channels >= 2)
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(rRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + rRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(rRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + rRMax;
				}
				else
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(lRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + lRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(lRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + lRMax;
				}

				lmin = 0;
				lmax = 0;

				rmin = 0;
				rmax = 0;
			}

			index++;
			rows++;
			if (gotIndex > steps)
				break;
		}

		return array;
		#else
		return [[[0], [0]], [[0], [0]]];
		#end
	}

	private var daSpacing:Float = 0.3;

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		try
		{
			PlayState.SONG = Song.loadFromJson(song.toLowerCase() + diffDropFinal, song.toLowerCase());
		}
		catch (e)
		{
			PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		}

		MusicBeatState.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		MusicBeatState.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		SaveData.save();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + diffDropFinal + ".json");
		}
	}

	private function savePrettyLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + diffDropFinal + ".json");
		}
	}

	private function saveGenericLevel()
	{
		var genericSong = {
			song: _song.song,
			notes: _song.notes,
			bpm: _song.bpm,
			numofchar: _song.numofchar,
			needsVoices: _song.needsVoices,
			speed: _song.speed,
			player1: _song.player1,
			player2: _song.player2,
			player3: _song.player3,
			player4: _song.player4
		};

		var json = {
			"song": genericSong
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + diffDropFinal + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	function swapSections()
	{
		for (i in 0..._song.notes[curSection].sectionNotes.length)
		{
			var note = _song.notes[curSection].sectionNotes[i];
			note[1] = (note[1] + 4) % 8;
			_song.notes[curSection].sectionNotes[i] = note;
			updateGrid();
		}
	}

	function sectionHasBfNotes(section:Int):Bool
	{
		var notes = _song.notes[section].sectionNotes;
		var mustHit = _song.notes[section].mustHitSection;

		for (x in notes)
		{
			if (mustHit)
			{
				if (x[1] < 4)
				{
					return true;
				}
			}
			else
			{
				if (x[1] > 3)
				{
					return true;
				}
			}
		}

		return false;
	}

	function removeDuplicates(section:Int, ?forceNote:Array<Dynamic> = null)
	{
		var newNotes:Array<Dynamic> = [];

		if (forceNote != null)
		{
			newNotes.push(forceNote);
		}

		for (x in _song.notes[section].sectionNotes)
		{
			var add = true;

			for (y in newNotes)
			{
				if (newNotes.length > 0)
				{
					if (approxEqual(x[0], y[0], 6) && x[1] == y[1])
					{
						add = false;
					}
				}
			}

			if (add)
				newNotes.push(x);
		}

		_song.notes[section].sectionNotes = newNotes;
	}

	function approxEqual(x:Dynamic, y:Dynamic, tolerance:Float)
	{
		return x <= y + tolerance && x >= y - tolerance;
	}

	override function beatHit()
	{
		super.beatHit();

		if (FlxG.sound.music.playing && curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			if (_song.notes[curSection + 1] == null)
				addSection();

			changeSection(curSection + 1, false);
		}

		if (FlxG.sound.music.playing && metronome.checked)
		{
			if (curBeat % 4 == 0)
				FlxG.sound.play(Paths.sound('metronomeBar'), 0.8);
			else
				FlxG.sound.play(Paths.sound('metronomeBeat'), 0.8);
		}
	}
}
