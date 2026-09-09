/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Love/LoveNode.h"

#include <emscripten/emscripten.h>

#include <string>

namespace
{
Dora::Ref<Dora::LoveNode> probeNode;
std::string probeError;
int probeState = 0;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_shader_probe_start()
{
	if (probeNode)
		return 1;
	probeError.clear();
	probeState = 0;
	SharedApplication.invokeInLogic([]() {
		auto *node = Dora::LoveNode::createProbe("/love-shader/main.lua"_slice, probeError);
		if (!node)
		{
			if (probeError.empty()) probeError = "failed to create the Love Web shader fixture";
			probeState = -1;
			return;
		}
		probeNode = node;
		SharedDirector.getUI()->removeAllChildren(true);
		SharedDirector.getUI()->addChild(node);
		probeState = 1;
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_shader_probe_status()
{
	if (!probeNode)
		return probeState;
	const auto error = probeNode->getLastError().toString();
	if (!error.empty())
	{
		probeError = error;
		probeState = -1;
		return probeState;
	}
	return probeNode->isRunning() ? 1 : probeState;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_shader_probe_release()
{
	if (!probeNode || probeState != 1)
	{
		probeError = "Love Web shader fixture is not running";
		return 0;
	}
	probeState = 3;
	SharedApplication.invokeInLogic([]() {
		if (!probeNode->hasProbeGraphicsResources())
		{
			probeError = "Love Web shader fixture created no graphics resources";
			probeState = -1;
			return;
		}
		probeNode->removeFromParent(true);
		if (probeNode->hasProbeGraphicsResources())
		{
			probeError = "Love Web shader resources survived node cleanup";
			probeState = -1;
			return;
		}
		probeNode = nullptr;
		probeState = 2;
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE const char *dora_web_love_shader_probe_error()
{
	return probeError.c_str();
}
