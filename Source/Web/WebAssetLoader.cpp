/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
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

#include "Web/WebAssetLoader.h"

#include "Web/WebTaskQueue.h"

#include <cstdint>
#include <limits>
#include <unordered_map>
#include <utility>

#include <emscripten/emscripten.h>

namespace {

struct AssetRequest {
	uint64_t generation;
	Dora::Web::AssetFetchCallback callback;
};

std::unordered_map<int, AssetRequest>& requests() {
	static auto* value = new std::unordered_map<int, AssetRequest>();
	return *value;
}

uint64_t& generation() {
	static auto* value = new uint64_t(1);
	return *value;
}

int nextRequestId() {
	static auto* value = new uint32_t(0);
	int requestId;
	do {
		*value = *value == static_cast<uint32_t>(std::numeric_limits<int>::max()) ? 1 : *value + 1;
		requestId = static_cast<int>(*value);
	} while (requests().contains(requestId));
	return requestId;
}

EM_JS(void, requestWebAsset, (int requestId, const char* path), {
	const assetPath = UTF8ToString(path);
	const complete = (success, message) => {
		Module.ccall("dora_web_asset_complete", null,
			["number", "number", "string"], [requestId, success ? 1 : 0, message || ""]);
	};
	Promise.resolve().then(() => {
		if (!globalThis.DoraWebLoader || typeof globalThis.DoraWebLoader.fetchPath !== "function") {
			throw new Error("Dora Web asset loader is unavailable");
		}
		return globalThis.DoraWebLoader.fetchPath(Module, assetPath);
	}).then(() => complete(true, ""), (error) => {
		complete(false, String(error && error.message || error));
	});
});

} // namespace

extern "C" void dora_web_asset_complete(int requestId, int success, const char* message) {
	auto& pending = requests();
	auto it = pending.find(requestId);
	if (it == pending.end()) return;
	auto request = std::move(it->second);
	pending.erase(it);
	auto error = std::string(message ? message : "");
	Dora::Web::postTask([request = std::move(request), success = success != 0, error = std::move(error)]() mutable {
		if (request.generation == generation()) {
			request.callback(success, std::move(error));
		}
	});
}

namespace Dora::Web {

void fetchAsset(std::string path, AssetFetchCallback callback) {
	const int requestId = nextRequestId();
	requests().emplace(requestId, AssetRequest{generation(), std::move(callback)});
	requestWebAsset(requestId, path.c_str());
}

void cancelAssetFetches() {
	++generation();
	requests().clear();
}

} // namespace Dora::Web
