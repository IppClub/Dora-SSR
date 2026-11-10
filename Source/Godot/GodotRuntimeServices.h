#pragma once
#include "GodotBridgeCheck.h"
#include "GodotBridgeImport.h"
#include "GodotBridgeScene.h"
#include <string>
#include <utility>
namespace GodotRuntimeServices {
enum Operation { Check = 0,
	Import = 1,
	InspectScene = 2 };
template <class Resolve>
inline std::pair<bool, std::string> call(int operation, const DoraGodotConfig& config, const std::string& file, const std::string& content, Resolve resolve) {
	const char* reply = nullptr;
	if (operation == InspectScene) {
		const auto getter = reinterpret_cast<DoraGodotGetSceneAPI>(resolve("dora_godot_get_scene_api"));
		DoraGodotSceneAPI api{};
		api.size = sizeof(api);
		if (!getter || !getter(DORA_GODOT_SCENE_ABI_VERSION, &api) || api.size < sizeof(api) || api.abi_version != DORA_GODOT_SCENE_ABI_VERSION || !api.inspect)
			return {false, "Bundled Godot runtime has no static scene inspection API; rebuild the runtime library"};
		reply = api.inspect(&config, file.c_str(), content.c_str());
	} else if (operation == Import) {
		const auto getter = reinterpret_cast<DoraGodotGetImportAPI>(resolve("dora_godot_get_import_api"));
		DoraGodotImportAPI api{};
		api.size = sizeof(api);
		if (!getter || !getter(DORA_GODOT_IMPORT_ABI_VERSION, &api) || api.size < sizeof(api) || api.abi_version != DORA_GODOT_IMPORT_ABI_VERSION || !api.import_asset)
			return {false, "Bundled Godot runtime has no asset-import API; rebuild the runtime library"};
		reply = api.import_asset(&config, file.c_str(), content.c_str());
	} else {
		const auto getter = reinterpret_cast<DoraGodotGetCheckAPI>(resolve("dora_godot_get_check_api"));
		DoraGodotCheckAPI api{};
		api.size = sizeof(api);
		if (!getter || !getter(DORA_GODOT_CHECK_ABI_VERSION, &api) || api.size < sizeof(api) || api.abi_version != DORA_GODOT_CHECK_ABI_VERSION || !api.check)
			return {false, "Bundled Godot runtime has no compiler-check API; rebuild the runtime library"};
		reply = api.check(&config, file.c_str(), content.c_str());
	}
	return {reply != nullptr, reply ? reply : "Godot service returned no result"};
}
} // namespace GodotRuntimeServices
