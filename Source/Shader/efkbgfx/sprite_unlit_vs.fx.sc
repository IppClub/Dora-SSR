$input a_position a_color0 a_texcoord0
$output v_Color v_UV v_PosP

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
    vec2 UV;
};

struct VS_Output
{
    vec4 PosVS;
    vec4 Color;
    vec2 UV;
    vec4 PosP;
};

VS_Output _main(VS_Input Input)
{
#if BGFX_SHADER_LANGUAGE_GLSL || BGFX_SHADER_LANGUAGE_ESSL
    VS_Output Output = VS_Output(vec4(0.0), vec4(0.0), vec2(0.0), vec4(0.0));
#else
    VS_Output Output = (VS_Output)0;
#endif
    vec4 worldPos = vec4(Input.Pos.x, Input.Pos.y, Input.Pos.z, 1.0);
    Output.PosVS = mul(u_mCameraProj, worldPos);
    Output.Color = Input.Color;
    vec2 uv1 = Input.UV;
    uv1.y = u_mUVInversed.x + (u_mUVInversed.y * uv1.y);
    Output.UV = uv1;
    Output.PosP = Output.PosVS;
    return Output;
}

void main()
{
    VS_Input Input;
    Input.Pos = a_position;
    Input.Color = a_color0;
    Input.UV = a_texcoord0;
    VS_Output flattenTemp = _main(Input);
    vec4 _position = flattenTemp.PosVS;
    gl_Position = _position;
    v_Color = flattenTemp.Color;
    v_UV = flattenTemp.UV;
    v_PosP = flattenTemp.PosP;
}
