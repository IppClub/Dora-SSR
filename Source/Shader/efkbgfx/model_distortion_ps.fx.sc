$input v_UV v_ProjBinormal v_ProjTangent v_PosP v_Color

#include <bgfx_shader.sh>
#include "defines.sh"
uniform vec4 u_fsg_scale;
uniform vec4 u_fsmUVInversedBack;
uniform vec4 u_fsfFlipbookParameter;
uniform vec4 u_fsfUVDistortionParameter;
uniform vec4 u_fsfBlendTextureParameter;
uniform vec4 u_fssoftParticleParam;
uniform vec4 u_fsreconstructionParam1;
uniform vec4 u_fsreconstructionParam2;
SAMPLER2D (s_colorTex,0);
SAMPLER2D (s_backTex,1);
SAMPLER2D (s_depthTex,2);

struct PS_Input
{
    vec4 PosVS;
    vec2 UV;
    vec4 ProjBinormal;
    vec4 ProjTangent;
    vec4 PosP;
    vec4 Color;
};

float SoftParticle(float backgroundZ, float meshZ, vec4 softparticleParam, vec4 reconstruct1, vec4 reconstruct2)
{
    float distanceFar = softparticleParam.x;
    float distanceNear = softparticleParam.y;
    float distanceNearOffset = softparticleParam.z;
    vec2 rescale = reconstruct1.xy;
    vec4 params = reconstruct2;
    vec2 zs = vec2((backgroundZ * rescale.x) + rescale.y, meshZ);
    vec2 depth = ((zs * params.w) - vec2_splat(params.y)) / (vec2_splat(params.x) - (zs * params.z));
    float dir = sign(depth.x);
    depth *= dir;
    float alphaFar = (depth.x - depth.y) / distanceFar;
    float alphaNear = (depth.y - distanceNearOffset) / distanceNear;
    return min(max(min(alphaFar, alphaNear), 0.0), 1.0);
}

vec4 _main(PS_Input Input)
{
    vec4 Output = texture2D(s_colorTex, Input.UV);
    Output.w *= Input.Color.w;
    vec2 pos = Input.PosP.xy / vec2_splat(Input.PosP.w);
    vec2 posR = Input.ProjTangent.xy / vec2_splat(Input.ProjTangent.w);
    vec2 posU = Input.ProjBinormal.xy / vec2_splat(Input.ProjBinormal.w);
    float xscale = (((Output.x * 2.0) - 1.0) * Input.Color.x) * u_fsg_scale.x;
    float yscale = (((Output.y * 2.0) - 1.0) * Input.Color.y) * u_fsg_scale.x;
    vec2 uv = (pos + ((posR - pos) * xscale)) + ((posU - pos) * yscale);
    uv.x = (uv.x + 1.0) * 0.5;
    uv.y = 1.0 - ((uv.y + 1.0) * 0.5);
    uv.y = u_fsmUVInversedBack.x + (u_fsmUVInversedBack.y * uv.y);
    vec3 color = vec3(texture2D(s_backTex, uv).xyz);
    Output.x = color.x;
    Output.y = color.y;
    Output.z = color.z;
    vec4 screenPos = Input.PosP / vec4_splat(Input.PosP.w);
    vec2 screenUV = (screenPos.xy + vec2_splat(1.0)) / vec2_splat(2.0);
    screenUV.y = 1.0 - screenUV.y;
    if (u_fssoftParticleParam.w != 0.0)
    {
        float backgroundZ = texture2D(s_depthTex, screenUV).x;
        float param = backgroundZ;
        float param_1 = screenPos.z;
        vec4 param_2 = u_fssoftParticleParam;
        vec4 param_3 = u_fsreconstructionParam1;
        vec4 param_4 = u_fsreconstructionParam2;
        Output.w *= SoftParticle(param, param_1, param_2, param_3, param_4);
    }
    if (Output.w == 0.0)
    {
        discard;
    }
    return Output;
}

void main()
{
    PS_Input Input;
    Input.PosVS = gl_FragCoord;
    Input.UV = v_UV;
    Input.ProjBinormal = v_ProjBinormal;
    Input.ProjTangent = v_ProjTangent;
    Input.PosP = v_PosP;
#ifdef LINEAR_INPUT_COLOR
    Input.Color = to_linear(v_Color);
#else
    Input.Color = v_Color;
#endif //LINEAR_INPUT_COLOR

    vec4 _314 = _main(Input);
    gl_FragColor = _314;
}
