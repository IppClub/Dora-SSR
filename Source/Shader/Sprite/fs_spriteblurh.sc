$input v_color0, v_texcoord0

#include <bgfx_shader.sh>

uniform vec4 u_radius;

SAMPLER2D(s_texColor, 0);

void main()
{
	gl_FragColor = texture2D(s_texColor, v_texcoord0) * 0.204164;
	gl_FragColor += texture2D(s_texColor, v_texcoord0 + vec2(1.407333 / u_radius.x, 0.0)) * 0.304005;
	gl_FragColor += texture2D(s_texColor, v_texcoord0 - vec2(1.407333 / u_radius.x, 0.0)) * 0.304005;
	gl_FragColor += texture2D(s_texColor, v_texcoord0 + vec2(3.294215 / u_radius.x, 0.0)) * 0.093913;
	gl_FragColor += texture2D(s_texColor, v_texcoord0 - vec2(3.294215 / u_radius.x, 0.0)) * 0.093913;
}

