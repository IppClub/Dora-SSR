/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#if BX_PLATFORM_ANDROID
	#include <jni.h>
	#include <android/log.h>
#else
	#include <cstdio>
	#include <cassert>
#endif

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

/** @brief The print function for debugging output. */
template <typename ...Args>
void Print(const char* format, const Args& ...args) noexcept
{
#if BX_PLATFORM_ANDROID
	__android_log_print(ANDROID_LOG_DEBUG, "dorothy debug info", format, Argument(args)...);
#else
	printf(format, Argument(args)...);
#endif
}
inline void Print(const char* str)
{
	Print("%s", str);
}

#if !defined(DORA_DEBUG) || DORA_DEBUG == 0
	#define Log(...) DORA_DUMMY
#else
	#define Log(format, ...) \
		Print("[Dorothy Log] " \
			format \
			"\n",  ##__VA_ARGS__)
#endif

#if DORA_DISABLE_ASSERT_IN_LUA
	#define DORA_ASSERT(cond) assert(cond)
#else
	#define DORA_ASSERT(cond) \
		if (!SharedLueEngine.executeAssert(cond, #cond)) \
		{ \
			assert(cond); \
		}
#endif

#if DORA_DISABLE_ASSERT
	#define AssertIf(cond, ...) DORA_DUMMY
	#define AssertUnless(cond, ...) DORA_DUMMY
#else
	#define AssertIf(cond, ...) \
		{ \
			if (cond) \
			{ \
				Print("[Dorothy Assert] [File] %s, [Func] %s, [Line] %d, [Error] ", \
					__FILE__, __FUNCTION__, __LINE__); \
				Print(__VA_ARGS__); \
				Print("\n"); \
				DORA_ASSERT(!(cond)); \
			} \
		}
	#define AssertUnless(cond, ...) \
		{ \
			if (!(cond)) \
			{ \
				Print("[Dorothy Assert] [File] %s, [Func] %s, [Line] %d, [Error] ", \
					__FILE__, __FUNCTION__, __LINE__); \
				Print(__VA_ARGS__); \
				Print("\n"); \
				DORA_ASSERT(cond); \
			} \
		}
#endif

NS_DOROTHY_END
