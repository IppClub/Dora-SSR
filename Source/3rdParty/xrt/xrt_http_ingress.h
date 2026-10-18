/* Optional bounded HTTP ingress for xhttpd. Included by xrt.h after its helpers.
 * Socket workers own framing; request leases survive deferred handlers/close.
 * Bodies selected for spooling never become an in-memory request buffer. */
static void __xhttpdReleaseBodyLease(ptr opaque) {
	__xhttpd_body_lease* lease = (__xhttpd_body_lease*)opaque;
	__xhttpd_body_budget* budget = lease->budget;
	__xnetAtomicAddFetch32(lease->spool ? &budget->spooled : &budget->buffered, -lease->amount);
	if (__xnetAtomicAddFetch32(&budget->refs, -1) == 0) free(budget);
	free(lease);
}

static int __xhttpdIngressError(xhttpdconn* conn, uint32 status) {
	__xhttpdRequestDestroy(conn->pIncoming);
	conn->pIncoming = NULL;
	__xhttpdSendSimpleStatus(conn, status, __xhttpdStatusText(status));
	return -1;
}

/* Returns 1 for a complete line, 0 for more bytes, -1 for an oversized line. */
static int __xhttpdIngressLine(xnetchain* chain, char* line, size_t cap, size_t* len) {
	size_t available = xrtNetChainBytes(chain);
	size_t bytes = available < cap ? available : cap;
	xrtNetChainPeek(chain, line, bytes);
	for (size_t i = 1; i < bytes; ++i) {
		if (line[i - 1] == '\r' && line[i] == '\n') {
			line[i - 1] = 0; *len = i - 1;
			xrtNetChainConsume(chain, i + 1); return 1;
		}
	}
	return available >= cap ? -1 : 0;
}

/* Reserve the declared size (or worst-case chunked size) before allocation. */
static uint32 __xhttpdBeginIngress(xhttpdconn* conn, xnetchain* chain) {
	xhttpdserver* server = conn->pServer;
	xcodecframe frame;
	xcodechttp1msg msg;
	xcodecstatus parsed;
	xhttpdrequest* req;
	size_t end = __xcodecChainFindPattern(chain, (const uint8*)"\r\n\r\n", 4, 0);
	if (end == SIZE_MAX) return xrtNetChainBytes(chain) > 65536 ? 431 : 0;
	if (end + 4 > 65536) return 431;
	parsed = __xcodecHttp1Parse(chain, &frame, &msg, true);
	if (parsed != XCODEC_STATUS_FRAME) return 400;
	if ((msg.iFlags & XCODEC_HTTP1_F_RESPONSE) ||
		((msg.iFlags & XCODEC_HTTP1_F_CHUNKED) && msg.iContentLength >= 0) ||
		(xrtCodecHttp1GetHeader(&msg, "Transfer-Encoding") &&
		 !__xhttpdStrEqNoCase(xrtCodecHttp1GetHeader(&msg, "Transfer-Encoding"), "chunked"))) {
		xrtCodecHttp1MessageUnit(&msg); return 400;
	}
	req = __xhttpdRequestCreate();
	if (!req) { xrtCodecHttp1MessageUnit(&msg); return 503; }
	frame.iPayloadBytes = frame.iMeta0 = 0;
	if (!__xhttpdBuildRequest(&frame, &msg, chain, req, 0)) {
		xrtCodecHttp1MessageUnit(&msg); __xhttpdRequestDestroy(req); return 400;
	}
	/* BuildRequest rewrites chunked Content-Length to decoded size; retain
	 * the wire framing here until streaming is complete. */
	req->iContentLength = msg.iContentLength;
	conn->pIncoming = req;
	uint32 status = server->tEvents.OnRequestHead
		? server->tEvents.OnRequestHead(server->pUserData, server, conn, req) : 0;
	conn->iIncomingLimit = (req->iFlags & XHTTPD_REQ_F_SPOOL)
		? server->tConfig.iSpoolBodyLimit : server->tConfig.iBodyLimit;
	if (!status && req->iContentLength > (int64_t)conn->iIncomingLimit) status = 413;
	if (!status && ((req->iFlags & XHTTPD_REQ_F_CHUNKED) || req->iContentLength > 0)) {
		bool spool = (req->iFlags & XHTTPD_REQ_F_SPOOL) != 0;
		__xhttpd_body_budget* budget = server->pBodyBudget;
		volatile long* counter = spool ? &budget->spooled : &budget->buffered;
		uint32 limit = spool ? server->tConfig.iSpoolBodySlots : server->tConfig.iBufferedBodyBudget;
		long amount = spool ? 1 : (long)((req->iFlags & XHTTPD_REQ_F_CHUNKED) ? conn->iIncomingLimit : (size_t)req->iContentLength);
		long count = __xnetAtomicAddFetch32(counter, amount);
		if (count > (long)limit) { __xnetAtomicAddFetch32(counter, -amount); status = 503; }
		else {
			__xhttpd_body_lease* lease = (__xhttpd_body_lease*)malloc(sizeof(*lease));
			if (!lease) { __xnetAtomicAddFetch32(counter, -amount); status = 503; }
			else {
				__xnetAtomicAddFetch32(&budget->refs, 1);
				lease->budget = budget; lease->amount = amount; lease->spool = spool;
				req->pBodyLease = lease; req->ReleaseBodyLease = __xhttpdReleaseBodyLease;
				if (spool) {
					req->pBodyFile = server->tConfig.OpenSpoolFile
						? server->tConfig.OpenSpoolFile(server->tConfig.pSpoolContext) : tmpfile();
					if (!req->pBodyFile) status = 507;
				} else {
					size_t cap = (req->iFlags & XHTTPD_REQ_F_CHUNKED) ? conn->iIncomingLimit : (size_t)req->iContentLength;
					req->pBody = (char*)XNET_ALLOC(cap + 1);
					if (!req->pBody) status = 503;
				}
			}
		}
	}
	conn->iBodyRemaining = req->iContentLength > 0 ? (size_t)req->iContentLength : 0;
	conn->iChunkState = conn->iTrailerBytes = 0;
	xrtCodecHttp1MessageUnit(&msg);
	if (status) return status;
	xrtNetChainConsume(chain, end + 4);
	if (__xhttpdContainsTokenNoCase(xrtHttpdRequestHeader(req, "Expect"), "100-continue"))
		(void)xrtNetStreamSend(conn->pStream, "HTTP/1.1 100 Continue\r\n\r\n", 25);
	return 0;
}

static int __xhttpdWriteIngress(xhttpdconn* conn, xnetchain* chain, size_t bytes) {
	char buffer[16384];
	xhttpdrequest* req = conn->pIncoming;
	if (bytes > conn->iIncomingLimit - req->iBodyLen) return 413;
	while (bytes) {
		size_t take = bytes < sizeof(buffer) ? bytes : sizeof(buffer);
		if (req->pBodyFile) {
			if (xrtNetChainPeek(chain, buffer, take) != take || fwrite(buffer, 1, take, req->pBodyFile) != take) return 507;
		} else {
			if (xrtNetChainPeek(chain, req->pBody + req->iBodyLen, take) != take) return 400;
		}
		xrtNetChainConsume(chain, take); req->iBodyLen += take; bytes -= take;
	}
	return 0;
}

static int __xhttpdReadIngress(xhttpdconn* conn, xnetstream* stream, xnetchain* chain, xhttpdrequest** output) {
	uint32 status;
	(void)stream;
	if (!conn->pIncoming) {
		status = __xhttpdBeginIngress(conn, chain);
		if (status) return __xhttpdIngressError(conn, status);
		if (!conn->pIncoming) return 0;
	}
	xhttpdrequest* req = conn->pIncoming;
	if (req->iFlags & XHTTPD_REQ_F_CHUNKED) {
		while (conn->iChunkState != 4) {
			size_t available = xrtNetChainBytes(chain), len = 0;
			char line[8192];
			if (conn->iChunkState == 0 || conn->iChunkState == 3) {
				int got = __xhttpdIngressLine(chain, line, conn->iChunkState == 0 ? 128 : sizeof(line), &len);
				if (!got) return 0;
				if (got < 0) return __xhttpdIngressError(conn, 400);
				if (conn->iChunkState == 3) {
					conn->iTrailerBytes += len + 2;
					if (conn->iTrailerBytes > 65536 || (len && !strchr(line, ':'))) return __xhttpdIngressError(conn, 400);
					if (!len) conn->iChunkState = 4;
				} else {
					size_t size = 0, digits = 0;
					while (digits < len && isxdigit((unsigned char)line[digits])) {
						unsigned char ch = (unsigned char)tolower((unsigned char)line[digits++]);
						unsigned value = ch <= '9' ? ch - '0' : ch - 'a' + 10;
						if (size > (SIZE_MAX - value) / 16) return __xhttpdIngressError(conn, 413);
						size = size * 16 + value;
					}
					if (!digits || (digits < len && line[digits] != ';')) return __xhttpdIngressError(conn, 400);
					if (size > conn->iIncomingLimit - req->iBodyLen) return __xhttpdIngressError(conn, 413);
					conn->iBodyRemaining = size;
					conn->iChunkState = size ? 1 : 3;
				}
			} else if (conn->iChunkState == 1) {
				size_t take = available < conn->iBodyRemaining ? available : conn->iBodyRemaining;
				if (!take) return 0;
				status = __xhttpdWriteIngress(conn, chain, take);
				if (status) return __xhttpdIngressError(conn, status);
				conn->iBodyRemaining -= take;
				if (!conn->iBodyRemaining) conn->iChunkState = 2;
			} else {
				if (available < 2) return 0;
				xrtNetChainPeek(chain, line, 2);
				if (memcmp(line, "\r\n", 2)) return __xhttpdIngressError(conn, 400);
				xrtNetChainConsume(chain, 2); conn->iChunkState = 0;
			}
		}
	} else {
		size_t take = xrtNetChainBytes(chain);
		if (take > conn->iBodyRemaining) take = conn->iBodyRemaining;
		status = __xhttpdWriteIngress(conn, chain, take);
		if (status) return __xhttpdIngressError(conn, status);
		conn->iBodyRemaining -= take;
		if (conn->iBodyRemaining) return 0;
	}
	if (req->pBodyFile) {
		if (fflush(req->pBodyFile) || fseek(req->pBodyFile, 0, SEEK_SET)) return __xhttpdIngressError(conn, 507);
	} else if (req->pBody) req->pBody[req->iBodyLen] = 0;
	req->iContentLength = (int64_t)req->iBodyLen;
	*output = req; conn->pIncoming = NULL;
	return 1;
}

static void __xhttpdIngressTimer(xnetworker* worker, ptr arg) {
	xhttpdconn* conn = (xhttpdconn*)arg;
	(void)worker;
	/* Timers run on the owning socket worker. The reference keeps conn alive
	 * after close; a detached/closing connection never touches its server. */
	if (!__xhttpdAtomicLoad(&conn->iCleanupPosted) && conn->pStream && !conn->pStream->bClosing) {
		double now = xrtTimer();
		double idle = conn->pServer->tConfig.iIdleTimeoutMs / 1000.0;
		bool receiving = !conn->bResponseInFlight;
		double deadline = conn->pIncoming && conn->pIncoming->pBodyFile ? 600.0 : 30.0;
		if (receiving && (now - conn->tLastReceive >= idle || now - conn->tRequestStarted >= deadline)) {
			__xhttpdIngressError(conn, 408);
		} else {
			__xhttpdStartIngressTimer(conn);
		}
	}
	__xhttpdConnRelease(conn);
}
static void __xhttpdStartIngressTimer(xhttpdconn* conn) {
	xnetstream* stream = conn->pStream;
	if (xrtNetEnginePostDelayed(stream->pEngine, stream->pWorker->iId, 1000,
		__xhttpdIngressTimer, __xhttpdConnAddRef(conn)) != XRT_NET_OK) {
		__xhttpdConnRelease(conn);
		xrtNetStreamClose(stream, XNET_CLOSE_F_ABORT);
	}
}
