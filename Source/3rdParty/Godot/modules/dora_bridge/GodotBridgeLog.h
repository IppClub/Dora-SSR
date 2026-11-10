// Optional bounded error/warning stream. No Godot objects cross the C ABI.
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_LOG_ABI_VERSION 1u
#define DORA_GODOT_LOG_WARNING 1u
#define DORA_GODOT_LOG_ERROR 2u
typedef struct DoraGodotLogAPI {
    uint32_t size, abi_version;
    // Owner thread only. Enable before boot, disable after shutdown.
    void (*set_enabled)(int enabled);
    // Pop on the owner thread; text is valid until the next pop. Null: empty.
    // Producers may run on any thread. At most 128 records of 8192 bytes are
    // retained; overflow produces a warning containing the dropped count.
    const char *(*pop)(uint32_t *level);
} DoraGodotLogAPI;
typedef int (*DoraGodotGetLogAPI)(uint32_t, DoraGodotLogAPI *);
DORA_GODOT_EXPORT int dora_godot_get_log_api(uint32_t, DoraGodotLogAPI *);
#ifdef __cplusplus
}
#endif
