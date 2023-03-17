package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class DokiModifierSubState extends MusicBeatSubstate
{
	var modifierData:Array<Array<Dynamic>> = [
		// internal, name, unlock, save, type, default
		['offset', LangUtil.getString('cmnOffset'), true, 'offset', 'float', 0],
		['botplay', LangUtil.getString('cmnBotplay'), true, 'botplay', 'bool', false],
		['mirror', LangUtil.getString('nameMirror', 'option'), SaveData.beatFestival, 'mirrorMode', 'bool', false],
		['ghost', LangUtil.getString('nameGhostTap', 'option'), true, 'ghostTapping', 'bool', true],
		['death', LangUtil.getString('nameSudden', 'option'), true, 'missModeType', 'int', 0],
		['random', LangUtil.getString('nameRandom', 'option'), SaveData.beatFestival, 'randomMode', 'bool', false],
		['scroll', LangUtil.getString('nameScroll', 'option'), true, 'scrollSpeed', 'float', 0.9],
		['down', LangUtil.getString('nameDownscroll', 'option'), true, 'downScroll', 'bool', false],
		['middle', LangUtil.getString('nameMiddleScrollOn', 'option'), true, 'middleScroll', 'bool', false],
		['speed', LangUtil.getString('cmnSpeed'), true, 'songSpeed', 'float', 1],
		['selfAware', LangUtil.getString('nameSelfAware', 'option'), true, 'selfAware', 'bool', true],
		['cool', 'Cool gameplay!!!', true, 'coolGameplay', 'bool', false]
	];

	var curSelected:Int = 0;

	var acceptInput:Bool = false;

	var mouseManager:FlxMouseEventManager = new FlxMouseEventManager();
	var txtGrp:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

	public static var instance:DokiModifierSubState;

	public function new()
	{
		super();

		instance = this;

		DokiFreeplayState.instance.acceptInput = false;

		for (i in modifierData)
		{
			if (!i[2])
			{
				modifierData.remove(i);
				continue;
			}
		}

		var background:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFFF38CC5);
		background.alpha = 0.4;
		add(background);

		var menuBG:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplay/extra/modifiersmenu'));
		menuBG.antialiasing = SaveData.globalAntialiasing;
		add(menuBG);

		for (i in 0...modifierData.length)
		{
			var modText:FlxText = new FlxText(280, 129 + (i * 36), 714, modifierData[i][1], 26);
			modText.setFormat(LangUtil.getFont('grotesk'), 26, 0xFF821F8B, FlxTextAlign.LEFT);
			modText.y += LangUtil.getFontOffset('grotesk');
			modText.antialiasing = SaveData.globalAntialiasing;
			modText.ID = i;
			txtGrp.add(modText);
			mouseManager.add(modText, onMouseDown, null, onMouseOver);
		}

		add(txtGrp);
		add(mouseManager);

		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			acceptInput = true;
		});

		changeSelection();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (acceptInput)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				DokiFreeplayState.instance.acceptInput = true;
				SaveData.save();
				close();
			}

			if (controls.UP_P)
				changeSelection(-1);
			if (controls.DOWN_P)
				changeSelection(1);

			// LEFT, RIGHT
			if (FlxG.keys.pressed.SHIFT ? controls.LEFT : controls.LEFT_P)
				changeModifier(-1);
			if (FlxG.keys.pressed.SHIFT ? controls.RIGHT : controls.RIGHT_P)
				changeModifier(1);

			if (FlxG.keys.justPressed.R)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				setValue(modifierData[curSelected][5]);
				updateText();
			}
		}
	}

	function changeSelection(amt:Int = 0):Void
	{
		var prevSelected:Int = curSelected;
		curSelected += amt;

		if (prevSelected != curSelected)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelected >= modifierData.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = modifierData.length - 1;

		updateText();
	}

	function updateText():Void
	{
		txtGrp.forEach(function(txt:FlxText)
		{
			if (txt.ID == curSelected)
				txt.text = '> ${modifierData[txt.ID][1]}: < ${displayValue(txt.ID)} >';
			else
				txt.text = '${modifierData[txt.ID][1]}: < ${displayValue(txt.ID)} >';
		});
	}

	function changeModifier(amt:Int = 0):Void
	{
		switch (modifierData[curSelected][4])
		{
			case 'bool':
			{
				setValue(!getValue());
			}
			case 'int':
			{
				var min:Int = 0;
				var max:Int = 1;

				switch (modifierData[curSelected][0])
				{
					case 'death':
					{
						max = 2;
					}
				}

				setValue(getValue() + amt);

				if (getValue() > max)
					setValue(min);
				if (getValue() < min)
					setValue(max);
			}
			case 'float':
			{
				var min:Float = 0;
				var max:Float = 1;
				var trueAmt:Float = amt;

				switch (modifierData[curSelected][0])
				{
					case 'offset':
					{
						min = -FlxMath.MAX_VALUE_FLOAT;
						max = FlxMath.MAX_VALUE_FLOAT;
					}
					case 'scroll':
					{
						min = 0.9;
						max = 4;
						trueAmt *= 0.1;
					}
					case 'speed':
					{
						min = 0.5;
						max = 2;
						trueAmt *= 0.05;
					}
				}

				setValue(getValue() + trueAmt);

				if (getValue() < min)
					setValue(min);
				if (getValue() > max)
					setValue(max); 
			}
		}

		if (!FlxG.keys.pressed.SHIFT)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function onMouseOver(txt:FlxText):Void
	{
		if (acceptInput && curSelected != txt.ID)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			curSelected = txt.ID;
			changeSelection();
		}
	}

	function onMouseDown(txt:FlxText):Void
	{
		if (acceptInput && modifierData[curSelected][4] != 'float')
			changeModifier(1);
	}

	function setValue(value:Dynamic)
	{
		if (modifierData[curSelected][4] == 'float')
			value = FlxMath.roundDecimal(value, 2);

		Reflect.setProperty(SaveData, modifierData[curSelected][3], value);
	}

	function getValue(ID:Null<Int> = null):Dynamic
	{
		if (ID == null)
			ID = curSelected;

		return Reflect.getProperty(SaveData, modifierData[ID][3]);
	}

	function displayValue(ID:Int):String
	{
		var value:Dynamic = getValue(ID);
		var display:String = '';

		switch (modifierData[ID][0])
		{
			default:
			{
				if (modifierData[ID][4] == 'bool')
				{
					display = value ? LangUtil.getString('cmnOn') : LangUtil.getString('cmnOff');
				}
				else
				{
					display = value;
				}
			}
			case 'offset':
			{
				display = '${value} ms';
			}
			case 'death':
			{
				switch (value)
				{
					case 0:
					{
						display = LangUtil.getString('cmnOff');
					}
					case 1:
					{
						display = 'FC Only';
					}
					case 2:
					{
						display = 'Sick Only';
					}
				}
			}
			case 'scroll':
			{
				if (value < 1)
				{
					display = LangUtil.getString('nameScrollDefault', 'option');
				}
				else
				{
					display = value;
				}
			}
			case 'speed':
			{
				display = '${value}x';
			}
		}

		return display;
	}
}
