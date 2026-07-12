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
} // extern "C"

static void linkConstraint3D(wasm3::module3& mod) {
	mod.link_optional("*", "constraint3d_type", constraint3d_type);
	mod.link_optional("*", "constraint3d_get_world", constraint3d_get_world);
	mod.link_optional("*", "constraint3d_get_first_body", constraint3d_get_first_body);
	mod.link_optional("*", "constraint3d_get_second_body", constraint3d_get_second_body);
	mod.link_optional("*", "constraint3d_destroy", constraint3d_destroy);
}