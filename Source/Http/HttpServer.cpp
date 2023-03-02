/* Copyright (c) 2023 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Http/HttpServer.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Common/Async.h"

#include "httplib/httplib.h"

NS_DOROTHY_BEGIN

static httplib::Server& getServer() {
	static httplib::Server server;
	return server;
}

HttpServer::~HttpServer() {
	getServer().stop();
}

void HttpServer::setWWWPath(String var) {
	_wwwPath = var;
}

const std::string& HttpServer::getWWWPath() const {
	return _wwwPath;
}

void HttpServer::post(String pattern, const PostHandler& handler) {
	_posts.push_back({pattern, handler});
}

void HttpServer::upload(String pattern, const FileAcceptHandler& acceptHandler, const FileDoneHandler& doneHandler) {
	_files.push_back({pattern, acceptHandler, doneHandler});
}

bool HttpServer::start(int port) {
	auto& server = getServer();
	if (server.is_running()) return false;
	server.set_default_headers({
		{"Access-Control-Allow-Origin"s, "*"s},
		{"Access-Control-Allow-Headers"s, "*"s}
	});
	server.Options(".*", [](const httplib::Request& req, httplib::Response& res) { });
	bool success = server.bind_to_port("localhost", port);
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
				response.status = res.status;
				bx::Semaphore waitForResponse;
				SharedApplication.invokeInLogic([&]() {
					response = post.handler(request);
					waitForResponse.post();
				});
				waitForResponse.wait();
				res.set_content(response.content, response.contentType);
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
					}
				);
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
		SharedAsyncThread.HttpServer.run([]() {
			getServer().listen_after_bind();
		});
	}
	return success;
}

void HttpServer::stop() {
	getServer().stop();
	getServer().clear_posts();
	_posts.clear();
}

NS_DOROTHY_END
