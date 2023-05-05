/* Copyright (c) 2023 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Async;

class HttpServer {
public:
	virtual ~HttpServer();
	PROPERTY_STRING(WWWPath);
	PROPERTY_READONLY(std::string, LocalIP);
	struct Request {
		std::list<Slice> params;
		Slice contentType;
		Slice body;
	};
	struct Response {
		Response(int status = -1)
			: status(status) { }
		Response(Response&& res);
		void operator=(Response&& res);
		std::string content;
		std::string contentType;
		int status;
	};

	using PostHandler = std::function<Response(const Request&)>;
	struct Post {
		std::string pattern;
		PostHandler handler;
	};
	void post(String pattern, const PostHandler& handler);

	using PostScheduledFunc = std::function<std::optional<Response>()>;
	using PostScheduledHandler = std::function<PostScheduledFunc(const Request&)>;
	struct PostScheduled {
		std::string pattern;
		PostScheduledHandler handler;
	};
	void postSchedule(String pattern, const PostScheduledHandler& handler);

	using FileAcceptHandler = std::function<std::optional<std::string>(const Request&, const std::string&)>;
	using FileDoneHandler = std::function<bool(const Request&, const std::string&)>;
	struct File {
		std::string pattern;
		FileAcceptHandler acceptHandler;
		FileDoneHandler doneHandler;
	};

	void upload(String pattern, const FileAcceptHandler& acceptHandler, const FileDoneHandler& doneHandler);
	bool start(int port);
	void stop();

protected:
	HttpServer();

private:
	std::string _wwwPath;
	std::list<Post> _posts;
	std::list<PostScheduled> _postScheduled;
	std::list<File> _files;
	Async* _thread;
	SINGLETON_REF(HttpServer, AsyncThread, Director);
};

#define SharedHttpServer \
	Dorothy::Singleton<Dorothy::HttpServer>::shared()

NS_DOROTHY_END
