$input v_color0, v_texcoord0

#include <bgfx_shader.sh>

SAMPLER2D(s_texColor, 0);

void main()
{
	vec4 texColor = texture2D(s_texColor, v_texcoord0);
	if (texColor.a <= u_alphaRef) discard;
	gl_FragColor = v_color0 * texColor;
}
