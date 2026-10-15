$input v_Color v_UV v_WorldN v_WorldB v_WorldT v_PosP

#include <bgfx_shader.sh>
#include "defines.sh"
uniform vec4 u_fsfLightDirection;
uniform vec4 u_fsfLightColor;
uniform vec4 u_fsfLightAmbient;
uniform vec4 u_fsfFlipbookParameter;
uniform vec4 u_fsfUVDistortionParameter;
uniform vec4 u_fsfBlendTextureParameter;
uniform vec4 u_fsfCameraFrontDirection;
uniform vec4 u_fsfFalloffParameter;
uniform vec4 u_fsfFalloffBeginColor;
uniform vec4 u_fsfFalloffEndColor;
uniform vec4 u_fsfEmissiveScaling;
uniform vec4 u_fsfEdgeColor;
uniform vec4 u_fsfEdgeParameter;
uniform vec4 u_fssoftParticleParam;
uniform vec4 u_fsreconstructionParam1;
uniform vec4 u_fsreconstructionParam2;
uniform vec4 u_fsmUVInversedBack;
uniform vec4 u_fsmiscFlags;
SAMPLER2D (s_colorTex,0);
SAMPLER2D (s_normalTex,1);
SAMPLER2D (s_depthTex,2);

struct PS_Input
{
    vec4 PosVS;
    vec4 Color;
    vec2 UV;
    vec3 WorldN;
    vec3 WorldB;
    vec3 WorldT;
    vec4 PosP;
};

vec3 PositivePow(vec3 base, vec3 power)
{
    return pow(max(abs(base), vec3_splat(1.1920928955078125e-07)), power);
}

vec3 LinearToSRGB(vec3 c)
{
    vec3 param = c;
    vec3 param_1 = vec3_splat(0.4166666567325592041015625);
    return max((PositivePow(param, param_1) * 1.05499994754791259765625) - vec3_splat(0.054999999701976776123046875), vec3_splat(0.0));
}

vec4 LinearToSRGB(vec4 c)
{
    vec3 param = c.xyz;
    return vec4(LinearToSRGB(param), c.w);
}

vec4 ConvertFromSRGBTexture(vec4 c, bool isValid)
{
    if (!isValid)
    {
        return c;
    }
    vec4 param = c;
    return LinearToSRGB(param);
}

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

vec3 SRGBToLinear(vec3 c)
{
    return min(c, c * ((c * ((c * 0.305306017398834228515625) + vec3_splat(0.6821711063385009765625))) + vec3_splat(0.01252287812530994415283203125)));
}

vec4 SRGBToLinear(vec4 c)
{
    vec3 param = c.xyz;
    return vec4(SRGBToLinear(param), c.w);
}

vec4 ConvertToScreen(vec4 c, bool isValid)
{
    if (!isValid)
    {
        return c;
    }
    vec4 param = c;
    return SRGBToLinear(param);
}

vec4 _main(PS_Input Input)
{
    bool convertColorSpace = u_fsmiscFlags.x != 0.0;
    vec4 param = texture2D(s_colorTex, Input.UV);
    bool param_1 = convertColorSpace;
    vec4 Output = ConvertFromSRGBTexture(param, param_1) * Input.Color;
    vec3 texNormal = (texture2D(s_normalTex, Input.UV).xyz - vec3_splat(0.5)) * 2.0;
    vec3 localNormal = normalize(mul(mtxFromCols(Input.WorldT, Input.WorldB, Input.WorldN), texNormal));
    float diffuse = max(dot(u_fsfLightDirection.xyz, localNormal), 0.0);
    vec4 _300 = Output;
    vec3 _311 = _300.xyz * ((u_fsfLightColor.xyz * diffuse) + u_fsfLightAmbient.xyz);
    Output.x = _311.x;
    Output.y = _311.y;
    Output.z = _311.z;
    vec4 _321 = Output;
    vec3 _323 = _321.xyz * u_fsfEmissiveScaling.x;
    Output.x = _323.x;
    Output.y = _323.y;
    Output.z = _323.z;
    vec4 screenPos = Input.PosP / vec4_splat(Input.PosP.w);
    vec2 screenUV = (screenPos.xy + vec2_splat(1.0)) / vec2_splat(2.0);
    screenUV.y = 1.0 - screenUV.y;
    screenUV.y = u_fsmUVInversedBack.x + (u_fsmUVInversedBack.y * screenUV.y);
    if (u_fssoftParticleParam.w != 0.0)
    {
        float backgroundZ = texture2D(s_depthTex, screenUV).x;
        float param_2 = backgroundZ;
        float param_3 = screenPos.z;
        vec4 param_4 = u_fssoftParticleParam;
        vec4 param_5 = u_fsreconstructionParam1;
        vec4 param_6 = u_fsreconstructionParam2;
        Output.w *= SoftParticle(param_2, param_3, param_4, param_5, param_6);
    }
    if (Output.w == 0.0)
    {
        discard;
    }
    vec4 param_7 = Output;
    bool param_8 = convertColorSpace;
    return ConvertToScreen(param_7, param_8);
}

void main()
{
    PS_Input Input;
    Input.PosVS = gl_FragCoord;
#ifdef LINEAR_INPUT_COLOR
    Input.Color = to_linear(v_Color);
#else
    Input.Color = v_Color;
#endif //LINEAR_INPUT_COLOR

    Input.UV = v_UV;
    Input.WorldN = v_WorldN;
    Input.WorldB = v_WorldB;
    Input.WorldT = v_WorldT;
    Input.PosP = v_PosP;
    vec4 _435 = _main(Input);
    gl_FragColor = _435;
}
