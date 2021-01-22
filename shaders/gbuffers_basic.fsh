#version 120

#include "/gbuffers_config.glsl"
#define PROGRAM_COLOR vec3(0.5, 0.0, 0.0)

varying vec4 glcolor;

void main() {
	vec4 color = glcolor;

	#if GBUFFER_DEBUG == PROGRAM_ID
		vec3 debug = PROGRAM_COLOR;
		#include "/apply_debug.glsl"
	#endif

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}