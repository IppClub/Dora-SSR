/* Copyright (c) 2026 Li Jin <dragon-fly@qq.com>
 * SPDX-License-Identifier: MIT */
#pragma once
#include <string>
#include <system_error>
#if BX_PLATFORM_LINUX || BX_PLATFORM_WINDOWS
#include "ghc/fs_fwd.hpp"
#else
#include <filesystem>
#endif

namespace Dora::PathPolicy {
#if BX_PLATFORM_LINUX || BX_PLATFORM_WINDOWS
namespace fs = ghc::filesystem;
#else
namespace fs = std::filesystem;
#endif

inline bool isWithin(const std::string& value, const std::string& root) try {
	if (value.empty() || root.empty() || value.find('\0') != std::string::npos || root.find('\0') != std::string::npos) return false;
	std::error_code error;
	const fs::path candidate(value), base(root);
	if (!candidate.is_absolute() || !base.is_absolute()) return false;
	// Go's filesystem normalizes dot segments before opening a repository.
	// Reject them so validation and execution cannot resolve different symlinks.
	for (const auto& part : candidate) {
		if (part == "." || part == "..") return false;
	}
	// Resolve before comparing: lexical normalization alone misses symlink
	// escapes. weakly_canonical also supports clone/init into new directories.
	const auto resolvedBase = fs::canonical(base, error);
	if (error) return false;
	const auto resolved = fs::weakly_canonical(candidate, error);
	if (error) return false;
	// A dangling symlink must not become an apparently safe nonexistent suffix.
	fs::path prefix;
	for (const auto& part : candidate) {
		prefix /= part;
		auto status = fs::symlink_status(prefix, error);
		if (error && error != std::errc::no_such_file_or_directory) return false;
		error.clear();
		if (fs::is_symlink(status)) {
			(void)fs::canonical(prefix, error);
			if (error) return false;
		}
	}
	auto it = resolved.begin();
	for (const auto& part : resolvedBase) {
		if (it == resolved.end() || *it != part) return false;
		++it;
	}
	return true;
} catch (const fs::filesystem_error&) {
	return false;
}
} // namespace Dora::PathPolicy
