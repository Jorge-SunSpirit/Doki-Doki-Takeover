package;

import flixel.FlxG;

// for reference: https://www.techonthenet.com/js/language_tags.php
class LangUtil
{
	public static var localeList:Array<String>;

	public static function getFont(type:String = 'vcr'):String
	{
		var font:String = '';

		switch (type.toLowerCase())
		{
			case 'aller':
				switch (FlxG.save.data.language)
				{
					case 'ru-RU':
						font = 'Ubuntu Bold';
					default:
						font = 'Aller';
				}
			case 'riffic':
				switch (FlxG.save.data.language)
				{
					case 'ru-RU':
						font = 'Ubuntu Bold';
					default:
						font = 'Riffic Free Bold';
				}
			case 'pixel':
				switch (FlxG.save.data.language)
				{
					default:
						font = 'LanaPixel';
				}
			default:
				switch (FlxG.save.data.language)
				{
					case 'ru-RU':
						font = 'Ubuntu Bold';
					default:
						font = 'VCR OSD Mono';
				}
		}

		return font;
	}

	public static function getString(identifier:String):String
	{
		var string:String = '';

		for (i in 0...localeList.length)
		{
			var data:Array<String> = localeList[i].split('::');

			if (data[0] != identifier)
				continue;
			else
				string = data[1];
		}

		if (string == '')
			return identifier;
		else
			return string;
	}
}
