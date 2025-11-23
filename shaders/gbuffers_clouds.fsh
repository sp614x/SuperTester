#version 120

#include "/gbuffers_config.glsl"
#define PROGRAM_COLOR vec3(1.0, 1.0, 0.0)

varying vec4 glcolor;
varying vec3 glvertex;

#if MC_VERSION < 12102
uniform sampler2D texture;

varying vec2 texcoord;
varying vec3 normal;
varying vec3 rotatedNormal;
#endif

void main() {

	#if MC_VERSION < 12102
		vec4 color = texture2D(texture, texcoord) * glcolor;
	#else
		vec4 color = glcolor;
	#endif
		
	#if MC_VERSION < 12102
		#if GBUFFER_DEBUG == PROGRAM_ID
			vec3 debug = PROGRAM_COLOR;
			#include "/apply_debug.glsl"
		#endif
		#if GBUFFER_DEBUG == GLX_NORMAL
			vec3 debug = normal * 0.5 + 0.5;
			#include "/apply_debug.glsl"
		#endif
		#if GBUFFER_DEBUG == GLX_NORMALMATRIX
			vec3 debug = rotatedNormal * 0.5 + 0.5;
			#include "/apply_debug.glsl"
		#endif
		#if GBUFFER_DEBUG == GLX_COLOR
			vec3 debug = glcolor.rgb;
			#include "/apply_debug.glsl"
		#endif
		#if GBUFFER_DEBUG == GLX_VERTEX
			vec3 debug = glvertex / 16.0;
			#include "/apply_debug.glsl"
		#endif
	#endif

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}