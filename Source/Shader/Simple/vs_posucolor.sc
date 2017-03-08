$input a_position
$output v_fragColor

uniform vec4 u_color;

#include "../bgfx_shader.sh"

void main()
{
	gl_Position = a_position;
	v_fragColor = vec4(u_color.rgb * u_color.a, u_color.a);
}
