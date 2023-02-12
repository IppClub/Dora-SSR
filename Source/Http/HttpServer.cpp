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

bool HttpServer::start(int port) {
	auto& server = getServer();
	if (server.is_running()) return false;
	bool success = server.bind_to_port("localhost", port);
	if (success) {
		if (!_wwwPath.empty()) {
			server.set_mount_point("/", _wwwPath);
		}
		server.set_mount_point("/", SharedContent.getWritablePath());
		for (const auto& post : _posts) {
			server.Post(post.pattern, [this, &post](const httplib::Request& req, httplib::Response& res) {
				auto request = std::make_shared<HttpServer::Request>();
				for (const auto& param : req.params) {
					request->params.emplace_back(param.first);
					request->params.emplace_back(param.second);
				}
				if (auto it = req.headers.find("Content-Type"s);
					it != req.headers.end()) {
					request->contentType = it->second;
				}
				request->body = req.body;
				HttpServer::Response response;
				response.status = res.status;
				bx::Semaphore waitForResponse;
				SharedApplication.invokeInLogic([&, request = std::move(request)]() {
					response = post.handler(*request);
					waitForResponse.post();
				});
				waitForResponse.wait();
				res.set_content(response.content, response.contentType);
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
