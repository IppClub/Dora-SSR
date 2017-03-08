$input a_position, a_texcoord0, a_color0
$output v_color0, v_texcoord0
uniform vec4 u_color;

#include "../bgfx_shader.sh"

void main()
{
	v_color0 = vec4(a_color0.rgb * a_color0.a * u_color.a, a_color0.a) * u_color;
	v_texcoord0 = a_texcoord0;
	gl_Position = a_position;
}		
