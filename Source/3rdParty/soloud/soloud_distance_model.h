/*
SoLoud audio engine
Copyright (c) 2013-2020 Jari Komppa

This altered source file adds OpenAL-compatible application distance models
for Dora's embedded Love runtime. It remains under SoLoud's zlib/libpng-style
license; see LICENSE in this directory.
*/

#ifndef SOLOUD_DISTANCE_MODEL_H
#define SOLOUD_DISTANCE_MODEL_H

#include <algorithm>
#include <cmath>

namespace SoLoud
{
	enum DISTANCE_MODELS
	{
		DISTANCE_NONE = 0,
		DISTANCE_INVERSE,
		DISTANCE_INVERSE_CLAMPED,
		DISTANCE_LINEAR,
		DISTANCE_LINEAR_CLAMPED,
		DISTANCE_EXPONENT,
		DISTANCE_EXPONENT_CLAMPED,
		DISTANCE_MODEL_COUNT
	};

	// Matches OpenAL Soft's distance attenuation rules. The returned factor is
	// intentionally not capped at 1: OpenAL applies source min/max gain after
	// multiplying it by the source gain.
	inline float calculateDistanceAttenuation(DISTANCE_MODELS aModel, float aDistance,
		float aReferenceDistance, float aMaxDistance, float aRolloffFactor)
	{
		float distance = aDistance;
		switch (aModel)
		{
		case DISTANCE_INVERSE_CLAMPED:
		case DISTANCE_LINEAR_CLAMPED:
		case DISTANCE_EXPONENT_CLAMPED:
			if (aReferenceDistance <= aMaxDistance)
				distance = std::clamp(distance, aReferenceDistance, aMaxDistance);
			else
				distance = aReferenceDistance;
			break;
		default:
			break;
		}

		switch (aModel)
		{
		case DISTANCE_INVERSE:
		case DISTANCE_INVERSE_CLAMPED:
			if (aReferenceDistance > 0.0f)
			{
				const float denominator = aReferenceDistance
					+ aRolloffFactor * (distance - aReferenceDistance);
				if (denominator > 0.0f)
					return aReferenceDistance / denominator;
			}
			return 1.0f;

		case DISTANCE_LINEAR:
		case DISTANCE_LINEAR_CLAMPED:
			if (aMaxDistance != aReferenceDistance)
			{
				const float scale = (distance - aReferenceDistance)
					/ (aMaxDistance - aReferenceDistance);
					return (std::max)(1.0f - scale * aRolloffFactor, 0.0f);
			}
			return 1.0f;

		case DISTANCE_EXPONENT:
		case DISTANCE_EXPONENT_CLAMPED:
			if (distance > 0.0f && aReferenceDistance > 0.0f)
				return std::pow(distance / aReferenceDistance, -aRolloffFactor);
			return 1.0f;

		case DISTANCE_NONE:
		default:
			return 1.0f;
		}
	}
}

#endif
