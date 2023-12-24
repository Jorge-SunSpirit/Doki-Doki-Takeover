package;

/// Code created by Rozebud for FPS Plus (thanks rozebud)
// modified by KadeDev for use in Kade Engine/Tricky
import flixel.util.FlxAxes;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class KeyBindSubstate extends MusicBeatSubstate
{
	var keyTextDisplay:FlxText;
	var keyWarning:FlxText;
	var warningTween:FlxTween;
	var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
	var defaultKeys:Array<String> = ["A", "S", "W", "D", "R"];
	var curSelected:Int = 0;

	var keys:Array<String> = [
		SaveData.leftBind,
		SaveData.downBind,
		SaveData.upBind,
		SaveData.rightBind
	];

	var tempKey:String = "";
	var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "TAB"];

	var blackBox:FlxSprite;
	var infoText:FlxText;

	var state:String = "select";

	var acceptInput:Bool = false;

	override function create()
	{
		for (i in 0...keys.length)
		{
			var k = keys[i];
			if (k == null)
				keys[i] = defaultKeys[i];
		}

		persistentUpdate = persistentDraw = true;

		keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat(LangUtil.getFont('riffic'), 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFF7CFF);
		keyTextDisplay.y += LangUtil.getFontOffset('riffic');
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 3;
		keyTextDisplay.antialiasing = SaveData.globalAntialiasing;

		blackBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackBox);

		infoText = new FlxText(-10, 580, 1280, 'Just Monika.', 72);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat(LangUtil.getFont('riffic'), 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, 0xFFFF7CFF);
		infoText.y += LangUtil.getFontOffset('riffic');
		infoText.borderSize = 2;
		infoText.borderQuality = 3;
		infoText.alpha = 0;
		infoText.screenCenter(FlxAxes.X);
		infoText.antialiasing = SaveData.globalAntialiasing;
		add(infoText);
		add(keyTextDisplay);

		blackBox.alpha = 0;
		keyTextDisplay.alpha = 0;

		FlxTween.tween(keyTextDisplay, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0.7}, 1, {
			ease: FlxEase.expoInOut,
			onComplete: function(flx:FlxTween)
			{
				acceptInput = true;
			}
		});

		OptionsState.instance.acceptInput = false;

		textUpdate();

		super.create();
	}

	override function update(elapsed:Float)
	{
		infoText.text = '${LangUtil.getString('descKeyBindControls', 'option')}\n${lastKey != '' ? LangUtil.getString('descKeyBindBlacklist', 'option', lastKey) : ''}';

		if (acceptInput)
		{
			switch (state)
			{
				case "select":
					if (FlxG.keys.justPressed.UP)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(-1);
					}

					if (FlxG.keys.justPressed.DOWN)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(1);
					}

					if (FlxG.keys.justPressed.ENTER)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						state = "input";
					}
					else if (FlxG.keys.justPressed.ESCAPE)
					{
						quit();
					}
					else if (FlxG.keys.justPressed.BACKSPACE)
					{
						reset();
					}

				case "input":
					tempKey = keys[curSelected];

					keys[curSelected] = "?";
					textUpdate();

					state = "waiting";

				case "waiting":
					if (FlxG.keys.justPressed.ESCAPE)
					{
						keys[curSelected] = tempKey;
						state = "select";
						FlxG.sound.play(Paths.sound('confirmMenu'));
					}
					else if (FlxG.keys.justPressed.ENTER)
					{
						addKey(defaultKeys[curSelected]);
						save();
						state = "select";
					}
					else if (FlxG.keys.justPressed.ANY)
					{
						addKey(FlxG.keys.getIsDown()[0].ID.toString());
						save();
						state = "select";
					}

				case "exiting":

				default:
					state = "select";
			}

			if (FlxG.keys.justPressed.ANY)
				textUpdate();
		}

		super.update(elapsed);
	}

	function textUpdate()
	{
		keyTextDisplay.text = "\n\n";

		for (i in 0...4)
		{
			var textStart = (i == curSelected) ? "> " : "  ";
			keyTextDisplay.text += textStart + keyText[i] + ": " + ((keys[i] != keyText[i]) ? (keys[i] + " / ") : "") + keyText[i] + " ARROW\n";
		}

		keyTextDisplay.screenCenter();
	}

	function save()
	{
		SaveData.upBind = keys[2];
		SaveData.downBind = keys[1];
		SaveData.leftBind = keys[0];
		SaveData.rightBind = keys[3];

		SaveData.save();

		PlayerSettings.player1.controls.loadKeyBinds();
	}

	function reset()
	{
		for (i in 0...5)
		{
			keys[i] = defaultKeys[i];
		}
		quit();
	}

	function quit()
	{
		state = "exiting";

		save();

		FlxTween.tween(keyTextDisplay, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0}, 1.1, {
			ease: FlxEase.expoInOut,
			onComplete: function(flx:FlxTween)
			{
				OptionsState.instance.acceptInput = true;
				close();
			}
		});
		FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
	}

	public var lastKey:String = "";

	function addKey(r:String)
	{
		var shouldReturn:Bool = true;

		var notAllowed:Array<String> = [];
		var swapKey:Int = -1;

		for (x in blacklist)
		{
			notAllowed.push(x);
		}

		for (x in 0...keys.length)
		{
			var oK = keys[x];
			if (oK == r)
			{
				swapKey = x;
				keys[x] = null;
			}
			if (notAllowed.contains(oK))
			{
				keys[x] = null;
				lastKey = oK;
				return;
			}
		}

		if (notAllowed.contains(r))
		{
			keys[curSelected] = tempKey;
			lastKey = r;
			return;
		}

		lastKey = "";

		if (shouldReturn)
		{
			// Swap keys instead of setting the other one as null
			if (swapKey != -1)
			{
				keys[swapKey] = tempKey;
			}
			keys[curSelected] = r;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		else
		{
			keys[curSelected] = tempKey;
			lastKey = r;
		}
	}

	function changeItem(_amount:Int = 0)
	{
		curSelected += _amount;

		if (curSelected > 3)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 3;
	}
}
