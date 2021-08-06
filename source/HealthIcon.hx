package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = true;
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('bf-pixel', [21, 22], 0, false, isPlayer);
		animation.add('bf-pixelangry', [21, 22], 0, false, isPlayer);
		animation.add('face', [10, 11], 0, false, isPlayer);
		animation.add('dad', [12, 13], 0, false, isPlayer);
		animation.add('senpai', [30, 30], 0, false, isPlayer);
		animation.add('playablesenpai', [30, 30], 0, false, isPlayer);
		animation.add('senpai-angry', [31, 31], 0, false, isPlayer);
		animation.add('monika', [24, 25], 0, false, isPlayer);
		animation.add('monika-senpai', [26, 27], 0, false, isPlayer);
		animation.add('monika-angry', [28, 29], 0, false, isPlayer);
		animation.add('duet', [26, 27], 0, false, isPlayer);
		animation.add('bf-old', [14, 15], 0, false, isPlayer);
		animation.add('gf', [16], 0, false, isPlayer);
		animation.add('gf-pixel', [16], 0, false, isPlayer);
		animation.add('gf-doki', [16], 0, false, isPlayer);
		animation.add('natsuki', [10, 11], 0, false, isPlayer);
		animation.add('sayori', [10, 11], 0, false, isPlayer);
		animation.play(char);

		switch(char)
		{
			case 'bf-pixel' | 'bf-pixelangry' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel' | 'monika':
				antialiasing = false;
		}
		
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
