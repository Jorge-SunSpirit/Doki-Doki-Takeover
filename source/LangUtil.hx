package;

import flixel.FlxG;

class LangUtil
{
	public static function getFont(?type:String):String
	{
		var font:String = '';

		switch (type.toLowerCase())
		{
			case 'aller':
				switch (FlxG.save.data.language)
				{
					default:
						font = 'Aller';
				}
			case 'riffic':
				switch (FlxG.save.data.language)
				{
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
				switch (FlxG.save.data.language)
				{
					default:
						font = 'VCR OSD Mono';
				}
		}
		
		return font;
	}

	public static function getString(identifier:String):String
		{
			var localeList:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/textData', 'preload', true));

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
