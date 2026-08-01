/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Http/HttpServer.h"

#include "Http/XrtHttpClient.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Common/Async.h"
#include "Event/Event.h"
#include "Event/Listener.h"
#include "Support/Dictionary.h"
#include "Support/Value.h"

#define XRT_NO_SUBPROCESS
#define XRT_NO_LOGGER
#define XRT_NO_FILE_ASYNC
#define XRT_NO_COROUTINE
#define XRT_NO_XID
#define XRT_NO_BUFFER
#define XRT_NO_ARRAY
#define XRT_NO_BSMN
#define XRT_NO_MEMUNIT
#define XRT_NO_MEMPOOL_FS
#define XRT_NO_STACK
#define XRT_NO_AVLTREE
#define XRT_NO_MEMPOOL
#define XRT_NO_DICT
#define XRT_NO_LIST
#define XRT_NO_VALUE
#define XRT_NO_JSON
#define XRT_NO_XSON
#define XRT_NO_TEMPLATE
#define XRT_NO_REGEX
#define i8 xrt_i8
extern "C" {
#include "xrt/xrt.h"
}
#undef i8

#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"

#include "yuescript/parser.hpp"

#if BX_PLATFORM_LINUX
#include <limits.h>
#include <unistd.h>

#include "ghc/fs_fwd.hpp"
namespace fs = ghc::filesystem;
#elif BX_PLATFORM_WINDOWS
#include "ghc/fs_fwd.hpp"
namespace fs = ghc::filesystem;
#else
#include <filesystem>
namespace fs = std::filesystem;
#endif // BX_PLATFORM_LINUX

#include <algorithm>
#include <atomic>
#include <charconv>
#include <chrono>
#include <condition_variable>
#include <cstdlib>
#include <memory>
#include <mutex>
#include <optional>
#include <set>
#include <string_view>
#include <unordered_map>
#include <vector>

#include "SDL.h"

#if BX_PLATFORM_WINDOWS
static std::string get_local_ip() {
	std::string localIP;

	char hostname[255] = {0};
	gethostname(hostname, sizeof(hostname));
	hostent* host = gethostbyname(hostname);
	if (host == nullptr) return localIP;

	short i = 0;
	while (host->h_addr_list[i]) {
		in_addr addr;
		memcpy(&addr, host->h_addr_list[i], sizeof(in_addr));
		Slice ip(inet_ntoa(addr));
		if (ip.left(8) == "192.168."_slice) { // C
			localIP = ip.toString();
			break;
		} else if (ip.left(3) == "10."_slice) { // A
			localIP = ip.toString();
		}
		i++;
	}
	return localIP;
}
#else // BX_PLATFORM_WINDOWS
#include <ifaddrs.h>

static std::string get_local_ip() {
	std::string localIP;
	ifaddrs* ifAddrStruct = nullptr;
	ifaddrs* ifa = nullptr;
	void* tmpAddrPtr = nullptr;

	getifaddrs(&ifAddrStruct);

	for (ifa = ifAddrStruct; ifa != nullptr; ifa = ifa->ifa_next) {
		if (!ifa->ifa_addr) {
			continue;
		}
		if (ifa->ifa_addr->sa_family == AF_INET) {
			tmpAddrPtr = &(r_cast<sockaddr_in*>(ifa->ifa_addr))->sin_addr;
			char addressBuffer[INET_ADDRSTRLEN];
			inet_ntop(AF_INET, tmpAddrPtr, addressBuffer, INET_ADDRSTRLEN);

			Slice ip(addressBuffer);
			if (ip.left(8) == "192.168."_slice) { // C
				localIP = ip.toString();
				break;
			} else if (ip.left(3) == "10."_slice) { // A
				localIP = ip.toString();
			}
		}
	}
	if (ifAddrStruct != nullptr) freeifaddrs(ifAddrStruct);
	return localIP;
}
#endif // BX_PLATFORM_WINDOWS

NS_DORA_BEGIN

static std::string get_query_param(const std::string& resource, const std::string& key) {
	auto qpos = resource.find('?');
	if (qpos == std::string::npos) {
		return std::string{};
	}
	auto query = resource.substr(qpos + 1);
	size_t start = 0;
	while (start < query.size()) {
		auto amp = query.find('&', start);
		if (amp == std::string::npos) {
			amp = query.size();
		}
		auto part = query.substr(start, amp - start);
		auto eq = part.find('=');
		if (eq != std::string::npos) {
			auto name = part.substr(0, eq);
			if (name == key) {
				return part.substr(eq + 1);
			}
		}
		start = amp + 1;
	}
	return std::string{};
}

static std::string sha256_hex(std::string_view data) {
	if (data.empty()) {
		return {};
	}
	char hash[65];
	return DoraXrtSha256Hex(data.data(), data.size(), hash) ? std::string(hash) : std::string{};
}

static std::string hmac_sha256_hex(std::string_view key, std::string_view data) {
	char hash[65];
	return DoraXrtHmacSha256Hex(key.data(), key.size(), data.data(), data.size(), hash) ? std::string(hash) : std::string{};
}

static std::string canonicalize_query(std::vector<std::pair<std::string, std::string>> params) {
	if (params.empty()) return {};
	std::sort(params.begin(), params.end(), [](const auto& a, const auto& b) {
		if (a.first == b.first) {
			return a.second < b.second;
		}
		return a.first < b.first;
	});
	std::string query;
	for (size_t i = 0; i < params.size(); ++i) {
		if (i > 0) query += '&';
		auto encode = [](const std::string& text) {
			std::string result(text.size() * 3 + 1, '\0');
			size_t length = 0;
			if (!xrtPercentEncodeTo(text.data(), text.size(), result.data(), result.size(), &length, false)) return std::string{};
			result.resize(length);
			return result;
		};
		query += encode(params[i].first);
		query += '=';
		query += encode(params[i].second);
	}
	return query;
}

static std::string canonicalize_path(const std::string& path, const std::vector<std::pair<std::string, std::string>>& params) {
	if (params.empty()) return path;
	std::vector<std::pair<std::string, std::string>> pairs;
	pairs.reserve(params.size());
	for (const auto& param : params) {
		pairs.emplace_back(param.first, param.second);
	}
	auto query = canonicalize_query(std::move(pairs));
	return query.empty() ? path : path + "?"s + query;
}

static std::vector<std::pair<std::string, std::string>> parse_query_pairs(const std::string& resource) {
	std::vector<std::pair<std::string, std::string>> params;
	auto qpos = resource.find('?');
	if (qpos == std::string::npos) return params;
	auto query = resource.substr(qpos + 1);
	size_t start = 0;
	while (start < query.size()) {
		auto amp = query.find('&', start);
		if (amp == std::string::npos) {
			amp = query.size();
		}
		auto part = query.substr(start, amp - start);
		auto eq = part.find('=');
		if (eq != std::string::npos) {
			auto decode = [](const std::string& text) {
				std::string result(text.size() + 1, '\0');
				size_t length = 0;
				if (!xrtPercentDecodeTo(text.data(), text.size(), result.data(), result.size(), &length, true)) return std::string{};
				result.resize(length);
				return result;
			};
			auto name = decode(part.substr(0, eq));
			auto value = decode(part.substr(eq + 1));
			params.emplace_back(std::move(name), std::move(value));
		}
		start = amp + 1;
	}
	return params;
}

static Dictionary* makeAppWSMessage(String type, std::string&& msg = std::string{}) {
	auto payload = Dictionary::create();
	payload->set("type"_slice, Value::alloc(type.toString()));
	payload->set("msg"_slice, Value::alloc(msg));
	return payload;
}

class WebSocketServer {
	struct Connection {
		explicit Connection(xwsconn* ws)
			: webSocket(ws) { }
		xwsconn* webSocket = nullptr;
		std::mutex lock;
	};
	using ConnectionPtr = std::shared_ptr<Connection>;
	using ConnectionMap = std::unordered_map<xwsconn*, ConnectionPtr>;

public:
	explicit WebSocketServer(HttpServer* owner)
		: _owner(owner) { }

	~WebSocketServer() {
		stop();
	}

	int getConnectionCount() const {
		std::lock_guard<std::mutex> guard(_connectionLock);
		return s_cast<int>(_connections.size());
	}

	bool init() {
		return true;
	}

	void send(const std::string& msg) {
		auto connections = snapshotConnections();
		for (const auto& connection : connections) {
			if (!connection) continue;
			std::lock_guard<std::mutex> guard(connection->lock);
			if (connection->webSocket && xrtWsConnIsOpen(connection->webSocket)) {
				if (xrtWsConnSendBinary(connection->webSocket, msg.data(), msg.size()) != XRT_NET_OK) {
					Error("failed to send message to websocket connection!");
				}
			}
		}
	}

	void sendLog(const std::string& log) {
		rapidjson::StringBuffer buf;
		rapidjson::Writer<rapidjson::StringBuffer> writer(buf);
		writer.StartObject();
		writer.Key("name");
		writer.String("Log");
		writer.Key("text");
		writer.String(log.c_str(), log.size());
		writer.EndObject();
		Event::send("AppWS"sv, makeAppWSMessage("Send"_slice, std::string{buf.GetString(), buf.GetLength()}));
	}

	bool start(int port) {
		_engine = r_cast<xnetengine*>(DoraXrtNetworkEngineCreate(1));
		if (!_engine) return false;
		xwsserverconfig config;
		xrtWsServerConfigInit(&config);
		xrtNetAddrInitAny(&config.tBindAddr, AF_INET, s_cast<uint16>(port));
		config.iRecvLimit = 16u * 1024u * 1024u;
		xwsserverevents events{};
		events.OnAuthorize = [](ptr owner, xwsserver*, xwsconn*, const char* target) {
			auto self = r_cast<WebSocketServer*>(owner);
			return !self->_owner || self->_owner->isWebSocketAuthorized(target ? target : "/"s);
		};
		events.OnOpen = [](ptr owner, xwsserver*, xwsconn* ws) {
			auto self = r_cast<WebSocketServer*>(owner);
			auto connection = std::make_shared<Connection>(ws);
			{
				std::lock_guard<std::mutex> guard(self->_connectionLock);
				self->_connections.emplace(ws, std::move(connection));
			}
			SharedApplication.invokeInLogic([]() {
				Event::send("AppWS"sv, makeAppWSMessage("Open"_slice));
			});
		};
		auto receive = [](ptr, xwsserver*, xwsconn*, const void* data, size_t length) {
			auto message = std::make_shared<std::string>(r_cast<const char*>(data), length);
			SharedApplication.invokeInLogic([message = std::move(message)]() {
				Event::send("AppWS"sv, makeAppWSMessage("Receive"_slice, std::move(*message)));
			});
		};
		events.OnBinary = receive;
		events.OnText = [](ptr owner, xwsserver* server, xwsconn* ws, const char* data, size_t length) {
			auto message = std::make_shared<std::string>(data, length);
			SharedApplication.invokeInLogic([message = std::move(message)]() {
				Event::send("AppWS"sv, makeAppWSMessage("Receive"_slice, std::move(*message)));
			});
		};
		events.OnClose = [](ptr owner, xwsserver*, xwsconn* ws, xnet_result) {
			auto self = r_cast<WebSocketServer*>(owner);
			ConnectionPtr connection;
			{
				std::lock_guard<std::mutex> guard(self->_connectionLock);
				auto it = self->_connections.find(ws);
				if (it != self->_connections.end()) {
					connection = std::move(it->second);
					self->_connections.erase(it);
				}
			}
			if (connection) {
				std::lock_guard<std::mutex> guard(connection->lock);
				connection->webSocket = nullptr;
			}
			SharedApplication.invokeInLogic([]() {
				Event::send("AppWS"sv, makeAppWSMessage("Close"_slice));
			});
		};
		events.OnError = [](ptr, xwsserver*, xwsconn*, int error) {
			Error("websocket server error: {}", error);
		};
		_server = xrtWsServerCreate(_engine, &config, &events, this);
		if (!_server || xrtWsServerStart(_server) != XRT_NET_OK) {
			if (_server) xrtWsServerDestroy(_server);
			_server = nullptr;
			DoraXrtNetworkEngineDestroy(_engine);
			_engine = nullptr;
			Error("failed to bind websocket server port {}!", port);
			return false;
		}
		LogHandler += std::make_pair(this, &WebSocketServer::sendLog);
		return true;
	}

	void stop() {
		if (_server) {
			auto connections = snapshotConnections();
			for (const auto& connection : connections) {
				if (!connection) continue;
				std::lock_guard<std::mutex> guard(connection->lock);
				if (connection->webSocket && xrtWsConnIsOpen(connection->webSocket)) {
					xrtWsConnClose(connection->webSocket, XWS_CLOSE_GOING_AWAY, "shutting down");
				}
			}
			xrtWsServerDestroy(_server);
			_server = nullptr;
		}
		if (_engine) {
			DoraXrtNetworkEngineDestroy(_engine);
			_engine = nullptr;
		}
		LogHandler -= std::make_pair(this, &WebSocketServer::sendLog);
	}

private:
	std::vector<ConnectionPtr> snapshotConnections() const {
		std::vector<ConnectionPtr> connections;
		std::lock_guard<std::mutex> guard(_connectionLock);
		connections.reserve(_connections.size());
		for (const auto& [_, connection] : _connections) {
			connections.push_back(connection);
		}
		return connections;
	}

private:
	HttpServer* _owner;
	xnetengine* _engine = nullptr;
	xwsserver* _server = nullptr;
	ConnectionMap _connections;
	mutable std::mutex _connectionLock;
};

HttpServer::Response::Response(HttpServer::Response&& res)
	: content(std::move(res.content))
	, contentType(std::move(res.contentType))
	, status(res.status) { }

void HttpServer::Response::operator=(HttpServer::Response&& res) {
	content = std::move(res.content);
	contentType = std::move(res.contentType);
	status = res.status;
}

static std::optional<Slice> find_header(const HttpServer::Request& req, String name) {
	auto expected = name.toString();
	for (size_t i = 0; i + 1 < req.headers.size(); i += 2) {
		auto actual = req.headers[i].toString();
		if (actual.size() == expected.size() && std::equal(actual.begin(), actual.end(), expected.begin(), [](char a, char b) {
			return std::tolower(s_cast<unsigned char>(a)) == std::tolower(s_cast<unsigned char>(b));
		})) return req.headers[i + 1];
	}
	return std::nullopt;
}

static bool has_valid_auth(const HttpServer::Request& req, const std::string& token) {
	if (auto value = find_header(req, "X-Dora-Auth"_slice); value && *value == token) {
		return true;
	}
	if (auto value = find_header(req, "Authorization"_slice)) {
		const auto auth = value->toString();
		if (auth == token) {
			return true;
		}
		const std::string bearer = "Bearer "s;
		if (auth.rfind(bearer, 0) == 0 && auth.substr(bearer.size()) == token) {
			return true;
		}
		const std::string dora = "Dora "s;
		if (auth.rfind(dora, 0) == 0 && auth.substr(dora.size()) == token) {
			return true;
		}
	}
	for (size_t i = 0; i + 1 < req.params.size(); i += 2) {
		if (req.params[i] == "auth"_slice && req.params[i + 1] == token) {
			return true;
		}
	}
	return false;
}

static void set_response(xhttpdresponse* response, int status, const std::string& content, const std::string& contentType) {
	xrtHttpdResponseSetStatus(response, s_cast<uint32>(status), nullptr);
	if (!contentType.empty()) xrtHttpdResponseSetHeader(response, "Content-Type", contentType.c_str());
	xrtHttpdResponseSetBodyCopy(response, content.data(), content.size(), nullptr);
}

static void set_unauthorized(xhttpdresponse* response) {
	set_response(response, 401, R"({"success":false,"message":"unauthorized"})"s, "application/json"s);
}

static void set_service_unavailable(xhttpdresponse* response) {
	set_response(response, 503, R"({"success":false,"message":"server shutting down"})"s, "application/json"s);
}

template <class T>
class PendingLogicResult {
public:
	bool isCancelled() const noexcept {
		return _cancelled.load(std::memory_order_acquire);
	}

	void complete(T result) {
		if (isCancelled()) return;
		_result.emplace(std::move(result));
		_ready.post();
	}

	std::optional<T> wait(const std::atomic_bool& stopping, const std::atomic_uint64_t& generation, uint64_t requestGeneration) {
		while (!_ready.wait(50)) {
			if (stopping.load(std::memory_order_acquire)
				|| generation.load(std::memory_order_acquire) != requestGeneration
				|| !SharedApplication.isLogicRunning()) {
				_cancelled.store(true, std::memory_order_release);
				return std::nullopt;
			}
		}
		return std::move(_result);
	}

private:
	std::atomic_bool _cancelled{false};
	bx::Semaphore _ready;
	std::optional<T> _result;
};

HttpServer::HttpServer()
	: _authRequired(false)
	, _authTokenHasExpiry(false)
	, _staticCacheControl("no-cache") { }

HttpServer::~HttpServer() {
	stop();
}

int HttpServer::getWSConnectionCount() const noexcept {
	if (_webSocketServer) {
		return _webSocketServer->getConnectionCount();
	}
	return 0;
}

std::string HttpServer::getLocalIP() const noexcept {
	return get_local_ip();
}

void HttpServer::setWWWPath(String var) {
	_wwwPath = var.toString();
}

const std::string& HttpServer::getWWWPath() const noexcept {
	return _wwwPath;
}

static bool isValidHeaderValue(String value) {
	const auto text = value.toString();
	return text.find('\r') == std::string::npos && text.find('\n') == std::string::npos;
}

bool HttpServer::setStaticCacheControl(String cacheControl) {
	if (!isValidHeaderValue(cacheControl)) return false;
	std::lock_guard<std::mutex> lock(_staticCacheControlMutex);
	_staticCacheControl = cacheControl.toString();
	return true;
}

bool HttpServer::addStaticCacheControl(String pattern, String cacheControl) {
	if (!isValidHeaderValue(cacheControl)) return false;
	try {
		StaticCacheControlRule rule{
			std::regex(pattern.toString(), std::regex::ECMAScript),
			cacheControl.toString(),
		};
		std::lock_guard<std::mutex> lock(_staticCacheControlMutex);
		_staticCacheControlRules.push_back(std::move(rule));
		return true;
	} catch (const std::regex_error&) {
		return false;
	}
}

void HttpServer::clearStaticCacheControls() {
	std::lock_guard<std::mutex> lock(_staticCacheControlMutex);
	_staticCacheControlRules.clear();
}

std::string HttpServer::getStaticCacheControl(String requestPath) {
	const auto path = requestPath.toString();
	std::lock_guard<std::mutex> lock(_staticCacheControlMutex);
	for (const auto& rule : _staticCacheControlRules) {
		if (std::regex_match(path, rule.pattern)) {
			return rule.cacheControl;
		}
	}
	return _staticCacheControl;
}

void HttpServer::setAuthToken(String var) {
	_authToken = var.toString();
	_authSessionId.clear();
	_authSessionSecret.clear();
	{
		std::lock_guard<std::mutex> lock(_authNonceMutex);
		_authNonces.clear();
	}
	if (_authToken.empty()) {
		_authTokenHasExpiry = false;
	} else {
		auto pos = _authToken.find(':');
		if (pos != std::string::npos) {
			_authSessionId = _authToken.substr(0, pos);
			_authSessionSecret = _authToken.substr(pos + 1);
		} else {
			_authSessionSecret = _authToken;
		}
		_authTokenHasExpiry = true;
		_authTokenExpiry = std::chrono::steady_clock::now() + std::chrono::seconds(AuthTokenTTLSeconds);
	}
}

const std::string& HttpServer::getAuthToken() const noexcept {
	return _authToken;
}

void HttpServer::setAuthRequired(bool var) {
	_authRequired = var;
	if (!_authRequired) {
		_authTokenHasExpiry = false;
	} else if (!_authToken.empty()) {
		_authTokenHasExpiry = true;
		_authTokenExpiry = std::chrono::steady_clock::now() + std::chrono::seconds(AuthTokenTTLSeconds);
	}
}

bool HttpServer::isAuthRequired() const noexcept {
	return _authRequired;
}

bool HttpServer::isAuthorized(const Request& req) {
	if (!_authRequired) {
		return true;
	}
	if (_authToken.empty()) {
		return false;
	}
	if (_authTokenHasExpiry && std::chrono::steady_clock::now() > _authTokenExpiry) {
		_authToken.clear();
		_authSessionId.clear();
		_authSessionSecret.clear();
		_authTokenHasExpiry = false;
		return false;
	}
	if (!_authSessionId.empty()) {
		auto sessionHeader = find_header(req, "X-Dora-Session"_slice);
		auto timestampHeader = find_header(req, "X-Dora-Timestamp"_slice);
		auto nonceHeader = find_header(req, "X-Dora-Nonce"_slice);
		auto signatureHeader = find_header(req, "X-Dora-Signature"_slice);
		if (!sessionHeader || !timestampHeader || !nonceHeader || !signatureHeader) {
			return false;
		}
		auto sessionId = sessionHeader->toString();
		if (sessionId != _authSessionId) {
			return false;
		}
		long long timestamp = 0;
		try {
			timestamp = std::stoll(timestampHeader->toString());
		} catch (...) {
			return false;
		}
		auto now = std::chrono::system_clock::now();
		auto nowSeconds = std::chrono::duration_cast<std::chrono::seconds>(now.time_since_epoch()).count();
		if (std::llabs(nowSeconds - timestamp) > AuthSignatureTTLSeconds) {
			return false;
		}
		auto nonce = nonceHeader->toString();
		std::vector<std::pair<std::string, std::string>> params;
		for (size_t i = 0; i + 1 < req.params.size(); i += 2) params.emplace_back(req.params[i].toString(), req.params[i + 1].toString());
		auto path = canonicalize_path(req.path.toString(), params);
		auto bodyHash = sha256_hex(req.body.toString());
		auto payload = fmt::format("{}\n{}\n{}\n{}\n{}\n{}", sessionId, req.method.toString(), path, timestampHeader->toString(), nonce, bodyHash);
		auto expected = hmac_sha256_hex(_authSessionSecret, payload);
		if (expected != signatureHeader->toString()) {
			return false;
		}
		{
			std::lock_guard<std::mutex> lock(_authNonceMutex);
			auto cutoff = std::chrono::steady_clock::now() - std::chrono::seconds(AuthSignatureTTLSeconds);
			for (auto it = _authNonces.begin(); it != _authNonces.end();) {
				if (it->second < cutoff) {
					it = _authNonces.erase(it);
				} else {
					++it;
				}
			}
			if (_authNonces.find(nonce) != _authNonces.end()) {
				return false;
			}
			_authNonces.emplace(nonce, std::chrono::steady_clock::now());
		}
	} else if (!has_valid_auth(req, _authToken)) {
		return false;
	}
	if (_authTokenHasExpiry) {
		_authTokenExpiry = std::chrono::steady_clock::now() + std::chrono::seconds(AuthTokenTTLSeconds);
	}
	return true;
}

bool HttpServer::isTokenValid(const std::string& token) {
	if (!_authRequired) {
		return true;
	}
	if (_authToken.empty()) {
		return false;
	}
	if (_authTokenHasExpiry && std::chrono::steady_clock::now() > _authTokenExpiry) {
		_authToken.clear();
		_authSessionId.clear();
		_authSessionSecret.clear();
		_authTokenHasExpiry = false;
		return false;
	}
	if (!_authSessionId.empty()) {
		return false;
	} else if (token != _authToken) {
		return false;
	}
	if (_authTokenHasExpiry) {
		_authTokenExpiry = std::chrono::steady_clock::now() + std::chrono::seconds(AuthTokenTTLSeconds);
	}
	return true;
}

bool HttpServer::isWebSocketAuthorized(const std::string& resource) {
	if (!_authRequired) {
		return true;
	}
	if (_authToken.empty()) {
		return false;
	}
	if (_authTokenHasExpiry && std::chrono::steady_clock::now() > _authTokenExpiry) {
		_authToken.clear();
		_authSessionId.clear();
		_authSessionSecret.clear();
		_authTokenHasExpiry = false;
		return false;
	}
	if (_authSessionId.empty()) {
		auto token = get_query_param(resource, "auth"s);
		return isTokenValid(token);
	}
	auto params = parse_query_pairs(resource);
	std::string sessionId;
	std::string timestamp;
	std::string nonce;
	std::string signature;
	std::vector<std::pair<std::string, std::string>> signParams;
	signParams.reserve(params.size());
	for (const auto& param : params) {
		if (param.first == "session"s) {
			sessionId = param.second;
		} else if (param.first == "ts"s) {
			timestamp = param.second;
		} else if (param.first == "nonce"s) {
			nonce = param.second;
		} else if (param.first == "sig"s) {
			signature = param.second;
		} else {
			signParams.push_back(param);
		}
	}
	if (sessionId.empty() || timestamp.empty() || nonce.empty() || signature.empty()) {
		return false;
	}
	if (sessionId != _authSessionId) {
		return false;
	}
	long long tsValue = 0;
	try {
		tsValue = std::stoll(timestamp);
	} catch (...) {
		return false;
	}
	auto now = std::chrono::system_clock::now();
	auto nowSeconds = std::chrono::duration_cast<std::chrono::seconds>(now.time_since_epoch()).count();
	if (std::llabs(nowSeconds - tsValue) > AuthSignatureTTLSeconds) {
		return false;
	}
	auto pathEnd = resource.find('?');
	auto path = pathEnd == std::string::npos ? resource : resource.substr(0, pathEnd);
	signParams.emplace_back("nonce"s, nonce);
	signParams.emplace_back("session"s, sessionId);
	signParams.emplace_back("ts"s, timestamp);
	auto canonicalPath = canonicalize_query(signParams);
	if (!canonicalPath.empty()) {
		canonicalPath = path + "?"s + canonicalPath;
	} else {
		canonicalPath = path;
	}
	auto payload = fmt::format("{}\nGET\n{}\n{}\n{}\n{}", sessionId, canonicalPath, timestamp, nonce, ""s);
	auto expected = hmac_sha256_hex(_authSessionSecret, payload);
	if (expected != signature) {
		return false;
	}
	{
		std::lock_guard<std::mutex> lock(_authNonceMutex);
		auto cutoff = std::chrono::steady_clock::now() - std::chrono::seconds(AuthSignatureTTLSeconds);
		for (auto it = _authNonces.begin(); it != _authNonces.end();) {
			if (it->second < cutoff) {
				it = _authNonces.erase(it);
			} else {
				++it;
			}
		}
		if (_authNonces.find(nonce) != _authNonces.end()) {
			return false;
		}
		_authNonces.emplace(nonce, std::chrono::steady_clock::now());
	}
	if (_authTokenHasExpiry) {
		_authTokenExpiry = std::chrono::steady_clock::now() + std::chrono::seconds(AuthTokenTTLSeconds);
	}
	return true;
}

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

static bool route_matches(const std::string& pattern, const std::string& path) {
	try {
		return std::regex_match(path, std::regex(pattern, std::regex::ECMAScript));
	} catch (const std::regex_error&) {
		return pattern == path;
	}
}

static HttpServer::Request make_request(const xhttpdrequest* nativeRequest, std::vector<std::string>& paramStorage) {
	HttpServer::Request request;
	request.method = nativeRequest->sMethod;
	request.path = nativeRequest->sPath;
	request.headers.reserve(nativeRequest->iHeaderCount * 2u);
	for (uint32 i = 0; i < nativeRequest->iHeaderCount; ++i) {
		request.headers.emplace_back(nativeRequest->arrHeaders[i].sName);
		request.headers.emplace_back(nativeRequest->arrHeaders[i].sValue);
	}
	auto params = parse_query_pairs(nativeRequest->sTarget);
	paramStorage.reserve(params.size() * 2u);
	for (auto& [name, value] : params) {
		paramStorage.push_back(std::move(name));
		paramStorage.push_back(std::move(value));
	}
	request.params.reserve(paramStorage.size());
	for (const auto& value : paramStorage) request.params.emplace_back(value);
	if (auto contentType = xrtHttpdRequestHeader(nativeRequest, "Content-Type")) request.contentType = contentType;
	if (nativeRequest->pBody && nativeRequest->iBodyLen > 0u) request.body = Slice(nativeRequest->pBody, nativeRequest->iBodyLen);
	return request;
}

static bool valid_static_path(const std::string& path) {
	if (path.empty() || path.front() != '/' || path.find('\0') != std::string::npos) return false;
	size_t start = 1;
	while (start <= path.size()) {
		auto end = path.find('/', start);
		if (end == std::string::npos) end = path.size();
		auto part = std::string_view(path).substr(start, end - start);
		if (part == ".."sv) return false;
		start = end + 1;
	}
	return true;
}

static const char* content_type_for_path(const std::string& path) {
	auto dot = path.find_last_of('.');
	auto ext = dot == std::string::npos ? std::string{} : path.substr(dot);
	std::transform(ext.begin(), ext.end(), ext.begin(), [](unsigned char ch) { return s_cast<char>(std::tolower(ch)); });
	static const std::unordered_map<std::string, const char*> types{
		{".html", "text/html; charset=utf-8"}, {".htm", "text/html; charset=utf-8"},
		{".js", "text/javascript; charset=utf-8"}, {".mjs", "text/javascript; charset=utf-8"},
		{".css", "text/css; charset=utf-8"}, {".json", "application/json; charset=utf-8"},
		{".txt", "text/plain; charset=utf-8"}, {".xml", "application/xml; charset=utf-8"},
		{".svg", "image/svg+xml"}, {".png", "image/png"}, {".jpg", "image/jpeg"}, {".jpeg", "image/jpeg"},
		{".gif", "image/gif"}, {".webp", "image/webp"}, {".ico", "image/x-icon"},
		{".wasm", "application/wasm"}, {".pdf", "application/pdf"}, {".zip", "application/zip"},
		{".woff", "font/woff"}, {".woff2", "font/woff2"}, {".ttf", "font/ttf"}, {".otf", "font/otf"},
		{".mp3", "audio/mpeg"}, {".ogg", "audio/ogg"}, {".wav", "audio/wav"}, {".mp4", "video/mp4"},
	};
	auto it = types.find(ext);
	return it == types.end() ? "application/octet-stream" : it->second;
}

enum class RangeParseResult {
	None,
	Valid,
	Unsatisfiable,
};

struct ByteRange {
	size_t first = 0;
	size_t last = 0;
};

static RangeParseResult parse_byte_range(const HttpServer::Request& request, size_t contentSize, ByteRange& result) {
	auto header = find_header(request, "Range"_slice);
	if (!header) return RangeParseResult::None;
	auto value = header->toString();
	if (value.rfind("bytes="s, 0) != 0) return RangeParseResult::None;
	auto range = std::string_view(value).substr(6);
	if (range.empty() || range.find(',') != std::string_view::npos || contentSize == 0) return RangeParseResult::Unsatisfiable;
	auto dash = range.find('-');
	if (dash == std::string_view::npos) return RangeParseResult::Unsatisfiable;
	auto firstText = range.substr(0, dash);
	auto lastText = range.substr(dash + 1);
	auto parse = [](std::string_view text, uint64_t& number) {
		if (text.empty()) return false;
		auto [ptr, error] = std::from_chars(text.data(), text.data() + text.size(), number);
		return error == std::errc{} && ptr == text.data() + text.size();
	};
	uint64_t first = 0;
	uint64_t last = 0;
	if (firstText.empty()) {
		uint64_t suffix = 0;
		if (!parse(lastText, suffix) || suffix == 0) return RangeParseResult::Unsatisfiable;
		result.first = suffix >= contentSize ? 0 : contentSize - s_cast<size_t>(suffix);
		result.last = contentSize - 1;
		return RangeParseResult::Valid;
	}
	if (!parse(firstText, first) || first >= contentSize) return RangeParseResult::Unsatisfiable;
	if (lastText.empty()) {
		last = contentSize - 1;
	} else if (!parse(lastText, last) || first > last) {
		return RangeParseResult::Unsatisfiable;
	}
	result.first = s_cast<size_t>(first);
	result.last = s_cast<size_t>(std::min<uint64_t>(last, contentSize - 1));
	return RangeParseResult::Valid;
}

bool HttpServer::start(int port) {
	if (_server) return false;
	auto engine = r_cast<xnetengine*>(DoraXrtNetworkEngine());
	if (!engine) return false;
	xhttpdconfig config;
	xrtHttpdConfigInit(&config);
	xrtNetAddrInitAny(&config.tBindAddr, AF_INET, s_cast<uint16>(port));
	config.iRecvLimit = 512u * 1024u * 1024u;
	config.iBodyLimit = config.iRecvLimit;
	xhttpdevents events{};
	events.OnRequest = [](ptr owner, xhttpdserver*, xhttpdconn*, const xhttpdrequest* nativeRequest, xhttpdresponse* nativeResponse) {
		auto self = r_cast<HttpServer*>(owner);
		const auto requestGeneration = self->_generation.load(std::memory_order_acquire);
		xrtHttpdResponseSetHeader(nativeResponse, "Access-Control-Allow-Origin", "*");
		xrtHttpdResponseSetHeader(nativeResponse, "Access-Control-Allow-Headers", "*");
		std::vector<std::string> paramStorage;
		auto request = make_request(nativeRequest, paramStorage);
		auto path = request.path.toString();
		auto respond = [&](HttpServer::Response&& response) {
			set_response(nativeResponse, response.status > 0 ? response.status : 200, response.content, response.contentType);
		};
		if (nativeRequest->iMethod == XHTTPD_METHOD_OPTIONS) {
			set_response(nativeResponse, 200, {}, {});
			return true;
		}
		if (nativeRequest->iMethod == XHTTPD_METHOD_GET || nativeRequest->iMethod == XHTTPD_METHOD_HEAD) {
			if (nativeRequest->iMethod == XHTTPD_METHOD_GET) {
				for (const auto& route : self->_gets) {
					if (!route_matches(route.pattern, path)) continue;
					auto pending = std::make_shared<PendingLogicResult<HttpServer::Response>>();
					SharedApplication.invokeInLogic([pending, route = &route, request]() {
						if (!pending->isCancelled()) pending->complete(route->handler(request));
					});
					auto response = pending->wait(self->_stopping, self->_generation, requestGeneration);
					if (!response) set_service_unavailable(nativeResponse); else respond(std::move(*response));
					return true;
				}
			}
			std::string decodedPath(path.size() + 1, '\0');
			size_t decodedLength = 0;
			if (!xrtPercentDecodeTo(path.data(), path.size(), decodedPath.data(), decodedPath.size(), &decodedLength, false)) return false;
			decodedPath.resize(decodedLength);
			if (!valid_static_path(decodedPath)) return false;
			if (decodedPath.back() == '/') decodedPath += "index.html";
			auto requestPath = decodedPath;
			decodedPath.erase(decodedPath.begin());
			if (!SharedContent.exist(decodedPath)) {
				bool found = false;
				if (!self->_wwwPath.empty()) {
					auto checkPath = Path::concat({self->_wwwPath, decodedPath});
					if (SharedContent.exist(checkPath)) { decodedPath = checkPath; found = true; }
				}
				if (!found) {
					auto checkPath = Path::concat({SharedContent.getWritablePath(), decodedPath});
					if (SharedContent.exist(checkPath)) { decodedPath = checkPath; found = true; }
				}
				if (!found) return false;
			}
			auto pending = std::make_shared<PendingLogicResult<std::string>>();
			SharedContent.getThread()->run([pending, file = decodedPath]() {
				if (!pending->isCancelled()) pending->complete(SharedContent.loadUnsafe(file));
			});
			auto content = pending->wait(self->_stopping, self->_generation, requestGeneration);
			if (!content) {
				set_service_unavailable(nativeResponse);
				return true;
			}
			if (content->empty()) return false;
			xrtHttpdResponseSetHeader(nativeResponse, "Content-Type", content_type_for_path(decodedPath));
			auto cacheControl = self->getStaticCacheControl(requestPath);
			if (!cacheControl.empty()) xrtHttpdResponseSetHeader(nativeResponse, "Cache-Control", cacheControl.c_str());
			xrtHttpdResponseSetHeader(nativeResponse, "Accept-Ranges", "bytes");
			ByteRange range;
			auto rangeResult = parse_byte_range(request, content->size(), range);
			if (rangeResult == RangeParseResult::Unsatisfiable) {
				auto contentRange = fmt::format("bytes */{}", content->size());
				xrtHttpdResponseSetHeader(nativeResponse, "Content-Range", contentRange.c_str());
				set_response(nativeResponse, 416, {}, {});
				return true;
			}
			auto first = rangeResult == RangeParseResult::Valid ? range.first : 0;
			auto last = rangeResult == RangeParseResult::Valid ? range.last : content->size() - 1;
			auto length = last - first + 1;
			if (rangeResult == RangeParseResult::Valid) {
				auto contentRange = fmt::format("bytes {}-{}/{}", first, last, content->size());
				xrtHttpdResponseSetHeader(nativeResponse, "Content-Range", contentRange.c_str());
			}
			xrtHttpdResponseSetStatus(nativeResponse, rangeResult == RangeParseResult::Valid ? 206u : 200u, nullptr);
			if (nativeRequest->iMethod == XHTTPD_METHOD_HEAD) {
				auto contentLength = std::to_string(length);
				xrtHttpdResponseSetHeader(nativeResponse, "Content-Length", contentLength.c_str());
			} else {
				xrtHttpdResponseSetBodyCopy(nativeResponse, content->data() + first, length, nullptr);
			}
			return true;
		}
		if (nativeRequest->iMethod != XHTTPD_METHOD_POST) return false;
		if (path != "/auth"sv && path != "/auth/confirm"sv && !self->isAuthorized(request)) {
			set_unauthorized(nativeResponse);
			return true;
		}
		for (const auto& route : self->_posts) {
			if (!route_matches(route.pattern, path)) continue;
			auto pending = std::make_shared<PendingLogicResult<HttpServer::Response>>();
			SharedApplication.invokeInLogic([pending, route = &route, request]() {
				if (!pending->isCancelled()) pending->complete(route->handler(request));
			});
			auto response = pending->wait(self->_stopping, self->_generation, requestGeneration);
			if (!response) set_service_unavailable(nativeResponse); else respond(std::move(*response));
			return true;
		}
		for (const auto& route : self->_postScheduled) {
			if (!route_matches(route.pattern, path)) continue;
			auto pending = std::make_shared<PendingLogicResult<HttpServer::Response>>();
			SharedApplication.invokeInLogic([pending, route = &route, request]() {
				if (pending->isCancelled()) return;
				auto scheduleFunc = route->handler(request);
				SharedDirector.getSystemScheduler()->schedule([pending, scheduleFunc = std::move(scheduleFunc)](double) {
					if (pending->isCancelled()) return true;
					auto response = scheduleFunc();
					if (!response) return false;
					pending->complete(std::move(*response));
					return true;
				});
			});
			auto response = pending->wait(self->_stopping, self->_generation, requestGeneration);
			if (!response) set_service_unavailable(nativeResponse); else respond(std::move(*response));
			return true;
		}
		for (const auto& route : self->_files) {
			if (!route_matches(route.pattern, path)) continue;
			auto contentType = xrtHttpdRequestHeader(nativeRequest, "Content-Type");
			xrtstrview boundary{};
			if (!contentType || !xrtMultipartBoundaryFromContentType(contentType, &boundary) || !nativeRequest->pBody) {
				set_response(nativeResponse, 403, {}, {});
				return true;
			}
			xrthttputillimits limits;
			xrtHttpUtilLimitsInit(&limits);
			limits.iMaxMultipartBytes = 512u * 1024u * 1024u;
			if (!xrtMultipartValidateN(nativeRequest->pBody, nativeRequest->iBodyLen, boundary.sPtr, boundary.iLen, &limits)) {
				set_response(nativeResponse, 400, {}, {});
				return true;
			}
			std::list<std::string> acceptedFiles;
			size_t offset = 0;
			xrtmultipartpartview part{};
			while (xrtMultipartNextN(nativeRequest->pBody, nativeRequest->iBodyLen, boundary.sPtr, boundary.iLen, &offset, &part)) {
				if ((part.iFlags & XRT_MULTIPART_F_HAS_FILENAME) == 0u) continue;
				std::string filename(part.tFileName.iLen * 3u + 1u, '\0');
				size_t filenameLength = 0;
				if (!xrtMultipartDecodeFileNameTo(&part, filename.data(), filename.size(), &filenameLength)) {
					set_response(nativeResponse, 400, {}, {});
					return true;
				}
				filename.resize(filenameLength);
				auto accepted = std::make_shared<PendingLogicResult<std::optional<std::string>>>();
				SharedApplication.invokeInLogic([accepted, route = &route, request, filename]() {
					if (!accepted->isCancelled()) accepted->complete(route->acceptHandler(request, filename));
				});
				auto acceptedPath = accepted->wait(self->_stopping, self->_generation, requestGeneration);
				if (!acceptedPath) {
					set_service_unavailable(nativeResponse);
					return true;
				}
				if (!acceptedPath->has_value()) {
					set_response(nativeResponse, 403, {}, {});
					return true;
				}
				auto file = std::move(acceptedPath->value());
				auto stream = std::unique_ptr<SDL_RWops, decltype(&SDL_RWclose)>(SDL_RWFromFile(file.c_str(), "wb+"), SDL_RWclose);
				if (!stream || SDL_RWwrite(stream.get(), part.tBody.sPtr, 1, part.tBody.iLen) != part.tBody.iLen) {
					set_response(nativeResponse, 500, {}, {});
					return true;
				}
				acceptedFiles.emplace_back(std::move(file));
			}
			auto done = std::make_shared<PendingLogicResult<bool>>();
			SharedApplication.invokeInLogic([done, route = &route, request, acceptedFiles]() {
				if (done->isCancelled()) return;
				bool success = true;
				for (const auto& file : acceptedFiles) {
					if (!route->doneHandler(request, file)) { SharedContent.remove(file); success = false; break; }
				}
				done->complete(success);
			});
			auto success = done->wait(self->_stopping, self->_generation, requestGeneration);
			if (!success) set_service_unavailable(nativeResponse); else set_response(nativeResponse, *success ? 200 : 500, {}, {});
			return true;
		}
		return false;
	};
	events.OnError = [](ptr, xhttpdserver*, xhttpdconn*, int error) { Error("http server error: {}", error); };
	auto server = xrtHttpdCreate(engine, &config, &events, this);
	if (!server || xrtHttpdStart(server) != XRT_NET_OK) {
		if (server) xrtHttpdDestroy(server);
		return false;
	}
	_server = server;
	_stopping.store(false, std::memory_order_release);
	return true;
}

bool HttpServer::startWS(int port) {
	_webSocketServer = New<WebSocketServer>(this);
	if (!_webSocketServer->init()) {
		_webSocketServer = nullptr;
		return false;
	}
	if (!_webSocketServer->start(port)) {
		_webSocketServer = nullptr;
		return false;
	}
	_webSocketListener = Listener::create("AppWS"s, [this](Event* event) {
		if (_webSocketServer) {
			// Backward compatible:
			// 1) New Lua/C++ style: emit("AppWS", payloadDictionary)
			// 2) Legacy Lua style: emit("AppWS", "Send", msg)
			if (DoraAs<LuaEventArgs>(event)) {
				Dictionary* payload = nullptr;
				if (event->get(payload) && payload) {
					if (payload->get("type"_slice, std::string{}) == "Send"sv) {
						_webSocketServer->send(payload->get("msg"_slice, std::string{}));
					}
				} else {
					std::string eventType;
					std::string msg;
					if (event->get(eventType, msg) && eventType == "Send"sv) {
						_webSocketServer->send(msg);
					}
				}
				return;
			}
			Dictionary* payload = nullptr;
			if (event->get(payload) && payload && payload->get("type"_slice, std::string{}) == "Send"sv) {
				_webSocketServer->send(payload->get("msg"_slice, std::string{}));
			}
		}
	});
	return true;
}

void HttpServer::stop() {
	_stopping.store(true, std::memory_order_release);
	_generation.fetch_add(1, std::memory_order_acq_rel);
	if (_server) {
		auto server = r_cast<xhttpdserver*>(_server);
		_server = nullptr;
		xrtHttpdDestroy(server);
	}
	_gets.clear();
	_posts.clear();
	_postScheduled.clear();
	_files.clear();

	if (_webSocketServer) {
		_webSocketServer = nullptr;
	}
	_webSocketListener = nullptr;
}

const char* HttpServer::getVersion() {
	return "2026-05-21";
}

/* HttpClient */

namespace {
std::mutex s_httpClientRequestMutex;
struct HttpRequestState {
	uint64_t id = 0;
	std::atomic_bool cancelling = false;
	std::atomic_bool finished = false;
};
std::unordered_map<uint64_t, std::shared_ptr<HttpRequestState>> s_httpClientRequests;
std::atomic_uint64_t s_httpClientRequestId{0};

static std::shared_ptr<HttpRequestState> register_http_client_request() {
	if (SharedHttpClient.isStopped()) {
		return nullptr;
	}
	std::lock_guard<std::mutex> lock(s_httpClientRequestMutex);
	if (SharedHttpClient.isStopped()) {
		return nullptr;
	}
	auto request = std::make_shared<HttpRequestState>();
	request->id = s_httpClientRequestId.fetch_add(1, std::memory_order_relaxed) + 1;
	s_httpClientRequests.emplace(request->id, request);
	return request;
}

static void unregister_http_client_request(const std::shared_ptr<HttpRequestState>& request) {
	if (!request) {
		return;
	}
	if (request->finished.exchange(true, std::memory_order_relaxed)) {
		return;
	}
	const auto id = request->id;
	if (id == 0) {
		return;
	}
	std::lock_guard<std::mutex> lock(s_httpClientRequestMutex);
	s_httpClientRequests.erase(id);
}

static std::shared_ptr<HttpRequestState> get_http_client_request(uint64_t id) {
	std::lock_guard<std::mutex> lock(s_httpClientRequestMutex);
	if (auto it = s_httpClientRequests.find(id); it != s_httpClientRequests.end()) {
		return it->second;
	}
	return nullptr;
}

static std::vector<std::shared_ptr<HttpRequestState>> snapshot_http_client_requests() {
	std::vector<std::shared_ptr<HttpRequestState>> requests;
	std::lock_guard<std::mutex> lock(s_httpClientRequestMutex);
	requests.reserve(s_httpClientRequests.size());
	for (const auto& item : s_httpClientRequests) {
		requests.push_back(item.second);
	}
	return requests;
}

static unsigned int to_timeout_ms(float timeout) {
	if (!(timeout > 0.0f)) {
		return 0u;
	}
	auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
		std::chrono::duration<float>(timeout));
	if (duration.count() <= 0) {
		return 1u;
	}
	return s_cast<unsigned int>(duration.count());
}

static int should_cancel_xrt_http(void* userData) {
	auto request = r_cast<HttpRequestState*>(userData);
	return request && request->cancelling.load(std::memory_order_relaxed);
}

static void prepare_xrt_http_headers(
	std::vector<std::string>& headerNames,
	std::vector<std::string>& headerValues,
	std::vector<const char*>& headerNamePtrs,
	std::vector<const char*>& headerValuePtrs,
	const std::vector<std::pair<std::string, std::string>>& headers) {
	headerNames.clear();
	headerValues.clear();
	headerNamePtrs.clear();
	headerValuePtrs.clear();
	headerNames.reserve(headers.size() + 1);
	headerValues.reserve(headers.size() + 1);
	for (const auto& header : headers) {
		headerNames.push_back(header.first);
		headerValues.push_back(header.second);
	}
	headerNamePtrs.reserve(headerNames.size());
	headerValuePtrs.reserve(headerValues.size());
	for (size_t i = 0; i < headerNames.size(); ++i) {
		headerNamePtrs.push_back(headerNames[i].c_str());
		headerValuePtrs.push_back(headerValues[i].c_str());
	}
}

struct XrtPostStreamCompletion {
	std::shared_ptr<HttpClient::ContentHandler> callback;
	std::atomic<size_t> queuedChunks{0};
	std::atomic<size_t> handledChunks{0};
	std::atomic<size_t> queuedBytes{0};
	std::atomic<size_t> handledBytes{0};
	std::atomic_bool finalRequested{false};
	std::atomic_bool finalSuccess{false};
	std::atomic_bool completed{false};
};

struct XrtPostStreamContext {
	std::shared_ptr<HttpRequestState> request;
	std::shared_ptr<HttpClient::ContentPartHandler> partCallback;
	std::shared_ptr<std::atomic<bool>> stopped;
	std::shared_ptr<XrtPostStreamCompletion> completion;
};

static void try_finish_xrt_post_stream_in_logic(const std::shared_ptr<XrtPostStreamCompletion>& completion) {
	if (!completion || !completion->finalRequested.load(std::memory_order_relaxed)) {
		return;
	}
	const auto queuedChunkCount = completion->queuedChunks.load(std::memory_order_relaxed);
	const auto handledChunkCount = completion->handledChunks.load(std::memory_order_relaxed);
	const auto queuedByteCount = completion->queuedBytes.load(std::memory_order_relaxed);
	const auto handledByteCount = completion->handledBytes.load(std::memory_order_relaxed);
	if (handledChunkCount < queuedChunkCount || handledByteCount < queuedByteCount) {
		return;
	}
	if (completion->completed.exchange(true, std::memory_order_relaxed)) {
		return;
	}
	const auto success = completion->finalSuccess.load(std::memory_order_relaxed);
	if (success) {
		(*completion->callback)(""_slice);
	} else {
		(*completion->callback)(std::nullopt);
	}
}

static void request_finish_xrt_post_stream_in_logic(const std::shared_ptr<XrtPostStreamCompletion>& completion, bool success) {
	SharedApplication.invokeInLogic([completion, success]() {
		completion->finalSuccess.store(success, std::memory_order_relaxed);
		completion->finalRequested.store(true, std::memory_order_relaxed);
		try_finish_xrt_post_stream_in_logic(completion);
	});
}

static int on_xrt_post_stream_chunk(const char* data, size_t dataLen, size_t, size_t, void* userData) {
	auto context = r_cast<XrtPostStreamContext*>(userData);
	if (!context || !data || dataLen == 0 || !context->partCallback || !*context->partCallback) {
		return context && context->request && context->request->cancelling.load(std::memory_order_relaxed);
	}
	std::string body(data, dataLen);
	context->completion->queuedChunks.fetch_add(1, std::memory_order_relaxed);
	context->completion->queuedBytes.fetch_add(dataLen, std::memory_order_relaxed);
	SharedApplication.invokeInLogic([request = context->request, partCallback = context->partCallback, stopped = context->stopped, completion = context->completion, body = std::move(body)]() {
		completion->handledChunks.fetch_add(1, std::memory_order_relaxed);
		completion->handledBytes.fetch_add(body.size(), std::memory_order_relaxed);
		if (*stopped) {
			try_finish_xrt_post_stream_in_logic(completion);
			return;
		}
		if ((*partCallback)(body)) {
			*stopped = true;
			request->cancelling.store(true, std::memory_order_relaxed);
		}
		try_finish_xrt_post_stream_in_logic(completion);
	});
	return context->stopped->load(std::memory_order_relaxed) ||
		(context->request && context->request->cancelling.load(std::memory_order_relaxed));
}

struct XrtDownloadStreamContext {
	std::shared_ptr<HttpRequestState> request;
	std::shared_ptr<std::function<bool(bool interrupted, uint64_t current, uint64_t total)>> progress;
	std::shared_ptr<std::atomic<bool>> stopped;
	SDL_RWops* output = nullptr;
	std::string url;
	size_t written = 0;
	bool writeFailed = false;
};

static int on_xrt_download_stream_chunk(const char* data, size_t dataLen, size_t current, size_t total, void* userData) {
	auto context = r_cast<XrtDownloadStreamContext*>(userData);
	if (!context || !data || dataLen == 0) {
		return context && context->request && context->request->cancelling.load(std::memory_order_relaxed);
	}
	auto written = SDL_RWwrite(context->output, data, 1, dataLen);
	if (written != dataLen) {
		context->writeFailed = true;
		context->request->cancelling.store(true, std::memory_order_relaxed);
		return 1;
	}
	context->written += written;
	SharedApplication.invokeInLogic([request = context->request, progress = context->progress, stopped = context->stopped, current = s_cast<uint64_t>(current), total = s_cast<uint64_t>(total)]() {
		if (*stopped) {
			return;
		}
		*stopped = (*progress)(false, current, total);
		if (*stopped) {
			request->cancelling.store(true, std::memory_order_relaxed);
		}
	});
	return context->stopped->load(std::memory_order_relaxed) ||
		context->request->cancelling.load(std::memory_order_relaxed);
}
} // namespace

HttpClient::HttpClient()
	: _stopped(false) {
}

HttpClient::~HttpClient() {
	stop();
}

bool HttpClient::isStopped() const noexcept {
	return _stopped.load(std::memory_order_relaxed);
}

bool HttpClient::cancel(RequestId requestId) {
	auto request = get_http_client_request(requestId);
	if (!request || request->finished.load(std::memory_order_relaxed)) {
		return false;
	}
	request->cancelling.store(true, std::memory_order_relaxed);
	return true;
}

bool HttpClient::isRequestActive(RequestId requestId) const {
	auto request = get_http_client_request(requestId);
	return request && !request->finished.load(std::memory_order_relaxed);
}

void HttpClient::reapDownloadWorkers(bool all) {
	std::lock_guard<std::mutex> lock(_downloadWorkersMutex);
	for (auto it = _downloadWorkers.begin(); it != _downloadWorkers.end();) {
		if (all || it->completed->load(std::memory_order_acquire)) {
			if (it->thread.joinable()) {
				it->thread.join();
			}
			it = _downloadWorkers.erase(it);
		} else {
			++it;
		}
	}
}

HttpClient::RequestId HttpClient::postAsync(String url, std::span<Slice> headers, String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback) {
	if (_stopped.load(std::memory_order_relaxed)) {
		callback(std::nullopt);
		return 0;
	}
	auto request = register_http_client_request();
	if (!request) {
		callback(std::nullopt);
		return 0;
	}
	std::vector<std::pair<std::string, std::string>> postHeaders;
	for (const auto& header : headers) {
		auto parts = header.split(":"sv);
		if (parts.size() == 2) {
			postHeaders.emplace_back(parts.front().toString(), parts.back().toString());
		}
	}
	postHeaders.emplace_back("Content-Type"s, "application/json"s);
	auto callbackFunc = std::make_shared<ContentHandler>(callback);
	auto partCallbackFunc = std::make_shared<ContentPartHandler>(partCallback);
	SharedAsyncThread.run([request, json = json.toString(), timeout, urlStr = url.toString(), partCallbackFunc, callbackFunc, headers = std::move(postHeaders)]() {
		std::vector<std::string> headerNames;
		std::vector<std::string> headerValues;
		std::vector<const char*> headerNamePtrs;
		std::vector<const char*> headerValuePtrs;
		DoraXrtHttpResponse response;
		prepare_xrt_http_headers(headerNames, headerValues, headerNamePtrs, headerValuePtrs, headers);
		if (*partCallbackFunc) {
			auto stopped = std::make_shared<std::atomic<bool>>(false);
			auto completion = std::make_shared<XrtPostStreamCompletion>();
			completion->callback = callbackFunc;
			XrtPostStreamContext streamContext{request, partCallbackFunc, stopped, completion};
			int statusCode = 0;
			auto status = DoraXrtHttpExecuteStream(
				"POST",
				urlStr.c_str(),
				headerNamePtrs.data(),
				headerValuePtrs.data(),
				headerNamePtrs.size(),
				json.data(),
				json.size(),
				to_timeout_ms(timeout),
				0,
				should_cancel_xrt_http,
				request.get(),
				on_xrt_post_stream_chunk,
				&streamContext,
				&statusCode);
			if (status != 0 || statusCode < 200 || statusCode >= 400 || stopped->load(std::memory_order_relaxed)) {
				request_finish_xrt_post_stream_in_logic(completion, false);
			} else {
				request_finish_xrt_post_stream_in_logic(completion, true);
			}
		} else {
			auto status = DoraXrtHttpExecute(
				"POST",
				urlStr.c_str(),
				headerNamePtrs.data(),
				headerValuePtrs.data(),
				headerNamePtrs.size(),
				json.data(),
				json.size(),
				to_timeout_ms(timeout),
				0,
				should_cancel_xrt_http,
				request.get(),
				&response);
			if (status != 0 || response.statusCode < 200 || response.statusCode >= 400) {
				Info("failed to do HTTP POST \"{}\"; network status: {}, HTTP status: {}", urlStr, DoraXrtHttpStatusName(status), response.statusCode);
				SharedApplication.invokeInLogic([callbackFunc]() {
					(*callbackFunc)(std::nullopt);
				});
			} else {
				std::string body(response.body ? response.body : "", response.bodyLen);
				SharedApplication.invokeInLogic([callbackFunc, body = std::move(body)]() {
					(*callbackFunc)(body);
				});
			}
			DoraXrtHttpResponseFree(&response);
		}
		unregister_http_client_request(request);
		return nullptr;
	},
		[partCallbackFunc, callbackFunc](Own<Values>) {
		});
	return request->id;
}

HttpClient::RequestId HttpClient::postAsync(String url, String json, float timeout, const ContentHandler& callback) {
	return postAsync(url, std::span<Slice>{}, json, timeout, nullptr, callback);
}

HttpClient::RequestId HttpClient::postAsync(String url, const std::vector<std::string>& headers, String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback) {
	std::vector<Slice> headerArray(headers.size());
	for (size_t i = 0; i < headers.size(); i++) {
		headerArray[i] = headers[i];
	}
	return postAsync(url, std::span<Slice>(headerArray), json, timeout, partCallback, callback);
}

HttpClient::RequestId HttpClient::postAsync(String url, const std::vector<std::string>& headers, String json, float timeout, const ContentHandler& callback) {
	return postAsync(url, headers, json, timeout, nullptr, callback);
}

HttpClient::RequestId HttpClient::postAsync(String url, Slice headers[], int count, String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback) {
	return postAsync(url, std::span<Slice>(headers, s_cast<size_t>(count)), json, timeout, partCallback, callback);
}

HttpClient::RequestId HttpClient::postAsync(String url, Slice headers[], int count, String json, float timeout, const ContentHandler& callback) {
	return postAsync(url, std::span<Slice>(headers, s_cast<size_t>(count)), json, timeout, nullptr, callback);
}

HttpClient::RequestId HttpClient::getAsync(String url, float timeout, const ContentHandler& callback) {
	if (_stopped.load(std::memory_order_relaxed)) {
		callback(std::nullopt);
		return 0;
	}
	auto request = register_http_client_request();
	if (!request) {
		callback(std::nullopt);
		return 0;
	}
	SharedAsyncThread.run([request, timeout, urlStr = url.toString(), callback]() {
		std::vector<std::string> headerNames;
		std::vector<std::string> headerValues;
		std::vector<const char*> headerNamePtrs;
		std::vector<const char*> headerValuePtrs;
		DoraXrtHttpResponse response;
		prepare_xrt_http_headers(headerNames, headerValues, headerNamePtrs, headerValuePtrs, {});
		auto status = DoraXrtHttpExecute(
			"GET",
			urlStr.c_str(),
			headerNamePtrs.data(),
			headerValuePtrs.data(),
			headerNamePtrs.size(),
			nullptr,
			0,
			to_timeout_ms(timeout),
			0,
			should_cancel_xrt_http,
			request.get(),
			&response);
		if (status != 0 || response.statusCode < 200 || response.statusCode >= 400) {
			Info("failed to do HTTP GET \"{}\"; network status: {}, HTTP status: {}", urlStr, DoraXrtHttpStatusName(status), response.statusCode);
			SharedApplication.invokeInLogic([callback]() {
				callback(std::nullopt);
			});
		} else {
			std::string body(response.body ? response.body : "", response.bodyLen);
			SharedApplication.invokeInLogic([callback, body = std::move(body)]() {
				callback(body);
			});
		}
		DoraXrtHttpResponseFree(&response);
		unregister_http_client_request(request);
	});
	return request->id;
}

HttpClient::RequestId HttpClient::downloadAsync(String url, String filePath, float timeout, const std::function<bool(bool interrupted, uint64_t current, uint64_t total)>& progress) {
	if (_stopped.load(std::memory_order_relaxed)) {
		progress(true, 0, 0);
		return 0;
	}
	auto request = register_http_client_request();
	if (!request) {
		progress(true, 0, 0);
		return 0;
	}
	auto progressFunc = std::make_shared<std::function<bool(bool interrupted, uint64_t current, uint64_t total)>>(progress);
	auto completed = std::make_shared<std::atomic_bool>(false);
	auto fileStr = filePath.toString();
	auto urlStr = url.toString();
	auto worker = [request, fileStr, urlStr, timeout, progressFunc, completed]() {
		DEFER(completed->store(true, std::memory_order_release));
		try {
			if (request->cancelling.load(std::memory_order_relaxed)) {
				SharedApplication.invokeInLogic([progressFunc]() {
					(*progressFunc)(true, 0, 0);
				});
				unregister_http_client_request(request);
				return;
			}
			std::vector<std::string> headerNames;
			std::vector<std::string> headerValues;
			std::vector<const char*> headerNamePtrs;
			std::vector<const char*> headerValuePtrs;
			prepare_xrt_http_headers(headerNames, headerValues, headerNamePtrs, headerValuePtrs, {});
			auto fullname = fileStr;
			SDL_RWops* out = SDL_RWFromFile(fullname.c_str(), "wb+");
			if (!out) {
				Error("invalid local file path \"{}\" to download to", fileStr);
				unregister_http_client_request(request);
				return;
			}
			auto stream = std::shared_ptr<SDL_RWops>{out, [](SDL_RWops* io) {
														 SDL_RWclose(io);
													 }};
			auto stopped = std::make_shared<std::atomic<bool>>(false);
			XrtDownloadStreamContext streamContext{request, progressFunc, stopped, out, urlStr};
			int statusCode = 0;
			auto status = DoraXrtHttpExecuteStream(
				"GET",
				urlStr.c_str(),
				headerNamePtrs.data(),
				headerValuePtrs.data(),
				headerNamePtrs.size(),
				nullptr,
				0,
				to_timeout_ms(timeout),
				0,
				should_cancel_xrt_http,
				request.get(),
				on_xrt_download_stream_chunk,
				&streamContext,
				&statusCode);
			if (status != 0 || statusCode < 200 || statusCode >= 400 || streamContext.writeFailed || stopped->load(std::memory_order_relaxed)) {
				Info("failed to download \"{}\"; network status: {}, HTTP status: {}", urlStr, DoraXrtHttpStatusName(status), statusCode);
				SharedApplication.invokeInLogic([progressFunc]() {
					(*progressFunc)(true, 0, 0);
				});
				std::error_code err;
				fs::remove_all(fileStr, err);
				WarnIf(err, "failed to remove download file \"{}\" due to \"{}\".", fileStr, err.message());
				unregister_http_client_request(request);
				return;
			}
			SharedApplication.invokeInLogic([request, progressFunc, total = s_cast<uint64_t>(streamContext.written), stream, stopped]() {
				if (!*stopped) {
					*stopped = (*progressFunc)(false, total, total);
				}
				if (*stopped) {
					request->cancelling.store(true, std::memory_order_relaxed);
				}
			});
		} catch (const std::invalid_argument& ex) {
			Error("invalid url \"{}\" to download due to: {}", urlStr, ex.what());
			SharedApplication.invokeInLogic([progressFunc]() {
				(*progressFunc)(true, 0, 0);
			});
		} catch (const std::exception& ex) {
			Error("failed to download \"{}\" due to: {}", urlStr, ex.what());
			SharedApplication.invokeInLogic([progressFunc]() {
				(*progressFunc)(true, 0, 0);
			});
		}
		unregister_http_client_request(request);
	};
	reapDownloadWorkers(false);
	bool stoppedBeforeStart = false;
	bool startFailed = false;
	std::string startError;
	{
		std::lock_guard<std::mutex> lock(_downloadWorkersMutex);
		if (_stopped.load(std::memory_order_relaxed)) {
			stoppedBeforeStart = true;
		} else {
			bool workerSlotAdded = false;
			try {
				_downloadWorkers.push_back({std::thread{}, completed});
				workerSlotAdded = true;
				_downloadWorkers.back().thread = std::thread(std::move(worker));
			} catch (const std::exception& ex) {
				startFailed = true;
				startError = ex.what();
				if (workerSlotAdded) {
					_downloadWorkers.pop_back();
				}
			}
		}
	}
	if (stoppedBeforeStart || startFailed) {
		if (startFailed) {
			Error("failed to start download worker for \"{}\" due to: {}", urlStr, startError);
		}
		unregister_http_client_request(request);
		progress(true, 0, 0);
		return 0;
	}
	return request->id;
}

void HttpClient::stop() {
	_stopped.store(true, std::memory_order_relaxed);
	auto requests = snapshot_http_client_requests();
	for (const auto& request : requests) {
		if (request) {
			request->cancelling.store(true, std::memory_order_relaxed);
		}
	}
	reapDownloadWorkers(true);
}

NS_DORA_END
