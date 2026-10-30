#include "Source/Godot/GodotBridgeGL.h"
#include "Source/Godot/GodotBridgeAudio.h"
#include "Source/Godot/GodotBridgeViewport.h"
#include "Source/Godot/GodotBridgeGLTargets.h"
_Static_assert(offsetof(DoraGodotGLTargetsAPI,abi_version)==4,"GL targets extension prefix");
_Static_assert(offsetof(DoraGodotViewportAPI,abi_version)==4,"viewport extension prefix");
_Static_assert(offsetof(DoraGodotAudioAPI, abi_version) == 4, "audio extension prefix");
_Static_assert(DORA_GODOT_AUDIO_ABI_VERSION == 2, "worker PCM audio ABI");
_Static_assert(sizeof(DoraGodotAudioFormat) == 12, "audio format size");
_Static_assert(offsetof(DoraGodotGLAPI, abi_version) == 4, "GL extension prefix");
_Static_assert(DORA_GODOT_GL_ABI_VERSION == 2, "queued GL production ABI");
_Static_assert(offsetof(DoraGodotGLAPI, can_advance) == offsetof(DoraGodotGLAPI, consumer_end) + sizeof(((DoraGodotGLAPI*)0)->consumer_end), "GL v1 prefix preserved");
_Static_assert(DORA_GODOT_ABI_VERSION == 1, "ABI version");
_Static_assert(sizeof(uint32_t) == 4, "fixed-width API integers");
_Static_assert(sizeof(uint64_t) == 8, "fixed-width event timelines");
_Static_assert(offsetof(DoraGodotAPI, abi_version) == 4, "API version prefix");
_Static_assert(offsetof(DoraGodotConfig, backend) == 4, "backend prefix");
_Static_assert(offsetof(DoraGodotInput, kind) == 4, "input prefix");
int main(void) { DoraGodotAPI api = {0}; api.size = sizeof(api); return api.abi_version; }
