/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t bodydef3d_type() {
	return DoraType<BodyDef3D>();
}
DORA_EXPORT void bodydef3d_set_type(int64_t self, int32_t val) {
	r_cast<BodyDef3D*>(self)->setType(s_cast<BodyType3D>(val));
}
DORA_EXPORT int32_t bodydef3d_get_type(int64_t self) {
	return s_cast<int32_t>(r_cast<BodyDef3D*>(self)->getType());
}
DORA_EXPORT void bodydef3d_set_collision_layer(int64_t self, int32_t val) {
	r_cast<BodyDef3D*>(self)->setCollisionLayer(s_cast<uint8_t>(val));
}
DORA_EXPORT int32_t bodydef3d_get_collision_layer(int64_t self) {
	return s_cast<int32_t>(r_cast<BodyDef3D*>(self)->getCollisionLayer());
}
DORA_EXPORT void bodydef3d_set_collision_mask(int64_t self, int32_t val) {
	r_cast<BodyDef3D*>(self)->setCollisionMask(s_cast<uint32_t>(val));
}
DORA_EXPORT int32_t bodydef3d_get_collision_mask(int64_t self) {
	return s_cast<int32_t>(r_cast<BodyDef3D*>(self)->getCollisionMask());
}
DORA_EXPORT void bodydef3d_set_sensor(int64_t self, int32_t val) {
	r_cast<BodyDef3D*>(self)->setSensor(val != 0);
}
DORA_EXPORT int32_t bodydef3d_is_sensor(int64_t self) {
	return r_cast<BodyDef3D*>(self)->isSensor() ? 1 : 0;
}
DORA_EXPORT int32_t bodydef3d_attach(int64_t self, int64_t fixture, int64_t position, int64_t angles) {
	return r_cast<BodyDef3D*>(self)->attach(r_cast<FixtureDef3D*>(fixture), Vec3_From(position), Vec3_From(angles)) ? 1 : 0;
}
DORA_EXPORT int64_t bodydef3d_new() {
	return Object_From(BodyDef3D::create());
}
} // extern "C"

static void linkBodyDef3D(wasm3::module3& mod) {
	mod.link_optional("*", "bodydef3d_type", bodydef3d_type);
	mod.link_optional("*", "bodydef3d_set_type", bodydef3d_set_type);
	mod.link_optional("*", "bodydef3d_get_type", bodydef3d_get_type);
	mod.link_optional("*", "bodydef3d_set_collision_layer", bodydef3d_set_collision_layer);
	mod.link_optional("*", "bodydef3d_get_collision_layer", bodydef3d_get_collision_layer);
	mod.link_optional("*", "bodydef3d_set_collision_mask", bodydef3d_set_collision_mask);
	mod.link_optional("*", "bodydef3d_get_collision_mask", bodydef3d_get_collision_mask);
	mod.link_optional("*", "bodydef3d_set_sensor", bodydef3d_set_sensor);
	mod.link_optional("*", "bodydef3d_is_sensor", bodydef3d_is_sensor);
	mod.link_optional("*", "bodydef3d_attach", bodydef3d_attach);
	mod.link_optional("*", "bodydef3d_new", bodydef3d_new);
}