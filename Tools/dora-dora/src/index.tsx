/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import ReactDOM from 'react-dom/client';
import './index.css';
import reportWebVitals from './reportWebVitals';
import React from 'react';
import * as Service from './Service';
import i18n from './i18n';
import Info from './Info';
import Path from './3rdParty/Path';
import AuthDialog, { AuthDialogProps, AuthSession } from './AuthDialog';

export const showAuthDialog = ({origFetch, onToken}: AuthDialogProps) => {
	const container = document.createElement('div');
	document.body.appendChild(container);
	const modalRoot = ReactDOM.createRoot(container);
	return new Promise<AuthSession>((resolve) => {
		const cleanup = (nextToken: AuthSession) => {
			modalRoot.unmount();
			container.remove();
			resolve(nextToken);
		};

		const handleToken = (session: AuthSession) => {
			onToken(session);
			cleanup(session);
		};

		modalRoot.render(<AuthDialog origFetch={origFetch} onToken={handleToken} />);
	});
};

const setupAuth = async (): Promise<void> => {
	const hasAuthRequiredCookie = () => !document.cookie
		.split(';')
		.some((part) => part.trim().startsWith('DoraAuthRequired=0'));
	const isAuthBypassUrl = (input: RequestInfo | URL) => {
		const url = input instanceof Request ? input.url : String(input);
		return url.includes('/auth');
	};
	const storageKey = 'doraWebAuthSession';
	const parseSession = (raw: string | null): AuthSession | null => {
		if (!raw) return null;
		try {
			const parsed = JSON.parse(raw) as AuthSession;
			if (parsed && parsed.sessionId && parsed.sessionSecret) {
				return parsed;
			}
		} catch (err) {
			void err;
		}
		return null;
	};
	let session = parseSession(localStorage.getItem(storageKey));
	let authRequired = hasAuthRequiredCookie();
	let authInFlight: Promise<AuthSession | null> | null = null;
	let signingKeyPromise: Promise<CryptoKey> | null = null;

	const normalizeSession = (nextSession: AuthSession | null) => {
		if (nextSession && nextSession.sessionId && nextSession.sessionSecret) {
			return nextSession;
		}
		return null;
	};

	const setSession = (nextSession: AuthSession | null) => {
		session = normalizeSession(nextSession);
		signingKeyPromise = null;
		if (session) {
			localStorage.setItem(storageKey, JSON.stringify(session));
		} else {
			localStorage.removeItem(storageKey);
		}
	};

	(window as any).__setDoraAuthToken = (nextToken: AuthSession | string) => {
		if (typeof nextToken === 'string') {
			setSession(parseSession(nextToken));
		} else {
			setSession(nextToken);
		}
	};

	const origFetch = window.fetch ? window.fetch.bind(window) : null;
	let modalInFlight: Promise<AuthSession> | null = null;

	const showAuthModal = () => {
		if (!origFetch) return Promise.resolve({sessionId: '', sessionSecret: ''});
		Service.getWebSocket()?.close();
		return showAuthDialog({
			origFetch,
			onToken: (nextSession) => {
				setSession(nextSession);
			},
		});
	};

	const requestAuthToken = () => {
		if (modalInFlight) return modalInFlight;
		modalInFlight = showAuthModal().finally(() => {
			modalInFlight = null;
		});
		return modalInFlight;
	};

	const ensureAuth = (force: boolean) => {
		if (!authRequired) return Promise.resolve(session);
		if (session && !force) return Promise.resolve(session);
		if (!authInFlight) {
			authInFlight = (() => {
				let attempts = 0;
				const tryAuth = (): Promise<AuthSession | null> => {
					attempts += 1;
					return requestAuthToken().then((nextSession) => {
						if ((nextSession && nextSession.sessionSecret) || attempts >= 3) return nextSession;
						return tryAuth();
					});
				};
				return tryAuth().finally(() => {
					authInFlight = null;
				});
			})();
		}
		return authInFlight;
	};

	const encoder = new TextEncoder();

	const bufferToHex = (buffer: ArrayBuffer) =>
		Array.from(new Uint8Array(buffer))
			.map((byte) => byte.toString(16).padStart(2, '0'))
			.join('');

	const sha256Hex = async (data: Uint8Array) => {
		if (!data.length) return '';
		const hash = await crypto.subtle.digest('SHA-256', data as BufferSource);
		return bufferToHex(hash);
	};

	const getSigningKey = async () => {
		if (!session) return null;
		if (!signingKeyPromise) {
			signingKeyPromise = crypto.subtle.importKey(
				'raw',
				encoder.encode(session.sessionSecret),
				{name: 'HMAC', hash: 'SHA-256'},
				false,
				['sign'],
			);
		}
		return signingKeyPromise;
	};

	const hmacHex = async (payload: string) => {
		if (!session) return '';
		const key = await getSigningKey();
		if (!key) return '';
		const signature = await crypto.subtle.sign('HMAC', key, encoder.encode(payload));
		return bufferToHex(signature);
	};

	const canonicalizePath = (url: URL) => {
		if (!url.searchParams || Array.from(url.searchParams).length === 0) {
			return url.pathname;
		}
		const params = Array.from(url.searchParams.entries());
		params.sort(([keyA, valueA], [keyB, valueB]) => {
			const keySort = keyA.localeCompare(keyB);
			if (keySort !== 0) return keySort;
			return valueA.localeCompare(valueB);
		});
		const query = params
			.map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
			.join('&');
		return query ? `${url.pathname}?${query}` : url.pathname;
	};

	const getBodyBytes = async (request: Request) => {
		if (request.method === 'GET' || request.method === 'HEAD') {
			return new Uint8Array();
		}
		try {
			const buffer = await request.clone().arrayBuffer();
			return new Uint8Array(buffer);
		} catch (err) {
			void err;
			return new Uint8Array();
		}
	};

	const buildAuthHeaders = async (request: Request) => {
		if (!session) return null;
		const url = new URL(request.url, window.location.href);
		const path = canonicalizePath(url);
		const timestamp = Math.floor(Date.now() / 1000).toString();
		const nonce = crypto.randomUUID ? crypto.randomUUID() : Math.random().toString(16).slice(2);
		const bodyBytes = await getBodyBytes(request);
		const bodyHash = await sha256Hex(bodyBytes);
		const payload = [session.sessionId, request.method.toUpperCase(), path, timestamp, nonce, bodyHash].join('\n');
		const signature = await hmacHex(payload);
		return {
			'X-Dora-Session': session.sessionId,
			'X-Dora-Timestamp': timestamp,
			'X-Dora-Nonce': nonce,
			'X-Dora-Signature': signature,
		};
	};

	if (origFetch) {
		window.fetch = async (input: RequestInfo | URL, init?: RequestInit) => {
			const doFetch = async () => {
				const request = input instanceof Request ? new Request(input, init) : new Request(input, init);
				const headers = new Headers(request.headers);
				if (session) {
					const authHeaders = await buildAuthHeaders(request);
					if (authHeaders) {
						Object.entries(authHeaders).forEach(([key, value]) => headers.set(key, value));
					}
				}
				const next = new Request(request, {headers});
				return origFetch(next);
			};

			if (authRequired && !session && !isAuthBypassUrl(input)) {
				await ensureAuth(false);
				const res = await doFetch();
				if (res.status === 401) {
					await ensureAuth(true);
					return doFetch();
				}
				return res;
			}

			const res = await doFetch();
			if (res.status === 401 && authRequired && !isAuthBypassUrl(input)) {
				setSession(null);
				await ensureAuth(true);
				return doFetch();
			}
			return res;
		};
	}

	const OrigWebSocket = window.WebSocket;
	if (OrigWebSocket) {
		const WrappedWebSocket = function (url: string | URL, protocols?: string | string[]) {
			const socket = protocols ? new OrigWebSocket(url, protocols) : new OrigWebSocket(url);
			socket.addEventListener('close', () => {
				if (authRequired && origFetch) {
					void (async () => {
						try {
							const probe = await origFetch(Service.addr('/info'), {
								method: 'POST',
								headers: {'Content-Type': 'application/json'},
								body: '{}',
							});
							if (probe.status === 401) {
								setSession(null);
								await ensureAuth(true);
							}
						} catch (err) {
							void err;
						}
					})();
				}
			});
			return socket;
		} as unknown as typeof WebSocket;
		WrappedWebSocket.prototype = OrigWebSocket.prototype;
		window.WebSocket = WrappedWebSocket;
	}

	if (!authRequired && !session && origFetch) {
		try {
			const probe = await origFetch(Service.addr('/info'), {
				method: 'POST',
				headers: {'Content-Type': 'application/json'},
				body: '{}',
			});
			if (probe.status === 401) {
				authRequired = true;
			}
		} catch (err) {
			void err;
		}
	}

	if (authRequired && !session && origFetch) {
		while (authRequired && !session) {
			await ensureAuth(true);
		}
	}
};

const App = React.lazy(() => Service.info().then((res) => {
	const {locale} = res;
	Info.locale = locale;
	Info.platform = res.platform;
	Info.path = res.platform === "Windows" ? Path.win32 : Path.posix;
	Info.version = res.version;
	Info.engineDev = res.engineDev;
	Info.webProfiler = res.webProfiler;
	Info.drawerWidth = res.drawerWidth;

	Path.setPath(Info.path);

	(window as any).getLanguageSetting = () => {
		if (locale.match(/^zh/)) {
			return "zh-cn";
		}
		return "en";
	};
	i18n.changeLanguage(locale.match(/^zh/) ? "zh" : "en");
	return import('./App');
}).catch(() => import('./App')));

const root = ReactDOM.createRoot(
	document.getElementById('root') as HTMLElement
);
const bootstrap = async () => {
	await setupAuth();
	root.render(<App/>);

	// If you want to start measuring performance in your app, pass a function
	// to log results (for example: reportWebVitals(console.log))
	// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
	reportWebVitals();
};
void bootstrap();
