#pragma once

#include <emscripten/emscripten.h>

// Included only by Audio.cpp. Non-player Web targets retain the SDL backend.
EM_JS(int, dora_worklet_ready, (), { return Module.doraAudio?.ready ? 1 : 0; });
EM_JS(int, dora_worklet_has, (const char* path), { return Module.doraAudio?.has(UTF8ToString(path)) ? 1 : 0; });
EM_JS(uint32_t, dora_worklet_play, (const char* path, const uint8_t* data, size_t size, int loop, float fade, int background), {
	return Module.doraAudio?.play(UTF8ToString(path), size ? HEAPU8.slice(data, data + size) : null, loop, fade, background) || 0;
});
EM_JS(void, dora_worklet_stop, (uint32_t id, float fade), { Module.doraAudio?.stop(id, fade); });
EM_JS(void, dora_worklet_stop_all, (float fade), { Module.doraAudio?.stopAll(fade); });
EM_JS(void, dora_worklet_volume, (float value), { Module.doraAudio?.volume(value); });
EM_JS(void, dora_worklet_pause, (int paused), { Module.doraAudio?.pause(paused); });

inline bool dora_worklet_handle(uint32_t handle) { return handle && !(handle & 0xfff); }
