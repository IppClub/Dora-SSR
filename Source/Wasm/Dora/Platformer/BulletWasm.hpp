/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t platformer_bullet_type() {
	return DoraType<Platformer::Bullet>();
}
void platformer_bullet_set_target_allow(int64_t self, int32_t val) {
	r_cast<Platformer::Bullet*>(self)->setTargetAllow(s_cast<uint32_t>(val));
}
int32_t platformer_bullet_get_target_allow(int64_t self) {
	return s_cast<int32_t>(r_cast<Platformer::Bullet*>(self)->getTargetAllow());
}
int32_t platformer_bullet_is_face_right(int64_t self) {
	return r_cast<Platformer::Bullet*>(self)->isFaceRight() ? 1 : 0;
}
void platformer_bullet_set_hit_stop(int64_t self, int32_t val) {
	r_cast<Platformer::Bullet*>(self)->setHitStop(val != 0);
}
int32_t platformer_bullet_is_hit_stop(int64_t self) {
	return r_cast<Platformer::Bullet*>(self)->isHitStop() ? 1 : 0;
}
int64_t platformer_bullet_get_emitter(int64_t self) {
	return Object_From(r_cast<Platformer::Bullet*>(self)->getEmitter());
}
int64_t platformer_bullet_get_bullet_def(int64_t self) {
	return Object_From(r_cast<Platformer::Bullet*>(self)->getBulletDef());
}
void platformer_bullet_set_face(int64_t self, int64_t val) {
	r_cast<Platformer::Bullet*>(self)->setFace(r_cast<Node*>(val));
}
int64_t platformer_bullet_get_face(int64_t self) {
	return Object_From(r_cast<Platformer::Bullet*>(self)->getFace());
}
void platformer_bullet_destroy(int64_t self) {
	r_cast<Platformer::Bullet*>(self)->destroy();
}
int64_t platformer_bullet_new(int64_t def, int64_t owner) {
	return Object_From(Platformer::Bullet::create(r_cast<Platformer::BulletDef*>(def), r_cast<Platformer::Unit*>(owner)));
}
} // extern "C"

static void linkPlatformerBullet(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_bullet_type", platformer_bullet_type);
	mod.link_optional("*", "platformer_bullet_set_target_allow", platformer_bullet_set_target_allow);
	mod.link_optional("*", "platformer_bullet_get_target_allow", platformer_bullet_get_target_allow);
	mod.link_optional("*", "platformer_bullet_is_face_right", platformer_bullet_is_face_right);
	mod.link_optional("*", "platformer_bullet_set_hit_stop", platformer_bullet_set_hit_stop);
	mod.link_optional("*", "platformer_bullet_is_hit_stop", platformer_bullet_is_hit_stop);
	mod.link_optional("*", "platformer_bullet_get_emitter", platformer_bullet_get_emitter);
	mod.link_optional("*", "platformer_bullet_get_bullet_def", platformer_bullet_get_bullet_def);
	mod.link_optional("*", "platformer_bullet_set_face", platformer_bullet_set_face);
	mod.link_optional("*", "platformer_bullet_get_face", platformer_bullet_get_face);
	mod.link_optional("*", "platformer_bullet_destroy", platformer_bullet_destroy);
	mod.link_optional("*", "platformer_bullet_new", platformer_bullet_new);
}