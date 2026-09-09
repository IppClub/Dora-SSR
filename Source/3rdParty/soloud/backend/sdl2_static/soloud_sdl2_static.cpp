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
#include <stdint.h>
#include <string.h>
#include <math.h>

namespace SoLoud
{
	struct SDL2StaticBackendData
	{
		SDL_AudioSpec activeAudioSpec;
		SDL_AudioDeviceID audioDeviceID;
		SoLoud::Soloud *soloud;
		uint64_t generation;
	};

	static uint64_t gNextBackendGeneration = 0;

	void soloud_sdl2static_audiomixer(void *userdata, Uint8 *stream, int len)
	{
		SDL2StaticBackendData *backend = (SDL2StaticBackendData *)userdata;
		if (!backend || backend->generation == 0 || !backend->soloud)
		{
			memset(stream, 0, len);
			return;
		}
		short *buf = (short*)stream;
		if (backend->activeAudioSpec.format == AUDIO_F32)
		{
			int samples = len / (backend->activeAudioSpec.channels * sizeof(float));
			backend->soloud->mix((float *)buf, samples);
		}
		else // assume s16 if not float
		{
			int samples = len / (backend->activeAudioSpec.channels * sizeof(short));
			backend->soloud->mixSigned16(buf, samples);
		}
	}

	static void soloud_sdl2static_deinit(SoLoud::Soloud *aSoloud)
	{
		SDL2StaticBackendData *backend = (SDL2StaticBackendData *)aSoloud->mBackendData;
		if (!backend)
			return;
		if (backend->audioDeviceID)
		{
			// SDL holds the device lock while invoking the callback. Taking it here
			// waits for an in-flight mix and makes every later callback return silence.
			SDL_LockAudioDevice(backend->audioDeviceID);
			backend->generation = 0;
			backend->soloud = NULL;
			SDL_UnlockAudioDevice(backend->audioDeviceID);
			SDL_CloseAudioDevice(backend->audioDeviceID);
			backend->audioDeviceID = 0;
		}
		aSoloud->mBackendData = NULL;
		delete backend;
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

		SDL2StaticBackendData *backend = new SDL2StaticBackendData();
		memset(backend, 0, sizeof(*backend));
		backend->soloud = aSoloud;
		backend->generation = ++gNextBackendGeneration;

		SDL_AudioSpec as;
		memset(&as, 0, sizeof(as));
		as.freq = aSamplerate;
		as.format = AUDIO_F32;
		as.channels = aChannels;
		as.samples = aBuffer;
		as.callback = soloud_sdl2static_audiomixer;
		as.userdata = backend;

		backend->audioDeviceID = SDL_OpenAudioDevice(NULL, 0, &as, &backend->activeAudioSpec, SDL_AUDIO_ALLOW_ANY_CHANGE & ~(SDL_AUDIO_ALLOW_FORMAT_CHANGE | SDL_AUDIO_ALLOW_CHANNELS_CHANGE));
		if (backend->audioDeviceID == 0)
		{
			as.format = AUDIO_S16;
			backend->audioDeviceID = SDL_OpenAudioDevice(NULL, 0, &as, &backend->activeAudioSpec, SDL_AUDIO_ALLOW_ANY_CHANGE & ~(SDL_AUDIO_ALLOW_FORMAT_CHANGE | SDL_AUDIO_ALLOW_CHANNELS_CHANGE));
			if (backend->audioDeviceID == 0)
			{
				delete backend;
				return UNKNOWN_ERROR;
			}
		}

		aSoloud->postinit_internal(backend->activeAudioSpec.freq, backend->activeAudioSpec.samples, aFlags, backend->activeAudioSpec.channels);

		aSoloud->mBackendData = backend;
		aSoloud->mBackendCleanupFunc = soloud_sdl2static_deinit;

		SDL_PauseAudioDevice(backend->audioDeviceID, 0);
		aSoloud->mBackendString = "SDL2 (static)";
		return 0;
	}	
};
#endif
