
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

float symLog(float x, float threshold)
 {
    // Values smaller than threshold are treated linearly
    return sign(x) * log2(1.0 + abs(x) / threshold);
}

float symQuant(float val, float step)
{
  return trunc(val / step) * step;
}

float symFract(float val)
{
  return val - trunc(val);
}

vec3 floatCol(float val)
{
  // Log space (1e4 => 25.0, 1e-4 -> 0.4) 
  val = symLog(val, 0.0003);
  // Quant
  float step = 5.0;
  float mul = step / (step - 1);
  // Frac (-1.0 : 1.0)
  float valFrac = symFract(val);
  val = trunc(val) / step;
  // Frac2 (-1.0 : 1.0)
  float valFrac2 = symFract(val) * mul;
  val = trunc(val) / step;
  // Frac3 (-1.0 : 1.0)
  float valFrac3 = symFract(val) * mul;
  // Normalize (0.0 : 1.0)
  float r = valFrac / 2.0 + 0.5;
  float g = valFrac2 / 2.0 + 0.5;
  float b = valFrac3 / 2.0 + 0.5;
  // Col
  return vec3(r, g, b);
}

vec3 uniformColorVec3(vec3 vec, vec2 tc, vec2 mins, vec2 maxs)
{
  vec2 dxy = (maxs - mins) / vec2(3, 1);
  //
  for(int x = 0; x < 4; x++)
  {
    vec2 xy = vec2(x, 0);
    if(between(tc, mins + dxy * xy, mins + dxy * (xy + 1)))
      return floatCol(vec[x]);
  }
  //
  return vec3(1.0, 1.0, 1.0);
}

vec3 uniformColorMat3(mat3 mx, vec2 tc, vec2 mins, vec2 maxs)
{
  vec2 dxy = (maxs - mins) / 3.0;
  //
  for(int x = 0; x < 3; x++)
  {
    for(int y = 0; y < 3; y++)
    {
      vec2 xy = vec2(x, y);
      if(between(tc, mins + dxy * xy, mins + dxy * (xy + 1)))
        return floatCol(mx[x][y]);
    }
  }
  //
  return vec3(1.0, 1.0, 1.0);
}

vec3 uniformColorMat4(mat4 mx, vec2 tc, vec2 mins, vec2 maxs)
{
  vec2 dxy = (maxs - mins) / 4.0;
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
  // Tex
  vec2 tc = vec2(texcoord.x, 1.0 - texcoord.y);
  // Start
  float sx = 0.05;
  float sy = 0.05;
  // Delta
  float dx = 0.05;
  float dy = 0.05;
  // Rect
  vec2 rc = vec2(sx, sy);
  vec2 dc = vec2(0.1, 0.1);
  // Color
  vec3 color = colDef;
  // Row 1
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
  // Row 2
  rc.x = sx;
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
  // Row 3
  rc.x = sx;
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
  // Row 4
  rc.x = sx;
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
