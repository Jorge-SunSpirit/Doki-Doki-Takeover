import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class KeyBinds
{
	public static var gamepad:Bool = false;

	public static function resetBinds():Void
	{
		SaveData.upBind = "W";
		SaveData.downBind = "S";
		SaveData.leftBind = "A";
		SaveData.rightBind = "D";
		SaveData.killBind = "R";
		PlayerSettings.player1.controls.loadKeyBinds();
	}

	public static function keyCheck():Void
	{
		if (SaveData.upBind == null)
			SaveData.upBind = "W";

		if (SaveData.downBind == null)
			SaveData.downBind = "S";

		if (SaveData.leftBind == null)
			SaveData.leftBind = "A";

		if (SaveData.rightBind == null)
			SaveData.rightBind = "D";


		if (SaveData.killBind == null)
			SaveData.killBind = "R";
	}
}
