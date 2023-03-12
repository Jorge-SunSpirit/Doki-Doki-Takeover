package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;

class MetadataDisplay extends FlxSpriteGroup
{
    var metaName:FlxText;
    var metaIcon:HealthIcon;
    var metaArtist:FlxText;
    var isPixel:Bool = false; // This is easier to call than PlayState.isPixelUI
    public function new(songName:String = '', songIcon:String = '', songArtist:String = '')
    {
        super();

        isPixel = PlayState.isPixelUI;

        // Set up song name
        metaName = new FlxText(20, 15, 0, "", 36);
		metaName.setFormat(isPixel ? LangUtil.getFont('vcr') : LangUtil.getFont('riffic'), 36, 
            FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        metaName.text = songName;
        metaName.updateHitbox();
        metaName.scrollFactor.set();
        metaName.alpha = 0;
        if (SaveData.globalAntialiasing)
            metaName.antialiasing = !isPixel;
        metaName.x = FlxG.width - (metaName.width + 20);
        metaName.y += (isPixel ? LangUtil.getFontOffset('vcr') : LangUtil.getFontOffset('riffic'));

        // Set up icon
        metaIcon = new HealthIcon(songIcon, false, false);
        metaIcon.scale.set(0.35, 0.35);
        metaIcon.setPosition(FlxG.width - (metaName.width) - 120, 15 - (metaIcon.height / 2) + 16);
        metaIcon.alpha = 0;

        // Set up artist(s)
        metaArtist = new FlxText(38, 38, 0, "", 20);
        metaArtist.setFormat(isPixel ? LangUtil.getFont('vcr') : LangUtil.getFont('aller'), 20,
		    FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        metaArtist.text = songArtist;
        metaArtist.updateHitbox();
        metaArtist.scrollFactor.set();
        metaArtist.alpha = 0;
        if (SaveData.globalAntialiasing)
            metaArtist.antialiasing = !isPixel;
        metaArtist.setPosition(FlxG.width - (metaArtist.width + 20), 
            metaArtist.y + (isPixel ? LangUtil.getFontOffset('vcr') : LangUtil.getFontOffset('aller')));
        
        // Finally, add them into this sprite group
        add(metaName);
		add(metaIcon);
        add(metaArtist);
    }

    public function tweenIn()
    {
        // Move them into the display
		FlxTween.tween(metaName, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(metaIcon, {alpha: 1, y: 20 - (metaIcon.height / 2) + 16}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(metaArtist, {alpha: 1, y: 58}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.4});
    }

    public function tweenOut()
    {
        // Move them out from display
		FlxTween.tween(metaName, {alpha: 0, y: 0}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(metaIcon, {alpha: 0, y: 0 - (metaIcon.height / 2) + 16}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(metaArtist, {alpha: 0, y: 38}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
    }
}