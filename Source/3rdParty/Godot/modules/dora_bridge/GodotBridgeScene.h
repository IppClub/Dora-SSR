// Read-only text scene metadata. Owner/render thread only; no resource loading.
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_SCENE_ABI_VERSION 1u
typedef struct DoraGodotSceneAPI {
    uint32_t size, abi_version;
    const char *(*inspect)(const DoraGodotConfig *, const char *file, const char *options);
} DoraGodotSceneAPI;
typedef int (*DoraGodotGetSceneAPI)(uint32_t, DoraGodotSceneAPI *);
DORA_GODOT_EXPORT int dora_godot_get_scene_api(uint32_t, DoraGodotSceneAPI *);
#ifdef __cplusplus
}
#endif
