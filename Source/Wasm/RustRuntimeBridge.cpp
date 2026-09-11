/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#include "Const/Header.h"

#include "Wasm/RustRuntimeBridge.h"

#include "Basic/Content.h"
#include "Basic/Object.h"
#include "Cache/TextureCache.h"
#include "Common/Debug.h"

#include <cstring>
#include <string>

extern "C" {

DORA_EXPORT int64_t str_new(int32_t len) {
	return r_cast<int64_t>(new std::string(len, 0));
}

DORA_EXPORT int32_t str_len(int64_t value) {
	return s_cast<int32_t>(r_cast<std::string*>(value)->size());
}

DORA_EXPORT void str_read(void* destination, int64_t source) {
	auto value = r_cast<std::string*>(source);
	if (!value->empty()) std::memcpy(destination, value->data(), value->size());
}

DORA_EXPORT void str_write(int64_t destination, const void* source) {
	auto value = r_cast<std::string*>(destination);
	if (!value->empty()) std::memcpy(value->data(), source, value->size());
}

DORA_EXPORT void str_release(int64_t value) {
	delete r_cast<std::string*>(value);
}

DORA_EXPORT void object_release(int64_t value) {
	r_cast<Dora::Object*>(value)->release();
}

DORA_EXPORT void content_set_asset_path(int64_t value) {
	SharedContent.setAssetPath(*r_cast<std::string*>(value));
}

DORA_EXPORT int64_t content_get_full_path(int64_t value) {
	return r_cast<int64_t>(new std::string(
		SharedContent.getFullPath(*r_cast<std::string*>(value))));
}

DORA_EXPORT int64_t content_load(int64_t value) {
	auto data = SharedContent.load(*r_cast<std::string*>(value));
	if (data.second == 0) return 0;
	return r_cast<int64_t>(new std::string(
		r_cast<const char*>(data.first.get()), data.second));
}

DORA_EXPORT int32_t texture2d_get_width(int64_t value) {
	return s_cast<int32_t>(r_cast<Dora::Texture2D*>(value)->getWidth());
}

DORA_EXPORT int32_t texture2d_get_height(int64_t value) {
	return s_cast<int32_t>(r_cast<Dora::Texture2D*>(value)->getHeight());
}

DORA_EXPORT int32_t texture2d_get_handle(int64_t value) {
	return s_cast<int32_t>(r_cast<Dora::Texture2D*>(value)->getHandle().idx);
}

DORA_EXPORT int64_t texture2d_with_file(int64_t value) {
	auto texture = SharedTextureCache.load(*r_cast<std::string*>(value));
	if (texture) texture->retain();
	return r_cast<int64_t>(texture);
}

DORA_EXPORT void dora_print_error(int64_t value) {
	Dora::LogErrorThreaded(*r_cast<std::string*>(value));
}

} // extern "C"
