/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import './PerformanceDiagnosticsBootstrap';
import ReactDOM from 'react-dom/client';
import './index.css';
import reportWebVitals from './reportWebVitals';
import React from 'react';
import * as Service from './Service';
import i18n from './i18n';
import Info from './Info';
import Path from './3rdParty/Path';
import AuthDialog, { AuthDialogProps, AuthSession } from './AuthDialog';
import { createAuthHeaders } from './AuthSignature';

const origFetch = window.fetch.bind(window);

const checkAuthRequired = async () => {
	try {
		const probe = await origFetch(Service.addr('/info'), {
			method: 'POST',
			headers: { 'Content-Type': 'application/json' },
			body: '{}',
			cache: 'no-store',
		});
		if (probe.status === 401 || probe.ok) {
			const required = probe.status === 401;
			Service.setAuthRequired(required);
			return required;
		}
	} catch (err) {
		void err;
	}
	return null; // An offline engine or server error does not establish its mode.
};

const showAuthDialog = ({ origFetch, onToken }: AuthDialogProps, refreshAuthRequired: () => Promise<boolean | null>) => {
	const container = document.createElement('div');
	document.body.appendChild(container);
	const modalRoot = ReactDOM.createRoot(container);
	return new Promise<AuthSession | null>((resolve) => {
		let disposed = false;
		let timer: ReturnType<typeof setTimeout>;
		const cleanup = (nextToken: AuthSession | null) => {
			if (disposed) return;
			disposed = true;
			clearTimeout(timer);
			modalRoot.unmount();
			container.remove();
			resolve(nextToken);
		};

		const handleToken = (session: AuthSession) => {
			if (disposed) return;
			onToken(session);
			cleanup(session);
		};

		modalRoot.render(<AuthDialog origFetch={origFetch} onToken={handleToken} />);
		const refresh = async () => {
			const required = await refreshAuthRequired();
			if (disposed) return;
			if (required === false) cleanup(null);
			else timer = setTimeout(() => { void refresh(); }, 1000);
		};
		void refresh();
	});
};

const setupAuth = async (): Promise<void> => {
	let authRequired = (await checkAuthRequired()) === true;
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
	let authInFlight: Promise<AuthSession | null> | null = null;

	const normalizeSession = (nextSession: AuthSession | null) => {
		if (nextSession && nextSession.sessionId && nextSession.sessionSecret) {
			return nextSession;
		}
		return null;
	};

	const setSession = (nextSession: AuthSession | null) => {
		session = normalizeSession(nextSession);
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

	const refreshAuthRequired = async () => {
		const required = await checkAuthRequired();
		if (required !== null) {
			authRequired = required;
			if (!required) setSession(null);
		}
		return required;
	};
	// A persisted WebView can retain a session from the previous engine run.
	if (!authRequired) setSession(null);
	let modalInFlight: Promise<AuthSession | null> | null = null;

	const showAuthModal = () => {
		Service.getWebSocket()?.close();
		return showAuthDialog({
			origFetch,
			onToken: (nextSession) => {
				setSession(nextSession);
			},
		}, refreshAuthRequired);
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
			authInFlight = (async () => {
				const required = await refreshAuthRequired();
				if (required !== true) {
					if (required === null) await new Promise(resolve => setTimeout(resolve, 1000));
					return null;
				}
				let attempts = 0;
				const tryAuth = (): Promise<AuthSession | null> => {
					attempts += 1;
					return requestAuthToken().then((nextSession) => {
						if (!authRequired || (nextSession && nextSession.sessionSecret) || attempts >= 3) return nextSession;
						return tryAuth();
					});
				};
				return tryAuth();
			})().finally(() => {
				authInFlight = null;
			});
		}
		return authInFlight;
	};

	const getBodyBytes = async (request: Request) => {
		if (request.method === 'GET' || request.method === 'HEAD') {
			return new Uint8Array();
		}
		const contentType = request.headers.get('Content-Type')?.toLowerCase() ?? '';
		if (contentType.startsWith('multipart/form-data')) {
			return new Uint8Array();
		}
		try {
			await request.clone().formData();
			return new Uint8Array();
		} catch (err) {
			void err;
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
		const signingSession = session;
		if (!signingSession) return null;
		return createAuthHeaders(signingSession, request.method, new URL(request.url, window.location.href),
			await getBodyBytes(request), !process.env.NODE_ENV || process.env.NODE_ENV === 'development');
	};

	window.fetch = async (input: RequestInfo | URL, init?: RequestInit) => {
		const doFetch = async () => {
			const request = input instanceof Request ? new Request(input, init) : new Request(input, init);
			const headers = new Headers(request.headers);
			if (authRequired && session && !isAuthBypassUrl(input)) {
				const authHeaders = await buildAuthHeaders(request);
				if (authHeaders) {
					Object.entries(authHeaders).forEach(([key, value]) => headers.set(key, value));
				}
			}
			const next = new Request(request, { headers });
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

	const OrigWebSocket = window.WebSocket;
	const WrappedWebSocket = function (url: string | URL, protocols?: string | string[]) {
		const socket = protocols ? new OrigWebSocket(url, protocols) : new OrigWebSocket(url);
		socket.addEventListener('close', () => {
			void (async () => {
				if ((await refreshAuthRequired()) === true) {
					setSession(null);
					await ensureAuth(true);
				}
			})();
		});
		return socket;
	} as unknown as typeof WebSocket;
	WrappedWebSocket.prototype = OrigWebSocket.prototype;
	window.WebSocket = WrappedWebSocket;

	if (authRequired && !session) {
		while (authRequired && !session) {
			await ensureAuth(true);
		}
	}
};

const App = React.lazy(() => Service.info().then((res) => {
	const { locale } = res;
	Info.locale = locale;
	Info.platform = res.platform;
	Info.path = res.platform === "Windows" ? Path.win32 : Path.posix;
	Info.version = res.version;
	Info.engineDev = res.engineDev;
	Info.webProfiler = res.webProfiler;
	Info.drawerWidth = res.drawerWidth;
	Info.webIDETourCompleted = res.webIDETourCompleted;

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
	root.render(<App />);

	// If you want to start measuring performance in your app, pass a function
	// to log results (for example: reportWebVitals(console.log))
	// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
	reportWebVitals();
};
void bootstrap();
