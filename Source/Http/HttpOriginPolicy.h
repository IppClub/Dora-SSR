// Copyright (c) 2026 Li Jin. Licensed under the MIT License.
#pragma once
#include <algorithm>
#include <charconv>
#include <optional>
#include <string>
#include <string_view>
#include <vector>
#if defined(_WIN32)
#include <winsock2.h>
#include <ws2tcpip.h>
#else
#include <arpa/inet.h>
#endif

namespace Dora::HttpPolicy {
inline std::string lowerAscii(std::string_view text) {
	std::string result(text);
	for (auto& c : result) if (c >= 'A' && c <= 'Z') c += 'a' - 'A';
	return result;
}
inline std::optional<std::string> normalizeHost(std::string_view text) {
	if (text.empty()) return std::nullopt;
	auto host = lowerAscii(text);
	unsigned char address[16];
	char buffer[INET6_ADDRSTRLEN];
	for (auto family : {AF_INET, AF_INET6}) {
		if (inet_pton(family, host.c_str(), address) == 1 && inet_ntop(family, address, buffer, sizeof(buffer))) return std::string(buffer);
	}
	// Hostnames are exact configured names, never suffixes or DNS resolutions.
	if (host.size() > 253 || host.front() == '.' || host.back() == '.') return std::nullopt;
	for (auto c : host) if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-' || c == '.')) return std::nullopt;
	return host;
}
struct Authority {
	std::string host;
	unsigned port;
};
inline std::optional<Authority> parseAuthority(std::string_view text, unsigned defaultPort = 80) {
	std::string_view host, port;
	if (text.empty()) return std::nullopt;
	if (text.front() == '[') {
		auto close = text.find(']');
		if (close == std::string_view::npos) return std::nullopt;
		host = text.substr(1, close - 1);
		unsigned char address[16];
		if (inet_pton(AF_INET6, std::string(host).c_str(), address) != 1) return std::nullopt;
		text.remove_prefix(close + 1);
	} else {
		auto colon = text.find(':');
		host = text.substr(0, colon);
		text = colon == std::string_view::npos ? std::string_view{} : text.substr(colon);
	}
	unsigned number = defaultPort;
	if (!text.empty()) {
		if (text.front() != ':') return std::nullopt;
		port = text.substr(1);
		auto result = std::from_chars(port.data(), port.data() + port.size(), number);
		if (port.empty() || result.ec != std::errc{} || result.ptr != port.data() + port.size() || number == 0 || number > 65535) return std::nullopt;
	}
	auto normalized = normalizeHost(host);
	if (!normalized) return std::nullopt;
	return Authority{std::move(*normalized), number};
}
// A valid source may require authentication; it is not rejected just for being
// cross-origin. Only an actual loopback peer using the loopback page origin can
// bypass authentication. Missing Origin never establishes a browser origin.
enum class Access { Denied, Authenticate, Local };
inline bool sameHttpOrigin(std::string_view host, std::string_view origin, unsigned port) {
	if (origin.substr(0, 7) != "http://") return false;
	auto target = parseAuthority(host);
	auto source = parseAuthority(origin.substr(7));
	return target && source && target->port == port && source->host == target->host && source->port == port;
}
inline bool needsAuthentication(Access access, bool publicRead, bool hasOrigin, std::string_view fetchSite, bool documentNavigation = false) {
	// A link from another site must be able to open the login page. This only
	// exempts static top-level navigation; cross-origin reads and GET APIs stay
	// protected, including iframe/script/fetch requests without Origin.
	return access != Access::Local && (!publicRead || hasOrigin || (!documentNavigation && (fetchSite == "cross-site" || fetchSite == "same-site")));
}
inline bool isLoopback(std::string_view host) {
	if (host == "localhost" || host == "::1") return true;
	unsigned char address[4];
	return inet_pton(AF_INET, std::string(host).c_str(), address) == 1 && address[0] == 127;
}
inline Access access(std::string_view host, const std::optional<std::string_view>& origin,
	unsigned listenerPort, unsigned pagePort, const std::vector<std::string>& allowedHosts,
	bool loopbackPeer = false, std::string_view fetchSite = {}) {
	auto target = parseAuthority(host);
	if (!target || target->port != listenerPort || std::find(allowedHosts.begin(), allowedHosts.end(), target->host) == allowedHosts.end()) return Access::Denied;
	if (!origin) return loopbackPeer && isLoopback(target->host) && fetchSite == "same-origin" ? Access::Local : Access::Authenticate;
	auto scheme = origin->find("://");
	if (scheme == std::string_view::npos) return Access::Denied;
	auto protocol = lowerAscii(origin->substr(0, scheme));
	if (protocol != "http" && protocol != "https") return Access::Denied;
	auto source = parseAuthority(origin->substr(scheme + 3), protocol == "https" ? 443 : 80);
	if (!source) return Access::Denied;
	return loopbackPeer && isLoopback(target->host) && protocol == "http"
	 && source->host == target->host && source->port == pagePort && fetchSite != "cross-site"
	 ? Access::Local : Access::Authenticate;
}
}
