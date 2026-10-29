// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_GL_TARGETS_ABI_VERSION 1u
// Host-owned GL RGBA8 textures, same share group, exact requested dimensions.
// Owner/render thread only, between native frames; drain host GPU reads first.
// bind resizes the real viewport without restarting SceneTree/pause/audio, then
// replaces every slot. Keep textures alive until rebinding or client close.
// Old targets are never deleted by Godot. Requery slots after successful bind.
// Invalid dimensions/count/IDs reject; after other failures close the client.
typedef struct DoraGodotGLTargetsAPI {
    uint32_t size,abi_version;
    int (*bind)(void *runtime,uint32_t width,uint32_t height,const uint32_t *textures,uint32_t count);
} DoraGodotGLTargetsAPI;
typedef int (*DoraGodotGetGLTargetsAPI)(uint32_t,DoraGodotGLTargetsAPI *);
DORA_GODOT_EXPORT int dora_godot_get_gl_targets_api(uint32_t,DoraGodotGLTargetsAPI *);
#ifdef __cplusplus
}
#endif
