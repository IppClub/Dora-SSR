/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <cassert>

NS_DORA_BEGIN

extern Acf::Delegate<void(const std::string&)> LogHandler;

void LogError(const std::string& str);
void LogPrintInThread(const std::string& str);

bool IsInLuaOrWasm();

#define LogPrint(...) \
	Dora::LogPrintInThread(fmt::format(__VA_ARGS__))

#define println(format, ...) \
	LogPrint(format "\n", ##__VA_ARGS__)

#if DORA_DISABLE_LOG
#define Info(...) DORA_DUMMY
#define Warn(...) DORA_DUMMY
#define Error(...) DORA_DUMMY
#define InfoIf(...) DORA_DUMMY
#define WarnIf(...) DORA_DUMMY
#define ErrorIf(...) DORA_DUMMY
#else
#define Info(format, ...) \
	LogPrint("[Dora Info] " format "\n", ##__VA_ARGS__)
#define Warn(format, ...) \
	LogPrint("[Dora Warning] " format "\n", ##__VA_ARGS__)
#define Error(format, ...) \
	LogPrint("[Dora Error] " format "\n", ##__VA_ARGS__)
#define InfoIf(format, ...) \
	if (cond) { \
		LogPrint("[Dora Info] " format "\n", ##__VA_ARGS__); \
	}
#define WarnIf(cond, format, ...) \
	if (cond) { \
		LogPrint("[Dora Warning] " format "\n", ##__VA_ARGS__); \
	}
#define ErrorIf(cond, format, ...) \
	if (cond) { \
		LogPrint("[Dora Error] " format "\n", ##__VA_ARGS__); \
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
			auto msg = fmt::format("[Dora Error]\n[File] {},\n[Func] {}, [Line] {},\n[Message] {}", \
				__FILE__, __FUNCTION__, __LINE__, \
				fmt::format(__VA_ARGS__)); \
			if (Dora::IsInLuaOrWasm()) { \
				throw std::runtime_error(msg); \
			} else { \
				Dora::LogError(msg + '\n'); \
				std::abort(); \
			} \
		} \
	} while (false)
#define AssertUnless(cond, ...) \
	do { \
		if (!(cond)) { \
			auto msg = fmt::format("[Dora Error]\n[File] {},\n[Func] {}, [Line] {},\n[Message] {}", \
				__FILE__, __FUNCTION__, __LINE__, \
				fmt::format(__VA_ARGS__)); \
			if (Dora::IsInLuaOrWasm()) { \
				throw std::runtime_error(msg); \
			} else { \
				Dora::LogError(msg + '\n'); \
				std::abort(); \
			} \
		} \
	} while (false)
#define Issue(...) \
	do { \
		auto msg = fmt::format("[Dora Error]\n[File] {},\n[Func] {}, [Line] {},\n[Message] {}", \
			__FILE__, __FUNCTION__, __LINE__, \
			fmt::format(__VA_ARGS__)); \
		if (Dora::IsInLuaOrWasm()) { \
			throw std::runtime_error(msg); \
		} else { \
			Dora::LogError(msg + '\n'); \
			std::abort(); \
		} \
	} while (false)
#endif

NS_DORA_END
