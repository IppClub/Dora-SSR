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
import AuthDialog, { AuthDialogProps } from './AuthDialog';

export const showAuthDialog = ({origFetch, onToken}: AuthDialogProps) => {
	const container = document.createElement('div');
	document.body.appendChild(container);
	const modalRoot = ReactDOM.createRoot(container);
	return new Promise<string>((resolve) => {
		const cleanup = (nextToken: string) => {
			modalRoot.unmount();
			container.remove();
			resolve(nextToken);
		};

		const handleToken = (token: string) => {
			onToken(token);
			cleanup(token);
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
	const storageKey = 'doraWebAuthToken';
	let token = localStorage.getItem(storageKey) || '';
	let authRequired = hasAuthRequiredCookie();
	let authInFlight: Promise<string> | null = null;

	const setToken = (nextToken: string) => {
		token = (nextToken || '').trim();
		if (token) {
			localStorage.setItem(storageKey, token);
		} else {
			localStorage.removeItem(storageKey);
		}
	};

	(window as any).__setDoraAuthToken = (nextToken: string) => {
		setToken(nextToken);
	};

	const origFetch = window.fetch ? window.fetch.bind(window) : null;
	let modalInFlight: Promise<string> | null = null;

	const showAuthModal = () => {
		if (!origFetch) return Promise.resolve('');
		Service.getWebSocket()?.close();
		return showAuthDialog({
			origFetch,
			onToken: (nextToken) => {
				setToken(nextToken);
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
		if (!authRequired) return Promise.resolve(token);
		if (token && !force) return Promise.resolve(token);
		if (!authInFlight) {
			authInFlight = (() => {
				let attempts = 0;
				const tryAuth = (): Promise<string> => {
					attempts += 1;
					return requestAuthToken().then((nextToken) => {
						if (nextToken || attempts >= 3) return nextToken;
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

	if (origFetch) {
		window.fetch = (input: RequestInfo | URL, init?: RequestInit) => {
			const doFetch = () => {
				let headers: Headers;
				if (input instanceof Request) {
					headers = new Headers(input.headers);
					if (token) headers.set('X-Dora-Auth', token);
					const next = new Request(input, {headers});
					return origFetch(next, init);
				}
				headers = new Headers(init?.headers || {});
				if (token) headers.set('X-Dora-Auth', token);
				return origFetch(input, {...init, headers});
			};

			if (authRequired && !token && !isAuthBypassUrl(input)) {
				return ensureAuth(false).then(() =>
					doFetch().then((res) => {
						if (res.status === 401) {
							return ensureAuth(true).then(() => doFetch());
						}
						return res;
					})
				);
			}

			return doFetch().then((res) => {
				if (res.status === 401 && authRequired && !isAuthBypassUrl(input)) {
					setToken('');
					return ensureAuth(true).then(() => doFetch());
				}
				return res;
			});
		};
	}

	const origSend = XMLHttpRequest.prototype.send;
	XMLHttpRequest.prototype.send = function (body?: XMLHttpRequestBodyInit | Document | null) {
		try {
			if (token) {
				this.setRequestHeader('X-Dora-Auth', token);
			}
		} catch (err) {
			void err;
		}
		return origSend.call(this, body as XMLHttpRequestBodyInit | Document | null | undefined);
	};

	const OrigWebSocket = window.WebSocket;
	if (OrigWebSocket) {
		const WrappedWebSocket = function (url: string | URL, protocols?: string | string[]) {
			if (token) {
				try {
					const nextUrl = new URL(url, window.location.href);
					if (!nextUrl.searchParams.has('auth')) {
						nextUrl.searchParams.set('auth', token);
					}
					url = nextUrl.toString();
				} catch (err) {
					void err;
					const suffix = `${url.toString().includes('?') ? '&' : '?'}auth=${encodeURIComponent(token)}`;
					url = `${url.toString()}${suffix}`;
				}
			}
			const socket = protocols ? new OrigWebSocket(url, protocols) : new OrigWebSocket(url);
			let opened = false;
			socket.addEventListener('open', () => {
				opened = true;
			});
			socket.addEventListener('close', () => {
				if (!opened && authRequired && origFetch) {
					void (async () => {
						try {
							const probe = await origFetch(Service.addr('/info'), {
								method: 'POST',
								headers: {'Content-Type': 'application/json'},
								body: '{}',
							});
							if (probe.status === 401) {
								setToken('');
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

	if (!authRequired && !token && origFetch) {
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

	if (authRequired && !token && origFetch) {
		while (authRequired && !token) {
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
