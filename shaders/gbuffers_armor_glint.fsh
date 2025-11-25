#version 120

#include "/gbuffers_config.glsl"
#define PROGRAM_COLOR vec3(0.0, 0.5, 0.5)

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
  vec4 color = texture2D(texture, texcoord) * glcolor;
  vec3 debug;

  #if GBUFFER_DEBUG == PROGRAM_ID
    debug = PROGRAM_COLOR;
  #else
    debug = color.rgb * texture2D(lightmap, lmcoord).rgb;
  #endif

  #include "/apply_debug.glsl"

/* DRAWBUFFERS:0 */
  gl_FragData[0] = color; //gcolor
}