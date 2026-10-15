$input v_color0, v_texcoord01, v_worldPos, v_worldNormal, v_worldTangent, v_shadowCoord

#include <bgfx_shader.sh>

#if BGFX_SHADER_LANGUAGE_GLSL >= 300
uniform highp samplerCube s_irradiance;
uniform highp samplerCube s_prefilter;
#else
SAMPLERCUBE(s_irradiance, 8);
SAMPLERCUBE(s_prefilter, 9);
#endif
SAMPLER2D(s_shadowMap, 10);

uniform vec4 u_viewPos;
uniform vec4 u_envDiffuse;
uniform vec4 u_envSpecular;
uniform vec4 u_pbrParams;
uniform vec4 u_directionalLightDirection;
uniform vec4 u_directionalLightColor;
uniform vec4 u_pointLightPositionRange[4];
uniform vec4 u_pointLightColorIntensity[4];
uniform vec4 u_overflowLightSH[4];
uniform vec4 u_shadowParams;
uniform vec4 u_baseColor;
uniform vec4 u_emissiveFactor;
uniform vec4 u_metallicRoughness;
uniform vec4 u_alphaMode;
uniform vec4 u_materialExt;
uniform vec4 u_specularColor;

#define PI 3.14159265359

float saturateFloat(float value)
{
	return clamp(value, 0.0, 1.0);
}

vec3 linearToSrgb(vec3 value)
{
	return pow(max(value, vec3_splat(0.0)), vec3_splat(1.0 / 2.2));
}

highp vec3 safeNormalize(highp vec3 value, highp vec3 fallback)
{
	highp float lengthSquared = dot(value, value);
	if (lengthSquared != lengthSquared || lengthSquared <= 0.000001) return fallback;
	return value * inversesqrt(lengthSquared);
}

float maxValue(vec3 value)
{
	return max(value.x, max(value.y, value.z));
}

float distributionGGX(float nDotH, float roughness)
{
	float alpha = roughness * roughness;
	float alpha2 = alpha * alpha;
	float denom = nDotH * nDotH * (alpha2 - 1.0) + 1.0;
	return alpha2 / max(PI * denom * denom, 0.000001);
}

float geometrySchlickGGX(float nDotV, float roughness)
{
	float r = roughness + 1.0;
	float k = (r * r) / 8.0;
	return nDotV / max(nDotV * (1.0 - k) + k, 0.000001);
}

vec3 fresnelSchlickF90(float cosTheta, vec3 f0, vec3 f90)
{
	return f0 + (f90 - f0) * pow(1.0 - cosTheta, 5.0);
}

vec3 fresnelSchlickRoughnessF90(float cosTheta, vec3 f0, vec3 f90, float roughness)
{
	vec3 roughF90 = max(f90 * (1.0 - roughness), f0);
	return f0 + (roughF90 - f0) * pow(1.0 - cosTheta, 5.0);
}

vec2 environmentBRDF(float nDotV, float roughness)
{
	vec4 c0 = vec4(-1.0, -0.0275, -0.572, 0.022);
	vec4 c1 = vec4(1.0, 0.0425, 1.04, -0.04);
	vec4 r = roughness * c0 + c1;
	float a004 = min(r.x * r.x, exp2(-9.28 * nDotV)) * r.x + r.y;
	return vec2(-1.04, 1.04) * a004 + r.zw;
}

float directionalShadow(vec3 normal, vec3 lightDirection, vec4 shadowCoord)
{
	if (u_shadowParams.w < 0.5) return 1.0;
	vec3 coord = shadowCoord.xyz / max(shadowCoord.w, 0.000001);
	if (coord.x <= 0.0 || coord.x >= 1.0 || coord.y <= 0.0 || coord.y >= 1.0 || coord.z <= 0.0 || coord.z >= 1.0) return 1.0;
	float normalOffset = u_shadowParams.y * (1.0 - saturateFloat(dot(normal, lightDirection)));
	float receiverDepth = coord.z - u_shadowParams.x - normalOffset;
	float visibility = 0.0;
	vec2 texel = vec2_splat(u_shadowParams.z);
#define DORA_SHADOW_SAMPLE(_x, _y, _weight) \
	{ \
		vec4 packedDepth = texture2D(s_shadowMap, coord.xy + vec2(_x, _y) * texel); \
		float casterDepth = dot(packedDepth, vec4(0.000000059604645, 0.000015258789, 0.00390625, 1.0)); \
		visibility += (receiverDepth <= casterDepth ? 1.0 : 0.0) * _weight; \
	}
	DORA_SHADOW_SAMPLE(-1.5, -1.5, 1.0)
	DORA_SHADOW_SAMPLE(-1.5, -0.5, 3.0)
	DORA_SHADOW_SAMPLE(-1.5,  0.5, 3.0)
	DORA_SHADOW_SAMPLE(-1.5,  1.5, 1.0)
	DORA_SHADOW_SAMPLE(-0.5, -1.5, 3.0)
	DORA_SHADOW_SAMPLE(-0.5, -0.5, 9.0)
	DORA_SHADOW_SAMPLE(-0.5,  0.5, 9.0)
	DORA_SHADOW_SAMPLE(-0.5,  1.5, 3.0)
	DORA_SHADOW_SAMPLE( 0.5, -1.5, 3.0)
	DORA_SHADOW_SAMPLE( 0.5, -0.5, 9.0)
	DORA_SHADOW_SAMPLE( 0.5,  0.5, 9.0)
	DORA_SHADOW_SAMPLE( 0.5,  1.5, 3.0)
	DORA_SHADOW_SAMPLE( 1.5, -1.5, 1.0)
	DORA_SHADOW_SAMPLE( 1.5, -0.5, 3.0)
	DORA_SHADOW_SAMPLE( 1.5,  0.5, 3.0)
	DORA_SHADOW_SAMPLE( 1.5,  1.5, 1.0)
#undef DORA_SHADOW_SAMPLE
	return visibility / 64.0;
}

vec3 evaluateDirectLight(
	vec3 n,
	vec3 v,
	vec3 l,
	vec3 lightColor,
	vec3 baseColor,
	vec3 dielectricF0Color,
	vec3 dielectricF90Color,
	float metallic,
	float roughness)
{
	highp vec3 h = safeNormalize(v + l, n);
	float nDotL = saturateFloat(dot(n, l));
	float nDotV = max(saturateFloat(dot(n, v)), 0.000001);
	float nDotH = saturateFloat(dot(n, h));
	float hDotV = saturateFloat(dot(h, v));
	vec3 dielectricF = fresnelSchlickF90(hDotV, dielectricF0Color, dielectricF90Color);
	vec3 metalF = fresnelSchlickF90(hDotV, baseColor, vec3_splat(1.0));
	vec3 f = mix(dielectricF, metalF, metallic);
	float d = distributionGGX(nDotH, roughness);
	float g = geometrySchlickGGX(nDotV, roughness) * geometrySchlickGGX(nDotL, roughness);
	vec3 specular = (d * g * f) / max(4.0 * nDotV * nDotL, 0.000001);
	vec3 diffuse = vec3_splat(1.0 - maxValue(dielectricF)) * (1.0 - metallic) * baseColor / PI;
	return (diffuse + specular) * nDotL * lightColor;
}

vec3 pbrNeutralToneMap(vec3 color)
{
	const float startCompression = 0.76;
	const float desaturation = 0.15;
	float lowestChannel = min(color.r, min(color.g, color.b));
	float offset = lowestChannel < 0.08 ? lowestChannel - 6.25 * lowestChannel * lowestChannel : 0.04;
	color -= offset;
	float peak = max(color.r, max(color.g, color.b));
	if (peak < startCompression) return color;
	float shoulder = 1.0 - startCompression;
	float compressedPeak = 1.0 - shoulder * shoulder / (peak + shoulder - startCompression);
	color *= compressedPeak / peak;
	float grayMix = 1.0 - 1.0 / (desaturation * (peak - compressedPeak) + 1.0);
	return mix(color, vec3_splat(compressedPeak), grayMix);
}

void main()
{
	highp vec4 baseColor = u_baseColor * v_color0;
	if (u_alphaMode.x > 0.5 && u_alphaMode.x < 1.5 && baseColor.a < u_alphaMode.y) discard;

	highp vec3 n = normalize(v_worldNormal.xyz);
	highp vec3 v = safeNormalize(u_viewPos.xyz - v_worldPos.xyz, n);
	float nDotV = max(saturateFloat(dot(n, v)), 0.000001);
	float metallic = saturateFloat(u_metallicRoughness.x);
	float roughness = max(u_metallicRoughness.y, 0.04);
	float dielectricF0 = pow((u_materialExt.y - 1.0) / (u_materialExt.y + 1.0), 2.0);
	float specularStrength = saturateFloat(u_materialExt.x);
	highp vec3 dielectricF0Color = min(vec3_splat(dielectricF0) * u_specularColor.rgb, vec3_splat(1.0)) * specularStrength;
	highp vec3 dielectricF90Color = vec3_splat(specularStrength);
	highp vec3 direct = vec3_splat(0.0);
	if (u_directionalLightDirection.w > 0.5)
	{
		vec3 directionalLight = normalize(u_directionalLightDirection.xyz);
		direct += evaluateDirectLight(n, v, directionalLight, u_directionalLightColor.rgb, baseColor.rgb, dielectricF0Color, dielectricF90Color, metallic, roughness) * directionalShadow(n, directionalLight, v_shadowCoord);
	}
	for (int lightIndex = 0; lightIndex < 4; ++lightIndex)
	{
		float range = u_pointLightPositionRange[lightIndex].w;
		vec3 lightOffset = u_pointLightPositionRange[lightIndex].xyz - v_worldPos.xyz;
		float distanceToLight = length(lightOffset);
		if (range > 0.0 && distanceToLight < range)
		{
			float normalizedDistance = distanceToLight / range;
			float cutoff = saturateFloat(1.0 - pow(normalizedDistance, 4.0));
			float attenuation = cutoff * cutoff / max(distanceToLight * distanceToLight, 0.01);
			vec3 pointColor = u_pointLightColorIntensity[lightIndex].rgb * u_pointLightColorIntensity[lightIndex].w * attenuation;
			direct += evaluateDirectLight(n, v, normalize(lightOffset), pointColor, baseColor.rgb, dielectricF0Color, dielectricF90Color, metallic, roughness);
		}
	}

	vec3 dielectricFAmbient = fresnelSchlickRoughnessF90(nDotV, dielectricF0Color, dielectricF90Color, roughness);
	vec3 metalFAmbient = fresnelSchlickRoughnessF90(nDotV, baseColor.rgb, vec3_splat(1.0), roughness);
	vec3 kD = vec3_splat(1.0 - maxValue(dielectricFAmbient)) * (1.0 - metallic);
	vec3 overflowIrradiance = max(u_overflowLightSH[0].rgb + u_overflowLightSH[1].rgb * n.x + u_overflowLightSH[2].rgb * n.y + u_overflowLightSH[3].rgb * n.z, vec3_splat(0.0));
	direct += kD * baseColor.rgb * overflowIrradiance / PI;
	highp vec3 diffuseIrradiance = textureCube(s_irradiance, n).rgb * u_envDiffuse.a;
	highp vec3 diffuseAmbient = kD * baseColor.rgb * diffuseIrradiance / PI;
	vec3 reflection = reflect(-v, n);
	highp vec3 specularIrradiance = textureCubeLod(s_prefilter, reflection, roughness * u_envSpecular.y).rgb * u_envSpecular.a;
	vec2 envBRDF = environmentBRDF(nDotV, roughness);
	vec3 dielectricSpecularAmbient = specularIrradiance * (dielectricF0Color * envBRDF.x + dielectricF90Color * envBRDF.y);
	vec3 metalSpecularAmbient = specularIrradiance * (baseColor.rgb * envBRDF.x + vec3_splat(envBRDF.y));
	highp vec3 color = (diffuseAmbient + mix(dielectricSpecularAmbient, metalSpecularAmbient, metallic) + direct + u_emissiveFactor.rgb) * u_pbrParams.x;
	color = pbrNeutralToneMap(color);
	gl_FragColor = vec4(linearToSrgb(color), baseColor.a);
}
