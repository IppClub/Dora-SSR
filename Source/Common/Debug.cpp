/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Common/Debug.h"
#include "Common/Singleton.h"
#include "Common/Async.h"
#include "Basic/Application.h"

#if BX_PLATFORM_ANDROID
#include <jni.h>
#include <android/log.h>
#endif // BX_PLATFORM_ANDROID

#if !DORA_DISABLE_ASSERT_IN_LUA
#include "Lua/LuaEngine.h"
#endif // !DORA_DISABLE_ASSERT_IN_LUA

NS_DOROTHY_BEGIN

Delegate<void (const string&)> LogHandler;

void LogPrintInThread(const string& str)
{
	SharedApplication.invokeInLogic([str]()
	{
		SharedAsyncLogThread.run([str]
		{
	#if DORA_DEBUG
	#if BX_PLATFORM_ANDROID
			__android_log_print(ANDROID_LOG_DEBUG, "dorothy debug info", "%s", str.c_str());
	#else
			fmt::print("{}", str);
	#endif // BX_PLATFORM_ANDROID
	#endif // DORA_DEBUG
			return std::move(Values::None);
		}, [str](std::unique_ptr<Values>)
		{
			LogHandler(str);
		});
	});
}

#if !DORA_DISABLE_ASSERT_IN_LUA
void DoraAssert(bool cond, const Slice& msg)
{
	if (Dorothy::Singleton<Dorothy::LuaEngine>::isDisposed())
	{
		assert(cond);
	}
	else if (!cond && !SharedLuaEngine.executeAssert(cond, msg))
	{
		assert(cond);
	}
}
#endif // !DORA_DISABLE_ASSERT_IN_LUA

NS_DOROTHY_END
