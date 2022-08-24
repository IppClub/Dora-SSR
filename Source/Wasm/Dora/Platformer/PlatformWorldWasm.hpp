static int32_t platformer_platformworld_type() {
	return DoraType<Platformer::PlatformWorld>();
}
static int64_t platformer_platformworld_get_camera(int64_t self) {
	return from_object(r_cast<Platformer::PlatformWorld*>(self)->getCamera());
}
static void platformer_platformworld_move_child(int64_t self, int64_t child, int32_t new_order) {
	r_cast<Platformer::PlatformWorld*>(self)->moveChild(r_cast<Node*>(child), s_cast<int>(new_order));
}
static int64_t platformer_platformworld_get_layer(int64_t self, int32_t order) {
	return from_object(r_cast<Platformer::PlatformWorld*>(self)->getLayer(s_cast<int>(order)));
}
static void platformer_platformworld_set_layer_ratio(int64_t self, int32_t order, int64_t ratio) {
	r_cast<Platformer::PlatformWorld*>(self)->setLayerRatio(s_cast<int>(order), vec2_from(ratio));
}
static int64_t platformer_platformworld_get_layer_ratio(int64_t self, int32_t order) {
	return vec2_retain(r_cast<Platformer::PlatformWorld*>(self)->getLayerRatio(s_cast<int>(order)));
}
static void platformer_platformworld_set_layer_offset(int64_t self, int32_t order, int64_t offset) {
	r_cast<Platformer::PlatformWorld*>(self)->setLayerOffset(s_cast<int>(order), vec2_from(offset));
}
static int64_t platformer_platformworld_get_layer_offset(int64_t self, int32_t order) {
	return vec2_retain(r_cast<Platformer::PlatformWorld*>(self)->getLayerOffset(s_cast<int>(order)));
}
static void platformer_platformworld_swap_layer(int64_t self, int32_t order_a, int32_t order_b) {
	r_cast<Platformer::PlatformWorld*>(self)->swapLayer(s_cast<int>(order_a), s_cast<int>(order_b));
}
static void platformer_platformworld_remove_layer(int64_t self, int32_t order) {
	r_cast<Platformer::PlatformWorld*>(self)->removeLayer(s_cast<int>(order));
}
static void platformer_platformworld_remove_all_layers(int64_t self) {
	r_cast<Platformer::PlatformWorld*>(self)->removeAllLayers();
}
static int64_t platformer_platformworld_new() {
	return from_object(Platformer::PlatformWorld::create());
}
static void linkPlatformerPlatformWorld(wasm3::module& mod) {
	mod.link_optional("*", "platformer_platformworld_type", platformer_platformworld_type);
	mod.link_optional("*", "platformer_platformworld_get_camera", platformer_platformworld_get_camera);
	mod.link_optional("*", "platformer_platformworld_move_child", platformer_platformworld_move_child);
	mod.link_optional("*", "platformer_platformworld_get_layer", platformer_platformworld_get_layer);
	mod.link_optional("*", "platformer_platformworld_set_layer_ratio", platformer_platformworld_set_layer_ratio);
	mod.link_optional("*", "platformer_platformworld_get_layer_ratio", platformer_platformworld_get_layer_ratio);
	mod.link_optional("*", "platformer_platformworld_set_layer_offset", platformer_platformworld_set_layer_offset);
	mod.link_optional("*", "platformer_platformworld_get_layer_offset", platformer_platformworld_get_layer_offset);
	mod.link_optional("*", "platformer_platformworld_swap_layer", platformer_platformworld_swap_layer);
	mod.link_optional("*", "platformer_platformworld_remove_layer", platformer_platformworld_remove_layer);
	mod.link_optional("*", "platformer_platformworld_remove_all_layers", platformer_platformworld_remove_all_layers);
	mod.link_optional("*", "platformer_platformworld_new", platformer_platformworld_new);
}