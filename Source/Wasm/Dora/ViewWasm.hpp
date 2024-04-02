/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int64_t view_get_size() {
	return size_retain(SharedView.getSize());
}
static float view_get_standard_distance() {
	return SharedView.getStandardDistance();
}
static float view_get_aspect_ratio() {
	return SharedView.getAspectRatio();
}
static void view_set_near_plane_distance(float var) {
	SharedView.setNearPlaneDistance(var);
}
static float view_get_near_plane_distance() {
	return SharedView.getNearPlaneDistance();
}
static void view_set_far_plane_distance(float var) {
	SharedView.setFarPlaneDistance(var);
}
static float view_get_far_plane_distance() {
	return SharedView.getFarPlaneDistance();
}
static void view_set_field_of_view(float var) {
	SharedView.setFieldOfView(var);
}
static float view_get_field_of_view() {
	return SharedView.getFieldOfView();
}
static void view_set_scale(float var) {
	SharedView.setScale(var);
}
static float view_get_scale() {
	return SharedView.getScale();
}
static void view_set_post_effect(int64_t var) {
	SharedView.setPostEffect(r_cast<SpriteEffect*>(var));
}
static int64_t view_get_post_effect() {
	return from_object(SharedView.getPostEffect());
}
static void view_set_post_effect_null() {
	view_set_post_effect_nullptr();
}
static void view_set_vsync(int32_t var) {
	SharedView.setVSync(var != 0);
}
static int32_t view_is_vsync() {
	return SharedView.isVSync() ? 1 : 0;
}
static void linkView(wasm3::module3& mod) {
	mod.link_optional("*", "view_get_size", view_get_size);
	mod.link_optional("*", "view_get_standard_distance", view_get_standard_distance);
	mod.link_optional("*", "view_get_aspect_ratio", view_get_aspect_ratio);
	mod.link_optional("*", "view_set_near_plane_distance", view_set_near_plane_distance);
	mod.link_optional("*", "view_get_near_plane_distance", view_get_near_plane_distance);
	mod.link_optional("*", "view_set_far_plane_distance", view_set_far_plane_distance);
	mod.link_optional("*", "view_get_far_plane_distance", view_get_far_plane_distance);
	mod.link_optional("*", "view_set_field_of_view", view_set_field_of_view);
	mod.link_optional("*", "view_get_field_of_view", view_get_field_of_view);
	mod.link_optional("*", "view_set_scale", view_set_scale);
	mod.link_optional("*", "view_get_scale", view_get_scale);
	mod.link_optional("*", "view_set_post_effect", view_set_post_effect);
	mod.link_optional("*", "view_get_post_effect", view_get_post_effect);
	mod.link_optional("*", "view_set_post_effect_null", view_set_post_effect_null);
	mod.link_optional("*", "view_set_vsync", view_set_vsync);
	mod.link_optional("*", "view_is_vsync", view_is_vsync);
}