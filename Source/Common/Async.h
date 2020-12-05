/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <atomic>
#include <thread>
#include "Event/EventQueue.h"
#include "Support/Value.h"

NS_DOROTHY_BEGIN

/** @brief get a worker runs in another thread and returns a result,
 get a finisher receives the result and runs in main thread. */
class Async
{
	typedef std::pair<function<Own<Values>()>, function<void(Own<Values>)>> Package;
public:
	Async();
	virtual ~Async();
	void run(const function<Own<Values>()>& worker, const function<void(Own<Values>)>& finisher);
	void run(const function<void()>& worker);
	void pause();
	void resume();
	void cancel();
	void stop();
	static int work(bx::Thread* thread, void* userData);
private:
	bool _scheduled;
	std::atomic_bool _paused;
	bx::Thread _thread;
	bx::Semaphore _workerSemaphore;
	bx::Semaphore _pauseSemaphore;
	vector<std::unique_ptr<function<void()>>> _workers;
	vector<std::unique_ptr<Package>> _packages;
	EventQueue _workerEvent;
	EventQueue _finisherEvent;
};

class AsyncThread
{
public:
	Async FileIO;
	AsyncThread();
	void run(const function<Own<Values>()>& worker, const function<void(Own<Values>)>& finisher);
#if BX_PLATFORM_WINDOWS
	inline void* operator new(size_t i)
	{
		return _mm_malloc(i, 16);
	}
	inline void operator delete(void* p)
	{
		_mm_free(p);
	}
#endif // BX_PLATFORM_WINDOWS
private:
	int _nextProcess;
	OwnVector<Async> _process;
	SINGLETON_REF(AsyncThread, ObjectBase);
};

#define SharedAsyncThread \
	Dorothy::Singleton<Dorothy::AsyncThread>::shared()

class AsyncLogThread : public Async
{
public:
	virtual ~AsyncLogThread()
	{
		Async::stop();
	}
#if BX_PLATFORM_WINDOWS
	inline void* operator new(size_t i)
	{
		return _mm_malloc(i, 16);
	}
	inline void operator delete(void* p)
	{
		_mm_free(p);
	}
#endif // BX_PLATFORM_WINDOWS
	SINGLETON_REF(AsyncLogThread);
};

#define SharedAsyncLogThread \
	Dorothy::Singleton<Dorothy::AsyncLogThread>::shared()

NS_DOROTHY_END
