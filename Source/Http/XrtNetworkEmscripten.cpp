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

#include "Http/XrtNetwork.h"

#include <emscripten.h>
#include <emscripten/fetch.h>

#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

namespace {

constexpr int XRT_NET_OK = 0;
constexpr int XRT_NET_ERROR = 1;
constexpr int XRT_NET_TIMEOUT = 3;

struct FetchState {
	DoraXrtHttpResponse* response = nullptr;
	bool done = false;
};

char* copy_string(const char* value, size_t length) {
	if (!value) value = "";
	auto* result = static_cast<char*>(std::malloc(length + 1));
	if (!result) return nullptr;
	std::memcpy(result, value, length);
	result[length] = '\0';
	return result;
}

void copy_response_headers(emscripten_fetch_t* fetch, DoraXrtHttpResponse* response) {
	const auto length = emscripten_fetch_get_response_headers_length(fetch);
	if (length == 0) return;
	std::string raw(length + 1, '\0');
	emscripten_fetch_get_response_headers(fetch, raw.data(), raw.size());
	raw.resize(length);
	char** unpacked = emscripten_fetch_unpack_response_headers(raw.c_str());
	if (!unpacked) return;

	size_t count = 0;
	while (unpacked[count * 2] && unpacked[count * 2 + 1]) ++count;
	if (count > 0) {
		response->headers = static_cast<DoraXrtHttpHeader*>(std::calloc(count, sizeof(DoraXrtHttpHeader)));
		if (response->headers) {
			response->headerCount = count;
			for (size_t i = 0; i < count; ++i) {
				const auto name = unpacked[i * 2];
				const auto value = unpacked[i * 2 + 1];
				response->headers[i].name = copy_string(name, std::strlen(name));
				response->headers[i].value = copy_string(value, std::strlen(value));
			}
		}
	}
	emscripten_fetch_free_unpacked_response_headers(unpacked);
}

void copy_response(emscripten_fetch_t* fetch, DoraXrtHttpResponse* response) {
	response->statusCode = fetch->status;
	response->statusLine = copy_string(fetch->statusText, std::strlen(fetch->statusText));
	if (fetch->data && fetch->numBytes > 0) {
		response->body = static_cast<char*>(std::malloc(fetch->numBytes));
		if (response->body) {
			std::memcpy(response->body, fetch->data, fetch->numBytes);
			response->bodyLen = fetch->numBytes;
		}
	}
	copy_response_headers(fetch, response);
}

void on_fetch_success(emscripten_fetch_t* fetch) {
	auto* state = static_cast<FetchState*>(fetch->userData);
	if (!state || !state->response) return;
	state->response->netStatus = XRT_NET_OK;
	copy_response(fetch, state->response);
	state->done = true;
}

void on_fetch_error(emscripten_fetch_t* fetch) {
	auto* state = static_cast<FetchState*>(fetch->userData);
	if (state && state->response) {
		auto* response = state->response;
		// Fetch reports HTTP errors through onerror, but the response is still
		// useful to callers (for example Lua dora.https needs status and body).
		// A zero status means that no HTTP response was received.
		response->netStatus = fetch->status == 0
			? (fetch->statusText[0] != '\0' ? XRT_NET_TIMEOUT : XRT_NET_ERROR)
			: XRT_NET_OK;
		copy_response(fetch, response);
	}
	if (state) state->done = true;
}

} // namespace

extern "C" int DoraXrtHttpExecute(
	const char* method,
	const char* url,
	const char* const* headerNames,
	const char* const* headerValues,
	size_t headerCount,
	const void* body,
	size_t bodyLen,
	unsigned int timeoutMs,
	int,
	DoraXrtHttpShouldCancel,
	void*,
	DoraXrtHttpResponse* response) {
	if (!method || !url || !response) return XRT_NET_ERROR;
	std::memset(response, 0, sizeof(*response));
	FetchState state{response, false};

	std::vector<const char*> headers;
	headers.reserve(headerCount * 2 + 1);
	for (size_t i = 0; i < headerCount; ++i) {
		headers.push_back(headerNames && headerNames[i] ? headerNames[i] : "");
		headers.push_back(headerValues && headerValues[i] ? headerValues[i] : "");
	}
	headers.push_back(nullptr);

	emscripten_fetch_attr_t attr;
	emscripten_fetch_attr_init(&attr);
	std::strncpy(attr.requestMethod, method, sizeof(attr.requestMethod) - 1);
	// The Lua-facing dora.https API is synchronous. Asyncify lets this legacy
	// API yield the browser event loop while fetch remains asynchronous, which
	// avoids forbidden synchronous XHR on the browser main thread.
	attr.attributes = EMSCRIPTEN_FETCH_LOAD_TO_MEMORY | EMSCRIPTEN_FETCH_REPLACE;
	attr.timeoutMSecs = timeoutMs;
	attr.userData = &state;
	attr.onsuccess = on_fetch_success;
	attr.onerror = on_fetch_error;
	attr.requestHeaders = headers.data();
	if (body && bodyLen > 0) {
		attr.requestData = static_cast<const char*>(body);
		attr.requestDataSize = bodyLen;
	}
	auto* fetch = emscripten_fetch(&attr, url);
	if (!fetch) {
		response->netStatus = XRT_NET_ERROR;
		return XRT_NET_ERROR;
	}
	while (!state.done) {
		emscripten_sleep(1);
	}
	const auto status = response->netStatus;
	emscripten_fetch_close(fetch);
	return status;
}

extern "C" int DoraXrtHttpExecuteStream(
	const char*, const char*, const char* const*, const char* const*, size_t,
	const void*, size_t, unsigned int, int, DoraXrtHttpShouldCancel, void*,
	DoraXrtHttpStreamHandler, void*, int*) {
	return XRT_NET_ERROR;
}

extern "C" void DoraXrtHttpResponseFree(DoraXrtHttpResponse* response) {
	if (!response) return;
	std::free(response->body);
	for (size_t i = 0; i < response->headerCount; ++i) {
		std::free(response->headers[i].name);
		std::free(response->headers[i].value);
	}
	std::free(response->headers);
	std::free(response->statusLine);
	std::memset(response, 0, sizeof(*response));
}

extern "C" const char* DoraXrtHttpStatusName(int status) {
	switch (status) {
		case XRT_NET_OK: return "ok";
		case XRT_NET_TIMEOUT: return "request timed out";
		default: return "network error";
	}
}
