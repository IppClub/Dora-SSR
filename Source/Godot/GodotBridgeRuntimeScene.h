// Read-only live scene snapshots, on the runtime owner thread. No script calls.
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_RUNTIME_SCENE_ABI_VERSION 1u
typedef struct DoraGodotRuntimeSceneAPI {
    uint32_t size, abi_version;
    const char *(*inspect)(const DoraGodotConfig *, const char *options);
} DoraGodotRuntimeSceneAPI;
typedef int (*DoraGodotGetRuntimeSceneAPI)(uint32_t, DoraGodotRuntimeSceneAPI *);
DORA_GODOT_EXPORT int dora_godot_get_runtime_scene_api(uint32_t, DoraGodotRuntimeSceneAPI *);
#ifdef __cplusplus
}
#endif
