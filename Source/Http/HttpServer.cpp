/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Http/HttpServer.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Common/Async.h"
#include "Event/Event.h"
#include "Event/Listener.h"
#include "Support/Dictionary.h"
#include "Support/Value.h"

#define CPPHTTPLIB_OPENSSL_SUPPORT
#define CPPHTTPLIB_ZLIB_SUPPORT
#include "httplib/httplib.h"

#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"

#include "yuescript/parser.hpp"

#include "openssl/evp.h"
#include "openssl/hmac.h"

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
#include <chrono>
#include <condition_variable>
#include <cstdlib>
#include <mutex>
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

static std::string to_hex(const unsigned char* data, size_t len) {
	static constexpr char hex[] = "0123456789abcdef";
	std::string out;
	out.reserve(len * 2);
	for (size_t i = 0; i < len; ++i) {
		unsigned char byte = data[i];
		out.push_back(hex[byte >> 4]);
		out.push_back(hex[byte & 0x0F]);
	}
	return out;
}

static std::string sha256_hex(std::string_view data) {
	if (data.empty()) {
		return {};
	}
	unsigned char hash[EVP_MAX_MD_SIZE];
	unsigned int hash_len = 0;
	EVP_MD_CTX* ctx = EVP_MD_CTX_new();
	if (!ctx) return {};
	if (EVP_DigestInit_ex(ctx, EVP_sha256(), nullptr) != 1) {
		EVP_MD_CTX_free(ctx);
		return {};
	}
	if (!data.empty()) {
		EVP_DigestUpdate(ctx, data.data(), data.size());
	}
	EVP_DigestFinal_ex(ctx, hash, &hash_len);
	EVP_MD_CTX_free(ctx);
	return to_hex(hash, hash_len);
}

static std::string hmac_sha256_hex(std::string_view key, std::string_view data) {
	unsigned char hash[EVP_MAX_MD_SIZE];
	unsigned int hash_len = 0;
	HMAC(EVP_sha256(), key.data(), s_cast<int>(key.size()), r_cast<const unsigned char*>(data.data()), data.size(), hash, &hash_len);
	return to_hex(hash, hash_len);
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
		query += httplib::encode_uri(params[i].first);
		query += '=';
		query += httplib::encode_uri(params[i].second);
	}
	return query;
}

static std::string canonicalize_path(const std::string& path, const httplib::Params& params) {
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
			auto name = httplib::decode_uri(part.substr(0, eq));
			auto value = httplib::decode_uri(part.substr(eq + 1));
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
		explicit Connection(httplib::ws::WebSocket* ws)
			: webSocket(ws) { }
		httplib::ws::WebSocket* webSocket = nullptr;
		std::mutex lock;
	};
	using ConnectionPtr = std::shared_ptr<Connection>;
	using ConnectionSet = std::set<ConnectionPtr>;

public:
	explicit WebSocketServer(HttpServer* owner)
		: _thread(SharedAsyncThread.newThread())
		, _owner(owner) { }

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
			if (connection->webSocket && connection->webSocket->is_open()) {
				if (!connection->webSocket->send(msg.data(), msg.size())) {
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
		try {
			_server.WebSocket(".*", [this](const httplib::Request& req, httplib::ws::WebSocket& ws) {
				auto resource = req.target.empty() ? req.path : req.target;
				if (_owner && _owner->_authRequired && !_owner->isWebSocketAuthorized(resource)) {
					ws.close(httplib::ws::CloseStatus::PolicyViolation, "unauthorized"s);
					return;
				}
				auto connection = std::make_shared<Connection>(&ws);
				{
					std::lock_guard<std::mutex> guard(_connectionLock);
					_connections.insert(connection);
				}
				SharedApplication.invokeInLogic([]() {
					Event::send("AppWS"sv, makeAppWSMessage("Open"_slice));
				});
				std::string msg;
				httplib::ws::ReadResult ret;
				while ((ret = ws.read(msg))) {
					if (ret == httplib::ws::Binary) {
						auto message = std::make_shared<std::string>(std::move(msg));
						SharedApplication.invokeInLogic([message = std::move(message)]() {
							Event::send("AppWS"sv, makeAppWSMessage("Receive"_slice, std::move(*message)));
						});
					}
				}
				{
					std::lock_guard<std::mutex> guard(connection->lock);
					connection->webSocket = nullptr;
				}
				{
					std::lock_guard<std::mutex> guard(_connectionLock);
					_connections.erase(connection);
				}
				SharedApplication.invokeInLogic([]() {
					Event::send("AppWS"sv, makeAppWSMessage("Close"_slice));
				});
			});
			if (!_server.bind_to_port("0.0.0.0", port)) {
				Error("failed to bind websocket server port {}!", port);
				return false;
			}
			{
				std::lock_guard<std::mutex> guard(_shutdownLock);
				_stopped = false;
			}
			_thread->run([this]() {
				if (!_server.listen_after_bind()) {
					Error("websocket server failed to start");
				}
				{
					std::lock_guard<std::mutex> guard(_shutdownLock);
					_stopped = true;
				}
				_waitForShutdown.notify_all();
			});
			LogHandler += std::make_pair(this, &WebSocketServer::sendLog);
			return true;
		} catch (const std::exception& e) {
			Error("failed to start websocket server! {}", e.what());
			return false;
		}
	}

	void stop() {
		bool needStop = false;
		{
			std::lock_guard<std::mutex> guard(_shutdownLock);
			needStop = !_stopped;
		}
		if (needStop) {
			auto connections = snapshotConnections();
			for (const auto& connection : connections) {
				if (!connection) continue;
				std::lock_guard<std::mutex> guard(connection->lock);
				if (connection->webSocket && connection->webSocket->is_open()) {
					connection->webSocket->close(httplib::ws::CloseStatus::GoingAway, "shutting down"s);
				}
			}
			_server.stop();
			std::unique_lock<std::mutex> lock(_shutdownLock);
			_waitForShutdown.wait(lock, [this]() {
				return _stopped;
			});
		}
		LogHandler -= std::make_pair(this, &WebSocketServer::sendLog);
	}

private:
	std::vector<ConnectionPtr> snapshotConnections() const {
		std::vector<ConnectionPtr> connections;
		std::lock_guard<std::mutex> guard(_connectionLock);
		connections.reserve(_connections.size());
		for (const auto& connection : _connections) {
			connections.push_back(connection);
		}
		return connections;
	}

private:
	Async* _thread;
	HttpServer* _owner;
	httplib::Server _server;
	ConnectionSet _connections;
	mutable std::mutex _connectionLock;
	mutable std::mutex _shutdownLock;
	std::condition_variable _waitForShutdown;
	bool _stopped = true;
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

static httplib::Server& getServer() {
	static httplib::Server server;
	return server;
}

static bool has_valid_auth(const httplib::Request& req, const std::string& token) {
	auto it = req.headers.find("X-Dora-Auth"s);
	if (it != req.headers.end() && it->second == token) {
		return true;
	}
	it = req.headers.find("Authorization"s);
	if (it != req.headers.end()) {
		const std::string& auth = it->second;
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
	for (const auto& param : req.params) {
		if (param.first == "auth"s && param.second == token) {
			return true;
		}
	}
	return false;
}

static void set_unauthorized(httplib::Response& res) {
	res.status = 401;
	res.set_content(R"({"success":false,"message":"unauthorized"})"s, "application/json"s);
}

HttpServer::HttpServer()
	: _thread(SharedAsyncThread.newThread())
	, _authRequired(false)
	, _authTokenHasExpiry(false) { }

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

bool HttpServer::isAuthorized(const httplib::Request& req) {
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
		auto sessionIt = req.headers.find("X-Dora-Session"s);
		auto timestampIt = req.headers.find("X-Dora-Timestamp"s);
		auto nonceIt = req.headers.find("X-Dora-Nonce"s);
		auto signatureIt = req.headers.find("X-Dora-Signature"s);
		if (sessionIt == req.headers.end() || timestampIt == req.headers.end() || nonceIt == req.headers.end() || signatureIt == req.headers.end()) {
			return false;
		}
		const auto& sessionId = sessionIt->second;
		if (sessionId != _authSessionId) {
			return false;
		}
		long long timestamp = 0;
		try {
			timestamp = std::stoll(timestampIt->second);
		} catch (...) {
			return false;
		}
		auto now = std::chrono::system_clock::now();
		auto nowSeconds = std::chrono::duration_cast<std::chrono::seconds>(now.time_since_epoch()).count();
		if (std::llabs(nowSeconds - timestamp) > AuthSignatureTTLSeconds) {
			return false;
		}
		const auto& nonce = nonceIt->second;
		auto path = canonicalize_path(req.path, req.params);
		auto bodyHash = sha256_hex(req.body);
		auto payload = fmt::format("{}\n{}\n{}\n{}\n{}\n{}", sessionId, req.method, path, timestampIt->second, nonce, bodyHash);
		auto expected = hmac_sha256_hex(_authSessionSecret, payload);
		if (expected != signatureIt->second) {
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

bool HttpServer::start(int port) {
	auto& server = getServer();
	if (server.is_running()) return false;
	server.set_default_headers({{"Access-Control-Allow-Origin"s, "*"s},
		{"Access-Control-Allow-Headers"s, "*"s}});
	server.set_file_request_handler([this](const httplib::Request& req, httplib::Response& res) {
		std::string path = req.path;
		if (!httplib::detail::is_valid_path(path)) {
			return false;
		}
		if (path.back() == '/') {
			path += "index.html";
		}
		if (path.size() > 0 && path[0] == '/') {
			path.erase(path.begin());
		}
		if (!SharedContent.exist(path)) {
			bool found = false;
			if (!_wwwPath.empty()) {
				auto checkPath = Path::concat({_wwwPath, path});
				if (SharedContent.exist(checkPath)) {
					path = checkPath;
					found = true;
				}
			}
			if (!found) {
				auto checkPath = Path::concat({SharedContent.getWritablePath(), path});
				if (SharedContent.exist(checkPath)) {
					path = checkPath;
					found = true;
				}
			}
			if (!found) {
				return false;
			}
		}
		auto content_type = httplib::detail::find_content_type(path, {}, "application/octet-stream"s);
		bx::Semaphore waitForLoaded;
		std::string result;
		SharedContent.getThread()->run([&]() {
			result = SharedContent.loadUnsafe(path);
			waitForLoaded.post();
		});
		waitForLoaded.wait();
		if (!result.empty()) {
			res.set_header("Content-Type", content_type);
			res.body = std::move(result);
			return true;
		}
		return false;
	});
	server.Options(".*", [](const httplib::Request& req, httplib::Response& res) { });
	bool success = server.bind_to_port("0.0.0.0", port);
	if (success) {
		for (const auto& get : _gets) {
			server.Get(get.pattern, [this, &get](const httplib::Request& req, httplib::Response& res) {
				HttpServer::Request request;
				request.headers.reserve(req.headers.size() * 2);
				for (const auto& header : req.headers) {
					request.headers.emplace_back(header.first);
					request.headers.emplace_back(header.second);
				}
				request.params.reserve(req.params.size() * 2);
				for (const auto& param : req.params) {
					request.params.emplace_back(param.first);
					request.params.emplace_back(param.second);
				}
				if (auto it = req.headers.find("Content-Type"s);
					it != req.headers.end()) {
					request.contentType = it->second;
				}
				HttpServer::Response response;
				bx::Semaphore waitForResponse;
				SharedApplication.invokeInLogic([&]() {
					response = get.handler(request);
					waitForResponse.post();
				});
				waitForResponse.wait();
				res.set_content(response.content, response.contentType);
				res.status = response.status;
			});
		}
		for (const auto& post : _posts) {
			server.Post(post.pattern, [this, &post](const httplib::Request& req, httplib::Response& res) {
				if (req.path != "/auth"sv && req.path != "/auth/confirm"sv && !isAuthorized(req)) {
					set_unauthorized(res);
					return;
				}
				HttpServer::Request request;
				request.headers.reserve(req.headers.size() * 2);
				for (const auto& header : req.headers) {
					request.headers.emplace_back(header.first);
					request.headers.emplace_back(header.second);
				}
				request.params.reserve(req.params.size() * 2);
				for (const auto& param : req.params) {
					request.params.emplace_back(param.first);
					request.params.emplace_back(param.second);
				}
				if (auto it = req.headers.find("Content-Type"s);
					it != req.headers.end()) {
					request.contentType = it->second;
				}
				request.body = req.body;
				HttpServer::Response response;
				bx::Semaphore waitForResponse;
				SharedApplication.invokeInLogic([&]() {
					response = post.handler(request);
					waitForResponse.post();
				});
				waitForResponse.wait();
				res.set_content(response.content, response.contentType);
				res.status = response.status;
			});
		}
		for (const auto& post : _postScheduled) {
			server.Post(post.pattern, [this, &post](const httplib::Request& req, httplib::Response& res) {
				if (req.path != "/auth"sv && req.path != "/auth/confirm"sv && !isAuthorized(req)) {
					set_unauthorized(res);
					return;
				}
				HttpServer::Request request;
				request.headers.reserve(req.headers.size() * 2);
				for (const auto& header : req.headers) {
					request.headers.emplace_back(header.first);
					request.headers.emplace_back(header.second);
				}
				request.params.reserve(req.params.size() * 2);
				for (const auto& param : req.params) {
					request.params.emplace_back(param.first);
					request.params.emplace_back(param.second);
				}
				if (auto it = req.headers.find("Content-Type"s);
					it != req.headers.end()) {
					request.contentType = it->second;
				}
				request.body = req.body;
				HttpServer::Response response;
				bx::Semaphore waitForResponse;
				SharedApplication.invokeInLogic([&]() {
					auto scheduleFunc = post.handler(request);
					SharedDirector.getSystemScheduler()->schedule([scheduleFunc, &response, &waitForResponse](double) {
						auto fRes = scheduleFunc();
						if (fRes) {
							response = std::move(fRes.value());
							waitForResponse.post();
							return true;
						}
						return false;
					});
				});
				waitForResponse.wait();
				res.set_content(response.content, response.contentType);
				res.status = response.status;
			});
		}
		for (const auto& postFile : _files) {
			server.Post(postFile.pattern,
				[&](const httplib::Request& req, httplib::Response& res, const httplib::ContentReader& content_reader) {
					if (req.path != "/auth"sv && req.path != "/auth/confirm"sv && !isAuthorized(req)) {
						set_unauthorized(res);
						return;
					}
					if (!req.is_multipart_form_data()) {
						res.status = 403;
						return;
					}
					HttpServer::Request request;
					request.headers.reserve(req.headers.size() * 2);
					for (const auto& header : req.headers) {
						request.headers.emplace_back(header.first);
						request.headers.emplace_back(header.second);
					}
					request.params.reserve(req.params.size() * 2);
					for (const auto& param : req.params) {
						request.params.emplace_back(param.first);
						request.params.emplace_back(param.second);
					}
					if (auto it = req.headers.find("Content-Type"s);
						it != req.headers.end()) {
						request.contentType = it->second;
					}
					std::list<std::string> acceptedFiles;
					std::list<std::shared_ptr<SDL_RWops>> streams;
					content_reader(
						[&](const httplib::FormData& file) {
							bool accepted = false;
							bx::Semaphore waitForResponse;
							SharedApplication.invokeInLogic([&]() {
								if (auto newFile = postFile.acceptHandler(request, file.filename)) {
									auto fullPath = newFile.value();
									SDL_RWops* stream = SDL_RWFromFile(fullPath.c_str(), "wb+");
									if (stream) {
										streams.push_back({stream, [](SDL_RWops* io) {
															   SDL_RWclose(io);
														   }});
										accepted = true;
										acceptedFiles.emplace_back(newFile.value());
									}
								}
								waitForResponse.post();
							});
							waitForResponse.wait();
							return accepted;
						},
						[&](const char* data, size_t data_length) {
							if (!streams.empty()) {
								size_t written = SDL_RWwrite(streams.back().get(), data, 1, data_length);
								if (written == data_length) {
									return true;
								}
							}
							acceptedFiles.pop_back();
							return false;
						});
					streams.clear();
					bool done = true;
					bx::Semaphore waitForResponse;
					SharedApplication.invokeInLogic([&]() {
						for (const auto& file : acceptedFiles) {
							if (!postFile.doneHandler(request, file)) {
								SharedContent.remove(file);
								done = false;
								break;
							}
						}
						waitForResponse.post();
					});
					waitForResponse.wait();
					if (!done) {
						res.status = 500;
					}
				});
		}
		_thread->run([]() {
			if (!getServer().listen_after_bind()) {
				LogError("http server failed to start");
			}
		});
	}
	return success;
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
	getServer().stop();
	getServer().clear_posts();
	_posts.clear();
	_postScheduled.clear();
	_files.clear();

	if (_webSocketServer) {
		_webSocketServer = nullptr;
	}
	_webSocketListener = nullptr;
}

const char* HttpServer::getVersion() {
	return CPPHTTPLIB_VERSION;
}

/* HttpClient */

namespace {
std::mutex s_httpClientRequestMutex;
struct HttpRequestState {
	uint64_t id = 0;
	std::atomic_bool cancelling = false;
	std::atomic_bool finished = false;
	std::mutex clientMutex;
	std::shared_ptr<httplib::Client> client;
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

static void set_http_client_request_client(const std::shared_ptr<HttpRequestState>& request, const std::shared_ptr<httplib::Client>& client) {
	if (!request) {
		return;
	}
	std::lock_guard<std::mutex> lock(request->clientMutex);
	request->client = client;
}

static std::shared_ptr<httplib::Client> get_http_client_request_client(const std::shared_ptr<HttpRequestState>& request) {
	if (!request) {
		return nullptr;
	}
	std::lock_guard<std::mutex> lock(request->clientMutex);
	return request->client;
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

static std::pair<time_t, time_t> to_timeout_parts(float timeout) {
	if (!(timeout > 0.0f)) {
		return {0, 0};
	}
	auto duration = std::chrono::duration_cast<std::chrono::microseconds>(
		std::chrono::duration<float>(timeout));
	if (duration.count() <= 0) {
		duration = std::chrono::microseconds(1);
	}
	const auto seconds = std::chrono::duration_cast<std::chrono::seconds>(duration);
	const auto micros = std::chrono::duration_cast<std::chrono::microseconds>(duration - seconds);
	return {
		s_cast<time_t>(seconds.count()),
		s_cast<time_t>(micros.count())};
}

static void configure_http_client(const std::shared_ptr<httplib::Client>& client, float timeout) {
	if (!client) {
		return;
	}
	client->enable_server_certificate_verification(false);
	client->set_follow_location(true);
	client->set_keep_alive(false);
	auto [timeoutSec, timeoutUsec] = to_timeout_parts(timeout);
	client->set_connection_timeout(timeoutSec, timeoutUsec);
	client->set_read_timeout(timeoutSec, timeoutUsec);
	client->set_write_timeout(timeoutSec, timeoutUsec);
	client->set_max_timeout(0);
}

static void prepare_http_request_headers(httplib::Headers& headers) {
	headers.emplace("Connection"s, "close"s);
}
} // namespace

HttpClient::HttpClient()
	: _downloadThread(nullptr)
	, _stopped(false) {
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
	auto client = get_http_client_request_client(request);
	if (!client) {
		return true;
	}
	SharedAsyncThread.run([request, client]() {
		if (!request->finished.load(std::memory_order_relaxed)) {
			client->stop();
		}
	});
	return true;
}

bool HttpClient::isRequestActive(RequestId requestId) const {
	auto request = get_http_client_request(requestId);
	return request && !request->finished.load(std::memory_order_relaxed);
}

static std::optional<std::pair<std::string, std::string>> getURLParts(String url) {
	static std::regex urlRegex(
		R"(^(([^:\/?#]+):)?(//([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?)",
		std::regex::extended);
	std::smatch matchResult;
	auto urlStr = url.toString();
	std::string schemeHostPort, pathToGet;
	if (std::regex_match(urlStr, matchResult, urlRegex)) {
		std::string scheme = matchResult[2];
		std::string authority = matchResult[4];
		std::string path = matchResult[5];
		std::string query = matchResult[7];
		std::string fragment = matchResult[9];
		if (scheme.empty()) {
			Error("url scheme is missing for \"{}\"", urlStr);
			return std::nullopt;
		}
		if (authority.empty()) {
			Error("url authority is missing for \"{}\"", urlStr);
			return std::nullopt;
		}
		schemeHostPort = scheme + "://"s + authority;
		pathToGet = path;
		if (!query.empty()) {
			pathToGet += '?' + query;
		}
		if (!fragment.empty()) {
			pathToGet += '#' + fragment;
		}
		return std::make_pair(schemeHostPort, pathToGet);
	} else {
		Error("got malformed url \"{}\"", urlStr);
		return std::nullopt;
	}
}

HttpClient::RequestId HttpClient::postAsync(String url, std::span<Slice> headers, String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback) {
	if (_stopped.load(std::memory_order_relaxed)) {
		callback(std::nullopt);
		return 0;
	}
	auto parts = getURLParts(url);
	std::string schemeHostPort, pathToGet;
	if (parts) {
		schemeHostPort = parts->first;
		pathToGet = parts->second;
	} else {
		callback(std::nullopt);
		return 0;
	}
	auto request = register_http_client_request();
	if (!request) {
		callback(std::nullopt);
		return 0;
	}
	httplib::Headers postHeaders;
	for (const auto& header : headers) {
		auto parts = header.split(":"sv);
		if (parts.size() == 2) {
			postHeaders.emplace(parts.front(), parts.back());
		}
	}
	auto callbackFunc = std::make_shared<ContentHandler>(callback);
	auto partCallbackFunc = std::make_shared<ContentPartHandler>(partCallback);
	SharedAsyncThread.run([request, schemeHostPort, json = json.toString(), timeout, urlStr = url.toString(), partCallbackFunc, callbackFunc, pathToGet, headers = std::move(postHeaders)]() {
		try {
			auto client = std::make_shared<httplib::Client>(schemeHostPort);
			set_http_client_request_client(request, client);
			if (request->cancelling.load(std::memory_order_relaxed)) {
				client->stop();
				SharedApplication.invokeInLogic([callbackFunc]() {
					(*callbackFunc)(std::nullopt);
				});
				unregister_http_client_request(request);
				return nullptr;
			}
			configure_http_client(client, timeout);
			httplib::Request req;
			req.method = "POST";
			req.headers = headers;
			prepare_http_request_headers(req.headers);
			req.path = pathToGet;
			req.set_header("Content-Type"s, "application/json"s);
			if (timeout > 0) {
				req.start_time_ = std::chrono::steady_clock::now();
			}
			if (*partCallbackFunc) {
				req.content_receiver = [request, partCallbackFunc, stopped = std::make_shared<std::atomic<bool>>(false)](const char* data, size_t data_length, uint64_t offset, uint64_t total_length) -> bool {
					DORA_UNUSED_PARAM(offset);
					DORA_UNUSED_PARAM(total_length);
					if (request->cancelling.load(std::memory_order_relaxed)) {
						return false;
					}
					SharedApplication.invokeInLogic([request, partCallbackFunc, part = std::string(data, data_length), stopped]() {
						if (!*stopped) {
							*stopped = (*partCallbackFunc)(part);
						}
						if (*stopped) {
							request->cancelling.store(true, std::memory_order_relaxed);
							if (auto activeClient = get_http_client_request_client(request)) {
								activeClient->stop();
							}
						}
					});
					return true;
				};
			}
			req.body = std::move(json);
			auto result = client->send(req);
			if (!result || result.error() != httplib::Error::Success) {
				Info("failed to do HTTP POST \"{}\" due to {}", urlStr, httplib::to_string(result.error()));
				SharedApplication.invokeInLogic([callbackFunc]() {
					(*callbackFunc)(std::nullopt);
				});
			} else {
				SharedApplication.invokeInLogic([callbackFunc, body = std::move(result.value().body)]() {
					(*callbackFunc)(body);
				});
			}
		} catch (const std::invalid_argument& ex) {
			Error("invalid url \"{}\" to do HTTP POST due to: {}", urlStr, ex.what());
			SharedApplication.invokeInLogic([callbackFunc]() {
				(*callbackFunc)(Slice::Empty);
			});
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
	auto parts = getURLParts(url);
	std::string schemeHostPort, pathToGet;
	if (parts) {
		schemeHostPort = parts->first;
		pathToGet = parts->second;
	} else {
		callback(std::nullopt);
		return 0;
	}
	auto request = register_http_client_request();
	if (!request) {
		callback(std::nullopt);
		return 0;
	}
	SharedAsyncThread.run([request, schemeHostPort, timeout, urlStr = url.toString(), callback, pathToGet]() {
		try {
			auto client = std::make_shared<httplib::Client>(schemeHostPort);
			set_http_client_request_client(request, client);
			if (request->cancelling.load(std::memory_order_relaxed)) {
				client->stop();
				SharedApplication.invokeInLogic([callback]() {
					callback(std::nullopt);
				});
				unregister_http_client_request(request);
				return;
			}
			configure_http_client(client, timeout);
			httplib::Headers headers;
			prepare_http_request_headers(headers);
			auto result = client->Get(pathToGet, headers);
			if (!result || result.error() != httplib::Error::Success) {
				Info("failed to do HTTP GET \"{}\" due to {}", urlStr, httplib::to_string(result.error()));
				SharedApplication.invokeInLogic([callback]() {
					callback(std::nullopt);
				});
			} else {
				SharedApplication.invokeInLogic([callback, body = std::move(result.value().body)]() {
					callback(body);
				});
			}
		} catch (const std::invalid_argument& ex) {
			Error("invalid url \"{}\" to do HTTP GET due to: {}", urlStr, ex.what());
			SharedApplication.invokeInLogic([callback]() {
				callback(std::nullopt);
			});
		}
		unregister_http_client_request(request);
	});
	return request->id;
}

HttpClient::RequestId HttpClient::downloadAsync(String url, String filePath, float timeout, const std::function<bool(bool interrupted, uint64_t current, uint64_t total)>& progress) {
	if (_stopped.load(std::memory_order_relaxed)) {
		progress(true, 0, 0);
		return 0;
	}
	if (!_downloadThread) {
		_downloadThread = SharedAsyncThread.newThread();
	}
	auto parts = getURLParts(url);
	std::string schemeHostPort, pathToGet;
	if (parts) {
		schemeHostPort = parts->first;
		pathToGet = parts->second;
	} else {
		progress(true, 0, 0);
		return 0;
	}
	auto request = register_http_client_request();
	if (!request) {
		progress(true, 0, 0);
		return 0;
	}
	auto progressFunc = std::make_shared<std::function<bool(bool interrupted, uint64_t current, uint64_t total)>>(progress);
	_downloadThread->run([request, schemeHostPort, fileStr = filePath.toString(), urlStr = url.toString(), timeout, progressFunc, pathToGet]() -> Own<Values> {
		try {
			auto client = std::make_shared<httplib::Client>(schemeHostPort);
			set_http_client_request_client(request, client);
			if (request->cancelling.load(std::memory_order_relaxed)) {
				client->stop();
				SharedApplication.invokeInLogic([progressFunc]() {
					(*progressFunc)(true, 0, 0);
				});
				unregister_http_client_request(request);
				return nullptr;
			}
			configure_http_client(client, timeout);
			auto fullname = fileStr;
			SDL_RWops* out = SDL_RWFromFile(fullname.c_str(), "wb+");
			if (!out) {
				Error("invalid local file path \"{}\" to download to", fileStr);
				unregister_http_client_request(request);
				return nullptr;
			}
			auto stream = std::shared_ptr<SDL_RWops>{out, [](SDL_RWops* io) {
														 SDL_RWclose(io);
													 }};
			httplib::Headers headers;
			prepare_http_request_headers(headers);
			auto result = client->Get(
				pathToGet, headers, [request, &out, progressFunc, fileStr, urlStr](const char* data, size_t data_length) -> bool {
					if (SharedHttpClient.isStopped() || request->cancelling.load(std::memory_order_relaxed)) {
						return false;
					}
					size_t written = SDL_RWwrite(out, data, 1, data_length);
					if (written != data_length) {
						Error("failed to write downloaded file for \"{}\"", urlStr);
						SharedApplication.invokeInLogic([progressFunc]() {
							(*progressFunc)(true, 0, 0);
						});
						std::error_code err;
						fs::remove_all(fileStr, err);
						WarnIf(err, "failed to remove download file \"{}\" due to \"{}\".", fileStr, err.message());
						return false;
					}
					return true;
				},
				[request, progressFunc, stream, stopped = std::make_shared<std::atomic<bool>>(false)](uint64_t current, uint64_t total) -> bool {
					if (request->cancelling.load(std::memory_order_relaxed)) {
						return false;
					}
					SharedApplication.invokeInLogic([request, progressFunc, current, total, stopped]() {
						if (!*stopped) {
							*stopped = (*progressFunc)(false, current, total);
						}
						if (*stopped) {
							request->cancelling.store(true, std::memory_order_relaxed);
							if (auto activeClient = get_http_client_request_client(request)) {
								activeClient->stop();
							}
						}
					});
					return true;
				});
			if (!result || result.error() != httplib::Error::Success) {
				Info("failed to download \"{}\" due to {}", urlStr, httplib::to_string(result.error()));
				SharedApplication.invokeInLogic([progressFunc]() {
					(*progressFunc)(true, 0, 0);
				});
				std::error_code err;
				if (fs::exists(fileStr, err)) {
					fs::remove_all(fileStr, err);
					WarnIf(err, "failed to remove download file \"{}\" due to \"{}\".", fileStr, err.message());
				}
			}
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
		return nullptr;
	},
		[progressFunc](Own<Values>) {
		});
	return request->id;
}

void HttpClient::stop() {
	_stopped.store(true, std::memory_order_relaxed);
	auto requests = snapshot_http_client_requests();
	for (const auto& request : requests) {
		if (request) {
			request->cancelling.store(true, std::memory_order_relaxed);
			if (auto client = get_http_client_request_client(request)) {
				client->stop();
			}
		}
	}
}

NS_DORA_END
