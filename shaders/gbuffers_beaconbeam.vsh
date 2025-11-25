#version 120

attribute vec4 at_tangent;
attribute vec4 at_velocity;
attribute vec4 at_midBlock;
attribute vec4 mc_midTexCoord;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 cameraPosition;

varying vec2 lmcoord;
varying vec2 midcoord;
varying vec2 texcoord;

varying vec3 normal;
varying vec3 rotatedNormal;
varying vec3 tangent;
varying vec3 tangentMatrix;
varying vec3 velocity;
varying vec3 midblock;

varying vec3 glvertex;
varying vec3 playerPos;
varying vec3 shadowSamplePos;
varying vec3 shadowViewPos;
varying vec3 viewPos;
varying vec3 worldPos;

varying vec4 glcolor;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;
  midcoord = step(mc_midTexCoord.xy, texcoord);
  normal = gl_Normal;
  rotatedNormal = gl_NormalMatrix * gl_Normal;
  tangent = normalize(at_tangent.xyz);
  tangentMatrix = normalize(gl_NormalMatrix * at_tangent.xyz);
  velocity = at_velocity.xyz;
  midblock = at_midBlock.xyz / 64.0;
  
  glvertex = gl_Vertex.xyz;
  playerPos = (gbufferModelViewInverse * (gl_ModelViewMatrix * gl_Vertex)).xyz;
  viewPos = (gbufferModelView * vec4(playerPos, 1.0)).xyz;
  worldPos = playerPos + cameraPosition;

  shadowViewPos = (shadowModelView * vec4(playerPos, 1.0)).xyz;
  shadowSamplePos = (shadowProjection * vec4(shadowViewPos, 1.0)).xyz * 0.5 + 0.5;
}