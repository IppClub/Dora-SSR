// @preview-file off clear
import { dns } from 'socket';

export function isHttpUrl(url: string): boolean {
	const normalized = url.trim().toLowerCase();
	return normalized.startsWith("http://") || normalized.startsWith("https://");
}

export function getHttpUrlHost(url: string): string | undefined {
	const schemeEnd = url.indexOf("://");
	if (schemeEnd < 0) return undefined;
	let authority = url.slice(schemeEnd + 3);
	for (const separator of ["/", "?", "#"]) {
		const index = authority.indexOf(separator);
		if (index >= 0) authority = authority.slice(0, index);
	}
	let at = -1;
	for (let i = 0; i < authority.length; i++) {
		if (authority.charAt(i) === "@") at = i;
	}
	if (at >= 0) authority = authority.slice(at + 1);
	if (authority.startsWith("[")) {
		const end = authority.indexOf("]");
		return end > 1 ? authority.slice(1, end).toLowerCase() : undefined;
	}
	let colon = -1;
	for (let i = 0; i < authority.length; i++) {
		if (authority.charAt(i) === ":") colon = i;
	}
	if (colon >= 0) authority = authority.slice(0, colon);
	return authority !== "" ? authority.toLowerCase() : undefined;
}

export function isPrivateNetworkAddress(address: string): boolean {
	const normalized = address.toLowerCase();
	if (normalized.includes(":")) {
		if (normalized === "::" || normalized === "::1") return true;
		if (normalized.startsWith("fc") || normalized.startsWith("fd")) return true;
		if (normalized.startsWith("fe8") || normalized.startsWith("fe9") || normalized.startsWith("fea") || normalized.startsWith("feb")) return true;
		const mappedPrefix = "::ffff:";
		if (normalized.startsWith(mappedPrefix)) return isPrivateNetworkAddress(normalized.slice(mappedPrefix.length));
		return false;
	}
	const parts = normalized.split(".");
	if (parts.length !== 4) return true;
	const octets: number[] = [];
	for (const part of parts) {
		const value = Number(part);
		if (part === "" || value < 0 || value > 255 || math.floor(value) !== value) return true;
		octets.push(value);
	}
	const first = octets[0];
	const second = octets[1];
	if (first === 0 || first === 10 || first === 127) return true;
	if (first === 100 && second >= 64 && second <= 127) return true;
	if (first === 169 && second === 254) return true;
	if (first === 172 && second >= 16 && second <= 31) return true;
	if (first === 192 && (second === 0 || second === 168)) return true;
	if (first === 198 && (second === 18 || second === 19)) return true;
	if (first >= 224) return true;
	return false;
}

export function isSafePublicHttpUrl(url: string): boolean {
	if (!isHttpUrl(url)) return false;
	const host = getHttpUrlHost(url);
	if (!host) return false;
	if (host === "localhost" || host.endsWith(".localhost") || host.endsWith(".local")) return false;
	if (host === "metadata.google.internal" || host.endsWith(".internal")) return false;
	if (host.includes(":")) return false; // Reject IPv6 literals, including loopback and unique-local ranges.
	const [numericHost] = string.match(host, "^[%d%.]+$");
	if (numericHost !== undefined) return false;
	const ipv4 = host.split(".");
	if (ipv4.length === 4 && ipv4.every(part => part !== "" && Number(part) >= 0 && Number(part) <= 255)) {
		return false; // Literal IPs are unnecessary here and are unsafe across alternate/private encodings.
	}
	const [addresses] = dns.getaddrinfo(host);
	if (!addresses || addresses.length === 0) return false;
	for (const address of addresses) {
		if (isPrivateNetworkAddress(address.addr)) return false;
	}
	return true;
}
