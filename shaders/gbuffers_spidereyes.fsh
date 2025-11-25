#version 120

#include "/gbuffers_config.glsl"
//#define DISABLE_SPIDEREYES //Discards all fragments in gbuffers_spidereyes
#define PROGRAM_COLOR vec3(0.0, 0.0, 1.0)

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
  #ifdef DISABLE_SPIDEREYES
    discard;
  #endif

  vec4 color = texture2D(texture, texcoord) * glcolor;
  #if GBUFFER_DEBUG == PROGRAM_ID
    vec3 debug = PROGRAM_COLOR;
    #include "/apply_debug.glsl"
  #endif

/* DRAWBUFFERS:0 */
  gl_FragData[0] = color; //gcolor
}