$input v_color0, v_texcoord01, v_worldPos, v_worldNormal, v_worldTangent, v_shadowCoord

#include <bgfx_shader.sh>

SAMPLER2D(s_baseColor, 0);
SAMPLER2D(s_metallicRoughness, 1);
SAMPLER2D(s_normal, 2);
SAMPLER2D(s_emissive, 3);
SAMPLER2D(s_occlusion, 4);
SAMPLER2D(s_clearcoat, 5);
SAMPLER2D(s_clearcoatRoughness, 6);
SAMPLER2D(s_clearcoatNormal, 7);
SAMPLERCUBE(s_irradiance, 8);
SAMPLERCUBE(s_prefilter, 9);
SAMPLER2D(s_shadowMap, 10);
SAMPLER2D(s_specular, 11);
SAMPLER2D(s_specularColor, 12);
SAMPLER2D(s_transmission, 13);
#ifdef DORA_THICKNESS_SHEEN_TEXTURE
SAMPLER2D(s_thicknessSheen, 14);
#elif defined(DORA_SHEEN_ROUGHNESS_TEXTURE)
SAMPLER2D(s_sheenRoughness, 14);
#else
SAMPLER2D(s_thickness, 14);
#endif
SAMPLER2D(s_sheenColor, 15);

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
uniform vec4 u_clearcoat;
uniform vec4 u_transmission;
uniform vec4 u_volume;
uniform vec4 u_attenuationColor;
uniform vec4 u_sheen;
uniform vec4 u_anisotropy;
uniform vec4 u_uvBaseColor;
uniform vec4 u_uvBaseColorOffset;
uniform vec4 u_uvMetallicRoughness;
uniform vec4 u_uvMetallicRoughnessOffset;
uniform vec4 u_uvNormal;
uniform vec4 u_uvNormalOffset;
uniform vec4 u_uvEmissive;
uniform vec4 u_uvEmissiveOffset;
uniform vec4 u_uvOcclusion;
uniform vec4 u_uvOcclusionOffset;
uniform vec4 u_uvClearcoat;
uniform vec4 u_uvClearcoatOffset;
uniform vec4 u_uvClearcoatRoughness;
uniform vec4 u_uvClearcoatRoughnessOffset;
uniform vec4 u_uvClearcoatNormal;
uniform vec4 u_uvClearcoatNormalOffset;
uniform vec4 u_uvSpecular;
uniform vec4 u_uvSpecularOffset;
uniform vec4 u_uvSpecularColor;
uniform vec4 u_uvSpecularColorOffset;
uniform vec4 u_uvTransmission;
uniform vec4 u_uvTransmissionOffset;
#ifdef DORA_THICKNESS_SHEEN_TEXTURE
uniform vec4 u_uvThickness;
uniform vec4 u_uvThicknessOffset;
uniform vec4 u_uvSheenRoughness;
uniform vec4 u_uvSheenRoughnessOffset;
#elif defined(DORA_SHEEN_ROUGHNESS_TEXTURE)
uniform vec4 u_uvSheenRoughness;
uniform vec4 u_uvSheenRoughnessOffset;
#else
uniform vec4 u_uvThickness;
uniform vec4 u_uvThicknessOffset;
#endif
uniform vec4 u_uvSheenColor;
uniform vec4 u_uvSheenColorOffset;

#define PI 3.14159265359

vec2 transformUv(vec2 uv, vec4 transform, vec4 offset)
{
	return vec2(
		uv.x * transform.x + uv.y * transform.z + offset.x,
		uv.x * transform.y + uv.y * transform.w + offset.y);
}

vec2 selectUv(vec4 texcoord01, float uvSet)
{
	return uvSet > 0.5 ? texcoord01.zw : texcoord01.xy;
}

vec3 srgbToLinear(vec3 value)
{
	return pow(value, vec3_splat(2.2));
}

vec3 linearToSrgb(vec3 value)
{
	return pow(max(value, vec3_splat(0.0)), vec3_splat(1.0 / 2.2));
}

float saturateFloat(float value)
{
	return clamp(value, 0.0, 1.0);
}

vec3 getNormal(vec3 worldNormal, vec4 worldTangent, vec2 uv)
{
	vec3 normal = normalize(worldNormal);
	vec3 tangent = normalize(worldTangent.xyz);
	vec3 bitangent = normalize(cross(normal, tangent) * worldTangent.w);
	vec3 tangentNormal = texture2D(s_normal, uv).xyz * 2.0 - 1.0;
	tangentNormal.xy *= u_metallicRoughness.z;
	return normalize(tangent * tangentNormal.x + bitangent * tangentNormal.y + normal * tangentNormal.z);
}

vec3 getTextureNormal(vec3 worldNormal, vec4 worldTangent, vec2 uv, vec3 tangentNormal, float scale)
{
	vec3 normal = normalize(worldNormal);
	vec3 tangent = normalize(worldTangent.xyz);
	vec3 bitangent = normalize(cross(normal, tangent) * worldTangent.w);
	tangentNormal = tangentNormal * 2.0 - 1.0;
	tangentNormal.xy *= scale;
	return normalize(tangent * tangentNormal.x + bitangent * tangentNormal.y + normal * tangentNormal.z);
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

float distributionGGXAnisotropic(float nDotH, float tDotH, float bDotH, float ax, float ay)
{
	float denom = (tDotH * tDotH) / max(ax * ax, 0.000001) + (bDotH * bDotH) / max(ay * ay, 0.000001) + nDotH * nDotH;
	return 1.0 / max(PI * ax * ay * denom * denom, 0.000001);
}

float lambdaGGXAnisotropic(float nDotV, float tDotV, float bDotV, float ax, float ay)
{
	float numerator = (tDotV * ax) * (tDotV * ax) + (bDotV * ay) * (bDotV * ay);
	float value = numerator / max(nDotV * nDotV, 0.000001);
	return 0.5 * (-1.0 + sqrt(1.0 + value));
}

float visibilityGGXAnisotropic(float nDotL, float nDotV, float tDotL, float bDotL, float tDotV, float bDotV, float ax, float ay)
{
	float lambdaL = lambdaGGXAnisotropic(nDotL, tDotL, bDotL, ax, ay);
	float lambdaV = lambdaGGXAnisotropic(nDotV, tDotV, bDotV, ax, ay);
	return 1.0 / max(4.0 * nDotL * nDotV * (1.0 + lambdaL + lambdaV), 0.000001);
}

vec3 fresnelSchlick(float cosTheta, vec3 f0)
{
	return f0 + (vec3_splat(1.0) - f0) * pow(1.0 - cosTheta, 5.0);
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
	if (u_shadowParams.w < 0.5)
	{
		return 1.0;
	}
	vec3 coord = shadowCoord.xyz / max(shadowCoord.w, 0.000001);
	if (coord.x <= 0.0 || coord.x >= 1.0 || coord.y <= 0.0 || coord.y >= 1.0 || coord.z <= 0.0 || coord.z >= 1.0)
	{
		return 1.0;
	}
	float normalOffset = u_shadowParams.y * (1.0 - saturateFloat(dot(normal, lightDirection)));
	float receiverDepth = coord.z - u_shadowParams.x - normalOffset;
	float visibility = 0.0;
	vec2 texel = vec2_splat(u_shadowParams.z);
#define DORA_SHADOW_SAMPLE(_x, _y) \
	{ \
		vec4 packedDepth = texture2D(s_shadowMap, coord.xy + vec2(_x, _y) * texel); \
		float casterDepth = dot(packedDepth, vec4(0.000000059604645, 0.000015258789, 0.00390625, 1.0)); \
		visibility += receiverDepth <= casterDepth ? 1.0 : 0.0; \
	}
	DORA_SHADOW_SAMPLE(-1.5, -1.5)
	DORA_SHADOW_SAMPLE(-1.5, -0.5)
	DORA_SHADOW_SAMPLE(-1.5,  0.5)
	DORA_SHADOW_SAMPLE(-1.5,  1.5)
	DORA_SHADOW_SAMPLE(-0.5, -1.5)
	DORA_SHADOW_SAMPLE(-0.5, -0.5)
	DORA_SHADOW_SAMPLE(-0.5,  0.5)
	DORA_SHADOW_SAMPLE(-0.5,  1.5)
	DORA_SHADOW_SAMPLE( 0.5, -1.5)
	DORA_SHADOW_SAMPLE( 0.5, -0.5)
	DORA_SHADOW_SAMPLE( 0.5,  0.5)
	DORA_SHADOW_SAMPLE( 0.5,  1.5)
	DORA_SHADOW_SAMPLE( 1.5, -1.5)
	DORA_SHADOW_SAMPLE( 1.5, -0.5)
	DORA_SHADOW_SAMPLE( 1.5,  0.5)
	DORA_SHADOW_SAMPLE( 1.5,  1.5)
#undef DORA_SHADOW_SAMPLE
	return visibility / 16.0;
}

float maxValue(vec3 value)
{
	return max(value.x, max(value.y, value.z));
}

vec3 pbrNeutralToneMap(vec3 color)
{
	const float startCompression = 0.76;
	const float desaturation = 0.15;
	float lowestChannel = min(color.r, min(color.g, color.b));
	float offset = lowestChannel < 0.08 ? lowestChannel - 6.25 * lowestChannel * lowestChannel : 0.04;
	color -= offset;
	float peak = max(color.r, max(color.g, color.b));
	if (peak < startCompression)
	{
		return color;
	}
	float shoulder = 1.0 - startCompression;
	float compressedPeak = 1.0 - shoulder * shoulder / (peak + shoulder - startCompression);
	color *= compressedPeak / peak;
	float grayMix = 1.0 - 1.0 / (desaturation * (peak - compressedPeak) + 1.0);
	return mix(color, vec3_splat(compressedPeak), grayMix);
}

vec3 evaluateDirectLight(
	vec3 n,
	vec3 clearcoatNormal,
	vec3 v,
	vec3 anisotropyTangent,
	vec3 anisotropyBitangent,
	vec3 l,
	vec3 lightColor,
	vec3 baseColor,
	vec3 dielectricF0Color,
	vec3 dielectricF90Color,
	float metallic,
	float roughness,
	float clearcoatRoughness,
	float clearcoatFactor,
	vec3 sheenColor,
	float sheenRoughness,
	float anisotropyStrength,
	float transmissionFactor)
{
	vec3 h = normalize(v + l);
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
	if (anisotropyStrength > 0.0001)
	{
		float alpha = max(roughness * roughness, 0.001);
		float ax = max(alpha * (1.0 + anisotropyStrength), 0.001);
		float ay = max(alpha * (1.0 - anisotropyStrength), 0.001);
		float tDotH = dot(anisotropyTangent, h);
		float bDotH = dot(anisotropyBitangent, h);
		float tDotL = dot(anisotropyTangent, l);
		float bDotL = dot(anisotropyBitangent, l);
		float tDotV = dot(anisotropyTangent, v);
		float bDotV = dot(anisotropyBitangent, v);
		float dAniso = distributionGGXAnisotropic(nDotH, tDotH, bDotH, ax, ay);
		float vAniso = visibilityGGXAnisotropic(nDotL, nDotV, tDotL, bDotL, tDotV, bDotV, ax, ay);
		specular = dAniso * vAniso * f;
	}
	vec3 diffuse = vec3_splat(1.0 - maxValue(dielectricF)) * (1.0 - metallic) * baseColor / PI;
	float ccNDotL = saturateFloat(dot(clearcoatNormal, l));
	float ccNDotV = max(saturateFloat(dot(clearcoatNormal, v)), 0.000001);
	float ccNDotH = saturateFloat(dot(clearcoatNormal, h));
	float ccHDotV = saturateFloat(dot(h, v));
	float ccD = distributionGGX(ccNDotH, clearcoatRoughness);
	float ccG = geometrySchlickGGX(ccNDotV, clearcoatRoughness) * geometrySchlickGGX(ccNDotL, clearcoatRoughness);
	float ccF = fresnelSchlick(ccHDotV, vec3_splat(0.04)).x;
	vec3 clearcoatSpecular = vec3_splat((ccD * ccG * ccF) / max(4.0 * ccNDotV * ccNDotL, 0.000001) * ccNDotL * clearcoatFactor);
	float sheenPower = mix(8.0, 2.0, sheenRoughness);
	float sheenLobe = pow(max(1.0 - hDotV, 0.0), sheenPower) * (0.5 + 0.5 * sheenRoughness);
	vec3 sheenDirect = sheenColor * sheenLobe * nDotL * (1.0 - metallic);
	return (((diffuse * (1.0 - transmissionFactor)) + specular) * nDotL * (1.0 - 0.25 * clearcoatFactor) + clearcoatSpecular + sheenDirect) * lightColor;
}

void main()
{
	vec2 baseColorUv = transformUv(selectUv(v_texcoord01, u_uvBaseColorOffset.z), u_uvBaseColor, u_uvBaseColorOffset);
	vec2 metallicRoughnessUv = transformUv(selectUv(v_texcoord01, u_uvMetallicRoughnessOffset.z), u_uvMetallicRoughness, u_uvMetallicRoughnessOffset);
	vec2 normalUv = transformUv(selectUv(v_texcoord01, u_uvNormalOffset.z), u_uvNormal, u_uvNormalOffset);
	vec2 emissiveUv = transformUv(selectUv(v_texcoord01, u_uvEmissiveOffset.z), u_uvEmissive, u_uvEmissiveOffset);
	vec2 occlusionUv = transformUv(selectUv(v_texcoord01, u_uvOcclusionOffset.z), u_uvOcclusion, u_uvOcclusionOffset);
	vec2 clearcoatUv = transformUv(selectUv(v_texcoord01, u_uvClearcoatOffset.z), u_uvClearcoat, u_uvClearcoatOffset);
	vec2 clearcoatRoughnessUv = transformUv(selectUv(v_texcoord01, u_uvClearcoatRoughnessOffset.z), u_uvClearcoatRoughness, u_uvClearcoatRoughnessOffset);
	vec2 clearcoatNormalUv = transformUv(selectUv(v_texcoord01, u_uvClearcoatNormalOffset.z), u_uvClearcoatNormal, u_uvClearcoatNormalOffset);
	vec2 specularUv = transformUv(selectUv(v_texcoord01, u_uvSpecularOffset.z), u_uvSpecular, u_uvSpecularOffset);
	vec2 specularColorUv = transformUv(selectUv(v_texcoord01, u_uvSpecularColorOffset.z), u_uvSpecularColor, u_uvSpecularColorOffset);
	vec2 transmissionUv = transformUv(selectUv(v_texcoord01, u_uvTransmissionOffset.z), u_uvTransmission, u_uvTransmissionOffset);
#ifdef DORA_THICKNESS_SHEEN_TEXTURE
	vec2 thicknessUv = transformUv(selectUv(v_texcoord01, u_uvThicknessOffset.z), u_uvThickness, u_uvThicknessOffset);
	vec2 sheenRoughnessUv = transformUv(selectUv(v_texcoord01, u_uvSheenRoughnessOffset.z), u_uvSheenRoughness, u_uvSheenRoughnessOffset);
#elif defined(DORA_SHEEN_ROUGHNESS_TEXTURE)
	vec2 sheenRoughnessUv = transformUv(selectUv(v_texcoord01, u_uvSheenRoughnessOffset.z), u_uvSheenRoughness, u_uvSheenRoughnessOffset);
#else
	vec2 thicknessUv = transformUv(selectUv(v_texcoord01, u_uvThicknessOffset.z), u_uvThickness, u_uvThicknessOffset);
#endif
	vec2 sheenColorUv = transformUv(selectUv(v_texcoord01, u_uvSheenColorOffset.z), u_uvSheenColor, u_uvSheenColorOffset);
	vec4 baseSample = texture2D(s_baseColor, baseColorUv);
	vec4 baseColor = vec4(srgbToLinear(baseSample.rgb), baseSample.a) * u_baseColor * v_color0;
	if (u_alphaMode.x > 0.5 && u_alphaMode.x < 1.5 && baseColor.a < u_alphaMode.y)
	{
		discard;
	}

	vec4 metallicRoughness = texture2D(s_metallicRoughness, metallicRoughnessUv);
	float metallic = saturateFloat(u_metallicRoughness.x * metallicRoughness.b);
	float roughness = max(u_metallicRoughness.y * metallicRoughness.g, 0.04);
	float clearcoatFactor = saturateFloat(u_clearcoat.x * texture2D(s_clearcoat, clearcoatUv).r);
	float clearcoatRoughness = max(u_clearcoat.y * texture2D(s_clearcoatRoughness, clearcoatRoughnessUv).g, 0.04);
	float transmissionFactor = saturateFloat(u_transmission.x * texture2D(s_transmission, transmissionUv).r);
	vec3 sheenColor = u_sheen.rgb * srgbToLinear(texture2D(s_sheenColor, sheenColorUv).rgb);
#ifdef DORA_THICKNESS_SHEEN_TEXTURE
	float sheenRoughness = clamp(u_sheen.w * texture2D(s_thicknessSheen, sheenRoughnessUv).a, 0.0, 1.0);
#elif defined(DORA_SHEEN_ROUGHNESS_TEXTURE)
	float sheenRoughness = clamp(u_sheen.w * texture2D(s_sheenRoughness, sheenRoughnessUv).a, 0.0, 1.0);
#else
	float sheenRoughness = clamp(u_sheen.w, 0.0, 1.0);
#endif
	float occlusion = mix(1.0, texture2D(s_occlusion, occlusionUv).r, u_metallicRoughness.w);
	vec3 emissive = srgbToLinear(texture2D(s_emissive, emissiveUv).rgb) * u_emissiveFactor.rgb;
	if (u_materialExt.z > 0.5)
	{
		vec3 unlitColor = pbrNeutralToneMap((baseColor.rgb + emissive) * u_pbrParams.x);
		gl_FragColor = vec4(linearToSrgb(unlitColor), baseColor.a);
		return;
	}

	vec3 n = getNormal(v_worldNormal.xyz, v_worldTangent, normalUv);
	vec3 clearcoatNormal = getTextureNormal(
		v_worldNormal.xyz,
		v_worldTangent,
		clearcoatNormalUv,
		texture2D(s_clearcoatNormal, clearcoatNormalUv).xyz,
		u_clearcoat.z);
	vec3 v = normalize(u_viewPos.xyz - v_worldPos.xyz);
	float nDotV = max(saturateFloat(dot(n, v)), 0.000001);
	vec3 tangent = normalize(v_worldTangent.xyz - n * dot(n, v_worldTangent.xyz));
	vec3 bitangent = normalize(cross(n, tangent) * v_worldTangent.w);
	float anisotropyDirectionX = u_anisotropy.y;
	float anisotropyDirectionY = u_anisotropy.z;
	float anisotropyStrength = saturateFloat(u_anisotropy.x);
	if (u_anisotropy.w > 0.5)
	{
		float anisotropyAngle = metallicRoughness.r * (PI * 2.0) - PI;
		float textureDirectionX = cos(anisotropyAngle);
		float textureDirectionY = sin(anisotropyAngle);
		anisotropyDirectionX = textureDirectionX * u_anisotropy.y - textureDirectionY * u_anisotropy.z;
		anisotropyDirectionY = textureDirectionX * u_anisotropy.z + textureDirectionY * u_anisotropy.y;
		anisotropyStrength *= metallicRoughness.a;
	}
	vec3 anisotropyTangent = normalize(tangent * anisotropyDirectionX + bitangent * anisotropyDirectionY);
	vec3 anisotropyBitangent = normalize(cross(n, anisotropyTangent));

	float dielectricF0 = pow((u_materialExt.y - 1.0) / (u_materialExt.y + 1.0), 2.0);
	float specularStrength = saturateFloat(u_materialExt.x * texture2D(s_specular, specularUv).a);
	vec3 specularColorFactor = u_specularColor.rgb * srgbToLinear(texture2D(s_specularColor, specularColorUv).rgb);
	vec3 dielectricF0Color = min(vec3_splat(dielectricF0) * specularColorFactor, vec3_splat(1.0)) * specularStrength;
	vec3 dielectricF90Color = vec3_splat(specularStrength);
	float ccNDotV = max(saturateFloat(dot(clearcoatNormal, v)), 0.000001);
	float sheenStrength = maxValue(sheenColor);
	vec3 direct = vec3_splat(0.0);
	if (u_directionalLightDirection.w > 0.5)
	{
		vec3 directionalLight = normalize(u_directionalLightDirection.xyz);
		direct += evaluateDirectLight(n, clearcoatNormal, v, anisotropyTangent, anisotropyBitangent, directionalLight, u_directionalLightColor.rgb, baseColor.rgb, dielectricF0Color, dielectricF90Color, metallic, roughness, clearcoatRoughness, clearcoatFactor, sheenColor, sheenRoughness, anisotropyStrength, transmissionFactor) * directionalShadow(n, directionalLight, v_shadowCoord);
	}
	for (int lightIndex = 0; lightIndex < 4; ++lightIndex)
	{
		float range = u_pointLightPositionRange[lightIndex].w;
		vec3 offset = u_pointLightPositionRange[lightIndex].xyz - v_worldPos.xyz;
		float distanceToLight = length(offset);
		if (range > 0.0 && distanceToLight < range)
		{
			float normalizedDistance = distanceToLight / range;
			float cutoff = saturateFloat(1.0 - pow(normalizedDistance, 4.0));
			float lightAttenuation = cutoff * cutoff / max(distanceToLight * distanceToLight, 0.01);
			vec3 pointColor = u_pointLightColorIntensity[lightIndex].rgb * u_pointLightColorIntensity[lightIndex].w * lightAttenuation;
			direct += evaluateDirectLight(n, clearcoatNormal, v, anisotropyTangent, anisotropyBitangent, normalize(offset), pointColor, baseColor.rgb, dielectricF0Color, dielectricF90Color, metallic, roughness, clearcoatRoughness, clearcoatFactor, sheenColor, sheenRoughness, anisotropyStrength, transmissionFactor);
		}
	}
	vec3 dielectricFAmbient = fresnelSchlickRoughnessF90(nDotV, dielectricF0Color, dielectricF90Color, roughness);
	vec3 metalFAmbient = fresnelSchlickRoughnessF90(nDotV, baseColor.rgb, vec3_splat(1.0), roughness);
	vec3 kD = vec3_splat(1.0 - maxValue(dielectricFAmbient)) * (1.0 - metallic);
	vec3 overflowIrradiance = max(u_overflowLightSH[0].rgb + u_overflowLightSH[1].rgb * n.x + u_overflowLightSH[2].rgb * n.y + u_overflowLightSH[3].rgb * n.z, vec3_splat(0.0));
	direct += kD * baseColor.rgb * overflowIrradiance * occlusion * (1.0 - transmissionFactor) / PI;
	vec3 diffuseIrradiance = textureCube(s_irradiance, n).rgb * u_envDiffuse.a;
	vec3 diffuseAmbient = kD * baseColor.rgb * diffuseIrradiance * occlusion * (1.0 - transmissionFactor) / PI;
	vec3 r = reflect(-v, n);
	if (anisotropyStrength > 0.0001)
	{
		vec3 anisotropicR = normalize(
			anisotropyTangent * dot(r, anisotropyTangent) * (1.0 + anisotropyStrength) +
			anisotropyBitangent * dot(r, anisotropyBitangent) * (1.0 - anisotropyStrength) +
			n * max(dot(r, n), 0.0));
		r = normalize(mix(r, anisotropicR, anisotropyStrength));
	}
	float eta = 1.0 / max(u_materialExt.y, 0.001);
	vec3 transmissionDir = refract(-v, n, eta);
	transmissionDir = dot(transmissionDir, transmissionDir) > 0.000001 ? transmissionDir : -r;
	vec3 transmissionIrradiance = textureCubeLod(s_prefilter, transmissionDir, roughness * u_envSpecular.y).rgb * u_envSpecular.a;
	vec3 transmissionColor = transmissionIrradiance * baseColor.rgb * transmissionFactor * occlusion;
#ifdef DORA_THICKNESS_SHEEN_TEXTURE
	float thickness = max(u_volume.x * texture2D(s_thicknessSheen, thicknessUv).g, 0.0);
#elif defined(DORA_SHEEN_ROUGHNESS_TEXTURE)
	float thickness = 0.0;
#else
	float thickness = max(u_volume.x * texture2D(s_thickness, thicknessUv).g, 0.0);
#endif
	if (u_volume.y > 0.0 && thickness > 0.0)
	{
		vec3 attenuation = pow(clamp(u_attenuationColor.rgb, vec3_splat(0.0001), vec3_splat(1.0)), vec3_splat(thickness / u_volume.y));
		transmissionColor *= attenuation;
	}
	vec3 specularIrradiance = textureCubeLod(s_prefilter, r, roughness * u_envSpecular.y).rgb * u_envSpecular.a;
	vec2 envBRDF = environmentBRDF(nDotV, roughness);
	vec3 dielectricSpecularAmbient = specularIrradiance * (dielectricF0Color * envBRDF.x + dielectricF90Color * envBRDF.y);
	vec3 metalSpecularAmbient = specularIrradiance * (baseColor.rgb * envBRDF.x + vec3_splat(envBRDF.y));
	vec3 specularAmbient = mix(dielectricSpecularAmbient, metalSpecularAmbient, metallic) * occlusion;
	vec3 clearcoatR = reflect(-v, clearcoatNormal);
	vec2 clearcoatBRDF = environmentBRDF(ccNDotV, clearcoatRoughness);
	vec3 clearcoatAmbient = textureCubeLod(s_prefilter, clearcoatR, clearcoatRoughness * u_envSpecular.y).rgb * (0.04 * clearcoatBRDF.x + clearcoatBRDF.y) * clearcoatFactor * u_envSpecular.a * occlusion;
	vec3 sheenAmbient = diffuseIrradiance * sheenColor * sheenStrength * (0.25 + 0.5 * sheenRoughness) * occlusion;
	vec3 color = (diffuseAmbient * (1.0 - 0.25 * clearcoatFactor) + transmissionColor + specularAmbient + clearcoatAmbient + sheenAmbient + direct + emissive) * u_pbrParams.x;
	color = pbrNeutralToneMap(color);
	gl_FragColor = vec4(linearToSrgb(color), baseColor.a * (1.0 - 0.65 * transmissionFactor));
}
