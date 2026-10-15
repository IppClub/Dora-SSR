import { sha256 } from '@noble/hashes/sha2.js';
import { hmac } from '@noble/hashes/hmac.js';
import { bytesToHex } from '@noble/hashes/utils.js';

const encodeRfc3986Component = (value: string) => encodeURIComponent(value).replace(/[!'()*]/g, (character) =>
	`%${character.charCodeAt(0).toString(16).toUpperCase()}`,
);

export const canonicalizeAuthPath = (url: URL) => {
	if (!url.searchParams || Array.from(url.searchParams).length === 0) {
		return url.pathname;
	}
	const params = Array.from(url.searchParams.entries());
	params.sort(([keyA, valueA], [keyB, valueB]) => {
		const keySort = keyA < keyB ? -1 : keyA > keyB ? 1 : 0;
		if (keySort !== 0) return keySort;
		return valueA < valueB ? -1 : valueA > valueB ? 1 : 0;
	});
	const query = params
		.map(([key, value]) => `${encodeRfc3986Component(key)}=${encodeRfc3986Component(value)}`)
		.join('&');
	return query ? `${url.pathname}?${query}` : url.pathname;
};

export const authNonce = () => bytesToHex(crypto.getRandomValues(new Uint8Array(16)));

export const signAuthPayload = (secret: string, payload: string) => {
	const encoder = new TextEncoder();
	return bytesToHex(hmac(sha256, encoder.encode(secret), encoder.encode(payload)));
};

// Synchronous hashing also supports compiler XHR and HTTP LAN pages, where
// browsers expose getRandomValues but do not provide crypto.subtle.
export const createAuthHeaders = (
	session: {sessionId: string; sessionSecret: string}, method: string, url: URL,
	body: Uint8Array, development: boolean,
) => {
	const target = new URL(url.href);
	if (development && target.pathname.startsWith('/__dora/api/')) {
		target.pathname = target.pathname.slice('/__dora/api'.length);
	}
	const timestamp = Math.floor(Date.now() / 1000).toString();
	const nonce = authNonce();
	const bodyHash = body.length ? bytesToHex(sha256(body)) : '';
	const payload = [session.sessionId, method.toUpperCase(), canonicalizeAuthPath(target), timestamp, nonce, bodyHash].join('\n');
	return {
		'X-Dora-Session': session.sessionId,
		'X-Dora-Timestamp': timestamp,
		'X-Dora-Nonce': nonce,
		'X-Dora-Signature': signAuthPayload(session.sessionSecret, payload),
	};
};
