/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t platformer_platformcamera_type() {
	return DoraType<Platformer::PlatformCamera>();
}
DORA_EXPORT void platformer_platformcamera_set_position(int64_t self, int64_t val) {
	r_cast<Platformer::PlatformCamera*>(self)->setPosition(Vec2_From(val));
}
DORA_EXPORT int64_t platformer_platformcamera_get_position(int64_t self) {
	return Vec2_Retain(r_cast<Platformer::PlatformCamera*>(self)->getPosition());
}
DORA_EXPORT void platformer_platformcamera_set_rotation(int64_t self, float val) {
	r_cast<Platformer::PlatformCamera*>(self)->setRotation(val);
}
DORA_EXPORT float platformer_platformcamera_get_rotation(int64_t self) {
	return r_cast<Platformer::PlatformCamera*>(self)->getRotation();
}
DORA_EXPORT void platformer_platformcamera_set_zoom(int64_t self, float val) {
	r_cast<Platformer::PlatformCamera*>(self)->setZoom(val);
}
DORA_EXPORT float platformer_platformcamera_get_zoom(int64_t self) {
	return r_cast<Platformer::PlatformCamera*>(self)->getZoom();
}
DORA_EXPORT void platformer_platformcamera_set_boundary(int64_t self, int64_t val) {
	r_cast<Platformer::PlatformCamera*>(self)->setBoundary(*r_cast<Rect*>(val));
}
DORA_EXPORT int64_t platformer_platformcamera_get_boundary(int64_t self) {
	return r_cast<int64_t>(new Rect{r_cast<Platformer::PlatformCamera*>(self)->getBoundary()});
}
DORA_EXPORT void platformer_platformcamera_set_follow_ratio(int64_t self, int64_t val) {
	r_cast<Platformer::PlatformCamera*>(self)->setFollowRatio(Vec2_From(val));
}
DORA_EXPORT int64_t platformer_platformcamera_get_follow_ratio(int64_t self) {
	return Vec2_Retain(r_cast<Platformer::PlatformCamera*>(self)->getFollowRatio());
}
DORA_EXPORT void platformer_platformcamera_set_follow_offset(int64_t self, int64_t val) {
	r_cast<Platformer::PlatformCamera*>(self)->setFollowOffset(Vec2_From(val));
}
DORA_EXPORT int64_t platformer_platformcamera_get_follow_offset(int64_t self) {
	return Vec2_Retain(r_cast<Platformer::PlatformCamera*>(self)->getFollowOffset());
}
DORA_EXPORT void platformer_platformcamera_set_follow_target(int64_t self, int64_t val) {
	r_cast<Platformer::PlatformCamera*>(self)->setFollowTarget(r_cast<Node*>(val));
}
DORA_EXPORT int64_t platformer_platformcamera_get_follow_target(int64_t self) {
	return Object_From(r_cast<Platformer::PlatformCamera*>(self)->getFollowTarget());
}
DORA_EXPORT void platformer_platformcamera_set_follow_target_null(int64_t self) {
	PlatformCamera_SetFollowTargetNullptr(r_cast<Platformer::PlatformCamera*>(self));
}
DORA_EXPORT int64_t platformer_platformcamera_new(int64_t name) {
	return Object_From(Platformer::PlatformCamera::create(*Str_From(name)));
}
} // extern "C"

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