/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_COMMON_ODEBUG_H__
#define __DOROTHY_COMMON_ODEBUG_H__

#if BX_PLATFORM_ANDROID
	#include <jni.h>
	#include <android/log.h>
#else
	#include <cstdio>
	#include <cassert>
#endif

NS_DOROTHY_BEGIN

template <typename T>
T oArgument(T value) noexcept
{
	return value;
}

inline const char* oArgument(const string& value) noexcept
{
	return value.empty() ? "" : value.c_str();
}

/** @brief The print function for debugging output. */
template <typename ... Args>
void oPrint(char const * const format, Args const & ... args) noexcept
{
#if BX_PLATFORM_ANDROID
	__android_log_print(ANDROID_LOG_DEBUG, "dorothy debug info", format, oArgument(args) ...);
#else
	printf(format, oArgument(args) ...);
#endif
}
inline void oPrint(char const * const str)
{
	oPrint("%s", str);
}

#if !defined(DORA_DEBUG) || DORA_DEBUG == 0
	#define oLog(...) DORA_DUMMY
#else
	#define oLog(format, ...) \
		oPrint("[Dorothy Log] " \
			format \
			"\n", ##__VA_ARGS__)
#endif

#if DORA_DISABLE_ASSERT
	#define oAssertIf(cond, msg) DORA_DUMMY
	#define oAssertUnless(cond, msg) DORA_DUMMY
#else
	#if BX_PLATFORM_ANDROID
		#define oAssertIf(cond, msg) \
		    if (cond) \
			{ \
        		__android_log_print(ANDROID_LOG_ERROR, \
					"dorothy assert", "file:%s function:%s line:%d, %s", \
					__FILE__, __FUNCTION__, __LINE__, msg); \
    		}
		#define oAssertUnless(cond, msg) \
		    if (!(cond)) \
			{ \
        		__android_log_print(ANDROID_LOG_ERROR, \
					"dorothy assert", "file:%s function:%s line:%d, %s", \
					__FILE__, __FUNCTION__, __LINE__, msg); \
    		}
	#else
		#define oAssertIf(cond, msg) \
			if (cond) \
			{ \
				oPrint("dorothy assert, file:%s function:%s line:%d, %s", \
					__FILE__, __FUNCTION__, __LINE__, msg); \
				assert(!(cond)); \
			}
		#define oAssertUnless(cond, msg) \
			if (!(cond)) \
			{ \
				oPrint("dorothy assert, file:%s function:%s line:%d, %s", \
					__FILE__, __FUNCTION__, __LINE__, msg); \
				assert(cond); \
			}
	#endif
#endif

NS_DOROTHY_END

#endif // __DOROTHY_COMMON_ODEBUG_H__
