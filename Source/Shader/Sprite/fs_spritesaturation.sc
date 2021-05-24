$input v_color0, v_texcoord0

#include <bgfx_shader.sh>

uniform vec4 u_adjustment;

SAMPLER2D(s_texColor, 0);

void main()
{
	vec4 color = v_color0 * texture2D(s_texColor, v_texcoord0);
	const vec3 W = vec3(0.2125, 0.7154, 0.0721);
	float value = dot(color.rgb, W);
	vec3 intensity = vec3(value, value, value);
	gl_FragColor = vec4(mix(intensity, color.rgb, u_adjustment.x), color.w);
}
