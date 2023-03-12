package;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	private var initChar:String = 'bf';
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;
	public var isHealth:Bool = true;
	public var sprTracker:FlxSprite;

	private var iconOffsets:Array<Float> = [0, 0];

	var pixelIcons:Array<String> = [
		'bf-pixel',
		'senpai',
		'spirit',
		'monika-pixel',
		'monika-pixelnew',
		'duet',
		'duetnew',
		'monika-angry',
		'monika-angrynew',
		'dual-demise',
		'pen-pixel',
		'pen-demise',
		'jill',
		'shaker'
	];

	public function new(?char:String = 'bf', ?isPlayer:Bool = false, ?isHealth:Bool = true)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;
		this.isHealth = isHealth;

		initChar = char;

		isPlayer = isOldIcon = false;

		changeIcon(char);
		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		(isOldIcon = !isOldIcon) ? changeIcon('bf-old') : changeIcon(initChar);
	}

	public function changeIcon(daChar:String)
	{
		if (!Paths.fileExists('images/icons/icon-$daChar.png', IMAGE))
			daChar = 'bf-old';

		if (isHealth)
		{
			loadGraphic(Paths.image('icons/icon-' + daChar));
			loadGraphic(Paths.image('icons/icon-' + daChar), true, Math.floor(width / 3), Math.floor(height));
			iconOffsets[0] = (width - 150) / 3;
			iconOffsets[1] = (width - 150) / 3;
			updateHitbox();
		}
		else
			loadGraphic(Paths.image('icons/icon-' + daChar), true, 150, 150);

		animation.add(daChar, [0, 1, 2], 0, false, isPlayer);
		animation.play(daChar);

		if (SaveData.globalAntialiasing)
			antialiasing = !pixelIcons.contains(daChar);

		char = daChar; // gotta make sure the icon itself is actually the changed char
	}

	override function updateHitbox()
	{
		super.updateHitbox();

		if (isHealth)
		{
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
