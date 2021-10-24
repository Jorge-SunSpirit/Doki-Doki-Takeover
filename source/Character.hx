package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/GF_assets');
				frames = tex;
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'gf-realdoki':
				// GIRLFRIEND CODE
				tex = Paths.getSparrowAtlas('characters/DDLCGF_ass_sets');
				frames = tex;
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('countdownThree', 'GF countdown', [0, 1, 2, 3, 4, 5, 6], "", 24, false);
				animation.addByIndices('countdownTwo', 'GF countdown', [7, 8, 9, 10, 11, 12, 13, 14, 15], "", 24, false);
				animation.addByIndices('countdownOne', 'GF countdown', [16, 17, 18, 19, 20, 21, 22, 23], "", 24, false);
				animation.addByIndices('countdownGo', 'GF countdown', [24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34], "", 24, false);
				animation.addByPrefix('necksnap', 'GF NECKSNAP', 24, true);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('characters/gfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'nogf-pixel':
				tex = Paths.getSparrowAtlas('characters/nogfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'gf-doki':
				tex = Paths.getSparrowAtlas('characters/gfdoki');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile(curCharacter);
				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getSparrowAtlas('characters/DADDY_DEAREST');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);
				animation.addByIndices('idleLoop', "Dad idle dance", [11, 12], "", 12, true);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'bf':
				var tex = Paths.getSparrowAtlas('characters/BOYFRIEND');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;

			case 'bf-doki':
				var tex = Paths.getSparrowAtlas('characters/DDLCBoyFriend_Assets');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;

			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);
				animation.addByPrefix('peaceSIGN', 'BF PEACE', 24, false);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;

			case 'bf-pixelangry':
				frames = Paths.getSparrowAtlas('characters/bfPixelangry');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;

			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				loadOffsetFile(curCharacter);

				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;

			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'playablesenpai':
				frames = Paths.getSparrowAtlas('characters/playablesenpai');
				animation.addByPrefix('idle', 'Senpai Idle', 24, true);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'miss Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFTmiss', 'miss Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'miss Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWNmiss', 'miss Senpai DOWN NOTE', 24, false);

				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "senpai retry", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);

				// I'M TILTED I HAD T OMODIDFY SENPAI'S STUPD PECKIN SPRITE SHEET JUST SO HE DIES WITHOUT CRASHING THE GAME, IF I DIDN'T HAVE LUMATIC ON MY SIDE I WOULD OF LOST IT HOURS AGO SO THANK YOU STUPID CODE FOR NOT WORKING SMILE
				// Lumatic says "Jorge and Senpai have a big forehead tho"

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				flipX = true;

				playAnim('idle');

				antialiasing = false;

			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'monika':
				frames = Paths.getSparrowAtlas('characters/monika');
				animation.addByPrefix('idle', 'Monika Idle', 24, false);
				animation.addByPrefix('singUP', 'Monika UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Monika LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Monika RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Monika DOWN NOTE', 24, false);

				animation.addByPrefix('singUP-alt', 'Monika UP NOTE', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Monika DOWN NOTE', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Monika LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Monika RIGHT NOTE', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			// Duet_Assets
			case 'duet':
				frames = Paths.getSparrowAtlas('characters/Duet_Assets');
				animation.addByPrefix('idle', 'Duet Idle', 24, false);
				animation.addByPrefix('singUP', 'Duet Monika UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Duet Monika LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Duet Monika RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Duet Monika DOWN NOTE', 24, false);

				animation.addByPrefix('singUP-alt', 'Duet Senpai UP NOTE', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Duet Senpai DOWN NOTE', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Duet Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Duet Senpai RIGHT NOTE', 24, false);

				animation.addByPrefix('cutsceneidle', 'cutscene idle', 24, false);
				animation.addByPrefix('cutscenetransition', 'cutscene transition', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'monika-angry':
				frames = Paths.getSparrowAtlas('characters/Monika_Finale');
				animation.addByPrefix('idle', 'MONIKA IDLE', 24, false);
				animation.addByPrefix('singUP', 'MONIKA UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'MONIKA LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'MONIKA RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'MONIKA DOWN NOTE', 24, false);

				animation.addByPrefix('singUP-alt', 'MONIKA UP GLITCH', 24, false);
				animation.addByPrefix('singLEFT-alt', 'MONIKA LEFT GLITCH', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'MONIKA RIGHT GLITCH', 24, false);
				animation.addByPrefix('singDOWN-alt', 'MONIKA DOWN GLITCH', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'natsuki':
				tex = Paths.getSparrowAtlas('characters/Doki_Nat_Assets');
				frames = tex;
				animation.addByPrefix('idle', 'Nat Idle', 24, false);
				animation.addByPrefix('singUP', 'Nat Sing Note Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Nat Sing Note Right', 24, false);
				animation.addByPrefix('singDOWN', 'Nat Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Nat Sing Note Left', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'sayori':
				// and the blind forest
				tex = Paths.getSparrowAtlas('characters/Doki_Sayo_Assets');
				frames = tex;
				animation.addByIndices('danceLeft', 'Sayo Idle nrw test', [25, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceRight', 'Sayo Idle nrw test', [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], "", 24, false);
				// animation.addByPrefix('idle', 'Sayo Idle', 24, false);
				animation.addByPrefix('singUP', 'Sayo Sing Note Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Sayo Sing Note Right', 24, false);
				animation.addByPrefix('singDOWN', 'Sayo Sing Note Down', 24, false);
				animation.addByPrefix('singLEFT', 'Sayo Sing Note Left', 24, false);
				animation.addByPrefix('nara', 'Sayo Nara animated', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'yuri':
				// on ice
				tex = Paths.getSparrowAtlas('characters/Doki_Yuri_Assets');
				frames = tex;
				animation.addByPrefix('idle', 'Yuri Idle', 24, false);
				animation.addByPrefix('singUP', 'Yuri Sing Note Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Yuri Sing Note Right', 24, false);
				animation.addByPrefix('singDOWN', 'Yuri Sing Note Down', 24, false);
				animation.addByPrefix('singLEFT', 'Yuri Sing Note Left', 24, false);
				animation.addByPrefix('breath', 'Yuri Breath', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'yuri-crazy':
				// damn she crazy
				tex = Paths.getSparrowAtlas('characters/Doki_Crazy_Yuri_Assets');
				frames = tex;
				animation.addByPrefix('idle', 'Yuri Crazy Idle', 24, false);
				animation.addByPrefix('singUP', 'Yuri Crazy Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Yuri Crazy Right', 24, false);
				animation.addByPrefix('singDOWN', 'Yuri Crazy Down', 24, false);
				animation.addByPrefix('singLEFT', 'Yuri Crazy Left', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'monika-real':
				// I love my wife - SirDuSterBuster
				tex = Paths.getSparrowAtlas('characters/Doki_MonikaNonPixel_Assets');
				frames = tex;
				animation.addByPrefix('idle', 'Monika Returns Idle', 24, false);
				animation.addByPrefix('singUP', 'Monika Returns Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Monika Returns Right', 24, false);
				animation.addByPrefix('singDOWN', 'Monika Returns Down', 24, false);
				animation.addByPrefix('singLEFT', 'Monika Returns Left', 24, false);

				animation.addByPrefix('singUP-alt', 'Monika Returns Up', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Monika Returns Right', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Monika Returns Down', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Monika Returns Left', 24, false);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * .9));
				playAnim('idle');

			case 'bigmonika':
				frames = Paths.getSparrowAtlas('characters/big_monikia_base');
				animation.addByPrefix('idle', 'Big Monika Idle', 24, false);
				animation.addByPrefix('singUP', 'Big Monika Up', 24, false);
				animation.addByPrefix('singDOWN', 'Big Monika Down', 24, false);
				animation.addByPrefix('singLEFT', 'Big Monika Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Big Monika Right', 24, false);
				animation.addByPrefix('lastNOTE', 'Big Monika Last Note', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');
				updateHitbox();
			case 'bigmonika-dead':
				frames = Paths.getSparrowAtlas('characters/big_monikia_death');
				animation.addByPrefix('singUP', "Big Monika Retry Start", 24, false);
				animation.addByPrefix('firstDeath', 'Big Monika Retry Start', 24, false);
				animation.addByPrefix('deathLoop', 'Big Monika Retry Loop', 24, true);
				animation.addByPrefix('deathConfirm', 'Big Monika Retry End', 24, false);
				animation.addByPrefix('crashDeath', 'Big Monika SCARY', 24, false);
				animation.play('firstDeath');

				loadOffsetFile(curCharacter);

				flipX = true;
				playAnim('firstDeath');
				updateHitbox();
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf') && !curCharacter.startsWith("playablesenpai") && !curCharacter.startsWith("bigmonika-dead"))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	public function loadOffsetFile(character:String)
	{
		var offset:Array<String> = CoolUtil.coolTextFile(Paths.txt('images/characters/' + character + "Offsets"));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			if (animation.getByName('idleLoop') != null)
			{
				if (!animation.curAnim.name.startsWith('sing') && animation.curAnim.finished)
					playAnim('idleLoop');
			}

			var dadVar:Float = 6;

			if (curCharacter == 'yuri-crazy')
				dadVar = 4;

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(altAnim:Bool = false)
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-realdoki' | 'gf-pixel' | 'gf-doki' | 'nogf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'sayori':
					if (animation.curAnim.name != 'nara')
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'yuri':
					if (animation.curAnim.name != 'breath')
					{
						if (altAnim && animation.getByName('idle-alt') != null)
							playAnim('idle-alt')
						else
							playAnim('idle');
					}

				case 'bigmonika':
					if (animation.curAnim.name != 'lastNOTE')
					{
						if (altAnim && animation.getByName('idle-alt') != null)
							playAnim('idle-alt')
						else
							playAnim('idle');
					}

				default:
					if (altAnim && animation.getByName('idle-alt') != null)
						playAnim('idle-alt')
					else
						playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
