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
DORA_EXPORT int32_t node3d_has_children(int64_t self) {
	return r_cast<Node3D*>(self)->hasChildren() ? 1 : 0;
}
DORA_EXPORT void node3d_set_position(int64_t self, int64_t val) {
	r_cast<Node3D*>(self)->setPosition(Vec3_From(val));
}
DORA_EXPORT int64_t node3d_get_position(int64_t self) {
	return Vec3_Retain(r_cast<Node3D*>(self)->getPosition());
}
DORA_EXPORT void node3d_set_scale(int64_t self, int64_t val) {
	r_cast<Node3D*>(self)->setScale(Vec3_From(val));
}
DORA_EXPORT int64_t node3d_get_scale(int64_t self) {
	return Vec3_Retain(r_cast<Node3D*>(self)->getScale());
}
DORA_EXPORT void node3d_set_euler_angles(int64_t self, int64_t val) {
	r_cast<Node3D*>(self)->setEulerAngles(Vec3_From(val));
}
DORA_EXPORT int64_t node3d_get_euler_angles(int64_t self) {
	return Vec3_Retain(r_cast<Node3D*>(self)->getEulerAngles());
}
DORA_EXPORT void node3d_set_x(int64_t self, float val) {
	r_cast<Node3D*>(self)->setX(val);
}
DORA_EXPORT float node3d_get_x(int64_t self) {
	return r_cast<Node3D*>(self)->getX();
}
DORA_EXPORT void node3d_set_y(int64_t self, float val) {
	r_cast<Node3D*>(self)->setY(val);
}
DORA_EXPORT float node3d_get_y(int64_t self) {
	return r_cast<Node3D*>(self)->getY();
}
DORA_EXPORT void node3d_set_z(int64_t self, float val) {
	r_cast<Node3D*>(self)->setZ(val);
}
DORA_EXPORT float node3d_get_z(int64_t self) {
	return r_cast<Node3D*>(self)->getZ();
}
DORA_EXPORT void node3d_set_angle_x(int64_t self, float val) {
	r_cast<Node3D*>(self)->setAngleX(val);
}
DORA_EXPORT float node3d_get_angle_x(int64_t self) {
	return r_cast<Node3D*>(self)->getAngleX();
}
DORA_EXPORT void node3d_set_angle_y(int64_t self, float val) {
	r_cast<Node3D*>(self)->setAngleY(val);
}
DORA_EXPORT float node3d_get_angle_y(int64_t self) {
	return r_cast<Node3D*>(self)->getAngleY();
}
DORA_EXPORT void node3d_set_angle_z(int64_t self, float val) {
	r_cast<Node3D*>(self)->setAngleZ(val);
}
DORA_EXPORT float node3d_get_angle_z(int64_t self) {
	return r_cast<Node3D*>(self)->getAngleZ();
}
DORA_EXPORT void node3d_set_scale_x(int64_t self, float val) {
	r_cast<Node3D*>(self)->setScaleX(val);
}
DORA_EXPORT float node3d_get_scale_x(int64_t self) {
	return r_cast<Node3D*>(self)->getScaleX();
}
DORA_EXPORT void node3d_set_scale_y(int64_t self, float val) {
	r_cast<Node3D*>(self)->setScaleY(val);
}
DORA_EXPORT float node3d_get_scale_y(int64_t self) {
	return r_cast<Node3D*>(self)->getScaleY();
}
DORA_EXPORT void node3d_set_scale_z(int64_t self, float val) {
	r_cast<Node3D*>(self)->setScaleZ(val);
}
DORA_EXPORT float node3d_get_scale_z(int64_t self) {
	return r_cast<Node3D*>(self)->getScaleZ();
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
DORA_EXPORT int64_t node3d_convert_to_world_space(int64_t self, int64_t local_point) {
	return Vec3_Retain(r_cast<Node3D*>(self)->convertToWorldSpace(Vec3_From(local_point)));
}
DORA_EXPORT int64_t node3d_convert_to_node_space(int64_t self, int64_t world_point) {
	return Vec3_Retain(r_cast<Node3D*>(self)->convertToNodeSpace(Vec3_From(world_point)));
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
	mod.link_optional("*", "node3d_has_children", node3d_has_children);
	mod.link_optional("*", "node3d_set_position", node3d_set_position);
	mod.link_optional("*", "node3d_get_position", node3d_get_position);
	mod.link_optional("*", "node3d_set_scale", node3d_set_scale);
	mod.link_optional("*", "node3d_get_scale", node3d_get_scale);
	mod.link_optional("*", "node3d_set_euler_angles", node3d_set_euler_angles);
	mod.link_optional("*", "node3d_get_euler_angles", node3d_get_euler_angles);
	mod.link_optional("*", "node3d_set_x", node3d_set_x);
	mod.link_optional("*", "node3d_get_x", node3d_get_x);
	mod.link_optional("*", "node3d_set_y", node3d_set_y);
	mod.link_optional("*", "node3d_get_y", node3d_get_y);
	mod.link_optional("*", "node3d_set_z", node3d_set_z);
	mod.link_optional("*", "node3d_get_z", node3d_get_z);
	mod.link_optional("*", "node3d_set_angle_x", node3d_set_angle_x);
	mod.link_optional("*", "node3d_get_angle_x", node3d_get_angle_x);
	mod.link_optional("*", "node3d_set_angle_y", node3d_set_angle_y);
	mod.link_optional("*", "node3d_get_angle_y", node3d_get_angle_y);
	mod.link_optional("*", "node3d_set_angle_z", node3d_set_angle_z);
	mod.link_optional("*", "node3d_get_angle_z", node3d_get_angle_z);
	mod.link_optional("*", "node3d_set_scale_x", node3d_set_scale_x);
	mod.link_optional("*", "node3d_get_scale_x", node3d_get_scale_x);
	mod.link_optional("*", "node3d_set_scale_y", node3d_set_scale_y);
	mod.link_optional("*", "node3d_get_scale_y", node3d_get_scale_y);
	mod.link_optional("*", "node3d_set_scale_z", node3d_set_scale_z);
	mod.link_optional("*", "node3d_get_scale_z", node3d_get_scale_z);
	mod.link_optional("*", "node3d_add_child", node3d_add_child);
	mod.link_optional("*", "node3d_remove_child", node3d_remove_child);
	mod.link_optional("*", "node3d_remove_all_children", node3d_remove_all_children);
	mod.link_optional("*", "node3d_remove_from_parent", node3d_remove_from_parent);
	mod.link_optional("*", "node3d_cleanup", node3d_cleanup);
	mod.link_optional("*", "node3d_convert_to_world_space", node3d_convert_to_world_space);
	mod.link_optional("*", "node3d_convert_to_node_space", node3d_convert_to_node_space);
	mod.link_optional("*", "node3d_new", node3d_new);
}