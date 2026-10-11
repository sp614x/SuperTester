#ifndef UTILS_GLSL
#define UTILS_GLSL

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

#endif