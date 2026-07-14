/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t constraint3d_type() {
	return DoraType<Constraint3D>();
}
DORA_EXPORT int64_t constraint3d_get_world(int64_t self) {
	return Object_From(r_cast<Constraint3D*>(self)->getPhysicsWorld());
}
DORA_EXPORT int64_t constraint3d_get_first_body(int64_t self) {
	return Object_From(r_cast<Constraint3D*>(self)->getFirstBody());
}
DORA_EXPORT int64_t constraint3d_get_second_body(int64_t self) {
	return Object_From(r_cast<Constraint3D*>(self)->getSecondBody());
}
DORA_EXPORT void constraint3d_destroy(int64_t self) {
	r_cast<Constraint3D*>(self)->destroy();
}
DORA_EXPORT int64_t constraint3d_fixed(int64_t first_body, int64_t second_body, int64_t anchor) {
	return Object_From(Constraint3D::createFixed(r_cast<Body3D*>(first_body), r_cast<Body3D*>(second_body), Vec3_From(anchor)));
}
DORA_EXPORT int64_t constraint3d_distance(int64_t first_body, int64_t second_body, int64_t first_anchor, int64_t second_anchor, float min_distance, float max_distance) {
	return Object_From(Constraint3D::createDistance(r_cast<Body3D*>(first_body), r_cast<Body3D*>(second_body), Vec3_From(first_anchor), Vec3_From(second_anchor), min_distance, max_distance));
}
DORA_EXPORT int64_t constraint3d_hinge(int64_t first_body, int64_t second_body, int64_t anchor, int64_t axis, float min_angle, float max_angle) {
	return Object_From(Constraint3D::createHinge(r_cast<Body3D*>(first_body), r_cast<Body3D*>(second_body), Vec3_From(anchor), Vec3_From(axis), min_angle, max_angle));
}
} // extern "C"

static void linkConstraint3D(wasm3::module3& mod) {
	mod.link_optional("*", "constraint3d_type", constraint3d_type);
	mod.link_optional("*", "constraint3d_get_world", constraint3d_get_world);
	mod.link_optional("*", "constraint3d_get_first_body", constraint3d_get_first_body);
	mod.link_optional("*", "constraint3d_get_second_body", constraint3d_get_second_body);
	mod.link_optional("*", "constraint3d_destroy", constraint3d_destroy);
	mod.link_optional("*", "constraint3d_fixed", constraint3d_fixed);
	mod.link_optional("*", "constraint3d_distance", constraint3d_distance);
	mod.link_optional("*", "constraint3d_hinge", constraint3d_hinge);
}