#version 120

#define NOTHING 0
#define SUN_POSITION 1
#define MOON_POSITION 2
#define UP_POSITION 3
#define VIEW_POS 4
#define PLAYER_POS 5
#define PROGRAM_ID 6
#define SKYBASIC_DEBUG NOTHING //What to draw in gbuffers_skybasic. For CONSTANT, see the key in the zip file. [NOTHING SUN_POSITION MOON_POSITION UP_POSITION VIEW_POS PLAYER_POS PROGRAM_ID]
#define COLOR_WEIGHT 0.75 //Mix level which combines the grayscale texture with the thing being debugged [0.0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]

#define PROGRAM_COLOR vec3(0.0, 0.5, 0.0)

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 upPosition;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
}

void main() {
	vec4 tmp = gbufferProjectionInverse * vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
	vec3 viewPos = normalize(tmp.xyz);

	vec3 color = starData.a > 0.5 ? starData.rgb : calcSkyColor(viewPos);
	vec3 debug;

	#if SKYBASIC_DEBUG == NOTHING
		debug = color;
	#elif SKYBASIC_DEBUG == SUN_POSITION
		debug = vec3(fract(log2(dot(viewPos, normalize(sunPosition)) * -0.5 + 0.5)));
	#elif SKYBASIC_DEBUG == MOON_POSITION
		debug = vec3(fract(log2(dot(viewPos, normalize(moonPosition)) * -0.5 + 0.5)));
	#elif SKYBASIC_DEBUG == UP_POSITION
		debug = vec3(fract(log2(dot(viewPos, normalize(upPosition)) * -0.5 + 0.5)));
	#elif SKYBASIC_DEBUG == VIEW_POS
		viewPos = abs(viewPos);
		debug = viewPos / (viewPos.x + viewPos.y + viewPos.z);
	#elif SKYBASIC_DEBUG == PLAYER_POS
		vec3 playerPos = mat3(gbufferModelViewInverse) * viewPos;
		playerPos = abs(playerPos);
		debug = playerPos / (playerPos.x + playerPos.y + playerPos.z);
	#elif SKYBASIC_DEBUG == PROGRAM_ID
		debug = PROGRAM_COLOR;
	#endif

	//don't include because apply_debug assumes alpha exists, which it doesn't here.
	#if SKYBASIC_DEBUG != NOTHING
		float grayscale = dot(color, vec3(0.25, 0.5, 0.25));
		color = mix(vec3(grayscale), debug, COLOR_WEIGHT);
	#endif

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}