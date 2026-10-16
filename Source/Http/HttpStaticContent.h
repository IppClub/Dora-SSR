/* Copyright (c) 2026 Li Jin <dragon-fly@qq.com>
 * SPDX-License-Identifier: MIT */
#pragma once
#include <algorithm>
#include <cstdint>
#include <limits>
#include <optional>
#include <string>
#include <string_view>
#include <utility>
#include <zlib.h>

namespace Dora::HttpPolicy {
struct StaticContent {
	std::string data;
	bool gzipEncoded = false;
};

inline bool isPrecompressedGzip(std::string_view packed) {
	if (packed.size() < 18) return false;
	const auto* bytes = reinterpret_cast<const unsigned char*>(packed.data());
	return bytes[0] == 0x1f && bytes[1] == 0x8b && bytes[2] == 8 && bytes[3] == 0;
}

inline std::optional<std::string> decodePrecompressedGzip(std::string_view packed,
		size_t limit = 512u * 1024u * 1024u) {
	if (!isPrecompressedGzip(packed) || packed.size() > std::numeric_limits<uInt>::max()) return std::nullopt;
	z_stream stream{};
	if (inflateInit2(&stream, MAX_WBITS + 16) != Z_OK) return std::nullopt;
	stream.next_in = reinterpret_cast<Bytef*>(const_cast<char*>(packed.data()));
	stream.avail_in = static_cast<uInt>(packed.size());
	std::string result;
	char buffer[64 * 1024];
	int status;
	do {
		stream.next_out = reinterpret_cast<Bytef*>(buffer);
		stream.avail_out = sizeof(buffer);
		status = inflate(&stream, Z_NO_FLUSH);
		auto produced = sizeof(buffer) - stream.avail_out;
		if ((status != Z_OK && status != Z_STREAM_END) || produced > limit - result.size()) {
			inflateEnd(&stream); return std::nullopt;
		}
		result.append(buffer, produced);
	} while (status != Z_STREAM_END);
	const bool complete = stream.avail_in == 0;
	inflateEnd(&stream);
	return complete ? std::optional<std::string>(std::move(result)) : std::nullopt;
}

// Build-time validation checks the complete gzip stream. At request time its
// header and original CRC/size reject stale companions after a live file edit.
// No payload, path metadata or compression result is retained across requests.
inline bool matchesPrecompressedGzip(std::string_view original, std::string_view packed) {
	if (!isPrecompressedGzip(packed) || packed.size() >= original.size()) return false;
	const auto* bytes = reinterpret_cast<const unsigned char*>(packed.data());
	if (bytes[0] != 0x1f || bytes[1] != 0x8b || bytes[2] != 8 || bytes[3] != 0) return false;
	auto littleEndian = [&](size_t at) -> uint32_t {
		return uint32_t(bytes[at]) | uint32_t(bytes[at + 1]) << 8
			| uint32_t(bytes[at + 2]) << 16 | uint32_t(bytes[at + 3]) << 24;
	};
	if (littleEndian(packed.size() - 4) != static_cast<uint32_t>(original.size())) return false;
	uLong checksum = crc32(0, nullptr, 0);
	for (size_t offset = 0; offset < original.size();) {
		auto length = static_cast<uInt>(std::min(original.size() - offset,
			static_cast<size_t>(std::numeric_limits<uInt>::max())));
		checksum = crc32(checksum, reinterpret_cast<const Bytef*>(original.data() + offset), length);
		offset += length;
	}
	return littleEndian(packed.size() - 8) == checksum;
}
}
