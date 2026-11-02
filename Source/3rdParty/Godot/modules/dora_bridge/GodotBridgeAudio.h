// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridge.h"

#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_AUDIO_ABI_VERSION 2u
#define DORA_GODOT_AUDIO_MAX_FRAMES 4096u

typedef struct DoraGodotAudioFormat {
    uint32_t size, sample_rate, channels;
} DoraGodotAudioFormat;

typedef struct DoraGodotAudioStats {
    uint32_t size;
    uint64_t produced, consumed, nonzero_produced, underrun_frames;
} DoraGodotAudioStats;

// A registered Godot worker produces into a bounded SPSC queue independently
// of rendering. get_format/start_capture/get_stats use the owner thread.
// read_pcm is a single-consumer lock-free queue copy, callable from the host
// mixer: it never invokes the Godot VM/mixer. Quiesce the host callback before
// close/shutdown, which joins the worker. Godot never opens an audio device.
typedef struct DoraGodotAudioAPI {
    uint32_t size, abi_version;
    int (*get_format)(void *runtime, DoraGodotAudioFormat *format);
    int (*start_capture)(void *runtime);
    // Interleaved float32 stereo, 48000 Hz. Returns frames written, or zero
    // for an invalid/empty request. Partial reads leave the remainder untouched;
    // the host fills missing frames with silence.
    // Capacity is frames * channels, with 1..MAX_FRAMES accepted per call.
    uint32_t (*read_pcm)(void *runtime, float *samples, uint32_t frames);
    int (*get_stats)(void *runtime, DoraGodotAudioStats *stats);
} DoraGodotAudioAPI;

typedef int (*DoraGodotGetAudioAPI)(uint32_t requested_abi, DoraGodotAudioAPI *api);
DORA_GODOT_EXPORT int dora_godot_get_audio_api(uint32_t requested_abi, DoraGodotAudioAPI *api);
#ifdef __cplusplus
}
#endif
