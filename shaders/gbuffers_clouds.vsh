#version 120

uniform vec3 modelOffset;

varying vec4 glcolor;
varying vec3 glvertex;

#if MC_VERSION < 12102
varying vec2 texcoord;
varying vec3 normal;
varying vec3 rotatedNormal;
#endif

void main() {
    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * vec4(gl_Vertex.xyz + modelOffset, 1.0);
  glcolor = gl_Color;
  glvertex = gl_Vertex.xyz;

  #if MC_VERSION < 12102
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    normal = gl_Normal;
    rotatedNormal = normalize(gl_NormalMatrix * gl_Normal);
  #endif
}