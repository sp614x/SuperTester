#version 120
#extension GL_EXT_gpu_shader4 : enable

#include "/gbuffers_config.glsl"
#define SHADOW_BIAS 0.00010 //Increase this if you get shadow acne. Decrease this if you get peter panning. [0.00000 0.00001 0.00002 0.00003 0.00004 0.00005 0.00006 0.00007 0.00008 0.00009 0.00010 0.00012 0.00014 0.00016 0.00018 0.00020 0.00022 0.00024 0.00026 0.00028 0.00030 0.00035 0.00040 0.00045 0.00050]
#define PROGRAM_COLOR vec3(1.0, 0.0, 1.0)
#define ID_GETTER mcentity;

uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D texture;
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;
uniform vec3 shadowLightPosition;

varying float mcentity;

varying vec2 lmcoord;
varying vec2 midcoord;
varying vec2 texcoord;

varying vec3 normal;
varying vec3 rotatedNormal;
varying vec3 tangent;
varying vec3 tangentMatrix;

varying vec3 glvertex;
varying vec3 playerPos;
varying vec3 shadowSamplePos;
varying vec3 shadowViewPos;
varying vec3 viewPos;
varying vec3 worldPos;

varying vec4 glcolor;

const float shadowDistance = 32.0; //Distance to draw shadows [16.0 32.0 64.0 128.0 256.0]
const int shadowMapResolution = 2048; //Resolution of the shadow map [256 512 1024 2048 4096 8192]
const float sunPathRotation = 0.0; //Changes the path of the sun overhead [-45.0 -40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -5.0 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0]

void main() {
	#include "/gbuffers_common.glsl"

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}