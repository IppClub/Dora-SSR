// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif

// Optional Metal extension. Textures are host-owned id<MTLTexture> objects
// created on the same MTLDevice with RenderTarget and ShaderRead usage.
#define DORA_GODOT_METAL_TARGETS_ABI_VERSION 1u
typedef struct DoraGodotMetalTargetsAPI {
    uint32_t size, abi_version;
    int (*bind)(void *runtime, uint32_t width, uint32_t height,
        const uint64_t *textures, uint32_t count);
} DoraGodotMetalTargetsAPI;
typedef int (*DoraGodotGetMetalTargetsAPI)(uint32_t requested_abi,
    DoraGodotMetalTargetsAPI *api);
DORA_GODOT_EXPORT int dora_godot_get_metal_targets_api(
    uint32_t requested_abi, DoraGodotMetalTargetsAPI *api);

#ifdef __cplusplus
}
#endif
