/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#define DORA_DEFAULT_ORG_NAME "IppClub"
#define DORA_DEFAULT_APP_NAME "DoraSSR"

#define NS_DORA_BEGIN namespace Dora {
#define NS_DORA_END }

#define NS_BEGIN(name) namespace name {
#define NS_END(name) }

/** @brief Debug flag, set with the compilar flag by default. */
#ifndef DORA_DEBUG
#define DORA_DEBUG 1
#endif

/** @brief Flag to display a Windows command console. */
#ifndef DORA_WIN_CONSOLE
#define DORA_WIN_CONSOLE 0
#endif

/** @brief Flag to enable test, set with the compilar flag by default. */
#ifndef DORA_TEST
#if DORA_DEBUG
#define DORA_TEST 1
#else
#define DORA_TEST 0
#endif
#endif

/** @brief Disable log function, set with the debug flag. */
#ifndef DORA_DISABLE_LOG
#if DORA_DEBUG
#define DORA_DISABLE_LOG 0
#else
#define DORA_DISABLE_LOG 1
#endif
#endif

/** @brief Disable assert function, set with the debug flag. */
#ifndef DORA_DISABLE_ASSERTION
#if DORA_DEBUG
#define DORA_DISABLE_ASSERTION 0
#else
#define DORA_DISABLE_ASSERTION 1
#endif
#endif

/** @brief The buffer size for content copy function.
 */
#ifndef DORA_COPY_BUFFER_SIZE
#define DORA_COPY_BUFFER_SIZE 4096
#endif

/** @brief Flag to disable lua binding debug codes.
 */
#if !DORA_DEBUG
#define TOLUA_RELEASE
#endif

/** @brief The single squared texture size for baking fonts.
 */
#ifndef DORA_FONT_TEXTURE_SIZE
#define DORA_FONT_TEXTURE_SIZE 2048
#endif

#ifndef DORA_DISABLE_PROFILER
#define DORA_DISABLE_PROFILER 0
#endif

#ifndef DORA_WASM_STACK_SIZE
#define DORA_WASM_STACK_SIZE (1024 * 1024) // 1 MB stack size
#endif

#ifndef DORA_MAX_IMGUI_LOG
#define DORA_MAX_IMGUI_LOG 10000
#endif

#ifndef DORA_STREAMING_AUDIO_FILE_SIZE
#define DORA_STREAMING_AUDIO_FILE_SIZE (2 * 1024 * 1024) // 2 MB file size
#endif

#ifdef DORA_AS_LIB
	#if BX_PLATFORM_WINDOWS
		#define DORA_EXPORT __declspec(dllexport)
	#else
		#define DORA_EXPORT
	#endif
#else
	#define DORA_EXPORT
#endif

// #define DORA_NO_WA

#ifdef DORA_NO_RUST
	#define DORA_NO_STATIC_CALL_BACK
#endif
