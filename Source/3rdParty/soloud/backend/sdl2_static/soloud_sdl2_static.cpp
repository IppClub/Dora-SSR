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
#include <stdlib.h>
#include <atomic>
#include <cstdio>

#include "soloud.h"

#if !defined(WITH_SDL2_STATIC)

namespace SoLoud
{
	result sdl2static_init(SoLoud::Soloud *aSoloud, unsigned int aFlags, unsigned int aSamplerate, unsigned int aBuffer)
	{
		return NOT_IMPLEMENTED;
	}
}

#else

#include "SDL.h"
#include <math.h>

namespace SoLoud
{
	static SDL_AudioSpec gActiveAudioSpec;
	static SDL_AudioDeviceID gAudioDeviceID;
	static std::atomic<unsigned long long> gAudioCallbackCount{0};
	static std::atomic<unsigned long long> gAudioDeviceGeneration{0};

	static bool audioTraceSample(unsigned long long count)
	{
		return count <= 3;
	}

	void soloud_sdl2static_audiomixer(void *userdata, Uint8 *stream, int len)
	{
		const auto callbackCount = gAudioCallbackCount.fetch_add(1, std::memory_order_relaxed) + 1;
		SoLoud::Soloud *soloud = (SoLoud::Soloud *)userdata;
		if (audioTraceSample(callbackCount))
			std::fprintf(stderr,
				"[DoraAudioTrace] SDL mixer callback=%llu device=%u generation=%llu userdata=%p len=%d format=%u channels=%u samples=%u\n",
				callbackCount, static_cast<unsigned int>(gAudioDeviceID),
				gAudioDeviceGeneration.load(std::memory_order_relaxed), userdata, len,
				static_cast<unsigned int>(gActiveAudioSpec.format),
				static_cast<unsigned int>(gActiveAudioSpec.channels),
				static_cast<unsigned int>(gActiveAudioSpec.samples));
		if (!soloud || !stream || len <= 0)
			return;
		short *buf = (short*)stream;
		if (gActiveAudioSpec.format == AUDIO_F32)
		{
			int samples = len / (gActiveAudioSpec.channels * sizeof(float));
			soloud->mix((float *)buf, samples);
		}
		else // assume s16 if not float
		{
			int samples = len / (gActiveAudioSpec.channels * sizeof(short));
			soloud->mixSigned16(buf, samples);
		}
	}

	static void soloud_sdl2static_deinit(SoLoud::Soloud *aSoloud)
	{
		std::fprintf(stderr,
			"[DoraAudioTrace] SDL deinit device=%u generation=%llu userdata=%p callbacks=%llu\n",
			static_cast<unsigned int>(gAudioDeviceID),
			gAudioDeviceGeneration.load(std::memory_order_relaxed), aSoloud,
			gAudioCallbackCount.load(std::memory_order_relaxed));
		SDL_PauseAudioDevice(gAudioDeviceID, 1);
		SDL_CloseAudioDevice(gAudioDeviceID);
		gAudioDeviceID = 0;
	}

	result sdl2static_init(SoLoud::Soloud *aSoloud, unsigned int aFlags, unsigned int aSamplerate, unsigned int aBuffer, unsigned int aChannels)
	{
		if (!SDL_WasInit(SDL_INIT_AUDIO))
		{
			if (SDL_InitSubSystem(SDL_INIT_AUDIO) < 0)
			{
				return UNKNOWN_ERROR;
			}
		}

		SDL_AudioSpec as;
		as.freq = aSamplerate;
		as.format = AUDIO_F32;
		as.channels = aChannels;
		as.samples = aBuffer;
		as.callback = soloud_sdl2static_audiomixer;
		as.userdata = (void*)aSoloud;

		gAudioDeviceID = SDL_OpenAudioDevice(NULL, 0, &as, &gActiveAudioSpec, SDL_AUDIO_ALLOW_ANY_CHANGE & ~(SDL_AUDIO_ALLOW_FORMAT_CHANGE | SDL_AUDIO_ALLOW_CHANNELS_CHANGE));
		if (gAudioDeviceID == 0)
		{
			as.format = AUDIO_S16;
			gAudioDeviceID = SDL_OpenAudioDevice(NULL, 0, &as, &gActiveAudioSpec, SDL_AUDIO_ALLOW_ANY_CHANGE & ~(SDL_AUDIO_ALLOW_FORMAT_CHANGE | SDL_AUDIO_ALLOW_CHANNELS_CHANGE));
			if (gAudioDeviceID == 0)
			{
				return UNKNOWN_ERROR;
			}
		}
		gAudioDeviceGeneration.fetch_add(1, std::memory_order_relaxed);
		gAudioCallbackCount.store(0, std::memory_order_relaxed);
		std::fprintf(stderr,
			"[DoraAudioTrace] SDL initialized device=%u generation=%llu userdata=%p requestedRate=%u requestedBuffer=%u obtainedRate=%d obtainedBuffer=%u format=%u channels=%u\n",
			static_cast<unsigned int>(gAudioDeviceID),
			gAudioDeviceGeneration.load(std::memory_order_relaxed), aSoloud,
			aSamplerate, aBuffer, gActiveAudioSpec.freq,
			static_cast<unsigned int>(gActiveAudioSpec.samples),
			static_cast<unsigned int>(gActiveAudioSpec.format),
			static_cast<unsigned int>(gActiveAudioSpec.channels));

		aSoloud->postinit_internal(gActiveAudioSpec.freq, gActiveAudioSpec.samples, aFlags, gActiveAudioSpec.channels);

		aSoloud->mBackendCleanupFunc = soloud_sdl2static_deinit;

		SDL_PauseAudioDevice(gAudioDeviceID, 0);
		aSoloud->mBackendString = "SDL2 (static)";
		return 0;
	}	
};
#endif
