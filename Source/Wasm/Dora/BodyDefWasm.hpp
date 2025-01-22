/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t bodydef_type() {
	return DoraType<BodyDef>();
}
void bodydef_set_type(int64_t self, int32_t body_type) {
	BodyDef_SetTypeEnum(r_cast<BodyDef*>(self), body_type);
}
int32_t bodydef_get_type(int64_t self) {
	return BodyDef_GetTypeEnum(r_cast<BodyDef*>(self));
}
void bodydef_set_position(int64_t self, int64_t val) {
	r_cast<BodyDef*>(self)->offset = Vec2_From(val);
}
int64_t bodydef_get_position(int64_t self) {
	return Vec2_Retain(r_cast<BodyDef*>(self)->offset);
}
void bodydef_set_angle(int64_t self, float val) {
	r_cast<BodyDef*>(self)->angleOffset = s_cast<float>(val);
}
float bodydef_get_angle(int64_t self) {
	return r_cast<BodyDef*>(self)->angleOffset;
}
void bodydef_set_face(int64_t self, int64_t val) {
	r_cast<BodyDef*>(self)->face = *Str_From(val);
}
int64_t bodydef_get_face(int64_t self) {
	return Str_Retain(r_cast<BodyDef*>(self)->face);
}
void bodydef_set_face_pos(int64_t self, int64_t val) {
	r_cast<BodyDef*>(self)->facePos = Vec2_From(val);
}
int64_t bodydef_get_face_pos(int64_t self) {
	return Vec2_Retain(r_cast<BodyDef*>(self)->facePos);
}
void bodydef_set_linear_damping(int64_t self, float val) {
	r_cast<BodyDef*>(self)->setLinearDamping(val);
}
float bodydef_get_linear_damping(int64_t self) {
	return r_cast<BodyDef*>(self)->getLinearDamping();
}
void bodydef_set_angular_damping(int64_t self, float val) {
	r_cast<BodyDef*>(self)->setAngularDamping(val);
}
float bodydef_get_angular_damping(int64_t self) {
	return r_cast<BodyDef*>(self)->getAngularDamping();
}
void bodydef_set_linear_acceleration(int64_t self, int64_t val) {
	r_cast<BodyDef*>(self)->setLinearAcceleration(Vec2_From(val));
}
int64_t bodydef_get_linear_acceleration(int64_t self) {
	return Vec2_Retain(r_cast<BodyDef*>(self)->getLinearAcceleration());
}
void bodydef_set_fixed_rotation(int64_t self, int32_t val) {
	r_cast<BodyDef*>(self)->setFixedRotation(val != 0);
}
int32_t bodydef_is_fixed_rotation(int64_t self) {
	return r_cast<BodyDef*>(self)->isFixedRotation() ? 1 : 0;
}
void bodydef_set_bullet(int64_t self, int32_t val) {
	r_cast<BodyDef*>(self)->setBullet(val != 0);
}
int32_t bodydef_is_bullet(int64_t self) {
	return r_cast<BodyDef*>(self)->isBullet() ? 1 : 0;
}
int64_t bodydef_polygon_with_center(int64_t center, float width, float height, float angle, float density, float friction, float restitution) {
	return Object_From(BodyDef::polygon(Vec2_From(center), width, height, angle, density, friction, restitution));
}
int64_t bodydef_polygon(float width, float height, float density, float friction, float restitution) {
	return Object_From(BodyDef::polygon(width, height, density, friction, restitution));
}
int64_t bodydef_polygon_with_vertices(int64_t vertices, float density, float friction, float restitution) {
	return Object_From(BodyDef::polygon(Vec_FromVec2(vertices), density, friction, restitution));
}
void bodydef_attach_polygon_with_center(int64_t self, int64_t center, float width, float height, float angle, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachPolygon(Vec2_From(center), width, height, angle, density, friction, restitution);
}
void bodydef_attach_polygon(int64_t self, float width, float height, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachPolygon(width, height, density, friction, restitution);
}
void bodydef_attach_polygon_with_vertices(int64_t self, int64_t vertices, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachPolygon(Vec_FromVec2(vertices), density, friction, restitution);
}
int64_t bodydef_multi(int64_t vertices, float density, float friction, float restitution) {
	return Object_From(BodyDef::multi(Vec_FromVec2(vertices), density, friction, restitution));
}
void bodydef_attach_multi(int64_t self, int64_t vertices, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachMulti(Vec_FromVec2(vertices), density, friction, restitution);
}
int64_t bodydef_disk_with_center(int64_t center, float radius, float density, float friction, float restitution) {
	return Object_From(BodyDef::disk(Vec2_From(center), radius, density, friction, restitution));
}
int64_t bodydef_disk(float radius, float density, float friction, float restitution) {
	return Object_From(BodyDef::disk(radius, density, friction, restitution));
}
void bodydef_attach_disk_with_center(int64_t self, int64_t center, float radius, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachDisk(Vec2_From(center), radius, density, friction, restitution);
}
void bodydef_attach_disk(int64_t self, float radius, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachDisk(radius, density, friction, restitution);
}
int64_t bodydef_chain(int64_t vertices, float friction, float restitution) {
	return Object_From(BodyDef::chain(Vec_FromVec2(vertices), friction, restitution));
}
void bodydef_attach_chain(int64_t self, int64_t vertices, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachChain(Vec_FromVec2(vertices), friction, restitution);
}
void bodydef_attach_polygon_sensor(int64_t self, int32_t tag, float width, float height) {
	r_cast<BodyDef*>(self)->attachPolygonSensor(s_cast<int>(tag), width, height);
}
void bodydef_attach_polygon_sensor_with_center(int64_t self, int32_t tag, int64_t center, float width, float height, float angle) {
	r_cast<BodyDef*>(self)->attachPolygonSensor(s_cast<int>(tag), Vec2_From(center), width, height, angle);
}
void bodydef_attach_polygon_sensor_with_vertices(int64_t self, int32_t tag, int64_t vertices) {
	r_cast<BodyDef*>(self)->attachPolygonSensor(s_cast<int>(tag), Vec_FromVec2(vertices));
}
void bodydef_attach_disk_sensor_with_center(int64_t self, int32_t tag, int64_t center, float radius) {
	r_cast<BodyDef*>(self)->attachDiskSensor(s_cast<int>(tag), Vec2_From(center), radius);
}
void bodydef_attach_disk_sensor(int64_t self, int32_t tag, float radius) {
	r_cast<BodyDef*>(self)->attachDiskSensor(s_cast<int>(tag), radius);
}
int64_t bodydef_new() {
	return Object_From(BodyDef::create());
}
} // extern "C"

static void linkBodyDef(wasm3::module3& mod) {
	mod.link_optional("*", "bodydef_type", bodydef_type);
	mod.link_optional("*", "bodydef_set_type", bodydef_set_type);
	mod.link_optional("*", "bodydef_get_type", bodydef_get_type);
	mod.link_optional("*", "bodydef_set_position", bodydef_set_position);
	mod.link_optional("*", "bodydef_get_position", bodydef_get_position);
	mod.link_optional("*", "bodydef_set_angle", bodydef_set_angle);
	mod.link_optional("*", "bodydef_get_angle", bodydef_get_angle);
	mod.link_optional("*", "bodydef_set_face", bodydef_set_face);
	mod.link_optional("*", "bodydef_get_face", bodydef_get_face);
	mod.link_optional("*", "bodydef_set_face_pos", bodydef_set_face_pos);
	mod.link_optional("*", "bodydef_get_face_pos", bodydef_get_face_pos);
	mod.link_optional("*", "bodydef_set_linear_damping", bodydef_set_linear_damping);
	mod.link_optional("*", "bodydef_get_linear_damping", bodydef_get_linear_damping);
	mod.link_optional("*", "bodydef_set_angular_damping", bodydef_set_angular_damping);
	mod.link_optional("*", "bodydef_get_angular_damping", bodydef_get_angular_damping);
	mod.link_optional("*", "bodydef_set_linear_acceleration", bodydef_set_linear_acceleration);
	mod.link_optional("*", "bodydef_get_linear_acceleration", bodydef_get_linear_acceleration);
	mod.link_optional("*", "bodydef_set_fixed_rotation", bodydef_set_fixed_rotation);
	mod.link_optional("*", "bodydef_is_fixed_rotation", bodydef_is_fixed_rotation);
	mod.link_optional("*", "bodydef_set_bullet", bodydef_set_bullet);
	mod.link_optional("*", "bodydef_is_bullet", bodydef_is_bullet);
	mod.link_optional("*", "bodydef_polygon_with_center", bodydef_polygon_with_center);
	mod.link_optional("*", "bodydef_polygon", bodydef_polygon);
	mod.link_optional("*", "bodydef_polygon_with_vertices", bodydef_polygon_with_vertices);
	mod.link_optional("*", "bodydef_attach_polygon_with_center", bodydef_attach_polygon_with_center);
	mod.link_optional("*", "bodydef_attach_polygon", bodydef_attach_polygon);
	mod.link_optional("*", "bodydef_attach_polygon_with_vertices", bodydef_attach_polygon_with_vertices);
	mod.link_optional("*", "bodydef_multi", bodydef_multi);
	mod.link_optional("*", "bodydef_attach_multi", bodydef_attach_multi);
	mod.link_optional("*", "bodydef_disk_with_center", bodydef_disk_with_center);
	mod.link_optional("*", "bodydef_disk", bodydef_disk);
	mod.link_optional("*", "bodydef_attach_disk_with_center", bodydef_attach_disk_with_center);
	mod.link_optional("*", "bodydef_attach_disk", bodydef_attach_disk);
	mod.link_optional("*", "bodydef_chain", bodydef_chain);
	mod.link_optional("*", "bodydef_attach_chain", bodydef_attach_chain);
	mod.link_optional("*", "bodydef_attach_polygon_sensor", bodydef_attach_polygon_sensor);
	mod.link_optional("*", "bodydef_attach_polygon_sensor_with_center", bodydef_attach_polygon_sensor_with_center);
	mod.link_optional("*", "bodydef_attach_polygon_sensor_with_vertices", bodydef_attach_polygon_sensor_with_vertices);
	mod.link_optional("*", "bodydef_attach_disk_sensor_with_center", bodydef_attach_disk_sensor_with_center);
	mod.link_optional("*", "bodydef_attach_disk_sensor", bodydef_attach_disk_sensor);
	mod.link_optional("*", "bodydef_new", bodydef_new);
}