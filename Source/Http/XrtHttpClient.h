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

typedef struct DoraXrtHttpResponse {
	int netStatus;
	int statusCode;
	char* body;
	size_t bodyLen;
} DoraXrtHttpResponse;

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

#ifdef __cplusplus
}
#endif
