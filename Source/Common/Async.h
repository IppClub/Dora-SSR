/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Values : public Object
{
public:
	virtual ~Values() { }
	template<class... Args>
	static Ref<Values> create(const Args&... args);
	template<class... Args>
	void get(Args&... args);
	static const Ref<Values> None;
protected:
	Values() { }
};

template<class... Fields>
class ValuesEx : public Values
{
public:
	template<class... Args>
	ValuesEx(const Args&... args):values(std::make_tuple(args...))
	{ }
	std::tuple<Fields...> values;
};

template<class... Args>
Ref<Values> Values::create(const Args&... args)
{
	auto item = new ValuesEx<Args...>(args...);
	Ref<Values> itemRef(item);
	item->release();
	return itemRef;
}

template<class... Args>
void Values::get(Args&... args)
{
	auto values = d_cast<ValuesEx<Args...>*>(this);
	AssertIf(values == nullptr, "no required value type can be retrieved.");
	std::tie(args...) = values->values;
}

/** @brief get a worker runs in another thread and returns a result,
 get a finisher receives the result and runs in main thread. */
class Async
{
	typedef std::pair<function<Ref<Values> ()>,function<void (Values*)>> Package;
public:
	~Async();
	void run(function<Ref<Values> ()> worker, function<void(Values*)> finisher);
	void pause();
	void resume();
	void cancel();
	static int work(void* userData);
private:
	bx::Thread _thread;
	bx::Semaphore _workerSemaphore;
	bx::Semaphore _pauseSemaphore;
	vector<Package> _packages;
	EventQueue _workerEvent;
	EventQueue _finisherEvent;
};

class AsyncThread
{
public:
	Async FileIO;
	Async Process;
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
	SINGLETON(AsyncThread, "ObjectBase");
};

#define SharedAsyncThread \
	Dorothy::Singleton<Dorothy::AsyncThread>::shared()

NS_DOROTHY_END
