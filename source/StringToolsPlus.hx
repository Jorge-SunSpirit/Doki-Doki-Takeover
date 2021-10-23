package;

using StringTools;

class StringToolsPlus
{
	// https://api.haxe.org/StringTools.html
	public static function replaceArray(s:String, sub:Array<String>, by:Array<String>):String
	{
		var sData:String = s;
		var subData:Array<String> = sub;
		var byData:Array<String> = by;

		for (i in 0...subData.length)
		{
			sData = StringTools.replace(sData, subData[i], byData[i]);
		}
		
		return sData;
	}
}
