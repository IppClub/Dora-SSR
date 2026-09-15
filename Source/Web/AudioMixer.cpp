// Independent SoLoud instance owned exclusively by the AudioWorklet.
// No Dora objects, shared WASM memory, SDL callbacks or main-thread mixing.
#include "soloud.h"
#include "soloud_wavstream.h"
#include <emscripten/emscripten.h>
#include <cstdint>
#include <map>
#include <memory>

namespace SoLoud {
result null_init(Soloud* engine, unsigned flags, unsigned rate, unsigned buffer, unsigned channels) {
	engine->postinit_internal(rate, buffer, flags, channels);
	engine->mBackendString = "Dora AudioWorklet";
	return SO_NO_ERROR;
}
}

// Voice ownership here is local; never call back into Dora's logic scheduler.
void soloud_stop_voice(uint32_t) { }

namespace {
SoLoud::Soloud mixer;
struct Asset {
	SoLoud::WavStream source;
	unsigned bytes = 0;
};
struct Voice { unsigned handle; unsigned asset; };
std::map<unsigned, std::unique_ptr<Asset>> assets;
std::map<unsigned, Voice> voices;
unsigned storedBytes = 0;
constexpr unsigned maxBytes = 64 * 1024 * 1024;
float output[256];

void collect() {
	for (auto it = voices.begin(); it != voices.end();) {
		if (!mixer.isValidVoiceHandle(it->second.handle)) it = voices.erase(it);
		else ++it;
	}
}
void trim(unsigned required) {
	collect();
	for (auto it = assets.begin(); it != assets.end() && storedBytes + required > maxBytes;) {
		bool used = false;
		for (const auto& voice : voices) if (voice.second.asset == it->first) used = true;
		if (used) { ++it; continue; }
		storedBytes -= it->second->bytes;
		it = assets.erase(it);
	}
}
}

extern "C" {
EMSCRIPTEN_KEEPALIVE int audio_init(unsigned rate) {
	return mixer.init(SoLoud::Soloud::CLIP_ROUNDOFF, SoLoud::Soloud::NULLDRIVER, rate, 128, 2);
}
EMSCRIPTEN_KEEPALIVE int audio_play(unsigned id, unsigned assetId, unsigned char* data, unsigned bytes, int loop, float fade, int background) {
	collect();
	if (voices.size() >= 64 || !bytes || bytes > maxBytes) return 1;
	if (!assets.count(assetId)) {
		trim(bytes);
		if (storedBytes + bytes > maxBytes) return 2;
		auto asset = std::make_unique<Asset>();
		int error = asset->source.loadMem(data, bytes, true, false);
		if (error) return error;
		asset->bytes = bytes;
		storedBytes += bytes;
		assets.emplace(assetId, std::move(asset));
	}
	auto& source = assets.at(assetId)->source;
	const auto handle = background ? mixer.playBackground(source, fade > 0 ? 0 : 1)
		: mixer.play(source, fade > 0 ? 0 : 1);
	if (!handle) return 3;
	mixer.setLooping(handle, loop != 0);
	if (background) mixer.setProtectVoice(handle, true);
	if (fade > 0) mixer.fadeVolume(handle, 1, fade);
	voices[id] = {handle, assetId};
	return 0;
}
EMSCRIPTEN_KEEPALIVE void audio_stop(unsigned id, float fade) {
	auto it = voices.find(id);
	if (it == voices.end()) return;
	if (fade > 0) {
		mixer.fadeVolume(it->second.handle, 0, fade);
		mixer.scheduleStop(it->second.handle, fade);
	} else {
		mixer.stop(it->second.handle);
		voices.erase(it);
	}
}
EMSCRIPTEN_KEEPALIVE void audio_stop_all(float fade) {
	if (fade > 0) {
		for (const auto& voice : voices) {
			mixer.fadeVolume(voice.second.handle, 0, fade);
			mixer.scheduleStop(voice.second.handle, fade);
		}
	} else {
		mixer.stopAll();
		voices.clear();
		assets.clear();
		storedBytes = 0;
	}
}
EMSCRIPTEN_KEEPALIVE void audio_volume(float value) { mixer.setGlobalVolume(value); }
EMSCRIPTEN_KEEPALIVE void audio_pause(int paused) { mixer.setPauseAll(paused != 0); }
EMSCRIPTEN_KEEPALIVE float* audio_mix() { mixer.mix(output, 128); return output; }
EMSCRIPTEN_KEEPALIVE unsigned audio_voice_count() { collect(); return voices.size(); }
EMSCRIPTEN_KEEPALIVE unsigned audio_asset_bytes() { return storedBytes; }
}
