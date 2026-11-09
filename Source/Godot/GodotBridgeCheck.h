// Copyright (c) 2026 Dora SSR contributors. MIT license.
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_CHECK_ABI_VERSION 1u
// Owner/render thread only. The returned UTF-8 JSON is owned by the library
// until the next check. Source is an in-memory buffer; no scene is executed.
typedef struct DoraGodotCheckAPI {
    uint32_t size, abi_version;
    const char *(*check)(const DoraGodotConfig *, const char *file, const char *source);
} DoraGodotCheckAPI;
typedef int (*DoraGodotGetCheckAPI)(uint32_t, DoraGodotCheckAPI *);
DORA_GODOT_EXPORT int dora_godot_get_check_api(uint32_t, DoraGodotCheckAPI *);
#ifdef __cplusplus
}
#endif
