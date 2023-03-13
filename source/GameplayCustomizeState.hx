import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.util.FlxTimer;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.ui.Keyboard;
import flixel.FlxSprite;
import flixel.FlxG;

class GameplayCustomizeState extends MusicBeatState
{
	var defaultX:Float = 569; // FlxG.width * 0.55 - 135
	var defaultY:Float = 540; // FlxG.height / 2 - 50

	var sick:FlxSprite;

	var text:FlxText;

	var bf:Character;
	var dad:Character;
	var gf:Character;

	public var laneunderlay:FlxSprite;
	public var laneunderlayOpponent:FlxSprite;

	var strumLine:FlxSprite;
	var strumLineNotes:FlxTypedGroup<FlxSprite>;
	var playerStrums:FlxTypedGroup<FlxSprite>;
	var cpuStrums:FlxTypedGroup<FlxSprite>;

	var zoomStuff:Bool = false;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public override function create()
	{
		super.create();

		Character.isFestival = false;

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Customizing Gameplay Modules", null);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		camHUD.zoom = SaveData.zoom;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

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

		var camFollow = new FlxObject(0, 0, 1, 1);

		dad = new Character(100, 100, 'dad');
		bf = new Character(770, 450, 'bf', true);
		gf = new Character(400, 130, 'gf');
		gf.scrollFactor.set(0.95, 0.95);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + 400, dad.getGraphicMidpoint().y);

		camFollow.setPosition(camPos.x, camPos.y);

		add(gf);
		add(bf);
		add(dad);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = 0.9;
		FlxG.camera.focusOn(camFollow.getPosition());

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		if (SaveData.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		laneunderlayOpponent = new FlxSprite(70, 0).makeGraphic(500, FlxG.height * 2, FlxColor.BLACK);
		laneunderlayOpponent.alpha = SaveData.laneTransparency;
		laneunderlayOpponent.scrollFactor.set();
		laneunderlayOpponent.screenCenter(Y);
		laneunderlayOpponent.cameras = [camHUD];

		laneunderlay = new FlxSprite(70 + (FlxG.width / 2), 0).makeGraphic(500, FlxG.height * 2, FlxColor.BLACK);
		laneunderlay.alpha = SaveData.laneTransparency;
		laneunderlay.scrollFactor.set();
		laneunderlay.screenCenter(Y);
		laneunderlay.cameras = [camHUD];

		if (SaveData.laneUnderlay)
		{
			add(laneunderlayOpponent);
			add(laneunderlay);
		}

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		sick = new FlxSprite().loadGraphic(Paths.image('sick'));
		sick.setGraphicSize(Std.int(sick.width * 0.7));
		sick.antialiasing = SaveData.globalAntialiasing;
		sick.scrollFactor.set();
		sick.updateHitbox();

		if (SaveData.ratingToggle)
			insert(members.indexOf(strumLineNotes), sick);

		if (!SaveData.changedHit)
		{
			SaveData.changedHitX = defaultX;
			SaveData.changedHitY = defaultY;
		}

		sick.x = SaveData.changedHitX;
		sick.y = SaveData.changedHitY;

		strumLine.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		sick.cameras = [camHUD];

		generateStaticArrows(0);
		generateStaticArrows(1);

		if (SaveData.middleScroll)
		{
			laneunderlayOpponent.alpha = 0;
			laneunderlay.screenCenter(X);
		}

		text = new FlxText(0, FlxG.height + 40, 0, LangUtil.getString('descCustomizeState', 'option'), 12);
		text.antialiasing = SaveData.globalAntialiasing;
		text.scrollFactor.set();
		text.setFormat(LangUtil.getFont(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		text.cameras = [camHUD];

		add(text);

		FlxTween.tween(text, {y: FlxG.height - 22 + LangUtil.getFontOffset()}, 2, {ease: FlxEase.elasticInOut});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!zoomStuff)
		{
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				zoomStuff = true;
			});
		}

		if (SaveData.zoom < 0.8)
			SaveData.zoom = 0.8;

		if (SaveData.zoom > 1.1)
			SaveData.zoom = 1.1;

		FlxG.camera.zoom = FlxMath.lerp(0.9, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(SaveData.zoom, camHUD.zoom, 0.95);

		if (FlxG.mouse.overlaps(sick) && FlxG.mouse.pressed)
		{
			sick.x = (FlxG.mouse.x - sick.width / 2) - 60;
			sick.y = (FlxG.mouse.y - sick.height) - 60;
		}

		for (i in playerStrums)
			i.y = strumLine.y;
		for (i in strumLineNotes)
			i.y = strumLine.y;

		if (FlxG.keys.justPressed.Q)
		{
			SaveData.zoom -= 0.02;
			camHUD.zoom = SaveData.zoom;
		}

		if (FlxG.keys.justPressed.E)
		{
			SaveData.zoom += 0.02;
			camHUD.zoom = SaveData.zoom;
		}

		if (FlxG.mouse.overlaps(sick) && FlxG.mouse.justReleased)
		{
			SaveData.changedHitX = sick.x;
			SaveData.changedHitY = sick.y;
			SaveData.changedHit = true;
		}

		if (FlxG.keys.justPressed.C)
		{
			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (FlxG.random.int(10, 420) + "").split('');

			// make sure theres a 0 in front or it looks weird lol!
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
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
				numScore.screenCenter();
				numScore.x = sick.x + (45 * daLoop) - 50;
				numScore.y = sick.y + 100;
				numScore.cameras = [camHUD];
				numScore.antialiasing = SaveData.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				if (SaveData.ratingToggle)
					insert(members.indexOf(strumLineNotes), numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}
		}

		if (FlxG.keys.justPressed.R)
		{
			sick.x = defaultX;
			sick.y = defaultY;
			SaveData.zoom = 1;
			camHUD.zoom = SaveData.zoom;
			SaveData.changedHitX = sick.x;
			SaveData.changedHitY = sick.y;
			SaveData.changedHit = false;
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new OptionsState());
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 2 == 0)
		{
			bf.dance();
			dad.dance();
		}
		else if (dad.curCharacter == 'sayori')
			dad.dance();

		gf.dance();

		if (!FlxG.keys.pressed.SPACE && zoomStuff && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.010;
		}
	}

	// ripped from play state cuz im lazy
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
			babyArrow.antialiasing = SaveData.globalAntialiasing;
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

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					if (SaveData.middleScroll)
						babyArrow.visible = false;
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 98;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (SaveData.middleScroll)
				babyArrow.x -= 320;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}
}
