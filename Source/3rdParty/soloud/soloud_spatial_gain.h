/*
SoLoud audio engine
Copyright (c) 2013-2015 Jari Komppa

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
      claim that you wrote the original software. If you use this software
      in a product, an acknowledgment in the product documentation would be
      appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
      misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
*/

#ifndef SOLOUD_SPATIAL_GAIN_H
#define SOLOUD_SPATIAL_GAIN_H

#include <algorithm>
#include <cmath>

namespace SoLoud
{
	inline constexpr float OPENAL_AIR_ABSORPTION_GAIN_HF = 0.99426f;
	inline constexpr float OPENAL_HF_REFERENCE = 5000.0f;

	struct HighShelfCoefficients
	{
		float b0 = 1.0f;
		float b1 = 0.0f;
		float b2 = 0.0f;
		float a1 = 0.0f;
		float a2 = 0.0f;
	};

	// OpenAL cone angles describe the full cone width, while the angle between
	// the source direction and source-to-listener vector is a half-angle.
	inline float calculateConeAttenuation(float aDirectionX, float aDirectionY,
		float aDirectionZ, float aListenerToSourceX, float aListenerToSourceY,
		float aListenerToSourceZ, float aInnerAngle, float aOuterAngle,
		float aOuterVolume)
	{
		const float directionMagnitude = std::sqrt(aDirectionX * aDirectionX
			+ aDirectionY * aDirectionY + aDirectionZ * aDirectionZ);
		if (directionMagnitude <= 0.0f || aInnerAngle >= 6.28318530717958647692f)
			return 1.0f;

		const float positionMagnitude = std::sqrt(aListenerToSourceX * aListenerToSourceX
			+ aListenerToSourceY * aListenerToSourceY
			+ aListenerToSourceZ * aListenerToSourceZ);
		float dot = 0.0f;
		if (positionMagnitude > 0.0f)
		{
			dot = -(aDirectionX * aListenerToSourceX
				+ aDirectionY * aListenerToSourceY
				+ aDirectionZ * aListenerToSourceZ)
				/ (directionMagnitude * positionMagnitude);
		}
		const float angle = 2.0f * std::acos(std::clamp(dot, -1.0f, 1.0f));
		if (angle >= aOuterAngle)
			return aOuterVolume;
		if (angle >= aInnerAngle)
		{
			const float scale = (angle - aInnerAngle) / (aOuterAngle - aInnerAngle);
			return 1.0f + (aOuterVolume - 1.0f) * scale;
		}
		return 1.0f;
	}

	inline float clampSourceGain(float aGain, float aMinVolume, float aMaxVolume)
	{
		return std::clamp(aGain, (std::min)(aMinVolume, aMaxVolume), aMaxVolume);
	}

	inline float calculateFinalSourceGain(float aGain, float aMinVolume, float aMaxVolume,
		bool aUseVolumeLimits, bool aUseApplicationDistance)
	{
		return aUseVolumeLimits || aUseApplicationDistance
			? clampSourceGain(aGain, aMinVolume, aMaxVolume)
			: aGain;
	}

	inline float calculateHighFrequencyAttenuation(float aDirectionX, float aDirectionY,
		float aDirectionZ, float aToListenerX, float aToListenerY, float aToListenerZ,
		float aInnerAngle, float aOuterAngle, float aOuterHighGain, float aDistance,
		float aReferenceDistance, float aRolloffFactor, float aAirAbsorptionFactor)
	{
		float gain = calculateConeAttenuation(aDirectionX, aDirectionY, aDirectionZ,
			aToListenerX, aToListenerY, aToListenerZ, aInnerAngle, aOuterAngle,
			aOuterHighGain);
		if (aDistance > aReferenceDistance && aAirAbsorptionFactor > 0.0f)
		{
			const float absorb = (aDistance - aReferenceDistance) * aRolloffFactor
				* aAirAbsorptionFactor;
			if (absorb > 0.0f)
				gain *= std::pow(OPENAL_AIR_ABSORPTION_GAIN_HF, absorb);
		}
		return gain;
	}

	inline HighShelfCoefficients calculateOpenALHighShelf(float aSamplerate,
		float aHighFrequencyGain, float aReferenceFrequency = OPENAL_HF_REFERENCE)
	{
		const float gain = (std::max)(aHighFrequencyGain, 0.001f);
		const float normalized = (std::min)(aReferenceFrequency / aSamplerate, 0.49f);
		const float w0 = 6.28318530717958647692f * normalized;
		const float sinW0 = std::sin(w0);
		const float cosW0 = std::cos(w0);
		const float alpha = sinW0 * 0.70710678118654752440f;
		const float sqrtGainAlpha2 = 2.0f * std::sqrt(gain) * alpha;
		const float b0 = gain * ((gain + 1.0f) + (gain - 1.0f) * cosW0 + sqrtGainAlpha2);
		const float b1 = -2.0f * gain * ((gain - 1.0f) + (gain + 1.0f) * cosW0);
		const float b2 = gain * ((gain + 1.0f) + (gain - 1.0f) * cosW0 - sqrtGainAlpha2);
		const float a0 = (gain + 1.0f) - (gain - 1.0f) * cosW0 + sqrtGainAlpha2;
		const float a1 = 2.0f * ((gain - 1.0f) - (gain + 1.0f) * cosW0);
		const float a2 = (gain + 1.0f) - (gain - 1.0f) * cosW0 - sqrtGainAlpha2;
		return {b0 / a0, b1 / a0, b2 / a0, a1 / a0, a2 / a0};
	}

	inline float processHighShelfSample(float aInput, const HighShelfCoefficients &aCoefficients,
		float &aState1, float &aState2)
	{
		const float output = aInput * aCoefficients.b0 + aState1;
		aState1 = aInput * aCoefficients.b1 - output * aCoefficients.a1 + aState2;
		aState2 = aInput * aCoefficients.b2 - output * aCoefficients.a2;
		return output;
	}
}

#endif
