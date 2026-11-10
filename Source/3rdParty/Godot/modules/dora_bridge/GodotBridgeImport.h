// Additive embedded asset service. Call on the runtime owner/render thread.
#pragma once
#include "GodotBridge.h"
#ifdef __cplusplus
extern "C" {
#endif
#define DORA_GODOT_IMPORT_ABI_VERSION 1u
typedef struct DoraGodotImportAPI {
	uint32_t size, abi_version;
	// options is JSON: {"force":false}. Returned JSON is library-owned.
	const char* (*import_asset)(const DoraGodotConfig*, const char* file, const char* options);
} DoraGodotImportAPI;
typedef int (*DoraGodotGetImportAPI)(uint32_t, DoraGodotImportAPI*);
DORA_GODOT_EXPORT int dora_godot_get_import_api(uint32_t, DoraGodotImportAPI*);
#ifdef __cplusplus
}
#endif
