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
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

namespace SoLoud
{
	struct SDL2StaticBackendData
	{
		SDL_AudioSpec activeAudioSpec;
		SDL_AudioDeviceID audioDeviceID;
		SoLoud::Soloud *soloud;
		uint64_t generation;
#ifdef __EMSCRIPTEN__
		float *webBuffer;
#endif
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
#ifdef __EMSCRIPTEN__
		MAIN_THREAD_EM_ASM({ Module.doraLegacyAudio?.dispose(); });
		SDL_free(backend->webBuffer);
#endif
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
#ifdef __EMSCRIPTEN__
		// Dora's Web backend owns the JS boundary: browser exceptions must become
		// a failed optional backend, rather than unwind through SDL's device locks.
		SDL2StaticBackendData *backend = new SDL2StaticBackendData();
		backend->soloud = aSoloud;
		backend->generation = ++gNextBackendGeneration;
		backend->activeAudioSpec.format = AUDIO_F32;
		backend->activeAudioSpec.channels = aChannels;
		backend->webBuffer = (float *)SDL_malloc(aBuffer * aChannels * sizeof(float));
		if (!backend->webBuffer) { delete backend; return OUT_OF_MEMORY; }
		int rate = MAIN_THREAD_EM_ASM_INT({
			return (() => {
			const workletReady = Module.doraAudio?.ready;
			let context, node, timer;
			let warned = false, disposed = false;
			const warn = error => {
				if (warned) return;
				warned = true;
				console.warn(workletReady ? '[DoraAudio] Legacy audio unavailable; continuing with AudioWorklet:' : '[DoraAudio] Legacy audio unavailable; continuing muted:', error);
			};
			const resume = () => {
				try { if (!disposed && context.state === 'suspended') Promise.resolve(context.resume()).catch(warn); }
				catch (error) { warn(error); }
			};
			const dispose = () => {
				if (disposed) return;
				disposed = true;
				clearInterval(timer);
				globalThis.removeEventListener('pointerdown', resume, true);
				globalThis.removeEventListener('keydown', resume, true);
				if (node) node.onaudioprocess = null;
				try { node?.disconnect(); } catch (error) { warn(error); }
				try { if (context) Promise.resolve(context.close()).catch(warn); } catch (error) { warn(error); }
			};
			try {
				const Context = globalThis.AudioContext || globalThis.webkitAudioContext;
				if (!Context) throw new Error('Web Audio API is unavailable');
				context = new Context();
				node = context.createScriptProcessor($2, 0, $4);
				const mix = () => { dynCall('vppi', $3, [$0, $1, $2 * $4 * 4]); };
				node.onaudioprocess = event => {
					if (disposed) return;
					mix();
					for (let channel = 0; channel < $4; channel++) {
						const output = event.outputBuffer.getChannelData(channel);
						for (let frame = 0; frame < output.length; frame++) output[frame] = HEAPF32[($1 >> 2) + frame * $4 + channel];
					}
				};
				node.connect(context.destination);
				// Match SDL: advance voices while autoplay is suspended, discarding PCM.
				timer = setInterval(() => { if (!disposed && context.state === 'suspended') mix(); }, $2 * 1000 / context.sampleRate);
				globalThis.addEventListener('pointerdown', resume, true);
				globalThis.addEventListener('keydown', resume, true);
				Module.doraLegacyAudio = {dispose, context, get state() { return context.state; }};
				return context.sampleRate;
			} catch (error) {
				warn(error);
				dispose();
				Module.doraAudioDisabled = !workletReady;
				return workletReady ? $5 : 0;
			}
			})();
		}, backend, backend->webBuffer, aBuffer, soloud_sdl2static_audiomixer, aChannels, aSamplerate);
		if (!rate) { SDL_free(backend->webBuffer); delete backend; return UNKNOWN_ERROR; }
		aSoloud->postinit_internal(rate, aBuffer, aFlags, aChannels);
		aSoloud->mBackendData = backend;
		aSoloud->mBackendCleanupFunc = soloud_sdl2static_deinit;
		aSoloud->mBackendString = "Dora Web Audio";
		return 0;
#else
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
#endif
	}	
};
#endif
