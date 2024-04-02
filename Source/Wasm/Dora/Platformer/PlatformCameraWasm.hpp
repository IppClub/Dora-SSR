/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t platformer_platformcamera_type() {
	return DoraType<Platformer::PlatformCamera>();
}
static void platformer_platformcamera_set_position(int64_t self, int64_t var) {
	r_cast<Platformer::PlatformCamera*>(self)->setPosition(vec2_from(var));
}
static int64_t platformer_platformcamera_get_position(int64_t self) {
	return vec2_retain(r_cast<Platformer::PlatformCamera*>(self)->getPosition());
}
static void platformer_platformcamera_set_rotation(int64_t self, float var) {
	r_cast<Platformer::PlatformCamera*>(self)->setRotation(var);
}
static float platformer_platformcamera_get_rotation(int64_t self) {
	return r_cast<Platformer::PlatformCamera*>(self)->getRotation();
}
static void platformer_platformcamera_set_zoom(int64_t self, float var) {
	r_cast<Platformer::PlatformCamera*>(self)->setZoom(var);
}
static float platformer_platformcamera_get_zoom(int64_t self) {
	return r_cast<Platformer::PlatformCamera*>(self)->getZoom();
}
static void platformer_platformcamera_set_boundary(int64_t self, int64_t var) {
	r_cast<Platformer::PlatformCamera*>(self)->setBoundary(*r_cast<Rect*>(var));
}
static int64_t platformer_platformcamera_get_boundary(int64_t self) {
	return r_cast<int64_t>(new Rect{r_cast<Platformer::PlatformCamera*>(self)->getBoundary()});
}
static void platformer_platformcamera_set_follow_ratio(int64_t self, int64_t var) {
	r_cast<Platformer::PlatformCamera*>(self)->setFollowRatio(vec2_from(var));
}
static int64_t platformer_platformcamera_get_follow_ratio(int64_t self) {
	return vec2_retain(r_cast<Platformer::PlatformCamera*>(self)->getFollowRatio());
}
static void platformer_platformcamera_set_follow_offset(int64_t self, int64_t var) {
	r_cast<Platformer::PlatformCamera*>(self)->setFollowOffset(vec2_from(var));
}
static int64_t platformer_platformcamera_get_follow_offset(int64_t self) {
	return vec2_retain(r_cast<Platformer::PlatformCamera*>(self)->getFollowOffset());
}
static void platformer_platformcamera_set_follow_target(int64_t self, int64_t var) {
	r_cast<Platformer::PlatformCamera*>(self)->setFollowTarget(r_cast<Node*>(var));
}
static int64_t platformer_platformcamera_get_follow_target(int64_t self) {
	return from_object(r_cast<Platformer::PlatformCamera*>(self)->getFollowTarget());
}
static void platformer_platformcamera_set_follow_target_null(int64_t self) {
	platform_camera_set_follow_target_nullptr(r_cast<Platformer::PlatformCamera*>(self));
}
static int64_t platformer_platformcamera_new(int64_t name) {
	return from_object(Platformer::PlatformCamera::create(*str_from(name)));
}
static void linkPlatformerPlatformCamera(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_platformcamera_type", platformer_platformcamera_type);
	mod.link_optional("*", "platformer_platformcamera_set_position", platformer_platformcamera_set_position);
	mod.link_optional("*", "platformer_platformcamera_get_position", platformer_platformcamera_get_position);
	mod.link_optional("*", "platformer_platformcamera_set_rotation", platformer_platformcamera_set_rotation);
	mod.link_optional("*", "platformer_platformcamera_get_rotation", platformer_platformcamera_get_rotation);
	mod.link_optional("*", "platformer_platformcamera_set_zoom", platformer_platformcamera_set_zoom);
	mod.link_optional("*", "platformer_platformcamera_get_zoom", platformer_platformcamera_get_zoom);
	mod.link_optional("*", "platformer_platformcamera_set_boundary", platformer_platformcamera_set_boundary);
	mod.link_optional("*", "platformer_platformcamera_get_boundary", platformer_platformcamera_get_boundary);
	mod.link_optional("*", "platformer_platformcamera_set_follow_ratio", platformer_platformcamera_set_follow_ratio);
	mod.link_optional("*", "platformer_platformcamera_get_follow_ratio", platformer_platformcamera_get_follow_ratio);
	mod.link_optional("*", "platformer_platformcamera_set_follow_offset", platformer_platformcamera_set_follow_offset);
	mod.link_optional("*", "platformer_platformcamera_get_follow_offset", platformer_platformcamera_get_follow_offset);
	mod.link_optional("*", "platformer_platformcamera_set_follow_target", platformer_platformcamera_set_follow_target);
	mod.link_optional("*", "platformer_platformcamera_get_follow_target", platformer_platformcamera_get_follow_target);
	mod.link_optional("*", "platformer_platformcamera_set_follow_target_null", platformer_platformcamera_set_follow_target_null);
	mod.link_optional("*", "platformer_platformcamera_new", platformer_platformcamera_new);
}