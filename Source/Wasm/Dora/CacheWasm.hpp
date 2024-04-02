/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

static int32_t cache_load(int64_t filename) {
	return Cache::load(*str_from(filename)) ? 1 : 0;
}
static void cache_load_async(int64_t filename, int32_t func) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	Cache::loadAsync(*str_from(filename), [func, deref]() {
		SharedWasmRuntime.invoke(func);
	});
}
static void cache_update_item(int64_t filename, int64_t content) {
	Cache::update(*str_from(filename), *str_from(content));
}
static void cache_update_texture(int64_t filename, int64_t texture) {
	Cache::update(*str_from(filename), r_cast<Texture2D*>(texture));
}
static int32_t cache_unload_item_or_type(int64_t name) {
	return Cache::unload(*str_from(name)) ? 1 : 0;
}
static void cache_remove_unused() {
	Cache::removeUnused();
}
static void cache_remove_unused_by_type(int64_t type_name) {
	Cache::removeUnused(*str_from(type_name));
}
static void linkCache(wasm3::module3& mod) {
	mod.link_optional("*", "cache_load", cache_load);
	mod.link_optional("*", "cache_load_async", cache_load_async);
	mod.link_optional("*", "cache_update_item", cache_update_item);
	mod.link_optional("*", "cache_update_texture", cache_update_texture);
	mod.link_optional("*", "cache_unload_item_or_type", cache_unload_item_or_type);
	mod.link_optional("*", "cache_remove_unused", cache_remove_unused);
	mod.link_optional("*", "cache_remove_unused_by_type", cache_remove_unused_by_type);
}