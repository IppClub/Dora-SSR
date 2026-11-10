// Included once by the selected renderer backend. Keep extension ABI negotiation
// identical across Metal, GL/GLES/WebGL and D3D12.
extern "C" DORA_GODOT_EXPORT int dora_godot_get_check_api(uint32_t requested, DoraGodotCheckAPI *api) {
	if (requested != DORA_GODOT_CHECK_ABI_VERSION || !api || api->size < sizeof(*api)) {
		return 0;
	}
	*api = { sizeof(*api), DORA_GODOT_CHECK_ABI_VERSION, check_code };
	return 1;
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_import_api(uint32_t requested, DoraGodotImportAPI *api) {
	if (requested != DORA_GODOT_IMPORT_ABI_VERSION || !api || api->size < sizeof(*api)) {
		return 0;
	}
	*api = { sizeof(*api), DORA_GODOT_IMPORT_ABI_VERSION, import_asset };
	return 1;
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_scene_api(uint32_t requested,DoraGodotSceneAPI *api) {
    if(requested!=DORA_GODOT_SCENE_ABI_VERSION || !api || api->size<sizeof(*api))return 0;
    *api={sizeof(*api),DORA_GODOT_SCENE_ABI_VERSION,inspect_scene};return 1;
}
