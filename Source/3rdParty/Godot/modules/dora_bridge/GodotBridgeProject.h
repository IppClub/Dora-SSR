// Copyright (c) 2026 Dora SSR contributors. MIT license.
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_PROJECT_ABI_VERSION 1u
// Render/owner-thread snapshot after close; not a cross-thread polling API.
enum DoraGodotProjectState {
    DORA_GODOT_PROJECT_UNSUPPORTED=0,
    DORA_GODOT_PROJECT_ACTIVE=1,
    DORA_GODOT_PROJECT_UNLOADED=2,
    DORA_GODOT_PROJECT_TERMINATED=3
};
typedef struct DoraGodotProjectAPI {
    uint32_t size,abi_version;
    uint32_t (*get_state)(void);
} DoraGodotProjectAPI;
typedef int (*DoraGodotGetProjectAPI)(uint32_t,DoraGodotProjectAPI *);
DORA_GODOT_EXPORT int dora_godot_get_project_api(uint32_t,DoraGodotProjectAPI *);
#ifdef __cplusplus
}
#endif
