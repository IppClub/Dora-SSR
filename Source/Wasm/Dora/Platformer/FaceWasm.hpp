/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t platformer_face_type() {
	return DoraType<Platformer::Face>();
}
void platformer_face_add_child(int64_t self, int64_t face) {
	r_cast<Platformer::Face*>(self)->addChild(r_cast<Platformer::Face*>(face));
}
int64_t platformer_face_to_node(int64_t self) {
	return Object_From(r_cast<Platformer::Face*>(self)->toNode());
}
int64_t platformer_face_new(int64_t face_str, int64_t point, float scale, float angle) {
	return Object_From(Platformer::Face::create(*Str_From(face_str), Vec2_From(point), scale, angle));
}
int64_t platformer_face_with_func(int32_t func, int64_t stack, int64_t point, float scale, float angle) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return Object_From(Platformer::Face::create([func, args, deref]() {
		args->clear();
		SharedWasmRuntime.invoke(func);
		return s_cast<Node*>(std::get<Object*>(args->pop()));
	}, Vec2_From(point), scale, angle));
}
} // extern "C"

static void linkPlatformerFace(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_face_type", platformer_face_type);
	mod.link_optional("*", "platformer_face_add_child", platformer_face_add_child);
	mod.link_optional("*", "platformer_face_to_node", platformer_face_to_node);
	mod.link_optional("*", "platformer_face_new", platformer_face_new);
	mod.link_optional("*", "platformer_face_with_func", platformer_face_with_func);
}