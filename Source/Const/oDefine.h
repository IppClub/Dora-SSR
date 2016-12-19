/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_CONST_ODEFINE_H__
#define __DOROTHY_CONST_ODEFINE_H__

#define DORA_DEFAULT_ORG_NAME "LuvFight"
#define DORA_DEFAULT_APP_NAME "DorothySSR"

/** @brief Define the destruction orders of singleton intances,
	the lowest indiced instance will be destroyed first. */
ENUM_START(oSingletonIndex)
{
	ContentManager,
	PoolManager,
	LuaEngine,
	Director
}
ENUM_END(oSingletonIndex)

/** @brief Debug flag, set with the compilar flag by default. */
#ifndef DORA_DEBUG
	#if NDEBUG
		#define DORA_DEBUG 0
	#else
		#define DORA_DEBUG 1
	#endif
#endif

/** @brief Disable assert, set with the debug flag. */
#ifndef DORA_DISABLE_ASSERT
	#if DORA_DEBUG
		#define DORA_DISABLE_ASSERT 0
	#else
		#define DORA_DISABLE_ASSERT 1
	#endif
#endif

#endif // __DOROTHY_CONST_ODEFINE_H__
