$input v_Color v_UV_Others v_WorldN v_WorldB v_WorldT v_Alpha_Dist_UV v_Blend_Alpha_Dist_UV v_Blend_FBNextIndex_UV v_PosP

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
SAMPLER2D (s_uvDistortionTex,3);
SAMPLER2D (s_colorTex,0);
SAMPLER2D (s_normalTex,1);
SAMPLER2D (s_alphaTex,2);
SAMPLER2D (s_blendUVDistortionTex,6);
SAMPLER2D (s_blendTex,4);
SAMPLER2D (s_blendAlphaTex,5);
SAMPLER2D (s_depthTex,7);

struct PS_Input
{
    vec4 PosVS;
    vec4 Color;
    vec4 UV_Others;
    vec3 WorldN;
    vec3 WorldB;
    vec3 WorldT;
    vec4 Alpha_Dist_UV;
    vec4 Blend_Alpha_Dist_UV;
    vec4 Blend_FBNextIndex_UV;
    vec4 PosP;
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
        vec4 _219 = dstColor;
        vec3 _222 = (blendColor.xyz * blendColor.w) + (_219.xyz * (1.0 - blendColor.w));
        dstColor.x = _222.x;
        dstColor.y = _222.y;
        dstColor.z = _222.z;
    }
    else
    {
        if (blendType == 1.0)
        {
            vec4 _237 = dstColor;
            vec3 _239 = _237.xyz + (blendColor.xyz * blendColor.w);
            dstColor.x = _239.x;
            dstColor.y = _239.y;
            dstColor.z = _239.z;
        }
        else
        {
            if (blendType == 2.0)
            {
                vec4 _254 = dstColor;
                vec3 _256 = _254.xyz - (blendColor.xyz * blendColor.w);
                dstColor.x = _256.x;
                dstColor.y = _256.y;
                dstColor.z = _256.z;
            }
            else
            {
                if (blendType == 3.0)
                {
                    vec4 _271 = dstColor;
                    vec3 _273 = _271.xyz * (blendColor.xyz * blendColor.w);
                    dstColor.x = _273.x;
                    dstColor.y = _273.y;
                    dstColor.z = _273.z;
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
    PS_Input param = Input;
    AdvancedParameter advancedParam = DisolveAdvancedParameter(param);
    vec2 param_1 = advancedParam.UVDistortionUV;
    vec2 param_2 = u_fsfUVDistortionParameter.zw;
    bool param_3 = convertColorSpace;
    vec2 UVOffset = UVDistortionOffsetDistortionTex(param_1, param_2, param_3);
    UVOffset *= u_fsfUVDistortionParameter.x;
    vec4 param_4 = texture2D(s_colorTex, Input.UV_Others.xy + UVOffset);
    bool param_5 = convertColorSpace;
    vec4 Output = ConvertFromSRGBTexture(param_4, param_5) * Input.Color;
    vec3 texNormal = (texture2D(s_normalTex, Input.UV_Others.xy + UVOffset).xyz - vec3_splat(0.5)) * 2.0;
    vec3 localNormal = normalize(mul(mtxFromCols(Input.WorldT, Input.WorldB, Input.WorldN), texNormal));
    vec4 param_6 = Output;
    float param_7 = advancedParam.FlipbookRate;
    bool param_8 = convertColorSpace;
    ApplyFlipbook(param_6, u_fsfFlipbookParameter, Input.Color, advancedParam.FlipbookNextIndexUV + UVOffset, param_7, param_8);
    Output = param_6;
    vec4 param_9 = texture2D(s_alphaTex, advancedParam.AlphaUV + UVOffset);
    bool param_10 = convertColorSpace;
    vec4 AlphaTexColor = ConvertFromSRGBTexture(param_9, param_10);
    Output.w *= (AlphaTexColor.x * AlphaTexColor.w);
    vec2 param_11 = advancedParam.BlendUVDistortionUV;
    vec2 param_12 = u_fsfUVDistortionParameter.zw;
    bool param_13 = convertColorSpace;
    vec2 BlendUVOffset = UVDistortionOffsetBlendUVDistortionTex(param_11, param_12, param_13);
    BlendUVOffset *= u_fsfUVDistortionParameter.y;
    vec4 param_14 = texture2D(s_blendTex, advancedParam.BlendUV + BlendUVOffset);
    bool param_15 = convertColorSpace;
    vec4 BlendTextureColor = ConvertFromSRGBTexture(param_14, param_15);
    vec4 param_16 = texture2D(s_blendAlphaTex, advancedParam.BlendAlphaUV + BlendUVOffset);
    bool param_17 = convertColorSpace;
    vec4 BlendAlphaTextureColor = ConvertFromSRGBTexture(param_16, param_17);
    BlendTextureColor.w *= (BlendAlphaTextureColor.x * BlendAlphaTextureColor.w);
    vec4 param_18 = Output;
    ApplyTextureBlending(param_18, BlendTextureColor, u_fsfBlendTextureParameter.x);
    Output = param_18;
    float diffuse = max(dot(u_fsfLightDirection.xyz, localNormal), 0.0);
    vec4 _633 = Output;
    vec3 _644 = _633.xyz * ((u_fsfLightColor.xyz * diffuse) + u_fsfLightAmbient.xyz);
    Output.x = _644.x;
    Output.y = _644.y;
    Output.z = _644.z;
    if (u_fsfFalloffParameter.x == 1.0)
    {
        vec3 cameraVec = normalize(-u_fsfCameraFrontDirection.xyz);
        float CdotN = clamp(dot(cameraVec, vec3(localNormal.x, localNormal.y, localNormal.z)), 0.0, 1.0);
        vec4 FalloffBlendColor = mix(u_fsfFalloffEndColor, u_fsfFalloffBeginColor, vec4_splat(pow(CdotN, u_fsfFalloffParameter.z)));
        if (u_fsfFalloffParameter.y == 0.0)
        {
            vec4 _692 = Output;
            vec3 _694 = _692.xyz + FalloffBlendColor.xyz;
            Output.x = _694.x;
            Output.y = _694.y;
            Output.z = _694.z;
        }
        else
        {
            if (u_fsfFalloffParameter.y == 1.0)
            {
                vec4 _709 = Output;
                vec3 _711 = _709.xyz - FalloffBlendColor.xyz;
                Output.x = _711.x;
                Output.y = _711.y;
                Output.z = _711.z;
            }
            else
            {
                if (u_fsfFalloffParameter.y == 2.0)
                {
                    vec4 _726 = Output;
                    vec3 _728 = _726.xyz * FalloffBlendColor.xyz;
                    Output.x = _728.x;
                    Output.y = _728.y;
                    Output.z = _728.z;
                }
            }
        }
        Output.w *= FalloffBlendColor.w;
    }
    vec4 _744 = Output;
    vec3 _746 = _744.xyz * u_fsfEmissiveScaling.x;
    Output.x = _746.x;
    Output.y = _746.y;
    Output.z = _746.z;
    vec4 screenPos = Input.PosP / vec4_splat(Input.PosP.w);
    vec2 screenUV = (screenPos.xy + vec2_splat(1.0)) / vec2_splat(2.0);
    screenUV.y = 1.0 - screenUV.y;
    screenUV.y = u_fsmUVInversedBack.x + (u_fsmUVInversedBack.y * screenUV.y);
    if (u_fssoftParticleParam.w != 0.0)
    {
        float backgroundZ = texture2D(s_depthTex, screenUV).x;
        float param_19 = backgroundZ;
        float param_20 = screenPos.z;
        vec4 param_21 = u_fssoftParticleParam;
        vec4 param_22 = u_fsreconstructionParam1;
        vec4 param_23 = u_fsreconstructionParam2;
        Output.w *= SoftParticle(param_19, param_20, param_21, param_22, param_23);
    }
    if (Output.w <= max(0.0, advancedParam.AlphaThreshold))
    {
        discard;
    }
    vec4 _832 = Output;
    float _835 = Output.w;
    vec3 _844 = mix(u_fsfEdgeColor.xyz * u_fsfEdgeParameter.y, _832.xyz, vec3_splat(ceil((_835 - advancedParam.AlphaThreshold) - u_fsfEdgeParameter.x)));
    Output.x = _844.x;
    Output.y = _844.y;
    Output.z = _844.z;
    vec4 param_24 = Output;
    bool param_25 = convertColorSpace;
    return ConvertToScreen(param_24, param_25);
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

    Input.UV_Others = v_UV_Others;
    Input.WorldN = v_WorldN;
    Input.WorldB = v_WorldB;
    Input.WorldT = v_WorldT;
    Input.Alpha_Dist_UV = v_Alpha_Dist_UV;
    Input.Blend_Alpha_Dist_UV = v_Blend_Alpha_Dist_UV;
    Input.Blend_FBNextIndex_UV = v_Blend_FBNextIndex_UV;
    Input.PosP = v_PosP;
    vec4 _894 = _main(Input);
    gl_FragColor = _894;
}
