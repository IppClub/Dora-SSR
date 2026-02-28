/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Dora.h"
using namespace Dora;

#include "imgui/imgui.h"
#include <algorithm>
#include <atomic>
#include <chrono>
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

DORA_TEST_ENTRY(AsyncCancelStopStressCpp) {
	struct State {
		std::atomic<bool> started{false};
		std::atomic<bool> finished{false};
		std::atomic<bool> logged{false};
		std::atomic<int> phase{0};
		std::atomic<int> poolExecuted{0};
		std::atomic<int> userExecuted{0};
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
						Async* userThread = owner.newThread();
						std::thread producer([&]() {
							for (int i = 0; i < 4000; i++) {
								userThread->run([state]() {
									std::this_thread::sleep_for(std::chrono::milliseconds(1));
									state->userExecuted.fetch_add(1, std::memory_order_relaxed);
								});
							}
						});
						std::this_thread::sleep_for(std::chrono::milliseconds(10));
						std::thread stopA([&]() { userThread->stop(); });
						std::thread stopB([&]() {
							std::this_thread::sleep_for(std::chrono::milliseconds(1));
							userThread->stop();
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
				case 2: phaseText = "phase2: concurrent userThread.stop()"; break;
				case 3: phaseText = "done"; break;
				default: break;
			}
			ImGui::Text("Phase: %s", phaseText);
			ImGui::Text("Pool task executed: %d", state->poolExecuted.load(std::memory_order_relaxed));
			ImGui::Text("User-thread task executed: %d", state->userExecuted.load(std::memory_order_relaxed));
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
				Println("[AsyncCancelStopStressCpp] user thread executed {}", state->userExecuted.load(std::memory_order_relaxed));
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
