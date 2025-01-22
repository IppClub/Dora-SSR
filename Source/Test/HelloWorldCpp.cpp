/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Dora.h"
using namespace Dora;

#include "imgui/imgui.h"

DORA_TEST_ENTRY(HelloWorldCpp) {
	auto node = Node::create();
	node->slot("Enter"sv, [](Event*) {
		println("on enter event"sv);
	});
	node->slot("Exit"sv, [](Event*) {
		println("on exit event"sv);
	});
	node->slot("Cleanup"sv, [](Event*) {
		println("on node destoyed event"sv);
	});
	node->schedule(once([]() -> Job {
		for (int i = 5; i > 0; i--) {
			println("{}", i);
			co_sleep(1);
		}
		println("Hello World!"sv);
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
