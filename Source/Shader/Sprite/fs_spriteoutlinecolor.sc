$input v_color0, v_texcoord0

#include <bgfx_shader.sh>

uniform vec4 u_linecolor;
uniform vec4 u_lineoffset;

SAMPLER2D(s_texColor, 0);

void main()
{
	float alphaThreshold = u_lineoffset.z;
	gl_FragColor = texture2D(s_texColor, v_texcoord0);
	ivec2 texSize = textureSize(s_texColor, 0);
	vec2 texel = vec2(u_lineoffset.x / float(texSize.x), u_lineoffset.x / float(texSize.y));
	if (gl_FragColor.a >= alphaThreshold)
	{
		gl_FragColor = v_color0 * gl_FragColor;
	}
	else
	{
		float a = 1.0;
		float radius = min(floor(u_lineoffset.y), 10.0);
		for (float i = radius; i >= 1.0; i--)
		{
			float ratio = i / radius;
			bool hasAlpha = true;
			for (int i = 0; i < 8; ++i)
			{
				float angle = float(i) * 0.785398; // 0.785398 = π/4
				vec2 offset = normalize(vec2(cos(angle), sin(angle))) * texel * ratio;
				if (texture2D(s_texColor, v_texcoord0 + offset).a >= alphaThreshold)
				{
					hasAlpha = false;
					break;
				}
			}
			if (hasAlpha)
			{
				a = 1.0 - ratio;
				break;
			}
		}
		float lineAlpha = u_linecolor.a * a * (1.0 - gl_FragColor.a);
		gl_FragColor = v_color0 * (vec4(u_linecolor.rgb, lineAlpha) + gl_FragColor);
	}
}
