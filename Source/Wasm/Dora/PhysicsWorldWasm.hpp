/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t physicsworld_type() {
	return DoraType<PhysicsWorld>();
}
int32_t physicsworld_query(int64_t self, int64_t rect, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return r_cast<PhysicsWorld*>(self)->query(*r_cast<Rect*>(rect), [func0, args0, deref0](Body* body) {
		args0->clear();
		args0->push(body);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}) ? 1 : 0;
}
int32_t physicsworld_raycast(int64_t self, int64_t start, int64_t stop, int32_t closest, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return r_cast<PhysicsWorld*>(self)->raycast(Vec2_From(start), Vec2_From(stop), closest != 0, [func0, args0, deref0](Body* body, Vec2 point, Vec2 normal) {
		args0->clear();
		args0->push(body);
		args0->push(point);
		args0->push(normal);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}) ? 1 : 0;
}
void physicsworld_set_iterations(int64_t self, int32_t velocity_iter, int32_t position_iter) {
	r_cast<PhysicsWorld*>(self)->setIterations(s_cast<int>(velocity_iter), s_cast<int>(position_iter));
}
void physicsworld_set_should_contact(int64_t self, int32_t group_a, int32_t group_b, int32_t contact) {
	r_cast<PhysicsWorld*>(self)->setShouldContact(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b), contact != 0);
}
int32_t physicsworld_get_should_contact(int64_t self, int32_t group_a, int32_t group_b) {
	return r_cast<PhysicsWorld*>(self)->getShouldContact(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)) ? 1 : 0;
}
void physicsworld_set_scale_factor(float val) {
	PhysicsWorld::scaleFactor = s_cast<float>(val);
}
float physicsworld_get_scale_factor() {
	return PhysicsWorld::scaleFactor;
}
int64_t physicsworld_new() {
	return Object_From(PhysicsWorld::create());
}
} // extern "C"

static void linkPhysicsWorld(wasm3::module3& mod) {
	mod.link_optional("*", "physicsworld_type", physicsworld_type);
	mod.link_optional("*", "physicsworld_query", physicsworld_query);
	mod.link_optional("*", "physicsworld_raycast", physicsworld_raycast);
	mod.link_optional("*", "physicsworld_set_iterations", physicsworld_set_iterations);
	mod.link_optional("*", "physicsworld_set_should_contact", physicsworld_set_should_contact);
	mod.link_optional("*", "physicsworld_get_should_contact", physicsworld_get_should_contact);
	mod.link_optional("*", "physicsworld_set_scale_factor", physicsworld_set_scale_factor);
	mod.link_optional("*", "physicsworld_get_scale_factor", physicsworld_get_scale_factor);
	mod.link_optional("*", "physicsworld_new", physicsworld_new);
}