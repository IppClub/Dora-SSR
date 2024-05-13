vec3 vec3_splat(vec3 v)
{
    return v;
}

vec2 vec2_splat(vec2 v)
{
    return v;
}

vec4 vec4_splat(vec4 v)
{
    return v;
}

vec3 to_linear(vec3 _rgb)
{
	return pow(abs(_rgb), vec3_splat(2.2) );
}

vec4 to_linear(vec4 _rgba)
{
	return vec4(to_linear(_rgba.xyz), _rgba.w);
}

#define gl_InstanceIndex gl_InstanceID