/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t dragonbone_type() {
	return DoraType<DragonBone>();
}
void dragonbone_set_hit_test_enabled(int64_t self, int32_t val) {
	r_cast<DragonBone*>(self)->setHitTestEnabled(val != 0);
}
int32_t dragonbone_is_hit_test_enabled(int64_t self) {
	return r_cast<DragonBone*>(self)->isHitTestEnabled() ? 1 : 0;
}
int64_t dragonbone_contains_point(int64_t self, float x, float y) {
	return Str_Retain(r_cast<DragonBone*>(self)->containsPoint(x, y));
}
int64_t dragonbone_intersects_segment(int64_t self, float x_1, float y_1, float x_2, float y_2) {
	return Str_Retain(r_cast<DragonBone*>(self)->intersectsSegment(x_1, y_1, x_2, y_2));
}
int64_t dragonbone_with_files(int64_t bone_file, int64_t atlas_file) {
	return Object_From(DragonBone::create(*Str_From(bone_file), *Str_From(atlas_file)));
}
int64_t dragonbone_new(int64_t bone_str) {
	return Object_From(DragonBone::create(*Str_From(bone_str)));
}
int64_t dragonbone_get_looks(int64_t bone_str) {
	return Vec_To(DragonBone_GetLookNames(*Str_From(bone_str)));
}
int64_t dragonbone_get_animations(int64_t bone_str) {
	return Vec_To(DragonBone_GetAnimationNames(*Str_From(bone_str)));
}
} // extern "C"

static void linkDragonBone(wasm3::module3& mod) {
	mod.link_optional("*", "dragonbone_type", dragonbone_type);
	mod.link_optional("*", "dragonbone_set_hit_test_enabled", dragonbone_set_hit_test_enabled);
	mod.link_optional("*", "dragonbone_is_hit_test_enabled", dragonbone_is_hit_test_enabled);
	mod.link_optional("*", "dragonbone_contains_point", dragonbone_contains_point);
	mod.link_optional("*", "dragonbone_intersects_segment", dragonbone_intersects_segment);
	mod.link_optional("*", "dragonbone_with_files", dragonbone_with_files);
	mod.link_optional("*", "dragonbone_new", dragonbone_new);
	mod.link_optional("*", "dragonbone_get_looks", dragonbone_get_looks);
	mod.link_optional("*", "dragonbone_get_animations", dragonbone_get_animations);
}