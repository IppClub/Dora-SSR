/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <cassert>

NS_DOROTHY_BEGIN

template <typename T>
inline typename std::enable_if<!std::is_same<T,Slice>::value,T>::type Argument(T value)
{
	return value;
}

inline const char* Argument(const string& value)
{
	return value.empty() ? "" : value.c_str();
}

template <typename ...Args>
string LogFormat(const char* format, const Args& ...args)
{
	return fmt::format(format, Argument(args)...);
}

extern Delegate<void (const string&)> LogHandler;

void LogError(const string& str);
void LogPrintInThread(const string& str);

/** @brief The print function for debugging output. */
template <typename ...Args>
void LogPrint(const char* format, const Args& ...args) noexcept
{
	LogPrintInThread(LogFormat(format, args...));
}
inline void LogPrint(const Slice& str)
{
	LogPrintInThread(str);
}

bool IsInLua();

#if DORA_DISABLE_LOG
	#define Info(...) DORA_DUMMY
	#define Warn(...) DORA_DUMMY
	#define Error(...) DORA_DUMMY
#else
	#define Info(format, ...)  \
		Dorothy::LogPrint("[Dorothy Info] " format "\n",  ##__VA_ARGS__)
	#define Warn(format, ...) \
		Dorothy::LogPrint("[Dorothy Warning] " format "\n",  ##__VA_ARGS__)
	#define Error(format, ...) \
		Dorothy::LogPrint("[Dorothy Error] " format "\n",  ##__VA_ARGS__)
#endif

#if DORA_DISABLE_ASSERTION
	#define AssertIf(cond, ...) DORA_DUMMY
	#define AssertUnless(cond, ...) DORA_DUMMY
#else
	#define AssertIf(cond, ...) \
		do { \
			if (cond) \
			{ \
				auto msg = fmt::format("[Dorothy Error]\n[File] {},\n[Func] {}, [Line] {},\n[Message] {}", \
					__FILE__, __FUNCTION__, __LINE__, \
					Dorothy::LogFormat(__VA_ARGS__)); \
				if (Dorothy::IsInLua()) \
				{ \
					throw std::runtime_error(msg); \
				} \
				else \
				{ \
					Dorothy::LogError(msg); \
					std::abort(); \
				} \
			} \
		} while (false)
	#define AssertUnless(cond, ...) \
		do { \
			if (!(cond)) \
			{ \
				auto msg = fmt::format("[Dorothy Error]\n[File] {},\n[Func] {}, [Line] {},\n[Message] {}", \
					__FILE__, __FUNCTION__, __LINE__, \
					Dorothy::LogFormat(__VA_ARGS__)); \
				if (Dorothy::IsInLua()) \
				{ \
					throw std::runtime_error(msg); \
				} \
				else \
				{ \
					Dorothy::LogError(msg); \
					std::abort(); \
				} \
			} \
		} while (false)
#endif

NS_DOROTHY_END
