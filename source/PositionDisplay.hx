package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxStringUtil;

class PositionDisplay extends FlxSpriteGroup
{
	public var songPosBG:FlxSprite;
	public var songPosBar:FlxBar;
	public var songText:FlxText;
	public var songPositionBar:Float = 0;

	private var isPixel:Bool = false; // This is easier to call than PlayState.isPixelUI
	private var songLength:Float = 0;

	public function new(songName:String = '', boyfriend:Character, dad:Character, songLength:Float)
	{
		super();

		isPixel = PlayState.isPixelUI;
		this.songLength = songLength;

		songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('timeBar'));
		if (SaveData.downScroll)
			songPosBG.y = FlxG.height * 0.9 + 40;
		songPosBG.screenCenter(X);
		songPosBG.scrollFactor.set();
		songPosBG.alpha = 0;

		songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
			'songPositionBar', 0, songLength);
		songPosBar.scrollFactor.set();
		songPosBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		songPosBar.createGradientBar([FlxColor.TRANSPARENT], [boyfriend.barColor, dad.barColor]);
		songPosBar.alpha = 0;

		songText = new FlxText(songPosBG.x + (songPosBG.width / 2) - (songName.length * 5), songPosBG.y, 400, songName, 18);
		songText.setFormat(LangUtil.getFont(), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songText.text = songName
			+ (Conductor.playbackSpeed != 1 ? ' (${Conductor.playbackSpeed}x)' : '')
			+ ' ('
			+ FlxStringUtil.formatTime(songLength / Conductor.playbackSpeed)
			+ ')';
		songText.screenCenter(X);
		songText.y += LangUtil.getFontOffset();
		songText.scrollFactor.set();
		songText.alpha = 0;

		if (SaveData.globalAntialiasing)
			songText.antialiasing = !isPixel;

		if (isPixel)
			songText.font = LangUtil.getFont('vcr');

		add(songPosBG);
		add(songPosBar);
		add(songText);
	}

	public function tweenIn(length:Float = 0.5)
	{
		FlxTween.tween(songPosBG, {alpha: 1}, length, {ease: FlxEase.circOut});
		FlxTween.tween(songPosBar, {alpha: 1}, length, {ease: FlxEase.circOut});
		FlxTween.tween(songText, {alpha: 1}, length, {ease: FlxEase.circOut});
	}

	public function tweenOut(length:Float = 0.5)
	{
		FlxTween.tween(songPosBG, {alpha: 0}, length, {ease: FlxEase.circOut});
		FlxTween.tween(songPosBar, {alpha: 0}, length, {ease: FlxEase.circOut});
		FlxTween.tween(songText, {alpha: 0}, length, {ease: FlxEase.circOut});
	}
}