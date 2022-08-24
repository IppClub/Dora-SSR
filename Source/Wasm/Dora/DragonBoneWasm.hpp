static int32_t dragonbone_type() {
	return DoraType<DragonBone>();
}
static void dragonbone_set_show_debug(int64_t self, int32_t var) {
	r_cast<DragonBone*>(self)->setShowDebug(var != 0);
}
static int32_t dragonbone_is_show_debug(int64_t self) {
	return r_cast<DragonBone*>(self)->isShowDebug() ? 1 : 0;
}
static void dragonbone_set_hit_test_enabled(int64_t self, int32_t var) {
	r_cast<DragonBone*>(self)->setHitTestEnabled(var != 0);
}
static int32_t dragonbone_is_hit_test_enabled(int64_t self) {
	return r_cast<DragonBone*>(self)->isHitTestEnabled() ? 1 : 0;
}
static int64_t dragonbone_contains_point(int64_t self, float x, float y) {
	return str_retain(r_cast<DragonBone*>(self)->containsPoint(x, y));
}
static int64_t dragonbone_intersects_segment(int64_t self, float x_1, float y_1, float x_2, float y_2) {
	return str_retain(r_cast<DragonBone*>(self)->intersectsSegment(x_1, y_1, x_2, y_2));
}
static int64_t dragonbone_with_files(int64_t bone_file, int64_t atlas_file) {
	return from_object(DragonBone::create(*str_from(bone_file), *str_from(atlas_file)));
}
static int64_t dragonbone_new(int64_t bone_str) {
	return from_object(DragonBone::create(*str_from(bone_str)));
}
static void dragonbone_get_looks(int64_t bone_str) {
	dragon_bone_get_look_names(*str_from(bone_str));
}
static void dragonbone_get_animations(int64_t bone_str) {
	dragon_bone_get_animation_names(*str_from(bone_str));
}
static void linkDragonBone(wasm3::module& mod) {
	mod.link_optional("*", "dragonbone_type", dragonbone_type);
	mod.link_optional("*", "dragonbone_set_show_debug", dragonbone_set_show_debug);
	mod.link_optional("*", "dragonbone_is_show_debug", dragonbone_is_show_debug);
	mod.link_optional("*", "dragonbone_set_hit_test_enabled", dragonbone_set_hit_test_enabled);
	mod.link_optional("*", "dragonbone_is_hit_test_enabled", dragonbone_is_hit_test_enabled);
	mod.link_optional("*", "dragonbone_contains_point", dragonbone_contains_point);
	mod.link_optional("*", "dragonbone_intersects_segment", dragonbone_intersects_segment);
	mod.link_optional("*", "dragonbone_with_files", dragonbone_with_files);
	mod.link_optional("*", "dragonbone_new", dragonbone_new);
	mod.link_optional("*", "dragonbone_get_looks", dragonbone_get_looks);
	mod.link_optional("*", "dragonbone_get_animations", dragonbone_get_animations);
}