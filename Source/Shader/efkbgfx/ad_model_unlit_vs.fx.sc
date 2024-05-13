$input a_position a_normal a_bitangent a_tangent a_texcoord0 a_color0
$output v_Color v_UV_Others v_WorldN v_Alpha_Dist_UV v_Blend_Alpha_Dist_UV v_Blend_FBNextIndex_UV v_PosP

#include <bgfx_shader.sh>
#include "defines.sh"
uniform mat4 u_mCameraProj;
uniform mat4 u_mModel_Inst[40];
uniform vec4 u_fUV[40];
uniform vec4 u_fAlphaUV[40];
uniform vec4 u_fUVDistortionUV[40];
uniform vec4 u_fBlendUV[40];
uniform vec4 u_fBlendAlphaUV[40];
uniform vec4 u_fBlendUVDistortionUV[40];
uniform vec4 u_flipbookParameter1;
uniform vec4 u_flipbookParameter2;
uniform vec4 u_fFlipbookIndexAndNextRate[40];
uniform vec4 u_fModelAlphaThreshold[40];
uniform vec4 u_fModelColor[40];
uniform vec4 u_fLightDirection;
uniform vec4 u_fLightColor;
uniform vec4 u_fLightAmbient;
uniform vec4 u_mUVInversed;


struct VS_Output
{
    vec4 PosVS;
    vec4 Color;
    vec4 UV_Others;
    vec3 WorldN;
    vec4 Alpha_Dist_UV;
    vec4 Blend_Alpha_Dist_UV;
    vec4 Blend_FBNextIndex_UV;
    vec4 PosP;
};

struct VS_Input
{
    vec3 Pos;
    vec3 Normal;
    vec3 Binormal;
    vec3 Tangent;
    vec2 UV;
    vec4 Color;
    uint Index;
};

vec2 GetFlipbookOriginUV(vec2 FlipbookUV, float FlipbookIndex, float DivideX, vec2 flipbookOneSize, vec2 flipbookOffset)
{
    vec2 DivideIndex;
    DivideIndex.x = mod(float(int(FlipbookIndex)), float(int(DivideX)));
    DivideIndex.y = float(int(FlipbookIndex) / int(DivideX));
    vec2 UVOffset = (DivideIndex * flipbookOneSize) + flipbookOffset;
    return FlipbookUV - UVOffset;
}

vec2 GetFlipbookUVForIndex(vec2 OriginUV, float Index, float DivideX, vec2 flipbookOneSize, vec2 flipbookOffset)
{
    vec2 DivideIndex;
    DivideIndex.x = mod(float(int(Index)), float(int(DivideX)));
    DivideIndex.y = float(int(Index) / int(DivideX));
    return (OriginUV + (DivideIndex * flipbookOneSize)) + flipbookOffset;
}

void ApplyFlipbookVS(inout float flipbookRate, inout vec2 flipbookUV, vec4 flipbookParameter1, vec4 flipbookParameter2, float flipbookIndex, vec2 uv, vec2 uvInversed)
{
    float flipbookEnabled = flipbookParameter1.x;
    float flipbookLoopType = flipbookParameter1.y;
    float divideX = flipbookParameter1.z;
    float divideY = flipbookParameter1.w;
    vec2 flipbookOneSize = flipbookParameter2.xy;
    vec2 flipbookOffset = flipbookParameter2.zw;
    if (flipbookEnabled > 0.0)
    {
        flipbookRate = fract(flipbookIndex);
        float Index = floor(flipbookIndex);
        float IndexOffset = 1.0;
        float NextIndex = Index + IndexOffset;
        float FlipbookMaxCount = divideX * divideY;
        if (flipbookLoopType == 0.0)
        {
            if (NextIndex >= FlipbookMaxCount)
            {
                NextIndex = FlipbookMaxCount - 1.0;
                Index = FlipbookMaxCount - 1.0;
            }
        }
        else
        {
            if (flipbookLoopType == 1.0)
            {
                Index = mod(Index, FlipbookMaxCount);
                NextIndex = mod(NextIndex, FlipbookMaxCount);
            }
            else
            {
                if (flipbookLoopType == 2.0)
                {
                    bool Reverse = mod(floor(Index / FlipbookMaxCount), 2.0) == 1.0;
                    Index = mod(Index, FlipbookMaxCount);
                    if (Reverse)
                    {
                        Index = (FlipbookMaxCount - 1.0) - floor(Index);
                    }
                    Reverse = mod(floor(NextIndex / FlipbookMaxCount), 2.0) == 1.0;
                    NextIndex = mod(NextIndex, FlipbookMaxCount);
                    if (Reverse)
                    {
                        NextIndex = (FlipbookMaxCount - 1.0) - floor(NextIndex);
                    }
                }
            }
        }
        vec2 notInversedUV = uv;
        notInversedUV.y = uvInversed.x + (uvInversed.y * notInversedUV.y);
        vec2 param = notInversedUV;
        float param_1 = Index;
        float param_2 = divideX;
        vec2 param_3 = flipbookOneSize;
        vec2 param_4 = flipbookOffset;
        vec2 OriginUV = GetFlipbookOriginUV(param, param_1, param_2, param_3, param_4);
        vec2 param_5 = OriginUV;
        float param_6 = NextIndex;
        float param_7 = divideX;
        vec2 param_8 = flipbookOneSize;
        vec2 param_9 = flipbookOffset;
        flipbookUV = GetFlipbookUVForIndex(param_5, param_6, param_7, param_8, param_9);
        flipbookUV.y = uvInversed.x + (uvInversed.y * flipbookUV.y);
    }
}

void CalculateAndStoreAdvancedParameter(vec2 uv, vec2 uv1, vec4 alphaUV, vec4 uvDistortionUV, vec4 blendUV, vec4 blendAlphaUV, vec4 blendUVDistortionUV, float flipbookIndexAndNextRate, float modelAlphaThreshold, inout VS_Output vsoutput)
{
    vsoutput.Alpha_Dist_UV.x = (uv.x * alphaUV.z) + alphaUV.x;
    vsoutput.Alpha_Dist_UV.y = (uv.y * alphaUV.w) + alphaUV.y;
    vsoutput.Alpha_Dist_UV.z = (uv.x * uvDistortionUV.z) + uvDistortionUV.x;
    vsoutput.Alpha_Dist_UV.w = (uv.y * uvDistortionUV.w) + uvDistortionUV.y;
    vsoutput.Blend_FBNextIndex_UV.x = (uv.x * blendUV.z) + blendUV.x;
    vsoutput.Blend_FBNextIndex_UV.y = (uv.y * blendUV.w) + blendUV.y;
    vsoutput.Blend_Alpha_Dist_UV.x = (uv.x * blendAlphaUV.z) + blendAlphaUV.x;
    vsoutput.Blend_Alpha_Dist_UV.y = (uv.y * blendAlphaUV.w) + blendAlphaUV.y;
    vsoutput.Blend_Alpha_Dist_UV.z = (uv.x * blendUVDistortionUV.z) + blendUVDistortionUV.x;
    vsoutput.Blend_Alpha_Dist_UV.w = (uv.y * blendUVDistortionUV.w) + blendUVDistortionUV.y;
    float flipbookRate = 0.0;
    vec2 flipbookNextIndexUV = vec2_splat(0.0);
    float param = flipbookRate;
    vec2 param_1 = flipbookNextIndexUV;
    vec4 param_2 = u_flipbookParameter1;
    vec4 param_3 = u_flipbookParameter2;
    float param_4 = flipbookIndexAndNextRate;
    vec2 param_5 = uv1;
    vec2 param_6 = vec2_splat(u_mUVInversed.xy);
    ApplyFlipbookVS(param, param_1, param_2, param_3, param_4, param_5, param_6);
    flipbookRate = param;
    flipbookNextIndexUV = param_1;
    vsoutput.Blend_FBNextIndex_UV.z = flipbookNextIndexUV.x;
    vsoutput.Blend_FBNextIndex_UV.w = flipbookNextIndexUV.y;
    vsoutput.UV_Others.z = flipbookRate;
    vsoutput.UV_Others.w = modelAlphaThreshold;
    vsoutput.Alpha_Dist_UV.y = u_mUVInversed.x + (u_mUVInversed.y * vsoutput.Alpha_Dist_UV.y);
    vsoutput.Alpha_Dist_UV.w = u_mUVInversed.x + (u_mUVInversed.y * vsoutput.Alpha_Dist_UV.w);
    vsoutput.Blend_FBNextIndex_UV.y = u_mUVInversed.x + (u_mUVInversed.y * vsoutput.Blend_FBNextIndex_UV.y);
    vsoutput.Blend_Alpha_Dist_UV.y = u_mUVInversed.x + (u_mUVInversed.y * vsoutput.Blend_Alpha_Dist_UV.y);
    vsoutput.Blend_Alpha_Dist_UV.w = u_mUVInversed.x + (u_mUVInversed.y * vsoutput.Blend_Alpha_Dist_UV.w);
}

VS_Output _main(VS_Input Input)
{
    uint index = Input.Index;
    mat4 mModel = u_mModel_Inst[index];
    vec4 uv = u_fUV[index];
    vec4 alphaUV = u_fAlphaUV[index];
    vec4 uvDistortionUV = u_fUVDistortionUV[index];
    vec4 blendUV = u_fBlendUV[index];
    vec4 blendAlphaUV = u_fBlendAlphaUV[index];
    vec4 blendUVDistortionUV = u_fBlendUVDistortionUV[index];
    vec4 modelColor = u_fModelColor[index] * Input.Color;
    float flipbookIndexAndNextRate = u_fFlipbookIndexAndNextRate[index].x;
    float modelAlphaThreshold = u_fModelAlphaThreshold[index].x;
#if BGFX_SHADER_LANGUAGE_GLSL || BGFX_SHADER_LANGUAGE_ESSL
    VS_Output Output = VS_Output(
        vec4(0.0), // PosVS
        vec4(0.0), // Color
        vec4(0.0), // UV_Others
        vec3(0.0), // WorldN
        vec4(0.0), // Alpha_Dist_UV
        vec4(0.0), // Blend_Alpha_Dist_UV
        vec4(0.0), // Blend_FBNextIndex_UV
        vec4(0.0)  // PosP
    );
#else
    VS_Output Output = (VS_Output)0;
#endif
    vec4 localPosition = vec4(Input.Pos.x, Input.Pos.y, Input.Pos.z, 1.0);
    vec4 worldPos = mul(mModel, localPosition);
    Output.PosVS = mul(u_mCameraProj, worldPos);
    vec2 outputUV = Input.UV;
    outputUV.x = (outputUV.x * uv.z) + uv.x;
    outputUV.y = (outputUV.y * uv.w) + uv.y;
    outputUV.y = u_mUVInversed.x + (u_mUVInversed.y * outputUV.y);
    Output.UV_Others.x = outputUV.x;
    Output.UV_Others.y = outputUV.y;
    vec4 localNormal = vec4(Input.Normal.x, Input.Normal.y, Input.Normal.z, 0.0);
    localNormal = normalize(mul(mModel, localNormal));
    Output.WorldN = localNormal.xyz;
    Output.Color = modelColor;
    vec2 param = Input.UV;
    vec2 param_1 = Output.UV_Others.xy;
    vec4 param_2 = alphaUV;
    vec4 param_3 = uvDistortionUV;
    vec4 param_4 = blendUV;
    vec4 param_5 = blendAlphaUV;
    vec4 param_6 = blendUVDistortionUV;
    float param_7 = flipbookIndexAndNextRate;
    float param_8 = modelAlphaThreshold;
    VS_Output param_9 = Output;
    CalculateAndStoreAdvancedParameter(param, param_1, param_2, param_3, param_4, param_5, param_6, param_7, param_8, param_9);
    Output = param_9;
    Output.PosP = Output.PosVS;
    return Output;
}

void main()
{
    VS_Input Input;
    Input.Pos = a_position;
    Input.Normal = a_normal;
    Input.Binormal = a_bitangent;
    Input.Tangent = a_tangent;
    Input.UV = a_texcoord0;
    Input.Color = a_color0;
    Input.Index = uint(gl_InstanceIndex);
    VS_Output flattenTemp = _main(Input);
    vec4 _position = flattenTemp.PosVS;
    gl_Position = _position;
    v_Color = flattenTemp.Color;
    v_UV_Others = flattenTemp.UV_Others;
    v_WorldN = flattenTemp.WorldN;
    v_Alpha_Dist_UV = flattenTemp.Alpha_Dist_UV;
    v_Blend_Alpha_Dist_UV = flattenTemp.Blend_Alpha_Dist_UV;
    v_Blend_FBNextIndex_UV = flattenTemp.Blend_FBNextIndex_UV;
    v_PosP = flattenTemp.PosP;
}
