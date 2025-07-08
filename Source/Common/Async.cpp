/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Common/Async.h"

#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"

NS_DORA_BEGIN

// Async

Async::Async()
	: _scheduled(false) { }

Async::~Async() {
	if (_thread.isRunning()) {
		Async::cancel();
		Async::stop();
	}
}

void Async::initThreadOnce() {
	std::call_once(_initThreadFlag, [this]() {
		if (!_thread.isRunning()) {
			_thread.init(Async::work, this);
		}
	});
}

void Async::stop() {
	if (_thread.isRunning()) {
		_workerEvent.post("Stop"_slice);
		_workerSemaphore.post();
		_thread.shutdown();
	}
}

void Async::run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher) {
	AssertUnless(SharedApplication.getLogicThread() == std::this_thread::get_id(), "Async runner with finisher should be invoked from logic thread");
	initThreadOnce();
	if (!_scheduled) {
		_scheduled = true;
		SharedDirector.getSystemScheduler()->schedule([this](double deltaTime) {
			DORA_UNUSED_PARAM(deltaTime);
			for (Own<QEvent> event = _finisherEvent.poll();
				event != nullptr;
				event = _finisherEvent.poll()) {
				Own<WorkDone> workDone;
				Own<Values> result;
				event->get(workDone, result);
				workDone->second(std::move(result));
			}
			return false;
		});
	}
	auto workDone = New<WorkDone>(worker, finisher);
	_workerEvent.post("WorkDone"_slice, std::move(workDone));
	_workerSemaphore.post();
}

void Async::run(const std::function<void()>& worker) {
	initThreadOnce();
	auto work = New<std::function<void()>>(worker);
	_workerEvent.post("Work"_slice, std::move(work));
	_workerSemaphore.post();
}

void Async::runInMainSync(const std::function<void()>& worker) {
	AssertUnless(SharedApplication.getLogicThread() == std::this_thread::get_id(), "Async runner should be invoked from logic thread");
	std::list<std::variant<WorkPtr, WorkDonePtr>> jobs;
	for (auto event = _workerEvent.poll();
		event != nullptr;
		event = _workerEvent.poll()) {
		switch (Switch::hash(event->getName())) {
			case "Work"_hash: {
				Own<std::function<void()>> worker;
				event->get(worker);
				jobs.push_back(std::move(worker));
				break;
			}
			case "WorkDone"_hash: {
				Own<WorkDone> workDone;
				event->get(workDone);
				jobs.push_back(std::move(workDone));
				break;
			}
		}
	}
	run([&]() {
		worker();
		_mainThreadSemaphore.post();
	});
	_mainThreadSemaphore.wait();
	for (auto& job : jobs) {
		if (std::holds_alternative<WorkPtr>(job)) {
			_workerEvent.post("Work"_slice, std::move(std::get<WorkPtr>(job)));
		} else {
			_workerEvent.post("WorkDone"_slice, std::move(std::get<WorkDonePtr>(job)));
		}
	}
	_workerSemaphore.post();
}

int Async::work(bx::Thread* thread, void* userData) {
	DORA_UNUSED_PARAM(thread);
	Async* worker = r_cast<Async*>(userData);
	while (true) {
		for (auto event = worker->_workerEvent.poll();
			event != nullptr;
			event = worker->_workerEvent.poll()) {
			switch (Switch::hash(event->getName())) {
				case "Work"_hash: {
					Own<std::function<void()>> worker;
					event->get(worker);
					(*worker)();
					break;
				}
				case "WorkDone"_hash: {
					Own<WorkDone> workDone;
					event->get(workDone);
					Own<Values> result = workDone->first();
					worker->_finisherEvent.post(Slice::Empty, std::move(workDone), std::move(result));
					break;
				}
				case "Stop"_hash: {
					return 0;
				}
			}
		}
		worker->_workerSemaphore.wait();
	}
	return 0;
}

void Async::cancel() {
	for (auto event = _workerEvent.poll();
		event != nullptr;
		event = _workerEvent.poll()) {
		switch (Switch::hash(event->getName())) {
			case "Work"_hash: {
				Own<std::function<void()>> worker;
				break;
			}
			case "WorkDone"_hash: {
				Own<WorkDone> workDone;
				event->get(workDone);
				break;
			}
		}
	}
}

// AsyncThread

AsyncThread::AsyncThread()
	: _nextProcess(0)
	, _process(std::max(std::thread::hardware_concurrency(), 4u) - 1) {
	for (int i = 0; i < s_cast<int>(_process.size()); i++) {
		_process[i] = New<Async>();
	}
}

Async& AsyncThread::getProcess(int index) {
	return *_process[index];
}

void AsyncThread::run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher) {
	size_t idx = _nextProcess.fetch_add(1, std::memory_order_relaxed) % _process.size();
	Async* async = _process[idx].get();
	async->run(worker, finisher);
}

void AsyncThread::run(const std::function<void()>& worker) {
	size_t idx = _nextProcess.fetch_add(1, std::memory_order_relaxed) % _process.size();
	Async* async = _process[idx].get();
	async->run(worker);
}

Async* AsyncThread::newThread() {
	_userThreads.push_back(New<Async>());
	return _userThreads.back().get();
}

void AsyncThread::cancel() {
	for (const auto& thread : _process) {
		thread->cancel();
		thread->stop();
	}
}

NS_DORA_END
