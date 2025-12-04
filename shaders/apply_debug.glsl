#if GBUFFER_DEBUG != NOTHING
  float grayscale = dot(color.rgb, vec3(0.25, 0.5, 0.25));
  color.rgb = mix(vec3(grayscale), debug, COLOR_WEIGHT);
#else
  color.rgb = debug;
#endif