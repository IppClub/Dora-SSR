/* Copyright (c) 2026 Li Jin <dragon-fly@qq.com>
 * SPDX-License-Identifier: MIT */
#pragma once
#include <cstddef>
#include <optional>
#include <utility>
#include <string>
#include <unordered_map>

namespace Dora::HttpPolicy {
struct StaticContent {
	std::string data;
	bool gzipEncoded = false;
};

// Owned by the Content worker. Bound both payload bytes and map metadata.
class StaticCache {
	struct Entry {
		std::string version, data, gzip;
		bool gzipComputed = false;
		size_t size() const { return data.capacity() + gzip.capacity(); }
	};
	std::unordered_map<std::string, Entry> entries;
	size_t bytes = 0;
	size_t limit, countLimit;
public:
	explicit StaticCache(size_t limit = 64u * 1024u * 1024u, size_t countLimit = 256)
		: limit(limit), countLimit(countLimit) { }
	size_t size() const { return bytes; }
	size_t count() const { return entries.size(); }
	template<class Load, class Compress>
	StaticContent load(const std::string& key, const std::optional<std::string>& version,
			bool gzip, Load&& read, Compress&& compress) {
		Entry entry;
		auto it = entries.find(key);
		if (it != entries.end()) {
			bytes -= it->second.size();
			if (version && it->second.version == *version) entry = std::move(it->second);
			entries.erase(it);
		}
		if (entry.data.empty()) {
			entry.data = read();
			if (version) entry.version = *version;
		}
		if (gzip && !entry.gzipComputed && !entry.data.empty()) {
			entry.gzipComputed = true;
			if (auto packed = compress(entry.data); packed && packed->size() < entry.data.size())
				entry.gzip = std::move(*packed);
		}
		StaticContent result{gzip && !entry.gzip.empty() ? entry.gzip : entry.data,
			gzip && !entry.gzip.empty()};
		// Missing, mutable/virtual and oversized assets must never occupy the cache.
		if (version && !entry.data.empty() && entry.size() <= limit && countLimit > 0) {
			if (bytes > limit - entry.size() || entries.size() >= countLimit) {
				entries.clear(); bytes = 0;
			}
			bytes += entry.size();
			entries.emplace(key, std::move(entry));
		}
		return result;
	}
};
}
