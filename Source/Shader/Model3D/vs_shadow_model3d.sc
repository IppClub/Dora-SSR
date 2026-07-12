$input a_position, a_texcoord0, a_texcoord1, a_color0, a_indices, a_weight
$output v_color0, v_texcoord01, v_shadowCoord

#include <bgfx_shader.sh>

#define MAX_JOINTS 64

uniform mat4 u_mCameraProj;
uniform mat4 u_mModel_Inst[40];
uniform mat4 u_joints[MAX_JOINTS];
uniform vec4 u_fUV[40];
uniform vec4 u_fModelColor[40];
uniform vec4 u_mUVInversed;

void main()
{
	int index = int(gl_InstanceID);
	vec4 uv = u_fUV[index];
	vec4 localPos = vec4(a_position, 1.0);
	float weightSum = a_weight.x + a_weight.y + a_weight.z + a_weight.w;
	if (weightSum > 0.0)
	{
		mat4 skin =
			u_joints[int(a_indices.x)] * a_weight.x +
			u_joints[int(a_indices.y)] * a_weight.y +
			u_joints[int(a_indices.z)] * a_weight.z +
			u_joints[int(a_indices.w)] * a_weight.w;
		localPos = mul(skin, localPos);
	}
	vec4 worldPos = mul(u_mModel_Inst[index], localPos);
	gl_Position = mul(u_mCameraProj, worldPos);
	v_shadowCoord = gl_Position;
	v_color0 = u_fModelColor[index] * a_color0;
	v_texcoord01.xy = vec2(
		a_texcoord0.x * uv.z + uv.x,
		u_mUVInversed.x + u_mUVInversed.y * (a_texcoord0.y * uv.w + uv.y));
	v_texcoord01.zw = vec2(
		a_texcoord1.x * uv.z + uv.x,
		u_mUVInversed.x + u_mUVInversed.y * (a_texcoord1.y * uv.w + uv.y));
}
