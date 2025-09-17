/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t platformer_bulletdef_type() {
	return DoraType<Platformer::BulletDef>();
}
DORA_EXPORT void platformer_bulletdef_set_tag(int64_t self, int64_t val) {
	r_cast<Platformer::BulletDef*>(self)->tag = *Str_From(val);
}
DORA_EXPORT int64_t platformer_bulletdef_get_tag(int64_t self) {
	return Str_Retain(r_cast<Platformer::BulletDef*>(self)->tag);
}
DORA_EXPORT void platformer_bulletdef_set_end_effect(int64_t self, int64_t val) {
	r_cast<Platformer::BulletDef*>(self)->endEffect = *Str_From(val);
}
DORA_EXPORT int64_t platformer_bulletdef_get_end_effect(int64_t self) {
	return Str_Retain(r_cast<Platformer::BulletDef*>(self)->endEffect);
}
DORA_EXPORT void platformer_bulletdef_set_life_time(int64_t self, float val) {
	r_cast<Platformer::BulletDef*>(self)->lifeTime = s_cast<float>(val);
}
DORA_EXPORT float platformer_bulletdef_get_life_time(int64_t self) {
	return r_cast<Platformer::BulletDef*>(self)->lifeTime;
}
DORA_EXPORT void platformer_bulletdef_set_damage_radius(int64_t self, float val) {
	r_cast<Platformer::BulletDef*>(self)->damageRadius = s_cast<float>(val);
}
DORA_EXPORT float platformer_bulletdef_get_damage_radius(int64_t self) {
	return r_cast<Platformer::BulletDef*>(self)->damageRadius;
}
DORA_EXPORT void platformer_bulletdef_set_high_speed_fix(int64_t self, int32_t val) {
	r_cast<Platformer::BulletDef*>(self)->setHighSpeedFix(val != 0);
}
DORA_EXPORT int32_t platformer_bulletdef_is_high_speed_fix(int64_t self) {
	return r_cast<Platformer::BulletDef*>(self)->isHighSpeedFix() ? 1 : 0;
}
DORA_EXPORT void platformer_bulletdef_set_gravity(int64_t self, int64_t val) {
	r_cast<Platformer::BulletDef*>(self)->setGravity(Vec2_From(val));
}
DORA_EXPORT int64_t platformer_bulletdef_get_gravity(int64_t self) {
	return Vec2_Retain(r_cast<Platformer::BulletDef*>(self)->getGravity());
}
DORA_EXPORT void platformer_bulletdef_set_face(int64_t self, int64_t val) {
	r_cast<Platformer::BulletDef*>(self)->setFace(r_cast<Platformer::Face*>(val));
}
DORA_EXPORT int64_t platformer_bulletdef_get_face(int64_t self) {
	return Object_From(r_cast<Platformer::BulletDef*>(self)->getFace());
}
DORA_EXPORT int64_t platformer_bulletdef_get_body_def(int64_t self) {
	return Object_From(r_cast<Platformer::BulletDef*>(self)->getBodyDef());
}
DORA_EXPORT int64_t platformer_bulletdef_get_velocity(int64_t self) {
	return Vec2_Retain(r_cast<Platformer::BulletDef*>(self)->getVelocity());
}
DORA_EXPORT void platformer_bulletdef_set_as_circle(int64_t self, float radius) {
	r_cast<Platformer::BulletDef*>(self)->setAsCircle(radius);
}
DORA_EXPORT void platformer_bulletdef_set_velocity(int64_t self, float angle, float speed) {
	r_cast<Platformer::BulletDef*>(self)->setVelocity(angle, speed);
}
DORA_EXPORT int64_t platformer_bulletdef_new() {
	return Object_From(Platformer::BulletDef::create());
}
} // extern "C"

static void linkPlatformerBulletDef(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_bulletdef_type", platformer_bulletdef_type);
	mod.link_optional("*", "platformer_bulletdef_set_tag", platformer_bulletdef_set_tag);
	mod.link_optional("*", "platformer_bulletdef_get_tag", platformer_bulletdef_get_tag);
	mod.link_optional("*", "platformer_bulletdef_set_end_effect", platformer_bulletdef_set_end_effect);
	mod.link_optional("*", "platformer_bulletdef_get_end_effect", platformer_bulletdef_get_end_effect);
	mod.link_optional("*", "platformer_bulletdef_set_life_time", platformer_bulletdef_set_life_time);
	mod.link_optional("*", "platformer_bulletdef_get_life_time", platformer_bulletdef_get_life_time);
	mod.link_optional("*", "platformer_bulletdef_set_damage_radius", platformer_bulletdef_set_damage_radius);
	mod.link_optional("*", "platformer_bulletdef_get_damage_radius", platformer_bulletdef_get_damage_radius);
	mod.link_optional("*", "platformer_bulletdef_set_high_speed_fix", platformer_bulletdef_set_high_speed_fix);
	mod.link_optional("*", "platformer_bulletdef_is_high_speed_fix", platformer_bulletdef_is_high_speed_fix);
	mod.link_optional("*", "platformer_bulletdef_set_gravity", platformer_bulletdef_set_gravity);
	mod.link_optional("*", "platformer_bulletdef_get_gravity", platformer_bulletdef_get_gravity);
	mod.link_optional("*", "platformer_bulletdef_set_face", platformer_bulletdef_set_face);
	mod.link_optional("*", "platformer_bulletdef_get_face", platformer_bulletdef_get_face);
	mod.link_optional("*", "platformer_bulletdef_get_body_def", platformer_bulletdef_get_body_def);
	mod.link_optional("*", "platformer_bulletdef_get_velocity", platformer_bulletdef_get_velocity);
	mod.link_optional("*", "platformer_bulletdef_set_as_circle", platformer_bulletdef_set_as_circle);
	mod.link_optional("*", "platformer_bulletdef_set_velocity", platformer_bulletdef_set_velocity);
	mod.link_optional("*", "platformer_bulletdef_new", platformer_bulletdef_new);
}