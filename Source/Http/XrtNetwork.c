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

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include "Http/XrtNetwork.h"
#if defined(_WIN32) || defined(_WIN64)
#include <fcntl.h>
#include <io.h>
#endif

#if defined(__APPLE__)
#include <TargetConditionals.h>
#endif

#if defined(_WIN32) || defined(_WIN64) || (defined(__APPLE__) && TARGET_OS_OSX && !TARGET_OS_IPHONE) || (defined(__linux__) && !defined(__ANDROID__))
#define DORA_XRT_SUBPROCESS
#else
#define XRT_NO_SUBPROCESS
#endif

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
/*
 * xrt's io_uring backend can busy-poll an idle ring on Linux kernels where
 * the ring fd remains readable without a consumable CQE. This is especially
 * costly on small ARM systems: each HTTP/WebSocket engine can consume a whole
 * CPU core while no requests are being served. The development server is
 * latency-insensitive enough that the mature blocking epoll backend is the
 * safer Linux default.
 */
#if defined(__linux__)
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
#include <stdio.h>
#include <string.h>

#ifdef DORA_XRT_SUBPROCESS
DoraXrtProcess* dora_xrt_process_spawn(const char* program, const char* const* args, size_t argCount, const char* workDir, const char* const* env, size_t envCount) {
	xprocessconfig config;
	xrtProcessConfigInit(&config);
	config.iTargetKind = XPROC_TARGET_EXEC;
	config.sProgram = (str)program;
	config.arrArgs = (str*)args;
	config.iArgCount = (uint32)argCount;
	config.sWorkDir = workDir && workDir[0] ? (str)workDir : NULL;
	config.arrEnv = (str*)env;
	config.iEnvCount = (uint32)envCount;
	config.bInheritEnv = true;
	config.bCreateProcessGroup = true;
	config.bHideWindow = true;
	config.iReadChunkSize = 64 * 1024;
	config.iMaxCaptureBytes = 8 * 1024 * 1024;
	config.iMaxEventCount = 2048;
	config.Stdin.iMode = XPROC_STDIO_PIPE;
	config.Stdout.iMode = XPROC_STDIO_PIPE;
	config.Stdout.bCapture = true;
	config.Stderr.iMode = XPROC_STDIO_PIPE;
	config.Stderr.bCapture = true;
	return (DoraXrtProcess*)xrtProcessSpawn(&config);
}

int dora_xrt_process_read(DoraXrtProcess* opaque, unsigned long long stdoutOffset, unsigned long long stderrOffset, DoraXrtProcessReadResult* result) {
	xprocess* process = (xprocess*)opaque;
	xprocessreadinfo stdoutInfo;
	xprocessreadinfo stderrInfo;
	xprocessexitinfo exitInfo;
	if (!process || !result) return 0;
	memset(result, 0, sizeof(*result));
	memset(&stdoutInfo, 0, sizeof(stdoutInfo));
	memset(&stderrInfo, 0, sizeof(stderrInfo));
	memset(&exitInfo, 0, sizeof(exitInfo));
	result->stdoutData = (char*)xrtProcessReadStdoutSince(process, (uint64)stdoutOffset, 256 * 1024, &result->stdoutSize, &stdoutInfo);
	result->stderrData = (char*)xrtProcessReadStderrSince(process, (uint64)stderrOffset, 256 * 1024, &result->stderrSize, &stderrInfo);
	result->stdoutOffset = stdoutInfo.iNextOffset;
	result->stderrOffset = stderrInfo.iNextOffset;
	result->running = xrtProcessIsRunning(process) ? 1 : 0;
	result->state = xrtProcessState(process);
	if (xrtProcessGetExitInfo(process, &exitInfo)) {
		result->exitKind = exitInfo.iKind;
		result->exitCode = exitInfo.iExitCode;
		result->exitSignal = exitInfo.iSignal;
		result->exitStage = exitInfo.iStage;
		result->osError = exitInfo.iOsError;
		result->stopReason = exitInfo.iStopReason;
		result->timedOut = exitInfo.bTimedOut ? 1 : 0;
		result->cancelled = exitInfo.bCancelled ? 1 : 0;
	}
	return 1;
}

long long dora_xrt_process_write(DoraXrtProcess* process, const void* data, size_t size) {
	return (long long)xrtProcessWrite((xprocess*)process, data, size);
}

int dora_xrt_process_close_stdin(DoraXrtProcess* process) {
	return xrtProcessCloseStdin((xprocess*)process) ? 1 : 0;
}

int dora_xrt_process_stop(DoraXrtProcess* process, int mode) {
	switch (mode) {
		case 1: return xrtProcessInterrupt((xprocess*)process) ? 1 : 0;
		case 2: return xrtProcessTerminate((xprocess*)process) ? 1 : 0;
		case 3: return xrtProcessKill((xprocess*)process) ? 1 : 0;
		case 4: return xrtProcessKillTree((xprocess*)process) ? 1 : 0;
		default: return 0;
	}
}

void dora_xrt_process_read_result_free(DoraXrtProcessReadResult* result) {
	if (!result) return;
	if (result->stdoutData) xrtFree(result->stdoutData);
	if (result->stderrData) xrtFree(result->stderrData);
	result->stdoutData = NULL;
	result->stderrData = NULL;
}

void dora_xrt_process_destroy(DoraXrtProcess* process) {
	if (!process) return;
	if (xrtProcessIsRunning((xprocess*)process)) xrtProcessKillTree((xprocess*)process);
	xrtProcessDestroy((xprocess*)process);
}
#endif

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

static void* DoraXrtNetworkEngine(void) {
	xnetengine* engine;
	if (!DoraXrtHttpAttachRuntimeThread()) {
		return NULL;
	}
	engine = xrtNetSyncGetHiddenEngine();
	xrtThreadDetachCurrent();
	return engine;
}

static void* DoraXrtNetworkEngineCreate(unsigned int workerCount) {
	xnetengineconfig config;
	xnetengine* engine;
	if (!DoraXrtHttpAttachRuntimeThread()) {
		return NULL;
	}
	xrtNetEngineConfigInit(&config);
	config.iWorkerCount = workerCount;
	engine = xrtNetEngineCreate(&config);
	if (engine && xrtNetEngineStart(engine) != XRT_NET_OK) {
		xrtNetEngineDestroy(engine);
		engine = NULL;
	}
	xrtThreadDetachCurrent();
	return engine;
}

static void DoraXrtNetworkEngineDestroy(void* engine) {
	if (!engine || !DoraXrtHttpAttachRuntimeThread()) {
		return;
	}
	xrtNetEngineDestroy((xnetengine*)engine);
	xrtThreadDetachCurrent();
}

struct DoraXrtHttpServer {
	volatile long activeRequests;
	char* temporaryDirectory;
	xhttpdserver* native;
	DoraXrtHttpServerEvents events;
	void* userData;
};

struct DoraXrtHttpServerResponse {
	xhttpdresponse* native;
};

struct DoraXrtWebSocketServer {
	xnetengine* engine;
	xwsserver* native;
	DoraXrtWebSocketServerEvents events;
	void* userData;
};

static int DoraXrtStringEqualNoCase(const char* left, const char* right) {
	unsigned char a;
	unsigned char b;
	if (!left || !right) {
		return 0;
	}
	while (*left && *right) {
		a = (unsigned char)*left++;
		b = (unsigned char)*right++;
		if (tolower(a) != tolower(b)) {
			return 0;
		}
	}
	return *left == '\0' && *right == '\0';
}

static int DoraXrtStreamIsLoopback(xnetstream* stream) {
	const xnetaddr* addr = xrtNetStreamRemoteAddr(stream);
	return addr && ((addr->iFamily == AF_INET && addr->aAddr[0] == 127)
		|| (addr->iFamily == AF_INET6 && memcmp(addr->aAddr, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1", 16) == 0));
}

static bool DoraXrtHttpServerHandleRequest(
	ptr owner,
	xhttpdserver* nativeServer,
	xhttpdconn* connection,
	const xhttpdrequest* nativeRequest,
	xhttpdresponse* nativeResponse, int loopbackPeer) {
	DoraXrtHttpServer* server = (DoraXrtHttpServer*)owner;
	DoraXrtHttpHeaderView headers[XHTTPD_MAX_HEADERS];
	DoraXrtHttpServerRequest request;
	DoraXrtHttpServerResponse response;
	uint32 index;
	(void)nativeServer;
	(void)connection;
	if (!server || !server->events.onRequest || !nativeRequest || !nativeResponse) {
		return false;
	}
	for (index = 0; index < nativeRequest->iHeaderCount && index < XHTTPD_MAX_HEADERS; ++index) {
		headers[index].name = nativeRequest->arrHeaders[index].sName;
		headers[index].value = nativeRequest->arrHeaders[index].sValue;
	}
	memset(&request, 0, sizeof(request));
	request.loopbackPeer = loopbackPeer;
	request.method = (DoraXrtHttpMethod)nativeRequest->iMethod;
	request.methodText = nativeRequest->sMethod;
	request.target = nativeRequest->sTarget;
	request.path = nativeRequest->sPath;
	request.headers = headers;
	request.headerCount = index;
	request.body = nativeRequest->pBody;
	request.bodyLen = nativeRequest->iBodyLen;
	request.bodyFile = nativeRequest->pBodyFile;
	request.uploadAuthorized = (nativeRequest->iFlags & XHTTPD_REQ_F_AUTHORIZED) != 0;
	response.native = nativeResponse;
	return server->events.onRequest(server->userData, &request, &response) != 0;
}

static uint32 DoraXrtHttpServerOnHead(ptr owner, xhttpdserver* native, xhttpdconn* connection, xhttpdrequest* request) {
	DoraXrtHttpServer* server = (DoraXrtHttpServer*)owner;
	DoraXrtHttpHeaderView headers[XHTTPD_MAX_HEADERS];
	DoraXrtHttpServerRequest view = {0};
	(void)native;
	if (!server->events.onUploadHead) return 0;
	for (uint32 i = 0; i < request->iHeaderCount; ++i) {
		headers[i].name = request->arrHeaders[i].sName;
		headers[i].value = request->arrHeaders[i].sValue;
	}
	view.loopbackPeer = DoraXrtStreamIsLoopback(connection->pStream);
	view.method = (DoraXrtHttpMethod)request->iMethod;
	view.methodText = request->sMethod; view.target = request->sTarget; view.path = request->sPath;
	view.headers = headers; view.headerCount = request->iHeaderCount;
	int result = server->events.onUploadHead(server->userData, &view);
	if (result == 1) request->iFlags |= XHTTPD_REQ_F_SPOOL | XHTTPD_REQ_F_AUTHORIZED;
	return result >= 400 ? (uint32)result : 0;
}

/* Anonymous, automatically removed spool files in the app's writable directory.
 * tmpfile() alone is not portable to sandboxed Android/iOS installations. */
static FILE* DoraXrtOpenUploadFile(ptr owner) {
	DoraXrtHttpServer* server = (DoraXrtHttpServer*)owner;
	const char* directory = server->temporaryDirectory;
	if (!directory || !*directory) return tmpfile();
#if defined(_WIN32) || defined(_WIN64)
	wchar_t folder[MAX_PATH], path[MAX_PATH];
	if (!MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, directory, -1, folder, MAX_PATH) ||
		!GetTempFileNameW(folder, L"dor", 0, path)) return NULL;
	HANDLE handle = CreateFileW(path, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING,
		FILE_ATTRIBUTE_TEMPORARY | FILE_FLAG_DELETE_ON_CLOSE, NULL);
	if (handle == INVALID_HANDLE_VALUE) { DeleteFileW(path); return NULL; }
	int fd = _open_osfhandle((intptr_t)handle, _O_BINARY | _O_RDWR);
	if (fd < 0) { CloseHandle(handle); return NULL; }
	FILE* file = _fdopen(fd, "w+b");
	if (!file) _close(fd);
	return file;
#else
	size_t size = strlen(directory) + 32;
	char* path = (char*)malloc(size);
	if (!path) return NULL;
	snprintf(path, size, "%s/.dora-upload-XXXXXX", directory);
	int fd = mkstemp(path);
	if (fd >= 0) unlink(path);
	free(path);
	if (fd < 0) return NULL;
	FILE* file = fdopen(fd, "w+b");
	if (!file) close(fd);
	return file;
#endif
}

static bool DoraXrtHttpServerOnRequest(ptr owner, xhttpdserver* server, xhttpdconn* connection,
	const xhttpdrequest* request, xhttpdresponse* response) {
	return DoraXrtHttpServerHandleRequest(owner, server, connection, request, response,
		connection && DoraXrtStreamIsLoopback(connection->pStream));
}

/* Scheduled Lua handlers cannot block the shared network worker: a TS build
 * needs that worker to serve its own compiler assets and result requests. */
typedef struct DoraXrtDeferredRequest {
	DoraXrtHttpServer* server;
	xhttpdrequest request;
	int loopbackPeer;
} DoraXrtDeferredRequest;

static void DoraXrtDeferredRequestFree(DoraXrtDeferredRequest* task) {
	uint32 index;
	if (!task) return;
	if (task->request.pBodyFile) fclose(task->request.pBodyFile);
	for (index = 0; index < task->request.iHeaderCount; ++index) {
		free(task->request.arrHeaders[index].sName);
		free(task->request.arrHeaders[index].sValue);
	}
	free(task->request.pBody);
	free(task);
}

static char* DoraXrtDeferredString(const char* text) {
	size_t size = strlen(text) + 1;
	char* result = (char*)malloc(size);
	if (result) memcpy(result, text, size);
	return result;
}

static int32 DoraXrtDeferredRequestRun(ptr arg, xfuture_result* result) {
	DoraXrtDeferredRequest* task = (DoraXrtDeferredRequest*)arg;
	DoraXrtHttpServer* server = task->server;
	xhttpdresponse* response = xrtHttpdResponseCreate();
	if (response && !DoraXrtHttpServerHandleRequest(server, NULL, NULL, &task->request, response, task->loopbackPeer)) {
		xrtHttpdResponseSetStatus(response, 404u, NULL);
	}
	result->pValue = response;
	DoraXrtDeferredRequestFree(task);
	__xnetAtomicAddFetch32(&server->activeRequests, -1);
	return response ? XRT_NET_OK : XRT_NET_ERROR;
}

static xfuture* DoraXrtHttpServerOnRequestAsync(ptr owner, xhttpdserver* nativeServer, xhttpdconn* connection, const xhttpdrequest* request) {
	DoraXrtHttpServer* server = (DoraXrtHttpServer*)owner;
	DoraXrtDeferredRequest* task;
	xfuture* future;
	uint32 index;
	(void)nativeServer;
	(void)connection;
	if (request->iMethod != XHTTPD_METHOD_POST || !server->events.shouldDefer || !server->events.shouldDefer(server->userData, request->sPath)) return NULL;
	if (__xnetAtomicAddFetch32(&server->activeRequests, 1) > 32) {
		__xnetAtomicAddFetch32(&server->activeRequests, -1);
		__xhttpdSendSimpleStatus(connection, 503, "Service Unavailable"); return NULL;
	}
	task = (DoraXrtDeferredRequest*)calloc(1, sizeof(*task));
	if (!task) goto rejected;
	task->loopbackPeer = connection && DoraXrtStreamIsLoopback(connection->pStream);
	task->server = server;
	task->request = *request;
	for (index = 0; index < request->iHeaderCount; ++index) {
		task->request.arrHeaders[index].sName = NULL;
		task->request.arrHeaders[index].sValue = NULL;
	}
	task->request.pBody = NULL;
	task->request.pBodyFile = NULL;
	for (index = 0; index < request->iHeaderCount; ++index) {
		task->request.arrHeaders[index].sName = DoraXrtDeferredString(request->arrHeaders[index].sName);
		task->request.arrHeaders[index].sValue = DoraXrtDeferredString(request->arrHeaders[index].sValue);
		if (!task->request.arrHeaders[index].sName || !task->request.arrHeaders[index].sValue) goto rejected;
	}
	if (request->pBody && request->iBodyLen) {
		task->request.pBody = (char*)malloc(request->iBodyLen);
		if (!task->request.pBody) goto rejected;
		memcpy(task->request.pBody, request->pBody, request->iBodyLen);
	}
	/* Transfer the anonymous upload file, not its contents. The original
	 * request retains its budget lease until response/async cleanup finishes. */
	task->request.pBodyFile = request->pBodyFile;
	((xhttpdrequest*)request)->pBodyFile = NULL;
	future = xTaskRunThread(DoraXrtDeferredRequestRun, task, 0);
	if (future) return future;
 rejected:
	DoraXrtDeferredRequestFree(task);
	__xnetAtomicAddFetch32(&server->activeRequests, -1);
	__xhttpdSendSimpleStatus(connection, 503, "Service Unavailable");
	return NULL;
}

static void DoraXrtHttpServerOnError(ptr owner, xhttpdserver* nativeServer, xhttpdconn* connection, int error) {
	DoraXrtHttpServer* server = (DoraXrtHttpServer*)owner;
	(void)nativeServer;
	(void)connection;
	if (server && server->events.onError) {
		server->events.onError(server->userData, error);
	}
}

DoraXrtHttpServer* DoraXrtHttpServerCreate(unsigned int port, size_t receiveLimit, const DoraXrtHttpServerEvents* events, void* userData) {
	DoraXrtHttpServer* server;
	xnetengine* engine;
	xhttpdconfig config;
	xhttpdevents nativeEvents;
	if (!events || !events->onRequest || port > 65535u || receiveLimit > UINT32_MAX) {
		return NULL;
	}
	engine = (xnetengine*)DoraXrtNetworkEngine();
	if (!engine) {
		return NULL;
	}
	server = (DoraXrtHttpServer*)calloc(1u, sizeof(DoraXrtHttpServer));
	if (!server) {
		return NULL;
	}
	server->events = *events;
	if (events->temporaryDirectory) {
		server->temporaryDirectory = DoraXrtDeferredString(events->temporaryDirectory);
		if (!server->temporaryDirectory) { free(server); return NULL; }
	}
	server->userData = userData;
	xrtHttpdConfigInit(&config);
	xrtNetAddrInitAny(&config.tBindAddr, AF_INET, (uint16)port);
	/* Reserve at most 32 MiB of body buffers across requests. Known lengths
	 * use their actual size; chunked bodies reserve the full per-body cap.
	 * Higher-layer copies remain bounded by the same request leases. */
	config.iRecvLimit = 256u * 1024u;
	config.iBodyLimit = (uint32)(receiveLimit && receiveLimit < 8u * 1024u * 1024u ? receiveLimit : 8u * 1024u * 1024u);
	config.iSpoolBodyLimit = (uint32)receiveLimit;
	config.iBufferedBodyBudget = 32u * 1024u * 1024u;
	config.iSpoolBodySlots = 2;
	config.iMaxConns = 64;
	config.iIdleTimeoutMs = 15000;
	config.OpenSpoolFile = DoraXrtOpenUploadFile;
	config.pSpoolContext = server;
	memset(&nativeEvents, 0, sizeof(nativeEvents));
	nativeEvents.OnRequestHead = DoraXrtHttpServerOnHead;
	nativeEvents.OnRequest = DoraXrtHttpServerOnRequest;
	nativeEvents.OnRequestAsync = DoraXrtHttpServerOnRequestAsync;
	nativeEvents.OnError = DoraXrtHttpServerOnError;
	server->native = xrtHttpdCreate(engine, &config, &nativeEvents, server);
	if (!server->native || xrtHttpdStart(server->native) != XRT_NET_OK) {
		if (server->native) {
			xrtHttpdDestroy(server->native);
		}
		free(server->temporaryDirectory);
		free(server);
		return NULL;
	}
	return server;
}

void DoraXrtHttpServerDestroy(DoraXrtHttpServer* server) {
	if (!server) {
		return;
	}
	if (server->native) {
		xrtHttpdDestroy(server->native);
		server->native = NULL;
	}
	while (__xnetAtomicLoad32(&server->activeRequests) != 0) xrtSleep(1u);
	free(server->temporaryDirectory);
	free(server);
}

const char* DoraXrtHttpServerRequestHeader(const DoraXrtHttpServerRequest* request, const char* name) {
	size_t index;
	if (!request || !name) {
		return NULL;
	}
	for (index = 0; index < request->headerCount; ++index) {
		if (DoraXrtStringEqualNoCase(request->headers[index].name, name)) {
			return request->headers[index].value;
		}
	}
	return NULL;
}

void DoraXrtHttpServerResponseSetStatus(DoraXrtHttpServerResponse* response, unsigned int statusCode, const char* reason) {
	if (response && response->native) {
		xrtHttpdResponseSetStatus(response->native, (uint32)statusCode, reason);
	}
}

int DoraXrtHttpServerResponseSetHeader(DoraXrtHttpServerResponse* response, const char* name, const char* value) {
	return response && response->native && xrtHttpdResponseSetHeader(response->native, name, value);
}

int DoraXrtHttpServerResponseSetBodyCopy(DoraXrtHttpServerResponse* response, const void* body, size_t bodyLen, const char* contentType) {
	return response && response->native && xrtHttpdResponseSetBodyCopy(response->native, body, bodyLen, contentType);
}

int DoraXrtPercentEncode(const char* input, size_t inputLen, char* output, size_t outputCap, size_t* outputLen, int spaceAsPlus) {
	return xrtPercentEncodeTo(input, inputLen, output, outputCap, outputLen, spaceAsPlus != 0);
}

int DoraXrtPercentDecode(const char* input, size_t inputLen, char* output, size_t outputCap, size_t* outputLen, int plusAsSpace) {
	return xrtPercentDecodeTo(input, inputLen, output, outputCap, outputLen, plusAsSpace != 0);
}

int DoraXrtMultipartForEachFile(const char* contentType, const void* body, size_t bodyLen, size_t maxBytes, DoraXrtMultipartFileHandler handler, void* userData) {
	xrtstrview boundary;
	xrthttputillimits limits;
	size_t offset = 0;
	xrtmultipartpartview part;
	if (!contentType || !body || !handler || !xrtMultipartBoundaryFromContentType(contentType, &boundary)) {
		return 0;
	}
	xrtHttpUtilLimitsInit(&limits);
	limits.iMaxMultipartBytes = maxBytes;
	if (!xrtMultipartValidateN(body, bodyLen, boundary.sPtr, boundary.iLen, &limits)) {
		return 0;
	}
	memset(&part, 0, sizeof(part));
	while (xrtMultipartNextN(body, bodyLen, boundary.sPtr, boundary.iLen, &offset, &part)) {
		DoraXrtMultipartFileView file;
		char* fileName;
		size_t fileNameLen = 0;
		int keepGoing;
		if ((part.iFlags & XRT_MULTIPART_F_HAS_FILENAME) == 0u) {
			continue;
		}
		fileName = (char*)malloc(part.tFileName.iLen * 3u + 1u);
		if (!fileName) {
			return 0;
		}
		if (!xrtMultipartDecodeFileNameTo(&part, fileName, part.tFileName.iLen * 3u + 1u, &fileNameLen)) {
			free(fileName);
			return 0;
		}
		fileName[fileNameLen] = '\0';
		memset(&file, 0, sizeof(file));
		file.fileName = fileName;
		file.fileNameLen = fileNameLen;
		file.body = part.tBody.sPtr;
		file.bodyLen = part.tBody.iLen;
		keepGoing = handler(userData, &file);
		free(fileName);
		if (!keepGoing) {
			return -1;
		}
	}
	return 1;
}

/* Reuse xrt's streaming multipart parser over the anonymous upload file.
 * Collect only bounded part metadata, validate the complete envelope first,
 * then expose file slices to the existing upload handlers. */
int DoraXrtMultipartFileForEachFile(const char* contentType, FILE* body, size_t bodyLen,
	size_t maxBytes, DoraXrtMultipartFileHandler handler, void* userData) {
	xrtstrview boundary;
	xrthttputillimits limits;
	xrtmultipartstream stream;
	struct Part { char* name; size_t nameLen, offset, size; } parts[64] = {{0}};
	char buffer[65536];
	size_t count = 0, fed = 0;
	int result = 0;
	if (!body || !handler || bodyLen > maxBytes ||
		!xrtMultipartBoundaryFromContentType(contentType, &boundary) ||
		!xrtMultipartStreamInit(&stream, boundary.sPtr, boundary.iLen, NULL)) return 0;
	xrtHttpUtilLimitsInit(&limits);
	limits.iMaxMultipartBytes = maxBytes;
	if (fseek(body, 0, SEEK_SET)) goto done;
	for (;;) {
		xrtmultipartstreamevent event;
		xrtmultipartstreamresult next = xrtMultipartStreamNext(&stream, &event);
		if (next == XRT_MULTIPART_STREAM_RESULT_ERROR) goto done;
		if (next == XRT_MULTIPART_STREAM_RESULT_END) break;
		if (next == XRT_MULTIPART_STREAM_RESULT_NEED_MORE) {
			if (fed == bodyLen) goto done;
			size_t bytes = bodyLen - fed;
			if (bytes > sizeof(buffer)) bytes = sizeof(buffer);
			if (fread(buffer, 1, bytes, body) != bytes || !xrtMultipartStreamFeed(&stream, buffer, bytes)) goto done;
			fed += bytes;
			if (fed == bodyLen) xrtMultipartStreamFinish(&stream);
		} else if (next == XRT_MULTIPART_STREAM_RESULT_PART_BEGIN) {
			if (count >= 64) goto done;
			/* Preserve the existing per-header/name/value checks on a tiny
			 * complete part, without copying any file data. */
			size_t cap = event.tPart.tHeaders.iLen + 2 * boundary.iLen + 32;
			char* check = (char*)malloc(cap);
			if (!check) goto done;
			int prefix = snprintf(check, cap, "--%.*s\r\n", (int)boundary.iLen, boundary.sPtr);
			memcpy(check + prefix, event.tPart.tHeaders.sPtr, event.tPart.tHeaders.iLen);
			size_t used = (size_t)prefix + event.tPart.tHeaders.iLen;
			int tail = snprintf(check + used, cap - used, "\r\n\r\n\r\n--%.*s--\r\n", (int)boundary.iLen, boundary.sPtr);
			bool valid = tail >= 0 && (size_t)tail < cap - used &&
				xrtMultipartValidateN(check, used + (size_t)tail, boundary.sPtr, boundary.iLen, &limits);
			free(check);
			if (!valid) goto done;
			parts[count].offset = fed - stream.iBufferLen + stream.iCursor;
			if (event.tPart.iFlags & XRT_MULTIPART_F_HAS_FILENAME) {
				size_t nameCap = limits.iMaxValueBytes * 3 + 1;
				parts[count].name = (char*)malloc(nameCap);
				if (!parts[count].name || !xrtMultipartDecodeFileNameTo(&event.tPart, parts[count].name, nameCap, &parts[count].nameLen)) goto done;
			}
		} else if (next == XRT_MULTIPART_STREAM_RESULT_DATA) {
			if (count >= 64 || event.tData.iLen > maxBytes - parts[count].size) goto done;
			parts[count].size += event.tData.iLen;
		} else if (next == XRT_MULTIPART_STREAM_RESULT_PART_END) {
			++count;
		}
	}
	result = 1;
	for (size_t i = 0; i < count; ++i) {
		if (!parts[i].name) continue;
		DoraXrtMultipartFileView view = {0};
		view.fileName = parts[i].name; view.fileNameLen = parts[i].nameLen;
		view.bodyFile = body; view.bodyOffset = parts[i].offset; view.bodyLen = parts[i].size;
		if (!handler(userData, &view)) { result = -1; break; }
	}
 done:
	xrtMultipartStreamUnit(&stream);
	for (size_t i = 0; i < 64; ++i) free(parts[i].name);
	return result;
}

int DoraXrtWebSocketIsLoopback(DoraXrtWebSocketConnection* connection) {
	xwsconn* native = (xwsconn*)connection;
	return native && DoraXrtStreamIsLoopback(native->pStream);
}

static uint32 DoraXrtWebSocketOnAuthorize(ptr owner, xwsserver* nativeServer, xwsconn* connection, const xcodechttp1msg* request) {
	DoraXrtWebSocketServer* server = (DoraXrtWebSocketServer*)owner;
	DoraXrtHttpHeaderView headers[XCODEC_HTTP1_MAX_HEADERS];
	(void)nativeServer;
	if (!server || !server->events.onAuthorize) return 0;
	for (size_t i = 0; i < request->iHeaderCount; ++i) {
		headers[i].name = request->arrHeaders[i].sName;
		headers[i].value = request->arrHeaders[i].sValue;
	}
	return (uint32)server->events.onAuthorize(server->userData, (DoraXrtWebSocketConnection*)connection, request->sTarget, headers, request->iHeaderCount);
}

static void DoraXrtWebSocketOnOpen(ptr owner, xwsserver* nativeServer, xwsconn* connection) {
	DoraXrtWebSocketServer* server = (DoraXrtWebSocketServer*)owner;
	(void)nativeServer;
	if (server && server->events.onOpen) {
		server->events.onOpen(server->userData, (DoraXrtWebSocketConnection*)connection);
	}
}

static void DoraXrtWebSocketOnText(ptr owner, xwsserver* nativeServer, xwsconn* connection, const char* data, size_t dataLen) {
	DoraXrtWebSocketServer* server = (DoraXrtWebSocketServer*)owner;
	(void)nativeServer;
	if (server && server->events.onText) {
		server->events.onText(server->userData, (DoraXrtWebSocketConnection*)connection, data, dataLen);
	}
}

static void DoraXrtWebSocketOnBinary(ptr owner, xwsserver* nativeServer, xwsconn* connection, const void* data, size_t dataLen) {
	DoraXrtWebSocketServer* server = (DoraXrtWebSocketServer*)owner;
	(void)nativeServer;
	if (server && server->events.onBinary) {
		server->events.onBinary(server->userData, (DoraXrtWebSocketConnection*)connection, data, dataLen);
	}
}

static void DoraXrtWebSocketOnClose(ptr owner, xwsserver* nativeServer, xwsconn* connection, xnet_result reason) {
	DoraXrtWebSocketServer* server = (DoraXrtWebSocketServer*)owner;
	(void)nativeServer;
	if (server && server->events.onClose) {
		server->events.onClose(server->userData, (DoraXrtWebSocketConnection*)connection, (int)reason);
	}
}

static void DoraXrtWebSocketOnError(ptr owner, xwsserver* nativeServer, xwsconn* connection, int error) {
	DoraXrtWebSocketServer* server = (DoraXrtWebSocketServer*)owner;
	(void)nativeServer;
	(void)connection;
	if (server && server->events.onError) {
		server->events.onError(server->userData, error);
	}
}

DoraXrtWebSocketServer* DoraXrtWebSocketServerCreate(unsigned int port, size_t receiveLimit, const DoraXrtWebSocketServerEvents* events, void* userData) {
	DoraXrtWebSocketServer* server;
	xwsserverconfig config;
	xwsserverevents nativeEvents;
	if (!events || port > 65535u || receiveLimit > UINT32_MAX) {
		return NULL;
	}
	server = (DoraXrtWebSocketServer*)calloc(1u, sizeof(DoraXrtWebSocketServer));
	if (!server) {
		return NULL;
	}
	server->events = *events;
	server->userData = userData;
	server->engine = (xnetengine*)DoraXrtNetworkEngineCreate(1u);
	if (!server->engine) {
		free(server);
		return NULL;
	}
	xrtWsServerConfigInit(&config);
	xrtNetAddrInitAny(&config.tBindAddr, AF_INET, (uint16)port);
	config.iRecvLimit = (uint32)receiveLimit;
	config.iMaxConns = 16;
	config.iHandshakeTimeoutMs = 15000;
	memset(&nativeEvents, 0, sizeof(nativeEvents));
	nativeEvents.OnAuthorizeRequest = DoraXrtWebSocketOnAuthorize;
	nativeEvents.OnOpen = DoraXrtWebSocketOnOpen;
	nativeEvents.OnText = DoraXrtWebSocketOnText;
	nativeEvents.OnBinary = DoraXrtWebSocketOnBinary;
	nativeEvents.OnClose = DoraXrtWebSocketOnClose;
	nativeEvents.OnError = DoraXrtWebSocketOnError;
	server->native = xrtWsServerCreate(server->engine, &config, &nativeEvents, server);
	if (!server->native || xrtWsServerStart(server->native) != XRT_NET_OK) {
		if (server->native) {
			xrtWsServerDestroy(server->native);
		}
		DoraXrtNetworkEngineDestroy(server->engine);
		free(server);
		return NULL;
	}
	return server;
}

void DoraXrtWebSocketServerDestroy(DoraXrtWebSocketServer* server) {
	if (!server) {
		return;
	}
	if (server->native) {
		xrtWsServerDestroy(server->native);
		server->native = NULL;
	}
	if (server->engine) {
		DoraXrtNetworkEngineDestroy(server->engine);
		server->engine = NULL;
	}
	free(server);
}

int DoraXrtWebSocketConnectionIsOpen(DoraXrtWebSocketConnection* connection) {
	return connection && xrtWsConnIsOpen((xwsconn*)connection);
}

int DoraXrtWebSocketConnectionSendBinary(DoraXrtWebSocketConnection* connection, const void* data, size_t dataLen) {
	return connection && xrtWsConnSendBinary((xwsconn*)connection, data, dataLen) == XRT_NET_OK;
}

void DoraXrtWebSocketConnectionClose(DoraXrtWebSocketConnection* connection, unsigned int code, const char* reason) {
	if (connection) {
		xrtWsConnClose((xwsconn*)connection, (uint16)code, reason);
	}
}

static int DoraXrtHttpIsRedirect(unsigned int statusCode) {
	return statusCode == 301u || statusCode == 302u || statusCode == 303u ||
		statusCode == 307u || statusCode == 308u;
}

static int DoraXrtHttpCopyResponse(const xhttpresponse* src, DoraXrtHttpResponse* dst) {
	size_t statusLineLen;
	if (!dst) {
		return 0;
	}
	dst->statusCode = src ? (int)src->iStatusCode : 0;
	dst->statusLine = NULL;
	dst->headers = NULL;
	dst->headerCount = 0;
	dst->body = NULL;
	dst->bodyLen = 0;
	if (!src) {
		return 1;
	}
	statusLineLen = strlen(src->sVersion) + strlen(src->sReason) + 32u;
	dst->statusLine = (char*)malloc(statusLineLen);
	if (!dst->statusLine) goto fail;
	(void)snprintf(dst->statusLine, statusLineLen, "%s %u %s",
		src->sVersion[0] ? src->sVersion : "HTTP/1.1",
		(unsigned int)src->iStatusCode,
		src->sReason);
	if (src->iHeaderCount > 0u) {
		dst->headers = (DoraXrtHttpHeader*)calloc(src->iHeaderCount, sizeof(DoraXrtHttpHeader));
		if (!dst->headers) goto fail;
		for (size_t i = 0; i < src->iHeaderCount; ++i) {
			const char* name = src->arrHeaders[i].sName ? src->arrHeaders[i].sName : "";
			const char* value = src->arrHeaders[i].sValue ? src->arrHeaders[i].sValue : "";
			dst->headerCount = i + 1u;
			dst->headers[i].name = (char*)malloc(strlen(name) + 1u);
			dst->headers[i].value = (char*)malloc(strlen(value) + 1u);
			if (!dst->headers[i].name || !dst->headers[i].value) goto fail;
			strcpy(dst->headers[i].name, name);
			strcpy(dst->headers[i].value, value);
		}
	}
	if (src->pBody && src->iBodyLen > 0u) {
		dst->body = (char*)malloc(src->iBodyLen);
		if (!dst->body) goto fail;
		memcpy(dst->body, src->pBody, src->iBodyLen);
		dst->bodyLen = src->iBodyLen;
	}
	return 1;

fail:
	free(dst->body);
	dst->body = NULL;
	dst->bodyLen = 0;
	for (size_t i = 0; i < dst->headerCount; ++i) {
		free(dst->headers[i].name);
		free(dst->headers[i].value);
	}
	free(dst->headers);
	dst->headers = NULL;
	dst->headerCount = 0;
	free(dst->statusLine);
	dst->statusLine = NULL;
	return 0;
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
	int serverClose;
	int headRequest;
	int interimResponses;
	struct DoraXrtHttpPooledConnection* owner;
	volatile long closeRequested;
	volatile long resolved;
	volatile long finalStatus;
} DoraXrtHttpStreamContext;

#define DORA_XRT_HTTP_POOL_SIZE 4
#define DORA_XRT_HTTP_POOL_IDLE_SECONDS 30.0

typedef struct DoraXrtHttpPooledConnection {
	xnetstream* stream;
	DoraXrtHttpStreamContext* active;
	char host[XHTTP_URL_CAP];
	unsigned short port;
	int https;
	int verifyPeer;
	int dead;
	int busy;
	int pooled;
	volatile long callbacks;
	double parkedAt;
} DoraXrtHttpPooledConnection;

static DoraXrtHttpPooledConnection g_httpPool[DORA_XRT_HTTP_POOL_SIZE];
static xmutex g_httpPoolLock = NULL;
static volatile long g_httpPoolLockOnce = 0;
static volatile long g_httpPoolFallbackLock = 0;
static __XNET_THREAD_LOCAL unsigned int g_httpPoolLockDepth = 0;

// Protect pool metadata and callback pins. Retiring a stream can re-enter
// OnClose synchronously, requiring same-thread reentrancy.
static void DoraXrtHttpPoolLockAcquire(void) {
	if (g_httpPoolLockDepth++ != 0) return;
	if (__xnetAtomicCompareExchange32(&g_httpPoolLockOnce, 1, 0) == 0) {
		g_httpPoolLock = xrtMutexCreate();
		__xnetAtomicExchange32(&g_httpPoolLockOnce, 2);
	}
	while (__xnetAtomicLoad32(&g_httpPoolLockOnce) != 2) xrtThreadYield();
	if (g_httpPoolLock) xrtMutexLock(g_httpPoolLock);
	else while (__xnetAtomicCompareExchange32(&g_httpPoolFallbackLock, 1, 0) != 0) xrtThreadYield();
}

static void DoraXrtHttpPoolLockRelease(void) {
	if (--g_httpPoolLockDepth != 0) return;
	if (g_httpPoolLock) xrtMutexUnlock(g_httpPoolLock);
	else __xnetAtomicExchange32(&g_httpPoolFallbackLock, 0);
}

static void DoraXrtHttpPoolDestroyStream(DoraXrtHttpPooledConnection* pc) {
	xnetstream* stream = pc->stream;
	pc->stream = NULL;
	if (stream) {
		// Destroy alone defers freeing a stream with an outstanding receive hold.
		// Abort first so idle sockets and their I/O holds are actually released.
		xrtNetStreamClose(stream, XNET_CLOSE_F_ABORT);
		xrtNetStreamDestroy(stream);
	}
}

/* Returns a pool slot for this request. If a matching idle connection exists,
 * pc->stream is set to it and pc->active is already bound; otherwise pc->stream
 * is NULL and the caller should connect a fresh stream into the slot. Returns
 * NULL when all slots are active; the caller then uses an unpooled owner. */
static DoraXrtHttpPooledConnection* DoraXrtHttpPoolAcquire(const xhttprequest* request, int verifyPeer, DoraXrtHttpStreamContext* ctx) {
	DoraXrtHttpPooledConnection* freeSlot = NULL;
	DoraXrtHttpPooledConnection* oldest = NULL;
	int i;
	DoraXrtHttpPoolLockAcquire();
	for (i = 0; i < DORA_XRT_HTTP_POOL_SIZE; ++i) {
		DoraXrtHttpPooledConnection* pc = &g_httpPool[i];
		// Reserved/connecting slots are active even before stream creation.
		if (pc->busy) continue;
		if (!pc->stream) {
			if (!freeSlot) freeSlot = pc;
			continue;
		}
		if (pc->dead || (xrtTimer() - pc->parkedAt) >= DORA_XRT_HTTP_POOL_IDLE_SECONDS) {
			DoraXrtHttpPoolDestroyStream(pc);
			pc->active = NULL;
			if (!freeSlot) freeSlot = pc;
			continue;
		}
		if (!oldest || pc->parkedAt < oldest->parkedAt) {
			oldest = pc;
		}
		if (!pc->active
			&& pc->https == (request->tURL.bHttps ? 1 : 0)
			&& pc->port == (unsigned short)request->tURL.iPort
			&& pc->verifyPeer == verifyPeer
			&& strcmp(pc->host, request->tURL.sHost) == 0) {
			pc->active = ctx;
			pc->busy = 1;
			DoraXrtHttpPoolLockRelease();
			return pc;
		}
	}
	if (!freeSlot) {
		if (!oldest) {
			DoraXrtHttpPoolLockRelease();
			return NULL;
		}
		DoraXrtHttpPoolDestroyStream(oldest);
		oldest->active = NULL;
		freeSlot = oldest;
	}
	freeSlot->active = ctx;
	freeSlot->busy = 1;
	freeSlot->pooled = 1;
	freeSlot->dead = 0;
	DoraXrtHttpPoolLockRelease();
	return freeSlot;
}

// Detach before waiting, so no new callback can obtain the stack context.
// Wait only for this connection's callbacks; never hold the pool lock while
// parsing/delivering response data or while waiting for a network worker.
static void DoraXrtHttpPoolParkOrRelease(DoraXrtHttpPooledConnection* pc, int parkable) {
	if (!pc) return;
	DoraXrtHttpPoolLockAcquire();
	DoraXrtHttpStreamContext* ctx = pc->active;
	pc->active = NULL;
	DoraXrtHttpPoolLockRelease();
	while (__xnetAtomicLoad32(&pc->callbacks) != 0) xrtThreadYield();
	DoraXrtHttpPoolLockAcquire();
	parkable = parkable && pc->pooled && ctx
		&& __xnetAtomicLoad32(&ctx->finalStatus) == XRT_NET_OK
		&& !ctx->streamError && ctx->headerParsed
		&& ctx->bodyMode != DORA_XRT_HTTP_BODY_CLOSE_DELIMITED
		&& !ctx->serverClose && __xnetAtomicLoad32(&ctx->closeRequested) == 0
		&& ctx->pendingLen == 0u && ctx->chunkRemaining == 0u;
	if (!parkable || pc->dead) DoraXrtHttpPoolDestroyStream(pc);
	else pc->parkedAt = xrtTimer();
	pc->busy = 0;
	DoraXrtHttpPoolLockRelease();
}

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
	__xnetAtomicCompareExchange32(&ctx->finalStatus, status, XRT_NET_AGAIN);
	if (__xnetAtomicCompareExchange32(&ctx->closeRequested, 1, 0) == 0) {
		if (ctx->stream) {
			xrtNetStreamClose(ctx->stream, XNET_CLOSE_F_ABORT);
			/* Abort close normally emits OnClose synchronously, but cancellation
			 * must not depend on that callback. In particular, a stalled network
			 * worker used to leave the request future unresolved and block engine
			 * shutdown forever. Resolving here is idempotent with OnClose, and a
			 * later deferred stream destroy clears its callbacks and user data. */
			DoraXrtHttpStreamResolve(ctx, (xnet_result)__xnetAtomicLoad32(&ctx->finalStatus));
		} else {
			DoraXrtHttpStreamResolve(ctx, (xnet_result)__xnetAtomicLoad32(&ctx->finalStatus));
		}
	}
}

/* Completes a request whose response ended cleanly (body framing satisfied and
 * no close requested): resolves the future but keeps the stream connected, so
 * the connection can be parked for reuse instead of being aborted. */
static void DoraXrtHttpStreamFinish(DoraXrtHttpStreamContext* ctx) {
	if (!ctx) {
		return;
	}
	__xnetAtomicCompareExchange32(&ctx->finalStatus, XRT_NET_OK, XRT_NET_AGAIN);
	DoraXrtHttpStreamResolve(ctx, (xnet_result)__xnetAtomicLoad32(&ctx->finalStatus));
}

int DoraXrtHttpAbortCloseFallbackTest(void) {
	DoraXrtHttpStreamContext ctx;
	xnetengine* engine;
	xnet_result status;
	int passed = 0;

	if (!DoraXrtHttpAttachRuntimeThread()) {
		return 0;
	}
	memset(&ctx, 0, sizeof(ctx));
	ctx.finalStatus = XRT_NET_AGAIN;
	ctx.future = xrtNetFutureCreate();
	engine = xrtNetSyncGetHiddenEngine();
	ctx.stream = engine ? xrtNetStreamCreate(engine, NULL, NULL) : NULL;
	if (ctx.future && ctx.stream) {
		DoraXrtHttpStreamCloseWith(&ctx, XRT_NET_CANCELLED);
		status = xrtNetFutureWait(ctx.future, 0u);
		passed = status == XRT_NET_CANCELLED;
	}
	if (ctx.stream) {
		xrtNetStreamDestroy(ctx.stream);
	}
	if (ctx.future) {
		xrtNetFutureDestroy(ctx.future);
	}
	xrtThreadDetachCurrent();
	return passed;
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
	ctx->serverClose |= strncmp(line, "HTTP/1.1 ", 9u) != 0 || ctx->statusCode == 101;
	ctx->noBody = ctx->headRequest || (ctx->statusCode >= 100 && ctx->statusCode < 200) || ctx->statusCode == 204 || ctx->statusCode == 304;
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
			if (!__xhttpStrEqNoCase(value, "chunked")) ctx->serverClose = 1;
		} else if (__xhttpStrEqNoCase(line, "Connection")) {
			if (xrtHttpHeaderContainsToken(value, "close")) {
				ctx->serverClose = 1;
			}
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
	if (ctx->statusCode >= 100 && ctx->statusCode < 200 && ctx->statusCode != 101) {
		if (++ctx->interimResponses > 8) return 0;
		ctx->statusCode = 0; ctx->noBody = 0; ctx->chunked = 0;
		ctx->hasContentLength = 0; ctx->contentLength = 0; ctx->suppressBody = 0;
		ctx->redirectLocation[0] = '\0';
		return DoraXrtHttpParseHeaders(ctx);
	}
	if (ctx->chunked && ctx->hasContentLength) ctx->serverClose = 1;
	ctx->headerParsed = 1;
	if (ctx->noBody) {
		ctx->bodyMode = DORA_XRT_HTTP_BODY_NONE;
		DoraXrtHttpStreamFinish(ctx);
	} else if (ctx->chunked) {
		ctx->bodyMode = DORA_XRT_HTTP_BODY_CHUNKED;
	} else if (ctx->hasContentLength) {
		ctx->bodyMode = DORA_XRT_HTTP_BODY_CONTENT_LENGTH;
		if (ctx->contentLength == 0u) {
			DoraXrtHttpStreamFinish(ctx);
		}
	} else {
		ctx->bodyMode = DORA_XRT_HTTP_BODY_CLOSE_DELIMITED;
	}
	return 1;
}

static int DoraXrtHttpDeliverChunk(DoraXrtHttpStreamContext* ctx, const char* data, size_t len, size_t total) {
	if (!ctx || len == 0u || ctx->suppressBody || __xnetAtomicLoad32(&ctx->closeRequested) != 0) {
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
		DoraXrtHttpStreamFinish(ctx);
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
		DoraXrtHttpStreamFinish(ctx);
		return 1;
	}
	trailerEnd = DoraXrtHttpFindBytes(ctx->pending, ctx->pendingLen, "\r\n\r\n", 4u);
	if (trailerEnd != (size_t)-1) {
		if (trailerEnd + 4u > DORA_XRT_HTTP_MAX_HEADER_BYTES) {
			DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
			return 0;
		}
		DoraXrtHttpStreamConsume(ctx, trailerEnd + 4u);
		DoraXrtHttpStreamFinish(ctx);
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

static void DoraXrtHttpStreamHandleOpen(ptr owner, xnetstream* stream) {
	DoraXrtHttpStreamContext* ctx = (DoraXrtHttpStreamContext*)owner;
	if (!ctx || !stream || __xnetAtomicLoad32(&ctx->closeRequested) != 0) {
		return;
	}
	if (xrtNetStreamSend(stream, ctx->requestBytes, ctx->requestLen) != XRT_NET_OK) {
		DoraXrtHttpStreamCloseWith(ctx, XRT_NET_ERROR);
	}
}

static void DoraXrtHttpStreamHandleRecv(ptr owner, xnetstream* stream, xnetchain* chain) {
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

static void DoraXrtHttpStreamHandleClose(ptr owner, xnetstream* stream, xnet_result reason) {
	DoraXrtHttpStreamContext* ctx = (DoraXrtHttpStreamContext*)owner;
	xnet_result status;
	(void)stream;
	if (!ctx) {
		return;
	}
	if (__xnetAtomicLoad32(&ctx->closeRequested) != 0) {
		DoraXrtHttpStreamResolve(ctx, (xnet_result)__xnetAtomicLoad32(&ctx->finalStatus));
		return;
	}
	if (__xnetAtomicLoad32(&ctx->finalStatus) == XRT_NET_AGAIN) {
		(void)DoraXrtHttpStreamProcess(ctx);
	}
	if (__xnetAtomicLoad32(&ctx->finalStatus) == XRT_NET_AGAIN) {
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
		__xnetAtomicCompareExchange32(&ctx->finalStatus, status, XRT_NET_AGAIN);
	}
	DoraXrtHttpStreamResolve(ctx, (xnet_result)__xnetAtomicLoad32(&ctx->finalStatus));
}

static void DoraXrtHttpStreamHandleError(ptr owner, xnetstream* stream, int sysErr) {
	(void)stream;
	DoraXrtHttpStreamContext* ctx = (DoraXrtHttpStreamContext*)owner;
	if (!ctx) {
		return;
	}
	ctx->streamError = 1;
	ctx->streamSysErr = sysErr;
}

static DoraXrtHttpStreamContext* DoraXrtPooledContext(ptr owner, xnetstream* stream, int terminal) {
	DoraXrtHttpPooledConnection* pc = (DoraXrtHttpPooledConnection*)owner;
	DoraXrtHttpStreamContext* ctx = NULL;
	DoraXrtHttpPoolLockAcquire();
	// Destroy clears stream callbacks/userdata before a stack owner can expire.
	// Test stream identity before dereferencing even an already captured owner.
	if (stream && stream->pEvents && stream->pUserData == owner && pc && pc->stream == stream) {
		if (terminal || !pc->active) pc->dead = 1;
		ctx = pc->active;
		if (ctx) __xnetAtomicAddFetch32(&pc->callbacks, 1);
	}
	DoraXrtHttpPoolLockRelease();
	return ctx;
}
static void DoraXrtPooledOnOpen(ptr owner, xnetstream* stream) {
	DoraXrtHttpStreamContext* ctx = DoraXrtPooledContext(owner, stream, 0);
	if (ctx) { DoraXrtHttpStreamHandleOpen(ctx, stream); __xnetAtomicAddFetch32(&ctx->owner->callbacks, -1); }
}
static void DoraXrtPooledOnRecv(ptr owner, xnetstream* stream, xnetchain* chain) {
	DoraXrtHttpStreamContext* ctx = DoraXrtPooledContext(owner, stream, 0);
	if (ctx) { DoraXrtHttpStreamHandleRecv(ctx, stream, chain); __xnetAtomicAddFetch32(&ctx->owner->callbacks, -1); }
	else {
		DoraXrtHttpPoolLockAcquire();
		if (stream && stream->pEvents && stream->pUserData == owner) xrtNetStreamClose(stream, XNET_CLOSE_F_ABORT);
		DoraXrtHttpPoolLockRelease();
	}
}
static void DoraXrtPooledOnClose(ptr owner, xnetstream* stream, xnet_result reason) {
	DoraXrtHttpStreamContext* ctx = DoraXrtPooledContext(owner, stream, 1);
	if (ctx) { DoraXrtHttpStreamHandleClose(ctx, stream, reason); __xnetAtomicAddFetch32(&ctx->owner->callbacks, -1); }
}
static void DoraXrtPooledOnError(ptr owner, xnetstream* stream, int sysErr) {
	DoraXrtHttpStreamContext* ctx = DoraXrtPooledContext(owner, stream, 1);
	if (ctx) { DoraXrtHttpStreamHandleError(ctx, stream, sysErr); __xnetAtomicAddFetch32(&ctx->owner->callbacks, -1); }
}

static const xnetstreamevents* DoraXrtPooledStreamEvents(void) {
	static const xnetstreamevents events = {
		DoraXrtPooledOnOpen,
		DoraXrtPooledOnRecv,
		NULL,
		DoraXrtPooledOnClose,
		DoraXrtPooledOnError,
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
	DoraXrtHttpPooledConnection standaloneOwner = {0};
	xnet_result status = XRT_NET_ERROR;
	int reused;
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
	ctx.headRequest = __xhttpStrEqNoCase(method, "HEAD");
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
			if (__xhttpStrEqNoCase(headerNames[i], "Connection") && xrtHttpHeaderContainsToken(headerValues[i], "close")) ctx.serverClose = 1;
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
	DoraXrtHttpPoolLockAcquire();
	reused = 0;
	for (int attempt = 0; attempt <= DORA_XRT_HTTP_POOL_SIZE; ++attempt) {
		ctx.owner = DoraXrtHttpPoolAcquire(&request, verifyPeer, &ctx);
		ctx.stream = ctx.owner ? ctx.owner->stream : NULL;
		if (!ctx.stream) break;
		if (xrtNetStreamSend(ctx.stream, ctx.requestBytes, ctx.requestLen) == XRT_NET_OK) {
			reused = 1; break;
		}
		// Only retry a rejected send. Never replay a POST after an accepted send.
		DoraXrtHttpPoolParkOrRelease(ctx.owner, 0);
		ctx.owner = NULL; ctx.stream = NULL;
	}
	DoraXrtHttpPoolLockRelease();
	if (!reused && ctx.owner && !ctx.owner->stream) {
		DoraXrtHttpPoolLockAcquire();
		ctx.owner->https = request.tURL.bHttps ? 1 : 0;
		ctx.owner->port = (unsigned short)request.tURL.iPort;
		ctx.owner->verifyPeer = verifyPeer;
		snprintf(ctx.owner->host, sizeof(ctx.owner->host), "%s", request.tURL.sHost);
		ctx.stream = xrtNetStreamCreate(engine, DoraXrtPooledStreamEvents(), ctx.owner);
		if (ctx.stream) {
			ctx.owner->stream = ctx.stream;
		}
		DoraXrtHttpPoolLockRelease();
	}
	if (!reused && !ctx.stream) {
		if (ctx.owner) { DoraXrtHttpPoolParkOrRelease(ctx.owner, 0); ctx.owner = NULL; }
		ctx.owner = &standaloneOwner;
		ctx.owner->active = &ctx; ctx.owner->busy = 1;
		ctx.stream = xrtNetStreamCreate(engine, DoraXrtPooledStreamEvents(), ctx.owner);
		ctx.owner->stream = ctx.stream;
	}
	if (!ctx.stream) {
		status = XRT_NET_ERROR;
		goto cleanup;
	}
	if (!reused) {
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
		// A resolved timeout is a result, not another poll timeout.
		if (__xnetAtomicLoad32(&ctx.resolved) != 0) { status = (xnet_result)__xnetAtomicLoad32(&ctx.finalStatus); break; }
	}
cleanup:
	if (ctx.owner) DoraXrtHttpPoolParkOrRelease(ctx.owner, status == XRT_NET_OK);
	ctx.stream = NULL;
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
	for (size_t i = 0; i < response->headerCount; ++i) {
		free(response->headers[i].name);
		free(response->headers[i].value);
	}
	free(response->headers);
	free(response->statusLine);
	response->body = NULL;
	response->bodyLen = 0;
	response->headers = NULL;
	response->headerCount = 0;
	response->statusLine = NULL;
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

int DoraXrtSha256FileHex(FILE* file, char outHex[65]) {
	xsha256_ctx context;
	uint8 digest[32];
	char buffer[65536];
	if (!file || !outHex || fseek(file, 0, SEEK_SET)) return 0;
	xrtSHA256Init(&context);
	size_t count;
	while ((count = fread(buffer, 1, sizeof(buffer), file)) != 0) xrtSHA256Update(&context, buffer, count);
	if (ferror(file)) return 0;
	xrtSHA256Final(&context, digest);
	DoraXrtToHex(digest, sizeof(digest), outHex);
	return 1;
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
