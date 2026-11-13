#pragma once

#include <initializer_list>
#include <string>
#include <string_view>

namespace Dora {
// Only a public HTTPS repository URL is accepted. Decode the query value once;
// neither shell arguments nor arbitrary query fields reach Git.
inline std::string projectRepository(std::string_view link) {
	constexpr std::string_view prefix = "dora-ssr://open";
	if (link.size() > 2048 || link.substr(0, prefix.size()) != prefix) return {};
	link.remove_prefix(prefix.size());
	if (!link.empty() && link.front() == '/') link.remove_prefix(1);
	constexpr std::string_view query = "?repo=";
	if (link.substr(0, query.size()) != query) return {};
	link.remove_prefix(query.size());
	std::string url;
	auto hex = [](char c) -> int {
		if (c >= '0' && c <= '9') return c - '0';
		if (c >= 'A' && c <= 'F') return c - 'A' + 10;
		if (c >= 'a' && c <= 'f') return c - 'a' + 10;
		return -1;
	};
	for (size_t i = 0; i < link.size(); ++i) {
		char c = link[i];
		if (c == '%') {
			if (i + 2 >= link.size()) return {};
			int a = hex(link[i + 1]), b = hex(link[i + 2]);
			if (a < 0 || b < 0) return {};
			c = static_cast<char>(a * 16 + b); i += 2;
		}
		if (static_cast<unsigned char>(c) <= 32 || static_cast<unsigned char>(c) >= 127) return {};
		url += c;
	}
	constexpr std::string_view https = "https://";
	if (url.compare(0, https.size(), https) != 0) return {};
	if (url.back() == '/') url.pop_back();
	auto slash = url.find('/', https.size());
	if (slash == std::string::npos) return {};
	const auto host = url.substr(https.size(), slash - https.size());
	if (host != "github.com" && host != "atomgit.com" && host != "gitee.com" && host != "gitcode.com") return {};
	auto next = url.find('/', slash + 1);
	if (next == std::string::npos || url.find('/', next + 1) != std::string::npos) return {};
	for (auto part : {url.substr(slash + 1, next - slash - 1), url.substr(next + 1)}) {
		if (part.empty() || part == "." || part == "..") return {};
		for (char c : part) if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '-' || c == '.')) return {};
	}
	if (url.size() >= 4 && url.compare(url.size() - 4, 4, ".git") == 0) url.resize(url.size() - 4);
	if (url.back() == '/') return {};
	return url;
}
} // namespace Dora
