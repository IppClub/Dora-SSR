/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Common/Utils.h"
#include "Basic/Application.h"
#include "Lua/ToLua/tolua++.h"
#ifdef DORA_FILESYSTEM_ALTER
#include "ghc/fs_fwd.hpp"
namespace fs = ghc::filesystem;
#else
#include <filesystem>
namespace fs = std::filesystem;
#endif // DORA_FILESYSTEM_ALTER

NS_DOROTHY_BEGIN

int doraType = TOLUA_REG_INDEX_TYPE; // 1:UBOX 2:CALLBACK 3:LUA_TYPE

namespace Math
{
	float rand0to1()
	{
		auto& app = SharedApplication;
		return s_cast<float>(s_cast<double>(app.getRand() - app.getRandMin()) / app.getRandMax());
	}

	float rand1to1()
	{
		return 2.0f * rand0to1() - 1.0f;
	}
}

Flag::Flag(Uint32 flags):_flags(flags)
{ }

void Flag::set(Uint32 type, bool value)
{
	if (value)
	{
		_flags |= type;
	}
	else
	{
		_flags &= ~type;
	}
}

void Flag::toggle(Uint32 type)
{
	set(type, !isOn(type));
}

Profiler::Profiler():
_lastTime(SharedApplication.getCurrentTime())
{ }

void Profiler::start()
{
	_lastTime = SharedApplication.getCurrentTime();
}

double Profiler::stop(String logName)
{
	double deltaTime = SharedApplication.getCurrentTime() - _lastTime;
	if (!logName.empty())
	{
		Info("{} cost {:.3f}s.", logName, deltaTime);
	}
	_lastTime = SharedApplication.getCurrentTime();
	return deltaTime;
}

string Path::concat(const list<string>& paths)
{
	if (paths.empty()) return Slice::Empty;
	if (paths.size() == 1) return paths.front();
	fs::path path = paths.front();
	for (auto it = ++paths.begin(); it != paths.end(); ++it)
	{
		path /= *(it);
	}
	return path.string();
}

string Path::getExt(const string& path)
{
	auto ext = fs::path(path).extension().string();
	if (!ext.empty()) ext.erase(ext.begin());
	for (auto& ch : ext) ch = s_cast<char>(std::tolower(ch));
	return ext;
}

string Path::getPath(const string& path)
{
	return fs::path(path).parent_path().string();
}

string Path::getName(const string& path)
{
	return fs::path(path).stem().string();
}

string Path::getFilename(const string& path)
{
	return fs::path(path).filename().string();
}

string Path::replaceExt(const string& path, const string& newExt)
{
	return fs::path(path).replace_extension('.' + newExt).string();
}

string Path::replaceFilename(const string& path, const string& newFile)
{
	return fs::path(path).replace_filename(newFile).string();
}

NS_DOROTHY_END

// fix issue caused by Android NDK r16
#if BX_PLATFORM_ANDROID
#include <stdio.h>

#undef stdin
#undef stdout
#undef stderr
FILE* stdin = &__sF[0];
FILE* stdout = &__sF[1];
FILE* stderr = &__sF[2];
#endif // BX_PLATFORM_ANDROID
