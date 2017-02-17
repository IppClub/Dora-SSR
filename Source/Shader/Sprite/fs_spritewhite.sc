$input v_color0, v_texcoord0

#include "../bgfx_shader.sh"

SAMPLER2D(s_texColor, 0);

void main()
{
	vec4 color = texture2D(s_texColor, v_texcoord0);
	color.xyz = vec3(1,1,1);
	gl_FragColor = v_color0 * color;
}
