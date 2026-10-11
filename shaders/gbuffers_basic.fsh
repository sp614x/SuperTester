#version 120

#include "/gbuffers_config.glsl"
#define PROGRAM_COLOR vec3(0.5, 0.0, 0.0)

varying vec4 glcolor;
varying vec3 glvertex;

void main()
{
  vec4 color = glcolor;
  vec3 debug = color.rgb;

  #if GBUFFER_DEBUG == PROGRAM_ID
    debug = PROGRAM_COLOR;
  #elseif GBUFFER_DEBUG == GLX_COLOR
    debug = glcolor.rgb;
  #elseif GBUFFER_DEBUG == GLX_VERTEX
    debug = glvertex / 16.0;
  #endif

  #include "/apply_debug.glsl"

/* DRAWBUFFERS:0 */
  gl_FragData[0] = color; //gcolor
}