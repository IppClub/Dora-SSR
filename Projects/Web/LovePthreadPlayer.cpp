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
#include "Basic/Scheduler.h"
#include "Love/LoveNode.h"

#include <emscripten/emscripten.h>

#include <string>

namespace
{
Dora::Ref<Dora::LoveNode> playerNode;
std::string playerError;
std::string playerProject;
int playerState = 0;

bool isInstalledLoveEntry(const std::string &path)
{
	constexpr const char *Root = "/user/projects/";
	return path.starts_with(Root)
		&& path.size() > std::char_traits<char>::length(Root) + std::char_traits<char>::length("main.lua")
		&& path.ends_with("/main.lua")
		&& path.find("/../") == std::string::npos
		&& path.find("\\") == std::string::npos;
}
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_player_start(const char *bootFile)
{
	if (!bootFile || playerNode || playerState == 2)
	{
		playerError = "Love player is already running or stopping";
		return 0;
	}
	const std::string requested = bootFile;
	if (!isInstalledLoveEntry(requested))
	{
		playerError = "Love player only starts installed /user/projects/*/main.lua entries";
		return 0;
	}
	playerError.clear();
	playerProject = requested;
	playerState = 0;
	SharedApplication.invokeInLogic([requested]() {
		auto *node = Dora::LoveNode::createProbe(requested, playerError);
		if (!node)
		{
			if (playerError.empty()) playerError = "Failed to create the Love project";
			playerState = -1;
			return;
		}
		playerNode = node;
		SharedDirector.getUI()->removeAllChildren(true);
		SharedDirector.getUI()->addChild(node);
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_player_status()
{
	if (!playerNode) return playerState;
	const auto error = playerNode->getLastError().toString();
	if (!error.empty())
	{
		playerError = error;
		playerState = -1;
	}
	else if (playerState == 0 && playerNode->isRunning())
		playerState = 1;
	return playerState;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_player_stop()
{
	if (!playerNode)
	{
		if (playerState < 0)
		{
			playerProject.clear();
			playerState = 3;
			return 1;
		}
		return 0;
	}
	if (playerState == 2 || playerState == 3) return 0;
	playerState = 2;
	SharedApplication.invokeInLogic([]() {
		playerNode->removeFromParent(true);
		SharedDirector.getSystemScheduler()->schedule([](double) {
			playerNode = nullptr;
			playerProject.clear();
			playerState = 3;
			return true;
		});
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE const char *dora_web_love_player_error()
{
	return playerError.c_str();
}

extern "C" EMSCRIPTEN_KEEPALIVE const char *dora_web_love_player_project()
{
	return playerProject.c_str();
}
