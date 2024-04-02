/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t platformer_bulletdef_type() {
	return DoraType<Platformer::BulletDef>();
}
static void platformer_bulletdef_set_tag(int64_t self, int64_t var) {
	r_cast<Platformer::BulletDef*>(self)->tag = *str_from(var);
}
static int64_t platformer_bulletdef_get_tag(int64_t self) {
	return str_retain(r_cast<Platformer::BulletDef*>(self)->tag);
}
static void platformer_bulletdef_set_end_effect(int64_t self, int64_t var) {
	r_cast<Platformer::BulletDef*>(self)->endEffect = *str_from(var);
}
static int64_t platformer_bulletdef_get_end_effect(int64_t self) {
	return str_retain(r_cast<Platformer::BulletDef*>(self)->endEffect);
}
static void platformer_bulletdef_set_life_time(int64_t self, float var) {
	r_cast<Platformer::BulletDef*>(self)->lifeTime = s_cast<float>(var);
}
static float platformer_bulletdef_get_life_time(int64_t self) {
	return r_cast<Platformer::BulletDef*>(self)->lifeTime;
}
static void platformer_bulletdef_set_damage_radius(int64_t self, float var) {
	r_cast<Platformer::BulletDef*>(self)->damageRadius = s_cast<float>(var);
}
static float platformer_bulletdef_get_damage_radius(int64_t self) {
	return r_cast<Platformer::BulletDef*>(self)->damageRadius;
}
static void platformer_bulletdef_set_high_speed_fix(int64_t self, int32_t var) {
	r_cast<Platformer::BulletDef*>(self)->setHighSpeedFix(var != 0);
}
static int32_t platformer_bulletdef_is_high_speed_fix(int64_t self) {
	return r_cast<Platformer::BulletDef*>(self)->isHighSpeedFix() ? 1 : 0;
}
static void platformer_bulletdef_set_gravity(int64_t self, int64_t var) {
	r_cast<Platformer::BulletDef*>(self)->setGravity(vec2_from(var));
}
static int64_t platformer_bulletdef_get_gravity(int64_t self) {
	return vec2_retain(r_cast<Platformer::BulletDef*>(self)->getGravity());
}
static void platformer_bulletdef_set_face(int64_t self, int64_t var) {
	r_cast<Platformer::BulletDef*>(self)->setFace(r_cast<Platformer::Face*>(var));
}
static int64_t platformer_bulletdef_get_face(int64_t self) {
	return from_object(r_cast<Platformer::BulletDef*>(self)->getFace());
}
static int64_t platformer_bulletdef_get_body_def(int64_t self) {
	return from_object(r_cast<Platformer::BulletDef*>(self)->getBodyDef());
}
static int64_t platformer_bulletdef_get_velocity(int64_t self) {
	return vec2_retain(r_cast<Platformer::BulletDef*>(self)->getVelocity());
}
static void platformer_bulletdef_set_as_circle(int64_t self, float radius) {
	r_cast<Platformer::BulletDef*>(self)->setAsCircle(radius);
}
static void platformer_bulletdef_set_velocity(int64_t self, float angle, float speed) {
	r_cast<Platformer::BulletDef*>(self)->setVelocity(angle, speed);
}
static int64_t platformer_bulletdef_new() {
	return from_object(Platformer::BulletDef::create());
}
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