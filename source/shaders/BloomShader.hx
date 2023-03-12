package shaders;

import flixel.system.FlxAssets.FlxShader;

class BloomShader extends FlxShader // Taken from BBPanzu anime mod hueh
{
	@:glFragmentSource('
	#pragma header
	vec2 uv = openfl_TextureCoordv.xy;
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
	vec2 iResolution = openfl_TextureSize;
    
    uniform float funrange;
    uniform float funsteps;
    uniform float funthreshhold;
    uniform float funbrightness;

	uniform float iTime;
	#define iChannel0 bitmap
	#define texture flixel_texture2D
	#define fragColor gl_FragColor
	#define mainImage main

	void mainImage() {

    vec2 uv = fragCoord / iResolution.xy;
    fragColor = texture(iChannel0, uv);
    
    for (float i = -funrange; i < funrange; i += funsteps) {
    
        float falloff = 1.0 - abs(i / funrange);
    
        vec4 blur = texture(iChannel0, uv + i);
        if (blur.r + blur.g + blur.b > funthreshhold * 3.0) {
            fragColor += blur * falloff * funsteps * funbrightness;
        }
        
        blur = texture(iChannel0, uv + vec2(i, -i));
        if (blur.r + blur.g + blur.b > funthreshhold * 3.0) {
            fragColor += blur * falloff * funsteps * funbrightness;
        }
    }
}
	')

	public function new(range:Float = 0.1, steps:Float = 0.005, threshhold:Float = 0.8, brightness:Float = 7.0)
	{
		super();

		data.funrange.value = [range];
		data.funsteps.value = [steps];
		data.funthreshhold.value = [threshhold];
		data.funbrightness.value = [brightness];
	}
}
