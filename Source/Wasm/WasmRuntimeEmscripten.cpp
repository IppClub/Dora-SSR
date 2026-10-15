/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#include "Wasm/WasmRuntimeEmscripten.h"

#include <emscripten.h>

#include <atomic>
#include <mutex>
#include <unordered_map>
#include <utility>

NS_DORA_BEGIN

namespace {

using StringCallback = std::function<void(String)>;

std::mutex s_callbackMutex;
std::unordered_map<int64_t, StringCallback> s_callbacks;
std::atomic_int64_t s_nextCallback{0};

int64_t registerCallback(StringCallback callback) {
	const auto id = s_nextCallback.fetch_add(1, std::memory_order_relaxed) + 1;
	std::lock_guard<std::mutex> lock(s_callbackMutex);
	s_callbacks.emplace(id, std::move(callback));
	return id;
}

StringCallback takeCallback(int64_t id) {
	std::lock_guard<std::mutex> lock(s_callbackMutex);
	auto it = s_callbacks.find(id);
	if (it == s_callbacks.end()) return {};
	auto callback = std::move(it->second);
	s_callbacks.erase(it);
	return callback;
}

} // namespace

extern "C" EMSCRIPTEN_KEEPALIVE void dora_wa_string_done(int64_t id, const char* result) {
	if (auto callback = takeCallback(id)) {
		callback(result ? String(result) : Slice::Empty);
	}
}

EM_JS(void, dora_wa_start_string_call, (const char* operation, int64_t id, const char* path), {
	const name = UTF8ToString(operation);
	const input = UTF8ToString(path);
	const finish = value => Module.ccall(
		'dora_wa_string_done',
		null,
		['number', 'string'],
		[id, String(value == null ? "" : value)]);
	const fail = error => finish('Wa ' + name + ' failed: ' + String(error));
	Promise.resolve().then(() => {
		if (!globalThis.DoraWa) {
			throw new Error('browser Wa module is not ready');
		}
		return Promise.resolve(globalThis.DoraWa.ready).then(api => {
			if (!api || typeof api[name] !== 'function') {
				throw new Error('browser Wa module is not ready');
			}
			return api[name](input);
		});
	}).then(finish, fail);
});

static void startStringCall(const char* operation, const std::string& path, StringCallback callback) {
	const auto id = registerCallback(std::move(callback));
	dora_wa_start_string_call(operation, id, path.c_str());
}

void buildWaAsyncEmscripten(const std::string& path, const std::function<void(String)>& callback) {
	startStringCall("build", path, callback);
}

void formatWaAsyncEmscripten(const std::string& path, const std::function<void(String)>& callback) {
	startStringCall("format", path, callback);
}

NS_DORA_END
