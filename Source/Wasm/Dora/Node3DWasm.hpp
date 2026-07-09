/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t node3d_type() {
	return DoraType<Node3D>();
}
DORA_EXPORT void node3d_set_visible(int64_t self, int32_t val) {
	r_cast<Node3D*>(self)->setVisible(val != 0);
}
DORA_EXPORT int32_t node3d_is_visible(int64_t self) {
	return r_cast<Node3D*>(self)->isVisible() ? 1 : 0;
}
DORA_EXPORT int64_t node3d_get_parent(int64_t self) {
	return Object_From(r_cast<Node3D*>(self)->getParent());
}
DORA_EXPORT void node3d_add_child(int64_t self, int64_t child) {
	r_cast<Node3D*>(self)->addChild(r_cast<Node3D*>(child));
}
DORA_EXPORT void node3d_remove_child(int64_t self, int64_t child, int32_t cleanup) {
	r_cast<Node3D*>(self)->removeChild(r_cast<Node3D*>(child), cleanup != 0);
}
DORA_EXPORT void node3d_remove_all_children(int64_t self, int32_t cleanup) {
	r_cast<Node3D*>(self)->removeAllChildren(cleanup != 0);
}
DORA_EXPORT void node3d_remove_from_parent(int64_t self, int32_t cleanup) {
	r_cast<Node3D*>(self)->removeFromParent(cleanup != 0);
}
DORA_EXPORT void node3d_cleanup(int64_t self) {
	r_cast<Node3D*>(self)->cleanup();
}
DORA_EXPORT void node3d_set_position(int64_t self, float x, float y, float z) {
	r_cast<Node3D*>(self)->setPosition(x, y, z);
}
DORA_EXPORT void node3d_set_scale(int64_t self, float x, float y, float z) {
	r_cast<Node3D*>(self)->setScale(x, y, z);
}
DORA_EXPORT void node3d_set_euler_angles(int64_t self, float x, float y, float z) {
	r_cast<Node3D*>(self)->setEulerAngles(x, y, z);
}
DORA_EXPORT int64_t node3d_new() {
	return Object_From(Node3D::create());
}
} // extern "C"

static void linkNode3D(wasm3::module3& mod) {
	mod.link_optional("*", "node3d_type", node3d_type);
	mod.link_optional("*", "node3d_set_visible", node3d_set_visible);
	mod.link_optional("*", "node3d_is_visible", node3d_is_visible);
	mod.link_optional("*", "node3d_get_parent", node3d_get_parent);
	mod.link_optional("*", "node3d_add_child", node3d_add_child);
	mod.link_optional("*", "node3d_remove_child", node3d_remove_child);
	mod.link_optional("*", "node3d_remove_all_children", node3d_remove_all_children);
	mod.link_optional("*", "node3d_remove_from_parent", node3d_remove_from_parent);
	mod.link_optional("*", "node3d_cleanup", node3d_cleanup);
	mod.link_optional("*", "node3d_set_position", node3d_set_position);
	mod.link_optional("*", "node3d_set_scale", node3d_set_scale);
	mod.link_optional("*", "node3d_set_euler_angles", node3d_set_euler_angles);
	mod.link_optional("*", "node3d_new", node3d_new);
}