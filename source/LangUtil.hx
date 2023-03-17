package;

import firetongue.Replace;

using StringTools;

// for reference: https://www.techonthenet.com/js/language_tags.php
class LangUtil
{
	public static function getFont(type:String = 'aller'):String
	{
		var font:String = '';

		switch (type.toLowerCase())
		{
			default: // aller
				switch (SaveData.language)
				{
					case 'ru-RU':
						font = 'Ubuntu Bold';
					case 'jp-JP':
						font = 'Noto Sans JP Medium';
					default:
						font = 'Aller';
				}
			case 'riffic':
				switch (SaveData.language)
				{
					case 'ru-RU':
						font = 'Ubuntu Bold';
					case 'jp-JP':
						font = 'Noto Sans JP Medium';
					default:
						font = 'Riffic Free Bold';
				}
			case 'halogen':
				switch (SaveData.language)
				{
					case 'ru-RU':
						font = 'Ubuntu Bold';
					case 'jp-JP':
						font = 'Noto Sans JP Medium';
					default:
						font = 'Halogen';
				}
			case 'grotesk':
				switch (SaveData.language)
				{
					case 'ru-RU':
						font = 'Ubuntu Bold';
					case 'jp-JP':
						font = 'Noto Sans JP Medium';
					default:
						font = 'HK Grotesk Bold';
				}
			case 'pixel':
				switch (SaveData.language)
				{
					default:
						font = 'LanaPixel';
				}
			case 'dos':
				switch (SaveData.language)
				{
					case 'ru-RU':
						font = 'Ubuntu Bold';
					case 'jp-JP':
						font = 'Noto Sans JP Medium';
					default:
						font = 'Perfect DOS VGA 437 Win';
				}
			case 'vcr':
				switch (SaveData.language)
				{
					case 'ru-RU':
						font = 'Ubuntu Bold';
					case 'jp-JP':
						font = 'Noto Sans JP Medium';
					default:
						font = 'VCR OSD Mono';
				}
			case 'waifu':
				switch (SaveData.language)
				{
					case 'en-US':
						font = 'CyberpunkWaifus';
					default:
						font = 'LanaPixel';
				}
		}

		return font;
	}

	public static function getFontOffset(type:String = 'aller'):Float
	{
		var offset:Float = 0;

		switch (type.toLowerCase())
		{
			default:
				switch (SaveData.language)
				{
					case 'ru-RU':
						offset = -2;
					case 'jp-JP':
						offset = -5;
				}
			case 'pixel' | 'waifu':
				// none because fallbacks use LanaPixel
		}

		return offset;
	}

	public static function getString(flag:String, context:String = 'data', ?replace:Dynamic):String
	{
		var str:String = Main.tongue.get(flag, context);

		if (replace != null)
			str = Replace.flags(str, ["<X>"], [Std.string(replace)]);

		return str;
	}
}
