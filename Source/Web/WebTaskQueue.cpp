/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#include "Web/WebTaskQueue.h"

#ifdef DORA_WEB_TASK_AUTORELEASE_POOL
#include "Const/Header.h"
#include "Basic/AutoreleasePool.h"
#endif

#include <cstdio>
#include <deque>

#include <emscripten/emscripten.h>

namespace Dora::Web {

namespace {

std::deque<std::function<void()>> tasks;
bool drainScheduled = false;

void drainOneTask(void*) {
	drainScheduled = false;
	if (tasks.empty()) return;
	auto task = std::move(tasks.front());
	tasks.pop_front();
#ifdef DORA_WEB_TASK_AUTORELEASE_POOL
	SharedPoolManager.push();
#endif
	try {
		task();
	} catch (...) {
		std::fputs("unhandled exception from WebTaskQueue task\n", stderr);
	}
#ifdef DORA_WEB_TASK_AUTORELEASE_POOL
	SharedPoolManager.pop();
#endif
	if (!tasks.empty() && !drainScheduled) {
		drainScheduled = true;
		emscripten_async_call(drainOneTask, nullptr, 0);
	}
}

} // namespace

void postTask(std::function<void()> task) {
	tasks.push_back(std::move(task));
	if (!drainScheduled) {
		drainScheduled = true;
		emscripten_async_call(drainOneTask, nullptr, 0);
	}
}

size_t pendingTaskCount() {
	return tasks.size();
}

} // namespace Dora::Web
