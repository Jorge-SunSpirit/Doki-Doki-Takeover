package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class ColorMaskShader extends FlxShader
{
	@:glFragmentSource('
	#pragma header

	uniform vec3 color1;
	uniform vec3 color2;

	void main()
	{
		vec4 texture = flixel_texture2D(bitmap, openfl_TextureCoordv.xy) / openfl_Alphav;
		float alpha = texture.g * openfl_Alphav;

		vec3 color1 = color1;
		vec3 color2 = color2;

		gl_FragColor = vec4(mix(color1, color2, vec3(texture.r)) * alpha, alpha);
	}
	')

	public function new(color1:FlxColor = FlxColor.RED, color2:FlxColor = FlxColor.BLUE)
	{
		super();
		updateColors(color1, color2);
	}

	public function updateColors(color1:FlxColor, color2:FlxColor)
	{
		data.color1.value = [color1.redFloat, color1.greenFloat, color1.blueFloat];
		data.color2.value = [color2.redFloat, color2.greenFloat, color2.blueFloat];
	}
}

class ColorMask
{
	public var shader(default, null):ColorMaskShader = new ColorMaskShader();
	public var color1(default, set):FlxColor = FlxColor.RED;
	public var color2(default, set):FlxColor = FlxColor.BLUE;

	private function set_color1(value:FlxColor)
	{
		color1 = value;
		shader.color1.value = [color1.redFloat, color1.greenFloat, color1.blueFloat];
		return color1;
	}

	private function set_color2(value:FlxColor)
	{
		color2 = value;
		shader.color2.value = [color2.redFloat, color2.greenFloat, color2.blueFloat];
		return color2;
	}

	public function new(color1:FlxColor = FlxColor.RED, color2:FlxColor = FlxColor.BLUE)
	{
		this.color1 = color1;
		this.color2 = color2;
	}
}
