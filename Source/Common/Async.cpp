/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Common/Async.h"

#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"

#include <algorithm>
#include <chrono>
#include <condition_variable>
#include <cstdio>
#include <exception>
#include <stdexcept>

NS_DORA_BEGIN

namespace {

thread_local Async* currentAsyncWorker = nullptr;
thread_local bool runningFrameTaskOnCaller = false;

void reportAsyncException(const std::exception_ptr& exception, const char* context) noexcept {
	try {
		try {
			std::rethrow_exception(exception);
		} catch (const std::exception& e) {
			LogErrorThreaded(fmt::format("unhandled exception from {}: {}", context, e.what()));
		} catch (...) {
			LogErrorThreaded(fmt::format("unhandled non-standard exception from {}", context));
		}
	} catch (...) {
		std::fputs("unhandled exception from Async; error reporting also failed\n", stderr);
	}
}

void requireLogicThread(const char* operation) {
	if (SharedApplication.getLogicThread() != std::this_thread::get_id()) {
		throw std::runtime_error(fmt::format("{} must be invoked from the logic thread", operation));
	}
}

} // namespace

class AsyncFinisherState {
public:
	EventQueue events;
	std::atomic_bool active{true};
};

class AsyncSyncState {
public:
	void complete(std::exception_ptr exception = nullptr) {
		std::lock_guard<std::mutex> guard(_mutex);
		if (_done) return;
		_exception = exception;
		_done = true;
		_condition.notify_all();
	}

	void cancel() {
		std::lock_guard<std::mutex> guard(_mutex);
		if (_done) return;
		_cancelled = true;
		_done = true;
		_condition.notify_all();
	}

	bool wait() {
		std::exception_ptr exception;
		bool cancelled;
		{
			std::unique_lock<std::mutex> lock(_mutex);
			_condition.wait(lock, [this]() { return _done; });
			exception = _exception;
			cancelled = _cancelled;
		}
		if (exception) std::rethrow_exception(exception);
		return !cancelled;
	}

private:
	std::mutex _mutex;
	std::condition_variable _condition;
	bool _done = false;
	bool _cancelled = false;
	std::exception_ptr _exception;
};

class AsyncTaskGroupState {
public:
	explicit AsyncTaskGroupState(bool reportExceptionsImmediately = false)
		: _reportExceptionsImmediately(reportExceptionsImmediately) { }

	void add() {
		std::lock_guard<std::mutex> guard(_mutex);
		++_pending;
	}

	void complete(std::exception_ptr exception = nullptr) {
		if (exception && _reportExceptionsImmediately) {
			reportAsyncException(exception, "default AsyncTaskGroup");
		}
		std::exception_ptr additionalException;
		{
			std::lock_guard<std::mutex> guard(_mutex);
			if (exception && !_reportExceptionsImmediately) {
				if (!_exception) {
					_exception = exception;
				} else {
					additionalException = exception;
				}
			}
			AssertUnless(_pending > 0, "completed an AsyncTaskGroup task more than once");
			if (--_pending == 0) {
				_condition.notify_all();
			}
		}
		if (additionalException) {
			reportAsyncException(additionalException, "AsyncTaskGroup additional task");
		}
	}

	void wait() {
		std::exception_ptr exception;
		{
			std::unique_lock<std::mutex> lock(_mutex);
			_condition.wait(lock, [this]() { return _pending == 0; });
			exception = std::exchange(_exception, nullptr);
		}
		if (exception) {
			std::rethrow_exception(exception);
		}
	}

	size_t getPendingCount() const {
		std::lock_guard<std::mutex> guard(_mutex);
		return _pending;
	}

private:
	mutable std::mutex _mutex;
	std::condition_variable _condition;
	size_t _pending = 0;
	std::exception_ptr _exception;
	bool _reportExceptionsImmediately;
};

class AsyncFrameTaskState {
public:
	void reset(size_t taskCount, const std::function<void(size_t)>& task) {
		std::lock_guard<std::mutex> guard(_mutex);
		AssertUnless(_pending.load(std::memory_order_relaxed) == 0,
			"resetting a FrameTask batch before it completed");
		AssertUnless(!_task, "resetting a FrameTask batch before wait consumed it");
		_exception = nullptr;
		_task = &task;
		_pending.store(taskCount, std::memory_order_release);
	}

	void execute(size_t index) noexcept {
		std::exception_ptr exception;
		try {
			AssertUnless(_task != nullptr, "executing a FrameTask without an active batch");
			(*_task)(index);
		} catch (...) {
			exception = std::current_exception();
		}
		complete(exception);
	}

	void cancel() noexcept {
		complete(nullptr);
	}

	void wait() {
		std::exception_ptr exception;
		{
			std::unique_lock<std::mutex> lock(_mutex);
			_condition.wait(lock, [this]() {
				return _pending.load(std::memory_order_acquire) == 0;
			});
			exception = std::exchange(_exception, nullptr);
			_task = nullptr;
		}
		if (exception) std::rethrow_exception(exception);
	}

private:
	void complete(const std::exception_ptr& exception) noexcept {
		std::exception_ptr additionalException;
		if (exception) {
			std::lock_guard<std::mutex> guard(_mutex);
			if (!_exception) {
				_exception = exception;
			} else {
				additionalException = exception;
			}
		}
		const auto previous = _pending.fetch_sub(1, std::memory_order_acq_rel);
		if (previous == 0) {
			LogError("completed a FrameTask more than once");
			std::abort();
		}
		if (previous == 1) {
			// Serialize the final notification with wait() entering its sleep state.
			// The pending counter is atomic, but notifying without this mutex leaves a
			// lost-wakeup window between the predicate check and the actual wait.
			std::lock_guard<std::mutex> guard(_mutex);
			_condition.notify_all();
		}
		if (additionalException) {
			reportAsyncException(additionalException, "FrameTask additional task");
		}
	}

	std::atomic<size_t> _pending{0};
	std::mutex _mutex;
	std::condition_variable _condition;
	const std::function<void(size_t)>* _task = nullptr;
	std::exception_ptr _exception;
};

// AsyncTaskGroup

AsyncTaskGroup::AsyncTaskGroup(AsyncThread* pool, std::shared_ptr<AsyncTaskGroupState> state)
	: _pool(pool)
	, _state(std::move(state)) { }

AsyncTaskGroup::AsyncTaskGroup(AsyncTaskGroup&& other) noexcept
	: _pool(std::exchange(other._pool, nullptr))
	, _state(std::move(other._state)) { }

AsyncTaskGroup& AsyncTaskGroup::operator=(AsyncTaskGroup&& other) noexcept {
	if (this != &other) {
		_pool = std::exchange(other._pool, nullptr);
		_state = std::move(other._state);
	}
	return *this;
}

AsyncTaskGroup::~AsyncTaskGroup() { }

bool AsyncTaskGroup::run(const std::function<void()>& worker) {
	return _pool && _state && _pool->run(*this, nullptr, worker);
}

void AsyncTaskGroup::wait() {
	if (_state) {
		if (currentAsyncWorker && currentAsyncWorker->_pool == _pool) {
			throw std::runtime_error("AsyncTaskGroup::wait cannot be called from a worker in the same pool");
		}
		_state->wait();
	}
}

size_t AsyncTaskGroup::getPendingCount() const {
	return _state ? _state->getPendingCount() : 0;
}

// Async

Async::Async()
	: _scheduled(false)
	, _finisherState(std::make_shared<AsyncFinisherState>())
	, _standaloneTaskState(std::make_shared<AsyncTaskGroupState>(true))
	, _stopped(false)
	, _pool(nullptr)
	, _poolIndex(0) { }

Async::~Async() {
	if (currentAsyncWorker == this) {
		LogError("destroying Async from its own worker thread is not supported");
		std::abort();
	}
	Async::cancel();
	Async::stop();
	_finisherState->active.store(false, std::memory_order_release);
}

void Async::initThreadOnce() {
	std::call_once(_initThreadFlag, [this]() {
		if (!_thread.isRunning()) {
			_thread.init(Async::work, this);
		}
	});
}

void Async::stop() {
	if (isPoolWorker() && !_pool->isStopping()) {
		throw std::runtime_error("an individual AsyncThread pool worker cannot be stopped; call AsyncThread::cancel instead");
	}
	requestStop();
	if (currentAsyncWorker == this) return;
	std::lock_guard<std::mutex> stopGuard(_stopMutex);
	if (_thread.isRunning()) {
		_thread.shutdown();
	}
}

void Async::requestStop() {
	_finisherState->active.store(false, std::memory_order_release);
	{
		std::lock_guard<std::mutex> submitGuard(_submitMutex);
		if (!_stopped.exchange(true, std::memory_order_acq_rel)) {
			if (!isPoolWorker()) {
				_workerSemaphore.post();
			}
		}
	}
}

void Async::run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher) {
	if (isPoolWorker()) {
		_pool->run(_pool->getDefaultGroup(), this, worker, finisher);
		return;
	}
	_standaloneTaskState->add();
	try {
		if (!run(worker, finisher, _standaloneTaskState)) {
			_standaloneTaskState->complete();
		}
	} catch (...) {
		_standaloneTaskState->complete();
		throw;
	}
}

bool Async::run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher, const std::shared_ptr<AsyncTaskGroupState>& group) {
	requireLogicThread("Async::run with finisher");
	std::lock_guard<std::mutex> submitGuard(_submitMutex);
	if (_stopped.load(std::memory_order_acquire)) {
		return false;
	}
	initThreadOnce();
	if (_stopped.load(std::memory_order_acquire)) {
		return false;
	}
	if (!_scheduled) {
		_scheduled = true;
		auto finisherState = _finisherState;
		SharedDirector.getSystemScheduler()->schedule([finisherState](double deltaTime) {
			DORA_UNUSED_PARAM(deltaTime);
			if (!finisherState->active.load(std::memory_order_acquire)) return true;
			for (Own<QEvent> event = finisherState->events.poll();
				event != nullptr;
				event = finisherState->events.poll()) {
				Own<WorkDone> workDone;
				Own<Values> result;
				event->get(workDone, result);
				try {
					workDone->second(std::move(result));
				} catch (...) {
					reportAsyncException(std::current_exception(), "Async finisher");
				}
			}
			return !finisherState->active.load(std::memory_order_acquire);
		});
	}
	auto workDone = New<WorkDone>(worker, finisher);
	_workerEvent.post("WorkDone"_slice, std::move(workDone), group);
	notifyWorker();
	return true;
}

void Async::run(const std::function<void()>& worker) {
	if (isPoolWorker()) {
		_pool->run(_pool->getDefaultGroup(), this, worker);
		return;
	}
	_standaloneTaskState->add();
	try {
		if (!run(worker, _standaloneTaskState)) {
			_standaloneTaskState->complete();
		}
	} catch (...) {
		_standaloneTaskState->complete();
		throw;
	}
}

bool Async::run(const std::function<void()>& worker, const std::shared_ptr<AsyncTaskGroupState>& group) {
	std::lock_guard<std::mutex> submitGuard(_submitMutex);
	if (_stopped.load(std::memory_order_acquire)) {
		return false;
	}
	initThreadOnce();
	if (_stopped.load(std::memory_order_acquire)) {
		return false;
	}
	auto work = New<std::function<void()>>(worker);
	_workerEvent.post("Work"_slice, std::move(work), group);
	notifyWorker();
	return true;
}

void Async::runInMainSync(const std::function<void()>& worker) {
	requireLogicThread("Async::runInMainSync");
	using QueuedWork = std::pair<WorkPtr, std::shared_ptr<AsyncTaskGroupState>>;
	using QueuedWorkDone = std::pair<WorkDonePtr, std::shared_ptr<AsyncTaskGroupState>>;
	using QueuedSyncWork = std::pair<WorkPtr, std::shared_ptr<AsyncSyncState>>;
	using QueuedJob = std::variant<QueuedWork, QueuedWorkDone, QueuedSyncWork>;
	std::list<QueuedJob> jobs;
	auto syncState = std::make_shared<AsyncSyncState>();
	{
		std::lock_guard<std::mutex> submitGuard(_submitMutex);
		if (_stopped.load(std::memory_order_acquire)) return;
		for (auto event = _workerEvent.poll();
			event != nullptr;
			event = _workerEvent.poll()) {
			switch (Switch::hash(event->getName())) {
				case "Work"_hash: {
					Own<std::function<void()>> queuedWorker;
					std::shared_ptr<AsyncTaskGroupState> group;
					event->get(queuedWorker, group);
					jobs.emplace_back(QueuedWork{std::move(queuedWorker), std::move(group)});
					break;
				}
				case "WorkDone"_hash: {
					Own<WorkDone> workDone;
					std::shared_ptr<AsyncTaskGroupState> group;
					event->get(workDone, group);
					jobs.emplace_back(QueuedWorkDone{std::move(workDone), std::move(group)});
					break;
				}
				case "SyncWork"_hash: {
					Own<std::function<void()>> queuedWorker;
					std::shared_ptr<AsyncSyncState> queuedState;
					event->get(queuedWorker, queuedState);
					jobs.emplace_back(QueuedSyncWork{std::move(queuedWorker), std::move(queuedState)});
					break;
				}
			}
		}
		initThreadOnce();
		auto syncWork = New<std::function<void()>>(worker);
		_workerEvent.post("SyncWork"_slice, std::move(syncWork), syncState);
		notifyWorker();
	}

	std::exception_ptr exception;
	bool completed = false;
	try {
		completed = syncState->wait();
	} catch (...) {
		exception = std::current_exception();
		completed = true;
	}

	{
		std::lock_guard<std::mutex> submitGuard(_submitMutex);
		bool restore = completed && !_stopped.load(std::memory_order_acquire);
		for (auto& job : jobs) {
			if (std::holds_alternative<QueuedWork>(job)) {
				auto& [queuedWorker, group] = std::get<QueuedWork>(job);
				if (restore) {
					_workerEvent.post("Work"_slice, std::move(queuedWorker), std::move(group));
				} else if (group) {
					group->complete();
				}
			} else if (std::holds_alternative<QueuedWorkDone>(job)) {
				auto& [workDone, group] = std::get<QueuedWorkDone>(job);
				if (restore) {
					_workerEvent.post("WorkDone"_slice, std::move(workDone), std::move(group));
				} else if (group) {
					group->complete();
				}
			} else {
				auto& [queuedWorker, queuedState] = std::get<QueuedSyncWork>(job);
				if (restore) {
					_workerEvent.post("SyncWork"_slice, std::move(queuedWorker), std::move(queuedState));
				} else {
					queuedState->cancel();
				}
			}
		}
		if (restore && !jobs.empty()) notifyWorker();
	}
	if (exception) std::rethrow_exception(exception);
}

int Async::work(bx::Thread* thread, void* userData) {
	DORA_UNUSED_PARAM(thread);
	Async* worker = r_cast<Async*>(userData);
	currentAsyncWorker = worker;
	DEFER(currentAsyncWorker = nullptr);
	while (true) {
		if (worker->isPoolWorker()) {
			AsyncThread::FrameTaskItem frameTask;
			if (worker->_pool->popFrameTask(frameTask)) {
				frameTask.state->execute(frameTask.index);
				continue;
			}
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
	std::lock_guard<std::mutex> submitGuard(_submitMutex);
	for (auto event = _workerEvent.poll();
		event != nullptr;
		event = _workerEvent.poll()) {
		switch (Switch::hash(event->getName())) {
			case "Work"_hash: {
				Own<std::function<void()>> worker;
				std::shared_ptr<AsyncTaskGroupState> group;
				event->get(worker, group);
				if (group) group->complete();
				break;
			}
			case "WorkDone"_hash: {
				Own<WorkDone> workDone;
				std::shared_ptr<AsyncTaskGroupState> group;
				event->get(workDone, group);
				if (group) group->complete();
				break;
			}
			case "SyncWork"_hash: {
				Own<std::function<void()>> worker;
				std::shared_ptr<AsyncSyncState> syncState;
				event->get(worker, syncState);
				syncState->cancel();
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
			std::shared_ptr<AsyncTaskGroupState> group;
			event->get(worker, group);
			try {
				(*worker)();
				if (group) group->complete();
			} catch (...) {
				if (group) {
					group->complete(std::current_exception());
				} else {
					reportAsyncException(std::current_exception(), "Async worker");
				}
			}
			return false;
		}
		case "WorkDone"_hash: {
			Own<WorkDone> workDone;
			std::shared_ptr<AsyncTaskGroupState> group;
			event->get(workDone, group);
			Own<Values> result;
			try {
				result = workDone->first();
			} catch (...) {
				if (group) {
					group->complete(std::current_exception());
				} else {
					reportAsyncException(std::current_exception(), "Async worker with finisher");
				}
				return false;
			}
			if (group) group->complete();
			owner->_finisherState->events.post(Slice::Empty, std::move(workDone), std::move(result));
			return false;
		}
		case "SyncWork"_hash: {
			Own<std::function<void()>> worker;
			std::shared_ptr<AsyncSyncState> syncState;
			event->get(worker, syncState);
			try {
				(*worker)();
				syncState->complete();
			} catch (...) {
				syncState->complete(std::current_exception());
			}
			return false;
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
	, _process(std::max(std::thread::hardware_concurrency(), 4u) - 1)
	, _defaultGroup(new TaskGroup(this, std::make_shared<AsyncTaskGroupState>(true)))
	, _frameTaskState(new AsyncFrameTaskState()) {
	for (int i = 0; i < s_cast<int>(_process.size()); i++) {
		_process[i] = New<Async>();
		_process[i]->bindPool(this, s_cast<size_t>(i));
	}
	for (int i = 0; i < s_cast<int>(_process.size()); i++) {
		_process[i]->initThreadOnce();
	}
}

AsyncThread::~AsyncThread() {
	if (currentAsyncWorker) {
		bool ownedWorker = currentAsyncWorker->_pool == this;
		if (!ownedWorker) {
			ownedWorker = std::any_of(_dedicatedThreads.begin(), _dedicatedThreads.end(), [](const Own<Async>& thread) {
				return thread.get() == currentAsyncWorker;
			});
		}
		if (ownedWorker) {
			LogError("destroying AsyncThread from one of its own workers is not supported");
			std::abort();
		}
	}
	cancel();
}

Async& AsyncThread::getProcess(int index) {
	if (index < 0 || s_cast<size_t>(index) >= _process.size()) {
		throw std::out_of_range(fmt::format("AsyncThread worker index {} is out of range [0, {})", index, _process.size()));
	}
	return *_process[index];
}

void AsyncThread::run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher) {
	run(*_defaultGroup, nullptr, worker, finisher);
}

void AsyncThread::run(const std::function<void()>& worker) {
	run(*_defaultGroup, nullptr, worker);
}

Async* AsyncThread::newThread() {
	std::lock_guard<std::mutex> guard(_submitMutex);
	if (_stopping.load(std::memory_order_acquire)) {
		throw std::runtime_error("cannot create an Async worker after AsyncThread has stopped");
	}
	_dedicatedThreads.push_back(New<Async>());
	return _dedicatedThreads.back().get();
}

AsyncThread::TaskGroup AsyncThread::createTaskGroup() {
	return TaskGroup(this, std::make_shared<AsyncTaskGroupState>());
}

void AsyncThread::runFrameTasks(const std::vector<std::function<void()>>& tasks) {
	runFrameTasks(tasks.size(), [&tasks](size_t index) { tasks[index](); });
}

void AsyncThread::runFrameTasks(size_t taskCount, const std::function<void(size_t)>& task,
	FrameTaskDispatchStats* stats) {
	if (currentAsyncWorker && currentAsyncWorker->_pool == this) {
		throw std::runtime_error("AsyncThread::runFrameTasks cannot be called from a worker in the same pool");
	}
	if (runningFrameTaskOnCaller) {
		throw std::runtime_error("AsyncThread::runFrameTasks cannot be called recursively from a caller task");
	}
	std::lock_guard<std::mutex> lock(_frameTaskMutex);
	if (stats) *stats = FrameTaskDispatchStats{taskCount};
	if (taskCount == 0) return;
	using Clock = std::chrono::steady_clock;
	const auto totalStarted = stats ? Clock::now() : Clock::time_point{};

	bool submitted = false;
	auto queuedTaskCount = size_t{0};
	auto callerFallbackBegin = taskCount;
	const auto submitStarted = stats ? Clock::now() : Clock::time_point{};
	{
		std::lock_guard<std::mutex> submitLock(_submitMutex);
		if (!_stopping.load(std::memory_order_acquire)) {
			_frameTaskState->reset(taskCount, task);
			for (auto index = size_t{1}; index < taskCount; ++index) {
				if (!_frameTasks.enqueue(FrameTaskItem{_frameTaskState.get(), index})) {
					callerFallbackBegin = index;
					break;
				}
				++queuedTaskCount;
			}
			submitted = true;
		}
	}
	if (stats) {
		stats->submitMilliseconds = std::chrono::duration<double, std::milli>(
			Clock::now() - submitStarted).count();
	}

	// A stopped pool preserves the old rejection fallback: execute the entire batch on the caller.
	if (!submitted) {
		std::exception_ptr exception;
		runningFrameTaskOnCaller = true;
		const auto callerStarted = stats ? Clock::now() : Clock::time_point{};
		for (auto index = size_t{0}; index < taskCount; ++index) {
			try {
				task(index);
			} catch (...) {
				if (!exception) {
					exception = std::current_exception();
				} else {
					reportAsyncException(std::current_exception(), "FrameTask additional caller task");
				}
			}
		}
		runningFrameTaskOnCaller = false;
		if (stats) {
			stats->callerMilliseconds = std::chrono::duration<double, std::milli>(
				Clock::now() - callerStarted).count();
			stats->totalMilliseconds = std::chrono::duration<double, std::milli>(
				Clock::now() - totalStarted).count();
		}
		if (exception) std::rethrow_exception(exception);
		return;
	}

	// The pool has one fewer worker than the hardware concurrency, so index zero uses the
	// reserved caller lane. The central lightweight queue lets any available worker claim the rest.
	notifyTasksPosted(queuedTaskCount);
	runningFrameTaskOnCaller = true;
	const auto callerStarted = stats ? Clock::now() : Clock::time_point{};
	_frameTaskState->execute(0);
	for (auto index = callerFallbackBegin; index < taskCount; ++index) {
		_frameTaskState->execute(index);
	}
	// Workers cannot preempt ordinary work that is already running. Claim any tasks that
	// remain in the FrameTask queue so a saturated pool degrades to caller-side execution
	// instead of making the frame wait for unrelated long-running work to finish.
	FrameTaskItem queuedFrameTask;
	while (_frameTasks.try_dequeue(queuedFrameTask)) {
		AssertUnless(queuedFrameTask.state == _frameTaskState.get(),
			"encountered a FrameTask from another batch while the current batch is active");
		queuedFrameTask.state->execute(queuedFrameTask.index);
	}
	runningFrameTaskOnCaller = false;
	if (stats) {
		stats->callerMilliseconds = std::chrono::duration<double, std::milli>(
			Clock::now() - callerStarted).count();
	}

	std::exception_ptr exception;
	const auto waitStarted = stats ? Clock::now() : Clock::time_point{};
	try {
		_frameTaskState->wait();
	} catch (...) {
		exception = std::current_exception();
	}
	if (stats) {
		stats->waitMilliseconds = std::chrono::duration<double, std::milli>(
			Clock::now() - waitStarted).count();
		stats->totalMilliseconds = std::chrono::duration<double, std::milli>(
			Clock::now() - totalStarted).count();
	}
	if (exception) std::rethrow_exception(exception);
}

size_t AsyncThread::getWorkerCount() const {
	return processCount();
}

AsyncThread::TaskGroup& AsyncThread::getDefaultGroup() {
	return *_defaultGroup;
}

void AsyncThread::cancel() {
	bool calledFromOwnedWorker = false;
	bool firstStopRequest = false;
	{
		std::lock_guard<std::mutex> guard(_submitMutex);
		firstStopRequest = !_stopping.exchange(true, std::memory_order_acq_rel);
		if (currentAsyncWorker) {
			calledFromOwnedWorker = currentAsyncWorker->_pool == this
				|| std::any_of(_dedicatedThreads.begin(), _dedicatedThreads.end(), [](const Own<Async>& thread) {
					return thread.get() == currentAsyncWorker;
				});
		}
	}
	FrameTaskItem frameTask;
	while (_frameTasks.try_dequeue(frameTask)) {
		frameTask.state->cancel();
	}
	if (firstStopRequest) notifyAllWorkers();
	for (const auto& thread : _process) {
		thread->requestStop();
	}
	for (const auto& thread : _dedicatedThreads) {
		thread->requestStop();
	}
	for (const auto& thread : _process) {
		thread->cancel();
	}
	for (const auto& thread : _dedicatedThreads) {
		thread->cancel();
	}
	if (calledFromOwnedWorker) return;
	for (const auto& thread : _process) {
		thread->stop();
	}
	for (const auto& thread : _dedicatedThreads) {
		thread->stop();
	}
}

bool AsyncThread::run(TaskGroup& group, Async* target, const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher) {
	std::lock_guard<std::mutex> guard(_submitMutex);
	if (_stopping.load(std::memory_order_acquire)) {
		return false;
	}
	if (!target) {
		size_t idx = _nextProcess.fetch_add(1, std::memory_order_relaxed) % _process.size();
		target = _process[idx].get();
	}
	group._state->add();
	try {
		if (!target->run(worker, finisher, group._state)) {
			group._state->complete();
			return false;
		}
	} catch (...) {
		group._state->complete();
		throw;
	}
	return true;
}

bool AsyncThread::run(TaskGroup& group, Async* target, const std::function<void()>& worker) {
	std::lock_guard<std::mutex> guard(_submitMutex);
	if (_stopping.load(std::memory_order_acquire)) {
		return false;
	}
	if (!target) {
		size_t idx = _nextProcess.fetch_add(1, std::memory_order_relaxed) % _process.size();
		target = _process[idx].get();
	}
	group._state->add();
	try {
		if (!target->run(worker, group._state)) {
			group._state->complete();
			return false;
		}
	} catch (...) {
		group._state->complete();
		throw;
	}
	return true;
}

bool AsyncThread::popFrameTask(FrameTaskItem& item) {
	return _frameTasks.try_dequeue(item);
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

void AsyncThread::notifyTasksPosted(size_t count) {
	for (auto i = size_t{0}; i < std::min(count, processCount()); ++i) {
		_workSemaphore.post();
	}
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
