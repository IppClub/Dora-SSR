// Independent SoLoud instance owned exclusively by the AudioWorklet.
// No Dora objects, shared WASM memory, SDL callbacks or main-thread mixing.
#include "soloud.h"
#include "soloud_wavstream.h"
#include "soloud_wav.h"
#include "soloud_bus.h"
#include "soloud_bassboostfilter.h"
#include "soloud_biquadresonantfilter.h"
#include "soloud_dcremovalfilter.h"
#include "soloud_echofilter.h"
#include "soloud_eqfilter.h"
#include "soloud_fftfilter.h"
#include "soloud_flangerfilter.h"
#include "soloud_freeverbfilter.h"
#include "soloud_lofifilter.h"
#include "soloud_robotizefilter.h"
#include "soloud_waveshaperfilter.h"
#include "AudioProtocol.h"
#include <emscripten/emscripten.h>
#include <cstdint>
#include <map>
#include <memory>
#include <array>
#include <cstring>

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
	std::unique_ptr<SoLoud::AudioSource> source;
	unsigned bytes = 0;
};
struct Bus {
	std::array<std::unique_ptr<SoLoud::Filter>, FILTERS_PER_STREAM> filters;
	SoLoud::Bus source;
	unsigned handle = 0;
};
std::map<unsigned, std::unique_ptr<Bus>> buses;
struct Voice {
	unsigned handle;
	unsigned asset;
	std::array<float, DoraWebAudio::SourceFields> config {};
	bool configured = false;
};
std::map<unsigned, std::unique_ptr<Asset>> assets;
std::map<unsigned, Voice> voices;
unsigned storedBytes = 0;
constexpr unsigned maxBytes = 64 * 1024 * 1024;
float output[256];
double status[1 + 64 * 3];
bool spatialDirty = false;

void configure(Voice& voice, const float* c) {
	using namespace DoraWebAudio;
	const auto changed = [&](unsigned start, unsigned count = 1) {
		return !voice.configured || std::memcmp(c + start, voice.config.data() + start, count * sizeof(float));
	};
	const auto h = voice.handle;
	if (changed(Volume)) mixer.setVolume(h, c[Volume]);
	if (c[Mode] != 1 && (changed(Pan) || changed(Mode))) mixer.setPan(h, c[Pan]);
	if (changed(Speed)) mixer.setRelativePlaySpeed(h, c[Speed]);
	if (changed(Loop)) mixer.setLooping(h, c[Loop] != 0);
	if (changed(Protected)) mixer.setProtectVoice(h, c[Protected] != 0);
	if (changed(LoopPoint)) mixer.setLoopPoint(h, c[LoopPoint]);
	if (c[HasVolumeLimits] && changed(HasVolumeLimits, 3)) mixer.setVoiceVolumeLimits(h, c[MinVolume], c[MaxVolume]);
	if (c[Mode] == 2 && (!voice.configured || changed(X, SourceFields - X))) {
		mixer.set3dSourcePosition(h, c[X], c[Y], c[Z]);
		mixer.set3dSourceVelocity(h, c[VX], c[VY], c[VZ]);
		mixer.set3dSourceCone(h, c[DX], c[DY], c[DZ], c[ConeInner], c[ConeOuter], c[ConeVolume], c[ConeHighGain]);
		mixer.set3dSourceAirAbsorption(h, c[AirAbsorption]);
		mixer.set3dSourceMinMaxDistance(h, c[MinDistance], c[MaxDistance]);
		mixer.set3dSourceAttenuation(h, static_cast<unsigned>(c[Attenuation]), c[Rolloff]);
		mixer.set3dSourceDopplerFactor(h, c[Doppler]);
		mixer.set3dSourceListenerRelative(h, c[ListenerRelative] != 0);
		spatialDirty = true;
	}
	std::memcpy(voice.config.data(), c, sizeof(float) * SourceFields);
	voice.configured = true;
	if (c[Mode] == 2) spatialDirty = true;
}

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
	const auto result = mixer.init(SoLoud::Soloud::CLIP_ROUNDOFF, SoLoud::Soloud::NULLDRIVER, rate, 128, 2);
	if (result) return result;
	// Match Dora's native mixer. Love creates a bus per Source; the upstream
	// default of 16 lets empty buses starve real voices in larger projects.
	return mixer.setMaxActiveVoiceCount(255);
}
// Bus operations: create, destroy, volume, pan, speed, their fades,
// filter replacement, parameter and parameter fade. IDs are not native handles.
EMSCRIPTEN_KEEPALIVE int audio_bus(unsigned id, unsigned op, double a, double b, double c, double d) {
	using namespace DoraWebAudio;
	if (op == CreateBus) {
		if (!id || buses.count(id)) return 1;
		const auto parent = buses.find(static_cast<unsigned>(a));
		if (a && parent == buses.end()) return 2;
		auto bus = std::make_unique<Bus>();
		bus->handle = mixer.play(bus->source, 1, 0, false, a ? parent->second->handle : 0);
		if (!bus->handle) return 3;
		mixer.setProtectVoice(bus->handle, true);
		bus->source.findBusHandle();
		buses.emplace(id, std::move(bus));
		return 0;
	}
	const auto it = buses.find(id);
	if (it == buses.end()) return op == DestroyBus ? 0 : 4;
	auto& bus = *it->second;
	const auto h = bus.handle;
	switch (op) {
		case DestroyBus: mixer.stop(h); buses.erase(it); collect(); break;
		case BusVolume: mixer.setVolume(h, a); break;
		case BusPan: mixer.setPan(h, a); break;
		case BusSpeed: return mixer.setRelativePlaySpeed(h, a);
		case FadeBusVolume: mixer.fadeVolume(h, a, b); break;
		case FadeBusPan: mixer.fadePan(h, a, b); break;
		case FadeBusSpeed: mixer.fadeRelativePlaySpeed(h, a, b); break;
		case BusFilter: {
			if (a < 0 || a >= FILTERS_PER_STREAM || b < 0 || b > 11) return 5;
			std::unique_ptr<SoLoud::Filter> filter;
			switch (static_cast<unsigned>(b)) {
				case 1: filter = std::make_unique<SoLoud::BassboostFilter>(); break;
				case 2: filter = std::make_unique<SoLoud::BiquadResonantFilter>(); break;
				case 3: filter = std::make_unique<SoLoud::DCRemovalFilter>(); break;
				case 4: filter = std::make_unique<SoLoud::EchoFilter>(); break;
				case 5: filter = std::make_unique<SoLoud::EqFilter>(); break;
				case 6: filter = std::make_unique<SoLoud::FFTFilter>(); break;
				case 7: filter = std::make_unique<SoLoud::FlangerFilter>(); break;
				case 8: filter = std::make_unique<SoLoud::FreeverbFilter>(); break;
				case 9: filter = std::make_unique<SoLoud::LofiFilter>(); break;
				case 10: filter = std::make_unique<SoLoud::RobotizeFilter>(); break;
				case 11: filter = std::make_unique<SoLoud::WaveShaperFilter>(); break;
			}
			bus.source.setFilter(a, nullptr);
			bus.filters[a] = std::move(filter);
			bus.source.setFilter(a, bus.filters[a].get());
			break;
		}
		case BusParameter: mixer.setFilterParameter(h, a, b, c); break;
		case FadeBusParameter: mixer.fadeFilterParameter(h, a, b, c, d); break;
		default: return 6;
	}
	return 0;
}
EMSCRIPTEN_KEEPALIVE int audio_play(unsigned id, unsigned assetId, unsigned char* data, unsigned bytes, int loop, float fade, int background, const float* config, unsigned busId, int isStatic) {
	collect();
	const auto bus = buses.find(busId);
	if (busId && bus == buses.end()) return 4;
	const unsigned busHandle = busId ? bus->second->handle : 0;
	if (voices.size() >= 64 || !bytes || bytes > maxBytes) return 1;
	if (!assets.count(assetId)) {
		trim(bytes);
		if (storedBytes + bytes > maxBytes) return 2;
		auto asset = std::make_unique<Asset>();
		int error;
		unsigned cost = bytes;
		if (isStatic) {
			// Inspect metadata before allocating PCM; compressed files can expand
			// far beyond the encoded cache budget or the WASM memory limit.
			SoLoud::WavStream probe;
			error = probe.loadMem(data, bytes, false, false);
			if (error) return error;
			const uint64_t decoded = static_cast<uint64_t>(probe.mSampleCount) * probe.mChannels * sizeof(float);
			if (decoded > maxBytes) return 2;
			cost = static_cast<unsigned>(decoded);
			trim(cost);
			if (storedBytes + cost > maxBytes) return 2;
			auto source = std::make_unique<SoLoud::Wav>();
			error = source->loadMem(data, bytes, true, false);
			asset->source = std::move(source);
		} else {
			auto source = std::make_unique<SoLoud::WavStream>();
			error = source->loadMem(data, bytes, true, false);
			asset->source = std::move(source);
		}
		if (error) return error;
		trim(cost);
		if (storedBytes + cost > maxBytes) return 2;
		asset->bytes = cost;
		storedBytes += cost;
		assets.emplace(assetId, std::move(asset));
	}
	auto& source = *assets.at(assetId)->source;
	unsigned handle;
	if (config) {
		using namespace DoraWebAudio;
		if (config[Mode] == 2) {
			handle = config[Delay] < 0
				? mixer.play3d(source, config[X], config[Y], config[Z], 0, 0, 0, config[Volume], false, busHandle)
				: mixer.play3dClocked(config[Delay], source, config[X], config[Y], config[Z], 0, 0, 0, config[Volume], busHandle);
			mixer.setInaudibleBehavior(handle, true, false);
		} else if (config[Mode] == 1) handle = mixer.playBackground(source, config[Volume], false, busHandle);
		else handle = config[Delay] > 0 ? mixer.playClocked(config[Delay], source, config[Volume], config[Pan], busHandle)
			: mixer.play(source, config[Volume], config[Pan], false, busHandle);
	} else handle = background ? mixer.playBackground(source, fade > 0 ? 0 : 1, false, busHandle)
		: mixer.play(source, fade > 0 ? 0 : 1, 0, false, busHandle);
	if (!handle) return 3;
	mixer.setLooping(handle, loop != 0);
	if (background) mixer.setProtectVoice(handle, true);
	if (fade > 0) mixer.fadeVolume(handle, 1, fade);
	voices[id] = {handle, assetId};
	if (config) configure(voices.at(id), config);
	return 0;
}
EMSCRIPTEN_KEEPALIVE void audio_config(unsigned id, const float* config) {
	auto it = voices.find(id);
	if (it != voices.end() && mixer.isValidVoiceHandle(it->second.handle)) configure(it->second, config);
}
EMSCRIPTEN_KEEPALIVE void audio_listener(const float* c) {
	mixer.set3dListenerParameters(c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11]);
	mixer.set3dSoundSpeed(c[12]);
	mixer.set3dDopplerScale(c[13]);
	mixer.set3dDistanceModel(static_cast<SoLoud::DISTANCE_MODELS>(static_cast<int>(c[14])));
	spatialDirty = true;
}
EMSCRIPTEN_KEEPALIVE int audio_control(unsigned id, unsigned op, double value) {
	auto it = voices.find(id);
	if (it == voices.end() || !mixer.isValidVoiceHandle(it->second.handle)) return 0;
	const auto h = it->second.handle;
	if (op == 0) return mixer.seek(h, value);
	if (op == 1) mixer.setPause(h, value != 0);
	if (op == 2) mixer.scheduleStop(h, value);
	return 0;
}
EMSCRIPTEN_KEEPALIVE double* audio_status() {
	collect();
	unsigned count = 0;
	for (const auto& [id, voice] : voices) {
		status[1 + count * 3] = id;
		status[2 + count * 3] = mixer.getPause(voice.handle);
		status[3 + count * 3] = mixer.getStreamPosition(voice.handle);
		++count;
	}
	status[0] = count;
	return status;
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
		// Keep bus topology alive: stopAll applies to sources, not routing nodes.
		for (const auto& voice : voices) mixer.stop(voice.second.handle);
		voices.clear();
		assets.clear();
		storedBytes = 0;
	}
}
EMSCRIPTEN_KEEPALIVE void audio_volume(float value) { mixer.setGlobalVolume(value); }
EMSCRIPTEN_KEEPALIVE void audio_pause(int paused) {
	mixer.setPauseAll(paused != 0);
}
EMSCRIPTEN_KEEPALIVE float* audio_mix() {
	if (spatialDirty) { mixer.update3dAudio(); spatialDirty = false; }
	mixer.mix(output, 128);
	return output;
}
EMSCRIPTEN_KEEPALIVE unsigned audio_voice_count() { collect(); return voices.size(); }
EMSCRIPTEN_KEEPALIVE unsigned audio_asset_bytes() { return storedBytes; }
EMSCRIPTEN_KEEPALIVE unsigned audio_bus_count() { return buses.size(); }
}
