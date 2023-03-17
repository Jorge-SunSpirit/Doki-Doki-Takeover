package;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import shaders.ColorMaskShader;

class CatfightPopup extends MusicBeatSubstate
{
	var isFreePlay:Bool = false;
	var canpressbuttons:Bool = false;

	var curSelected:Int = 1;
	var selectGrp:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	public function new(state:String = 'story')
	{
		super();

		if (state == 'freeplay')
		{
			var background:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
			background.alpha = 0.5;
			add(background);

			if (SaveData.mirrorMode)
				curSelected = 0;

			DokiFreeplayState.instance.acceptInput = false;
			isFreePlay = true;
		}
		else
		{
			var backdrop:FlxBackdrop = new FlxBackdrop(Paths.image('scrollingBG'));
			backdrop.velocity.set(-40, -40);
			backdrop.antialiasing = SaveData.globalAntialiasing;
			backdrop.shader = new ColorMaskShader(0xFFFDFFFF, 0xFFFDDBF1);
			add(backdrop);
			DokiSideStory.sidestoryinstance.acceptInput = false;
		}

		var select:FlxSprite = new FlxSprite(0, 40).loadGraphic(Paths.image('extraui/selecttext', true));
		select.antialiasing = SaveData.globalAntialiasing;
		select.scale.set(0.8, 0.8);
		select.updateHitbox();
		select.screenCenter(X);
		add(select);

		var yuri:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('extraui/catfightYuri'));
		yuri.antialiasing = SaveData.globalAntialiasing;
		yuri.scale.set(0.6, 0.6);
		yuri.updateHitbox();
		yuri.screenCenter();
		yuri.x -= 300;
		yuri.y += 60;
		yuri.ID = 0;
		add(yuri);

		var natsuki:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('extraui/catfightNat'));
		natsuki.antialiasing = SaveData.globalAntialiasing;
		natsuki.scale.set(0.6, 0.6);
		natsuki.updateHitbox();
		natsuki.screenCenter();
		natsuki.x += 300;
		natsuki.y += 60;
		natsuki.ID = 1;
		add(natsuki);

		selectGrp.add(yuri);
		selectGrp.add(natsuki);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			canpressbuttons = true;
		});

		changeItem();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (canpressbuttons)
		{
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
	
				if (isFreePlay)
					DokiFreeplayState.instance.acceptInput = true;
				else
					DokiSideStory.sidestoryinstance.acceptInput = true;
	
				close();
			}
	
			if (controls.LEFT_P) changeItem(-1);
			if (controls.RIGHT_P) changeItem(1);
	
			if (controls.ACCEPT)
			{
				if (isFreePlay)
				{
					PlayState.isYuri = (curSelected == 0 ? true : false);
					DokiFreeplayState.instance.startsong();
					close();
				}	
				else
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));
					PlayState.isYuri = (curSelected == 0 ? true : false);
					DokiSideStory.sidestoryinstance.loadSong('Catfight');
					canpressbuttons = false;
				}
			}
		}
	}

	function changeItem(amt:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += amt;

		if (curSelected > 1)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 1;

		for (sel in selectGrp.members)
		{
			if (sel.ID == curSelected)
				sel.color = FlxColor.WHITE;
			else
				sel.color = FlxColor.GRAY;
		}
	}
}
