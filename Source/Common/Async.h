/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <atomic>
#include <memory>
#include <mutex>

#include "Event/EventQueue.h"
#include "Support/Value.h"

#include "bx/thread.h"

NS_DORA_BEGIN

class AsyncThread;
class AsyncTaskGroupState;
class AsyncFinisherState;
class AsyncFrameTaskState;

struct FrameTaskDispatchStats {
	size_t taskCount = 0;
	double submitMilliseconds = 0.0;
	double callerMilliseconds = 0.0;
	double waitMilliseconds = 0.0;
	double totalMilliseconds = 0.0;
};

/** @brief A reusable group of tasks submitted to an AsyncThread pool.
 Tasks in one group can be waited on without waiting for unrelated pool work.
 Submit all tasks before calling wait, and call wait outside the pool's worker threads.
 Destroying a group does not wait for its tasks. Do not submit through a group after its
 AsyncThread pool has been destroyed. */
class AsyncTaskGroup : public NonCopyable {
public:
	AsyncTaskGroup(AsyncTaskGroup&& other) noexcept;
	AsyncTaskGroup& operator=(AsyncTaskGroup&& other) noexcept;
	~AsyncTaskGroup();
	bool run(const std::function<void()>& worker);
	void wait();
	size_t getPendingCount() const;

private:
	AsyncTaskGroup(AsyncThread* pool, std::shared_ptr<AsyncTaskGroupState> state);
	AsyncThread* _pool;
	std::shared_ptr<AsyncTaskGroupState> _state;
	friend class Async;
	friend class AsyncThread;
};

/** @brief get a worker runs in another thread and returns a result,
 get a finisher receives the result and runs in main thread. */
class Async : public NonCopyable {
	using WorkDone = std::pair<std::function<Own<Values>()>, std::function<void(Own<Values>)>>;
	using Work = std::function<void()>;
	using WorkPtr = Own<Work>;
	using WorkDonePtr = Own<WorkDone>;
	friend class AsyncThread;
	friend class AsyncTaskGroup;

public:
	Async();
	virtual ~Async();
	/** @brief Submits worker work and a logic-thread finisher.
	 This method must be called from the logic thread. Worker and finisher exceptions
	 are reported through Dora's threaded error logger. */
	void run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher);
	void run(const std::function<void()>& worker);
	/** @brief Runs work on this Async worker and blocks the logic thread until completion.
	 Worker exceptions are rethrown on the calling logic thread. */
	void runInMainSync(const std::function<void()>& worker);
	void cancel();
	/** @brief Requests this worker to stop and joins it from an external thread.
	 Individual workers owned by an AsyncThread pool must be stopped through AsyncThread::cancel(). */
	void stop();
	static int work(bx::Thread* thread, void* userData);

private:
	bool run(const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher, const std::shared_ptr<AsyncTaskGroupState>& group);
	bool run(const std::function<void()>& worker, const std::shared_ptr<AsyncTaskGroupState>& group);
	void bindPool(AsyncThread* pool, size_t index);
	void requestStop();
	Own<QEvent> pollWorkerEvent();
	void notifyWorker();
	bool processWorkerEvent(Own<QEvent> event, Async* owner);
	void initThreadOnce();
	bool isPoolWorker() const;
	bool _scheduled;
	bx::Thread _thread;
	bx::Semaphore _workerSemaphore;
	std::once_flag _initThreadFlag;
	EventQueue _workerEvent;
	std::shared_ptr<AsyncFinisherState> _finisherState;
	// Tracks standalone-thread tasks so uncaught exceptions can be reported safely.
	// It is not the AsyncThread pool's default group and does not affect scheduling.
	std::shared_ptr<AsyncTaskGroupState> _standaloneTaskState;
	std::mutex _submitMutex;
	std::mutex _stopMutex;
	std::atomic_bool _stopped;
	AsyncThread* _pool;
	size_t _poolIndex;
};

class AsyncThread : public NonCopyable {
	friend class Async;
	friend class AsyncTaskGroup;
public:
	using TaskGroup = AsyncTaskGroup;
	AsyncThread();
	~AsyncThread();
	/** @throws std::out_of_range if index is not a valid pool worker index. */
	Async& getProcess(int index);
	/** @brief Creates a dedicated serial Async worker retained for this AsyncThread's lifetime.
	 The worker owns a separate queue and OS thread, and never participates in the pool's
	 task distribution or work stealing. */
	Async* newThread();
	TaskGroup createTaskGroup();
	/** @brief Runs one frame-stage batch on the shared task pool and waits for completion.
	 The same internal batch state is reused across frames and subsystems, so calls are serialized.
	 The first task runs on the calling thread while later tasks are made available to the pool.
	 After its first task, the caller also executes tasks that workers have not claimed, preventing
	 unrelated long-running pool work from blocking the frame. Rejected tasks also run on the
	 calling thread. Worker and caller task exceptions are rethrown to the caller after all accepted
	 tasks finish.
	 This method must not be called from one of this pool's workers or recursively from its caller
	 task. */
	void runFrameTasks(const std::vector<std::function<void()>>& tasks);
	/** @brief Runs an indexed frame-stage batch without constructing one function per task.
	 @param stats Optional timing diagnostics. Passing null keeps timing calls out of the hot path. */
	void runFrameTasks(size_t taskCount, const std::function<void(size_t)>& task,
		FrameTaskDispatchStats* stats = nullptr);
	/** @brief Gets the fixed number of task-pool workers. */
	size_t getWorkerCount() const;
	/** @brief Gets the group used by the existing AsyncThread::run and pooled Async::run APIs.
	 Worker exceptions are reported immediately instead of being retained for wait().
	 Waiting on this group waits for their worker phase, but not for main-thread finishers. */
	TaskGroup& getDefaultGroup();
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
	struct FrameTaskItem {
		AsyncFrameTaskState* state;
		size_t index;
	};
	bool run(TaskGroup& group, Async* target, const std::function<Own<Values>()>& worker, const std::function<void(Own<Values>)>& finisher);
	bool run(TaskGroup& group, Async* target, const std::function<void()>& worker);
	bool popFrameTask(FrameTaskItem& item);
	bool popTask(size_t workerIndex, Async*& source, Own<QEvent>& event);
	void notifyTaskPosted();
	void notifyTasksPosted(size_t count);
	bool isStopping() const;
	void waitForTask();
	size_t processCount() const;
	void notifyAllWorkers();
	std::atomic<size_t> _nextProcess;
	std::atomic<size_t> _nextStealFrom;
	std::atomic_bool _stopping;
	bx::Semaphore _workSemaphore;
	std::mutex _submitMutex;
	OwnVector<Async> _process;
	OwnVector<Async> _dedicatedThreads;
	Own<TaskGroup> _defaultGroup;
	std::mutex _frameTaskMutex;
	Own<AsyncFrameTaskState> _frameTaskState;
	moodycamel::ConcurrentQueue<FrameTaskItem> _frameTasks;
	SINGLETON_REF(AsyncThread, Director);
};

#define SharedAsyncThread \
	Dora::Singleton<Dora::AsyncThread>::shared()

NS_DORA_END
