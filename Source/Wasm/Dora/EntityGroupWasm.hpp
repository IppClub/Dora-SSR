/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
int32_t group_type() {
	return DoraType<EntityGroup>();
}
int32_t entitygroup_get_count(int64_t self) {
	return s_cast<int32_t>(r_cast<EntityGroup*>(self)->getCount());
}
int64_t entitygroup_get_first(int64_t self) {
	return Object_From(r_cast<EntityGroup*>(self)->getFirst());
}
int64_t entitygroup_find(int64_t self, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	return Object_From(r_cast<EntityGroup*>(self)->find([func, args, deref](Entity* e) {
		args->clear();
		args->push(e);
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	}));
}
int64_t entitygroup_new(int64_t components) {
	return Object_From(EntityGroup::create(Vec_FromStr(components)));
}
} // extern "C"

static void linkEntityGroup(wasm3::module3& mod) {
	mod.link_optional("*", "group_type", group_type);
	mod.link_optional("*", "entitygroup_get_count", entitygroup_get_count);
	mod.link_optional("*", "entitygroup_get_first", entitygroup_get_first);
	mod.link_optional("*", "entitygroup_find", entitygroup_find);
	mod.link_optional("*", "entitygroup_new", entitygroup_new);
}