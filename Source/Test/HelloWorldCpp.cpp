/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Dora.h"
#include "Animation/Animation.h"
using namespace Dora;

#include "imgui/imgui.h"
#include "playrho/d2/DistanceJointConf.hpp"
#include <algorithm>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <mutex>
#include <random>
#include <stdexcept>
#include <thread>

DORA_TEST_ENTRY(HelloWorldCpp) {
	auto node = Node::create();
	node->slot("Enter"sv, [](Event*) {
		Println("on enter event"sv);
	});
	node->slot("Exit"sv, [](Event*) {
		Println("on exit event"sv);
	});
	node->slot("Cleanup"sv, [](Event*) {
		Println("on node destoyed event"sv);
	});
	node->schedule(once([]() -> Job {
		for (int i = 5; i > 0; i--) {
			Println("{}", i);
			co_sleep(1);
		}
		Println("Hello World!"sv);
	}));

	//	auto time = std::make_shared<double>(0);
	//	auto countDown = std::make_shared<int>(5);
	//	node->schedule([time, countDown](double deltaTime) {
	//		*time += deltaTime;
	//		if (*time >= 1.0) {
	//			*time = 0;
	//			if (*countDown > 0) {
	//				println("{}", *countDown);
	//			}
	//			--*countDown;
	//		}
	//		if (*countDown < 0) {
	//			println("Hello World!");
	//			return true;
	//		}
	//		return false;
	//	});

	auto ui = Node::create();
	ui->schedule([](double) {
		auto size = SharedApplication.getVisualSize();
		ImGui::SetNextWindowBgAlpha(0.35f);
		ImGui::SetNextWindowPos(Vec2{size.width - 10.0f, 10.0f}, ImGuiCond_Always, Vec2{1.0f, 0});
		ImGui::SetNextWindowSize(Vec2{240.0f, 0}, ImGuiCond_FirstUseEver);
		if (ImGui::Begin("Hello World", nullptr,
				ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav | ImGuiWindowFlags_NoMove)) {
			ImGui::Text("Hello World");
			ImGui::Separator();
			ImGui::TextWrapped("Basic Dora schedule and signal function usage. Written in C++. View outputs in log window!");
		}
		ImGui::End();
		return false;
	});
	return true;
}

DORA_TEST_ENTRY(PhysicsSensorLifecycleCpp) {
	auto check = [](bool condition, const char* message) {
		if (!condition) throw std::runtime_error(message);
	};
	// No external model/game assets are needed, including for the real Jump action.
	const auto modelName = "__sensor_lifecycle_test.model"sv;
	SharedModelCache.update(modelName, ModelDef::create());
	DEFER(SharedModelCache.unload(modelName));
	auto step = [](PhysicsWorld* world) {
		// A zero-dt step creates broad-phase contacts; the next updates their manifolds.
		world->doUpdate(0);
		world->doUpdate(0);
	};

	auto makeTarget = [](PhysicsWorld* world, Vec2 position, bool compound = false) {
		auto def = BodyDef::create();
		def->setType(pr::BodyType::Dynamic);
		def->attachDisk(5, 1, 0, 0);
		if (compound) def->attachDisk(4, 1, 0, 0);
		auto body = Body::create(def, world, position);
		world->addChild(body);
		pd::SetEnabled(*world->getPrWorld(), body->getPrBody(), true);
		return body;
	};

	{
		Ref<PhysicsWorld> world(PhysicsWorld::create());
		DEFER(world->cleanup());
		auto def = BodyDef::create();
		def->attachDiskSensor(0, 100);
		auto owner = Body::create(def, world.get());
		world->addChild(owner);
		pd::SetEnabled(*world->getPrWorld(), owner->getPrBody(), true);
		Ref<Sensor> sensor(owner->getSensorByTag(0));
		int enters = 0, leaves = 0;
		sensor->bodyEnter += [&](Body*, int) { ++enters; };
		sensor->bodyLeave += [&](Body*, int) { ++leaves; };
		Ref<Body> target(makeTarget(world.get(), Vec2::zero));
		step(world.get());
		check(enters == 1 && sensor->contains(target), "sensor did not enter normally");
		target->setPosition(Vec2{1000, 0});
		step(world.get());
		check(leaves == 1 && !sensor->isSensed(), "normal leave semantics changed");
		target->setPosition(Vec2::zero);
		step(world.get());
		check(enters == 2, "sensor did not re-enter normally");
		target->removeFromParent(true);
		check(!pr::IsValid(target->getPrBody()), "test target was not cleaned up");
		step(world.get());
		check(!sensor->isSensed() && !sensor->contains(target), "destroyed body retained in sensor");
		check(leaves == 1, "cleanup must not deliver a leave to an invalid body");

		Ref<Body> compound(makeTarget(world.get(), Vec2::zero, true));
		step(world.get());
		check(sensor->getSensedBodies()->getCount() == 2, "compound contact fixture setup failed");
		compound->removeFromParent(true);
		step(world.get());
		check(sensor->getSensedBodies()->isEmpty(), "compound body left a sensor membership behind");
		check(leaves == 1, "compound cleanup emitted a user leave");

		// Destroying bodies from a leave callback grows the queue being dispatched.
		RefVector<Body> targets;
		for (int i = 0; i < 64; ++i) targets.push_back(makeTarget(world.get(), Vec2{float(i), 0}));
		step(world.get());
		sensor->bodyLeave = [&](Body*, int) {
			++leaves;
			for (auto body : targets) body->removeFromParent(true);
		};
		targets.front()->setPosition(Vec2{1000, 0});
		step(world.get());
		check(leaves == 2 && !sensor->isSensed(), "reentrant leave cleanup did not drain safely");
		sensor->bodyEnter.Clear();
		sensor->bodyLeave.Clear();

		// A body can be cleaned before its queued enter is delivered. Neither the
		// stale enter nor its matching leave may deliver a user event afterwards.
		WRef<Body> expired;
		SharedPoolManager.push();
		{
			DEFER(SharedPoolManager.pop());
			auto temporaryDef = BodyDef::create();
			temporaryDef->setType(pr::BodyType::Dynamic);
			temporaryDef->attachDisk(5, 1, 0, 0);
			auto temporary = Body::create(temporaryDef, world.get());
			expired = temporary;
			pd::SetEnabled(*world->getPrWorld(), temporary->getPrBody(), true);
			pd::Step(*world->getPrWorld(), pr::StepConf{});
			temporary->cleanup();
		}
		check(!expired, "pending-enter body was not cleaned up");
		step(world.get());
		check(!sensor->isSensed(), "a destroyed pending enter reached the sensor");
	}

	{
		using namespace Dora::Platformer;
		Ref<PhysicsWorld> world(PhysicsWorld::create());
		DEFER(world->cleanup());
		auto def = Dictionary::create();
		def->set(Unit::Def::Size, Value::alloc(Size{20, 20}));
		def->set(Unit::Def::BodyType, Value::alloc("Dynamic"s));
		def->set(Unit::Def::Density, Value::alloc(1.0));
		def->set(Unit::Def::Playable, Value::alloc("model:__sensor_lifecycle_test.model"s));
		auto actions = Array::create();
		actions->add(Value::alloc("jump"s));
		def->set(Unit::Def::Actions, Value::alloc(actions));
		Ref<Entity> entity(Entity::create());
		entity->set("jump"sv, 100.0);
		Ref<Unit> unit(Unit::create(def, world.get(), entity.get(), Vec2{0, 10}, 0.0f));
		check(unit != nullptr, "failed to create asset-free test unit");
		world->addChild(unit);
		pd::SetEnabled(*world->getPrWorld(), unit->getPrBody(), true);
		Ref<Body> support(makeTarget(world.get(), Vec2{0, -4}));
		step(world.get());
		check(unit->isOnSurface(), "test unit has no initial support");
		support->removeFromParent(true);
		// In particular, test before the next physics/event flush.
		check(!unit->isOnSurface(), "destroyed support still counted as ground before leave dispatch");
		check(!unit->start("jump"sv), "jump accepted destroyed support");
		step(world.get());
		check(!unit->getGroundSensor()->isSensed(), "ground membership was not cleared");

		Ref<Body> first(makeTarget(world.get(), Vec2{-4, -4}));
		Ref<Body> second(makeTarget(world.get(), Vec2{4, -4}));
		step(world.get());
		auto ground = unit->getGroundSensor()->getSensedBodies();
		check(ground->getCount() >= 2, "multiple-support fixture setup failed");
		ground->get(0)->to<Body>()->removeFromParent(true);
		check(unit->isOnSurface(), "live secondary support was ignored");
		check(unit->start("jump"sv), "jump did not fall back to live secondary support");
		check(unit->getVelocityY() == 100.0f, "valid jump velocity changed");
		step(world.get());
	}
	Println("[PhysicsSensorLifecycleCpp] normal/compound/reentrant leaves and invalid-support jump: PASS");
	return true;
}

DORA_TEST_ENTRY(WaGitCloneCpp) {
	struct State {
		bool started = false;
		bool finished = false;
		bool logged = false;
		int64_t jobId = 0;
		double elapsed = 0.0;
		std::string parentPath;
		std::string repoPath;
		std::string status = "pending";
	};

	auto state = std::make_shared<State>();
	state->parentPath = Path::concat({SharedContent.getAppPath(), ".git-clone-test-parent"sv});
	state->repoPath = Path::concat({state->parentPath, "dora-wa-git-test"sv});
	SharedContent.remove(state->parentPath);
	SharedContent.remove(state->repoPath);

	auto ui = Node::create();
	ui->schedule([state](double deltaTime) {
		if (!state->started) {
			state->started = true;
			state->jobId = Git::run(
				state->parentPath,
				"git clone git://127.0.0.1:9418/dora-wa-git-test.git dora-wa-git-test"_slice,
				[state](String status) {
					state->status = status.toString();
					if (state->status.find("\"state\":\"done\"") != std::string::npos
						|| state->status.find("\"state\":\"error\"") != std::string::npos
						|| state->status.find("\"state\":\"canceled\"") != std::string::npos) {
						state->finished = true;
					}
				});
			Println("[WaGitCloneCpp] started job {} at {}", state->jobId, state->repoPath);
		}

		if (!state->finished && state->jobId != 0) {
			state->elapsed += deltaTime;
			if (state->elapsed > 60.0) {
				state->finished = true;
				Git::cancel(state->jobId);
			}
		}

		if (state->finished && !state->logged) {
			state->logged = true;
			bool pass = state->status.find("\"state\":\"done\"") != std::string::npos;
			Println("[WaGitCloneCpp] result: {}", pass ? "PASS" : "CHECK");
			Println("[WaGitCloneCpp] status: {}", state->status);
		}

		auto size = SharedApplication.getVisualSize();
		ImGui::SetNextWindowBgAlpha(0.35f);
		ImGui::SetNextWindowPos(Vec2{size.width - 10.0f, 10.0f}, ImGuiCond_Always, Vec2{1.0f, 0});
		ImGui::SetNextWindowSize(Vec2{440.0f, 0}, ImGuiCond_FirstUseEver);
		if (ImGui::Begin("Wa Git Clone", nullptr,
				ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav | ImGuiWindowFlags_NoMove)) {
			ImGui::TextWrapped("Job: %lld", static_cast<long long>(state->jobId));
			ImGui::TextWrapped("Path: %s", state->repoPath.c_str());
			ImGui::TextWrapped("Status: %s", state->status.c_str());
		}
		ImGui::End();
		return state->finished;
	});
	return true;
}

DORA_TEST_ENTRY(AsyncThreadStealingCpp) {
	struct State {
		bool started = false;
		bool finished = false;
		bool logged = false;
		uint32_t poolSize = std::max(std::thread::hardware_concurrency(), 4u) - 1;
		int longTaskCount = 24;
		int shortTaskCount = 12;
		int longTaskMs = 200;
		std::atomic<int> longDone{0};
		std::atomic<int> shortDone{0};
		std::chrono::steady_clock::time_point startTime;
		double elapsedMs = 0.0;
	};

	auto state = std::make_shared<State>();
	auto ui = Node::create();
	ui->schedule([state](double) {
		if (!state->started) {
			state->started = true;
			state->startTime = std::chrono::steady_clock::now();
			for (int i = 0; i < state->longTaskCount; i++) {
				SharedAsyncThread.getProcess(0).run([state]() {
					std::this_thread::sleep_for(std::chrono::milliseconds(state->longTaskMs));
					state->longDone.fetch_add(1, std::memory_order_relaxed);
				});
			}
			for (int i = 0; i < state->shortTaskCount; i++) {
				auto workerIndex = (i % (state->poolSize - 1)) + 1;
				SharedAsyncThread.getProcess(s_cast<int>(workerIndex)).run([state]() {
					state->shortDone.fetch_add(1, std::memory_order_relaxed);
				});
			}
		}

		int longDone = state->longDone.load(std::memory_order_relaxed);
		int shortDone = state->shortDone.load(std::memory_order_relaxed);
		int doneCount = longDone + shortDone;
		int totalCount = state->longTaskCount + state->shortTaskCount;
		if (!state->finished && doneCount == totalCount) {
			state->finished = true;
			auto now = std::chrono::steady_clock::now();
			state->elapsedMs = std::chrono::duration<double, std::milli>(now - state->startTime).count();
		}
		double serialMs = state->longTaskCount * state->longTaskMs;
		bool pass = state->finished && state->elapsedMs < serialMs * 0.85;
		if (state->finished && !state->logged) {
			state->logged = true;
			Println("[AsyncThreadStealingCpp] total done {}/{}", doneCount, totalCount);
			Println("[AsyncThreadStealingCpp] elapsed {:.2f} ms, serial baseline {:.2f} ms", state->elapsedMs, serialMs);
			Println("[AsyncThreadStealingCpp] result: {}", pass ? "PASS" : "CHECK");
		}

		auto size = SharedApplication.getVisualSize();
		ImGui::SetNextWindowBgAlpha(0.35f);
		ImGui::SetNextWindowPos(Vec2{size.width - 10.0f, 10.0f}, ImGuiCond_Always, Vec2{1.0f, 0});
		ImGui::SetNextWindowSize(Vec2{420.0f, 0}, ImGuiCond_FirstUseEver);
		if (ImGui::Begin("AsyncThread Stealing", nullptr,
				ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav | ImGuiWindowFlags_NoMove)) {
			ImGui::Text("Pool workers: %u", state->poolSize);
			ImGui::Text("Long tasks (queued to worker#0): %d x %dms", state->longTaskCount, state->longTaskMs);
			ImGui::Text("Short tasks (queued to other workers): %d", state->shortTaskCount);
			ImGui::Separator();
			ImGui::Text("Progress: long %d/%d, short %d/%d",
				longDone, state->longTaskCount, shortDone, state->shortTaskCount);
			if (state->finished) {
				ImGui::Text("Elapsed: %.2f ms", state->elapsedMs);
				ImGui::Text("Serial baseline: %.2f ms", serialMs);
				ImGui::Text("Stealing check (< 85%% baseline): %s", pass ? "PASS" : "CHECK");
			} else {
				ImGui::Text("Running...");
			}
			ImGui::Separator();
			ImGui::TextWrapped("This test enqueues long tasks only to worker #0. If worker stealing works, other idle workers should help and reduce total elapsed time.");
		}
		ImGui::End();
		return false;
	});
	return true;
}

DORA_TEST_ENTRY(FrameTaskCallerHelpCpp) {
	AsyncThread pool;
	const auto callerThread = std::this_thread::get_id();
	const auto workerCount = pool.getWorkerCount();
	std::mutex gateMutex;
	std::condition_variable gateCondition;
	bool releaseWorkers = false;
	bool frameReturned = false;
	bool watchdogTimedOut = false;
	std::atomic<size_t> startedWorkers{0};
	for (auto index = size_t{0}; index < workerCount; ++index) {
		pool.getProcess(s_cast<int>(index)).run([&]() {
			startedWorkers.fetch_add(1, std::memory_order_release);
			gateCondition.notify_all();
			std::unique_lock<std::mutex> lock(gateMutex);
			gateCondition.wait(lock, [&]() { return releaseWorkers; });
		});
	}
	{
		std::unique_lock<std::mutex> lock(gateMutex);
		AssertUnless(gateCondition.wait_for(lock, std::chrono::seconds(2), [&]() {
			return startedWorkers.load(std::memory_order_acquire) == workerCount;
		}), "failed to occupy every AsyncThread worker for FrameTask caller-help test");
	}

	std::thread watchdog([&]() {
		{
			std::unique_lock<std::mutex> lock(gateMutex);
			if (!gateCondition.wait_for(lock, std::chrono::seconds(2), [&]() {
				return frameReturned;
			})) {
				watchdogTimedOut = true;
			}
			releaseWorkers = true;
		}
		gateCondition.notify_all();
	});

	std::atomic<size_t> helpedTasks{0};
	auto helpedExceptionCaught = false;
	try {
		pool.runFrameTasks(workerCount + 1, [&](size_t index) {
			AssertUnless(std::this_thread::get_id() == callerThread,
				"a saturated worker unexpectedly claimed a FrameTask");
			helpedTasks.fetch_add(1, std::memory_order_relaxed);
			if (index == 1) {
				throw std::runtime_error("FrameTask caller-help expected exception");
			}
		});
	} catch (const std::runtime_error&) {
		helpedExceptionCaught = true;
	}
	{
		std::lock_guard<std::mutex> guard(gateMutex);
		frameReturned = true;
	}
	gateCondition.notify_all();
	watchdog.join();
	AssertUnless(!watchdogTimedOut,
		"FrameTask caller help waited for unrelated long-running worker tasks");
	AssertUnless(helpedTasks.load(std::memory_order_relaxed) == workerCount + 1,
		"FrameTask caller help did not execute every unclaimed task");
	AssertUnless(helpedExceptionCaught,
		"FrameTask caller help did not rethrow a task exception");
	Println("[FrameTaskCallerHelpCpp] saturated-pool progress and exception aggregation: PASS");
	return true;
}

DORA_TEST_ENTRY(AsyncTaskGroupCpp) {
	AsyncThread pool;
	auto group = pool.createTaskGroup();
	std::atomic<int> completed{0};
	for (int i = 0; i < 128; i++) {
		AssertUnless(group.run([&completed]() {
			completed.fetch_add(1, std::memory_order_relaxed);
		}), "failed to submit AsyncTaskGroup task");
	}
	group.wait();
	AssertUnless(completed.load(std::memory_order_relaxed) == 128, "AsyncTaskGroup wait returned before all tasks completed");
	AssertUnless(group.getPendingCount() == 0, "AsyncTaskGroup pending task count should be zero after wait");

	AssertUnless(group.run([]() {
		throw std::runtime_error("AsyncTaskGroup expected exception");
	}), "failed to submit AsyncTaskGroup exception task");
	auto caught = false;
	try {
		group.wait();
	} catch (const std::runtime_error&) {
		caught = true;
	}
	AssertUnless(caught, "AsyncTaskGroup wait should rethrow a worker exception");

	AssertUnless(group.run([&completed]() {
		completed.fetch_add(1, std::memory_order_relaxed);
	}), "failed to reuse AsyncTaskGroup");
	group.wait();
	AssertUnless(completed.load(std::memory_order_relaxed) == 129, "reused AsyncTaskGroup did not finish");

	std::vector<std::function<void()>> frameTasks;
	for (int i = 0; i < 32; ++i) {
		frameTasks.emplace_back([&completed]() {
			completed.fetch_add(1, std::memory_order_relaxed);
		});
	}
	pool.runFrameTasks(frameTasks);
	pool.runFrameTasks(frameTasks);
	AssertUnless(completed.load(std::memory_order_relaxed) == 193,
		"persistent FrameTaskGroup did not complete two batches");
	FrameTaskDispatchStats indexedStats;
	std::atomic<size_t> indexedTotal{0};
	pool.runFrameTasks(64, [&indexedTotal](size_t index) {
		indexedTotal.fetch_add(index + 1, std::memory_order_relaxed);
	}, &indexedStats);
	AssertUnless(indexedTotal.load(std::memory_order_relaxed) == 2080,
		"indexed FrameTask batch did not execute every index exactly once");
	AssertUnless(indexedStats.taskCount == 64 && indexedStats.totalMilliseconds >= 0.0,
		"indexed FrameTask diagnostics did not describe the completed batch");

	const auto frameCallerThread = std::this_thread::get_id();
	std::atomic<bool> framePoolTaskRanOffCaller{false};
	std::atomic<bool> frameCallerTaskRanOnCaller{false};
	pool.runFrameTasks({
		[&]() {
			frameCallerTaskRanOnCaller.store(
				std::this_thread::get_id() == frameCallerThread, std::memory_order_release);
			const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(2);
			while (!framePoolTaskRanOffCaller.load(std::memory_order_acquire)
				&& std::chrono::steady_clock::now() < deadline) {
				std::this_thread::yield();
			}
		},
		[&]() {
			framePoolTaskRanOffCaller.store(
				std::this_thread::get_id() != frameCallerThread, std::memory_order_release);
		},
	});
	AssertUnless(framePoolTaskRanOffCaller.load(std::memory_order_acquire),
		"FrameTaskGroup should run later tasks on the worker pool");
	AssertUnless(frameCallerTaskRanOnCaller.load(std::memory_order_acquire),
		"FrameTaskGroup should run its first task on the calling thread");

	std::atomic<bool> callerFrameTasksRejected{false};
	pool.runFrameTasks({[&]() {
		try {
			pool.runFrameTasks({[]() { }});
		} catch (const std::runtime_error&) {
			callerFrameTasksRejected.store(true, std::memory_order_release);
		}
	}});
	AssertUnless(callerFrameTasksRejected.load(std::memory_order_acquire),
		"FrameTaskGroup should reject recursive calls from its caller task");

	frameTasks = {[]() { throw std::runtime_error("FrameTaskGroup expected caller exception"); }};
	auto frameExceptionCaught = false;
	try {
		pool.runFrameTasks(frameTasks);
	} catch (const std::runtime_error&) {
		frameExceptionCaught = true;
	}
	AssertUnless(frameExceptionCaught, "FrameTaskGroup should rethrow a caller-task exception");

	std::atomic<bool> callerFinishedBeforeWorkerException{false};
	frameExceptionCaught = false;
	try {
		pool.runFrameTasks({
			[&]() { callerFinishedBeforeWorkerException.store(true, std::memory_order_release); },
			[]() { throw std::runtime_error("FrameTaskGroup expected worker exception"); },
		});
	} catch (const std::runtime_error&) {
		frameExceptionCaught = true;
	}
	AssertUnless(frameExceptionCaught, "FrameTaskGroup should rethrow a worker exception");
	AssertUnless(callerFinishedBeforeWorkerException.load(std::memory_order_acquire),
		"FrameTaskGroup should finish its caller task before rethrowing a worker exception");
	frameTasks = {[&completed]() { completed.fetch_add(1, std::memory_order_relaxed); }};
	pool.runFrameTasks(frameTasks);
	AssertUnless(completed.load(std::memory_order_relaxed) == 194,
		"FrameTaskGroup could not be reused after an exception");

	std::atomic<bool> workerFrameTasksRejected{false};
	pool.run([&]() {
		try {
			pool.runFrameTasks({[]() { }});
		} catch (const std::runtime_error&) {
			workerFrameTasksRejected.store(true, std::memory_order_release);
		}
	});
	pool.getDefaultGroup().wait();
	AssertUnless(workerFrameTasksRejected.load(std::memory_order_acquire),
		"FrameTaskGroup should reject calls from its own pool workers");

	pool.run([&completed]() {
		completed.fetch_add(1, std::memory_order_relaxed);
	});
	pool.getDefaultGroup().wait();
	AssertUnless(completed.load(std::memory_order_relaxed) == 195, "AsyncThread default TaskGroup did not finish");
	pool.run([]() {
		throw std::runtime_error("AsyncThread default TaskGroup expected logged exception");
	});
	pool.getDefaultGroup().wait();

	auto syncExceptionCaught = false;
	try {
		pool.getProcess(0).runInMainSync([]() {
			throw std::runtime_error("AsyncThread pool runInMainSync expected exception");
		});
	} catch (const std::runtime_error&) {
		syncExceptionCaught = true;
	}
	AssertUnless(syncExceptionCaught, "pool runInMainSync should rethrow on the calling thread");

	Async* dedicatedThread = pool.newThread();
	syncExceptionCaught = false;
	try {
		dedicatedThread->runInMainSync([]() {
			throw std::runtime_error("dedicated Async thread runInMainSync expected exception");
		});
	} catch (const std::runtime_error&) {
		syncExceptionCaught = true;
	}
	AssertUnless(syncExceptionCaught, "dedicated-thread runInMainSync should rethrow on the calling thread");

	std::mutex userDoneMutex;
	std::condition_variable userDoneCondition;
	bool userDone = false;
	dedicatedThread->run([]() {
		throw std::runtime_error("dedicated Async thread expected logged exception");
	});
	dedicatedThread->run([&]() {
		{
			std::lock_guard<std::mutex> guard(userDoneMutex);
			userDone = true;
		}
		userDoneCondition.notify_one();
	});
	{
		std::unique_lock<std::mutex> lock(userDoneMutex);
		AssertUnless(userDoneCondition.wait_for(lock, std::chrono::seconds(2), [&]() { return userDone; }),
			"dedicated Async worker should continue after a reported exception");
	}

	std::atomic<bool> offThreadFinisherRejected{false};
	std::thread offThreadSubmitter([&]() {
		try {
			dedicatedThread->run([]() -> Own<Values> { return {}; }, [](Own<Values>) { });
		} catch (const std::runtime_error&) {
			offThreadFinisherRejected.store(true, std::memory_order_release);
		}
	});
	offThreadSubmitter.join();
	AssertUnless(offThreadFinisherRejected.load(std::memory_order_acquire),
		"finisher submission outside the logic thread should be rejected in release builds too");

	auto outOfRangeCaught = false;
	try {
		pool.getProcess(-1);
	} catch (const std::out_of_range&) {
		outOfRangeCaught = true;
	}
	AssertUnless(outOfRangeCaught, "AsyncThread::getProcess should reject invalid indices");

	{
		AsyncThread selfCancelPool;
		std::atomic<bool> cancelReturned{false};
		selfCancelPool.run([&]() {
			selfCancelPool.cancel();
			cancelReturned.store(true, std::memory_order_release);
		});
		selfCancelPool.getDefaultGroup().wait();
		selfCancelPool.cancel();
		AssertUnless(cancelReturned.load(std::memory_order_acquire), "cancel called from a pool worker should return without self-join");
	}

	{
		AsyncThread syncCancelPool;
		auto pendingGroup = syncCancelPool.createTaskGroup();
		const auto workerCount = std::max(std::thread::hardware_concurrency(), 4u) - 1;
		std::mutex gateMutex;
		std::condition_variable gateCondition;
		bool releaseWorkers = false;
		std::atomic<uint32_t> startedWorkers{0};
		for (uint32_t i = 0; i < workerCount; i++) {
			syncCancelPool.getProcess(s_cast<int>(i)).run([&]() {
				startedWorkers.fetch_add(1, std::memory_order_release);
				gateCondition.notify_all();
				std::unique_lock<std::mutex> lock(gateMutex);
				gateCondition.wait(lock, [&]() { return releaseWorkers; });
			});
		}
		{
			std::unique_lock<std::mutex> lock(gateMutex);
			AssertUnless(gateCondition.wait_for(lock, std::chrono::seconds(2), [&]() {
				return startedWorkers.load(std::memory_order_acquire) == workerCount;
			}), "failed to occupy every AsyncThread worker for cancellation test");
		}
		for (int i = 0; i < 128; i++) {
			AssertUnless(pendingGroup.run([]() { }), "failed to submit pending cancellation task");
		}
		std::thread stopper([&]() {
			std::this_thread::sleep_for(std::chrono::milliseconds(20));
			syncCancelPool.cancel();
		});
		syncCancelPool.getProcess(0).runInMainSync([]() { });
		{
			std::lock_guard<std::mutex> guard(gateMutex);
			releaseWorkers = true;
		}
		gateCondition.notify_all();
		stopper.join();
		pendingGroup.wait();
		AssertUnless(pendingGroup.getPendingCount() == 0,
			"cancelled runInMainSync should settle tasks drained from its worker queue");
	}

	{
		AsyncThread cancelPool;
		auto cancelGroup = cancelPool.createTaskGroup();
		for (int i = 0; i < 256; i++) {
			AssertUnless(cancelGroup.run([]() {
				std::this_thread::sleep_for(std::chrono::milliseconds(1));
			}), "failed to submit AsyncTaskGroup cancellation task");
		}
		cancelPool.cancel();
		cancelGroup.wait();
		AssertUnless(cancelGroup.getPendingCount() == 0, "cancelled AsyncTaskGroup should have no pending tasks");
		AssertUnless(!cancelGroup.run([]() { }), "cancelled AsyncThread should reject new group tasks");
	}

	{
		AsyncThread frameCancelPool;
		std::atomic<bool> callerStarted{false};
		std::atomic<size_t> executed{0};
		std::thread caller([&]() {
			frameCancelPool.runFrameTasks(4096, [&](size_t index) {
				if (index == 0) callerStarted.store(true, std::memory_order_release);
				executed.fetch_add(1, std::memory_order_relaxed);
				std::this_thread::sleep_for(std::chrono::milliseconds(1));
			});
		});
		while (!callerStarted.load(std::memory_order_acquire)) {
			std::this_thread::yield();
		}
		frameCancelPool.cancel();
		caller.join();
		AssertUnless(executed.load(std::memory_order_relaxed) > 0
				&& executed.load(std::memory_order_relaxed) < 4096,
			"cancelled FrameTask batch should settle queued items without executing all of them");
		const auto beforeFallback = executed.load(std::memory_order_relaxed);
		frameCancelPool.runFrameTasks(8, [&](size_t) {
			executed.fetch_add(1, std::memory_order_relaxed);
		});
		AssertUnless(executed.load(std::memory_order_relaxed) == beforeFallback + 8,
			"stopped FrameTask pool should execute the complete batch on its caller");
	}
	Println("[AsyncTaskGroupCpp] result: PASS");
	return true;
}

DORA_TEST_ENTRY(FrameTaskDispatchBenchmarkCpp) {
	AsyncThread pool;
	auto legacyGroup = pool.createTaskGroup();
	const auto maxTasks = std::min(pool.getWorkerCount() + 1, std::size_t{12});
	const size_t scenarios[] = {2, std::min(std::size_t{4}, maxTasks), maxTasks};
	constexpr auto warmupBatches = 100;
	constexpr auto measuredBlocks = 6;
	constexpr auto batchesPerBlock = 500;
	std::atomic<size_t> sink{0};

	for (const auto taskCount: scenarios) {
		if (taskCount < 2) continue;
		auto runLegacy = [&]() {
			for (auto index = size_t{1}; index < taskCount; ++index) {
				AssertUnless(legacyGroup.run([&sink]() {
					sink.fetch_add(1, std::memory_order_relaxed);
				}), "legacy FrameTask benchmark submission failed");
			}
			sink.fetch_add(1, std::memory_order_relaxed);
			legacyGroup.wait();
		};
		auto runIndexed = [&]() {
			pool.runFrameTasks(taskCount, [&sink](size_t) {
				sink.fetch_add(1, std::memory_order_relaxed);
			});
		};
		for (auto i = 0; i < warmupBatches; ++i) {
			runLegacy();
			runIndexed();
		}
		double legacyMs = 0.0;
		double indexedMs = 0.0;
		for (auto block = 0; block < measuredBlocks; ++block) {
			auto measure = [&](auto&& run) {
				const auto started = std::chrono::steady_clock::now();
				for (auto batch = 0; batch < batchesPerBlock; ++batch) run();
				return std::chrono::duration<double, std::milli>(
					std::chrono::steady_clock::now() - started).count();
			};
			if ((block & 1) == 0) {
				legacyMs += measure(runLegacy);
				indexedMs += measure(runIndexed);
			} else {
				indexedMs += measure(runIndexed);
				legacyMs += measure(runLegacy);
			}
		}
		const auto batches = static_cast<double>(measuredBlocks * batchesPerBlock);
		const auto legacyUs = legacyMs * 1000.0 / batches;
		const auto indexedUs = indexedMs * 1000.0 / batches;
		Println("[FrameTaskDispatchAB] workers={} tasks={} legacy_us={:.6f} "
			"indexed_us={:.6f} speedup={:.4f}", pool.getWorkerCount(), taskCount,
			legacyUs, indexedUs, legacyUs / indexedUs);
	}
	AssertUnless(sink.load(std::memory_order_relaxed) > 0,
		"FrameTask dispatch benchmark did not execute tasks");
	return true;
}

DORA_TEST_ENTRY(PlayRhoParallelIslandsCpp) {
	using namespace playrho;
	auto parallelConf = pd::WorldConf{};
	const auto workerCount = SharedAsyncThread.getWorkerCount();
	parallelConf.islandTaskConcurrency = workerCount + 1;
	parallelConf.minParallelIslandCost = 0;
	std::atomic<int> islandDispatches{0};
	std::atomic<int> broadPhaseDispatches{0};
	parallelConf.islandTaskExecutor = [&islandDispatches](
		size_t taskCount, const pd::ParallelTask& task) {
		islandDispatches.fetch_add(1, std::memory_order_relaxed);
		SharedAsyncThread.runFrameTasks(taskCount, task);
	};
	parallelConf.broadPhaseTaskConcurrency = workerCount + 1;
	parallelConf.minParallelBroadPhaseProxies = 0;
	parallelConf.broadPhaseProxiesPerTask = 1;
	parallelConf.broadPhaseTaskExecutor = [&broadPhaseDispatches](
		size_t taskCount, const pd::ParallelTask& task) {
		broadPhaseDispatches.fetch_add(1, std::memory_order_relaxed);
		SharedAsyncThread.runFrameTasks(taskCount, task);
	};
	auto serialWorld = pd::World{};
	auto parallelWorld = pd::World{parallelConf};

	auto populate = [](pd::World& world) {
		std::mt19937 random{0x5eed1234u};
		std::uniform_real_distribution<float> offset{-0.08f, 0.08f};
		auto shape = pd::CreateShape(world,
			pd::PolygonShapeConf{1_m, 1_m}.UseDensity(1_kgpm2).UseFriction(0.4f));
		for (int i = 0; i < 32; ++i) {
			const auto x = static_cast<float>(i) * 5.0f + offset(random);
			pd::CreateBody(world, pd::BodyConf{}
				.Use(BodyType::Static)
				.UseLocation(Length2{x * Meter, 0_m})
				.Use(shape));
			pd::CreateBody(world, pd::BodyConf{}
				.Use(BodyType::Dynamic)
				.UseLocation(Length2{x * Meter, 1.5_m + offset(random) * Meter})
				.UseLinearVelocity(LinearVelocity2{offset(random) * MeterPerSecond, -1_mps})
				.Use(shape));
		}
	};
	populate(serialWorld);
	populate(parallelWorld);

	std::vector<ContactID> serialBegin;
	std::vector<ContactID> parallelBegin;
	std::vector<ContactID> serialEnd;
	std::vector<ContactID> parallelEnd;
	std::vector<ContactID> serialPre;
	std::vector<ContactID> parallelPre;
	std::vector<ContactID> serialPost;
	std::vector<ContactID> parallelPost;
	const auto logicThread = std::this_thread::get_id();
	std::atomic<bool> listenerOnWorker{false};
	pd::SetBeginContactListener(serialWorld, [&](ContactID id) { serialBegin.push_back(id); });
	pd::SetBeginContactListener(parallelWorld, [&](ContactID id) {
		if (std::this_thread::get_id() != logicThread) {
			listenerOnWorker.store(true, std::memory_order_relaxed);
		}
		parallelBegin.push_back(id);
	});
	pd::SetEndContactListener(serialWorld, [&](ContactID id) { serialEnd.push_back(id); });
	pd::SetEndContactListener(parallelWorld, [&](ContactID id) {
		if (std::this_thread::get_id() != logicThread) {
			listenerOnWorker.store(true, std::memory_order_relaxed);
		}
		parallelEnd.push_back(id);
	});
	pd::SetPreSolveContactListener(serialWorld,
		[&](ContactID id, const pd::Manifold&) { serialPre.push_back(id); });
	pd::SetPreSolveContactListener(parallelWorld,
		[&](ContactID id, const pd::Manifold&) {
			if (std::this_thread::get_id() != logicThread) {
				listenerOnWorker.store(true, std::memory_order_relaxed);
			}
			parallelPre.push_back(id);
		});
	pd::SetPostSolveContactListener(serialWorld,
		[&](ContactID id, const pd::ContactImpulsesList&, unsigned) { serialPost.push_back(id); });
	pd::SetPostSolveContactListener(parallelWorld,
		[&](ContactID id, const pd::ContactImpulsesList&, unsigned) {
			if (std::this_thread::get_id() != logicThread) {
				listenerOnWorker.store(true, std::memory_order_relaxed);
			}
			parallelPost.push_back(id);
		});

	auto stepConf = StepConf{};
	stepConf.deltaTime = 1_s / 60;
	for (int frame = 0; frame < 120; ++frame) {
		serialBegin.clear();
		parallelBegin.clear();
		serialEnd.clear();
		parallelEnd.clear();
		serialPre.clear();
		parallelPre.clear();
		serialPost.clear();
		parallelPost.clear();
		pd::Step(serialWorld, stepConf);
		pd::Step(parallelWorld, stepConf);
		AssertUnless(serialWorld == parallelWorld,
			"fixed-seed serial and parallel PlayRho worlds diverged at frame {}", frame);
		AssertUnless(serialBegin == parallelBegin,
			"parallel begin-contact ordering diverged at frame {}", frame);
		AssertUnless(serialEnd == parallelEnd,
			"parallel end-contact ordering diverged at frame {}", frame);
		AssertUnless(serialPre == parallelPre,
			"parallel pre-solve ordering diverged at frame {}", frame);
		AssertUnless(serialPost == parallelPost,
			"parallel post-solve ordering diverged at frame {}", frame);
	}
	AssertUnless(!listenerOnWorker.load(std::memory_order_relaxed),
		"PlayRho listener was invoked from a physics worker");
	AssertUnless(islandDispatches.load(std::memory_order_relaxed) > 0,
		"fixed-seed replay did not exercise parallel island solving");
	AssertUnless(broadPhaseDispatches.load(std::memory_order_relaxed) > 0,
		"fixed-seed replay did not exercise parallel broad-phase queries");
	Println("[PlayRhoParallelIslandsCpp] fixed-seed island/broad-phase replay and listener ordering: PASS");
	return true;
}

DORA_TEST_ENTRY(PlayRhoLargeIslandBenchmarkCpp) {
	using namespace playrho;
	struct Scenario {
		int islandCount;
		int bodiesPerIsland;
	};
	constexpr auto warmupFrames = 60;
	constexpr auto measuredBlocks = 6;
	constexpr auto framesPerBlock = 120;
	const auto workerCount = SharedAsyncThread.getWorkerCount();
	AssertUnless(workerCount > 0, "large-island benchmark requires at least one pool worker");
	const Scenario scenarios[] = {
		{s_cast<int>(workerCount), 64},
		{s_cast<int>(workerCount + 1), 128},
		{s_cast<int>(workerCount * 2), 128},
		{s_cast<int>(workerCount * 2 + 1), 128},
		{s_cast<int>(workerCount + 1), 512},
		{s_cast<int>(workerCount * 2 + 1), 512},
	};

	auto populate = [](pd::World& world, const Scenario& scenario) {
		auto shape = pd::CreateShape(world,
			pd::PolygonShapeConf{0.2_m, 0.2_m}.UseDensity(1_kgpm2).UseFriction(0.2f));
		for (int islandIndex = 0; islandIndex < scenario.islandCount; ++islandIndex) {
			auto previous = InvalidBodyID;
			const auto baseX = static_cast<float>(islandIndex) * 4.0f * Meter;
			for (int bodyIndex = 0; bodyIndex < scenario.bodiesPerIsland; ++bodyIndex) {
				const auto body = pd::CreateBody(world, pd::BodyConf{}
					.Use(BodyType::Dynamic)
					.UseLocation(Length2{baseX, static_cast<float>(bodyIndex) * 0.5f * Meter})
					.UseLinearVelocity(LinearVelocity2{
						((bodyIndex & 1) ? 0.15f : -0.15f) * MeterPerSecond,
						((bodyIndex % 3) ? 0.05f : -0.1f) * MeterPerSecond})
					.UseAllowSleep(false)
					.Use(shape));
				if (IsValid(previous)) {
					pd::CreateJoint(world, pd::DistanceJointConf{
						previous, body, Length2{}, Length2{}, 0.5_m});
				}
				previous = body;
			}
		}
	};

	auto stepConf = StepConf{};
	stepConf.deltaTime = 1_s / 60;
	auto measure = [&stepConf](pd::World& world, int frames) {
		const auto started = std::chrono::steady_clock::now();
		for (int frame = 0; frame < frames; ++frame) {
			pd::Step(world, stepConf);
		}
		const auto elapsed = std::chrono::duration<double, std::milli>(
			std::chrono::steady_clock::now() - started).count();
		return elapsed / static_cast<double>(frames);
	};

	for (const auto& scenario : scenarios) {
		auto baselineGroup = SharedAsyncThread.createTaskGroup();
		auto baselineConf = pd::WorldConf{};
		baselineConf.islandTaskConcurrency = workerCount;
		baselineConf.minParallelIslandCost = 0;
		baselineConf.islandTaskExecutor = [&baselineGroup](size_t taskCount, const pd::ParallelTask& task) {
			std::exception_ptr exception;
			for (auto taskIndex = size_t{0}; taskIndex < taskCount; ++taskIndex) {
				if (!baselineGroup.run([&, taskIndex]() { task(taskIndex); })) {
					try {
						task(taskIndex);
					} catch (...) {
						if (!exception) exception = std::current_exception();
					}
				}
			}
			try {
				baselineGroup.wait();
			} catch (...) {
				if (!exception) exception = std::current_exception();
			}
			if (exception) std::rethrow_exception(exception);
		};
		auto callerConf = pd::WorldConf{};
		callerConf.islandTaskConcurrency = workerCount + 1;
		callerConf.minParallelIslandCost = 0;
		callerConf.islandTaskExecutor = [](size_t taskCount, const pd::ParallelTask& task) {
			SharedAsyncThread.runFrameTasks(taskCount, task);
		};
		auto serialWorld = pd::World{};
		auto baselineWorld = pd::World{baselineConf};
		auto callerWorld = pd::World{callerConf};
		populate(serialWorld, scenario);
		populate(baselineWorld, scenario);
		populate(callerWorld, scenario);
		for (int frame = 0; frame < warmupFrames; ++frame) {
			pd::Step(serialWorld, stepConf);
			pd::Step(baselineWorld, stepConf);
			pd::Step(callerWorld, stepConf);
		}
		AssertUnless(serialWorld == baselineWorld && baselineWorld == callerWorld,
			"large-island worlds diverged during warmup");

		double serialMs = 0.0;
		double baselineMs = 0.0;
		double callerMs = 0.0;
		for (int block = 0; block < measuredBlocks; ++block) {
			serialMs += measure(serialWorld, framesPerBlock);
			if ((block & 1) == 0) {
				baselineMs += measure(baselineWorld, framesPerBlock);
				callerMs += measure(callerWorld, framesPerBlock);
			} else {
				callerMs += measure(callerWorld, framesPerBlock);
				baselineMs += measure(baselineWorld, framesPerBlock);
			}
		}
		serialMs /= measuredBlocks;
		baselineMs /= measuredBlocks;
		callerMs /= measuredBlocks;
		AssertUnless(serialWorld == baselineWorld && baselineWorld == callerWorld,
			"large-island worlds diverged after measured replay");
		Println("[PlayRhoLargeIslandAB] workers={} islands={} bodies_per_island={} total_bodies={} "
			"serial_ms={:.6f} baseline_ms={:.6f} caller_ms={:.6f} "
			"caller_speedup={:.4f} parallel_speedup={:.4f}",
			workerCount, scenario.islandCount, scenario.bodiesPerIsland,
			scenario.islandCount * scenario.bodiesPerIsland,
			serialMs, baselineMs, callerMs, baselineMs / callerMs, serialMs / callerMs);
	}
	return true;
}

DORA_TEST_ENTRY(PlayRhoBroadPhaseBenchmarkCpp) {
	using namespace playrho;
	struct Scenario {
		int bodyCount;
		float spacing;
	};
	constexpr Scenario scenarios[] = {
		{16, 0.35f}, {32, 0.35f}, {64, 0.35f}, {128, 0.35f},
		{256, 0.35f}, {512, 0.35f}, {2048, 0.35f}, {4096, 0.35f},
		{256, 2.0f}, {512, 2.0f}, {2048, 2.0f},
	};
	constexpr auto warmupFrames = 10;
	constexpr auto measuredBlocks = 6;
	constexpr auto framesPerBlock = 30;
	const auto workerCount = SharedAsyncThread.getWorkerCount();
	AssertUnless(workerCount > 0, "broad-phase benchmark requires at least one pool worker");

	struct MovingBodies {
		std::vector<BodyID> ids;
		std::vector<Length2> locations;
	};
	auto populate = [](pd::World& world, const Scenario& scenario) {
		auto bodies = MovingBodies{};
		bodies.ids.reserve(scenario.bodyCount);
		bodies.locations.reserve(scenario.bodyCount);
		auto shape = pd::CreateShape(world,
			pd::PolygonShapeConf{0.2_m, 0.2_m}
				.UseDensity(1_kgpm2)
				.UseFilter(Filter{1u, 0u, 0}));
		constexpr auto columns = 64;
		for (int index = 0; index < scenario.bodyCount; ++index) {
			const auto location = Length2{
				static_cast<float>(index % columns) * scenario.spacing * Meter,
				static_cast<float>(index / columns) * scenario.spacing * Meter};
			bodies.locations.push_back(location);
			bodies.ids.push_back(pd::CreateBody(world, pd::BodyConf{}
				.Use(BodyType::Kinematic)
				.UseLocation(location)
				.UseAllowSleep(false)
				.Use(shape)));
		}
		return bodies;
	};
	auto moveBodies = [](pd::World& world, const MovingBodies& bodies, bool shifted) {
		const auto offset = shifted ? Length2{0.75_m, 0_m} : Length2{};
		for (auto index = std::size_t{0}; index < bodies.ids.size(); ++index) {
			auto body = pd::GetBody(world, bodies.ids[index]);
			pd::SetLocation(body, bodies.locations[index] + offset);
			pd::SetBody(world, bodies.ids[index], body);
		}
	};
	auto stepConf = StepConf{};
	stepConf.deltaTime = 0_s;
	auto measureStep = [&stepConf](pd::World& world) {
		const auto started = std::chrono::steady_clock::now();
		pd::Step(world, stepConf);
		return std::chrono::duration<double, std::milli>(
			std::chrono::steady_clock::now() - started).count();
	};

	for (const auto& scenario : scenarios) {
		struct DispatchTotals {
			double submitMs = 0.0;
			double callerMs = 0.0;
			double waitMs = 0.0;
			double totalMs = 0.0;
			size_t taskCount = 0;
			size_t dispatchCount = 0;
		} dispatchTotals;
		struct BroadPhaseTotals {
			double queryMs = 0.0;
			double mergeMs = 0.0;
			double sortMs = 0.0;
			double addContactsMs = 0.0;
			size_t candidates = 0;
			size_t uniqueCandidates = 0;
			size_t sampleCount = 0;
		} broadPhaseTotals;
		bool measureDispatch = false;
		auto parallelConf = pd::WorldConf{};
		parallelConf.broadPhaseTaskConcurrency = workerCount + 1;
		parallelConf.minParallelBroadPhaseProxies = 0;
		parallelConf.broadPhaseTaskExecutor = [&](size_t taskCount, const pd::ParallelTask& task) {
			FrameTaskDispatchStats stats;
			SharedAsyncThread.runFrameTasks(taskCount, task, measureDispatch ? &stats : nullptr);
			if (measureDispatch) {
				dispatchTotals.submitMs += stats.submitMilliseconds;
				dispatchTotals.callerMs += stats.callerMilliseconds;
				dispatchTotals.waitMs += stats.waitMilliseconds;
				dispatchTotals.totalMs += stats.totalMilliseconds;
				dispatchTotals.taskCount += stats.taskCount;
				++dispatchTotals.dispatchCount;
			}
		};
		parallelConf.broadPhaseProfiler = [&](const pd::BroadPhaseProfileStats& stats) {
			if (!measureDispatch) return;
			broadPhaseTotals.queryMs += stats.queryMilliseconds;
			broadPhaseTotals.mergeMs += stats.mergeMilliseconds;
			broadPhaseTotals.sortMs += stats.sortMilliseconds;
			broadPhaseTotals.addContactsMs += stats.addContactsMilliseconds;
			broadPhaseTotals.candidates += stats.candidateCount;
			broadPhaseTotals.uniqueCandidates += stats.uniqueCandidateCount;
			++broadPhaseTotals.sampleCount;
		};
		auto serialWorld = pd::World{};
		auto parallelWorld = pd::World{parallelConf};
		const auto serialBodies = populate(serialWorld, scenario);
		const auto parallelBodies = populate(parallelWorld, scenario);
		pd::Step(serialWorld, stepConf);
		pd::Step(parallelWorld, stepConf);
		for (int frame = 0; frame < warmupFrames; ++frame) {
			const auto shifted = (frame & 1) == 0;
			moveBodies(serialWorld, serialBodies, shifted);
			moveBodies(parallelWorld, parallelBodies, shifted);
			pd::Step(serialWorld, stepConf);
			pd::Step(parallelWorld, stepConf);
		}
		AssertUnless(serialWorld == parallelWorld,
			"broad-phase serial and parallel worlds diverged during warmup");

		measureDispatch = true;
		double serialMs = 0.0;
		double parallelMs = 0.0;
		for (int block = 0; block < measuredBlocks; ++block) {
			for (int frame = 0; frame < framesPerBlock; ++frame) {
				const auto shifted = ((block * framesPerBlock + frame) & 1) == 0;
				moveBodies(serialWorld, serialBodies, shifted);
				moveBodies(parallelWorld, parallelBodies, shifted);
				if ((block & 1) == 0) {
					serialMs += measureStep(serialWorld);
					parallelMs += measureStep(parallelWorld);
				} else {
					parallelMs += measureStep(parallelWorld);
					serialMs += measureStep(serialWorld);
				}
			}
		}
		const auto measuredFrames = static_cast<double>(measuredBlocks * framesPerBlock);
		serialMs /= measuredFrames;
		parallelMs /= measuredFrames;
		AssertUnless(serialWorld == parallelWorld,
			"broad-phase serial and parallel worlds diverged after measured replay");
		const auto dispatchDivisor = static_cast<double>(
			std::max(dispatchTotals.dispatchCount, std::size_t{1}));
		const auto profileDivisor = static_cast<double>(
			std::max(broadPhaseTotals.sampleCount, std::size_t{1}));
		Println("[PlayRhoBroadPhaseAB] workers={} bodies={} spacing={:.2f} serial_ms={:.6f} "
			"parallel_ms={:.6f} speedup={:.4f} dispatches={} tasks_avg={:.2f} "
			"submit_ms={:.6f} caller_ms={:.6f} wait_ms={:.6f} dispatch_ms={:.6f} "
			"query_ms={:.6f} merge_ms={:.6f} sort_ms={:.6f} add_ms={:.6f} "
			"candidates_avg={:.2f} unique_avg={:.2f}",
			workerCount, scenario.bodyCount,
			scenario.spacing, serialMs, parallelMs,
			serialMs / parallelMs, dispatchTotals.dispatchCount,
			static_cast<double>(dispatchTotals.taskCount) / dispatchDivisor,
			dispatchTotals.submitMs / dispatchDivisor,
			dispatchTotals.callerMs / dispatchDivisor,
			dispatchTotals.waitMs / dispatchDivisor,
			dispatchTotals.totalMs / dispatchDivisor,
			broadPhaseTotals.queryMs / profileDivisor,
			broadPhaseTotals.mergeMs / profileDivisor,
			broadPhaseTotals.sortMs / profileDivisor,
			broadPhaseTotals.addContactsMs / profileDivisor,
			static_cast<double>(broadPhaseTotals.candidates) / profileDivisor,
			static_cast<double>(broadPhaseTotals.uniqueCandidates) / profileDivisor);
	}
	return true;
}

DORA_TEST_ENTRY(PlayRhoBroadPhaseStressCpp) {
	using namespace playrho;
	struct Scenario {
		int bodyCount;
		float spacing;
	};
	constexpr Scenario scenarios[] = {{4096, 0.35f}, {2048, 2.0f}};
	const auto workerCount = SharedAsyncThread.getWorkerCount();
	AssertUnless(workerCount > 0, "broad-phase stress test requires at least one pool worker");

	auto parallelConf = pd::WorldConf{};
	parallelConf.broadPhaseTaskConcurrency = workerCount + 1;
	parallelConf.minParallelBroadPhaseProxies = 0;
	std::atomic<size_t> dispatches{0};
	parallelConf.broadPhaseTaskExecutor = [&dispatches](size_t taskCount, const pd::ParallelTask& task) {
		dispatches.fetch_add(1, std::memory_order_relaxed);
		SharedAsyncThread.runFrameTasks(taskCount, task);
	};
	auto stepConf = StepConf{};
	stepConf.deltaTime = 0_s;

	for (const auto& scenario : scenarios) {
		auto serialWorld = pd::World{};
		auto parallelWorld = pd::World{parallelConf};
		auto populate = [&](pd::World& world) {
			std::vector<BodyID> bodies;
			bodies.reserve(scenario.bodyCount);
			auto shape = pd::CreateShape(world,
				pd::PolygonShapeConf{0.2_m, 0.2_m}
					.UseDensity(1_kgpm2)
					.UseFilter(Filter{1u, 0u, 0}));
			for (int index = 0; index < scenario.bodyCount; ++index) {
				const auto location = Length2{
					static_cast<float>(index % 64) * scenario.spacing * Meter,
					static_cast<float>(index / 64) * scenario.spacing * Meter};
				bodies.push_back(pd::CreateBody(world, pd::BodyConf{}
					.Use(BodyType::Kinematic)
					.UseLocation(location)
					.UseAllowSleep(false)
					.Use(shape)));
			}
			return bodies;
		};
		const auto serialBodies = populate(serialWorld);
		const auto parallelBodies = populate(parallelWorld);
		for (int frame = 0; frame < 12; ++frame) {
			const auto offset = (frame & 1) ? Length2{0.75_m, 0_m} : Length2{};
			for (auto index = size_t{0}; index < serialBodies.size(); ++index) {
				auto serialBody = pd::GetBody(serialWorld, serialBodies[index]);
				auto parallelBody = pd::GetBody(parallelWorld, parallelBodies[index]);
				const auto location = Length2{
					static_cast<float>(index % 64) * scenario.spacing * Meter,
					static_cast<float>(index / 64) * scenario.spacing * Meter} + offset;
				pd::SetLocation(serialBody, location);
				pd::SetLocation(parallelBody, location);
				pd::SetBody(serialWorld, serialBodies[index], serialBody);
				pd::SetBody(parallelWorld, parallelBodies[index], parallelBody);
			}
			pd::Step(serialWorld, stepConf);
			pd::Step(parallelWorld, stepConf);
			AssertUnless(serialWorld == parallelWorld,
				"broad-phase stress worlds diverged at frame {}", frame);
		}
	}
	AssertUnless(dispatches.load(std::memory_order_relaxed) > 0,
		"broad-phase stress test did not exercise parallel dispatch");
	Println("[PlayRhoBroadPhaseStressCpp] dense=4096 sparse=2048 fixed replay: PASS");
	return true;
}

DORA_TEST_ENTRY(AsyncCancelStopStressCpp) {
	struct State {
		std::atomic<bool> started{false};
		std::atomic<bool> finished{false};
		std::atomic<bool> logged{false};
		std::atomic<int> phase{0};
		std::atomic<int> poolExecuted{0};
		std::atomic<int> dedicatedExecuted{0};
		bool pass = false;
		std::string message;
		double elapsedMs = 0.0;
	};

	auto state = std::make_shared<State>();
	auto ui = Node::create();
	ui->schedule([state](double) {
		if (!state->started.exchange(true, std::memory_order_acq_rel)) {
			SharedAsyncThread.run([state]() {
				auto start = std::chrono::steady_clock::now();
				try {
					state->phase.store(1, std::memory_order_relaxed);
					{
						AsyncThread pool;
						std::atomic<bool> keepProducing{true};
						std::thread producerA([&]() {
							for (int i = 0; i < 5000 && keepProducing.load(std::memory_order_relaxed); i++) {
								pool.run([state]() {
									std::this_thread::sleep_for(std::chrono::milliseconds(2));
									state->poolExecuted.fetch_add(1, std::memory_order_relaxed);
								});
							}
						});
						std::thread producerB([&]() {
							for (int i = 0; i < 5000 && keepProducing.load(std::memory_order_relaxed); i++) {
								pool.run([state]() {
									std::this_thread::sleep_for(std::chrono::milliseconds(1));
									state->poolExecuted.fetch_add(1, std::memory_order_relaxed);
								});
							}
						});
						std::this_thread::sleep_for(std::chrono::milliseconds(20));
						std::thread cancelA([&]() { pool.cancel(); });
						std::thread cancelB([&]() {
							std::this_thread::sleep_for(std::chrono::milliseconds(1));
							pool.cancel();
						});
						keepProducing.store(false, std::memory_order_relaxed);
						producerA.join();
						producerB.join();
						cancelA.join();
						cancelB.join();
					}

					state->phase.store(2, std::memory_order_relaxed);
					{
						AsyncThread owner;
						Async* dedicatedThread = owner.newThread();
						std::thread producer([&]() {
							for (int i = 0; i < 4000; i++) {
								dedicatedThread->run([state]() {
									std::this_thread::sleep_for(std::chrono::milliseconds(1));
									state->dedicatedExecuted.fetch_add(1, std::memory_order_relaxed);
								});
							}
						});
						std::this_thread::sleep_for(std::chrono::milliseconds(10));
						std::thread stopA([&]() { dedicatedThread->stop(); });
						std::thread stopB([&]() {
							std::this_thread::sleep_for(std::chrono::milliseconds(1));
							dedicatedThread->stop();
						});
						producer.join();
						stopA.join();
						stopB.join();
					}

					state->phase.store(3, std::memory_order_relaxed);
					auto end = std::chrono::steady_clock::now();
					state->elapsedMs = std::chrono::duration<double, std::milli>(end - start).count();
					state->pass = true;
					state->message = "cancel()/stop() stress finished without crash or deadlock";
				} catch (const std::exception& e) {
					state->pass = false;
					state->message = fmt::format("exception: {}", e.what());
				}
				state->finished.store(true, std::memory_order_release);
			});
		}

		auto size = SharedApplication.getVisualSize();
		ImGui::SetNextWindowBgAlpha(0.35f);
		ImGui::SetNextWindowPos(Vec2{size.width - 10.0f, 10.0f}, ImGuiCond_Always, Vec2{1.0f, 0});
		ImGui::SetNextWindowSize(Vec2{460.0f, 0}, ImGuiCond_FirstUseEver);
		if (ImGui::Begin("Async cancel/stop stress", nullptr,
				ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoFocusOnAppearing | ImGuiWindowFlags_NoNav | ImGuiWindowFlags_NoMove)) {
			const char* phaseText = "pending";
			switch (state->phase.load(std::memory_order_relaxed)) {
				case 1: phaseText = "phase1: concurrent pool.cancel()"; break;
				case 2: phaseText = "phase2: concurrent dedicatedThread.stop()"; break;
				case 3: phaseText = "done"; break;
				default: break;
			}
			ImGui::Text("Phase: %s", phaseText);
			ImGui::Text("Pool task executed: %d", state->poolExecuted.load(std::memory_order_relaxed));
			ImGui::Text("Dedicated-thread task executed: %d", state->dedicatedExecuted.load(std::memory_order_relaxed));
			if (state->finished.load(std::memory_order_acquire)) {
				ImGui::Separator();
				ImGui::Text("Elapsed: %.2f ms", state->elapsedMs);
				ImGui::Text("Result: %s", state->pass ? "PASS" : "FAIL");
				ImGui::TextWrapped("%s", state->message.c_str());
			} else {
				ImGui::Text("Running...");
			}
			ImGui::Separator();
			ImGui::TextWrapped("This stress test runs concurrent cancel()/stop() calls while producers are pushing tasks. PASS means the procedure returns normally.");
		}
		ImGui::End();

		if (state->finished.load(std::memory_order_acquire)) {
			if (!state->logged.exchange(true, std::memory_order_acq_rel)) {
				Println("[AsyncCancelStopStressCpp] elapsed {:.2f} ms", state->elapsedMs);
				Println("[AsyncCancelStopStressCpp] pool executed {}", state->poolExecuted.load(std::memory_order_relaxed));
				Println("[AsyncCancelStopStressCpp] dedicated thread executed {}", state->dedicatedExecuted.load(std::memory_order_relaxed));
				Println("[AsyncCancelStopStressCpp] result: {}", state->pass ? "PASS" : "FAIL");
				if (!state->message.empty()) {
					Println("[AsyncCancelStopStressCpp] {}", state->message);
				}
			}
		}
		return false;
	});
	return true;
}
