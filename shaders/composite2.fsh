#version 120

#include "/gbuffers_config.glsl"

varying vec2 texcoord;

uniform sampler2D gcolor;
uniform sampler2D colortex2;

void main()
{
  vec3 color = texture2D(gcolor, texcoord).rgb;
  
  #if GBUFFER_DEBUG == PROGRAM_ID
    // Program ID legend
    if(texcoord.x < 0.3 && texcoord.y < 0.3)
    {
      vec2 tc = vec2(texcoord / 0.3);
      color = texture2D(colortex2, vec2(tc.x, (1.0 - tc.y) * 0.61)).rgb;
    }
  #endif

/* DRAWBUFFERS:0 */
  gl_FragData[0] = vec4(color, 1.0); //gcolor
}