/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
void httpclient_post_async(int64_t url, int64_t json, float timeout, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	SharedHttpClient.postAsync(*Str_From(url), *Str_From(json), timeout, [func0, args0, deref0](OptString body) {
		args0->clear();
		args0->push(body);
		SharedWasmRuntime.invoke(func0);
	});
}
void httpclient_post_with_headers_async(int64_t url, int64_t headers, int64_t json, float timeout, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	SharedHttpClient.postAsync(*Str_From(url), Vec_FromStr(headers), *Str_From(json), timeout, [func0, args0, deref0](OptString body) {
		args0->clear();
		args0->push(body);
		SharedWasmRuntime.invoke(func0);
	});
}
void httpclient_post_with_headers_part_async(int64_t url, int64_t headers, int64_t json, float timeout, int32_t func0, int64_t stack0, int32_t func1, int64_t stack1) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	std::shared_ptr<void> deref1(nullptr, [func1](auto) {
		SharedWasmRuntime.deref(func1);
	});
	auto args1 = r_cast<CallStack*>(stack1);
	SharedHttpClient.postAsync(*Str_From(url), Vec_FromStr(headers), *Str_From(json), timeout, [func0, args0, deref0](String body) {
		args0->clear();
		args0->push(body);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(false);
	}, [func1, args1, deref1](OptString body) {
		args1->clear();
		args1->push(body);
		SharedWasmRuntime.invoke(func1);
	});
}
void httpclient_get_async(int64_t url, float timeout, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	SharedHttpClient.getAsync(*Str_From(url), timeout, [func0, args0, deref0](OptString body) {
		args0->clear();
		args0->push(body);
		SharedWasmRuntime.invoke(func0);
	});
}
void httpclient_download_async(int64_t url, int64_t full_path, float timeout, int32_t func0, int64_t stack0) {
	std::shared_ptr<void> deref0(nullptr, [func0](auto) {
		SharedWasmRuntime.deref(func0);
	});
	auto args0 = r_cast<CallStack*>(stack0);
	SharedHttpClient.downloadAsync(*Str_From(url), *Str_From(full_path), timeout, [func0, args0, deref0](bool interrupted, uint64_t current, uint64_t total) {
		args0->clear();
		args0->push(interrupted);
		args0->push(current);
		args0->push(total);
		SharedWasmRuntime.invoke(func0);
		return args0->pop_bool_or(true);
	});
}
} // extern "C"

static void linkHttpClient(wasm3::module3& mod) {
	mod.link_optional("*", "httpclient_post_async", httpclient_post_async);
	mod.link_optional("*", "httpclient_post_with_headers_async", httpclient_post_with_headers_async);
	mod.link_optional("*", "httpclient_post_with_headers_part_async", httpclient_post_with_headers_part_async);
	mod.link_optional("*", "httpclient_get_async", httpclient_get_async);
	mod.link_optional("*", "httpclient_download_async", httpclient_download_async);
}