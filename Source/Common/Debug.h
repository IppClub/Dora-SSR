/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Const/Config.h"
#include "Other/AcfDelegate.h"
#include "fmt/format.h"

#include <cassert>

NS_DORA_BEGIN

extern Acf::Delegate<void(const std::string&)> LogHandler;

void LogInfo(const std::string& msg);
void LogError(const std::string& msg);

void LogThreaded(const std::string& level, const std::string& msg);

void LogErrorThreaded(const std::string& msg);
void LogWarnThreaded(const std::string& msg);
void LogInfoThreaded(const std::string& msg);

bool LogSaveAs(std::string_view filename);

const char* getShortFilename(const char* filename);

bool IsInLuaOrWasm();

#define Println(...) Dora::LogInfoThreaded(fmt::format(__VA_ARGS__))

#if DORA_DISABLE_LOG
#define Info(...) DORA_DUMMY
#define Warn(...) DORA_DUMMY
#define Error(...) DORA_DUMMY
#define InfoIf(...) DORA_DUMMY
#define WarnIf(...) DORA_DUMMY
#define ErrorIf(...) DORA_DUMMY
#else
#define Info(...) Dora::LogInfoThreaded(fmt::format(__VA_ARGS__))
#define Warn(...) Dora::LogWarnThreaded(fmt::format(__VA_ARGS__))
#define Error(...) Dora::LogErrorThreaded(fmt::format(__VA_ARGS__))
#define InfoIf(cond, ...) \
	if (cond) { \
		Info(__VA_ARGS__); \
	}
#define WarnIf(cond, ...) \
	if (cond) { \
		Warn(__VA_ARGS__); \
	}
#define ErrorIf(cond, ...) \
	if (cond) { \
		Error(__VA_ARGS__); \
	}
#endif

#if DORA_DISABLE_ASSERTION
#define AssertIf(cond, ...) DORA_DUMMY
#define AssertUnless(cond, ...) DORA_DUMMY
#define Issue(...) DORA_DUMMY
#else
#define AssertIf(cond, ...) \
	do { \
		if (cond) { \
			auto msg = fmt::format("[runtime error]\n{}:{}: [{}] {}", \
				Dora::getShortFilename(__FILE__), __LINE__, __FUNCTION__, \
				fmt::format(__VA_ARGS__)); \
			if (Dora::IsInLuaOrWasm()) { \
				throw std::runtime_error(msg); \
			} else { \
				Dora::LogError(msg); \
				std::abort(); \
			} \
		} \
	} while (false)
#define AssertUnless(cond, ...) \
	do { \
		if (!(cond)) { \
			auto msg = fmt::format("[runtime error]\n{}:{}: [{}] {}", \
				Dora::getShortFilename(__FILE__), __LINE__, __FUNCTION__, \
				fmt::format(__VA_ARGS__)); \
			if (Dora::IsInLuaOrWasm()) { \
				throw std::runtime_error(msg); \
			} else { \
				Dora::LogError(msg); \
				std::abort(); \
			} \
		} \
	} while (false)
#define Issue(...) \
	do { \
		auto msg = fmt::format("[runtime error]\n{}:{}: [{}] {}", \
			Dora::getShortFilename(__FILE__), __LINE__, __FUNCTION__, \
			fmt::format(__VA_ARGS__)); \
		if (Dora::IsInLuaOrWasm()) { \
			throw std::runtime_error(msg); \
		} else { \
			Dora::LogError(msg); \
			std::abort(); \
		} \
	} while (false)
#endif

NS_DORA_END
