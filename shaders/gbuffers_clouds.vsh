#version 120

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 normal;
varying vec3 rotatedNormal;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
	normal = gl_Normal;
	rotatedNormal = normalize(gl_NormalMatrix * gl_Normal);
}