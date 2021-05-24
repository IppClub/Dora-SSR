$input a_position, a_texcoord0, a_color0
$output v_color0, v_texcoord0

#include <bgfx_shader.sh>

void main()
{
	gl_Position = a_position;
	v_color0 = a_color0;
	v_texcoord0 = a_texcoord0;
}
