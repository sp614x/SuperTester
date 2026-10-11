#include "/uniform_colors.glsl"

float getDepth(sampler2D sampler)
{
  return texture2D(sampler, texcoord).r;
}

float getDist(sampler2D depthtexN)
{
  vec3 pos = vec3(texcoord, texture2D(depthtexN, texcoord).r);
  vec4 tmp = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
  pos = tmp.xyz / tmp.w;
  return length(pos) / far;
}

