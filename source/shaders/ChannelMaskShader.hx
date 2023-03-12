package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class ChannelMaskShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header

	uniform vec3 rCol;
	uniform vec3 gCol;
	uniform vec3 bCol;

	void main()
	{
		vec4 texture = flixel_texture2D(bitmap, openfl_TextureCoordv.xy) / openfl_Alphav;
		float alpha = texture.a * openfl_Alphav;

		vec3 rCol = rCol;
		vec3 gCol = gCol;
		vec3 bCol = bCol;

		vec3 red = mix(vec3(0.0), rCol, texture.r);
		vec3 green = mix(vec3(0.0), gCol, texture.g);
		vec3 blue = mix(vec3(0.0), bCol, texture.b);
		vec3 color = red + green + blue;

		gl_FragColor = vec4(color * openfl_Alphav, alpha);
	}
	')

	public function new(rCol:FlxColor = FlxColor.RED, gCol:FlxColor = FlxColor.GREEN, bCol:FlxColor = FlxColor.BLUE)
	{
		super();
		updateColors(rCol, gCol, bCol);
	}

	public function updateColors(rCol:FlxColor, gCol:FlxColor, bCol:FlxColor)
	{
		data.rCol.value = [rCol.redFloat, rCol.greenFloat, rCol.blueFloat];
		data.gCol.value = [gCol.redFloat, gCol.greenFloat, gCol.blueFloat];
		data.bCol.value = [bCol.redFloat, bCol.greenFloat, bCol.blueFloat];
	}
}

class ChannelMask
{
	public var shader(default, null):ChannelMaskShader = new ChannelMaskShader();
	public var rCol(default, set):FlxColor = FlxColor.RED;
	public var gCol(default, set):FlxColor = FlxColor.GREEN;
	public var bCol(default, set):FlxColor = FlxColor.BLUE;

	private function set_rCol(value:FlxColor)
	{
		rCol = value;
		shader.rCol.value = [rCol.redFloat, rCol.greenFloat, rCol.blueFloat];
		return rCol;
	}

	private function set_gCol(value:FlxColor)
	{
		gCol = value;
		shader.gCol.value = [gCol.redFloat, gCol.greenFloat, gCol.blueFloat];
		return gCol;
	}

	private function set_bCol(value:FlxColor)
	{
		bCol = value;
		shader.bCol.value = [bCol.redFloat, bCol.greenFloat, bCol.blueFloat];
		return bCol;
	}

	public function new(rCol:FlxColor = FlxColor.RED, gCol:FlxColor = FlxColor.GREEN, bCol:FlxColor = FlxColor.BLUE)
	{
		this.rCol = rCol;
		this.gCol = gCol;
		this.bCol = bCol;
	}
}
