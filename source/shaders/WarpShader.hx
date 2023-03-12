package shaders;

import flixel.system.FlxAssets.FlxShader;

class WarpShader extends FlxShader // modified from https://www.shadertoy.com/view/wlScRz
{
	@:glFragmentSource('
	#pragma header
	uniform float iTime;

	float transformStrength = 0.4;

	vec4 perm(vec4 x)
	{
		x = ((x * 34.0) + 1.0) * x;
		return x - floor(x * (1.0 / 289.0)) * 289.0;
	}

	float noise2d(vec2 p)
	{
		vec2 a = floor(p);
		vec2 d = p - a;
		d = d * d * (3.0 - 2.0 * d);

		vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
		vec4 k1 = perm(b.xyxy);
		vec4 k2 = perm(k1.xyxy + b.zzww);

		vec4 c = k2 + a.yyyy;
		vec4 k3 = perm(c);
		vec4 k4 = perm(c + 1.0);

		vec4 o1 = fract(k3 * 0.0244);
		vec4 o2 = fract(k4 * 0.0244);

		vec4 o3 = o2 * d.y + o1 * (1.0 - d.y);
		vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

		return o4.y * d.y + o4.x * (1.0 - d.y);
	}

	void main()
	{
		vec2 uv = openfl_TextureCoordv.xy;

		uv.x -= 0.05;
		uv.y -= 0.05;

		float v1 = noise2d(vec2(uv * transformStrength - iTime));
		float v2 = noise2d(vec2(uv * transformStrength + iTime));

		gl_FragColor = flixel_texture2D(bitmap, uv + vec2(v1, v2) * 0.1);
	}
	')

	public function new()
	{
		super();
	}
}
