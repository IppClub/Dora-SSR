/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

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
			_server.send(hdl, msg, ws::frame::opcode::TEXT, ec);
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
		Event::send("AppWSSend"sv, std::string{buf.GetString(), buf.GetLength()});
	}

	bool start(int port) {
		try {
			_server.set_message_handler([this](ws::connection_hdl hdl, Server::message_ptr msg) {
				if (ws::frame::opcode::TEXT == msg->get_opcode()) {
					auto message = std::make_shared<std::string>(msg->get_payload());
					SharedApplication.invokeInLogic([message = std::move(message)]() {
						Event::send("AppWSMessage"sv, std::move(*message));
					});
				}
			});
			_server.set_open_handler([this](ws::connection_hdl hdl) {
				{
					wsl::lock_guard<wsl::mutex> guard(_connectionLock);
					_connections.insert(hdl);
				}
				SharedApplication.invokeInLogic([]() {
					Event::send("AppWSOpen"sv);
				});
			});
			_server.set_close_handler([this](ws::connection_hdl hdl) {
				{
					wsl::lock_guard<wsl::mutex> guard(_connectionLock);
					_connections.erase(hdl);
				}
				SharedApplication.invokeInLogic([]() {
					Event::send("AppWSClose"sv);
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

int HttpServer::getWSConnectionCount() const {
	if (_webSocketServer) {
		return _webSocketServer->getConnectionCount();
	}
	return 0;
}

std::string HttpServer::getLocalIP() const {
	return get_local_ip();
}

void HttpServer::setWWWPath(String var) {
	_wwwPath = var.toString();
}

const std::string& HttpServer::getWWWPath() const {
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
	server.set_file_request_handler([](const httplib::Request& req, httplib::Response& res) {
		std::string path = req.path;
		if (path.size() > 0 && path[0] == '/') {
			path.erase(path.begin());
		}
		if (httplib::detail::is_valid_path(path)) {
			if (!SharedContent.exist(path)) {
				return false;
			}
		} else {
			return false;
		}
		auto content_type = httplib::detail::find_content_type(path, {}, "application/octet-stream"s);
		OwnArray<uint8_t> data;
		size_t dataSize = 0;
		bx::Semaphore waitForLoaded;
		SharedContent.getThread()->run([&]() {
			int64_t size;
			auto result = SharedContent.loadUnsafe(path, size);
			if (size > 0) {
				data = MakeOwnArray(result);
				dataSize = s_cast<size_t>(size);
			}
			waitForLoaded.post();
		});
		waitForLoaded.wait();
		if (dataSize > 0) {
			auto sd = std::make_shared<OwnArray<uint8_t>>(std::move(data));
			res.set_chunked_content_provider(content_type, [sd = std::move(sd), dataSize](size_t, httplib::DataSink& sink) -> bool {
				sink.write(r_cast<const char*>((*sd).get()), dataSize);
				sink.done();
				return true;
			});
			return true;
		}
		return false;
	});
	server.Options(".*", [](const httplib::Request& req, httplib::Response& res) {});
	bool success = server.bind_to_port("0.0.0.0", port);
	if (success) {
		if (!_wwwPath.empty()) {
			server.set_mount_point("/", _wwwPath);
		}
		server.set_mount_point("/", SharedContent.getWritablePath());
		for (const auto& post : _posts) {
			server.Post(post.pattern, [this, &post](const httplib::Request& req, httplib::Response& res) {
				HttpServer::Request request;
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
					for (const auto& param : req.params) {
						request.params.emplace_back(param.first);
						request.params.emplace_back(param.second);
					}
					if (auto it = req.headers.find("Content-Type"s);
						it != req.headers.end()) {
						request.contentType = it->second;
					}
					std::list<std::string> acceptedFiles;
					std::list<std::ofstream> streams;
					content_reader(
						[&](const httplib::MultipartFormData& file) {
							bool accepted = false;
							bx::Semaphore waitForResponse;
							SharedApplication.invokeInLogic([&]() {
								if (auto newFile = postFile.acceptHandler(request, file.filename)) {
									auto& stream = streams.emplace_back(newFile.value(),
										std::ios::out | std::ios::trunc | std::ios::binary);
									if (stream) {
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
							if (streams.back().write(data, data_length)) {
								return true;
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
	_webSocketListener = Listener::create("AppWSSend"s, [this](Event* event) {
		if (_webSocketServer) {
			std::string msg;
			if (event->get(msg)) {
				_webSocketServer->send(msg);
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

NS_DORA_END
