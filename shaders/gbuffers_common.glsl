vec4 color = texture2D(texture, texcoord) * glcolor;
vec3 debug;

#if GBUFFER_DEBUG == NOTHING
	debug = color.rgb * texture2D(lightmap, lmcoord).rgb;
#elif GBUFFER_DEBUG == LMCOORD
	debug = vec3(lmcoord, 0.0);
#elif GBUFFER_DEBUG == LIGHTMAP
	debug = texture2D(lightmap, lmcoord).rgb;
#elif GBUFFER_DEBUG == GLX_NORMAL
	debug = normal * 0.5 + 0.5;
#elif GBUFFER_DEBUG == GLX_NORMALMATRIX
	debug = rotatedNormal * 0.5 + 0.5;
#elif GBUFFER_DEBUG == MC_MIDTEXCOORD
	debug = vec3(midcoord, 0.0);
#elif GBUFFER_DEBUG == AT_TANGENT
	debug = tangent * 0.5 + 0.5;
#elif GBUFFER_DEBUG == NUMERIC_ID
	int id = ID_GETTER;
	float blue = (id & 15) / 15.0;
	id >>= 4;
	float green = (id & 15) / 15.0;
	id >>= 4;
	float red = (id & 15) / 15.0;
	debug = vec3(red, green, blue);
#elif GBUFFER_DEBUG == GLX_COLOR
	debug = glcolor.rgb;
#elif GBUFFER_DEBUG == NORMALS_TEXTURE
	debug = texture2D(normals, texcoord).rgb;
#elif GBUFFER_DEBUG == SPECULAR_TEXTURE
	debug = texture2D(specular, texcoord).rgb;
#elif GBUFFER_DEBUG == GLX_VERTEX
	debug = glvertex / 16.0;
#elif GBUFFER_DEBUG == PLAYER_POS
	debug = playerPos;
#elif GBUFFER_DEBUG == WORLD_POS
	debug = worldPos;
#elif GBUFFER_DEBUG == VIEW_POS
	debug = viewPos;
#elif GBUFFER_DEBUG == SHADOW_VIEW_POS
	debug = shadowViewPos;
#elif GBUFFER_DEBUG == SHADOW_SAMPLE_POS
	debug = shadowSamplePos;
#elif GBUFFER_DEBUG == SHADOWCOLOR0
	if (shadowSamplePos.xy == clamp(shadowSamplePos.xy, 0.0, 1.0)) {
		float lightDot = dot(normalize(shadowLightPosition), normalize(rotatedNormal));
		float bias = (SHADOW_BIAS * shadowDistance / shadowMapResolution) / abs(lightDot);
		float depth = shadowSamplePos.z - texture2D(shadowtex0, shadowSamplePos.xy).r;
		if (depth > bias) {
			debug = vec3(0.0);
		}
		else if (depth < -bias) {
			debug = vec3(1.0);
		}
		else {
			debug = texture2D(shadowcolor0, shadowSamplePos.xy).rgb;
		}
	}
	else {
		debug = vec3(0.0);
	}
#elif GBUFFER_DEBUG == PROGRAM_ID
	debug = PROGRAM_COLOR;
#endif

#include "/apply_debug.glsl"