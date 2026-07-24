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

#include "Http/XrtHttpClient.h"

#define XRT_NO_XHTTPD
#define XRT_NO_XWS
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
#if defined(__ANDROID__)
#define XNET_FORCE_EPOLL
#endif
#define XRT_IMPLEMENTATION
#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#pragma clang diagnostic ignored "-Wdeprecated-non-prototype"
#pragma clang diagnostic ignored "-Wpointer-sign"
#elif defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wstrict-prototypes"
#pragma GCC diagnostic ignored "-Wpointer-sign"
#endif
#include "xrt/xrt.h"
#if defined(__clang__)
#pragma clang diagnostic pop
#elif defined(__GNUC__)
#pragma GCC diagnostic pop
#endif

#include <ctype.h>
#if !defined(_WIN32) && !defined(_WIN64)
#include <signal.h>
#endif
#include <stdlib.h>
#include <string.h>

#define DORA_XRT_HTTP_MAX_REDIRECTS 5
#define DORA_XRT_HTTP_POLL_MS 50u
#define DORA_XRT_HTTP_USER_AGENT "Dora-SSR"
#define DORA_XRT_HTTP_MAX_HEADER_BYTES ((XCODEC_HTTP1_MAX_HEADERS + 1u) * XCODEC_HTTP1_HEADER_MAX_LENGTH + 4u)

typedef enum DoraXrtHttpBodyMode {
	DORA_XRT_HTTP_BODY_UNKNOWN = 0,
	DORA_XRT_HTTP_BODY_NONE,
	DORA_XRT_HTTP_BODY_CONTENT_LENGTH,
	DORA_XRT_HTTP_BODY_CHUNKED,
	DORA_XRT_HTTP_BODY_CLOSE_DELIMITED
} DoraXrtHttpBodyMode;

static int DoraXrtHttpAttachRuntimeThread(void) {
	static volatile long initialized = 0;
	if (__xnetAtomicCompareExchange32(&initialized, 1, 0) == 0) {
#if !defined(_WIN32) && !defined(_WIN64)
		(void)signal(SIGPIPE, SIG_IGN);
#endif
		xrtInit();
		xrtThreadDetachCurrent();
	}
	return xrtThreadAttachCurrent() != NULL;
}

static int DoraXrtHttpIsRedirect(unsigned int statusCode) {
	return statusCode == 301u || statusCode == 302u || statusCode == 303u ||
		statusCode == 307u || statusCode == 308u;
}

static int DoraXrtHttpCopyResponse(const xhttpresponse* src, DoraXrtHttpResponse* dst) {
	if (!dst) {
		return 0;
	}
	dst->statusCode = src ? (int)src->iStatusCode : 0;
	dst->body = NULL;
	dst->bodyLen = 0;
	if (!src || !src->pBody || src->iBodyLen == 0u) {
		return 1;
	}
	dst->body = (char*)malloc(src->iBodyLen);
	if (!dst->body) {
		return 0;
	}
	memcpy(dst->body, src->pBody, src->iBodyLen);
	dst->bodyLen = src->iBodyLen;
	return 1;
}

static int DoraXrtHttpResolveRedirect(const char* baseUrl, const char* location, char* outUrl, size_t outUrlCap) {
	xrturlview baseView;
	size_t outLen = 0;
	if (!baseUrl || !location || !outUrl || outUrlCap == 0u) {
		return 0;
	}
	if (!xrtUrlParseView(baseUrl, &baseView)) {
		return 0;
	}
	if (!xrtUrlResolveTo(&baseView, location, strlen(location), outUrl, outUrlCap, &outLen)) {
		return 0;
	}
	outUrl[outLen < outUrlCap ? outLen : outUrlCap - 1u] = '\0';
	return 1;
}

typedef struct DoraXrtHttpStreamContext {
	xnetfuture* future;
	xnetstream* stream;
	char* requestBytes;
	size_t requestLen;
	char* pending;
	size_t pendingLen;
	size_t pendingCap;
	DoraXrtHttpStreamHandler onChunk;
	void* streamUserData;
	int statusCode;
	int hasContentLength;
	int chunked;
	int noBody;
	int suppressBody;
	int headerParsed;
	size_t contentLength;
	size_t received;
	size_t chunkRemaining;
	int chunkTerminated;
	DoraXrtHttpBodyMode bodyMode;
	char redirectLocation[XHTTP_URL_CAP];
	int streamError;
	int streamSysErr;
	volatile long closeRequested;
	volatile long resolved;
	xnet_result finalStatus;
} DoraXrtHttpStreamContext;

static void DoraXrtHttpStreamResolve(DoraXrtHttpStreamContext* ctx, xnet_result status) {
	if (!ctx || !ctx->future) {
		return;
	}
	if (__xnetAtomicCompareExchange32(&ctx->resolved, 1, 0) == 0) {
		(void)__xnetFutureResolve(ctx->future, status, NULL);
	}
}

static void DoraXrtHttpStreamCloseWith(DoraXrtHttpStreamContext* ctx, xnet_result status) {
	if (!ctx) {
		return;
	}
	if (ctx->finalStatus == XRT_NET_AGAIN) {
		ctx->finalStatus = status;
	}
	if (__xnetAtomicCompareExchange32(&ctx->closeRequested, 1, 0) == 0) {
		if (ctx->stream) {
			xrtNetStreamClose(ctx->stream, XNET_CLOSE_F_ABORT);
		} else {
			DoraXrtHttpStreamResolve(ctx, ctx->finalStatus);
		}
	}
}

static int DoraXrtHttpStreamAppend(DoraXrtHttpStreamContext* ctx, const char* data, size_t len) {
	char* newBuf;
	size_t newCap;
	if (!ctx || !data || len == 0u) {
		return 1;
	}
	if (ctx->pendingLen + len + 1u <= ctx->pendingCap) {
		memcpy(ctx->pending + ctx->pendingLen, data, len);
		ctx->pendingLen += len;
		ctx->pending[ctx->pendingLen] = '\0';
		return 1;
	}
	newCap = ctx->pendingCap ? ctx->pendingCap : 4096u;
	while (newCap < ctx->pendingLen + len + 1u) {
		newCap *= 2u;
	}
	newBuf = (char*)realloc(ctx->pending, newCap);
	if (!newBuf) {
		return 0;
	}
	ctx->pending = newBuf;
	ctx->pendingCap = newCap;
	memcpy(ctx->pending + ctx->pendingLen, data, len);
	ctx->pendingLen += len;
	ctx->pending[ctx->pendingLen] = '\0';
	return 1;
}

static void DoraXrtHttpStreamConsume(DoraXrtHttpStreamContext* ctx, size_t len) {
	if (!ctx || len == 0u) {
		return;
	}
	if (len >= ctx->pendingLen) {
		ctx->pendingLen = 0u;
		if (ctx->pending) {
			ctx->pending[0] = '\0';
		}
		return;
	}
	memmove(ctx->pending, ctx->pending + len, ctx->pendingLen - len);
	ctx->pendingLen -= len;
	ctx->pending[ctx->pendingLen] = '\0';
}

static size_t DoraXrtHttpFindBytes(const char* data, size_t len, const char* needle, size_t needleLen) {
	if (!data || !needle || needleLen == 0u || len < needleLen) {
		return (size_t)-1;
	}
	for (size_t i = 0; i <= len - needleLen; ++i) {
		if (memcmp(data + i, needle, needleLen) == 0) {
			return i;
		}
	}
	return (size_t)-1;
}

static int DoraXrtHttpStartsNoCase(const char* text, const char* prefix) {
	while (*prefix) {
		if (tolower((unsigned char)*text) != tolower((unsigned char)*prefix)) {
			return 0;
		}
		++text;
		++prefix;
	}
	return 1;
}

static int DoraXrtHttpHasHeader(const char* const* headerNames, size_t headerCount, const char* name) {
	if (!headerNames || !name) {
		return 0;
	}
	for (size_t i = 0; i < headerCount; ++i) {
		if (headerNames[i] && __xhttpStrEqNoCase(headerNames[i], name)) {
			return 1;
		}
	}
	return 0;
}

static char* DoraXrtHttpTrim(char* text) {
	char* end;
	while (*text == ' ' || *text == '\t') {
		++text;
	}
	end = text + strlen(text);
	while (end > text && (end[-1] == ' ' || end[-1] == '\t')) {
		*--end = '\0';
	}
	return text;
}

static int DoraXrtHttpIsTokenChar(unsigned char ch) {
	return (isalnum(ch) ||
		ch == '!' || ch == '#' || ch == '$' || ch == '%' || ch == '&' ||
		ch == '\'' || ch == '*' || ch == '+' || ch == '-' || ch == '.' ||
		ch == '^' || ch == '_' || ch == '`' || ch == '|' || ch == '~');
}

static int DoraXrtHttpValidHeaderName(const char* text) {
	if (!text || !text[0]) {
		return 0;
	}
	for (const unsigned char* p = (const unsigned char*)text; *p; ++p) {
		if (!DoraXrtHttpIsTokenChar(*p)) {
			return 0;
		}
	}
	return 1;
}

static int DoraXrtHttpValidHeaderValue(const char* text) {
	size_t len;
	if (!text) {
		return 0;
	}
	len = strlen(text);
	if (len == 0u) {
		return 1;
	}
	if (!(((unsigned char)text[0] >= 33u && (unsigned char)text[0] <= 126u) || (unsigned char)text[0] >= 128u)) {
		return 0;
	}
	if (!(((unsigned char)text[len - 1u] >= 33u && (unsigned char)text[len - 1u] <= 126u) || (unsigned char)text[len - 1u] >= 128u)) {
		return 0;
	}
	for (size_t i = 1u; i + 1u < len; ++i) {
		unsigned char ch = (unsigned char)text[i];
		if (ch == ' ' || ch == '\t' || (ch >= 33u && ch <= 126u) || ch >= 128u) {
			continue;
		}
		return 0;
	}
	return 1;
}

static int DoraXrtHttpParseSize(const char* text, size_t* outValue) {
	size_t value = 0u;
	if (!text || !text[0] || !outValue) {
		return 0;
	}
	for (const unsigned char* p = (const unsigned char*)text; *p; ++p) {
		size_t digit;
		if (*p < '0' || *p > '9') {
			return 0;
		}
		digit = (size_t)(*p - '0');
		if (value > (SIZE_MAX - digit) / 10u) {
			return 0;
		}
		value = value * 10u + digit;
	}
	*outValue = value;
	return 1;
}

static int DoraXrtHttpParseStatusCode(const char* line, int* outStatusCode) {
	const char* p;
	int value = 0;
	int digits = 0;
	if (!line || !outStatusCode) {
		return 0;
	}
	if (strncmp(line, "HTTP/1.0", 8u) != 0 && strncmp(line, "HTTP/1.1", 8u) != 0) {
		return 0;
	}
	p = line + 8u;
	if (*p != ' ' && *p != '\t') {
		return 0;
	}
	while (*p == ' ' || *p == '\t') {
		++p;
	}
	while (*p >= '0' && *p <= '9') {
		if (digits >= 3) {
			return 0;
		}
		value = value * 10 + (*p - '0');
		++digits;
		++p;
	}
	if (digits != 3 || value < 100 || value > 999) {
		return 0;
	}
	if (*p != '\0' && *p != ' ' && *p != '\t') {
		return 0;
	}
	*outStatusCode = value;
	return 1;
}

static int DoraXrtHttpParseHeaders(DoraXrtHttpStreamContext* ctx) {
	size_t headerEnd;
	size_t headerCount = 0u;
	char* headerBlock;
	char* line;
	char* next;
	char* contentLengthValue = NULL;
	if (!ctx || ctx->headerParsed) {
		return 1;
	}
	headerEnd = DoraXrtHttpFindBytes(ctx->pending, ctx->pendingLen, "\r\n\r\n", 4u);
	if (headerEnd == (size_t)-1) {
		if (ctx->pendingLen > DORA_XRT_HTTP_MAX_HEADER_BYTES) {
			return 0;
		}
		return 1;
	}
	if (headerEnd + 4u > DORA_XRT_HTTP_MAX_HEADER_BYTES) {
		return 0;
	}
	headerBlock = (char*)malloc(headerEnd + 1u);
	if (!headerBlock) {
		return 0;
	}
	memcpy(headerBlock, ctx->pending, headerEnd);
	headerBlock[headerEnd] = '\0';
	line = headerBlock;
	next = strstr(line, "\r\n");
	if (next) {
		*next = '\0';
		next += 2;
	}
	if (!DoraXrtHttpStartsNoCase(line, "HTTP/")) {
		free(headerBlock);
		return 0;
	}
	if (!DoraXrtHttpParseStatusCode(line, &ctx->statusCode)) {
		free(headerBlock);
		return 0;
	}
	ctx->noBody = (ctx->statusCode >= 100 && ctx->statusCode < 200) || ctx->statusCode == 204 || ctx->statusCode == 304;
	ctx->suppressBody = DoraXrtHttpIsRedirect((unsigned int)ctx->statusCode);
	line = next;
	while (line && *line) {
		char* value;
		size_t lineLen;
		next = strstr(line, "\r\n");
		if (next) {
			lineLen = (size_t)(next - line) + 2u;
			*next = '\0';
			next += 2;
		} else {
			lineLen = strlen(line);
		}
		if (lineLen > XCODEC_HTTP1_HEADER_MAX_LENGTH || headerCount >= XCODEC_HTTP1_MAX_HEADERS) {
			free(contentLengthValue);
			free(headerBlock);
			return 0;
		}
		value = strchr(line, ':');
		if (!value) {
			free(contentLengthValue);
			free(headerBlock);
			return 0;
		}
		*value++ = '\0';
		line = DoraXrtHttpTrim(line);
		value = DoraXrtHttpTrim(value);
		if (!DoraXrtHttpValidHeaderName(line) || !DoraXrtHttpValidHeaderValue(value)) {
			free(contentLengthValue);
			free(headerBlock);
			return 0;
		}
		++headerCount;
		if (__xhttpStrEqNoCase(line, "Content-Length")) {
			size_t parsedLength;
			if (!DoraXrtHttpParseSize(value, &parsedLength)) {
				free(contentLengthValue);
				free(headerBlock);
				return 0;
			}
			if (contentLengthValue && strcmp(contentLengthValue, value) != 0) {
				free(contentLengthValue);
				free(headerBlock);
				return 0;
			}
			if (!contentLengthValue) {
				contentLengthValue = (char*)malloc(strlen(value) + 1u);
				if (!contentLengthValue) {
					free(headerBlock);
					return 0;
				}
				strcpy(contentLengthValue, value);
				ctx->hasContentLength = 1;
				ctx->contentLength = parsedLength;
			}
		} else if (__xhttpStrEqNoCase(line, "Transfer-Encoding")) {
			ctx->chunked = xrtHttpHeaderContainsToken(value, "chunked") ? 1 : 0;
		} else if (__xhttpStrEqNoCase(line, "Location")) {
			size_t len = strlen(value);
			if (len >= sizeof(ctx->redirectLocation)) {
				len = sizeof(ctx->redirectLocation) - 1u;
			}
			memcpy(ctx->redirectLocation, value, len);
			ctx->redirectLocation[len] = '\0';
		}
		line = next;
	}
	free(contentLengthValue);
	free(headerBlock);
	DoraXrtHttpStreamConsume(ctx, headerEnd + 4u);
	ctx->headerParsed = 1;
	if (ctx->noBody) {
		ctx->bodyMode = DORA_XRT_HTTP_BODY_NONE;
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_OK);
	} else if (ctx->chunked) {
		ctx->bodyMode = DORA_XRT_HTTP_BODY_CHUNKED;
	} else if (ctx->hasContentLength) {
		ctx->bodyMode = DORA_XRT_HTTP_BODY_CONTENT_LENGTH;
		if (ctx->contentLength == 0u) {
			DoraXrtHttpStreamCloseWith(ctx, XRT_NET_OK);
		}
	} else {
		ctx->bodyMode = DORA_XRT_HTTP_BODY_CLOSE_DELIMITED;
	}
	return 1;
}

static int DoraXrtHttpDeliverChunk(DoraXrtHttpStreamContext* ctx, const char* data, size_t len, size_t total) {
	if (!ctx || len == 0u || ctx->suppressBody) {
		return 1;
	}
	if (ctx->onChunk && ctx->onChunk(data, len, ctx->received, total, ctx->streamUserData)) {
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_CANCELLED);
		return 0;
	}
	return 1;
}

static int DoraXrtHttpProcessFixedBody(DoraXrtHttpStreamContext* ctx) {
	while (ctx->pendingLen > 0u && ctx->received < ctx->contentLength) {
		size_t remain = ctx->contentLength - ctx->received;
		size_t take = ctx->pendingLen < remain ? ctx->pendingLen : remain;
		ctx->received += take;
		if (!DoraXrtHttpDeliverChunk(ctx, ctx->pending, take, ctx->contentLength)) {
			return 0;
		}
		DoraXrtHttpStreamConsume(ctx, take);
	}
	if (ctx->received >= ctx->contentLength) {
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_OK);
	}
	return 1;
}

static int DoraXrtHttpParseChunkSize(const char* line, size_t len, size_t* outSize) {
	size_t value = 0u;
	size_t i = 0u;
	int hasDigit = 0;
	if (!line || !outSize) {
		return 0;
	}
	while (i < len && line[i] != ';') {
		unsigned char ch = (unsigned char)line[i++];
		unsigned int digit;
		if (ch >= '0' && ch <= '9') {
			digit = ch - '0';
		} else if (ch >= 'a' && ch <= 'f') {
			digit = ch - 'a' + 10u;
		} else if (ch >= 'A' && ch <= 'F') {
			digit = ch - 'A' + 10u;
		} else if (isspace(ch)) {
			continue;
		} else {
			return 0;
		}
		if (value > (SIZE_MAX - digit) / 16u) {
			return 0;
		}
		value = value * 16u + digit;
		hasDigit = 1;
	}
	if (!hasDigit) {
		return 0;
	}
	*outSize = value;
	return 1;
}

static int DoraXrtHttpProcessChunkedTrailers(DoraXrtHttpStreamContext* ctx) {
	size_t trailerEnd;
	if (ctx->pendingLen >= 2u && ctx->pending[0] == '\r' && ctx->pending[1] == '\n') {
		DoraXrtHttpStreamConsume(ctx, 2u);
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_OK);
		return 1;
	}
	trailerEnd = DoraXrtHttpFindBytes(ctx->pending, ctx->pendingLen, "\r\n\r\n", 4u);
	if (trailerEnd != (size_t)-1) {
		if (trailerEnd + 4u > DORA_XRT_HTTP_MAX_HEADER_BYTES) {
			DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
			return 0;
		}
		DoraXrtHttpStreamConsume(ctx, trailerEnd + 4u);
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_OK);
		return 1;
	}
	if (ctx->pendingLen > DORA_XRT_HTTP_MAX_HEADER_BYTES) {
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
		return 0;
	}
	return 1;
}

static int DoraXrtHttpProcessChunkedBody(DoraXrtHttpStreamContext* ctx) {
	for (;;) {
		if (ctx->chunkTerminated) {
			return DoraXrtHttpProcessChunkedTrailers(ctx);
		}
		if (ctx->chunkRemaining == 0u) {
			size_t lineEnd = DoraXrtHttpFindBytes(ctx->pending, ctx->pendingLen, "\r\n", 2u);
			size_t nextSize = 0u;
			if (lineEnd == (size_t)-1) {
				if (ctx->pendingLen > XCODEC_HTTP1_HEADER_MAX_LENGTH) {
					DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
					return 0;
				}
				return 1;
			}
			if (lineEnd + 2u > XCODEC_HTTP1_HEADER_MAX_LENGTH) {
				DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
				return 0;
			}
			if (!DoraXrtHttpParseChunkSize(ctx->pending, lineEnd, &nextSize)) {
				DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
				return 0;
			}
			DoraXrtHttpStreamConsume(ctx, lineEnd + 2u);
			if (nextSize == 0u) {
				ctx->chunkTerminated = 1;
				continue;
			}
			ctx->chunkRemaining = nextSize;
		}
		if (ctx->chunkRemaining > SIZE_MAX - 2u) {
			DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
			return 0;
		}
		if (ctx->pendingLen < ctx->chunkRemaining + 2u) {
			return 1;
		}
		if (ctx->pending[ctx->chunkRemaining] != '\r' || ctx->pending[ctx->chunkRemaining + 1u] != '\n') {
			DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
			return 0;
		}
		ctx->received += ctx->chunkRemaining;
		if (!DoraXrtHttpDeliverChunk(ctx, ctx->pending, ctx->chunkRemaining, 0u)) {
			return 0;
		}
		DoraXrtHttpStreamConsume(ctx, ctx->chunkRemaining + 2u);
		ctx->chunkRemaining = 0u;
	}
}

static int DoraXrtHttpProcessCloseDelimitedBody(DoraXrtHttpStreamContext* ctx) {
	if (ctx->pendingLen == 0u) {
		return 1;
	}
	ctx->received += ctx->pendingLen;
	if (!DoraXrtHttpDeliverChunk(ctx, ctx->pending, ctx->pendingLen, 0u)) {
		return 0;
	}
	DoraXrtHttpStreamConsume(ctx, ctx->pendingLen);
	return 1;
}

static int DoraXrtHttpStreamProcess(DoraXrtHttpStreamContext* ctx) {
	if (!DoraXrtHttpParseHeaders(ctx)) {
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
		return 0;
	}
	if (!ctx->headerParsed || ctx->noBody || __xnetAtomicLoad32(&ctx->closeRequested) != 0) {
		return 1;
	}
	if (ctx->bodyMode == DORA_XRT_HTTP_BODY_CHUNKED) {
		return DoraXrtHttpProcessChunkedBody(ctx);
	}
	if (ctx->bodyMode == DORA_XRT_HTTP_BODY_CONTENT_LENGTH) {
		return DoraXrtHttpProcessFixedBody(ctx);
	}
	if (ctx->bodyMode == DORA_XRT_HTTP_BODY_CLOSE_DELIMITED) {
		return DoraXrtHttpProcessCloseDelimitedBody(ctx);
	}
	return 1;
}

static void DoraXrtHttpStreamOnOpen(ptr owner, xnetstream* stream) {
	DoraXrtHttpStreamContext* ctx = (DoraXrtHttpStreamContext*)owner;
	if (!ctx || !stream) {
		return;
	}
	if (xrtNetStreamSend(stream, ctx->requestBytes, ctx->requestLen) != XRT_NET_OK) {
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
	}
}

static void DoraXrtHttpStreamOnRecv(ptr owner, xnetstream* stream, xnetchain* chain) {
	DoraXrtHttpStreamContext* ctx = (DoraXrtHttpStreamContext*)owner;
	size_t len;
	char* data;
	(void)stream;
	if (!ctx || !chain || __xnetAtomicLoad32(&ctx->closeRequested) != 0) {
		return;
	}
	len = xrtNetChainBytes(chain);
	if (len == 0u) {
		return;
	}
	data = (char*)malloc(len);
	if (!data) {
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
		return;
	}
	if (xrtNetChainPeek(chain, data, len) != len) {
		free(data);
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
		return;
	}
	xrtNetChainConsume(chain, len);
	if (!DoraXrtHttpStreamAppend(ctx, data, len)) {
		free(data);
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
		return;
	}
	free(data);
	(void)DoraXrtHttpStreamProcess(ctx);
}

static void DoraXrtHttpStreamOnClose(ptr owner, xnetstream* stream, xnet_result reason) {
	DoraXrtHttpStreamContext* ctx = (DoraXrtHttpStreamContext*)owner;
	xnet_result status;
	(void)stream;
	if (!ctx) {
		return;
	}
	if (ctx->finalStatus == XRT_NET_AGAIN) {
		(void)DoraXrtHttpStreamProcess(ctx);
	}
	if (ctx->finalStatus == XRT_NET_AGAIN) {
		if (ctx->streamError) {
			status = XRT_NET_ERROR;
		} else if (!ctx->headerParsed) {
			status = reason == XRT_NET_CANCELLED ? XRT_NET_CANCELLED : XRT_NET_ERROR;
		} else if (ctx->bodyMode == DORA_XRT_HTTP_BODY_CHUNKED) {
			status = XRT_NET_ERROR;
		} else if (ctx->bodyMode == DORA_XRT_HTTP_BODY_CONTENT_LENGTH && ctx->received < ctx->contentLength) {
			status = XRT_NET_ERROR;
		} else {
			status = XRT_NET_OK;
		}
		ctx->finalStatus = status;
	}
	DoraXrtHttpStreamResolve(ctx, ctx->finalStatus);
}

static void DoraXrtHttpStreamOnError(ptr owner, xnetstream* stream, int sysErr) {
	(void)stream;
	DoraXrtHttpStreamContext* ctx = (DoraXrtHttpStreamContext*)owner;
	if (!ctx) {
		return;
	}
	ctx->streamError = 1;
	ctx->streamSysErr = sysErr;
}

static const xnetstreamevents* DoraXrtHttpStreamEvents(void) {
	static const xnetstreamevents events = {
		DoraXrtHttpStreamOnOpen,
		DoraXrtHttpStreamOnRecv,
		NULL,
		DoraXrtHttpStreamOnClose,
		DoraXrtHttpStreamOnError,
		NULL,
		NULL
	};
	return &events;
}

static xnet_result DoraXrtHttpExecuteStreamOnce(
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
	int* statusCode,
	char* redirectLocation,
	size_t redirectLocationCap) {
	xhttprequest request;
	xnetengine* engine;
	xnetconnectconfig connectConfig;
	xtlsconfig tlsConfig;
	DoraXrtHttpStreamContext ctx;
	xnet_result status = XRT_NET_ERROR;
	double startTime = xrtTimer();

	if (statusCode) {
		*statusCode = 0;
	}
	if (redirectLocation && redirectLocationCap > 0u) {
		redirectLocation[0] = '\0';
	}
	if (!method || !url) {
		return XRT_NET_ERROR;
	}

	memset(&ctx, 0, sizeof(ctx));
	ctx.finalStatus = XRT_NET_AGAIN;
	ctx.onChunk = onChunk;
	ctx.streamUserData = streamUserData;
	ctx.future = xrtNetFutureCreate();
	if (!ctx.future) {
		return XRT_NET_ERROR;
	}

	xrtHttpRequestInit(&request);
	if (!xrtHttpRequestSetMethod(&request, method) ||
		!xrtHttpRequestSetURL(&request, url)) {
		xrtHttpRequestUnit(&request);
		xrtNetFutureDestroy(ctx.future);
		return XRT_NET_ERROR;
	}
	for (size_t i = 0; i < headerCount; ++i) {
		if (headerNames && headerValues && headerNames[i] && headerValues[i]) {
			(void)xrtHttpRequestSetHeader(&request, headerNames[i], headerValues[i]);
		}
	}
	if (!DoraXrtHttpHasHeader(headerNames, headerCount, "User-Agent")) {
		(void)xrtHttpRequestSetHeader(&request, "User-Agent", DORA_XRT_HTTP_USER_AGENT);
	}
	if (body && bodyLen > 0u && !xrtHttpRequestSetBodyCopy(&request, body, bodyLen, NULL)) {
		xrtHttpRequestUnit(&request);
		xrtNetFutureDestroy(ctx.future);
		return XRT_NET_ERROR;
	}
	if (!__xhttpBuildRequestBytes(&request, &ctx.requestBytes, &ctx.requestLen)) {
		xrtHttpRequestUnit(&request);
		xrtNetFutureDestroy(ctx.future);
		return XRT_NET_ERROR;
	}

	engine = xrtNetSyncGetHiddenEngine();
	if (!engine) {
		status = XRT_NET_ERROR;
		goto cleanup;
	}
	ctx.stream = xrtNetStreamCreate(engine, DoraXrtHttpStreamEvents(), &ctx);
	if (!ctx.stream) {
		status = XRT_NET_ERROR;
		goto cleanup;
	}
	xrtNetConnectConfigInit(&connectConfig);
	connectConfig.sHost = request.tURL.sHost;
	connectConfig.iPort = request.tURL.iPort;
	connectConfig.iConnectTimeoutMs = timeoutMs;
	connectConfig.iRecvLimit = 8u * 1024u * 1024u;
	if (request.tURL.bHttps) {
		memset(&tlsConfig, 0, sizeof(tlsConfig));
		tlsConfig.sHostName = request.tURL.sHost;
		tlsConfig.bVerifyPeer = verifyPeer != 0;
		connectConfig.pTlsConfig = &tlsConfig;
	}
	if (xrtNetStreamConnect(ctx.stream, &connectConfig) != XRT_NET_OK) {
		status = XRT_NET_ERROR;
		goto cleanup;
	}

	for (;;) {
		if (shouldCancel && shouldCancel(cancelUserData)) {
			DoraXrtHttpStreamCloseWith(&ctx, XRT_NET_CANCELLED);
		} else if (timeoutMs > 0u && (unsigned int)((xrtTimer() - startTime) * 1000.0) >= timeoutMs) {
			DoraXrtHttpStreamCloseWith(&ctx, XRT_NET_TIMEOUT);
		}
		status = xrtNetFutureWait(ctx.future, DORA_XRT_HTTP_POLL_MS);
		if (status != XRT_NET_TIMEOUT) {
			break;
		}
	}
	if (status == XRT_NET_OK && ctx.statusCode == 0) {
		status = XRT_NET_ERROR;
	}
	if (statusCode) {
		*statusCode = ctx.statusCode;
	}
	if (redirectLocation && redirectLocationCap > 0u && ctx.redirectLocation[0] != '\0') {
		size_t len = strlen(ctx.redirectLocation);
		if (len >= redirectLocationCap) {
			len = redirectLocationCap - 1u;
		}
		memcpy(redirectLocation, ctx.redirectLocation, len);
		redirectLocation[len] = '\0';
	}

cleanup:
	if (ctx.stream) {
		xrtNetStreamDestroy(ctx.stream);
		ctx.stream = NULL;
	}
	if (ctx.requestBytes) {
		XNET_FREE(ctx.requestBytes);
	}
	free(ctx.pending);
	xrtHttpRequestUnit(&request);
	xrtNetFutureDestroy(ctx.future);
	return status;
}

static xhttpresponse* DoraXrtHttpExecuteOnce(
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
	int* netStatus) {
	xhttprequest request;
	xnetfuture* future = NULL;
	xhttpresponse* response = NULL;
	xnet_result status = XRT_NET_ERROR;
	double startTime = xrtTimer();

	if (netStatus) {
		*netStatus = XRT_NET_ERROR;
	}
	if (!method || !url) {
		return NULL;
	}

	xrtHttpRequestInit(&request);
	if (!xrtHttpRequestSetMethod(&request, method) ||
		!xrtHttpRequestSetURL(&request, url)) {
		xrtHttpRequestUnit(&request);
		return NULL;
	}
	for (size_t i = 0; i < headerCount; ++i) {
		if (headerNames && headerValues && headerNames[i] && headerValues[i]) {
			(void)xrtHttpRequestSetHeader(&request, headerNames[i], headerValues[i]);
		}
	}
	if (!DoraXrtHttpHasHeader(headerNames, headerCount, "User-Agent")) {
		(void)xrtHttpRequestSetHeader(&request, "User-Agent", DORA_XRT_HTTP_USER_AGENT);
	}
	if (body && bodyLen > 0u && !xrtHttpRequestSetBodyCopy(&request, body, bodyLen, NULL)) {
		xrtHttpRequestUnit(&request);
		return NULL;
	}
	if (timeoutMs > 0u) {
		xrtHttpRequestSetTimeout(&request, timeoutMs);
		xrtHttpRequestSetIdleTimeout(&request, timeoutMs);
	}
	xrtHttpRequestSetVerifyPeer(&request, verifyPeer != 0);

	future = xrtHttpExecuteAsync(NULL, &request);
	xrtHttpRequestUnit(&request);
	if (!future) {
		return NULL;
	}

	for (;;) {
		if (shouldCancel && shouldCancel(userData)) {
			(void)xFutureRequestCancel(future);
			status = xrtNetFutureWait(future, DORA_XRT_HTTP_POLL_MS);
			if (status == XRT_NET_TIMEOUT) {
				status = XRT_NET_CANCELLED;
			}
			break;
		}
		if (timeoutMs > 0u && (unsigned int)((xrtTimer() - startTime) * 1000.0) >= timeoutMs) {
			(void)xFutureRequestCancel(future);
			status = XRT_NET_TIMEOUT;
			break;
		}
		status = xrtNetFutureWait(future, DORA_XRT_HTTP_POLL_MS);
		if (status != XRT_NET_TIMEOUT) {
			break;
		}
	}

	if (status == XRT_NET_OK) {
		response = (xhttpresponse*)xrtNetFutureValue(future);
	}
	if (netStatus) {
		*netStatus = status;
	}
	xrtNetFutureDestroy(future);
	return response;
}

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
	DoraXrtHttpResponse* response) {
	char currentUrl[XHTTP_URL_CAP];
	char nextUrl[XHTTP_URL_CAP];
	const char* currentMethod = method;
	const void* currentBody = body;
	size_t currentBodyLen = bodyLen;
	int netStatus = XRT_NET_ERROR;

	if (!response || !method || !url) {
		return XRT_NET_ERROR;
	}
	if (!DoraXrtHttpAttachRuntimeThread()) {
		return XRT_NET_ERROR;
	}
	memset(response, 0, sizeof(*response));
	response->netStatus = XRT_NET_ERROR;
	if (strlen(url) >= sizeof(currentUrl)) {
		xrtThreadDetachCurrent();
		return XRT_NET_ERROR;
	}
	strcpy(currentUrl, url);

	for (int redirect = 0; redirect <= DORA_XRT_HTTP_MAX_REDIRECTS; ++redirect) {
		xhttpresponse* xrtResponse = DoraXrtHttpExecuteOnce(
			currentMethod,
			currentUrl,
			headerNames,
			headerValues,
			headerCount,
			currentBody,
			currentBodyLen,
			timeoutMs,
			verifyPeer,
			shouldCancel,
			userData,
			&netStatus);
		response->netStatus = netStatus;
		if (netStatus != XRT_NET_OK || !xrtResponse) {
			xrtThreadDetachCurrent();
			return netStatus;
		}
		if (DoraXrtHttpIsRedirect(xrtResponse->iStatusCode)) {
			const char* location = xrtHttpResponseHeader(xrtResponse, "Location");
			if (location && DoraXrtHttpResolveRedirect(currentUrl, location, nextUrl, sizeof(nextUrl))) {
				strcpy(currentUrl, nextUrl);
				if (xrtResponse->iStatusCode == 303u) {
					currentMethod = "GET";
					currentBody = NULL;
					currentBodyLen = 0u;
				}
				xrtHttpResponseDestroy(xrtResponse);
				continue;
			}
		}
		if (!DoraXrtHttpCopyResponse(xrtResponse, response)) {
			xrtHttpResponseDestroy(xrtResponse);
			response->netStatus = XRT_NET_ERROR;
			xrtThreadDetachCurrent();
			return XRT_NET_ERROR;
		}
		xrtHttpResponseDestroy(xrtResponse);
		xrtThreadDetachCurrent();
		return XRT_NET_OK;
	}
	xrtThreadDetachCurrent();
	return XRT_NET_ERROR;
}

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
	int* statusCode) {
	char currentUrl[XHTTP_URL_CAP];
	char nextUrl[XHTTP_URL_CAP];
	char location[XHTTP_URL_CAP];
	const char* currentMethod = method;
	const void* currentBody = body;
	size_t currentBodyLen = bodyLen;
	xnet_result status = XRT_NET_ERROR;

	if (statusCode) {
		*statusCode = 0;
	}
	if (!method || !url) {
		return XRT_NET_ERROR;
	}
	if (!DoraXrtHttpAttachRuntimeThread()) {
		return XRT_NET_ERROR;
	}
	if (strlen(url) >= sizeof(currentUrl)) {
		xrtThreadDetachCurrent();
		return XRT_NET_ERROR;
	}
	strcpy(currentUrl, url);

	for (int redirect = 0; redirect <= DORA_XRT_HTTP_MAX_REDIRECTS; ++redirect) {
		int currentStatusCode = 0;
		status = DoraXrtHttpExecuteStreamOnce(
			currentMethod,
			currentUrl,
			headerNames,
			headerValues,
			headerCount,
			currentBody,
			currentBodyLen,
			timeoutMs,
			verifyPeer,
			shouldCancel,
			cancelUserData,
			onChunk,
			streamUserData,
			&currentStatusCode,
			location,
			sizeof(location));
		if (statusCode) {
			*statusCode = currentStatusCode;
		}
		if (status != XRT_NET_OK) {
			xrtThreadDetachCurrent();
			return status;
		}
		if (DoraXrtHttpIsRedirect((unsigned int)currentStatusCode) &&
			location[0] != '\0' &&
			DoraXrtHttpResolveRedirect(currentUrl, location, nextUrl, sizeof(nextUrl))) {
			strcpy(currentUrl, nextUrl);
			if ((unsigned int)currentStatusCode == 303u) {
				currentMethod = "GET";
				currentBody = NULL;
				currentBodyLen = 0u;
			}
			continue;
		}
		xrtThreadDetachCurrent();
		return status;
	}
	xrtThreadDetachCurrent();
	return XRT_NET_ERROR;
}

void DoraXrtHttpResponseFree(DoraXrtHttpResponse* response) {
	if (!response) {
		return;
	}
	free(response->body);
	response->body = NULL;
	response->bodyLen = 0;
	response->statusCode = 0;
	response->netStatus = 0;
}

static void DoraXrtToHex(const uint8* data, size_t len, char* outHex) {
	static const char hex[] = "0123456789abcdef";
	for (size_t i = 0; i < len; ++i) {
		outHex[i * 2u] = hex[data[i] >> 4u];
		outHex[i * 2u + 1u] = hex[data[i] & 0x0Fu];
	}
	outHex[len * 2u] = '\0';
}

int DoraXrtSha256Hex(const void* data, size_t dataLen, char outHex[65]) {
	uint8 digest[32];
	if (!outHex || (!data && dataLen > 0u)) {
		return 0;
	}
	xrtSHA256((ptr)data, dataLen, digest);
	DoraXrtToHex(digest, sizeof(digest), outHex);
	return 1;
}

int DoraXrtHmacSha256Hex(const void* key, size_t keyLen, const void* data, size_t dataLen, char outHex[65]) {
	uint8 digest[32];
	if (!outHex || (!key && keyLen > 0u) || (!data && dataLen > 0u)) {
		return 0;
	}
	xrtHMAC_SHA256((const uint8*)key, keyLen, (const uint8*)data, dataLen, digest);
	DoraXrtToHex(digest, sizeof(digest), outHex);
	return 1;
}

const char* DoraXrtHttpStatusName(int status) {
	switch (status) {
		case XRT_NET_OK:
			return "ok";
		case XRT_NET_ERROR:
			return "network error";
		case XRT_NET_AGAIN:
			return "operation still pending";
		case XRT_NET_TIMEOUT:
			return "request timed out";
		case XRT_NET_CLOSED:
			return "connection closed";
		case XRT_NET_CANCELLED:
			return "request cancelled";
		default:
			return "unknown network status";
	}
}
