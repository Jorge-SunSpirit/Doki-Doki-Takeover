package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var willMiss:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType:Int = 0;
	public var noteStyle:String = '';

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;
	public var copyVisible:Bool = true;

	public var texture(default, set):String = null;

	public var distance:Float = 2000;

	public var playedEditorClick:Bool = false;
	public var editorBFNote:Bool = false;
	var mirrormode:Bool = false;
	public var absoluteNumber:Int;
	private var earlyHitMult:Float = 0.5;
	private var lateHitMult:Float = 1.3;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	private function set_texture(value:String):String
	{
		if (texture != value)
			reloadNote('', value);

		texture = value;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?noteType:Int = 0, noteStyle:String = 'normal')
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.noteStyle = noteStyle;
		this.noteType = noteType;
		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		if (!PlayState.isStoryMode)
			mirrormode = SaveData.mirrorMode;

		x += (SaveData.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		this.strumTime = strumTime;

		this.noteData = noteData;

		if (noteData > -1)
		{
			texture = '';

			x += swagWidth * (noteData % 4);

			// Doing this 'if' check to fix the warnings on Senpai songs
			if (!isSustainNote)
			{
				var animToPlay:String = '';
				switch (noteData % 4)
				{
					case 0:
						animToPlay = 'purple';
					case 1:
						animToPlay = 'blue';
					case 2:
						animToPlay = 'green';
					case 3:
						animToPlay = 'red';
				}
				animation.play(animToPlay + 'Scroll');
			}
		}

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;

			if (SaveData.downScroll)
				flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			offsetX -= width / 2;

			if (noteStyle == 'pixel')
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;

				if (PlayState.instance != null)
					prevNote.scale.y *= PlayState.instance.songSpeed;

				if (noteStyle == 'pixel')
				{
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); // Auto adjust note size
				}
				prevNote.scale.y /= Conductor.playbackSpeed;
				prevNote.updateHitbox();
			}

			if (noteStyle == 'pixel')
			{
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		}
		else if (!isSustainNote)
			earlyHitMult = 1;

		// markov note
		if (noteType == 2 && !mirrormode)
		{
			lateHitMult = 0.3;
			earlyHitMult = 0.2;
		}

		x += offsetX;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;

	public var originalHeightForCalcs:Float = 6;

	public function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '')
	{
		if (prefix == null)
			prefix = '';
		if (texture == null)
			texture = '';
		if (suffix == null)
			suffix = '';

		var skin:String = texture;

		if (texture.length < 1)
			skin = 'NOTE_assets';

		if (noteStyle == 'lib' && noteType != 2)
			skin = 'NOTE_assetsLibitina';

		var animName:String = null;

		if (animation.curAnim != null)
			animName = animation.curAnim.name;

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length - 1] = prefix + arraySkin[arraySkin.length - 1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');

		switch (noteStyle)
		{
			case 'pixel':
				if (isSustainNote)
				{
					loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
					width = width / 4;
					height = height / 2;
					originalHeightForCalcs = height;
					loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
				}
				else
				{
					loadGraphic(Paths.image('pixelUI/' + blahblah));
					width = width / 4;
					height = height / 6;
					loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				loadPixelNoteAnims();
				antialiasing = false;

				if (isSustainNote)
				{
					offsetX += lastNoteOffsetXForPixelAutoAdjusting;
					lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
					offsetX -= lastNoteOffsetXForPixelAutoAdjusting;
				}
			default:
				frames = Paths.getSparrowAtlas(blahblah);
				loadNoteAnims();
				antialiasing = SaveData.globalAntialiasing;
		}

		if (isSustainNote)
			scale.y = lastScaleY;

		updateHitbox();

		if (animName != null)
			animation.play(animName, true);
	}

	function loadNoteAnims()
	{
		switch (noteType)
		{
			case 2:
				animation.addByPrefix('greenScroll', 'markov green0');
				animation.addByPrefix('redScroll', 'markov red0');
				animation.addByPrefix('blueScroll', 'markov blue0');
				animation.addByPrefix('purpleScroll', 'markov purple0');

				if (isSustainNote)
				{
					animation.addByPrefix('purpleholdend', 'markov pruple end hold');
					animation.addByPrefix('greenholdend', 'markov green hold end');
					animation.addByPrefix('redholdend', 'markov red hold end');
					animation.addByPrefix('blueholdend', 'markov blue hold end');

					animation.addByPrefix('purplehold', 'markov purple hold piece');
					animation.addByPrefix('greenhold', 'markov green hold piece');
					animation.addByPrefix('redhold', 'markov red hold piece');
					animation.addByPrefix('bluehold', 'markov blue hold piece');
				}

			default:
				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				if (isSustainNote)
				{
					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');

					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
				}
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims()
	{
		if (isSustainNote)
		{
			animation.add('purpleholdend', [PURP_NOTE + 4]);
			animation.add('greenholdend', [GREEN_NOTE + 4]);
			animation.add('redholdend', [RED_NOTE + 4]);
			animation.add('blueholdend', [BLUE_NOTE + 4]);

			animation.add('purplehold', [PURP_NOTE]);
			animation.add('greenhold', [GREEN_NOTE]);
			animation.add('redhold', [RED_NOTE]);
			animation.add('bluehold', [BLUE_NOTE]);
		}
		else
		{
			switch (noteType)
			{
				case 2:
					animation.add('greenScroll', [GREEN_NOTE + 20]);
					animation.add('redScroll', [RED_NOTE + 20]);
					animation.add('blueScroll', [BLUE_NOTE + 20]);
					animation.add('purpleScroll', [PURP_NOTE + 20]);
				default:
					animation.add('greenScroll', [GREEN_NOTE + 4]);
					animation.add('redScroll', [RED_NOTE + 4]);
					animation.add('blueScroll', [BLUE_NOTE + 4]);
					animation.add('purpleScroll', [PURP_NOTE + 4]);
			} 
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (willMiss && !wasGoodHit)
			{
				tooLate = true;
				canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult))
				{
					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
						canBeHit = true;
				}
				else
				{
					canBeHit = true;
					willMiss = true;
				}
			}
		}
		else if (!SaveData.mirrorMode || (SaveData.mirrorMode && noteType != 2))
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}