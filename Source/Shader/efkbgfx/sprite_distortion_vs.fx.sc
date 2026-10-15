$input a_position a_color0 a_normal a_tangent a_texcoord0 a_texcoord1
$output v_UV v_ProjBinormal v_ProjTangent v_PosP v_Color

#include <bgfx_shader.sh>
#include "defines.sh"
uniform mat4 u_mCamera;
uniform mat4 u_mCameraProj;
uniform vec4 u_mUVInversed;
uniform vec4 u_mflipbookParameter;


struct VS_Input
{
    vec3 Pos;
    vec4 Color;
    vec4 Normal;
    vec4 Tangent;
    vec2 UV1;
    vec2 UV2;
};

struct VS_Output
{
    vec4 PosVS;
    vec2 UV;
    vec4 ProjBinormal;
    vec4 ProjTangent;
    vec4 PosP;
    vec4 Color;
};

VS_Output _main(VS_Input Input)
{
#if BGFX_SHADER_LANGUAGE_GLSL || BGFX_SHADER_LANGUAGE_ESSL
    VS_Output Output = VS_Output(
        vec4(0.0),   // PosVS
        vec2(0.0),   // UV
        vec4(0.0),   // ProjBinormal
        vec4(0.0),   // ProjTangent
        vec4(0.0),   // PosP
        vec4(0.0)    // Color
    );
#else
    VS_Output Output = (VS_Output)0;
#endif
    vec4 worldNormal = vec4((Input.Normal.xyz - vec3_splat(0.5)) * 2.0, 0.0);
    vec4 worldTangent = vec4((Input.Tangent.xyz - vec3_splat(0.5)) * 2.0, 0.0);
    vec4 worldBinormal = vec4(cross(worldNormal.xyz, worldTangent.xyz), 0.0);
    vec4 worldPos = vec4(Input.Pos.x, Input.Pos.y, Input.Pos.z, 1.0);
    Output.PosVS = mul(u_mCameraProj, worldPos);
    Output.Color = Input.Color;
    vec2 uv1 = Input.UV1;
    uv1.y = u_mUVInversed.x + (u_mUVInversed.y * uv1.y);
    Output.UV = uv1;
    Output.ProjTangent = mul(u_mCameraProj, (worldPos + worldTangent));
    Output.ProjBinormal = mul(u_mCameraProj, (worldPos + worldBinormal));
    Output.PosP = Output.PosVS;
    return Output;
}

void main()
{
    VS_Input Input;
    Input.Pos = a_position;
    Input.Color = a_color0;
    Input.Normal = a_normal;
    Input.Tangent = a_tangent;
    Input.UV1 = a_texcoord0;
    Input.UV2 = a_texcoord1;
    VS_Output flattenTemp = _main(Input);
    vec4 _position = flattenTemp.PosVS;
    gl_Position = _position;
    v_UV = flattenTemp.UV;
    v_ProjBinormal = flattenTemp.ProjBinormal;
    v_ProjTangent = flattenTemp.ProjTangent;
    v_PosP = flattenTemp.PosP;
    v_Color = flattenTemp.Color;
}
