$input v_color0, v_texcoord0

#include <bgfx_shader.sh>

uniform vec4 u_smooth; // u_smooth.x is the text boundary lower limit, u_smooth.y is the text boundary upper limit, u_smooth.z is outline width control (in SDF units)
uniform vec4 u_outlineColor; // Outline color RGBA

SAMPLER2D(s_texColor, 0);

void main()
{
	// Dynamically get texture size
	vec2 texSize = vec2(textureSize(s_texColor, 0)); // Assuming using mipmap level 0
	vec2 texelSize = 1.0 / texSize;

	// 3x3 sample sampling, calculate average SDF value
	float sdfValue = (
		texture2D(s_texColor, v_texcoord0 + vec2(-1, -1) * texelSize).a +
		texture2D(s_texColor, v_texcoord0 + vec2( 0, -1) * texelSize).a +
		texture2D(s_texColor, v_texcoord0 + vec2( 1, -1) * texelSize).a +
		texture2D(s_texColor, v_texcoord0 + vec2(-1,  0) * texelSize).a +
		texture2D(s_texColor, v_texcoord0 + vec2( 0,  0) * texelSize).a +
		texture2D(s_texColor, v_texcoord0 + vec2( 1,  0) * texelSize).a +
		texture2D(s_texColor, v_texcoord0 + vec2(-1,  1) * texelSize).a +
		texture2D(s_texColor, v_texcoord0 + vec2( 0,  1) * texelSize).a +
		texture2D(s_texColor, v_texcoord0 + vec2( 1,  1) * texelSize).a
	) / 9.0;

	// Define outline range (dynamically adjusted based on u_smooth.z)
	float outlineEdgeMin = u_smooth.x - u_smooth.z; // Outline lower limit
	float outlineEdgeMax = u_smooth.x + u_smooth.z; // Outline upper limit

	// Text body range
	float textEdgeMin = u_smooth.x; // Text fill range
	float textEdgeMax = u_smooth.y;

	// Determine if current pixel is within outline range
	float outlineAlpha = smoothstep(outlineEdgeMin, outlineEdgeMax, sdfValue);

	// Determine if current pixel is within text fill range
	float textAlpha = smoothstep(textEdgeMin, textEdgeMax, sdfValue);

	// Composite the text over the outline in premultiplied space, then convert
	// back to straight alpha for the sprite blend state. Mixing the two RGB
	// values directly lets the default transparent-black outline darken the
	// antialiased text edge.
	float textCoverage = textAlpha * v_color0.a;
	float outlineCoverage = outlineAlpha * u_outlineColor.a * (1.0 - textCoverage);
	float alpha = textCoverage + outlineCoverage;
	vec3 premultipliedColor =
		v_color0.rgb * textCoverage +
		u_outlineColor.rgb * outlineCoverage;
	vec3 color = premultipliedColor / max(alpha, 0.00001);
	gl_FragColor = vec4(color, alpha);
}
