static int32_t platformer_bullet_type() {
	return DoraType<Platformer::Bullet>();
}
static void platformer_bullet_set_target_allow(int64_t self, int32_t var) {
	r_cast<Platformer::Bullet*>(self)->setTargetAllow(s_cast<uint32_t>(var));
}
static int32_t platformer_bullet_get_target_allow(int64_t self) {
	return s_cast<int32_t>(r_cast<Platformer::Bullet*>(self)->getTargetAllow());
}
static int32_t platformer_bullet_is_face_right(int64_t self) {
	return r_cast<Platformer::Bullet*>(self)->isFaceRight() ? 1 : 0;
}
static void platformer_bullet_set_hit_stop(int64_t self, int32_t var) {
	r_cast<Platformer::Bullet*>(self)->setHitStop(var != 0);
}
static int32_t platformer_bullet_is_hit_stop(int64_t self) {
	return r_cast<Platformer::Bullet*>(self)->isHitStop() ? 1 : 0;
}
static int64_t platformer_bullet_get_owner(int64_t self) {
	return from_object(r_cast<Platformer::Bullet*>(self)->getOwner());
}
static int64_t platformer_bullet_get_bullet_def(int64_t self) {
	return from_object(r_cast<Platformer::Bullet*>(self)->getBulletDef());
}
static void platformer_bullet_set_face(int64_t self, int64_t var) {
	r_cast<Platformer::Bullet*>(self)->setFace(r_cast<Node*>(var));
}
static int64_t platformer_bullet_get_face(int64_t self) {
	return from_object(r_cast<Platformer::Bullet*>(self)->getFace());
}
static void platformer_bullet_destroy(int64_t self) {
	r_cast<Platformer::Bullet*>(self)->destroy();
}
static int64_t platformer_bullet_new(int64_t def, int64_t owner) {
	return from_object(Platformer::Bullet::create(r_cast<Platformer::BulletDef*>(def), r_cast<Platformer::Unit*>(owner)));
}
static void linkPlatformerBullet(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_bullet_type", platformer_bullet_type);
	mod.link_optional("*", "platformer_bullet_set_target_allow", platformer_bullet_set_target_allow);
	mod.link_optional("*", "platformer_bullet_get_target_allow", platformer_bullet_get_target_allow);
	mod.link_optional("*", "platformer_bullet_is_face_right", platformer_bullet_is_face_right);
	mod.link_optional("*", "platformer_bullet_set_hit_stop", platformer_bullet_set_hit_stop);
	mod.link_optional("*", "platformer_bullet_is_hit_stop", platformer_bullet_is_hit_stop);
	mod.link_optional("*", "platformer_bullet_get_owner", platformer_bullet_get_owner);
	mod.link_optional("*", "platformer_bullet_get_bullet_def", platformer_bullet_get_bullet_def);
	mod.link_optional("*", "platformer_bullet_set_face", platformer_bullet_set_face);
	mod.link_optional("*", "platformer_bullet_get_face", platformer_bullet_get_face);
	mod.link_optional("*", "platformer_bullet_destroy", platformer_bullet_destroy);
	mod.link_optional("*", "platformer_bullet_new", platformer_bullet_new);
}