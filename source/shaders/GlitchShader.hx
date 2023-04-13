package shaders;

import flixel.system.FlxAssets.FlxShader;
import lime.utils.Assets;
import haxe.Json;

typedef GlitchJSON =
{
	var presets:Array<Array<Float>>;
}

class GlitchShader extends FlxShader // https://www.shadertoy.com/view/XtyXzW
{
	// Linux crashes due to GL_NV_non_square_matrices
	// and I haven't found a way to set version to 130
	// (importing Eric's PR (openfl/openfl#2577) to this repo caused more errors)
	// So for now, Linux users will have to disable shaders specifically for Libitina.

	@:glFragmentSource('
	#extension GL_EXT_gpu_shader4 : enable
	#extension GL_NV_non_square_matrices : enable

	#pragma header

	vec2 uv = openfl_TextureCoordv.xy;
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
	vec2 iResolution = openfl_TextureSize;

	uniform float time;
	uniform float prob;
	uniform float intensityChromatic;
	const int sampleCount = 50;

	float _round(float n) {
		return floor(n + .5);
	}

	vec2 _round(vec2 n) {
		return floor(n + .5);
	}

	vec3 tex2D(sampler2D _tex,vec2 _p)
	{
		vec3 col=texture(_tex,_p).xyz;
		if(.5<abs(_p.x-.5)){
			col=vec3(.1);
		}
		return col;
	}

	#define PI 3.14159265359
	#define PHI (1.618033988749895)

	// --------------------------------------------------------
	// Glitch core
	// --------------------------------------------------------

	float rand(vec2 co){
		return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
	}

	const float glitchScale = .4;

	vec2 glitchCoord(vec2 p, vec2 gridSize) {
		vec2 coord = floor(p / gridSize) * gridSize;;
		coord += (gridSize / 2.);
		return coord;
	}

	struct GlitchSeed {
		vec2 seed;
		float prob;
	};

	float fBox2d(vec2 p, vec2 b) {
	vec2 d = abs(p) - b;
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
	}

	GlitchSeed glitchSeed(vec2 p, float speed) {
		float seedTime = floor(time * speed);
		vec2 seed = vec2(
			1. + mod(seedTime / 100., 100.),
			1. + mod(seedTime, 100.)
		) / 100.;
		seed += p;
		return GlitchSeed(seed, prob);
	}

	float shouldApply(GlitchSeed seed) {
		return round(
			mix(
				mix(rand(seed.seed), 1., seed.prob - .5),
				0.,
				(1. - seed.prob) * .5
			)
		);
	}

	// gamma again
	const float GAMMA = 1.0;

	vec3 gamma(vec3 color, float g) {
		return pow(color, vec3(g));
	}

	vec3 linearToScreen(vec3 linearRGB) {
		return gamma(linearRGB, 1.0 / GAMMA);
	}

	// --------------------------------------------------------
	// Glitch effects
	// --------------------------------------------------------

	// Swap

	vec4 swapCoords(vec2 seed, vec2 groupSize, vec2 subGrid, vec2 blockSize) {
		vec2 rand2 = vec2(rand(seed), rand(seed+.1));
		vec2 range = subGrid - (blockSize - 1.);
		vec2 coord = floor(rand2 * range) / subGrid;
		vec2 bottomLeft = coord * groupSize;
		vec2 realBlockSize = (groupSize / subGrid) * blockSize;
		vec2 topRight = bottomLeft + realBlockSize;
		topRight -= groupSize / 2.;
		bottomLeft -= groupSize / 2.;
		return vec4(bottomLeft, topRight);
	}

	float isInBlock(vec2 pos, vec4 block) {
		vec2 a = sign(pos - block.xy);
		vec2 b = sign(block.zw - pos);
		return min(sign(a.x + a.y + b.x + b.y - 3.), 0.);
	}

	vec2 moveDiff(vec2 pos, vec4 swapA, vec4 swapB) {
		vec2 diff = swapB.xy - swapA.xy;
		return diff * isInBlock(pos, swapA);
	}

	void swapBlocks(inout vec2 xy, vec2 groupSize, vec2 subGrid, vec2 blockSize, vec2 seed, float apply) {

		vec2 groupOffset = glitchCoord(xy, groupSize);
		vec2 pos = xy - groupOffset;

		vec2 seedA = seed * groupOffset;
		vec2 seedB = seed * (groupOffset + .1);

		vec4 swapA = swapCoords(seedA, groupSize, subGrid, blockSize);
		vec4 swapB = swapCoords(seedB, groupSize, subGrid, blockSize);

		vec2 newPos = pos;
		newPos += moveDiff(pos, swapA, swapB) * apply;
		newPos += moveDiff(pos, swapB, swapA) * apply;
		pos = newPos;

		xy = pos + groupOffset;
	}


	// Static

	void staticNoise(inout vec2 p, vec2 groupSize, float grainSize, float contrast) {
		GlitchSeed seedA = glitchSeed(glitchCoord(p, groupSize), 5.);
		seedA.prob *= .5;
		if (shouldApply(seedA) == 1.) {
			GlitchSeed seedB = glitchSeed(glitchCoord(p, vec2(grainSize)), 5.);
			vec2 offset = vec2(rand(seedB.seed), rand(seedB.seed + .1));
			offset = round(offset * 2. - 1.);
			offset *= contrast;
			p += offset;
		}
	}


	// Freeze time

	void freezeTime(vec2 p, inout float time, vec2 groupSize, float speed) {
		GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
		//seed.prob *= .5;
		if (shouldApply(seed) == 1.) {
			float frozenTime = floor(time * speed) / speed;
			time = frozenTime;
		}
	}


	// --------------------------------------------------------
	// Glitch compositions
	// --------------------------------------------------------

	void glitchSwap(inout vec2 p) {

		vec2 pp = p;

		float scale = glitchScale;
		float speed = 5.;

		vec2 groupSize;
		vec2 subGrid;
		vec2 blockSize;
		GlitchSeed seed;
		float apply;

		groupSize = vec2(.6) * scale;
		subGrid = vec2(2);
		blockSize = vec2(1);

		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		apply = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

		groupSize = vec2(.8) * scale;
		subGrid = vec2(3);
		blockSize = vec2(1);

		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		apply = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

		groupSize = vec2(.2) * scale;
		subGrid = vec2(6);
		blockSize = vec2(1);

		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		float apply2 = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 1.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 2.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 3.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 4.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 5.), apply * apply2);

		groupSize = vec2(1.2, .2) * scale;
		subGrid = vec2(9,2);
		blockSize = vec2(3,1);

		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		apply = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);
	}

	void glitchStatic(inout vec2 p) {
		staticNoise(p, vec2(.5, .25/2.) * glitchScale, .2 * glitchScale, 2.);
	}

	void glitchTime(vec2 p, inout float time) {
	freezeTime(p, time, vec2(.5) * glitchScale, 2.);
	}

	void glitchColor(vec2 p, inout vec3 color) {
		vec2 groupSize = vec2(.75,.125) * glitchScale;
		vec2 subGrid = vec2(0,6);
		float speed = 5.;
		GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
		seed.prob *= .3;
		if (shouldApply(seed) == 1.)
			color = vec3(0, 0, 0);
	}

	vec4 transverseChromatic(vec2 p) {
		vec2 destCoord = p;
		vec2 direction = normalize(destCoord - 0.5);
		vec2 velocity = direction * intensityChromatic * pow(length(destCoord - 0.5), 3.0);
		float inverseSampleCount = 1.0 / float(sampleCount);

		mat3x2 increments = mat3x2(velocity * 1.0 * inverseSampleCount, velocity * 2.0 * inverseSampleCount, velocity * 4.0 * inverseSampleCount);

		vec3 accumulator = vec3(0);
		mat3x2 offsets = mat3x2(0);
		for (int i = 0; i < sampleCount; i++) {
			accumulator.r += texture(bitmap, destCoord + offsets[0]).r;
			accumulator.g += texture(bitmap, destCoord + offsets[1]).g;
			accumulator.b += texture(bitmap, destCoord + offsets[2]).b;
			offsets -= increments;
		}
		vec4 newColor = vec4(accumulator / float(sampleCount), 1.0);
		return newColor;
	}

	void main() {
		// time = mod(time, 1.);
		vec2 uv = fragCoord/iResolution.xy;
		float alpha = texture(bitmap, uv).a;
		vec2 p = openfl_TextureCoordv.xy;
		vec3 color = texture2D(bitmap, p).rgb;

		glitchSwap(p);
		// glitchTime(p, time);
		glitchStatic(p);

		color = transverseChromatic(p).rgb;
		glitchColor(p, color);
		// color = linearToScreen(color);

	    gl_FragColor = vec4(color.r * alpha, color.g * alpha, color.b * alpha, alpha);
	}
	')

	var json:GlitchJSON = null;
	public var preset(default, set):Int = 0;

	function set_preset(value:Int):Int
	{
		var presetData:Array<Float> = json.presets[value];
		data.prob.value = [0.25 - (presetData[0] / 8)];
		data.intensityChromatic.value = [presetData[1]];
		return value;
	}

	public function new(preset:Int = 0)
	{
		super();

		var jsonTxt:String = Assets.getText(Paths.json('shader/glitch'));
		json = cast Json.parse(jsonTxt);

		data.time.value = [0];
		this.preset = preset;
	}
}
