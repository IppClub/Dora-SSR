$input v_color0, v_texcoord0

#include <bgfx_shader.sh>

SAMPLER2D(s_texColor, 0);

void main()
{
	float coverage = texture2D(s_texColor, v_texcoord0).r;
	if (coverage <= u_alphaRef) discard;
	gl_FragColor = vec4(v_color0.rgb, v_color0.a * coverage);
}
