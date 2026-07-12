/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT void cache_set_model3_d_budget(int64_t val) {
	Cache::setModel3DBudget(s_cast<uint64_t>(val));
}
DORA_EXPORT int64_t cache_get_model3_d_budget() {
	return s_cast<int64_t>(Cache::getModel3DBudget());
}
DORA_EXPORT int64_t cache_get_model3_d_usage() {
	return s_cast<int64_t>(Cache::getModel3DUsage());
}
DORA_EXPORT int32_t cache_get_model3_d_count() {
	return s_cast<int32_t>(Cache::getModel3DCount());
}
DORA_EXPORT int32_t cache_load(int64_t filename) {
	return Cache::load(*Str_From(filename)) ? 1 : 0;
}
DORA_EXPORT void cache_load_async(int64_t filename, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	Cache::loadAsync(*Str_From(filename), [func0, args0, deref0](bool success) {
		args0->clear();
		args0->push(success);
		SharedWasmRuntime.invoke(func0);
	});
}
DORA_EXPORT int64_t cache_get_load_state(int64_t filename) {
	return Str_Retain(Cache::getLoadState(*Str_From(filename)));
}
DORA_EXPORT int64_t cache_get_load_error(int64_t filename) {
	return Str_Retain(Cache::getLoadError(*Str_From(filename)));
}
DORA_EXPORT int32_t cache_cancel_load(int64_t filename) {
	return Cache::cancelLoad(*Str_From(filename)) ? 1 : 0;
}
DORA_EXPORT void cache_update_item(int64_t filename, int64_t content) {
	Cache::update(*Str_From(filename), *Str_From(content));
}
DORA_EXPORT void cache_update_texture(int64_t filename, int64_t texture) {
	Cache::update(*Str_From(filename), r_cast<Texture2D*>(texture));
}
DORA_EXPORT int32_t cache_unload_item_or_type(int64_t name) {
	return Cache::unload(*Str_From(name)) ? 1 : 0;
}
DORA_EXPORT void cache_unload() {
	Cache::unload();
}
DORA_EXPORT void cache_remove_unused() {
	Cache::removeUnused();
}
DORA_EXPORT void cache_remove_unused_by_type(int64_t type_name) {
	Cache::removeUnused(*Str_From(type_name));
}
} // extern "C"

static void linkCache(wasm3::module3& mod) {
	mod.link_optional("*", "cache_set_model3_d_budget", cache_set_model3_d_budget);
	mod.link_optional("*", "cache_get_model3_d_budget", cache_get_model3_d_budget);
	mod.link_optional("*", "cache_get_model3_d_usage", cache_get_model3_d_usage);
	mod.link_optional("*", "cache_get_model3_d_count", cache_get_model3_d_count);
	mod.link_optional("*", "cache_load", cache_load);
	mod.link_optional("*", "cache_load_async", cache_load_async);
	mod.link_optional("*", "cache_get_load_state", cache_get_load_state);
	mod.link_optional("*", "cache_get_load_error", cache_get_load_error);
	mod.link_optional("*", "cache_cancel_load", cache_cancel_load);
	mod.link_optional("*", "cache_update_item", cache_update_item);
	mod.link_optional("*", "cache_update_texture", cache_update_texture);
	mod.link_optional("*", "cache_unload_item_or_type", cache_unload_item_or_type);
	mod.link_optional("*", "cache_unload", cache_unload);
	mod.link_optional("*", "cache_remove_unused", cache_remove_unused);
	mod.link_optional("*", "cache_remove_unused_by_type", cache_remove_unused_by_type);
}