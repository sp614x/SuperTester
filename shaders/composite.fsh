#version 120

#define NOTHING 0
#define DEPTHTEX0 1
#define DEPTHTEX1 2
#define DEPTHTEX2 3
#define SHADOWTEX0 4
#define SHADOWTEX1 5
#define SHADOWCOLOR0 6
#define SHADOWCOLOR1 7
#define COMPOSITE_DEBUG NOTHING //What to draw in deferred [NOTHING DEPTHTEX0 DEPTHTEX1 DEPTHTEX2 SHADOWTEX0 SHADOWTEX1 SHADOWCOLOR0 SHADOWCOLOR1]

uniform float far;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D gcolor;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

varying vec2 texcoord;

float getDepth(sampler2D sampler) {
	return texture2D(sampler, texcoord).r;
}

float getDist(sampler2D sampler) {
	vec3 pos = vec3(texcoord, getDepth(sampler));
	vec4 tmp = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
	pos = tmp.xyz / tmp.w;
	return length(pos) / far;
}

void main() {
	vec3 color;
	
	#if COMPOSITE_DEBUG == NOTHING
		color = texture2D(gcolor, texcoord).rgb;
	#elif COMPOSITE_DEBUG == DEPTHTEX0
		color = vec3(getDist(depthtex0));
	#elif COMPOSITE_DEBUG == DEPTHTEX1
		color = vec3(getDist(depthtex1));
	#elif COMPOSITE_DEBUG == DEPTHTEX2
		color = vec3(getDist(depthtex2));
	#elif COMPOSITE_DEBUG == SHADOWTEX0
		color = vec3(getDepth(shadowtex0));
	#elif COMPOSITE_DEBUG == SHADOWTEX1
		color = vec3(getDepth(shadowtex1));
	#elif COMPOSITE_DEBUG == SHADOWCOLOR0
		color = texture2D(shadowcolor0, texcoord).rgb;
	#elif COMPOSITE_DEBUG == SHADOWCOLOR1
		color = texture2D(shadowcolor1, texcoord).rgb;
	#endif

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}