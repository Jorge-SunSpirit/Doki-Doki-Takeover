package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;
import shaders.ColorMaskShader;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;

	var moniSpr:FlxSprite;
	var tbdSpr:FlxSprite;
	var doki:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = true;

		curWacky = FlxG.random.getObject(getIntroTextShit());

		#if sys
		if (!initialized && Argument.parse(Sys.args()))
		{
			initialized = true;
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			Conductor.changeBPM(120);
			return;
		}
		#end

		startIntro();

		super.create();
	}

	var dokiApp:FlxSprite;
	var bottom:Int;
	var top:Int;


	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var backdrop:FlxBackdrop;
	var creditsBG:FlxBackdrop;
	var scanline:FlxBackdrop;
	var gradient:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			Conductor.changeBPM(120);
			FlxG.sound.music.fadeIn(2, 0, 0.7);
		}

		backdrop = new FlxBackdrop(Paths.image('scrollingBG'));
		backdrop.velocity.set(-10, 0);
		backdrop.antialiasing = SaveData.globalAntialiasing;
		backdrop.shader = new ColorMaskShader(0xFFFDEBF7, 0xFFFDDBF1);
		add(backdrop);

		creditsBG = new FlxBackdrop(Paths.image('credits/pocBackground', 'doki'));
		creditsBG.velocity.set(-50, 0);
		creditsBG.antialiasing = SaveData.globalAntialiasing;
		add(creditsBG);

		var scanline:FlxBackdrop = new FlxBackdrop(Paths.image('credits/scanlines', 'doki'));
		scanline.velocity.set(0, 20);
		scanline.antialiasing = SaveData.globalAntialiasing;
		add(scanline);

		var gradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/gradent', 'doki'));
		gradient.antialiasing = SaveData.globalAntialiasing;
		gradient.scrollFactor.set(0.1, 0.1);
		gradient.screenCenter();
		gradient.setGraphicSize(Std.int(gradient.width * 1.4));
		add(gradient);

		logoBl = new FlxSprite(-40, -12);
		logoBl.frames = Paths.getSparrowAtlas('Start_Screen_AssetsPlus');
		logoBl.antialiasing = SaveData.globalAntialiasing;
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.8));
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = SaveData.globalAntialiasing;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(170, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter', 'preload', true);
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = SaveData.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		// Put whatever hueh you want in the array
		var huehArray:Array<String> = ['TBDHueh', 'NatHueh', 'SayoHueh', 'YuriHueh', 'MoniHueh', 'ProtagHueh'];
		var hueh:String = huehArray[Random.randUInt(0, huehArray.length)];

		// hueh = 'TBDHueh'; // Forced hueh string
		moniSpr = new FlxSprite(0, FlxG.height * .7).loadGraphic(Paths.image('hueh/' + hueh));
		moniSpr.visible = false;
		moniSpr.setGraphicSize(Std.int(moniSpr.width * 1.2));
		moniSpr.updateHitbox();
		moniSpr.screenCenter(X);
		moniSpr.antialiasing = SaveData.globalAntialiasing;
		add(moniSpr);

		tbdSpr = new FlxSprite(0, FlxG.height * .45).loadGraphic(Paths.image('TBDLogo'));
		tbdSpr.visible = false;
		tbdSpr.setGraphicSize(Std.int(tbdSpr.width * 0.9));
		tbdSpr.updateHitbox();
		tbdSpr.screenCenter(X);
		tbdSpr.antialiasing = SaveData.globalAntialiasing;
		add(tbdSpr);

		//Handling doki stuff
		dokiApp = new FlxSprite(0, 0);

		// Before, Natsuki had a 4/5 chance of appearing.
		// Totally not fair!
		// [Pop up string, Bottom, Top]
		var dokiArray:Array<Array<Dynamic>> = [
			['NatsukiPopup', 770, 270], 
			['SayoriPopup', 770, 270],  
			['YuriPopup', 770, 240]
		];

		if (SaveData.beatYuri)
			dokiArray.push(['MonikaPopup', 770, 180]);

		if (SaveData.beatProtag)
			dokiArray.push(['ProtagPopup', 770, 170]);

		// The selected doki
		var selected:Int = Random.randUInt(0, dokiArray.length);
		// selected = 0 // Forced doki for testing

		var dokiIndex:String = dokiArray[selected][0];
		bottom = dokiArray[selected][1];
		top = dokiArray[selected][2];

		dokiApp.setPosition(0, bottom);
		dokiApp.frames = Paths.getSparrowAtlas('intro/${dokiIndex}', 'preload');
		dokiApp.animation.addByPrefix('pop', dokiIndex, 26, false);
		dokiApp.screenCenter(X);
		dokiApp.antialiasing = SaveData.globalAntialiasing;
		add(dokiApp);

		//preload maybe
		var predoki = new FlxSprite(0, 0);
		predoki.frames = Paths.getSparrowAtlas('intro/${dokiIndex}', 'preload');
		predoki.animation.addByPrefix('pop', dokiIndex, 26, false);
		predoki.screenCenter();
		predoki.antialiasing = SaveData.globalAntialiasing;
		predoki.alpha = 0.001;
		add(predoki);

		doki = new FlxSprite(50, 100);
		doki.frames = Paths.getSparrowAtlas('intro/DOKI DOKI');
		doki.animation.addByPrefix('doki', "Doki centered", 24, false);
		doki.antialiasing = SaveData.globalAntialiasing;
		doki.alpha = 0.001;
		doki.updateHitbox();
		add(doki);

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		#if debug
		if (FlxG.keys.pressed.CONTROL && (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L))
		{
			trace(dokiApp.x + " X " + dokiApp.y + ' y');
			if (FlxG.keys.pressed.I)
				dokiApp.y += -10;
			else if (FlxG.keys.pressed.K)
				dokiApp.y += 10;
			if (FlxG.keys.pressed.J)
				dokiApp.x += -10;
			else if (FlxG.keys.pressed.L)
				dokiApp.x += 10;
		}
		#end

		var pressedEnter:Bool = controls.ACCEPT || FlxG.mouse.justPressed;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (SaveData.flashing)
				titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new MainMenuState());
			});
		}

		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');

		switch (curBeat)
		{
			case 1:
				createCoolText(['Team TBD']);
			case 3:
				//addMoreText('presents');
				tbdSpr.visible = true;
			case 4:
				tbdSpr.visible = false;
				deleteCoolText();
			case 5:
				createCoolText(['Powered', 'by']);
			case 7:
				addMoreText('Hueh Engine');
				moniSpr.visible = true;
			case 8:
				deleteCoolText();
				moniSpr.visible = false;
			case 9:
				createCoolText([curWacky[0]]);
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				// addMoreText('Doki');
				dokiApp.animation.play('pop');
				FlxTween.tween(dokiApp, {"scale.x": 0.75, y: top}, 0.15, {ease: FlxEase.sineIn, startDelay: 0.2, onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(dokiApp, {"scale.x": 1}, 0.2, {ease: FlxEase.bounceInOut});
					}});
			case 14:
				doki.alpha = 1;
				doki.animation.play('doki');
			case 15:
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(moniSpr);
			remove(tbdSpr);
			remove(doki);
			remove(dokiApp);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
