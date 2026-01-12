#define NOTHING 0
#define LMCOORD 1
#define LIGHTMAP 2
#define GLX_NORMAL 3
#define GLX_NORMALMATRIX 4
#define MC_MIDTEXCOORD 5
#define AT_TANGENT 6
#define AT_TANGENTMATRIX 7
#define AT_VELOCITY 8
#define AT_MIDBLOCK 9
#define NUMERIC_ID 10
#define GLX_COLOR 11
#define NORMALS_TEXTURE 12
#define SPECULAR_TEXTURE 13
#define GLX_VERTEX 14
#define PLAYER_POS 15
#define WORLD_POS 16
#define VIEW_POS 17
#define SHADOW_VIEW_POS 18
#define SHADOW_SAMPLE_POS 19
#define SHADOWCOLOR0 20
#define PROGRAM_ID 21
#define TEXTURE 22
#define GBUFFER_DEBUG NOTHING //What to draw in gbuffers_textured. For CONSTANT, see the key in the zip file. [NOTHING TEXTURE NORMALS_TEXTURE SPECULAR_TEXTURE LMCOORD LIGHTMAP GLX_NORMAL GLX_NORMALMATRIX MC_MIDTEXCOORD AT_TANGENT AT_TANGENTMATRIX AT_VELOCITY AT_MIDBLOCK GLX_COLOR GLX_VERTEX PLAYER_POS WORLD_POS VIEW_POS SHADOW_VIEW_POS SHADOW_SAMPLE_POS SHADOWCOLOR0 NUMERIC_ID PROGRAM_ID]
#define COLOR_WEIGHT 0.75 //Mix level which combines the grayscale texture with the thing being debugged [0.0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]

int mix3(int x)
{
  int b0 = (x >> 0) & 1;
  int b1 = (x >> 3) & 1;
  int b2 = (x >> 6) & 1;
  return (b2 << 2) | (b1 << 1) | b0;
}

vec3 mixVec3(int x)
{
  float r = mix3(x) / 7.0;
  float g = mix3(x >> 1) / 7.0;
  float b = mix3(x >> 2) / 7.0;
  return vec3(r, g, b);
}
