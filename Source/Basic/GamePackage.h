/* Copyright (c) 2026 Li Jin <dragon-fly@qq.com>
 * SPDX-License-Identifier: MIT */
#pragma once

#include <cstdio>
#include <filesystem>
#include <memory>
#include <stdexcept>
#include <string>
#include <string_view>
#include "rapidjson/document.h"

namespace Dora::GamePackage {
namespace fs = std::filesystem;
using File = std::unique_ptr<FILE, decltype(&std::fclose)>;

inline fs::path path(std::string_view name) {
	return fs::path(std::u8string(name.begin(), name.end()));
}

inline std::string utf8(const fs::path& file) {
	auto name = file.generic_u8string();
	return {name.begin(), name.end()};
}

inline File open(const fs::path& file, const char* mode) {
#if defined(_WIN32)
	std::wstring wideMode(mode, mode + std::char_traits<char>::length(mode));
	return File(_wfopen(file.c_str(), wideMode.c_str()), std::fclose);
#else
	return File(std::fopen(file.c_str(), mode), std::fclose);
#endif
}

inline void require(bool condition, const char* message) {
	if (!condition) throw std::runtime_error(message);
}

inline const rapidjson::Value& member(const rapidjson::Value& value, const char* key) {
	require(value.IsObject(), "Invalid export options");
	auto it = value.FindMember(key);
	require(it != value.MemberEnd(), "Missing export option");
	return it->value;
}

inline std::string_view text(const rapidjson::Value& value) {
	require(value.IsString(), "Invalid export option");
	return {value.GetString(), value.GetStringLength()};
}

inline std::string_view text(const rapidjson::Value& value, const char* key) {
	return text(member(value, key));
}

inline fs::path path(const rapidjson::Value& value, const char* key) {
	return path(text(value, key));
}

std::string read(const fs::path& file, size_t limit);
std::string base64(std::string_view bytes);
std::string unbase64(std::string_view encoded);
void replaceOnce(std::string& source, std::string_view oldText, std::string_view newText);
std::string buildAndroid(const rapidjson::Value& options);
}
