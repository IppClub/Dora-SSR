// Copyright (c) 2026 Li Jin. Licensed under the MIT License.
#pragma once
#include <string_view>

namespace Dora::HttpPolicy {
// RFC 9110: the wildcard is a complete field value; quoted '*' is an opaque tag.
inline bool ifNoneMatch(std::string_view value, std::string_view selectedTag) {
	auto trim = [](std::string_view text) {
		while (!text.empty() && (text.front() == ' ' || text.front() == '\t')) text.remove_prefix(1);
		while (!text.empty() && (text.back() == ' ' || text.back() == '\t')) text.remove_suffix(1);
		return text;
	};
	value = trim(value);
	if (value == "*") return true;
	bool matched = false;
	while (!value.empty()) {
		value = trim(value);
		if (value.front() == ',') { value.remove_prefix(1); continue; }
		if (value.substr(0, 2) == "W/") value.remove_prefix(2);
		if (value.empty() || value.front() != '"') return false;
		size_t end = 1;
		for (; end < value.size() && value[end] != '"'; ++end) {
			auto c = static_cast<unsigned char>(value[end]);
			if (c < 0x21 || c == 0x7f) return false;
		}
		if (end == value.size()) return false;
		matched = matched || value.substr(0, end + 1) == selectedTag;
		value = trim(value.substr(end + 1));
		if (!value.empty() && value.front() != ',') return false;
	}
	return matched;
}
}
