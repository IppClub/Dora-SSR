/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Event/EventQueue.h"
#include "Support/Value.h"

#include "bx/thread.h"

NS_DORA_BEGIN

/** @brief get a worker runs in another thread and returns a result,
 get a finisher receives the result and runs in main thread. */
class Async : public NonCopyable {
	using WorkDone = std::pair<std::function<Own<Values>()>, std::function<void(Own<Values>)>>;
	using Work = std::function<void()>;
	using WorkPtr = Own<Work>;
	using WorkDonePtr = Own<WorkDone>;

public:
	Async();
	virtual ~Async();
	void run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher);
	void run(const std::function<void()>& worker);
	void runInMainSync(const std::function<void()>& worker);
	void cancel();
	void stop();
	static int work(bx::Thread* thread, void* userData);

private:
	void initThreadOnce();
	bool _scheduled;
	bx::Thread _thread;
	bx::Semaphore _workerSemaphore;
	bx::Semaphore _mainThreadSemaphore;
	std::once_flag _initThreadFlag;
	EventQueue _workerEvent;
	EventQueue _finisherEvent;
};

class AsyncThread : public NonCopyable {
public:
	AsyncThread();
	Async& getProcess(int index);
	Async* newThread();
	void run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher);
	void run(const std::function<void()>& worker);
	void cancel();
#if BX_PLATFORM_WINDOWS
	inline void* operator new(size_t i) {
		return _mm_malloc(i, 16);
	}
	inline void operator delete(void* p) {
		_mm_free(p);
	}
#endif // BX_PLATFORM_WINDOWS
private:
	std::atomic<size_t> _nextProcess;
	OwnVector<Async> _process;
	OwnVector<Async> _userThreads;
	SINGLETON_REF(AsyncThread, Director);
};

#define SharedAsyncThread \
	Dora::Singleton<Dora::AsyncThread>::shared()

NS_DORA_END
