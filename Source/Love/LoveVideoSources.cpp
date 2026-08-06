/*
 * Backend-independent Love 11.5 video implementation used by Dora's Love
 * runtime. The Ogg demuxer, Theora stream state machine, seeking, frame
 * synchronization, and double buffering remain upstream Love code.
 */

#include "3rdParty/Love/src/common/Data.cpp"
#include "3rdParty/Love/src/common/Stream.cpp"
#include "3rdParty/Love/src/modules/filesystem/FileData.cpp"
#include "3rdParty/Love/src/modules/filesystem/File.cpp"
#include "3rdParty/Love/src/modules/thread/threads.cpp"
#include "3rdParty/Love/src/modules/video/VideoStream.cpp"
#include "3rdParty/Love/src/modules/video/theora/OggDemuxer.cpp"
#include "3rdParty/Love/src/modules/video/theora/TheoraVideoStream.cpp"

#include <condition_variable>
#include <mutex>
#include <thread>

namespace love::thread
{

namespace
{

class StdMutex final : public Mutex
{
public:
	void lock() override { mutex.lock(); }
	void unlock() override { mutex.unlock(); }
	std::mutex mutex;
};

class StdConditional final : public Conditional
{
public:
	void signal() override { condition.notify_one(); }
	void broadcast() override { condition.notify_all(); }
	bool wait(Mutex *mutex, int timeout) override
	{
		auto *stdMutex = dynamic_cast<StdMutex *>(mutex);
		if (!stdMutex) return false;
		std::unique_lock lock(stdMutex->mutex, std::adopt_lock);
		bool result = true;
		if (timeout < 0) condition.wait(lock);
		else result = condition.wait_for(lock, std::chrono::milliseconds(timeout))
			!= std::cv_status::timeout;
		lock.release();
		return result;
	}
	std::condition_variable condition;
};

class StdThread final : public Thread
{
public:
	explicit StdThread(Threadable *owner)
		: owner(owner) { }
	~StdThread() override { wait(); }
	bool start() override
	{
		if (running.exchange(true)) return false;
		worker = std::thread([this]() {
			owner->threadFunction();
			running.store(false);
		});
		return true;
	}
	void wait() override
	{
		if (worker.joinable()) worker.join();
	}
	bool isRunning() override { return running.load(); }
	Threadable *owner;
	std::thread worker;
	std::atomic<bool> running = false;
};

} // namespace

Mutex *newMutex() { return new StdMutex(); }
Conditional *newConditional() { return new StdConditional(); }
Thread *newThread(Threadable *owner) { return new StdThread(owner); }

} // namespace love::thread
