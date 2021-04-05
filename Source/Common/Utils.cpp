/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

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

int doraType = TOLUA_REG_INDEX_TYPE; // UBOX, CALLBACK, LUA_TYPE

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

Flag::Flag(IntType flags):_flags(flags)
{ }

void Flag::set(IntType type, bool value)
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

void Flag::toggle(IntType type)
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

std::string Path::concat(const std::list<Slice>& paths)
{
	if (paths.empty()) return Slice::Empty;
	if (paths.size() == 1) return paths.front();
	fs::path path = paths.front().toString();
	for (auto it = ++paths.begin(); it != paths.end(); ++it)
	{
		path /= it->toString();
	}
	return path.string();
}

std::string Path::getExt(const std::string& path)
{
	auto ext = fs::path(path).extension().string();
	if (!ext.empty()) ext.erase(ext.begin());
	for (auto& ch : ext) ch = s_cast<char>(std::tolower(ch));
	return ext;
}

std::string Path::getPath(const std::string& path)
{
	return fs::path(path).parent_path().string();
}

std::string Path::getName(const std::string& path)
{
	return fs::path(path).stem().string();
}

std::string Path::getFilename(const std::string& path)
{
	return fs::path(path).filename().string();
}

std::string Path::replaceExt(const std::string& path, const std::string& newExt)
{
	return fs::path(path).replace_extension('.' + newExt).string();
}

std::string Path::replaceFilename(const std::string& path, const std::string& newFile)
{
	return fs::path(path).replace_filename(newFile).string();
}

NS_DOROTHY_END

// fix issue caused by bx lib from bgfx
#if BX_PLATFORM_ANDROID
#if __ANDROID_API__ < __ANDROID_API_N__

#include <stdio.h>
#undef stdin
#undef stdout
#undef stderr
FILE* stdin = &__sF[0];
FILE* stdout = &__sF[1];
FILE* stderr = &__sF[2];

#endif
#endif // BX_PLATFORM_ANDROID
