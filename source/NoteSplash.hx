package;

import flixel.FlxG;
import flixel.FlxSprite;

class NoteSplash extends FlxSprite
{
	var allowRotation:Bool = true;
	public function new(?fromNote:Int = 0, x:Float, y:Float, ?style:String)
	{
		super(x, y);

		antialiasing = SaveData.globalAntialiasing;

		switch (style) // Libbie for later
		{
			case 'lib':
				frames = Paths.getSparrowAtlas('libbie_Splash');
				allowRotation = false;
			case 'pixel':
				frames = Paths.getSparrowAtlas('pixel_Splash');
				scale.set(6, 6);
				setPosition(x + 100, y + 100);
				allowRotation = false;
				antialiasing = false;
			default:
				frames = Paths.getSparrowAtlas('NOTE_splashes_doki');
				allowRotation = true;
				setPosition(x - 25, y - 25);
		}

		animation.addByPrefix('note1', 'note splash blue', 24, false);
		animation.addByPrefix('note2', 'note splash green', 24, false);
		animation.addByPrefix('note0', 'note splash purple', 24, false);
		animation.addByPrefix('note3', 'note splash red', 24, false);

		setupNoteSplash(x, y, fromNote);
	}

	public function setupNoteSplash(x:Float, y:Float, noteData:Int = 0)
	{
		//setPosition(x - 25, y - 25);
		alpha = 1;

		flipX = Random.randBool(0.5);

		if (allowRotation)
			angle = Random.randF(0, 45);

		animation.play("note" + noteData, true);
		animation.finishCallback = function(name) kill();

		animation.curAnim.frameRate = 24 + Random.randUInt(-2, 2);
		updateHitbox();

		offset.set(width * 0.3, height * 0.3);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
