// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_VIEWPORT_ABI_VERSION 1u
// Owner-thread resize handshake. The host must quiesce its GPU consumers first.
// get_slot must be queried again afterwards: all slot resources are replaced.
// Simulation, SceneTree/autoload, pause state and PCM worker remain alive.
// On allocation/render failure the caller must close the client. Invalid size
// requests are rejected before mutation. Existing aliases remain host-owned.
typedef struct DoraGodotViewportAPI {
    uint32_t size, abi_version;
    int (*resize)(void *runtime,uint32_t width,uint32_t height);
} DoraGodotViewportAPI;
typedef int (*DoraGodotGetViewportAPI)(uint32_t,DoraGodotViewportAPI *);
DORA_GODOT_EXPORT int dora_godot_get_viewport_api(uint32_t,DoraGodotViewportAPI *);
#ifdef __cplusplus
}
#endif
