$input v_color0, v_texcoord0

#include <bgfx_shader.sh>

uniform vec4 u_linecolor;
uniform vec4 u_lineoffset;

SAMPLER2D(s_texColor, 0);

void main()
{
	float a = 0.0;
	float alphaThreshold = u_lineoffset.w;
	float radius = min(u_lineoffset.z, 10.0);
	for (float i = 1.0; i <= radius; i++)
	{
		float ratio = i / radius;
		float y = u_lineoffset.y * ratio;
		float x = u_lineoffset.x * ratio;
		if (texture2D(s_texColor, v_texcoord0 + vec2(x, y)).a >= alphaThreshold
		|| texture2D(s_texColor, v_texcoord0 + vec2(x, -y)).a >= alphaThreshold
		|| texture2D(s_texColor, v_texcoord0 + vec2(-x, y)).a >= alphaThreshold
		|| texture2D(s_texColor, v_texcoord0 + vec2(-x, -y)).a >= alphaThreshold)
		{
			a = 1.0 - (i - 1.0) / radius;
			break;
		}
	}
	gl_FragColor = texture2D(s_texColor, v_texcoord0);
	gl_FragColor = v_color0 * (u_linecolor * a * (1.0 - gl_FragColor.a) + gl_FragColor);
}

