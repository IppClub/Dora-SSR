// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_ANDROID_ABI_VERSION 1u
// Owner/render-thread callback. Initialize upstream Android Java/JNI services
// and Main::setup(..., false) using these exact arguments (argv[0] included).
// It must not create a Godot render view, surface, audio device or event loop.
typedef int (*DoraGodotAndroidPrepare)(void *,uint32_t,const char *const *);
typedef struct DoraGodotAndroidAPI {
    uint32_t size,abi_version;
    int (*configure)(DoraGodotAndroidPrepare prepare,void *userdata);
} DoraGodotAndroidAPI;
typedef int (*DoraGodotGetAndroidAPI)(uint32_t,DoraGodotAndroidAPI *);
DORA_GODOT_EXPORT int dora_godot_get_android_api(uint32_t,DoraGodotAndroidAPI *);
#ifdef __cplusplus
}
#endif
