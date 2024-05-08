$input v_color0, v_texcoord0

#include <bgfx_shader.sh>

void main()
{
	if (v_color0.a == 0.0) discard;
#if defined GL_OES_standard_derivatives
	gl_FragColor = v_color0 * smoothstep(0.0, length(fwidth(v_texcoord0)), 1.0 - length(v_texcoord0));
#else
	gl_FragColor = v_color0 * step(0.0, 1.0 - length(v_texcoord0));
#endif
}
