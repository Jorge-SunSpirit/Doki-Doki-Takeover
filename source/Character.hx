package;

import flixel.util.FlxColor;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import haxe.Json;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;
	var playericon:String;
	var costumes:String;
	var costumelist:Array<CostumeList>;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;

	var gameover_character:String;
	var gameover_character_mirror:String;
	var death_sound:String;
	var win_sound:String;
}

typedef CostumeList =
{
	var subfolder:Bool;
	var internal_Name:String;
	var charFile:String;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	var DEFAULT_CHARACTER:String = 'hidden';

	public var animOffsets:Map<String, Array<Dynamic>>;
	public static var debugMode:Bool = false;

	public static var loadaltcostume:Bool = true;

	public static var isFestival:Bool = false;

	public static var ingame:Bool = true;
	
	public var stunned:Bool = false;

	var costumeoverride:String = '';

	public var isPlayer:Bool = false;
	public var flipAnim:Bool = false;
	public var danceIdle:Bool = false;
	public var curCharacter:String = "hidden";
	public var barColor:FlxColor = FlxColor.WHITE;
	public var singDuration:Float = 6;
	public var specialAnim:Bool = false;
	public var animationsArray:Array<AnimArray> = [];
	public var costumeArray:Array<CostumeList> = [];
	public var deathsound:String = 'fnf_loss_sfx';
	public var winsound:String = 'fnf_loss_sfx';
	public var gameoverchara:String = 'gameover-generic';
	public var gameovercharamirror:String = 'bf';
	public var healthIcon:String = 'bf';
	var hasCostume = false;
	var json:CharacterFile;

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var holdTimer:Float = 0;

	// https://github.com/ThatRozebudDude/FPS-Plus-Public/pull/11
	public var initFacing:Int = FlxObject.RIGHT;
	var initWidth:Float;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?forceCostume:String = '')
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		flipAnim = isPlayer;
		costumeoverride = forceCostume;

		PlayState.altSection = false;

		jsonLoad(curCharacter);

		if (json.costumes != null && loadaltcostume)
		{
			hasCostume = true;
			costumeArray = json.costumelist;
		}

		if (hasCostume)
		{
			trace('we are in!');
			if (costumeoverride == '')
			{
				switch (json.costumes)
				{
					case 'protag':
						costumeoverride = SaveData.protagcostume;
					case 'monika':
						costumeoverride = SaveData.monikacostume;
					case 'yuri':
						costumeoverride = SaveData.yuricostume;
					case 'sayori':
						costumeoverride = SaveData.sayoricostume;
					case 'natsuki':
						costumeoverride = SaveData.natsukicostume;
					case 'gf':
						costumeoverride = SaveData.gfcostume;
					case 'bf':
						costumeoverride = SaveData.bfcostume;
				}
			}

			if (costumeoverride == 'hueh')
				costumeoverride = '';

			trace(costumeoverride);

			for (costume in costumeArray)
			{
				var internal_name:String = '' + costume.internal_Name;
				var charafile:String = '' + costume.charFile;
				var subfolder:Bool = costume.subfolder;

				if (internal_name != costumeoverride)
					continue;

				trace('found costume!');
				if (subfolder)
					jsonLoad("costumes/" + charafile);
				else
					jsonLoad(charafile);
			}	
		}
			
		if (Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT)))
		{
			frames = Paths.getPackerAtlas(json.image);
		}
		else
		{
			frames = Paths.getSparrowAtlas(json.image);
		}

		var imageFile:String = '';
		imageFile = json.image;

		if (!!json.flip_x)
		{
			initFacing = FlxObject.LEFT;
		}
		else
		{
			initFacing = FlxObject.RIGHT;
		}

		if (json.scale != 1)
		{
			setGraphicSize(Std.int(width * json.scale));
			updateHitbox();
		}

		positionArray = json.position;
		cameraPosition = json.camera_position;

		if (isPlayer && json.playericon != null)
			healthIcon = json.playericon;
		else
			healthIcon = json.healthicon;

		singDuration = json.sing_duration;
		if (json.gameover_character != null)
			gameoverchara = json.gameover_character;

		if (json.gameover_character_mirror != null)
			gameovercharamirror = json.gameover_character_mirror;
		else
			gameovercharamirror = curCharacter; // Don't want to edit literally every JSON

		deathsound = json.death_sound;
		winsound = json.win_sound;

		antialiasing = !json.no_antialiasing && SaveData.globalAntialiasing;

		barColor = FlxColor.fromRGB(json.healthbar_colors[0], json.healthbar_colors[1], json.healthbar_colors[2]);

		animationsArray = json.animations;
		if (animationsArray != null && animationsArray.length > 0)
		{
			for (anim in animationsArray)
			{
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; // Bruh
				var animIndices:Array<Int> = anim.indices;

				if (animIndices != null && animIndices.length > 0)
				{
					animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
				}
				else
				{
					animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}

				if (anim.offsets != null && anim.offsets.length > 1)
				{
					var offsetX:Float = anim.offsets[0] / (debugMode ? 1 : json.scale);
					var offsetY:Float = anim.offsets[1] / (debugMode ? 1 : json.scale);

					addOffset(anim.anim, offsetX, offsetY);
				}
			}
		}
		else
		{
			quickAnimAdd('idle', 'BF idle dance');
		}

		costumeoverride = '';
		initWidth = frameWidth;

		//Doing it like this for now
		setFacingFlip((initFacing == FlxObject.LEFT ? FlxObject.RIGHT : FlxObject.LEFT), true, false);
		
		if (!PlayState.mirrormode)	
			facing = (isPlayer ? FlxObject.LEFT : FlxObject.RIGHT);
		else // Turn around please, I beg of you ;-; //Edit, 20 lines of code condenced to this dumb crap ;-;
			facing = (isPlayer ? FlxObject.RIGHT : FlxObject.LEFT);

		calculateDanceIdle();
		dance();

		if (facing != initFacing)
		{
			if (animation.getByName('singRIGHT') != null)
			{
				var oldRight = animation.getByName('singRIGHT').frames;
				var oldOffset = animOffsets['singRIGHT'];
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animOffsets['singRIGHT'] = animOffsets['singLEFT'];
				animation.getByName('singLEFT').frames = oldRight;
				animOffsets['singLEFT'] = oldOffset;
			}

			// IF THEY HAVE MISS ANIMATIONS??
			if (animation.getByName('singRIGHTmiss') != null)
			{
				var oldMiss = animation.getByName('singRIGHTmiss').frames;
				var oldOffset = animOffsets['singRIGHTmiss'];
				animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
				animOffsets['singRIGHTmiss'] = animOffsets['singLEFTmiss'];
				animation.getByName('singLEFTmiss').frames = oldMiss;
				animOffsets['singLEFTmiss'] = oldOffset;
			}

			if (animation.getByName('singRIGHT-alt') != null)
			{
				var oldRight = animation.getByName('singRIGHT-alt').frames;
				var oldOffset = animOffsets['singRIGHT-alt'];
				animation.getByName('singRIGHT-alt').frames = animation.getByName('singLEFT-alt').frames;
				animOffsets['singRIGHT-alt'] = animOffsets['singLEFT-alt'];
				animation.getByName('singLEFT-alt').frames = oldRight;
				animOffsets['singLEFT-alt'] = oldOffset;
			}
		}
	}

	function quickAnimAdd(Name:String, Prefix:String)
	{
		animation.addByPrefix(Name, Prefix, 24, false);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			// HUGE SHOUTOUT TO HOLOFUNK DEV TEAM, I APPRECIATE THEM SO MUCH
			if (!this.isPlayer)
			{
				if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * (singDuration / Conductor.playbackSpeed) * 0.001)
				{
					dance(!isPlayer && PlayState.altSection);
					holdTimer = 0;
				}
			}
			else
			{
				if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;
				else
					holdTimer = 0;

				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
					dance();

				if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
					playAnim('deathLoop');
			}

			if (animation.curAnim != null && animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
				playAnim(animation.curAnim.name + '-loop');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	function jsonLoad(chara:String)
	{
		var path:String = '';

		path = Paths.json('characters/' + chara);

		if (!Assets.exists(path))
		{
			path = Paths.json('characters/' + DEFAULT_CHARACTER);
		}

		var rawJson = Assets.getText(path);
		json = cast Json.parse(rawJson);
	}

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(altAnim:Bool = false)
	{
		var altSuffix:String = '';

		if (!debugMode && !specialAnim)
		{
			if (altAnim)
				altSuffix = '-alt';

			switch (curCharacter)
			{
				default:
					if (danceIdle)
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight' + altSuffix);
						else
							playAnim('danceLeft' + altSuffix);
					}
					else
						playAnim('idle' + altSuffix);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (ingame)
		{
			if (isFestival)
				color = 0x828282;
			else
				color = 0xFFFFFF;
		}

		specialAnim = false;

		if (AnimName.endsWith('alt') && animation.getByName(AnimName) == null)
			AnimName = AnimName.split('-')[0];

		if (AnimName.endsWith('miss') && animation.getByName(AnimName) == null)
		{
			AnimName = AnimName.split('miss')[0];

			if (isFestival)
				color = 0x424282;
			else
				color = 0x8282FF;
		}

		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);

		if (animOffsets.exists(AnimName))
		{
			var offsetX:Float = daOffset[0] * (debugMode ? 1 : scale.x);
			var offsetY:Float = daOffset[1] * (debugMode ? 1 : scale.y);

			if (curCharacter == 'spirit')
				offset.set(offsetX, offsetY);
			else
				offset.set((facing != initFacing ? -1 : 1) * offsetX + (facing != initFacing ? frameWidth - initWidth : 0), offsetY);
		}
		else
		{
			offset.set();
		}

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	// https://github.com/ShadowMario/FNF-PsychEngine/blob/77e76afb1117aa3006685d76318ff4f37cc3d9f6/source/Character.hx#L314
	public function calculateDanceIdle()
	{
		danceIdle = (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
