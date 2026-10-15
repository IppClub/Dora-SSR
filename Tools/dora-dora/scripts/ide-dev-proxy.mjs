import os from 'node:os';

// Fixed local targets: never turn a browser parameter or Host into a proxy target.
export function ideDevProxy() {
	const hosts = new Set(['localhost', '127.0.0.1', '[::1]']);
	for (const entries of Object.values(os.networkInterfaces())) {
		for (const entry of entries ?? []) hosts.add(entry.family === 'IPv6' ? `[${entry.address}]` : entry.address);
	}
	const bypass = (req, res) => {
		let allowed = false;
		try {
			const host = req.headers.host;
			const target = new URL(`http://${host}`);
			const origin = req.headers.origin;
			const hostCount = req.rawHeaders.filter((_, i) => i % 2 === 0 && req.rawHeaders[i].toLowerCase() === 'host').length;
			const originCount = req.rawHeaders.filter((_, i) => i % 2 === 0 && req.rawHeaders[i].toLowerCase() === 'origin').length;
			allowed = hostCount === 1 && originCount <= 1 && hosts.has(target.hostname)
				&& target.host === host?.toLowerCase() && target.pathname === '/' && !target.username && !target.password
				&& req.headers['sec-fetch-site'] !== 'cross-site'
				&& (origin === undefined || origin === target.origin);
		} catch { /* Fail closed for malformed Host/Origin. */ }
		if (!allowed) {
			if (res) { res.statusCode = 403; res.end('Forbidden'); }
			else req.socket.end('HTTP/1.1 403 Forbidden\r\nConnection: close\r\nContent-Length: 0\r\n\r\n');
			return '/__dora_rejected'; // Vite bypasses both HTTP and WS before connecting upstream.
		}
		// Origin is rewritten only after validating the original browser source.
		if (req.headers.origin !== undefined) req.headers.origin = 'http://127.0.0.1:8866';
	};
	return {
		'^/__dora/api(?:/|\\?|$)': {
			target: 'http://127.0.0.1:8866', changeOrigin: true, bypass,
			rewrite: path => path.replace(/^\/__dora\/api(?=\/|\?|$)/, '') || '/',
		},
		'^/__dora/ws(?:\\?|$)': {
			target: 'ws://127.0.0.1:8868', changeOrigin: true, ws: true, bypass,
			rewrite: path => path.replace(/^\/__dora\/ws/, '/') ,
		},
	};
}
