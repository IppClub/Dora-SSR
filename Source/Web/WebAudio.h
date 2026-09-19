#pragma once

#include <emscripten/emscripten.h>
#include <cstdint>
#include <cstddef>
#include "AudioProtocol.h"

// Definitions are emitted once by Audio.cpp; AudioSource uses declarations.
#ifdef DORA_WEB_AUDIO_IMPLEMENTATION
EM_JS(int, dora_worklet_ready, (), { return Module.doraAudio?.ready ? 1 : 0; });
EM_JS(int, dora_worklet_has, (const char* path), { return Module.doraAudio?.has(UTF8ToString(path)) ? 1 : 0; });
EM_JS(uint32_t, dora_worklet_play, (const char* path, const uint8_t* data, size_t size, int loop, float fade, int background), {
	return Module.doraAudio?.play(UTF8ToString(path), size ? HEAPU8.slice(data, data + size) : null, loop, fade, background) || 0;
});
EM_JS(void, dora_worklet_stop, (uint32_t id, float fade), { Module.doraAudio?.stop(id, fade); });
EM_JS(void, dora_worklet_stop_all, (float fade), { Module.doraAudio?.stopAll(fade); });
EM_JS(void, dora_worklet_volume, (float value), { Module.doraAudio?.volume(value); });
EM_JS(void, dora_worklet_pause, (int paused), { Module.doraAudio?.pause(paused); });
EM_JS(uint32_t, dora_worklet_source, (const char* path, const uint8_t* data, size_t size, const float* config, uint32_t bus, int isStatic), {
	return Module.doraAudio?.play(UTF8ToString(path), size ? HEAPU8.slice(data, data + size) : null, false, 0, false, HEAPF32.slice(config >> 2, (config >> 2) + 31), bus, isStatic) || 0;
});
EM_JS(void, dora_worklet_bus, (uint32_t id, int op, double a, double b, double c, double d), {
	Module.doraAudio?.bus(id, op, a, b, c, d);
});
EM_JS(void, dora_worklet_config, (uint32_t id, const float* config), {
	Module.doraAudio?.configure(id, HEAPF32.slice(config >> 2, (config >> 2) + 31));
});
EM_JS(void, dora_worklet_listener, (const float* config), {
	Module.doraAudio?.listener(HEAPF32.slice(config >> 2, (config >> 2) + 15));
});
EM_JS(void, dora_worklet_control, (uint32_t id, int op, double value), { Module.doraAudio?.control(id, op, value); });
EM_JS(double, dora_worklet_get, (uint32_t id, int property), { return Module.doraAudio?.get(id, property) || 0; });
#else
extern "C" {
int dora_worklet_ready();
int dora_worklet_has(const char*);
uint32_t dora_worklet_play(const char*, const uint8_t*, size_t, int, float, int);
void dora_worklet_stop(uint32_t, float);
void dora_worklet_stop_all(float);
void dora_worklet_volume(float);
void dora_worklet_pause(int);
uint32_t dora_worklet_source(const char*, const uint8_t*, size_t, const float*, uint32_t, int);
void dora_worklet_bus(uint32_t, int, double, double, double, double);
void dora_worklet_config(uint32_t, const float*);
void dora_worklet_listener(const float*);
void dora_worklet_control(uint32_t, int, double);
double dora_worklet_get(uint32_t, int);
}
#endif

inline bool dora_worklet_handle(uint32_t handle) { return handle && !(handle & 0xfff); }
