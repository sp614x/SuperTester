#version 120

#define NOTHING 0
#define DEPTHTEX0 1
#define DEPTHTEX1 2
#define DEPTHTEX2 3
#define SHADOWTEX0 4
#define SHADOWTEX1 5
#define SHADOWCOLOR0 6
#define SHADOWCOLOR1 7
#define LIGHTMAP 8
#define TEXTURE_ATLAS 9
#define NORMALS_ATLAS 10
#define SPECULAR_ATLAS 11
#define UNIFORMS 12
#define COMPOSITE_DEBUG NOTHING //What to draw in deferred [NOTHING DEPTHTEX0 DEPTHTEX1 DEPTHTEX2 SHADOWTEX0 SHADOWTEX1 SHADOWCOLOR0 SHADOWCOLOR1 LIGHTMAP TEXTURE_ATLAS NORMALS_ATLAS SPECULAR_ATLAS UNIFORMS]

uniform float far;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D gcolor;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowcolor1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D colortex1;

uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform vec3 shadowLightPosition;
uniform vec3 upPosition;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferPreviousProjection;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform mat4 projectionMatrix;
uniform mat4 projectionMatrixInverse;

varying vec2 texcoord;

#include "/composite_common.glsl"

void main()
{
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
  #elif COMPOSITE_DEBUG == LIGHTMAP
    color = texture2D(colortex1, vec2(texcoord.x, 1.0 - texcoord.y)).rgb;
  #elif COMPOSITE_DEBUG == TEXTURE_ATLAS
    color = texture2D(colortex1, vec2(texcoord.x, 1.0 - texcoord.y)).rgb;
  #elif COMPOSITE_DEBUG == NORMALS_ATLAS
    color = texture2D(colortex1, vec2(texcoord.x, 1.0 - texcoord.y)).rgb;
  #elif COMPOSITE_DEBUG == SPECULAR_ATLAS
    color = texture2D(colortex1, vec2(texcoord.x, 1.0 - texcoord.y)).rgb;
  #elif COMPOSITE_DEBUG == UNIFORMS
    color = texture2D(gcolor, texcoord).rgb;
    color = uniformColor(color);
  #endif

/* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(color, 1.0); //gcolor
}