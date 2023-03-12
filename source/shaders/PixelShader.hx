package shaders;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.utils.Assets;
import flixel.FlxG;
import openfl.Lib;

class PixelShader extends FlxShader // https://www.shadertoy.com/view/4l2fDz
{
  public var upFloat:Float = 0.0;
  @:glFragmentSource('
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    uniform float iTime;
    uniform float strength;
    #define iChannel0 bitmap
    #define texture flixel_texture2D
    #define fragColor gl_FragColor
    #define mainImage main

    void mainImage()
    {
        vec2 pixel_count = max(floor(iResolution.xy * vec2((cos(strength) + 1.0) / 2.0)), 1.0);
        vec2 pixel_size = iResolution.xy / pixel_count;
        vec2 pixel = (pixel_size * floor(fragCoord / pixel_size)) + (pixel_size / 1.0);
        vec2 uv = pixel.xy / iResolution.xy;
    
        
        fragColor = vec4(texture(iChannel0, uv).xyz, 1.0);
    }
    ')
  public function new()
  {
		data.strength.value = upFloat;//Max is 2.7
    super();
  }
}//haMBURGERCHEESBEUBRGER!!!!!!!!
