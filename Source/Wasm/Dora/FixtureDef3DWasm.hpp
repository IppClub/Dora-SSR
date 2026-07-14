/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t fixturedef3d_type() {
	return DoraType<FixtureDef3D>();
}
DORA_EXPORT int32_t fixturedef3d_is_built(int64_t self) {
	return r_cast<FixtureDef3D*>(self)->isBuilt() ? 1 : 0;
}
DORA_EXPORT int32_t fixturedef3d_add_child(int64_t self, int64_t shape, int64_t position, int64_t angles) {
	return r_cast<FixtureDef3D*>(self)->addChild(r_cast<FixtureDef3D*>(shape), Vec3_From(position), Vec3_From(angles)) ? 1 : 0;
}
DORA_EXPORT int32_t fixturedef3d_build(int64_t self) {
	return r_cast<FixtureDef3D*>(self)->build() ? 1 : 0;
}
DORA_EXPORT int64_t fixturedef3d_with_box(int64_t half_extent) {
	return Object_From(FixtureDef3D::createBox(Vec3_From(half_extent)));
}
DORA_EXPORT int64_t fixturedef3d_with_sphere(float radius) {
	return Object_From(FixtureDef3D::createSphere(radius));
}
DORA_EXPORT int64_t fixturedef3d_with_capsule(float half_height, float radius) {
	return Object_From(FixtureDef3D::createCapsule(half_height, radius));
}
DORA_EXPORT int64_t fixturedef3d_with_compound() {
	return Object_From(FixtureDef3D::createCompound());
}
DORA_EXPORT void fixturedef3d_load_mesh_async(int64_t filename, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	FixtureDef3D::loadMeshAsync(*Str_From(filename), [func0, args0, deref0](FixtureDef3D* shape) {
		args0->clear();
		args0->push(shape);
		SharedWasmRuntime.invoke(func0);
	});
}
DORA_EXPORT void fixturedef3d_load_convex_hull_async(int64_t filename, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	FixtureDef3D::loadConvexHullAsync(*Str_From(filename), [func0, args0, deref0](FixtureDef3D* shape) {
		args0->clear();
		args0->push(shape);
		SharedWasmRuntime.invoke(func0);
	});
}
} // extern "C"

static void linkFixtureDef3D(wasm3::module3& mod) {
	mod.link_optional("*", "fixturedef3d_type", fixturedef3d_type);
	mod.link_optional("*", "fixturedef3d_is_built", fixturedef3d_is_built);
	mod.link_optional("*", "fixturedef3d_add_child", fixturedef3d_add_child);
	mod.link_optional("*", "fixturedef3d_build", fixturedef3d_build);
	mod.link_optional("*", "fixturedef3d_with_box", fixturedef3d_with_box);
	mod.link_optional("*", "fixturedef3d_with_sphere", fixturedef3d_with_sphere);
	mod.link_optional("*", "fixturedef3d_with_capsule", fixturedef3d_with_capsule);
	mod.link_optional("*", "fixturedef3d_with_compound", fixturedef3d_with_compound);
	mod.link_optional("*", "fixturedef3d_load_mesh_async", fixturedef3d_load_mesh_async);
	mod.link_optional("*", "fixturedef3d_load_convex_hull_async", fixturedef3d_load_convex_hull_async);
}