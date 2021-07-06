/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Common/Async.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"

NS_DOROTHY_BEGIN

// Async

Async::Async():
_scheduled(false),
_paused(false)
{ }

Async::~Async()
{
	if (_thread.isRunning())
	{
		Async::cancel();
		Async::stop();
	}
}

void Async::stop()
{
	if (_thread.isRunning())
	{
		_workerEvent.post("Stop"_slice);
		_workerSemaphore.post();
		_thread.shutdown();
	}
}

void Async::run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher)
{
	if (!_thread.isRunning())
	{
		_thread.init(Async::work, this);
	}
	if (!_scheduled)
	{
		_scheduled = true;
		SharedDirector.getSystemScheduler()->schedule([this](double deltaTime)
		{
			DORA_UNUSED_PARAM(deltaTime);
			for (Own<QEvent> event = _finisherEvent.poll();
				event != nullptr;
				event = _finisherEvent.poll())
			{
				Own<Package> package;
				Own<Values> result;
				event->get(package, result);
				package->second(std::move(result));
			}
			return false;
		});
	}
	auto package = New<Package>(worker, finisher);
	_workerEvent.post("WorkDone"_slice, std::move(package));
	_workerSemaphore.post();
}

void Async::run(const std::function<void()>& worker)
{
	if (!_thread.isRunning())
	{
		_thread.init(Async::work, this);
	}
	auto work = New<std::function<void()>>(worker);
	_workerEvent.post("Work"_slice, std::move(work));
	_workerSemaphore.post();
}

int Async::work(bx::Thread* thread, void* userData)
{
	DORA_UNUSED_PARAM(thread);
	Async* worker = r_cast<Async*>(userData);
	while (true)
	{
		for (auto event = worker->_workerEvent.poll();
			event != nullptr;
			event = worker->_workerEvent.poll())
		{
			switch (Switch::hash(event->getName()))
			{
				case "Work"_hash:
				{
					std::unique_ptr<std::function<void()>> worker;
					event->get(worker);
					(*worker)();
					break;
				}
				case "WorkDone"_hash:
				{
					Own<Package> package;
					event->get(package);
					Own<Values> result = package->first();
					worker->_finisherEvent.post(Slice::Empty, std::move(package), std::move(result));
					break;
				}
				case "Stop"_hash:
				{
					return 0;
				}
			}
		}
		if (worker->_paused)
		{
			worker->_paused = false;
			worker->_pauseSemaphore.post();
		}
		worker->_workerSemaphore.wait();
	}
	return 0;
}

void Async::pause()
{
	if (_thread.isRunning())
	{
		for (auto event = _workerEvent.poll();
			event != nullptr;
			event = _workerEvent.poll())
		{
			switch (Switch::hash(event->getName()))
			{
				case "Work"_hash:
				{
					Own<std::function<void()>> worker;
					event->get(worker);
					_workers.push_back(std::move(worker));
					break;
				}
				case "WorkDone"_hash:
				{
					std::unique_ptr<Package> package;
					event->get(package);
					_packages.push_back(std::move(package));
					break;
				}
			}
		}
		_paused = true;
		_workerSemaphore.post();
		_pauseSemaphore.wait(); // wait for worker to stop
	}
}

void Async::resume()
{
	if (_thread.isRunning() && !_packages.empty())
	{
		for (auto& package : _packages)
		{
			_workerEvent.post("WorkDone"_slice, std::move(package));
		}
		for (auto& worker : _workers)
		{
			_workerEvent.post("Work"_slice, std::move(worker));
		}
		_packages.clear();
		_workers.clear();
		_workerSemaphore.post(); // make worker work again
	}
}

void Async::cancel()
{
	for (auto event = _workerEvent.poll();
		event != nullptr;
		event = _workerEvent.poll())
	{
		switch (Switch::hash(event->getName()))
		{
			case "Work"_hash:
			{
				Own<std::function<void()>> worker;
				event->get(worker);
				break;
			}
			case "WorkDone"_hash:
			{
				Own<Package> package;
				event->get(package);
				break;
			}
		}
	}
	_packages.clear();
	_workers.clear();
}

// AsyncThread

AsyncThread::AsyncThread():
_nextProcess(0),
_process(std::max(std::thread::hardware_concurrency(), 4u) - 1)
{
	for (int i = 0; i < s_cast<int>(_process.size()); i++)
	{
		_process[i] = New<Async>();
	}
}

Async& AsyncThread::getProcess(int index)
{
	return *_process[index];
}

void AsyncThread::run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher)
{
	Async* async = _process[_nextProcess].get();
	async->run(worker, finisher);
	_nextProcess = (_nextProcess + 1) % _process.size();
}

NS_DOROTHY_END
