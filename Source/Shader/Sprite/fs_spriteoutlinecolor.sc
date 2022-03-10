$input v_color0, v_texcoord0

#include <bgfx_shader.sh>

uniform vec4 u_linecolor;
uniform vec4 u_lineoffset;

SAMPLER2D(s_texColor, 0);

void main()
{
	float alphaThreshold = u_lineoffset.w;
	gl_FragColor = texture2D(s_texColor, v_texcoord0);
	if (gl_FragColor.a >= alphaThreshold)
	{
		gl_FragColor = v_color0 * gl_FragColor;
	}
	else
	{
		float a = 1.0;
		float radius = min(floor(u_lineoffset.z), 10.0);
		for (float i = radius; i >= 1.0; i--)
		{
			float ratio = i / radius;
			float y = u_lineoffset.y * ratio;
			float x = u_lineoffset.x * ratio;
			if (texture2D(s_texColor, v_texcoord0 + vec2(x, y)).a < alphaThreshold
				&& texture2D(s_texColor, v_texcoord0 + vec2(x, -y)).a < alphaThreshold
				&& texture2D(s_texColor, v_texcoord0 + vec2(-x, y)).a < alphaThreshold
				&& texture2D(s_texColor, v_texcoord0 + vec2(-x, -y)).a < alphaThreshold)
			{
				a = 1.0 - i / radius;
				break;
			}
		}
		float lineAlpha = u_linecolor.a * a * (1.0 - gl_FragColor.a);
		gl_FragColor = v_color0 * (vec4(u_linecolor.rgb, lineAlpha) + gl_FragColor);
	}
}

