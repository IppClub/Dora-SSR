/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

(function installDoraWebNetwork(global) {
	"use strict";

	const HARD_MAX_RESPONSE_BYTES = 64 * 1024 * 1024;
	const inboundReason = "browser pages cannot bind inbound TCP/HTTP ports";
	const capabilities = Object.freeze({
		httpClient: true,
		httpServer: false,
		webSocketClient: true,
		webSocketServer: false,
		httpServerReason: inboundReason,
		webSocketServerReason: inboundReason,
	});

	class DoraWebNetworkError extends Error {
		constructor(code, message, cause) {
			super(message, cause === undefined ? undefined : {cause});
			this.name = "DoraWebNetworkError";
			this.code = code;
		}
	}

	function networkError(code, message, cause) {
		return new DoraWebNetworkError(code, message, cause);
	}

	function checkedUrl(input, allowedOrigins) {
		const url = new URL(String(input), global.location.href);
		if (url.protocol !== "http:" && url.protocol !== "https:") {
			throw networkError("URL", `unsupported URL protocol: ${url.protocol}`);
		}
		const allowed = new Set([global.location.origin]);
		for (const origin of allowedOrigins || []) allowed.add(new URL(origin, global.location.href).origin);
		if (!allowed.has(url.origin)) {
			throw networkError("ORIGIN", `cross-origin request is not allowed: ${url.origin}`);
		}
		return url;
	}

	function checkedLimit(value) {
		if (value === undefined) return HARD_MAX_RESPONSE_BYTES;
		if (!Number.isSafeInteger(value) || value < 0 || value > HARD_MAX_RESPONSE_BYTES) {
			throw networkError("LIMIT", `maxBytes must be an integer from 0 to ${HARD_MAX_RESPONSE_BYTES}`);
		}
		return value;
	}

	function start(input, options = {}) {
		const url = checkedUrl(input, options.allowedOrigins);
		const maxBytes = checkedLimit(options.maxBytes);
		const timeoutMs = options.timeoutMs === undefined ? 0 : Number(options.timeoutMs);
		if (!Number.isFinite(timeoutMs) || timeoutMs < 0) throw networkError("TIMEOUT", "timeoutMs must be a non-negative number");
		const controller = new AbortController();
		let abortKind = null;
		let timer = null;
		const externalSignal = options.signal;
		const abortFromSignal = () => {
			abortKind = "CANCELLED";
			controller.abort(externalSignal?.reason);
		};
		if (externalSignal?.aborted) abortFromSignal();
		else externalSignal?.addEventListener("abort", abortFromSignal, {once: true});
		if (timeoutMs > 0) {
			timer = global.setTimeout(() => {
				abortKind = "TIMEOUT";
				controller.abort();
			}, timeoutMs);
		}

		const promise = (async () => {
			try {
				const response = await global.fetch(url, {
					method: options.method || "GET",
					headers: options.headers,
					body: options.body,
					cache: options.cache || "no-store",
					credentials: options.credentials || "same-origin",
					signal: controller.signal,
				});
				const declared = Number(response.headers.get("content-length"));
				if (Number.isFinite(declared) && declared > maxBytes) {
					controller.abort();
					throw networkError("SIZE", `response exceeds ${maxBytes} bytes`);
				}
				const chunks = [];
				let received = 0;
				if (response.body?.getReader) {
					const reader = response.body.getReader();
					while (true) {
						const {done, value} = await reader.read();
						if (done) break;
						received += value.byteLength;
						if (received > maxBytes) {
							await reader.cancel();
							throw networkError("SIZE", `response exceeds ${maxBytes} bytes`);
						}
						chunks.push(value);
						options.onProgress?.(received, Number.isFinite(declared) ? declared : 0);
					}
				} else {
					const bytes = new Uint8Array(await response.arrayBuffer());
					received = bytes.byteLength;
					if (received > maxBytes) throw networkError("SIZE", `response exceeds ${maxBytes} bytes`);
					chunks.push(bytes);
					options.onProgress?.(received, Number.isFinite(declared) ? declared : received);
				}
				const body = new Uint8Array(received);
				let offset = 0;
				for (const chunk of chunks) {
					body.set(chunk, offset);
					offset += chunk.byteLength;
				}
				return {
					ok: response.ok,
					status: response.status,
					statusText: response.statusText,
					headers: Object.fromEntries(response.headers.entries()),
					body,
					text: () => new TextDecoder().decode(body),
				};
			} catch (error) {
				if (error instanceof DoraWebNetworkError) throw error;
				if (controller.signal.aborted) {
					const code = abortKind || "CANCELLED";
					throw networkError(code, code === "TIMEOUT" ? `request timed out after ${timeoutMs} ms` : "request cancelled", error);
				}
				throw networkError("NETWORK", "request failed; check connectivity and CORS policy", error);
			} finally {
				if (timer !== null) global.clearTimeout(timer);
				externalSignal?.removeEventListener("abort", abortFromSignal);
			}
		})();

		return Object.freeze({
			promise,
			cancel() {
				if (controller.signal.aborted) return false;
				abortKind = "CANCELLED";
				controller.abort();
				return true;
			},
		});
	}

	function unsupportedServer(kind) {
		return Object.freeze({supported: false, kind, reason: inboundReason});
	}

	const api = Object.freeze({
		HARD_MAX_RESPONSE_BYTES,
		capabilities,
		start,
		get(input, options) {
			return start(input, {...options, method: "GET"});
		},
		post(input, body, options) {
			return start(input, {...options, method: "POST", body});
		},
		startHttpServer() {
			return unsupportedServer("http");
		},
		startWebSocketServer() {
			return unsupportedServer("websocket");
		},
	});
	global.DoraWebNetwork = api;
	global.Module = global.Module || {};
	global.Module.doraWebCapabilities = capabilities;
})(globalThis);
