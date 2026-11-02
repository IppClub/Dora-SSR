// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_D3D12_TARGETS_ABI_VERSION 1u
typedef struct DoraGodotD3D12TargetsAPI {
    uint32_t size, abi_version;
    // Handles are NT shared handles created for same-adapter RGBA8
    // ID3D12Resource objects. The caller retains handle ownership.
    int (*bind)(void *runtime, uint32_t width, uint32_t height,
        const uint64_t *shared_handles, uint32_t count);
} DoraGodotD3D12TargetsAPI;
typedef int (*DoraGodotGetD3D12TargetsAPI)(uint32_t requested_abi,
    DoraGodotD3D12TargetsAPI *api);
DORA_GODOT_EXPORT int dora_godot_get_d3d12_targets_api(
    uint32_t requested_abi, DoraGodotD3D12TargetsAPI *api);
#ifdef __cplusplus
}
#endif
