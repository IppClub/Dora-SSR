import os from 'node:os';

const loopback = host => host === 'localhost' || host === '[::1]' || host === '::1' || host === '::ffff:127.0.0.1' || /^127(?:\.\d{1,3}){3}$/.test(host);

// Fixed local targets: never turn a browser parameter or Host into a proxy target.
export function ideDevProxy() {
	const hosts = new Set(['localhost', '127.0.0.1', '[::1]']);
	for (const entries of Object.values(os.networkInterfaces())) {
		for (const entry of entries ?? []) hosts.add(entry.family === 'IPv6' ? `[${entry.address}]` : entry.address);
	}
	const bypass = (req, res) => {
		let allowed = false;
		let local = false;
		try {
			const host = req.headers.host;
			const target = new URL(`http://${host}`);
			const origin = req.headers.origin;
			const source = origin === undefined ? null : new URL(origin);
			const validOrigin = !source || (['http:', 'https:'].includes(source.protocol) && source.origin === origin);
			const hostCount = req.rawHeaders.filter((_, i) => i % 2 === 0 && req.rawHeaders[i].toLowerCase() === 'host').length;
			const originCount = req.rawHeaders.filter((_, i) => i % 2 === 0 && req.rawHeaders[i].toLowerCase() === 'origin').length;
			allowed = hostCount === 1 && originCount <= 1 && hosts.has(target.hostname)
				&& (target.host === host?.toLowerCase() || `${target.hostname}:80` === host?.toLowerCase())
				&& target.pathname === '/' && !target.search && !target.hash && !target.username && !target.password
				&& validOrigin;
			local = loopback(target.hostname) && loopback(req.socket?.remoteAddress ?? '')
				&& (origin === target.origin || (origin === undefined && req.headers['sec-fetch-site'] === 'same-origin'))
				&& req.headers['sec-fetch-site'] !== 'cross-site';
		} catch { /* Fail closed for malformed Host/Origin. */ }
		if (!allowed) {
			if (res) { res.statusCode = 403; res.end('Forbidden'); }
			else req.socket.end('HTTP/1.1 403 Forbidden\r\nConnection: close\r\nContent-Length: 0\r\n\r\n');
			return '/__dora_rejected'; // Vite bypasses both HTTP and WS before connecting upstream.
		}
		// Preserve remote Origin: a loopback upstream connection must never turn
		// a LAN development client into an authentication-free local client.
		// Clients without Origin retain the engine's authenticated CLI behavior.
		if (local && req.headers.origin !== undefined) req.headers.origin = 'http://127.0.0.1:8866';
		// Force authenticated upstream handling for every other source, including
		// a foreign page whose Origin happens to equal the engine's Origin.
		req.headers['sec-fetch-site'] = local ? 'same-origin' : 'cross-site';
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
