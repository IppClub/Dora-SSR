$input v_color0, v_texcoord01, v_shadowCoord

#include <bgfx_shader.sh>

SAMPLER2D(s_baseColor, 0);
uniform vec4 u_baseColor;
uniform vec4 u_alphaMode;
uniform vec4 u_uvBaseColor;
uniform vec4 u_uvBaseColorOffset;
uniform vec4 u_shadowParams;

vec2 transformUv(vec2 uv, vec4 transform, vec4 offset)
{
	return vec2(
		uv.x * transform.x + uv.y * transform.z + offset.x,
		uv.x * transform.y + uv.y * transform.w + offset.y);
}

void main()
{
	vec2 sourceUv = u_uvBaseColorOffset.z > 0.5 ? v_texcoord01.zw : v_texcoord01.xy;
	vec2 uv = transformUv(sourceUv, u_uvBaseColor, u_uvBaseColorOffset);
	float alpha = texture2D(s_baseColor, uv).a * u_baseColor.a * v_color0.a;
	if (u_alphaMode.x > 0.5 && alpha < u_alphaMode.y)
	{
		discard;
	}
	float depth = (v_shadowCoord.z / max(v_shadowCoord.w, 0.000001)) * u_shadowParams.x + u_shadowParams.y;
	vec4 packedDepth = fract(depth * vec4(16777216.0, 65536.0, 256.0, 1.0));
	packedDepth -= packedDepth.xxyz * vec4(0.0, 0.00390625, 0.00390625, 0.00390625);
	gl_FragColor = packedDepth;
}
