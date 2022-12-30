static int32_t spine_type() {
	return DoraType<Spine>();
}
static void spine_set_show_debug(int64_t self, int32_t var) {
	r_cast<Spine*>(self)->setShowDebug(var != 0);
}
static int32_t spine_is_show_debug(int64_t self) {
	return r_cast<Spine*>(self)->isShowDebug() ? 1 : 0;
}
static void spine_set_hit_test_enabled(int64_t self, int32_t var) {
	r_cast<Spine*>(self)->setHitTestEnabled(var != 0);
}
static int32_t spine_is_hit_test_enabled(int64_t self) {
	return r_cast<Spine*>(self)->isHitTestEnabled() ? 1 : 0;
}
static int32_t spine_set_bone_rotation(int64_t self, int64_t name, float rotation) {
	return r_cast<Spine*>(self)->setBoneRotation(*str_from(name), rotation) ? 1 : 0;
}
static int64_t spine_contains_point(int64_t self, float x, float y) {
	return str_retain(r_cast<Spine*>(self)->containsPoint(x, y));
}
static int64_t spine_intersects_segment(int64_t self, float x_1, float y_1, float x_2, float y_2) {
	return str_retain(r_cast<Spine*>(self)->intersectsSegment(x_1, y_1, x_2, y_2));
}
static int64_t spine_with_files(int64_t skel_file, int64_t atlas_file) {
	return from_object(Spine::create(*str_from(skel_file), *str_from(atlas_file)));
}
static int64_t spine_new(int64_t spine_str) {
	return from_object(Spine::create(*str_from(spine_str)));
}
static void spine_get_looks(int64_t spine_str) {
	spine_get_look_names(*str_from(spine_str));
}
static void spine_get_animations(int64_t spine_str) {
	spine_get_animation_names(*str_from(spine_str));
}
static void linkSpine(wasm3::module& mod) {
	mod.link_optional("*", "spine_type", spine_type);
	mod.link_optional("*", "spine_set_show_debug", spine_set_show_debug);
	mod.link_optional("*", "spine_is_show_debug", spine_is_show_debug);
	mod.link_optional("*", "spine_set_hit_test_enabled", spine_set_hit_test_enabled);
	mod.link_optional("*", "spine_is_hit_test_enabled", spine_is_hit_test_enabled);
	mod.link_optional("*", "spine_set_bone_rotation", spine_set_bone_rotation);
	mod.link_optional("*", "spine_contains_point", spine_contains_point);
	mod.link_optional("*", "spine_intersects_segment", spine_intersects_segment);
	mod.link_optional("*", "spine_with_files", spine_with_files);
	mod.link_optional("*", "spine_new", spine_new);
	mod.link_optional("*", "spine_get_looks", spine_get_looks);
	mod.link_optional("*", "spine_get_animations", spine_get_animations);
}