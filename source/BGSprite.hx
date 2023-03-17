package;

import flixel.FlxG;
import flixel.FlxSprite;

class BGSprite extends FlxSprite
{
	private var idleAnim:String;

	public function new(image:String, library:String, ?locale:Bool, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?anim:Array<String> = null, ?loop:Bool = false, ?framerate:Int = 24)
	{
		super(x, y);

		if (anim != null)
		{
			frames = Paths.getSparrowAtlas(image, library, locale);
			animation.addByPrefix(anim[0], anim[1], framerate, loop);

			if (idleAnim == null)
			{
				idleAnim = anim[0];
				animation.play(idleAnim);
			}
		}
		else
		{
			if (image != null)
				loadGraphic(Paths.image(image, library, locale));

			active = false;
		}
		scrollFactor.set(scrollX, scrollY);
		antialiasing = SaveData.globalAntialiasing;
	}

	public function dance(?forceplay:Bool = false)
	{
		if (idleAnim != null)
			animation.play(idleAnim, forceplay);
	}
}
