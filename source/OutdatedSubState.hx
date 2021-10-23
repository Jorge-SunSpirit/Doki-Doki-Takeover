package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "IDFK LOL";
	public static var currChanges:String = "dk";

	private var bgColors:Array<String> = ['#314d7f', '#4e7093', '#70526e', '#594465'];
	private var colorRotation:Int = 1;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGFriends'));
		bg.scale.x *= 1;
		bg.scale.y *= 1;
		bg.screenCenter();
		add(bg);

		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Welcome to Doki Doki Takeover!"
			+ "\nThis is a sequel to the Monika Full Week mod"
			+ "\n\nHave you played Monika Full Week?\n\n"
			+ "\nEnter for Yes - Esc for No\n",
			32);

		txt.setFormat(LangUtil.getFont(), 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);

		FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
			if (colorRotation < (bgColors.length - 1))
				colorRotation++;
			else
				colorRotation = 0;
		}, 0);
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
		{
			FlxG.save.data.funnyquestionpopup = true;
			FlxG.switchState(new MainMenuState());
		}
		if (controls.ACCEPT)
		{
			FlxG.save.data.funnyquestionpopup = true;
			FlxG.save.data.monibeaten = true;
			FlxG.save.data.weekUnlocked = 2;

			#if debug
			// devonlystuff
			FlxG.save.data.sayobeaten = true;
			FlxG.save.data.natbeaten = true;
			FlxG.save.data.yuribeaten = true;
			FlxG.save.data.extrabeaten = true;
			FlxG.save.data.weekUnlocked = 10;
			#end

			FlxG.switchState(new MainMenuState());
		}
	}
}
