$input v_UV_Others v_ProjBinormal v_ProjTangent v_PosP v_Color v_Alpha_Dist_UV v_Blend_Alpha_Dist_UV v_Blend_FBNextIndex_UV

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
SAMPLER2D (s_uvDistortionTex,3);
SAMPLER2D (s_colorTex,0);
SAMPLER2D (s_alphaTex,2);
SAMPLER2D (s_blendUVDistortionTex,6);
SAMPLER2D (s_blendTex,4);
SAMPLER2D (s_blendAlphaTex,5);
SAMPLER2D (s_backTex,1);
SAMPLER2D (s_depthTex,7);

struct PS_Input
{
    vec4 PosVS;
    vec4 UV_Others;
    vec4 ProjBinormal;
    vec4 ProjTangent;
    vec4 PosP;
    vec4 Color;
    vec4 Alpha_Dist_UV;
    vec4 Blend_Alpha_Dist_UV;
    vec4 Blend_FBNextIndex_UV;
};

struct AdvancedParameter
{
    vec2 AlphaUV;
    vec2 UVDistortionUV;
    vec2 BlendUV;
    vec2 BlendAlphaUV;
    vec2 BlendUVDistortionUV;
    vec2 FlipbookNextIndexUV;
    float FlipbookRate;
    float AlphaThreshold;
};

AdvancedParameter DisolveAdvancedParameter(PS_Input psinput)
{
    AdvancedParameter ret;
    ret.AlphaUV = psinput.Alpha_Dist_UV.xy;
    ret.UVDistortionUV = psinput.Alpha_Dist_UV.zw;
    ret.BlendUV = psinput.Blend_FBNextIndex_UV.xy;
    ret.BlendAlphaUV = psinput.Blend_Alpha_Dist_UV.xy;
    ret.BlendUVDistortionUV = psinput.Blend_Alpha_Dist_UV.zw;
    ret.FlipbookNextIndexUV = psinput.Blend_FBNextIndex_UV.zw;
    ret.FlipbookRate = psinput.UV_Others.z;
    ret.AlphaThreshold = psinput.UV_Others.w;
    return ret;
}

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

vec2 UVDistortionOffsetDistortionTex(vec2 uv, vec2 uvInversed, bool convertFromSRGB)
{
    vec4 sampledColor = texture2D(s_uvDistortionTex, uv);
    if (convertFromSRGB)
    {
        vec4 param = sampledColor;
        bool param_1 = convertFromSRGB;
        sampledColor = ConvertFromSRGBTexture(param, param_1);
    }
    vec2 UVOffset = (sampledColor.xy * 2.0) - vec2_splat(1.0);
    UVOffset.y *= (-1.0);
    UVOffset.y = uvInversed.x + (uvInversed.y * UVOffset.y);
    return UVOffset;
}

vec2 UVDistortionOffsetBlendUVDistortionTex(vec2 uv, vec2 uvInversed, bool convertFromSRGB)
{
    vec4 sampledColor = texture2D(s_blendUVDistortionTex, uv);
    if (convertFromSRGB)
    {
        vec4 param = sampledColor;
        bool param_1 = convertFromSRGB;
        sampledColor = ConvertFromSRGBTexture(param, param_1);
    }
    vec2 UVOffset = (sampledColor.xy * 2.0) - vec2_splat(1.0);
    UVOffset.y *= (-1.0);
    UVOffset.y = uvInversed.x + (uvInversed.y * UVOffset.y);
    return UVOffset;
}

void ApplyFlipbook(inout vec4 dst, vec4 flipbookParameter, vec4 vcolor, vec2 nextUV, float flipbookRate, bool convertFromSRGB)
{
    if (flipbookParameter.x > 0.0)
    {
        vec4 sampledColor = texture2D(s_colorTex, nextUV);
        if (convertFromSRGB)
        {
            vec4 param = sampledColor;
            bool param_1 = convertFromSRGB;
            sampledColor = ConvertFromSRGBTexture(param, param_1);
        }
        vec4 NextPixelColor = sampledColor * vcolor;
        if (flipbookParameter.y == 1.0)
        {
            dst = mix(dst, NextPixelColor, vec4_splat(flipbookRate));
        }
    }
}

void ApplyTextureBlending(inout vec4 dstColor, vec4 blendColor, float blendType)
{
    if (blendType == 0.0)
    {
        vec4 _169 = dstColor;
        vec3 _172 = (blendColor.xyz * blendColor.w) + (_169.xyz * (1.0 - blendColor.w));
        dstColor.x = _172.x;
        dstColor.y = _172.y;
        dstColor.z = _172.z;
    }
    else
    {
        if (blendType == 1.0)
        {
            vec4 _187 = dstColor;
            vec3 _189 = _187.xyz + (blendColor.xyz * blendColor.w);
            dstColor.x = _189.x;
            dstColor.y = _189.y;
            dstColor.z = _189.z;
        }
        else
        {
            if (blendType == 2.0)
            {
                vec4 _204 = dstColor;
                vec3 _206 = _204.xyz - (blendColor.xyz * blendColor.w);
                dstColor.x = _206.x;
                dstColor.y = _206.y;
                dstColor.z = _206.z;
            }
            else
            {
                if (blendType == 3.0)
                {
                    vec4 _221 = dstColor;
                    vec3 _223 = _221.xyz * (blendColor.xyz * blendColor.w);
                    dstColor.x = _223.x;
                    dstColor.y = _223.y;
                    dstColor.z = _223.z;
                }
            }
        }
    }
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

vec4 _main(PS_Input Input)
{
    PS_Input param = Input;
    AdvancedParameter advancedParam = DisolveAdvancedParameter(param);
    vec2 param_1 = advancedParam.UVDistortionUV;
    vec2 param_2 = u_fsfUVDistortionParameter.zw;
    bool param_3 = false;
    vec2 UVOffset = UVDistortionOffsetDistortionTex(param_1, param_2, param_3);
    UVOffset *= u_fsfUVDistortionParameter.x;
    vec4 Output = texture2D(s_colorTex, vec2_splat(Input.UV_Others.xy) + UVOffset);
    Output.w *= Input.Color.w;
    vec4 param_4 = Output;
    float param_5 = advancedParam.FlipbookRate;
    bool param_6 = false;
    ApplyFlipbook(param_4, u_fsfFlipbookParameter, Input.Color, advancedParam.FlipbookNextIndexUV + UVOffset, param_5, param_6);
    Output = param_4;
    vec4 AlphaTexColor = texture2D(s_alphaTex, advancedParam.AlphaUV + UVOffset);
    Output.w *= (AlphaTexColor.x * AlphaTexColor.w);
    vec2 param_7 = advancedParam.BlendUVDistortionUV;
    vec2 param_8 = u_fsfUVDistortionParameter.zw;
    bool param_9 = false;
    vec2 BlendUVOffset = UVDistortionOffsetBlendUVDistortionTex(param_7, param_8, param_9);
    BlendUVOffset *= u_fsfUVDistortionParameter.y;
    vec4 BlendTextureColor = texture2D(s_blendTex, advancedParam.BlendUV + BlendUVOffset);
    vec4 BlendAlphaTextureColor = texture2D(s_blendAlphaTex, advancedParam.BlendAlphaUV + BlendUVOffset);
    BlendTextureColor.w *= (BlendAlphaTextureColor.x * BlendAlphaTextureColor.w);
    vec4 param_10 = Output;
    ApplyTextureBlending(param_10, BlendTextureColor, u_fsfBlendTextureParameter.x);
    Output = param_10;
    if (Output.w <= max(0.0, advancedParam.AlphaThreshold))
    {
        discard;
    }
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
        float param_11 = backgroundZ;
        float param_12 = screenPos.z;
        vec4 param_13 = u_fssoftParticleParam;
        vec4 param_14 = u_fsreconstructionParam1;
        vec4 param_15 = u_fsreconstructionParam2;
        Output.w *= SoftParticle(param_11, param_12, param_13, param_14, param_15);
    }
    return Output;
}

void main()
{
    PS_Input Input;
    Input.PosVS = gl_FragCoord;
    Input.UV_Others = v_UV_Others;
    Input.ProjBinormal = v_ProjBinormal;
    Input.ProjTangent = v_ProjTangent;
    Input.PosP = v_PosP;
#ifdef LINEAR_INPUT_COLOR
    Input.Color = to_linear(v_Color);
#else
    Input.Color = v_Color;
#endif //LINEAR_INPUT_COLOR

    Input.Alpha_Dist_UV = v_Alpha_Dist_UV;
    Input.Blend_Alpha_Dist_UV = v_Blend_Alpha_Dist_UV;
    Input.Blend_FBNextIndex_UV = v_Blend_FBNextIndex_UV;
    vec4 _706 = _main(Input);
    gl_FragColor = _706;
}
