#version 120

varying vec4 glcolor;
varying vec3 glvertex;

void main() {
	gl_Position = ftransform();
	glcolor = gl_Color;
	glvertex = gl_Vertex.xyz;
}