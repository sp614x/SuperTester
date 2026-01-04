#extension GL_ARB_gpu_shader5 : enable

float getDepth(sampler2D sampler)
{
  return texture2D(sampler, texcoord).r;
}

float getDist(sampler2D sampler)
{
  vec3 pos = vec3(texcoord, getDepth(sampler));
  vec4 tmp = gbufferProjectionInverse * vec4(pos * 2.0 - 1.0, 1.0);
  pos = tmp.xyz / tmp.w;
  return length(pos) / far;
}

bool between(float val, float min, float max)
{
  return step(min, val) != step (max, val);
} 

bool between(vec2 vals, vec2 mins, vec2 maxs)
{
  return between(vals.x, mins.x, maxs.x) && between(vals.y, mins.y, maxs.y);
} 

vec3 floatCol(float val)
{
  // The exponent is returned in this output parameter
  int exp;
  // Significand (0.5 - 1.0)
  float sig = frexp(val, exp);
  // Sign
  float r = (sign(val) + 1.0) / 2.0;
  // Significand
  float g = (abs(sig) - 0.5) * 2.0;
  // Exponent
  float b = clamp((exp + 10) / 20.0, 0.0, 1.0);
  // Col
  return vec3(r, g, b);
}

vec3 uniformColorVec3(vec3 vec, vec2 tc, vec2 mins, vec2 maxs)
{
  float dx = (maxs.x - mins.x) / 3;
  float dy = (maxs.y - mins.y) / 1;
  //
  for(int x = 0; x < 4; x++)
  {
    if(between(tc, mins + vec2(x * dx, 0.0), vec2((x + 1.0) * dx, dy)))
      return floatCol(vec[x]);
  }
  //
  return vec3(1.0, 1.0, 1.0);
}

vec3 uniformColorMat3(mat3 mx, vec2 tc, vec2 mins, vec2 maxs)
{
  float dx = (maxs.x - mins.x) / 3;
  float dy = (maxs.y - mins.y) / 3;
  //
  for(int x = 0; x < 3; x++)
  {
    for(int y = 0; y < 3; y++)
    {
      if(between(tc, mins + vec2(x * dx, y * dy), vec2((x + 1.0) * dx, (y + 1.0) * dy)))
        return floatCol(mx[x][y]);
    }
  }
  //
  return vec3(1.0, 1.0, 1.0);
}

vec3 uniformColorMat4(mat4 mx, vec2 tc, vec2 mins, vec2 maxs)
{
  float dx = (maxs.x - mins.x) / 4;
  float dy = (maxs.y - mins.y) / 4;
  vec2 dxy = vec2(dx, dy);
  //
  for(int x = 0; x < 4; x++)
  {
    for(int y = 0; y < 4; y++)
    {
      vec2 xy = vec2(x, y);
      if(between(tc, mins + dxy * xy, mins + dxy * (xy + 1)))
        return floatCol(mx[x][y]);
    }
  }
  //
  return vec3(0.0, 0.0, 0.0);
}

bool checkUniformColorVec3(vec3 vec, vec2 tc, inout vec2 rc, vec2 dc, float dx, out vec3 color)
{
  // Check
  if(!between(tc, rc, rc + dc))
  {
    // Next
    rc.x = rc.x + dc.x + dx;
    return false;
  }
  // Get
  color = uniformColorVec3(vec, tc, rc, rc + dc);
  // Next
  rc.x = rc.x + dc.x + dx;
  // Done
  return true;
} 

bool checkUniformColorMat4(mat4 mx, vec2 tc, inout vec2 rc, vec2 dc, float dx, out vec3 color)
{
  // Check
  if(!between(tc, rc, rc + dc))
  {
    // Next
    rc.x = rc.x + dc.x + dx;
    return false;
  }
  // Get
  color = uniformColorMat4(mx, tc, rc, rc + dc);
  // Next
  rc.x = rc.x + dc.x + dx;
  // Done
  return true;
} 

vec3 uniformColor(vec3 colDef)
{
  vec2 tc = vec2(texcoord.x, 1.0 - texcoord.y);
  float dx = 0.05;
  float dy = 0.05;
  vec2 rc = vec2(0.0, 0.0);
  vec2 dc = vec2(0.1, 0.1);
  vec3 color = colDef;
  // Sun
  if(checkUniformColorVec3(sunPosition, tc, rc, dc, dx, color))
    return color;
  // Moon
  if(checkUniformColorVec3(moonPosition, tc, rc, dc, dx, color))
    return color;
  // Shadow light
  if(checkUniformColorVec3(shadowLightPosition, tc, rc, dc, dx, color))
    return color;
  // Up
  if(checkUniformColorVec3(upPosition, tc, rc, dc, dx, color))
    return color;
  // Camera
  if(checkUniformColorVec3(cameraPosition, tc, rc, dc, dx, color))
    return color;
  // Previous camera
  if(checkUniformColorVec3(previousCameraPosition, tc, rc, dc, dx, color))
    return color;
  // Next line
  rc.x = 0.0;
  rc.y = rc.y + dc.y + dy;
  // Gbuffer modelview
  if(checkUniformColorMat4(gbufferModelView, tc, rc, dc, dx, color))
    return color;
  // Gbuffer previous modelview
  if(checkUniformColorMat4(gbufferPreviousModelView, tc, rc, dc, dx, color))
    return color;
  // Gbuffer modelview inverse
  if(checkUniformColorMat4(gbufferModelViewInverse, tc, rc, dc, dx, color))
    return color;
  // Gbuffer projection
  if(checkUniformColorMat4(gbufferProjection, tc, rc, dc, dx, color))
    return color;
  // Gbuffer previous projection
  if(checkUniformColorMat4(gbufferPreviousProjection, tc, rc, dc, dx, color))
    return color;
  // Gbuffer projection inverse
  if(checkUniformColorMat4(gbufferProjectionInverse, tc, rc, dc, dx, color))
    return color;
  // Next line
  rc.x = 0.0;
  rc.y = rc.y + dc.y + dy;
  // Shadow modelview
  if(checkUniformColorMat4(shadowModelView, tc, rc, dc, dx, color))
    return color;
  // Shadow modelview inverse
  if(checkUniformColorMat4(shadowModelViewInverse, tc, rc, dc, dx, color))
    return color;
  // Shadow projection
  if(checkUniformColorMat4(shadowProjection, tc, rc, dc, dx, color))
    return color;
  // Shadow projection inverse
  if(checkUniformColorMat4(shadowProjectionInverse, tc, rc, dc, dx, color))
    return color;
  // Next line
  rc.x = 0.0;
  rc.y = rc.y + dc.y + dy;
  // Projection matrix
  if(checkUniformColorMat4(projectionMatrix, tc, rc, dc, dx, color))
    return color;
  // Projection matrix inverse
  if(checkUniformColorMat4(projectionMatrixInverse, tc, rc, dc, dx, color))
    return color;
  //
  return colDef;
}
