/*
	REQUIREMENTS:

	I will be editing the API for this, meaning you have to download a git:
	haxelib git tentools https://github.com/TentaRJ/tentools.git
	UPDATED SEPT.6.2021

	You need to download and rebuild SysTools, I think you only need it for Windows but just get it *just in case*:
	haxelib git systools https://github.com/haya3218/systools
	haxelib run lime rebuild systools [windows, mac, linux]

	SETUP:
	To add your game's keys, you will need to make a file in the source folder named GJKeys.hx (filepath: ../source/GJKeys.hx)

	In this file, you will need to add the GJKeys class with two public static variables, id:Int and key:String

	Example:

	package;
	class GJKeys
	{
	public static var id:Int = 	0; // Put your game's ID here
	public static var key:String = ""; // Put your game's private API key here
	}

	You can find your game's API key and ID code within the game page's settngs under the game API tab.

	Hope this helps! -tenta

	USAGE:
	To start up the API, the two commands you want to use will be:
	GameJoltAPI.connect();
	GameJoltAPI.authDaUser(SaveData.gjUser, SaveData.gjToken);
	*You can't use the API until this step is done!*

	SaveData.gjUser & gjToken are the save values for the username and token, used for logging in once someone already logs in.
	Save values (gjUser & gjToken) are deleted when the player signs out with GameJoltAPI.deAuthDaUser(); and are replaced with "".

	To open up the login menu, switch the state to GameJoltLogin.
	Exiting the login menu will throw you back to Main Menu State. You can change this in the GameJoltLogin class.

	The session will automatically start on login and will be pinged every 30 seconds.
	If it isn't pinged within 120 seconds, the session automatically ends from Game Jolt's side.
	Thanks Game Jolt, makes my life much easier! Not sarcasm!

	You can give a trophy by using:
	GameJoltAPI.getTrophy(trophyID);
	Each trophy has an ID attached to it. Use that to give a trophy. It could be used for something like a week clear...

	Hope this helps! -tenta

	And yes, I run Mac. A fate worse than death.
 */

#if FEATURE_GAMEJOLT
import flixel.addons.display.FlxBackdrop;
import flixel.tile.FlxTile;
import haxe.ds.ReadOnlyArray;
import tentools.api.FlxGameJolt as GJApi;
import openfl.display.BitmapData;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import lime.system.System;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import shaders.ColorMaskShader;

#if FEATURE_FILESYSTEM
import Sys;
#end

class GameJoltAPI // Connects to tentools.api.FlxGameJolt
{
	static var userLogin:Bool = false;
	public static var totalTrophies:Float = GJApi.TROPHIES_ACHIEVED + GJApi.TROPHIES_MISSING;

	/* Grabs user data and returns as a string, true for Username, false for Token */
	public static function getUserInfo(username:Bool = true):String
	{
		if (username)
			return GJApi.username;
		else
			return GJApi.usertoken;
	}

	/* Checks to see if the user has signed in */
	public static function getStatus():Bool
	{
		return userLogin;
	}

	/* Sets the game ID and game key */
	public static function connect()
	{
		trace("Grabbing API keys...");
		GJApi.init(Std.int(GJKeys.id), Std.string(GJKeys.key), false);
	}

	/* Logs the user in */
	public static function authDaUser(in1, in2, ?loginArg:Bool = false)
	{
		if (!userLogin)
		{
			GJApi.authUser(in1, in2, function(v:Bool)
			{
				trace("user: " + (in1 == "" ? "n/a" : in1));
				trace("token:" + in2);
				if (v)
				{
					trace("User authenticated!");
					SaveData.gjUser = in1;
					SaveData.gjToken = in2;
					SaveData.save();
					userLogin = true;
					startSession();

					if (loginArg)
					{
						GameJoltLogin.login = true;
						FlxG.switchState(new GameJoltLogin());
					}
				}
				else
				{
					if (loginArg)
					{
						GameJoltLogin.login = true;
						FlxG.switchState(new GameJoltLogin());
					}
					trace("User login failure!");
				}
			});
		}
	}

	/* Logs the user out and closes the game */
	public static function deAuthDaUser()
	{
		closeSession();
		userLogin = false;
		trace(SaveData.gjUser + SaveData.gjToken);
		SaveData.gjUser = null;
		SaveData.gjToken = null;
		SaveData.save();
		trace(SaveData.gjUser + SaveData.gjToken);
		trace("Logged out!");
		Sys.exit(0);
	}

	/* Awards a trophy to the user! */
	public static function getTrophy(trophyID:Int)
	{
		if (userLogin)
		{
			GJApi.addTrophy(trophyID, function()
			{
				trace("Unlocked a trophy with an ID of " + trophyID);
			});
		}
	}

	/* Starts the session */
	public static function startSession()
	{
		GJApi.openSession(function()
		{
			trace("Session started!");
			new FlxTimer().start(20, function(tmr:FlxTimer)
			{
				pingSession();
			}, 0);
		});
	}

	/* Pings GameJolt to show the session is still active */
	public static function pingSession()
	{
		GJApi.pingSession(true, function()
		{
			trace("Ping!");
		});
	}

	/* Closes the session, used for signing out */
	public static function closeSession()
	{
		GJApi.closeSession(function()
		{
			trace('Closed out the session');
		});
	}
}

class GameJoltInfo extends FlxSubState
{
	public static var version:String = "1.0.2 Public Beta";
}

class GameJoltLogin extends MusicBeatSubstate
{
	var gamejoltText:FlxText;
	var loginTexts:FlxTypedGroup<FlxText>;
	var loginBoxes:FlxTypedGroup<FlxUIInputText>;
	var loginButtons:FlxTypedGroup<FlxButton>;
	var usernameText:FlxText;
	var tokenText:FlxText;
	var usernameBox:FlxUIInputText;
	var tokenBox:FlxUIInputText;
	var signInBox:FlxButton;
	var helpBox:FlxButton;
	var logOutBox:FlxButton;
	var cancelBox:FlxButton;
	var profileIcon:FlxSprite;
	var username:FlxText;
	var gamename:FlxText;
	var trophy:FlxBar;
	var trophyText:FlxText;
	var missTrophyText:FlxText;

	public static var charBop:FlxSprite;

	var icon:FlxSprite;
	var baseX:Int = -320;
	var versionText:FlxText;
	var backdrop:FlxBackdrop;

	public static var login:Bool = false;
	static var trophyCheck:Bool = false;

	override function create()
	{
		trace("init? " + GJApi.initialized);

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-40, -40);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
		add(backdrop);

		charBop = new FlxSprite(FlxG.width - 400, 250);
		charBop.frames = Paths.getSparrowAtlas('characters/boyfriend/DDLCBoyFriend_Assets');
		charBop.animation.addByPrefix('idle', 'BF idle dance', 24, false);
		charBop.animation.addByPrefix('loggedin', 'BF HEY', 24, false);
		charBop.setGraphicSize(Std.int(charBop.width * 1.4));
		charBop.antialiasing = SaveData.globalAntialiasing;
		charBop.flipX = false;
		add(charBop);

		gamejoltText = new FlxText(0, 25, 0, "Game Jolt Login");
		gamejoltText.setFormat(LangUtil.getFont('riffic'), 32, FlxColor.WHITE, CENTER);
		gamejoltText.y += LangUtil.getFontOffset('riffic');
		gamejoltText.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
		gamejoltText.antialiasing = SaveData.globalAntialiasing;
		gamejoltText.screenCenter(X);
		gamejoltText.x += baseX;
		add(gamejoltText);

		versionText = new FlxText(5, FlxG.height - 18, 0, "Game ID: " + GJKeys.id + " API: " + GameJoltInfo.version, 12);
		versionText.setFormat(LangUtil.getFont('riffic'), 12, FlxColor.WHITE, CENTER);
		versionText.y += LangUtil.getFontOffset('riffic');
		versionText.antialiasing = SaveData.globalAntialiasing;
		versionText.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
		add(versionText);

		loginTexts = new FlxTypedGroup<FlxText>(2);
		add(loginTexts);

		usernameText = new FlxText(0, 125, 300, "Username:");
		usernameText.antialiasing = SaveData.globalAntialiasing;

		tokenText = new FlxText(0, 225, 300, "Token:");
		tokenText.antialiasing = SaveData.globalAntialiasing;

		loginTexts.add(usernameText);
		loginTexts.add(tokenText);
		loginTexts.forEach(function(item:FlxText)
		{
			item.screenCenter(X);
			item.x += baseX;
			item.setFormat(LangUtil.getFont('riffic'), 30, FlxColor.WHITE, CENTER);
			item.y += LangUtil.getFontOffset('riffic');
			item.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
		});

		loginBoxes = new FlxTypedGroup<FlxUIInputText>(2);
		add(loginBoxes);

		usernameBox = new FlxUIInputText(0, 175, 300, null, 32, FlxColor.BLACK, FlxColor.WHITE);
		tokenBox = new FlxUIInputText(0, 275, 300, null, 32, FlxColor.BLACK, FlxColor.WHITE);

		usernameBox.font = LangUtil.getFont();
		tokenBox.font = LangUtil.getFont();

		usernameBox.antialiasing = SaveData.globalAntialiasing;
		tokenBox.antialiasing = SaveData.globalAntialiasing;

		loginBoxes.add(usernameBox);
		loginBoxes.add(tokenBox);
		loginBoxes.forEach(function(item:FlxUIInputText)
		{
			item.screenCenter(X);
			item.x += baseX;
		});

		if (GameJoltAPI.getStatus())
		{
			remove(loginTexts);
			remove(loginBoxes);
		}

		loginButtons = new FlxTypedGroup<FlxButton>(3);
		add(loginButtons);

		signInBox = new FlxButton(0, 450, "Sign In", function()
		{
			trace(usernameBox.text);
			trace(tokenBox.text);
			GameJoltAPI.authDaUser(usernameBox.text, tokenBox.text, true);
		});

		helpBox = new FlxButton(0, 550, "Token", function()
		{
			CoolUtil.openURL('https://www.youtube.com/watch?v=T5-x7kAGGnE');
		});

		logOutBox = new FlxButton(0, 650, "Log Out", function()
		{
			GameJoltAPI.deAuthDaUser();
		});

		cancelBox = new FlxButton(0, 650, "Cancel", function()
		{
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7, false, null, true, function()
			{
				FlxG.switchState(new OptionsState());
			});
		});

		if (!GameJoltAPI.getStatus())
		{
			loginButtons.add(signInBox);
			loginButtons.add(helpBox);
		}
		else
		{
			cancelBox.y = 550;
			cancelBox.text = "Continue";
			loginButtons.add(logOutBox);
		}

		loginButtons.add(cancelBox);

		loginButtons.forEach(function(item:FlxButton)
		{
			item.screenCenter(X);
			item.setGraphicSize(Std.int(item.width) * 3);
			item.x += baseX;

			item.label.setFormat(LangUtil.getFont(), 18, FlxColor.BLACK, CENTER);
			item.label.antialiasing = SaveData.globalAntialiasing;
		});

		if (GameJoltAPI.getStatus())
		{
			username = new FlxText(0, 75, 0, "Signed in as:\n" + GameJoltAPI.getUserInfo(true) + '\n', 40);
			username.setFormat(LangUtil.getFont('riffic'), 40, FlxColor.WHITE, CENTER);
			username.alignment = CENTER;
			username.setBorderStyle(OUTLINE, 0xFFFF7CFF, 2);
			username.antialiasing = SaveData.globalAntialiasing;
			username.screenCenter(X);
			username.x += baseX;
			add(username);
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new OptionsState());

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 2 == 0)
			charBop.animation.play((GameJoltAPI.getStatus() ? "loggedin" : "idle"), true);
	}
}
#end
