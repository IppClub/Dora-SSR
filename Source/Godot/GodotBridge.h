// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include <stddef.h>
#include <stdint.h>

// No Godot, STL, bgfx or graphics SDK types cross the library boundary.
// Extend only by appending fields and bumping the ABI when layout changes.
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_ABI_VERSION 1u
#define DORA_GODOT_MAX_BUFFERS 4u
#if defined(_WIN32) && defined(DORA_GODOT_BUILD_LIBRARY)
#define DORA_GODOT_EXPORT __declspec(dllexport)
#elif defined(_WIN32)
#define DORA_GODOT_EXPORT
#else
#define DORA_GODOT_EXPORT __attribute__((visibility("default")))
#endif

typedef enum DoraGodotBackend {
    DORA_GODOT_METAL = 1,
    DORA_GODOT_VULKAN = 2,
    DORA_GODOT_OPENGL = 3,
    DORA_GODOT_D3D12 = 4,
    DORA_GODOT_WEBGL2 = 5
} DoraGodotBackend;

typedef enum DoraGodotPixelFormat {
    DORA_GODOT_RGBA8 = 1, DORA_GODOT_BGRA8 = 2, DORA_GODOT_RGBA16F = 3
} DoraGodotPixelFormat;

typedef enum DoraGodotInputKind {
    DORA_GODOT_POINTER_MOVE = 1,
    DORA_GODOT_POINTER_BUTTON = 2,
    DORA_GODOT_KEY = 3,
    DORA_GODOT_TEXT = 4,
    DORA_GODOT_FOCUS = 5,
    // Controller events reuse the existing ABI layout: button carries Dora's
    // controller id, text carries the SDL standard button/axis name, and x is
    // the normalized axis value for DORA_GODOT_CONTROLLER_AXIS.
    DORA_GODOT_CONTROLLER_BUTTON = 6,
    DORA_GODOT_CONTROLLER_AXIS = 7
} DoraGodotInputKind;

typedef struct DoraGodotConfig {
    uint32_t size, backend, width, height, buffer_count;
    const char *project_path;
    const char *scene_path; // empty: project main scene
    void *native_device;
} DoraGodotConfig;

typedef struct DoraGodotSlot {
    uint32_t size, width, height, format;
    void *texture;
    void *ready_event;
    void *consumed_event;
} DoraGodotSlot;

typedef struct DoraGodotInput {
    uint32_t size, kind, pressed, button;
    double x, y;
    const char *text; // UTF-8 key name or committed text
    uint32_t shift, ctrl, alt, meta;
} DoraGodotInput;

typedef struct DoraGodotStats {
    uint32_t size;
    uint64_t produced, completed, gpu_errors, reuse_waits;
} DoraGodotStats;

typedef struct DoraGodotAPI {
    uint32_t size, abi_version;
    const char *(*version)(void);
    void *(*open)(const DoraGodotConfig *config);
    const char *(*last_error)(void *runtime);
    int (*get_slot)(void *runtime, uint32_t index, DoraGodotSlot *slot);
    uint64_t (*advance)(void *runtime, uint32_t slot, uint64_t last_read);
    int (*input)(void *runtime, const DoraGodotInput *input);
    int (*set_paused)(void *runtime, int paused);
    int (*restart_scene)(void *runtime, const char *scene_path);
    // Consumer GPU must be drained before closing; native slots remain pinned
    // until close. One process-owned Godot runtime currently permits one client.
    void (*close)(void *runtime, DoraGodotStats *stats);
    void (*shutdown)(void);
} DoraGodotAPI;

typedef int (*DoraGodotGetAPI)(uint32_t requested_abi, DoraGodotAPI *api);
DORA_GODOT_EXPORT int dora_godot_get_api(uint32_t requested_abi, DoraGodotAPI *api);
#ifdef __cplusplus
}
#endif
