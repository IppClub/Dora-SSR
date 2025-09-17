/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t platformer_platformworld_type() {
	return DoraType<Platformer::PlatformWorld>();
}
DORA_EXPORT int64_t platformer_platformworld_get_camera(int64_t self) {
	return Object_From(r_cast<Platformer::PlatformWorld*>(self)->getCamera());
}
DORA_EXPORT void platformer_platformworld_move_child(int64_t self, int64_t child, int32_t new_order) {
	r_cast<Platformer::PlatformWorld*>(self)->moveChild(r_cast<Node*>(child), s_cast<int>(new_order));
}
DORA_EXPORT int64_t platformer_platformworld_get_layer(int64_t self, int32_t order) {
	return Object_From(r_cast<Platformer::PlatformWorld*>(self)->getLayer(s_cast<int>(order)));
}
DORA_EXPORT void platformer_platformworld_set_layer_ratio(int64_t self, int32_t order, int64_t ratio) {
	r_cast<Platformer::PlatformWorld*>(self)->setLayerRatio(s_cast<int>(order), Vec2_From(ratio));
}
DORA_EXPORT int64_t platformer_platformworld_get_layer_ratio(int64_t self, int32_t order) {
	return Vec2_Retain(r_cast<Platformer::PlatformWorld*>(self)->getLayerRatio(s_cast<int>(order)));
}
DORA_EXPORT void platformer_platformworld_set_layer_offset(int64_t self, int32_t order, int64_t offset) {
	r_cast<Platformer::PlatformWorld*>(self)->setLayerOffset(s_cast<int>(order), Vec2_From(offset));
}
DORA_EXPORT int64_t platformer_platformworld_get_layer_offset(int64_t self, int32_t order) {
	return Vec2_Retain(r_cast<Platformer::PlatformWorld*>(self)->getLayerOffset(s_cast<int>(order)));
}
DORA_EXPORT void platformer_platformworld_swap_layer(int64_t self, int32_t order_a, int32_t order_b) {
	r_cast<Platformer::PlatformWorld*>(self)->swapLayer(s_cast<int>(order_a), s_cast<int>(order_b));
}
DORA_EXPORT void platformer_platformworld_remove_layer(int64_t self, int32_t order) {
	r_cast<Platformer::PlatformWorld*>(self)->removeLayer(s_cast<int>(order));
}
DORA_EXPORT void platformer_platformworld_remove_all_layers(int64_t self) {
	r_cast<Platformer::PlatformWorld*>(self)->removeAllLayers();
}
DORA_EXPORT int64_t platformer_platformworld_new() {
	return Object_From(Platformer::PlatformWorld::create());
}
} // extern "C"

static void linkPlatformerPlatformWorld(wasm3::module3& mod) {
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