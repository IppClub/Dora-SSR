/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Common/Utils.h"

#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Event/Event.h"
#include "Lua/ToLua/tolua++.h"

#if BX_PLATFORM_LINUX
#include <limits.h>
#include <unistd.h>

#include "ghc/fs_fwd.hpp"
namespace fs = ghc::filesystem;
#elif BX_PLATFORM_WINDOWS
#include "ghc/fs_fwd.hpp"
namespace fs = ghc::filesystem;
#else
#include <filesystem>
namespace fs = std::filesystem;
#endif // BX_PLATFORM_LINUX

NS_DORA_BEGIN

int doraType = TOLUA_REG_INDEX_TYPE; // UBOX, CALLBACK, LUA_TYPE

namespace Math {
float rand0to1() {
	auto& app = SharedApplication;
	return s_cast<float>(s_cast<double>(app.getRand() - app.getRandMin()) / app.getRandMax());
}

float rand1to1() {
	return 2.0f * rand0to1() - 1.0f;
}
} // namespace Math

Flag::Flag(ValueType flags)
	: _flags(flags) { }

void Flag::set(ValueType type, bool value) {
	if (value) {
		_flags |= type;
	} else {
		_flags &= ~type;
	}
}

void Flag::toggle(ValueType type) {
	set(type, !isOn(type));
}

const std::string Profiler::EventName = "_TIMECOST_"s;
int Profiler::level = -1;

Profiler::Profiler(String name, String msg)
	: _lastTime(SharedApplication.getCurrentTime())
	, _name(name.toString())
	, _msg(msg.toString()) {
	level++;
}

Profiler::~Profiler() {
	double deltaTime = SharedApplication.getCurrentTime() - _lastTime;
	Event::send(Profiler::EventName, _name, _msg, level, deltaTime);
	level--;
}

std::string Path::concatVector(const std::vector<std::string>& paths) {
	if (paths.empty()) return Slice::Empty;
	if (paths.size() == 1) return paths.front();
	fs::path path = paths.front();
	for (auto it = ++paths.begin(); it != paths.end(); ++it) {
		if (it->empty()) continue;
		if (path.empty()) {
			path = *it;
		} else {
			path /= *it;
		}
	}
	return path.string();
}

std::string Path::concat(const std::list<Slice>& paths) {
	if (paths.empty()) return Slice::Empty;
	if (paths.size() == 1) return paths.front().toString();
	fs::path path = paths.front().toString();
	for (auto it = ++paths.begin(); it != paths.end(); ++it) {
		if (it->empty()) continue;
		if (path.empty()) {
			path = it->toString();
		} else {
			path /= it->toString();
		}
	}
	return path.lexically_normal().string();
}

std::string Path::getExt(String path) {
	auto ext = fs::path(path.toString()).extension().string();
	if (!ext.empty()) ext.erase(ext.begin());
	for (auto& ch : ext) ch = s_cast<char>(std::tolower(ch));
	return ext;
}

std::string Path::getPath(String path) {
	return fs::path(path.toString()).parent_path().string();
}

std::string Path::getName(String path) {
	return fs::path(path.toString()).stem().string();
}

std::string Path::getFilename(String path) {
	return fs::path(path.toString()).filename().string();
}

std::string Path::getRelative(String path, String target) {
	return fs::path(path.toString()).lexically_relative(target.toString()).string();
}

std::string Path::replaceExt(String path, String newExt) {
	std::string ext;
	if (!newExt.empty()) {
		ext = newExt.front() != '.' ? '.' + newExt.toString() : newExt.toString();
	}
	return fs::path(path.toString()).replace_extension(ext).string();
}

std::string Path::replaceFilename(String path, String newFile) {
	return fs::path(path.toString()).replace_filename(newFile.toString()).string();
}

std::function<bool(double)> once(const std::function<Job()>& work) {
	auto co = std::make_shared<std::optional<Job>>();
	return std::function<bool(double)>([co, work](double) {
		if (!*co) {
			*co = work();
			const auto& coroutine = co->value();
			if (coroutine.promise().value || coroutine.done()) {
				return true;
			}
		} else {
			const auto& coroutine = co->value();
			coroutine.resume();
			if (coroutine.promise().exception) {
				std::rethrow_exception(coroutine.promise().exception);
			}
			if (coroutine.promise().value) {
				return true;
			}
			if (coroutine.done()) {
				return true;
			}
		}
		return false;
	});
}

std::function<bool(double)> loop(const std::function<Job()>& work) {
	auto co = std::make_shared<std::optional<Job>>();
	return std::function<bool(double)>([co, work](double) {
		if (!*co) {
			*co = work();
			const auto& coroutine = co->value();
			if (coroutine.promise().value || coroutine.done()) {
				return true;
			}
		} else {
			const auto& coroutine = co->value();
			coroutine.resume();
			if (coroutine.promise().exception) {
				std::rethrow_exception(coroutine.promise().exception);
			}
			if (coroutine.promise().value) {
				return true;
			}
			if (coroutine.done()) {
				*co = std::nullopt;
			}
		}
		return false;
	});
}

void thread(const std::function<Job()>& work) {
	SharedDirector.getScheduler()->schedule(once(work));
}

void threadLoop(const std::function<Job()>& work) {
	SharedDirector.getScheduler()->schedule(loop(work));
}

std::string sprintf(const char* fmt, ...) {
	int size = 1024;
	std::vector<char> buffer(size);

	va_list args;
	va_start(args, fmt);
	int n = vsnprintf(buffer.data(), size, fmt, args);
	va_end(args);

	if (n < 0) {
		// vsnprintf failed
		return "";
	} else if (n < size) {
		// formatted string successfully placed in buffer
		return std::string(buffer.data(), n);
	} else {
		// buffer is not enough, need to reallocate
		size = n + 1;
		buffer.resize(size);

		va_start(args, fmt);
		n = vsnprintf(buffer.data(), size, fmt, args);
		va_end(args);

		if (n < 0 || n >= size) {
			return "";
		}

		return std::string(buffer.data(), n);
	}
}

NS_DORA_END
