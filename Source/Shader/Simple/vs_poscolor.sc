$input a_position, a_color0
$output v_fragColor

#include <bgfx_shader.sh>

void main()
{
	gl_Position = a_position;
	v_fragColor = vec4(a_color0.rgb * a_color0.a, a_color0.a);
}
