package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import sys.FileSystem;

/**
	*DEBUG MODE
 */
using StringTools;

class AnimationDebugState extends MusicBeatState
{
	var _file:FileReference;
	var dad:Character;
	var char:Character;
	var dadRef:Character;
	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var daAnim:String = 'bf';
	var camFollow:FlxObject;
	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	public static var costumeoverride:String = '';

	public static var inGame:Bool = true;

	public static var isPlayer:Bool = false;

	var background:FlxSprite;
	var curt:FlxSprite;
	var front:FlxSprite;

	var multiplier:Float = 1.0;
	var tabSwitch:Bool = false;
	var facingright:Bool = true;

	var UI_box:FlxUITabMenu;
	var offsetX:FlxUINumericStepper;
	var offsetY:FlxUINumericStepper;

	var characters:Array<String> = [];

	public function new(daAnim:String = 'bf')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		FlxG.sound.music.stop();

		FlxG.camera.bgColor = FlxColor.BLACK;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		if (costumeoverride == '' && inGame == false)
			Character.loadaltcostume = false;
		else if (inGame == true)
			Character.loadaltcostume = true;

		Character.debugMode = true;

		background = new FlxSprite(-600, -375).loadGraphic(Paths.image('stageback', 'preload'));
		front = new FlxSprite(-650, 325).loadGraphic(Paths.image('stagefront', 'preload'));
		curt = new FlxSprite(-500, -625).loadGraphic(Paths.image('stagecurtains', 'preload'));
		background.antialiasing = SaveData.globalAntialiasing;
		front.antialiasing = SaveData.globalAntialiasing;
		curt.antialiasing = SaveData.globalAntialiasing;

		background.screenCenter(X);
		background.scale.set(0.7, 0.7);
		front.screenCenter(X);
		front.scale.set(0.7, 0.7);
		curt.screenCenter(X);
		curt.scale.set(0.7, 0.7);

		background.scrollFactor.set(0.9, 0.9);
		curt.scrollFactor.set(0.9, 0.9);
		front.scrollFactor.set(0.9, 0.9);

		add(background);
		add(front);
		add(curt);

		Character.isFestival = false;
		dad = new Character(0, 0, daAnim);
		dad.screenCenter();

		dadRef = new Character(0, 0, daAnim);
		dadRef.screenCenter();
		dadRef.alpha = 0.25;

		add(dadRef);
		add(dad);

		char = dad;

		dumbTexts = new FlxTypedGroup<FlxText>();
		dumbTexts.cameras = [camHUD];
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		textAnim.scrollFactor.set();
		textAnim.cameras = [camHUD];
		add(textAnim);

		genBoyOffsets();

		addHelpText();

		var charDirectory:String = Paths.getPreloadPath('data/characters/');

		if (FileSystem.exists(charDirectory))
		{
			for (file in FileSystem.readDirectory(charDirectory))
			{
				var path = haxe.io.Path.join([charDirectory, file]);

				if (!FileSystem.isDirectory(path) && file.endsWith('.json'))
				{
					var charToCheck:String = file.substr(0, file.length - 5);

					characters.push(charToCheck);
				}
			}
		}

		var tabs = [{name: "Offsets", label: 'Offset menu'},];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.scrollFactor.set();
		UI_box.resize(150, 200);
		UI_box.x = FlxG.width - UI_box.width - 20;
		UI_box.y = 20;
		UI_box.cameras = [camHUD];
		add(UI_box);

		addOffsetUI();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function addOffsetUI(?isPlayer:Bool = false):Void
	{
		var player1DropDown = new FlxUIDropDownMenu(10, 10, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			facingright = true;
			remove(dad);
			remove(dadRef);
			dad = new Character(0, 0, characters[Std.parseInt(character)], isPlayer);
			dad.screenCenter();

			dadRef = new Character(0, 0, characters[Std.parseInt(character)], isPlayer);
			dadRef.screenCenter();
			dadRef.alpha = 0.25;
			add(dadRef);
			add(dad);

			replace(char, dad);
			replace(char, dadRef);
			char = dad;

			dumbTexts.clear();
			genBoyOffsets(true, true);
			updateTexts();

			daAnim = characters[Std.parseInt(character)];
		});

		player1DropDown.selectedLabel = char.curCharacter;

		var offsetX_label = new FlxText(10, 50, 'X Offset');

		var UI_offsetX:FlxUINumericStepper = new FlxUINumericStepper(10, offsetX_label.y + offsetX_label.height + 10, 1,
			char.animOffsets.get(animList[curAnim])[0], -500.0, 500.0, 0);
		UI_offsetX.value = char.animOffsets.get(animList[curAnim])[0];
		UI_offsetX.name = 'offset_x';
		offsetX = UI_offsetX;

		var offsetY_label = new FlxText(10, UI_offsetX.y + UI_offsetX.height + 10, 'Y Offset');

		var UI_offsetY:FlxUINumericStepper = new FlxUINumericStepper(10, offsetY_label.y + offsetY_label.height + 10, 1,
			char.animOffsets.get(animList[curAnim])[0], -500.0, 500.0, 0);
		UI_offsetY.value = char.animOffsets.get(animList[curAnim])[1];
		UI_offsetY.name = 'offset_y';
		offsetY = UI_offsetY;

		var tab_group_offsets = new FlxUI(null, UI_box);
		tab_group_offsets.name = "Offsets";

		tab_group_offsets.add(offsetX_label);
		tab_group_offsets.add(offsetY_label);
		tab_group_offsets.add(UI_offsetX);
		tab_group_offsets.add(UI_offsetY);
		tab_group_offsets.add(player1DropDown);

		UI_box.addGroup(tab_group_offsets);
	}

	function genBoyOffsets(pushList:Bool = true, ?cleanArray:Bool = false):Void
	{
		if (cleanArray)
			animList.splice(0, animList.length);

		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			text.color = FlxColor.WHITE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function saveBoyOffsets():Void
	{
		var result = "";

		for (anim => offsets in char.animOffsets)
		{
			var text = anim + " " + offsets.join(" ");
			result += text + "\n";
		}

		if ((result != null) && (result.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			if (Character.loadaltcostume)
				switch (daAnim)
				{
					case 'bf-doki':
						if (SaveData.bfcostume == '')
							_file.save(result.trim(), daAnim + "Offsets.txt");
						else
							_file.save(result.trim(), daAnim + "-" + SaveData.bfcostume + "Offsets.txt");

					case 'gf-realdoki':
						if (SaveData.gfcostume == '')
							_file.save(result.trim(), daAnim + "Offsets.txt");
						else
							_file.save(result.trim(), daAnim + "-" + SaveData.gfcostume + "Offsets.txt");

					case 'monika':
						if (SaveData.monikacostume == '')
							_file.save(result.trim(), daAnim + "Offsets.txt");
						else
							_file.save(result.trim(), daAnim + "-" + SaveData.monikacostume + "Offsets.txt");

					case 'sayori':
						if (SaveData.sayoricostume == '')
							_file.save(result.trim(), daAnim + "Offsets.txt");
						else
							_file.save(result.trim(), daAnim + "-" + SaveData.sayoricostume + "Offsets.txt");

					case 'natsuki':
						if (SaveData.natsukicostume == '')
							_file.save(result.trim(), daAnim + "Offsets.txt");
						else
							_file.save(result.trim(), daAnim + "-" + SaveData.natsukicostume + "Offsets.txt");

					case 'yuri' | 'yuri-crazy':
						if (SaveData.yuricostume == '')
							_file.save(result.trim(), daAnim + "Offsets.txt");
						else
							_file.save(result.trim(), daAnim + "-" + SaveData.yuricostume + "Offsets.txt");

					case 'protag':
						if (SaveData.protagcostume == '')
							_file.save(result.trim(), daAnim + "Offsets.txt");
						else
							_file.save(result.trim(), daAnim + "-" + SaveData.protagcostume + "Offsets.txt");

					default:
						_file.save(result.trim(), daAnim + "Offsets.txt");
				}
			else
				_file.save(result.trim(), daAnim + "Offsets.txt");
		}
	}

	/**
	 * Called when the save file dialog is completed.
	 */
	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved OFFSET DATA.");
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
	 * Called if there is an error while saving the offset data.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Offset data");
	}

	function updateTexts():Void
	{
		offsetX.value = char.animOffsets.get(animList[curAnim])[0];
		offsetY.value = char.animOffsets.get(animList[curAnim])[1];

		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	var helpText:FlxText;

	function addHelpText():Void
	{
		var helpTextValue = "\n\nHelp:\nQ/E : Zoom in and out"
			+ '\nI/J/K/L : Pan camera (hold shift for x2 speed)' + "\nW/S : Cycle Animation" + "\nArrows : Offset Animation"
			+ "\nShift-Arrows : Offset Animation x10" + "\nSpace : Replay Animation" + "\nCTRL-S : Save Offsets to File" + "\nESC : Exit"
			+ "\nPress F1 to hide/show this!"
			+ "\nPress F to flip the character (used for playable characters)";
		helpText = new FlxText(850, 20, 0, helpTextValue, 15);
		helpText.scrollFactor.set();
		helpText.y = FlxG.height - helpText.height - 20;
		helpText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		helpText.color = FlxColor.WHITE;
		helpText.cameras = [camHUD];

		add(helpText);
	}

	override function update(elapsed:Float)
	{
		if (char.animation.curAnim != null)
			textAnim.text = char.animation.curAnim.name;

		// Pressing ESC takes you back to previous state
		if (FlxG.keys.justPressed.ESCAPE)
		{
			isPlayer = false;
			Character.debugMode = false;

			if (inGame)
				MusicBeatState.switchState(new PlayState());
			else
				MusicBeatState.switchState(new CostumeSelectState());
		}

		// Camera zooms
		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.justPressed.F)
		{
			facingright = !facingright;
			addOffsetUI(facingright);
		}

		if (FlxG.keys.justPressed.U)
			tabSwitch = !tabSwitch;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (!tabSwitch)
			{
				// Camera positioning and velocity changes
				if (FlxG.keys.pressed.I)
					if (FlxG.keys.pressed.SHIFT)
						camFollow.velocity.y = -180;
					else
						camFollow.velocity.y = -90;
				else if (FlxG.keys.pressed.K)
					if (FlxG.keys.pressed.SHIFT)
						camFollow.velocity.y = 180;
					else
						camFollow.velocity.y = 90;
				else
					camFollow.velocity.y = 0;

				if (FlxG.keys.pressed.J)
					if (FlxG.keys.pressed.SHIFT)
						camFollow.velocity.x = -180;
					else
						camFollow.velocity.x = -90;
				else if (FlxG.keys.pressed.L)
					if (FlxG.keys.pressed.SHIFT)
						camFollow.velocity.x = 180;
					else
						camFollow.velocity.x = 90;
				else
					camFollow.velocity.x = 0;
			}
			else
			{
				// Move dad reference
				// not working rn, but should suffice as a base reference
				/*
					if (FlxG.keys.pressed.I)
						dadRef.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
					if (FlxG.keys.pressed.K)
						dadRef.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
					if (FlxG.keys.pressed.L)
						dadRef.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
					if (FlxG.keys.pressed.J)
						dadRef.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;
				 */
			}
		}
		else
			camFollow.velocity.set();

		// Change animations
		if (FlxG.keys.justPressed.W)
			curAnim -= 1;

		if (FlxG.keys.justPressed.S)
			curAnim += 1;

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		// Play animation after changing animation or pressing SPACEBAR
		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			char.playAnim(animList[curAnim], true);

			updateTexts();
			genBoyOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		if (FlxG.keys.pressed.SHIFT)
			multiplier = 10.0;
		else
			multiplier = 1.0;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP)
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			if (downP)
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			if (leftP)
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			if (rightP)
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;

			updateTexts();
			genBoyOffsets(false);
			char.playAnim(animList[curAnim]);
		}

		// Save offsets in a txt file.
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			saveBoyOffsets();

		if (FlxG.keys.justPressed.F1)
			SaveData.showHelp = !SaveData.showHelp;

		helpText.visible = SaveData.showHelp;

		super.update(elapsed);
	}
}
