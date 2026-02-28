/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

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
	: _scheduled(false)
	, _stopped(false)
	, _pool(nullptr)
	, _poolIndex(0) { }

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
	std::lock_guard<std::mutex> guard(_stopMutex);
	if (_stopped.exchange(true, std::memory_order_acq_rel)) {
		return;
	}
	if (_thread.isRunning()) {
		if (isPoolWorker()) {
			_pool->notifyAllWorkers();
		} else {
			_workerSemaphore.post();
		}
		_thread.shutdown();
	}
}

void Async::run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher) {
	if (_stopped.load(std::memory_order_acquire)) {
		return;
	}
	AssertUnless(SharedApplication.getLogicThread() == std::this_thread::get_id(), "Async runner with finisher should be invoked from logic thread");
	initThreadOnce();
	if (_stopped.load(std::memory_order_acquire)) {
		return;
	}
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
	notifyWorker();
}

void Async::run(const std::function<void()>& worker) {
	if (_stopped.load(std::memory_order_acquire)) {
		return;
	}
	initThreadOnce();
	if (_stopped.load(std::memory_order_acquire)) {
		return;
	}
	auto work = New<std::function<void()>>(worker);
	_workerEvent.post("Work"_slice, std::move(work));
	notifyWorker();
}

void Async::runInMainSync(const std::function<void()>& worker) {
	if (_stopped.load(std::memory_order_acquire)) {
		return;
	}
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
	if (_stopped.load(std::memory_order_acquire)) {
		return;
	}
	_mainThreadSemaphore.wait();
	for (auto& job : jobs) {
		if (std::holds_alternative<WorkPtr>(job)) {
			_workerEvent.post("Work"_slice, std::move(std::get<WorkPtr>(job)));
		} else {
			_workerEvent.post("WorkDone"_slice, std::move(std::get<WorkDonePtr>(job)));
		}
	}
	notifyWorker();
}

int Async::work(bx::Thread* thread, void* userData) {
	DORA_UNUSED_PARAM(thread);
	Async* worker = r_cast<Async*>(userData);
	while (true) {
		if (worker->isPoolWorker()) {
			Async* source = nullptr;
			Own<QEvent> event;
			if (worker->_pool->popTask(worker->_poolIndex, source, event)) {
				source->processWorkerEvent(std::move(event), source);
				continue;
			}
			if (worker->_pool->isStopping()) {
				return 0;
			}
			worker->_pool->waitForTask();
			continue;
		}
		for (auto event = worker->pollWorkerEvent();
			event != nullptr;
			event = worker->pollWorkerEvent()) {
			if (worker->processWorkerEvent(std::move(event), worker)) {
				return 0;
			}
		}
		if (worker->_stopped.load(std::memory_order_acquire)) {
			return 0;
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

void Async::bindPool(AsyncThread* pool, size_t index) {
	_pool = pool;
	_poolIndex = index;
}

Own<QEvent> Async::pollWorkerEvent() {
	return _workerEvent.poll();
}

void Async::notifyWorker() {
	if (isPoolWorker()) {
		_pool->notifyTaskPosted();
	} else {
		_workerSemaphore.post();
	}
}

bool Async::processWorkerEvent(Own<QEvent> event, Async* owner) {
	switch (Switch::hash(event->getName())) {
		case "Work"_hash: {
			Own<std::function<void()>> worker;
			event->get(worker);
			(*worker)();
			return false;
		}
		case "WorkDone"_hash: {
			Own<WorkDone> workDone;
			event->get(workDone);
			Own<Values> result = workDone->first();
			owner->_finisherEvent.post(Slice::Empty, std::move(workDone), std::move(result));
			return false;
		}
		case "Stop"_hash: {
			return !owner->isPoolWorker();
		}
	}
	return false;
}

bool Async::isPoolWorker() const {
	return _pool != nullptr;
}

// AsyncThread

AsyncThread::AsyncThread()
	: _nextProcess(0)
	, _nextStealFrom(0)
	, _stopping(false)
	, _process(std::max(std::thread::hardware_concurrency(), 4u) - 1) {
	for (int i = 0; i < s_cast<int>(_process.size()); i++) {
		_process[i] = New<Async>();
		_process[i]->bindPool(this, s_cast<size_t>(i));
	}
	for (int i = 0; i < s_cast<int>(_process.size()); i++) {
		_process[i]->initThreadOnce();
	}
}

AsyncThread::~AsyncThread() {
	cancel();
}

Async& AsyncThread::getProcess(int index) {
	return *_process[index];
}

void AsyncThread::run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher) {
	if (_stopping.load(std::memory_order_relaxed)) {
		return;
	}
	size_t idx = _nextProcess.fetch_add(1, std::memory_order_relaxed) % _process.size();
	Async* async = _process[idx].get();
	async->run(worker, finisher);
}

void AsyncThread::run(const std::function<void()>& worker) {
	if (_stopping.load(std::memory_order_relaxed)) {
		return;
	}
	size_t idx = _nextProcess.fetch_add(1, std::memory_order_relaxed) % _process.size();
	Async* async = _process[idx].get();
	async->run(worker);
}

Async* AsyncThread::newThread() {
	_userThreads.push_back(New<Async>());
	return _userThreads.back().get();
}

void AsyncThread::cancel() {
	_stopping.store(true, std::memory_order_relaxed);
	notifyAllWorkers();
	for (const auto& thread : _process) {
		thread->cancel();
		thread->stop();
	}
}

bool AsyncThread::popTask(size_t workerIndex, Async*& source, Own<QEvent>& event) {
	Async* self = _process[workerIndex].get();
	if (!self) {
		return false;
	}
	event = self->pollWorkerEvent();
	if (event) {
		source = self;
		return true;
	}
	size_t count = processCount();
	if (count <= 1) {
		return false;
	}
	size_t start = _nextStealFrom.fetch_add(1, std::memory_order_relaxed) % count;
	for (size_t i = 0; i < count; i++) {
		size_t target = (start + i) % count;
		if (target == workerIndex) {
			continue;
		}
		Async* victim = _process[target].get();
		if (!victim) {
			continue;
		}
		event = victim->pollWorkerEvent();
		if (event) {
			source = victim;
			return true;
		}
	}
	return false;
}

void AsyncThread::notifyTaskPosted() {
	_workSemaphore.post();
}

bool AsyncThread::isStopping() const {
	return _stopping.load(std::memory_order_relaxed);
}

void AsyncThread::waitForTask() {
	_workSemaphore.wait();
}

size_t AsyncThread::processCount() const {
	return _process.size();
}

void AsyncThread::notifyAllWorkers() {
	for (size_t i = 0; i < processCount(); i++) {
		_workSemaphore.post();
	}
}

NS_DORA_END
