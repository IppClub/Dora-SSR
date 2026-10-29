#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
// Optional GL extension. All functions run with the bgfx EGL or WGL context current.
// can_produce is a nonblocking consumer fence query; begin/end encode GPU sync.
// ABI 2 appends queued production; ABI 1's three-function prefix remains
// available to legacy callers requesting 1 with a prefix-sized destination.
#define DORA_GODOT_GL_ABI_VERSION 2u
typedef struct DoraGodotGLAPI {
    uint32_t size, abi_version;
    int (*can_produce)(void *runtime, uint32_t slot, uint64_t last_read);
    int (*consumer_begin)(void *runtime, uint32_t slot, uint64_t sequence);
    int (*consumer_end)(void *runtime, uint32_t slot, uint64_t read);
    // V2: query completion of the previous producer, then queue a GPU wait
    // for the target's last submitted consumer. Never CPU-wait for that read.
    int (*can_advance)(void *runtime, uint32_t slot, uint64_t last_read);
    uint64_t (*advance_async)(void *runtime, uint32_t slot, uint64_t last_read);
} DoraGodotGLAPI;
typedef int (*DoraGodotGetGLAPI)(uint32_t requested_abi, DoraGodotGLAPI *api);
DORA_GODOT_EXPORT int dora_godot_get_gl_api(uint32_t requested_abi, DoraGodotGLAPI *api);
#ifdef __cplusplus
}
#endif
