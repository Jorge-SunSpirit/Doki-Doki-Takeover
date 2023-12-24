package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

#if FEATURE_GAMEJOLT
import GameJolt.GameJoltAPI;
#end

class PopupMessage extends MusicBeatSubstate
{
	var popupID:Int = 0;

	var popupData:Array<Array<Dynamic>> = [
		['prologue', ['Prologue']],
		['sayori', ['Sayo', 'GFCount']],
		['natsuki', ['Nat', 'Nat2', 'Extra1']],
		['yuri', ['Yuri', 'Extra2']],
		['monika', ['Monika']],
		['festival', ['Festival', 'Mirror', 'Epiphany']],
		['encore', ['Encore', 'Encore2']],
		['protag', ['Protag', 'Side', 'Costume', 'Extra3', 'Credits']],
		['side', ['Gallery', 'VA11HallA']],
		['epiphany', ['Lyrics']],
		['libitina', ['Side2', 'Libitina']]
	];

	var popupStyles:Array<Array<Dynamic>> = [
		['Epiphany', 'epiphany'],
		['Lyrics', 'epiphany'],
		['VA11HallA', 'va11halla'],
		['Libitina', 'libitina']
	];

	var state:String = 'story';
	var style:String = 'normal';
	var type:String = 'Prologue';

	var box:FlxSprite;
	var text:FlxText;
	var popupText:String = 'Just Monika.';

	public function new(type:String, state:String = 'story')
	{
		super();

		this.state = state.toLowerCase();
		this.type = type;

		switch (this.state)
		{
			case 'story':
				DokiStoryState.instance.acceptInput = false;
			case 'freeplay':
				DokiFreeplayState.instance.acceptInput = false;
		}

		for (i in 0...popupData.length)
		{
			if (popupData[i][0] != type.toLowerCase())
				continue;

			popupID = i;
		}

		var background:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		background.alpha = 0.5;
		add(background);

		box = new FlxSprite();
		box.frames = Paths.getSparrowAtlas('dokistory/popup', 'preload');
		box.animation.addByPrefix('normal', 'normal');
		box.animation.addByPrefix('glitch', 'glitch');
		box.animation.addByPrefix('va11halla', 'va11halla');
		box.animation.addByPrefix('libitina', 'libitina');
		box.animation.play('normal');
		box.antialiasing = SaveData.globalAntialiasing;
		box.screenCenter();
		box.offset.set(-71);
		add(box);

		text = new FlxText(0, box.y + 76, box.frameWidth * 0.95, popupText);
		text.setFormat(LangUtil.getFont('aller'), 32, FlxColor.BLACK, FlxTextAlign.CENTER);
		text.y += LangUtil.getFontOffset('aller');
		text.screenCenter(X);
		text.antialiasing = SaveData.globalAntialiasing;
		add(text);

		FlxG.sound.play(Paths.sound('scrollMenu'));
		updateBox();
	}

	function updateBox():Void
	{
		popupText = LangUtil.getString('msg' + popupData[popupID][1][0], 'story');

		for (i in 0...popupStyles.length)
		{
			if (popupStyles[i][0] != popupData[popupID][1][0])
				continue;

			style = popupStyles[i][1].toLowerCase();
		}

		switch (style)
		{
			default:
				if (!FlxG.sound.music.playing)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					Conductor.changeBPM(120);
				}

				text.setFormat(LangUtil.getFont('aller'), 32, FlxColor.BLACK, FlxTextAlign.CENTER);
				text.antialiasing = SaveData.globalAntialiasing;
				box.animation.play('normal');
				box.offset.set(-71);
				box.antialiasing = SaveData.globalAntialiasing;
			case 'epiphany':
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				text.setFormat(LangUtil.getFont('aller'), 32, FlxColor.BLACK, FlxTextAlign.CENTER);
				text.antialiasing = SaveData.globalAntialiasing;
				box.animation.play('glitch');
				box.offset.set();
				box.antialiasing = SaveData.globalAntialiasing;
			case 'va11halla':
				text.setFormat('CyberpunkWaifus', 38, FlxColor.WHITE, FlxTextAlign.CENTER);
				text.antialiasing = false;
				box.animation.play('va11halla');
				box.offset.set(-71);
				box.antialiasing = false;
			case 'libitina':
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				text.setFormat(LangUtil.getFont('dos'), 32, FlxColor.WHITE, FlxTextAlign.CENTER);
				text.y += 20;
				text.antialiasing = false;
				box.animation.play('libitina');
				box.offset.set(-71);
				box.antialiasing = SaveData.globalAntialiasing;
		}

		text.text = popupText;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			popupData[popupID][1].remove(popupData[popupID][1][0]);

			if (popupData[popupID][1].length > 0)
			{
				updateBox();
			}
			else
			{
				Reflect.setProperty(SaveData, 'popup' + type, true);
				SaveData.save();

				#if FEATURE_GAMEJOLT
				gameJoltUnlock();
				#end

				switch (state)
				{
					case 'story':
					{
						DokiStoryState.showPopUp = false;
						DokiStoryState.instance.acceptInput = true;
					}
					case 'freeplay':
					{
						DokiFreeplayState.showPopUp = false;
						DokiFreeplayState.instance.acceptInput = true;
					}
				}

				if (!FlxG.sound.music.playing)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					Conductor.changeBPM(120);
				}

				close();
			}
		}
	}

	public static function checkStatus(data:String):Bool
	{
		return Reflect.getProperty(SaveData, 'popup' + data);
	}

	#if FEATURE_GAMEJOLT
	inline function gameJoltUnlock():Void
	{
		var trophyID:Null<Int> = null;

		switch (type.toLowerCase())
		{
			case 'prologue':
				trophyID = 0;
			case 'sayori':
				trophyID = 0;
			case 'natsuki':
				trophyID = 0;
			case 'yuri':
				trophyID = 0;
			case 'monika':
				trophyID = 0;
			case 'festival':
				trophyID = 0;
			case 'encore':
				trophyID = 0;
			case 'protag':
				trophyID = 0;
			case 'side':
				trophyID = 0;
			case 'epiphany':
				trophyID = 0;
		}

		if (trophyID != null)
			GameJoltAPI.getTrophy(trophyID);
	}
	#end
}
