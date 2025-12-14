/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

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

#define CPPHTTPLIB_OPENSSL_SUPPORT
#define CPPHTTPLIB_ZLIB_SUPPORT
#include "httplib/httplib.h"

#define ASIO_STANDALONE
#include "asio.hpp"

#include "websocketpp/config/asio_no_tls.hpp"

#include "websocketpp/server.hpp"

#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"

#include "yuescript/parser.hpp"

namespace ws = websocketpp;
namespace wsl = websocketpp::lib;

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

#include <atomic>

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

class WebSocketServer {
	using Server = websocketpp::server<websocketpp::config::asio>;
	using ConnectionSet = std::set<ws::connection_hdl, std::owner_less<ws::connection_hdl>>;

public:
	WebSocketServer()
		: _thread(SharedAsyncThread.newThread()) { }

	~WebSocketServer() {
		stop();
	}

	int getConnectionCount() const {
		return s_cast<int>(_connections.size());
	}

	bool init() {
		try {
			_server.set_access_channels(ws::log::alevel::none);
			_server.set_error_channels(ws::log::elevel::none);
			_server.init_asio();
		} catch (const std::exception& e) {
			Error("failed to init asio! {}", e.what());
			return false;
		}
		return true;
	}

	void send(const std::string& msg) {
		wsl::lock_guard<wsl::mutex> guard(_connectionLock);
		wsl::error_code ec;
		for (const auto& hdl : _connections) {
			_server.send(hdl, msg, ws::frame::opcode::BINARY, ec);
			if (ec) {
				Error("failed to send message to websocket connection! {}", ec.message());
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
		Event::send("AppWS"sv, "Send"s, std::string{buf.GetString(), buf.GetLength()});
	}

	bool start(int port) {
		try {
			_server.set_message_handler([this](ws::connection_hdl hdl, Server::message_ptr msg) {
				if (ws::frame::opcode::BINARY == msg->get_opcode()) {
					auto message = std::make_shared<std::string>(msg->get_payload());
					SharedApplication.invokeInLogic([message = std::move(message)]() {
						Event::send("AppWS"sv, "Receive"s, std::move(*message));
					});
				}
			});
			_server.set_open_handler([this](ws::connection_hdl hdl) {
				{
					wsl::lock_guard<wsl::mutex> guard(_connectionLock);
					_connections.insert(hdl);
				}
				SharedApplication.invokeInLogic([]() {
					Event::send("AppWS"sv, "Open"s, Slice::Empty);
				});
			});
			_server.set_close_handler([this](ws::connection_hdl hdl) {
				{
					wsl::lock_guard<wsl::mutex> guard(_connectionLock);
					_connections.erase(hdl);
				}
				SharedApplication.invokeInLogic([]() {
					Event::send("AppWS"sv, "Close"s, Slice::Empty);
				});
			});
			_server.set_reuse_addr(true);
			_server.listen(port);
			_server.start_accept();
			_thread->run([this]() {
				_server.run();
				_waitForShutdown.notify_all();
			});
			LogHandler += std::make_pair(this, &WebSocketServer::sendLog);
			return true;
		} catch (const websocketpp::exception& e) {
			Error("failed to start websocket server! {}", e.what());
			return false;
		} catch (const std::exception& e) {
			Error("unexpected exception from websocket! {}", e.what());
			return false;
		}
	}

	void stop() {
		if (_server.is_listening()) {
			wsl::unique_lock<wsl::mutex> lock(_shutdownLock);
			wsl::error_code ec;
			_server.stop_listening(ec);
			if (ec) {
				Error("failed to stop websocket listening! {}", ec.message());
			}
			{
				wsl::lock_guard<wsl::mutex> guard(_connectionLock);
				for (auto hdl : _connections) {
					if (!hdl.expired()) {
						_server.close(hdl, websocketpp::close::status::going_away, "shutting down"s, ec);
						if (ec) {
							Error("failed to close websocket connection! {}", ec.message());
						}
					}
				}
				_connections.clear();
			}
			_waitForShutdown.wait(lock);
		}
		LogHandler -= std::make_pair(this, &WebSocketServer::sendLog);
	}

private:
	Async* _thread;
	Server _server;
	ConnectionSet _connections;
	wsl::mutex _connectionLock;
	wsl::mutex _shutdownLock;
	wsl::condition_variable _waitForShutdown;
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

HttpServer::HttpServer()
	: _thread(SharedAsyncThread.newThread()) { }

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

void HttpServer::post(String pattern, const PostHandler& handler) {
	_posts.push_back({pattern.toString(), handler});
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
		OwnArray<uint8_t> data;
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
		for (const auto& post : _posts) {
			server.Post(post.pattern, [this, &post](const httplib::Request& req, httplib::Response& res) {
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
										streams.push_back({stream, [](SDL_RWops* io) { SDL_RWclose(io); }});
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
	_webSocketServer = New<WebSocketServer>();
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
			std::string eventType;
			std::string msg;
			if (event->get(eventType, msg)) {
				if (eventType == "Send"sv) {
					_webSocketServer->send(msg);
				}
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

HttpClient::HttpClient()
	: _requestThread(nullptr)
	, _downloadThread(nullptr)
	, _stopped(false) {
}

HttpClient::~HttpClient() {
	stop();
}

bool HttpClient::isStopped() const noexcept {
	return _stopped;
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

void HttpClient::postAsync(String url, std::span<Slice> headers, String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback) {
	if (_stopped) {
		callback(std::nullopt);
		return;
	}
	if (!_requestThread) {
		_requestThread = SharedAsyncThread.newThread();
	}
	auto parts = getURLParts(url);
	std::string schemeHostPort, pathToGet;
	if (parts) {
		schemeHostPort = parts->first;
		pathToGet = parts->second;
	} else {
		callback(std::nullopt);
		return;
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
	_requestThread->run([schemeHostPort, json = json.toString(), timeout, urlStr = url.toString(), partCallbackFunc, callbackFunc, pathToGet, headers = std::move(postHeaders)]() {
		try {
			httplib::Client client(schemeHostPort);
			client.enable_server_certificate_verification(false);
			client.set_follow_location(true);
			client.set_connection_timeout(timeout);
			httplib::Request req;
			req.method = "POST";
			req.headers = headers;
			req.path = pathToGet;
			req.set_header("Content-Type"s, "application/json"s);
			if (timeout > 0) {
				req.start_time_ = std::chrono::steady_clock::now();
			}
			if (*partCallbackFunc) {
				req.content_receiver = [partCallbackFunc, stopped = std::make_shared<std::atomic<bool>>(false)](const char* data, size_t data_length, uint64_t offset, uint64_t total_length) -> bool {
					SharedApplication.invokeInLogic([partCallbackFunc, part = std::string(data, data_length), stopped]() {
						if (!*stopped) {
							*stopped = (*partCallbackFunc)(part);
						}
					});
					if (*stopped) {
						return false;
					}
					return true;
				};
			}
			req.body = std::move(json);
			auto result = client.send(req);
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
		return nullptr;
	},
		[partCallbackFunc, callbackFunc](Own<Values>) {
		});
}

void HttpClient::postAsync(String url, const std::vector<std::string>& headers, String json, float timeout, const ContentHandler& callback) {
	postAsync(url, headers, json, timeout, nullptr, callback);
}

void HttpClient::postAsync(String url, const std::vector<std::string>& headers, String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback) {
	std::vector<Slice> headerArray(headers.size());
	for (size_t i = 0; i < headers.size(); i++) {
		headerArray[i] = headers[i];
	}
	postAsync(url, headerArray, json, timeout, nullptr, callback);
}

void HttpClient::postAsync(String url, Slice headers[], int count, String json, float timeout, const ContentHandler& callback) {
	std::vector<Slice> headerArray(count);
	for (int i = 0; i < count; i++) {
		headerArray[i] = headers[i];
	}
	postAsync(url, headerArray, json, timeout, nullptr, callback);
}

void HttpClient::postAsync(String url, String json, float timeout, const ContentHandler& callback) {
	postAsync(url, nullptr, 0, json, timeout, callback);
}

void HttpClient::postAsync(String url, Slice headers[], int count, String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback) {
	std::vector<Slice> headerArray(count);
	for (int i = 0; i < count; i++) {
		headerArray[i] = headers[i];
	}
	postAsync(url, headerArray, json, timeout, partCallback, callback);
}

void HttpClient::getAsync(String url, float timeout, const ContentHandler& callback) {
	if (_stopped) {
		callback(std::nullopt);
		return;
	}
	if (!_requestThread) {
		_requestThread = SharedAsyncThread.newThread();
	}
	auto parts = getURLParts(url);
	std::string schemeHostPort, pathToGet;
	if (parts) {
		schemeHostPort = parts->first;
		pathToGet = parts->second;
	} else {
		callback(std::nullopt);
		return;
	}
	_requestThread->run([schemeHostPort, timeout, urlStr = url.toString(), callback, pathToGet]() {
		try {
			httplib::Client client(schemeHostPort);
			client.enable_server_certificate_verification(false);
			client.set_follow_location(true);
			client.set_connection_timeout(timeout);
			auto result = client.Get(pathToGet);
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
	});
}

void HttpClient::downloadAsync(String url, String filePath, float timeout, const std::function<bool(bool interrupted, uint64_t current, uint64_t total)>& progress) {
	if (_stopped) {
		progress(true, 0, 0);
		return;
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
		return;
	}
	auto progressFunc = std::make_shared<std::function<bool(bool interrupted, uint64_t current, uint64_t total)>>(progress);
	_downloadThread->run([schemeHostPort, fileStr = filePath.toString(), urlStr = url.toString(), timeout, progressFunc, pathToGet]() -> Own<Values> {
		try {
			httplib::Client client(schemeHostPort);
			client.enable_server_certificate_verification(false);
			client.set_follow_location(true);
			client.set_connection_timeout(timeout);
			auto fullname = fileStr;
			SDL_RWops* out = SDL_RWFromFile(fullname.c_str(), "wb+");
			if (!out) {
				Error("invalid local file path \"{}\" to download to", fileStr);
				return nullptr;
			}
			auto stream = std::shared_ptr<SDL_RWops>{out, [](SDL_RWops* io) { SDL_RWclose(io); }};
			auto result = client.Get(
				pathToGet, [&](const char* data, size_t data_length) -> bool {
					if (SharedHttpClient.isStopped()) {
						return false;
					} else {
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
					}
					return false;
				},
				[&, stream, stopped = std::make_shared<std::atomic<bool>>(false)](uint64_t current, uint64_t total) -> bool {
					SharedApplication.invokeInLogic([progressFunc, current, total, stopped]() {
						if (!*stopped) {
							*stopped = (*progressFunc)(false, current, total);
						}
					});
					if (*stopped) {
						return false;
					}
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
		return nullptr;
	},
		[progressFunc](Own<Values>) {
		});
}

void HttpClient::stop() {
	_stopped = true;
}

NS_DORA_END
