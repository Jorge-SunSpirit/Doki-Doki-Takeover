package;

import flixel.FlxG;

class LangUtil
{
	public static function getFont(type:String):String
	{
		var font:String = '';

		switch (type.toLowerCase())
		{
			case 'aller':
				switch (FlxG.save.data.language)
				{
					case 'es-US':
						font = 'VCR OSD Mono';
					default:
						font = 'Aller';
				}
			case 'riffic':
				switch (FlxG.save.data.language)
				{
					case 'es-US':
						font = 'VCR OSD Mono';
					default:
						font = 'Riffic Free Bold';
				}
			case 'pixel':
				switch (FlxG.save.data.language)
				{
					case 'es-US':
						font = 'VCR OSD Mono';
					default:
						font = 'Pixel Arial 11 Bold';
				}
			default:
				font = 'VCR OSD Mono';
		}
		
		return font;
	}
}
