/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

class WebSocketServer;
class Async;
class Listener;

class HttpServer : public NonCopyable {
public:
	virtual ~HttpServer();
	PROPERTY_STRING(WWWPath);
	PROPERTY_READONLY(std::string, LocalIP);
	PROPERTY_READONLY(int, WSConnectionCount);
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
	bool startWS(int port);
	void stop();

	static const char* getVersion();

protected:
	HttpServer();

private:
	std::string _wwwPath;
	std::list<Post> _posts;
	std::list<PostScheduled> _postScheduled;
	std::list<File> _files;
	Async* _thread;
	Own<WebSocketServer> _webSocketServer;
	Ref<Listener> _webSocketListener;
	SINGLETON_REF(HttpServer, AsyncThread, Director);
};

#define SharedHttpServer \
	Dora::Singleton<Dora::HttpServer>::shared()

class HttpClient : public NonCopyable {
public:
	using ContentPartHandler = std::function<bool(String)>;
	using ContentHandler = std::function<void(std::optional<Slice>)>;
	PROPERTY_BOOL(Stopped);
	virtual ~HttpClient();
	void stop();
	void postAsync(String url, String json, float timeout, const ContentHandler& callback);
	void postAsync(String url, std::span<Slice> headers, String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback);
	void postAsync(String url, const std::vector<std::string>& headers, String json, float timeout, const ContentHandler& callback);
	void postAsync(String url, const std::vector<std::string>& headers, String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback);
	void postAsync(String url, Slice headers[], int count, String json, float timeout, const ContentHandler& callback);
	void postAsync(String url, Slice headers[], int count, String json, float timeout, const ContentPartHandler& partCallback, const ContentHandler& callback);
	void getAsync(String url, float timeout, const ContentHandler& callback);
	void downloadAsync(String url, String filePath, float timeout, const std::function<bool(bool interrupted, uint64_t current, uint64_t total)>& progress);

protected:
	HttpClient();

private:
	Async* _requestThread;
	Async* _downloadThread;
	bool _stopped;
	SINGLETON_REF(HttpClient, AsyncThread, Director);
};

#define SharedHttpClient \
	Dora::Singleton<Dora::HttpClient>::shared()

NS_DORA_END
