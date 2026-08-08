/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef int (*DoraXrtHttpShouldCancel)(void* userData);
typedef int (*DoraXrtHttpStreamHandler)(const char* data, size_t dataLen, size_t current, size_t total, void* userData);

typedef struct DoraXrtHttpHeader {
	char* name;
	char* value;
} DoraXrtHttpHeader;

typedef struct DoraXrtHttpResponse {
	int netStatus;
	int statusCode;
	char* statusLine;
	DoraXrtHttpHeader* headers;
	size_t headerCount;
	char* body;
	size_t bodyLen;
} DoraXrtHttpResponse;

typedef struct DoraXrtHttpServer DoraXrtHttpServer;
typedef struct DoraXrtHttpServerResponse DoraXrtHttpServerResponse;
typedef struct DoraXrtWebSocketServer DoraXrtWebSocketServer;
typedef void DoraXrtWebSocketConnection;

typedef enum DoraXrtHttpMethod {
	DORA_XRT_HTTP_METHOD_UNKNOWN = 0,
	DORA_XRT_HTTP_METHOD_GET = 1,
	DORA_XRT_HTTP_METHOD_HEAD = 2,
	DORA_XRT_HTTP_METHOD_POST = 3,
	DORA_XRT_HTTP_METHOD_PUT = 4,
	DORA_XRT_HTTP_METHOD_DELETE = 5,
	DORA_XRT_HTTP_METHOD_PATCH = 6,
	DORA_XRT_HTTP_METHOD_OPTIONS = 7
} DoraXrtHttpMethod;

typedef struct DoraXrtHttpHeaderView {
	const char* name;
	const char* value;
} DoraXrtHttpHeaderView;

typedef struct DoraXrtHttpServerRequest {
	DoraXrtHttpMethod method;
	const char* methodText;
	const char* target;
	const char* path;
	const DoraXrtHttpHeaderView* headers;
	size_t headerCount;
	const void* body;
	size_t bodyLen;
} DoraXrtHttpServerRequest;

typedef int (*DoraXrtHttpServerRequestHandler)(void* userData, const DoraXrtHttpServerRequest* request, DoraXrtHttpServerResponse* response);
typedef void (*DoraXrtServerErrorHandler)(void* userData, int error);

typedef struct DoraXrtHttpServerEvents {
	DoraXrtHttpServerRequestHandler onRequest;
	DoraXrtServerErrorHandler onError;
} DoraXrtHttpServerEvents;

typedef int (*DoraXrtWebSocketAuthorizeHandler)(void* userData, DoraXrtWebSocketConnection* connection, const char* target);
typedef void (*DoraXrtWebSocketOpenHandler)(void* userData, DoraXrtWebSocketConnection* connection);
typedef void (*DoraXrtWebSocketMessageHandler)(void* userData, DoraXrtWebSocketConnection* connection, const void* data, size_t dataLen);
typedef void (*DoraXrtWebSocketCloseHandler)(void* userData, DoraXrtWebSocketConnection* connection, int reason);

typedef struct DoraXrtWebSocketServerEvents {
	DoraXrtWebSocketAuthorizeHandler onAuthorize;
	DoraXrtWebSocketOpenHandler onOpen;
	DoraXrtWebSocketMessageHandler onText;
	DoraXrtWebSocketMessageHandler onBinary;
	DoraXrtWebSocketCloseHandler onClose;
	DoraXrtServerErrorHandler onError;
} DoraXrtWebSocketServerEvents;

enum {
	DORA_XRT_WEBSOCKET_CLOSE_GOING_AWAY = 1001
};

typedef struct DoraXrtMultipartFileView {
	const char* fileName;
	size_t fileNameLen;
	const void* body;
	size_t bodyLen;
} DoraXrtMultipartFileView;

typedef int (*DoraXrtMultipartFileHandler)(void* userData, const DoraXrtMultipartFileView* file);

int DoraXrtHttpExecute(
	const char* method,
	const char* url,
	const char* const* headerNames,
	const char* const* headerValues,
	size_t headerCount,
	const void* body,
	size_t bodyLen,
	unsigned int timeoutMs,
	int verifyPeer,
	DoraXrtHttpShouldCancel shouldCancel,
	void* userData,
	DoraXrtHttpResponse* response);

int DoraXrtHttpExecuteStream(
	const char* method,
	const char* url,
	const char* const* headerNames,
	const char* const* headerValues,
	size_t headerCount,
	const void* body,
	size_t bodyLen,
	unsigned int timeoutMs,
	int verifyPeer,
	DoraXrtHttpShouldCancel shouldCancel,
	void* cancelUserData,
	DoraXrtHttpStreamHandler onChunk,
	void* streamUserData,
	int* statusCode);

int DoraXrtSha256Hex(const void* data, size_t dataLen, char outHex[65]);
int DoraXrtHmacSha256Hex(const void* key, size_t keyLen, const void* data, size_t dataLen, char outHex[65]);

const char* DoraXrtHttpStatusName(int status);
void DoraXrtHttpResponseFree(DoraXrtHttpResponse* response);

int DoraXrtPercentEncode(const char* input, size_t inputLen, char* output, size_t outputCap, size_t* outputLen, int spaceAsPlus);
int DoraXrtPercentDecode(const char* input, size_t inputLen, char* output, size_t outputCap, size_t* outputLen, int plusAsSpace);

DoraXrtHttpServer* DoraXrtHttpServerCreate(unsigned int port, size_t receiveLimit, const DoraXrtHttpServerEvents* events, void* userData);
void DoraXrtHttpServerDestroy(DoraXrtHttpServer* server);
const char* DoraXrtHttpServerRequestHeader(const DoraXrtHttpServerRequest* request, const char* name);
void DoraXrtHttpServerResponseSetStatus(DoraXrtHttpServerResponse* response, unsigned int statusCode, const char* reason);
int DoraXrtHttpServerResponseSetHeader(DoraXrtHttpServerResponse* response, const char* name, const char* value);
int DoraXrtHttpServerResponseSetBodyCopy(DoraXrtHttpServerResponse* response, const void* body, size_t bodyLen, const char* contentType);
int DoraXrtMultipartForEachFile(const char* contentType, const void* body, size_t bodyLen, size_t maxBytes, DoraXrtMultipartFileHandler handler, void* userData);

DoraXrtWebSocketServer* DoraXrtWebSocketServerCreate(unsigned int port, size_t receiveLimit, const DoraXrtWebSocketServerEvents* events, void* userData);
void DoraXrtWebSocketServerDestroy(DoraXrtWebSocketServer* server);
int DoraXrtWebSocketConnectionIsOpen(DoraXrtWebSocketConnection* connection);
int DoraXrtWebSocketConnectionSendBinary(DoraXrtWebSocketConnection* connection, const void* data, size_t dataLen);
void DoraXrtWebSocketConnectionClose(DoraXrtWebSocketConnection* connection, unsigned int code, const char* reason);

#ifdef __cplusplus
}
#endif
