package;

import haxe.Int64;

typedef Seed =
{
	var x:UInt;
	var y:UInt;
	var z:UInt;
	var w:UInt;
}

// I stole this from HAL Labs because its really really good
// With Firubii's permission I stole this from holofunk hueh
class Random
{
	public static var seed:Seed = {
		x: 0x159a55e5,
		y: 0x075bcd15,
		z: 0x5491333,
		w: 0x1f123bb5
	};

	/**
		Resets the seed based on the current time
	**/
	public static function resetSeed():Void
	{
		var ms = Int64.fromFloat(Date.now().getTime());
		seed.x = cast ms.high;
		seed.y = cast ms.low;
		seed.z = cast ms.high ^ 0x10D346D6;
		seed.w = cast ms.low ^ 0x1849F6A0;
	}

	/**
		Sets the seed to the default seed from Kirby Fighters 2
	**/
	public static function defaultSeed():Void
	{
		seed = {
			x: 0x159a55e5,
			y: 0x075bcd15,
			z: 0x5491333,
			w: 0x1f123bb5
		};
	}

	/**
		Advances the seed forward
	**/
	public static function advance():Void
	{
		var tempX:UInt = seed.x;
		tempX ^= tempX << 0xB;
		seed.x = seed.y;

		var tempW = seed.w;

		seed.y = seed.z;
		seed.z = tempW;
		seed.w = tempX ^ tempX >> 0x8 ^ tempW ^ tempW >> 0x13;
	}

	/**
		Advances the seed by the given amount of rolls
		@param amount The amount of rolls to perform
	**/
	public static function advanceCount(amount:Int):Void
	{
		for (i in 0...amount)
			advance();
	}

	/**
		Generates a random boolean
		@param rate The chance of generating `true`, from 0 to 1
	**/
	public static function randBool(rate:Float):Bool
	{
		if (rate == 0)
			return false;

		var tempX:UInt = seed.x;
		seed.x = seed.y;

		var tempW = seed.w;
		tempX ^= tempX << 0xB;
		var seedOut = tempX ^ tempX >> 0x8 ^ tempW ^ tempW >> 0x13;

		seed.y = seed.z;

		seed.z = tempW;
		seed.w = seedOut;

		// Debug.logTrace('[randBool] rate: $rate, output: ${(seedOut & 0xffff) * 0.00001526} (${(seedOut & 0xffff) * 0.00001526 <= rate})');
		return (seedOut & 0xffff) * 0.00001526 <= rate;
	}

	/**
		Generates a random signed 32-bit integer between 0 and a value
		@param limit The maximum value that should be returned
	**/
	public static function rand(limit:Int):Int
	{
		if (limit == 0)
			return 0;

		var tempX:UInt = seed.x;
		seed.x = seed.y;

		var tempW = seed.w;
		tempX ^= tempX << 0xB;
		var seedOut = tempX ^ tempX >> 0x8 ^ tempW ^ tempW >> 0x13;

		seed.w = seedOut;
		seedOut &= 0x7FFFFFFF;

		seed.y = seed.z;
		seed.z = tempW;

		var i:Int = 0;
		if (limit != 0)
			i = cast seedOut / limit;

		// Debug.logTrace('[rand] limit: $limit, output: ${seedOut - i * limit}');
		return seedOut - i * limit;
	}

	/**
		Generates a random signed 32-bit integer between two values
		@param min The minimum value that should be returned
		@param max The maximum value that should be returned
	**/
	public static function randInt(min:Int, max:Int):Int
	{
		if (min == max)
			return min;

		var tempX:UInt = seed.x;
		seed.x = seed.y;

		var tempW = seed.w;
		tempX ^= tempX << 0xB;
		var seedOut = tempX ^ tempX >> 0x8 ^ tempW ^ tempW >> 0x13;

		seed.y = seed.z;
		seed.z = tempW;

		max -= min;
		seedOut &= 0x7FFFFFFF;

		seed.w = seedOut;

		var i:Int = 0;
		if (max != 0)
			i = cast seedOut / max;

		// Debug.logTrace('[randInt] min: $min, max: $max, output: ${(seedOut - i * max) + min}');
		return (seedOut - i * max) + min;
	}

	/**
		Generates a random index into a table of weights
		@param weights The weights to randomize by
	**/
	public static function randWeighted(weights:Array<Int>):Int
	{
		var weightSum:Int = 0;
		for (i in 0...weights.length)
			weightSum += weights[i];

		var randWeight = rand(weightSum);
		for (i in 0...weights.length)
		{
			if (randWeight < weights[i])
				return i;
			randWeight -= weights[i];
		}

		return 0;
	}

	/**
		Generates a random unsigned 32-bit integer between two values
		@param min The minimum value that should be returned
		@param max The maximum value that should be returned
	**/
	public static function randUInt(min:UInt, max:UInt):UInt
	{
		if (min == max)
			return min;

		var tempX:UInt = seed.x;
		seed.x = seed.y;

		var tempW = seed.w;
		tempX ^= tempX << 0xB;
		var seedOut = tempX ^ tempX >> 0x8 ^ tempW ^ tempW >> 0x13;

		seed.y = seed.z;
		seed.z = tempW;

		max -= min;

		seed.w = seedOut;

		var i:Int = 0;
		if (max != 0)
			i = cast seedOut / max;

		// Debug.logTrace('[randUInt] min: $min, max: $max, output: ${(seedOut - i * max) + min}');
		return (seedOut - i * max) + min;
	}

	/**
		Generates a random float between two values
		@param min The minimum value that should be returned
		@param max The maximum value that should be returned
	**/
	public static function randF(min:Float, max:Float):Float
	{
		if (min == max)
			return min;

		var tempX:UInt = seed.x;
		seed.x = seed.y;

		var tempW = seed.w;
		tempX ^= tempX << 0xB;
		var seedOut = tempX ^ tempX >> 0x8 ^ tempW ^ tempW >> 0x13;

		seed.w = seedOut;
		seed.y = seed.z;
		seed.z = tempW;

		// Debug.logTrace('[randF] min: $min, max: $max, output: ${(max - min) * (seedOut & 0xFFFF) * 0.00001526 + min}');
		return (max - min) * (seedOut & 0xFFFF) * 0.00001526 + min;
	}

	/**
		Generates a random float between 0 and 1
	**/
	public static function randNF():Float
	{
		var tempX:UInt = seed.x;
		seed.x = seed.y;

		var tempW = seed.w;
		tempX ^= tempX << 0xB;
		var seedOut = tempX ^ tempX >> 0x8 ^ tempW ^ tempW >> 0x13;

		seed.w = seedOut;
		seed.y = seed.z;
		seed.z = tempW;

		// Debug.logTrace('[randNF] output: ${(seedOut & 0xFFFF) * 0.00001526}');
		return (seedOut & 0xFFFF) * 0.00001526;
	}

	/**
		Generates a random float
	**/
	public static function randAF():Float
	{
		var tempX:UInt = seed.x;
		seed.x = seed.y;

		var tempW = seed.w;
		tempX ^= tempX << 0xB;
		var seedOut = tempX ^ tempX >> 0x8 ^ tempW ^ tempW >> 0x13;

		seed.w = seedOut;
		seed.y = seed.z;
		seed.z = tempW;

		var f:Float = (seedOut & 0xffff) * 0.00001526;

		// Debug.logTrace('[randAF] output: ${f + f - 1}');
		return f + f - 1;
	}
}