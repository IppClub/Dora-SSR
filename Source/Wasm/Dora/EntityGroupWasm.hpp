/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t group_type() {
	return DoraType<EntityGroup>();
}
DORA_EXPORT int32_t entitygroup_get_count(int64_t self) {
	return s_cast<int32_t>(r_cast<EntityGroup*>(self)->getCount());
}
DORA_EXPORT int64_t entitygroup_get_first(int64_t self) {
	return Object_From(r_cast<EntityGroup*>(self)->getFirst());
}
DORA_EXPORT int64_t entitygroup_find(int64_t self, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	return Object_From(r_cast<EntityGroup*>(self)->find([func0, args0, deref0](Entity* e) {
		args0->clear();
		args0->push(e);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}));
}
DORA_EXPORT int64_t entitygroup_new(int64_t components) {
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