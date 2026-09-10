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

#include "Const/Header.h"
#include "Http/HttpServer.h"
#include "Event/Listener.h"

#include <emscripten/fetch.h>

#include <algorithm>
#include <atomic>
#include <cstdio>
#include <cstring>
#include <memory>
#include <mutex>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

#include "SDL.h"

NS_DORA_BEGIN

class WebSocketServer { };

HttpServer::Response::Response(Response&& res)
	: content(std::move(res.content))
	, contentType(std::move(res.contentType))
	, status(res.status) { }

void HttpServer::Response::operator=(Response&& res) {
	content = std::move(res.content);
	contentType = std::move(res.contentType);
	status = res.status;
}

HttpServer::HttpServer()
	: _authRequired(false)
	, _authTokenHasExpiry(false)
	, _staticCacheControl("no-cache") { }

HttpServer::~HttpServer() { stop(); }

int HttpServer::getWSConnectionCount() const noexcept { return 0; }
std::string HttpServer::getLocalIP() const noexcept { return {}; }

void HttpServer::setWWWPath(String var) { _wwwPath = var.toString(); }
const std::string& HttpServer::getWWWPath() const noexcept { return _wwwPath; }

bool HttpServer::setStaticCacheControl(String cacheControl) {
	_staticCacheControl = cacheControl.toString();
	return true;
}

bool HttpServer::addStaticCacheControl(String, String) { return false; }
void HttpServer::clearStaticCacheControls() { _staticCacheControlRules.clear(); }

void HttpServer::setAuthToken(String var) { _authToken = var.toString(); }
const std::string& HttpServer::getAuthToken() const noexcept { return _authToken; }
void HttpServer::setAuthRequired(bool var) { _authRequired = var; }
bool HttpServer::isAuthRequired() const noexcept { return _authRequired; }

void HttpServer::post(String pattern, const ServiceHandler& handler) {
	_posts.push_back({pattern.toString(), handler});
}

void HttpServer::get(String pattern, const ServiceHandler& handler) {
	_gets.push_back({pattern.toString(), handler});
}

void HttpServer::postSchedule(String pattern, const PostScheduledHandler& handler) {
	_postScheduled.push_back({pattern.toString(), handler});
}

void HttpServer::upload(String pattern, const FileAcceptHandler& acceptHandler, const FileDoneHandler& doneHandler) {
	_files.push_back({pattern.toString(), acceptHandler, doneHandler});
}

// A browser page cannot bind an inbound TCP/HTTP server. Web content is served
// by the hosting web server; HttpClient below is the browser-facing API.
bool HttpServer::start(int) { return false; }
bool HttpServer::startWS(int) { return false; }

void HttpServer::stop() {
	_stopping.store(true, std::memory_order_release);
	_generation.fetch_add(1, std::memory_order_acq_rel);
	_posts.clear();
	_gets.clear();
	_postScheduled.clear();
	_files.clear();
	_webSocketListener = nullptr;
	_webSocketServer = nullptr;
}

const char* HttpServer::getVersion() { return "emscripten-fetch"; }

namespace {

constexpr uint64_t WebResponseLimit = 64ull * 1024 * 1024;
constexpr uint64_t WebDownloadLimit = 512ull * 1024 * 1024;

enum class FetchKind {
	Response,
	Download,
};

struct FetchRequestState {
	HttpClient::RequestId id = 0;
	HttpClient* owner = nullptr;
	FetchKind kind = FetchKind::Response;
	bool post = false;
	std::atomic_bool cancelling{false};
	std::atomic_bool finished{false};
	emscripten_fetch_t* fetch = nullptr;
	std::shared_ptr<HttpClient::ContentPartHandler> partCallback;
	std::shared_ptr<HttpClient::ContentHandler> callback;
	std::shared_ptr<std::function<bool(bool, uint64_t, uint64_t)>> progress;
	std::string requestBody;
	std::string filePath;
	std::vector<std::string> headerNames;
	std::vector<std::string> headerValues;
	std::vector<const char*> headerPointers;
};

std::mutex s_fetchMutex;
std::unordered_map<HttpClient::RequestId, std::shared_ptr<FetchRequestState>> s_fetchRequests;
std::atomic_uint64_t s_fetchRequestId{0};

static std::shared_ptr<FetchRequestState> register_fetch(HttpClient* client, FetchKind kind) {
	if (!client || client->isStopped()) return nullptr;
	std::lock_guard<std::mutex> lock(s_fetchMutex);
	if (client->isStopped()) return nullptr;
	auto request = std::make_shared<FetchRequestState>();
	request->id = s_fetchRequestId.fetch_add(1, std::memory_order_relaxed) + 1;
	request->owner = client;
	request->kind = kind;
	s_fetchRequests.emplace(request->id, request);
	return request;
}

static std::shared_ptr<FetchRequestState> get_fetch(HttpClient::RequestId id) {
	std::lock_guard<std::mutex> lock(s_fetchMutex);
	if (auto it = s_fetchRequests.find(id); it != s_fetchRequests.end()) return it->second;
	return nullptr;
}

static std::vector<std::shared_ptr<FetchRequestState>> snapshot_fetches(const HttpClient* owner) {
	std::vector<std::shared_ptr<FetchRequestState>> result;
	std::lock_guard<std::mutex> lock(s_fetchMutex);
	result.reserve(s_fetchRequests.size());
	for (const auto& [_, request] : s_fetchRequests) {
		if (request->owner == owner) result.push_back(request);
	}
	return result;
}

static void unregister_fetch(const std::shared_ptr<FetchRequestState>& request) {
	if (!request) return;
	std::lock_guard<std::mutex> lock(s_fetchMutex);
	s_fetchRequests.erase(request->id);
}

static unsigned int timeout_ms(float timeout) {
	if (!(timeout > 0.0f)) return 0;
	return std::max(1u, static_cast<unsigned int>(timeout * 1000.0f));
}

static void add_request_header(FetchRequestState& request, Slice header) {
	const auto value = header.toView();
	const auto colon = value.find(':');
	if (colon == std::string_view::npos) return;
	const auto name = value.substr(0, colon);
	const auto headerValue = value.substr(colon + 1);
	const auto first = headerValue.find_first_not_of(" \t");
	request.headerNames.emplace_back(name);
	request.headerValues.emplace_back(first == std::string_view::npos ? std::string_view{} : headerValue.substr(first));
}

static void finalize_fetch(emscripten_fetch_t* fetch, bool success) {
	if (!fetch) return;
	auto* raw = r_cast<FetchRequestState*>(fetch->userData);
	if (!raw) {
		emscripten_fetch_close(fetch);
		return;
	}
	auto request = get_fetch(raw->id);
	if (!request || request->finished.exchange(true, std::memory_order_acq_rel)) {
		emscripten_fetch_close(fetch);
		return;
	}
	request->fetch = nullptr;

	const auto limit = request->kind == FetchKind::Download ? WebDownloadLimit : WebResponseLimit;
	const bool withinLimit = fetch->numBytes <= limit && (!fetch->totalBytes || fetch->totalBytes <= limit);
	const bool httpSuccess = success && withinLimit && fetch->status >= 200 && fetch->status < 400 && !request->cancelling.load(std::memory_order_relaxed);
	if (request->kind == FetchKind::Download) {
		bool written = false;
		if (httpSuccess && fetch->data) {
			if (auto* output = SDL_RWFromFile(request->filePath.c_str(), "wb+")) {
				written = SDL_RWwrite(output, fetch->data, 1, fetch->numBytes) == fetch->numBytes;
				SDL_RWclose(output);
			}
		}
		if (!httpSuccess || !written) {
			std::remove(request->filePath.c_str());
			if (request->progress) (*request->progress)(true, 0, 0);
		} else if (request->progress) {
			const auto total = fetch->totalBytes ? fetch->totalBytes : fetch->numBytes;
			(*request->progress)(false, fetch->numBytes, total);
		}
	} else if (!httpSuccess) {
		if (request->callback) (*request->callback)(std::nullopt);
	} else if (request->callback) {
		if (request->partCallback && *request->partCallback) {
			(*request->callback)(""_slice);
		} else {
			std::string body(fetch->data ? fetch->data : "", fetch->numBytes);
			(*request->callback)(body);
		}
	}

	unregister_fetch(request);
	emscripten_fetch_close(fetch);
}

static void on_fetch_success(emscripten_fetch_t* fetch) { finalize_fetch(fetch, true); }
static void on_fetch_error(emscripten_fetch_t* fetch) { finalize_fetch(fetch, false); }

static void on_fetch_progress(emscripten_fetch_t* fetch) {
	if (!fetch || !fetch->userData) return;
	auto* raw = r_cast<FetchRequestState*>(fetch->userData);
	auto request = get_fetch(raw->id);
	if (!request || request->finished.load(std::memory_order_relaxed)) return;
	const auto current = static_cast<uint64_t>(fetch->dataOffset) + fetch->numBytes;
	const auto limit = request->kind == FetchKind::Download ? WebDownloadLimit : WebResponseLimit;
	if (current > limit || (fetch->totalBytes && fetch->totalBytes > limit)) {
		request->cancelling.store(true, std::memory_order_relaxed);
		finalize_fetch(fetch, false);
		return;
	}
	if (request->kind == FetchKind::Response && request->partCallback && *request->partCallback && fetch->data && fetch->numBytes > 0) {
		std::string part(fetch->data, fetch->numBytes);
		if ((*request->partCallback)(part)) {
			request->cancelling.store(true, std::memory_order_relaxed);
			finalize_fetch(fetch, false);
		}
	} else if (request->kind == FetchKind::Download && request->progress) {
		if ((*request->progress)(false, current, fetch->totalBytes)) {
			request->cancelling.store(true, std::memory_order_relaxed);
			finalize_fetch(fetch, false);
		}
	}
}

static HttpClient::RequestId start_fetch(
	HttpClient* client,
	FetchKind kind,
	String url,
	std::span<Slice> headers,
	String body,
	bool post,
	float timeout,
	const HttpClient::ContentPartHandler& partCallback,
	const HttpClient::ContentHandler& callback,
	String filePath,
	const std::function<bool(bool, uint64_t, uint64_t)>& progress) {
	auto request = register_fetch(client, kind);
	if (!request) {
		if (kind == FetchKind::Download) progress(true, 0, 0); else callback(std::nullopt);
		return 0;
	}
	request->partCallback = std::make_shared<HttpClient::ContentPartHandler>(partCallback);
	request->callback = std::make_shared<HttpClient::ContentHandler>(callback);
	request->progress = std::make_shared<std::function<bool(bool, uint64_t, uint64_t)>>(progress);
	request->post = post;
	request->requestBody = body.toString();
	request->filePath = filePath.toString();
	for (auto header : headers) add_request_header(*request, header);
	if (request->post) {
		request->headerNames.emplace_back("Content-Type");
		request->headerValues.emplace_back("application/json");
	}
	request->headerPointers.reserve(request->headerNames.size() * 2 + 1);
	for (size_t i = 0; i < request->headerNames.size(); ++i) {
		request->headerPointers.push_back(request->headerNames[i].c_str());
		request->headerPointers.push_back(request->headerValues[i].c_str());
	}
	request->headerPointers.push_back(nullptr);

	emscripten_fetch_attr_t attr;
	emscripten_fetch_attr_init(&attr);
	strncpy(attr.requestMethod, request->post ? "POST" : "GET", sizeof(attr.requestMethod) - 1);
	attr.attributes = EMSCRIPTEN_FETCH_LOAD_TO_MEMORY | EMSCRIPTEN_FETCH_REPLACE;
	if (request->partCallback && *request->partCallback) {
		attr.attributes |= EMSCRIPTEN_FETCH_STREAM_DATA;
	}
	attr.timeoutMSecs = timeout_ms(timeout);
	attr.userData = request.get();
	attr.onsuccess = on_fetch_success;
	attr.onerror = on_fetch_error;
	attr.onprogress = on_fetch_progress;
	attr.requestHeaders = request->headerPointers.data();
	if (request->post) {
		attr.requestData = request->requestBody.data();
		attr.requestDataSize = request->requestBody.size();
	}
	const auto urlString = url.toString();
	request->fetch = emscripten_fetch(&attr, urlString.c_str());
	if (!request->fetch) {
		unregister_fetch(request);
		if (kind == FetchKind::Download) progress(true, 0, 0); else callback(std::nullopt);
		return 0;
	}
	return request->id;
}

} // namespace

HttpClient::HttpClient()
	: _stopped(false) { }

HttpClient::~HttpClient() { stop(); }

bool HttpClient::isStopped() const noexcept {
	return _stopped.load(std::memory_order_relaxed);
}

void HttpClient::stop() {
	_stopped.store(true, std::memory_order_relaxed);
	for (const auto& request : snapshot_fetches(this)) {
		if (!request) continue;
		request->cancelling.store(true, std::memory_order_relaxed);
		if (request->fetch) finalize_fetch(request->fetch, false);
	}
}

bool HttpClient::cancel(RequestId requestId) {
	auto request = get_fetch(requestId);
	if (!request || request->owner != this || request->finished.load(std::memory_order_relaxed)) return false;
	request->cancelling.store(true, std::memory_order_relaxed);
	if (request->fetch) finalize_fetch(request->fetch, false);
	return true;
}

bool HttpClient::isRequestActive(RequestId requestId) const {
	auto request = get_fetch(requestId);
	return request && request->owner == this && !request->finished.load(std::memory_order_relaxed);
}

HttpClient::RequestId HttpClient::postAsync(String url, std::span<Slice> headers, String json, float timeout,
	const ContentPartHandler& partCallback, const ContentHandler& callback) {
	return start_fetch(this, FetchKind::Response, url, headers, json, true, timeout, partCallback, callback, {}, {});
}

HttpClient::RequestId HttpClient::postAsync(String url, String json, float timeout, const ContentHandler& callback) {
	return postAsync(url, std::span<Slice>{}, json, timeout, nullptr, callback);
}

HttpClient::RequestId HttpClient::postAsync(String url, const std::vector<std::string>& headers,
	String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback) {
	std::vector<Slice> slices;
	slices.reserve(headers.size());
	for (const auto& header : headers) slices.emplace_back(header);
	return postAsync(url, std::span<Slice>(slices), json, timeout, partCallback, callback);
}

HttpClient::RequestId HttpClient::postAsync(String url, const std::vector<std::string>& headers,
	String json, float timeout, const ContentHandler& callback) {
	return postAsync(url, headers, json, timeout, nullptr, callback);
}

HttpClient::RequestId HttpClient::postAsync(String url, Slice headers[], int count, String json,
	float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback) {
	return postAsync(url, std::span<Slice>(headers, static_cast<size_t>(count)), json, timeout, partCallback, callback);
}

HttpClient::RequestId HttpClient::postAsync(String url, Slice headers[], int count, String json,
	float timeout, const ContentHandler& callback) {
	return postAsync(url, std::span<Slice>(headers, static_cast<size_t>(count)), json, timeout, nullptr, callback);
}

HttpClient::RequestId HttpClient::getAsync(String url, float timeout, const ContentHandler& callback) {
	return start_fetch(this, FetchKind::Response, url, {}, {}, false, timeout, nullptr, callback, {}, {});
}

HttpClient::RequestId HttpClient::downloadAsync(String url, String filePath, float timeout,
	const std::function<bool(bool, uint64_t, uint64_t)>& progress) {
	return start_fetch(this, FetchKind::Download, url, {}, {}, false, timeout, nullptr, {}, filePath, progress);
}

NS_DORA_END
