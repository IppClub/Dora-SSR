/* Copyright (c) 2026 Li Jin <dragon-fly@qq.com>
 * SPDX-License-Identifier: MIT */
#pragma once

#include <array>
#include <charconv>
#include <chrono>
#include <cstdio>
#include <cstdint>
#include <functional>
#include <memory>
#include <mutex>
#include <string>
#include <string_view>
#if defined(_WIN32)
#include <winsock2.h>
#include <windows.h>
#endif
#if BX_PLATFORM_LINUX || BX_PLATFORM_WINDOWS
#include "ghc/fs_fwd.hpp"
#else
#include <filesystem>
#endif
#include "Http/XrtNetwork.h"

namespace Dora::HttpUpload {
#if BX_PLATFORM_LINUX || BX_PLATFORM_WINDOWS
namespace fs = ghc::filesystem;
#else
namespace fs = std::filesystem;
#endif
constexpr uint64_t ChunkBytes = 4u * 1024u * 1024u;
constexpr uint64_t MaxFileBytes = 9007199254740991ull; // Exact JavaScript integer range.
struct Result {
	int status = 200;
	uint64_t offset = 0;
	bool complete = false;
};
inline bool number(std::string_view text, uint64_t& result) {
	if (text.empty()) return false;
	auto parsed = std::from_chars(text.data(), text.data() + text.size(), result);
	return parsed.ec == std::errc{} && parsed.ptr == text.data() + text.size();
}
inline bool digest(std::string_view text) {
	return text.size() == 64 && text.find_first_not_of("0123456789abcdef") == std::string_view::npos;
}
inline std::string utf8(const fs::path& path) {
	auto text = path.u8string();
	return {reinterpret_cast<const char*>(text.data()), text.size()};
}
inline fs::path fromUtf8(const std::string& text) {
	return fs::path(std::u8string(text.begin(), text.end()));
}
using File = std::unique_ptr<FILE, decltype(&fclose)>;
inline File open(const fs::path& path, bool write, bool append = false) {
#if defined(_WIN32)
	return File(_wfopen(path.wstring().c_str(), write ? (append ? L"ab" : L"wb") : L"rb"), fclose);
#else
	return File(fopen(path.c_str(), write ? (append ? "ab" : "wb") : "rb"), fclose);
#endif
}
inline bool replace(const fs::path& source, const fs::path& target) {
#if defined(_WIN32)
	return MoveFileExW(source.wstring().c_str(), target.wstring().c_str(), MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH) != 0;
#else
	std::error_code error;
	fs::rename(source, target, error);
	return !error;
#endif
}
inline bool contained(const fs::path& root, const fs::path& path) {
	auto a = root.begin(), b = path.begin();
	for (; a != root.end(); ++a, ++b) if (b == path.end() || *a != *b) return false;
	return b != path.end();
}
inline bool cleanName(std::string_view name) {
	if (name.empty() || name.front() == '/' || name.back() == '/') return false;
	if (name.find_first_of("\\:\r\n") != std::string_view::npos || name.find('\0') != std::string_view::npos) return false;
	size_t start = 0;
	while (start < name.size()) {
		auto end = name.find('/', start);
		if (end == std::string_view::npos) end = name.size();
		auto part = name.substr(start, end - start);
		if (part.empty() || part == "." || part == "..") return false;
		start = end + 1;
	}
	return true;
}

// All data is appended to a private file on the destination filesystem. Metadata
// commits the confirmed byte count *after* close succeeds. On restart, any tail
// left by an interrupted write is truncated back to that committed checkpoint.
class Store {
public:
	Result handle(const std::string& workspace, const std::string& directory, const std::string& name,
		const std::string& id, const std::string& hash, uint64_t size, const std::string& action,
		uint64_t offset, std::string_view body, const std::string& chunkHash) {
		if (!digest(id) || !digest(hash) || size > MaxFileBytes || !cleanName(name)
			|| directory.find('\0') != std::string::npos || directory.find_first_of("\r\n") != std::string::npos
			|| (action != "status" && action != "chunk" && action != "complete")) return {400};
		static std::array<std::mutex, 64> locks;
		std::lock_guard<std::mutex> guard(locks[std::hash<std::string>{}(workspace + id) % locks.size()]);
		try {
			auto root = fs::canonical(fromUtf8(workspace));
			auto destinationDir = fs::weakly_canonical(root / fromUtf8(directory));
			auto target = fs::weakly_canonical(destinationDir / fromUtf8(name));
			if ((destinationDir != root && !contained(root, destinationDir)) || !contained(root, target)
				|| !fs::is_directory(destinationDir)) return {403};
			auto uploadRoot = root / ".upload";
			auto stateRoot = uploadRoot / "resume";
			// Never follow a user-created symlink into another workspace.
			if (fs::is_symlink(uploadRoot) || fs::is_symlink(stateRoot)) return {403};
			fs::create_directories(stateRoot);
			if (target == uploadRoot || contained(uploadRoot, target)) return {403};
			auto session = stateRoot / id;
			if (fs::is_symlink(session)) return {403};
			if (action == "status") cleanup(stateRoot);
			fs::create_directories(session);
			auto data = session / "data", meta = session / "meta";
			if (fs::is_symlink(data) || fs::is_symlink(meta) || fs::is_symlink(session / "meta.tmp")) return {403};
			std::string identity = std::to_string(size) + "\n" + hash + "\n" + utf8(target);
			uint64_t committed = 0;
			if (fs::exists(meta)) {
				auto file = open(meta, false);
				char buffer[16384];
				if (!file) return {507};
				size_t count = fread(buffer, 1, sizeof(buffer), file.get());
				if (ferror(file.get()) || count == sizeof(buffer)) return {500};
				std::string_view text(buffer, count);
				auto newline = text.find('\n');
				if (newline == text.npos || !number(text.substr(0, newline), committed)
					|| text.substr(newline + 1) != identity || committed > size) return {409};
			} else {
				if (action != "status") return {404};
				if (!save(meta, 0, identity)) return {507};
			}
			// Completion is idempotent even when the final response was lost, or
			// Dora stopped after publishing the file but before replying.
			if (!fs::exists(data) && committed == size && fs::is_regular_file(target)
				&& fs::file_size(target) == size && fileHash(target) == hash) return {200, size, true};
			if (!fs::exists(data)) {
				if (committed != 0) {
					if (action != "status") return {409, committed};
					// The previously published file may have been edited or removed.
					// Selecting the original again must start a new transfer.
					committed = 0;
					if (!save(meta, 0, identity)) return {507};
				}
				auto file = open(data, true);
				if (!file || fclose(file.release()) != 0) return {507};
			}
			auto actual = fs::file_size(data);
			if (actual < committed) return {409};
			if (actual != committed) fs::resize_file(data, committed);
			if (action == "status") return {200, committed};
			if (action == "chunk") {
				if (offset != committed) return {409, committed};
				if (body.size() > ChunkBytes) return {413};
				if (body.empty() || body.size() > size - committed) return {400};
				char calculated[65];
				if (!digest(chunkHash) || !DoraXrtSha256Hex(body.data(), body.size(), calculated) || chunkHash != calculated) return {422, committed};
				auto file = open(data, true, true);
				if (!file) return {507, committed};
				bool written = fwrite(body.data(), 1, body.size(), file.get()) == body.size();
				written = fclose(file.release()) == 0 && written;
				if (!written || !save(meta, committed + body.size(), identity)) {
					fs::resize_file(data, committed);
					return {507, committed};
				}
				return {200, committed + body.size()};
			}
			if (committed != size) return {409, committed};
			auto actualHash = fileHash(data);
			if (actualHash.empty()) return {507, committed};
			if (actualHash != hash) {
				// A damaged checkpoint must be restartable by selecting the file again.
				if (!save(meta, 0, identity)) return {507};
				fs::resize_file(data, 0);
				return {422};
			}
			fs::create_directories(target.parent_path());
			// Recheck containment after creating parents (including nested names).
			if (!contained(root, fs::weakly_canonical(target))) return {403};
			if (!replace(data, target)) return {507, committed};
			return {200, size, true};
		} catch (const fs::filesystem_error&) { return {507}; }
	}
private:
	static std::string fileHash(const fs::path& path) {
		auto file = open(path, false);
		char hash[65];
		return file && DoraXrtSha256FileHex(file.get(), hash) ? hash : std::string{};
	}
	static bool save(const fs::path& meta, uint64_t offset, const std::string& identity) {
		auto temporary = meta.parent_path() / "meta.tmp";
		auto file = open(temporary, true);
		if (!file) return false;
		auto text = std::to_string(offset) + "\n" + identity;
		bool written = fwrite(text.data(), 1, text.size(), file.get()) == text.size();
		written = fclose(file.release()) == 0 && written;
		return written && replace(temporary, meta);
	}
	static void cleanup(const fs::path& root) {
		// Abandoned checkpoints expire after 24 hours; normal chunks refresh meta.
		auto cutoff = fs::file_time_type::clock::now() - std::chrono::hours(24);
		for (const auto& entry : fs::directory_iterator(root)) {
			if (!entry.is_directory() || entry.is_symlink() || !digest(utf8(entry.path().filename()))) continue;
			std::error_code error;
			auto touched = fs::last_write_time(entry.path() / "meta", error);
			if (!error && touched < cutoff) fs::remove_all(entry.path(), error);
		}
	}
};
} // namespace Dora::HttpUpload
