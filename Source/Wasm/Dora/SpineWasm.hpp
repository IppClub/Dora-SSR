/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t spine_type() {
	return DoraType<Spine>();
}
void spine_set_hit_test_enabled(int64_t self, int32_t var) {
	r_cast<Spine*>(self)->setHitTestEnabled(var != 0);
}
int32_t spine_is_hit_test_enabled(int64_t self) {
	return r_cast<Spine*>(self)->isHitTestEnabled() ? 1 : 0;
}
int32_t spine_set_bone_rotation(int64_t self, int64_t name, float rotation) {
	return r_cast<Spine*>(self)->setBoneRotation(*Str_From(name), rotation) ? 1 : 0;
}
int64_t spine_contains_point(int64_t self, float x, float y) {
	return Str_Retain(r_cast<Spine*>(self)->containsPoint(x, y));
}
int64_t spine_intersects_segment(int64_t self, float x_1, float y_1, float x_2, float y_2) {
	return Str_Retain(r_cast<Spine*>(self)->intersectsSegment(x_1, y_1, x_2, y_2));
}
int64_t spine_with_files(int64_t skel_file, int64_t atlas_file) {
	return Object_From(Spine::create(*Str_From(skel_file), *Str_From(atlas_file)));
}
int64_t spine_new(int64_t spine_str) {
	return Object_From(Spine::create(*Str_From(spine_str)));
}
int64_t spine_get_looks(int64_t spine_str) {
	return Vec_To(Spine_GetLookNames(*Str_From(spine_str)));
}
int64_t spine_get_animations(int64_t spine_str) {
	return Vec_To(Spine_GetAnimationNames(*Str_From(spine_str)));
}
} // extern "C"

static void linkSpine(wasm3::module3& mod) {
	mod.link_optional("*", "spine_type", spine_type);
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