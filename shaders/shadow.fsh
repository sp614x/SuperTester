#version 120
#extension GL_EXT_gpu_shader4 : enable

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
#define SHADOW_DEBUG NOTHING //What to draw in the shadow program [NOTHING LMCOORD LIGHTMAP GLX_NORMAL GLX_NORMALMATRIX MC_MIDTEXCOORD AT_TANGENT AT_TANGENTMATRIX AT_VELOCITY AT_MIDBLOCK NUMERIC_ID GLX_COLOR NORMALS_TEXTURE SPECULAR_TEXTURE GLX_VERTEX PLAYER_POS WORLD_POS VIEW_POS SHADOW_VIEW_POS SHADOW_SAMPLE_POS]  
#define COLOR_WEIGHT 0.75 //Mix level which combines the grayscale texture with the thing being debugged [0.0 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]

uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D texture;

varying float mcentity;

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
varying vec3 shadowViewPos;
varying vec3 shadowSamplePos;
varying vec3 viewPos;
varying vec3 worldPos;

varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	vec3 debug;
	
	#if SHADOW_DEBUG == NOTHING
		debug = color.rgb * texture2D(lightmap, lmcoord).rgb;
	#elif SHADOW_DEBUG == LMCOORD
		debug = vec3(lmcoord, 0.0);
	#elif SHADOW_DEBUG == LIGHTMAP
		debug = texture2D(lightmap, lmcoord).rgb;
	#elif SHADOW_DEBUG == GLX_NORMAL
		debug = normal * 0.5 + 0.5;
	#elif SHADOW_DEBUG == GLX_NORMALMATRIX
		debug = rotatedNormal * 0.5 + 0.5;
	#elif SHADOW_DEBUG == MC_MIDTEXCOORD
		debug = vec3(midcoord, 0.0);
	#elif SHADOW_DEBUG == AT_TANGENT
		debug = tangent * 0.5 + 0.5;
	#elif SHADOW_DEBUG == NUMERIC_ID
		int id = int(floor(mcentity + 0.5));
		float blue = (id & 15) / 15.0;
		id >>= 4;
		float green = (id & 15) / 15.0;
		id >>= 4;
		float red = (id & 15) / 15.0;
		debug = vec3(red, green, blue);
	#elif SHADOW_DEBUG == GLX_COLOR
		debug = glcolor.rgb;
	#elif SHADOW_DEBUG == NORMALS_TEXTURE
		debug = texture2D(normals, texcoord).rgb;
	#elif SHADOW_DEBUG == SPECULAR_TEXTURE
		debug = texture2D(specular, texcoord).rgb;
	#elif SHADOW_DEBUG == GLX_VERTEX
		debug = glvertex / 16.0;
	#elif SHADOW_DEBUG == PLAYER_POS
		debug = playerPos;
	#elif SHADOW_DEBUG == WORLD_POS
		debug = worldPos;
	#elif SHADOW_DEBUG == VIEW_POS
		debug = viewPos;
	#elif SHADOW_DEBUG == SHADOW_VIEW_POS
		debug = shadowViewPos;
	#elif SHADOW_DEBUG == SHADOW_SAMPLE_POS
		debug = shadowSamplePos;
	#endif
	
	//don't include because apply_debug checks for GBUFFER_DEBUG, not SHADOW_DEBUG
	#if SHADOW_DEBUG != NOTHING
		float grayscale = dot(color.rgb, vec3(0.25, 0.5, 0.25));
		color.rgb = mix(vec3(grayscale), debug, COLOR_WEIGHT);
		color.a = mix(color.a, step(0.1, color.a), COLOR_WEIGHT);
	#endif

	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(color.rgb, step(0.99, color.a));
}