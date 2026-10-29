// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_IME_ABI_VERSION 1u
// Owner-thread snapshot of Godot's OS text-input request. Coordinates use the
// Godot output's top-left pixel origin. revision changes only when state does.
typedef struct DoraGodotIMEState {
    uint32_t size,active;
    int32_t x,y;
    uint64_t revision;
} DoraGodotIMEState;
typedef struct DoraGodotIMEAPI {
    uint32_t size,abi_version;
    int (*get_state)(void *runtime,DoraGodotIMEState *state);
} DoraGodotIMEAPI;
typedef int (*DoraGodotGetIMEAPI)(uint32_t,DoraGodotIMEAPI *);
DORA_GODOT_EXPORT int dora_godot_get_ime_api(uint32_t,DoraGodotIMEAPI *);
#ifdef __cplusplus
}
#endif
