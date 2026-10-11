#version 120

#include "/gbuffers_config.glsl"
#define PROGRAM_COLOR vec3(0.5, 0.0, 0.5)

uniform sampler2D texture;

#include "/extended_uniforms.glsl"

varying vec2 texcoord;
varying vec4 glcolor;

// Color functions
#include "/uniform_colors.glsl"

void main()
{
  vec4 color = texture2D(texture, texcoord) * glcolor;
  vec3 debug = color.rgb;

  #if GBUFFER_DEBUG == PROGRAM_ID
    debug = PROGRAM_COLOR;
  #elif GBUFFER_DEBUG == UNIFORMS
    debug = uniformColor(debug).rgb;
  #endif

  #include "/apply_debug.glsl"

/* DRAWBUFFERS:0 */
  gl_FragData[0] = color; //gcolor
}