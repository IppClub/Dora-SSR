$input v_color0, v_texcoord0

#include <bgfx_shader.sh>

SAMPLER2D(s_texColor, 0);

void main()
{
	float alpha = texture2D(s_texColor, v_texcoord0).a;
	gl_FragColor = vec4(v_color0.rgb, v_color0.a * alpha);
}
