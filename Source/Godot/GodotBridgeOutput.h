// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_OUTPUT_ABI_VERSION 1u
// Owner-thread snapshot of the root Window's physical output dimensions. No
// simulation, GPU readback or allocation. On a size change advance returns zero
// without publishing a slot; negotiate replacement slots before advancing again.
// A zero advance is recoverable only when this query succeeds, resize_pending is set and differs from
// the currently bound slot dimensions. Other zero returns remain errors.
typedef struct DoraGodotOutputSize { uint32_t size,width,height,resize_pending; } DoraGodotOutputSize;
typedef struct DoraGodotOutputAPI {
    uint32_t size,abi_version;
    int (*get_size)(void *runtime,DoraGodotOutputSize *output);
} DoraGodotOutputAPI;
typedef int (*DoraGodotGetOutputAPI)(uint32_t,DoraGodotOutputAPI *);
DORA_GODOT_EXPORT int dora_godot_get_output_api(uint32_t,DoraGodotOutputAPI *);
#ifdef __cplusplus
}
#endif
