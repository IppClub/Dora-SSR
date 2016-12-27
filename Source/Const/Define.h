/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#define DORA_DEFAULT_ORG_NAME "LuvFight"
#define DORA_DEFAULT_APP_NAME "DorothySSR"

#define NS_DOROTHY_BEGIN namespace Dorothy {
#define NS_DOROTHY_END }

NS_DOROTHY_BEGIN

/** @brief Define the destruction orders of singleton intances,
	the lowest indiced instance will be destroyed first. */
namespace SingletonIndex
{
	enum {
		ContentManager,
		PoolManager,
		LuaEngine,
		Director,
		Application
	};
}

/** @brief Debug flag, set with the compilar flag by default. */
#ifndef DORA_DEBUG
	#if NDEBUG
		#define DORA_DEBUG 0
	#else
		#define DORA_DEBUG 1
	#endif
#endif

/** @brief Disable assert function, set with the debug flag. */
#ifndef DORA_DISABLE_ASSERT
	#if DORA_DEBUG
		#define DORA_DISABLE_ASSERT 0
	#else
		#define DORA_DISABLE_ASSERT 1
	#endif
#endif

/** @brief Disable replacing C++ assert with lua_error.
 Use lua_error, assert info will be print in lua console and program
 won`t be aborted.
 */
#ifndef DORA_DISABLE_ASSERT_IN_LUA
	#define DORA_DISABLE_ASSERT_IN_LUA 0
#else
	#define DORA_DISABLE_ASSERT_IN_LUA 1
#endif

/** @brief The SWITCH_STR_START() helper macros for doing faster string
 switch case, will do a string equal comparation to prevent string hash
 collision but that is a pretty rare case.
*/
#ifdef DORA_FEAR_HASH_COLLISION
	#define DORA_HASH_CHECK_EQUAL false
#else
	#define DORA_HASH_CHECK_EQUAL true
#endif

NS_DOROTHY_END
