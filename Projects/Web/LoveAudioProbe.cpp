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

#include "Audio/Audio.h"
#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Love/LoveNode.h"

#include "soloud.h"

#include <emscripten/emscripten.h>

#include <array>
#include <cstdint>
#include <string>

namespace
{
std::array<Dora::Ref<Dora::LoveNode>, 2> probeNodes;
std::string probeError;
int probeState = 0;
std::uint32_t baselineAudioFiles = 0;
unsigned int baselineVoices = 0;

unsigned int voiceCount()
{
	auto *soloud = SharedAudio.getSoLoud();
	return soloud ? soloud->getVoiceCount() : 0;
}

bool checkNode(const Dora::Ref<Dora::LoveNode> &node, std::size_t index)
{
	if (!node)
		return true;
	const auto error = node->getLastError().toString();
	if (error.empty())
		return true;
	probeError = "Love Web audio instance " + std::to_string(index + 1) + ": " + error;
	probeState = -1;
	return false;
}

Dora::LoveNode *createNode()
{
	auto *node = Dora::LoveNode::createProbe("/love-audio/main.lua"_slice, probeError);
	if (!node && probeError.empty())
		probeError = "failed to create the Love Web audio fixture";
	return node;
}

void removeNode(std::size_t index)
{
	if (!probeNodes[index])
		return;
	probeNodes[index]->removeFromParent(true);
	if (probeNodes[index]->hasProbeAudioResources())
	{
		probeError = "Love Web audio resources survived instance cleanup";
		probeState = -1;
		return;
	}
	probeNodes[index] = nullptr;
}
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_audio_probe_start()
{
	if (probeNodes[0] || probeNodes[1])
		return 1;
	probeError.clear();
	probeState = 0;
	baselineAudioFiles = Dora::AudioFile::getCount();
	baselineVoices = voiceCount();
	SharedApplication.invokeInLogic([]() {
		auto *first = createNode();
		if (!first)
		{
			probeState = -1;
			return;
		}
		probeNodes[0] = first;
		SharedDirector.getUI()->removeAllChildren(true);
		SharedDirector.getUI()->addChild(first);
		auto *second = createNode();
		if (!second)
		{
			removeNode(0);
			probeState = -1;
			return;
		}
		probeNodes[1] = second;
		SharedDirector.getUI()->addChild(second);
		probeState = 1;
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_audio_probe_status()
{
	if (!checkNode(probeNodes[0], 0) || !checkNode(probeNodes[1], 1))
		return -1;
	return probeState;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_audio_probe_restart_first()
{
	if (probeState != 1 || !probeNodes[0] || !probeNodes[1])
	{
		probeError = "Love Web audio instances are not ready to restart";
		return 0;
	}
	probeState = 3;
	SharedApplication.invokeInLogic([]() {
		if (!probeNodes[0]->restart())
		{
			probeError = probeNodes[0]->getLastError().toString();
			if (probeError.empty()) probeError = "Love Web audio instance restart failed";
			probeState = -1;
			return;
		}
		probeState = 1;
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_audio_probe_release_first()
{
	if (probeState != 1 || !probeNodes[0] || !probeNodes[1])
	{
		probeError = "Love Web audio instances are not ready for isolated cleanup";
		return 0;
	}
	probeState = 4;
	SharedApplication.invokeInLogic([]() {
		removeNode(0);
		if (probeState < 0)
			return;
		if (!probeNodes[1] || !probeNodes[1]->isRunning()
			|| probeNodes[1]->getProbeAudioSourceCount() == 0)
		{
			probeError = "cleaning one Love Web audio instance affected its peer";
			probeState = -1;
			return;
		}
		probeState = 5;
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_audio_probe_release()
{
	if (probeState != 1 && probeState != 5)
	{
		probeError = "Love Web audio fixture is not ready for cleanup";
		return 0;
	}
	probeState = 6;
	SharedApplication.invokeInLogic([]() {
		removeNode(0);
		if (probeState < 0) return;
		removeNode(1);
		if (probeState < 0) return;
		// Lua proxies and their retained AudioFiles leave the autorelease pool at
		// the end of the logic frame. Check the process-wide counters after two
		// scheduler turns so a correct cleanup is not mistaken for a leak.
		SharedDirector.getSystemScheduler()->schedule([remaining = 2](double) mutable {
			if (remaining-- > 0) return false;
			if (Dora::AudioFile::getCount() != baselineAudioFiles)
			{
				probeError = "Love Web AudioFile objects survived final cleanup";
				probeState = -1;
				return true;
			}
			if (voiceCount() != baselineVoices)
			{
				probeError = "Love Web SoLoud voices survived final cleanup";
				probeState = -1;
				return true;
			}
			probeState = 2;
			return true;
		});
	});
	return 1;
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_audio_probe_instance_count()
{
	return static_cast<int>((probeNodes[0] ? 1 : 0) + (probeNodes[1] ? 1 : 0));
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_audio_probe_source_count()
{
	std::size_t count = 0;
	for (const auto &node : probeNodes)
		if (node) count += node->getProbeAudioSourceCount();
	return static_cast<int>(count);
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_audio_probe_playing_count()
{
	std::size_t count = 0;
	for (const auto &node : probeNodes)
		if (node) count += node->getProbePlayingAudioSourceCount();
	return static_cast<int>(count);
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_audio_probe_audio_file_delta()
{
	return static_cast<int>(Dora::AudioFile::getCount()) - static_cast<int>(baselineAudioFiles);
}

extern "C" EMSCRIPTEN_KEEPALIVE int dora_web_love_audio_probe_voice_delta()
{
	return static_cast<int>(voiceCount()) - static_cast<int>(baselineVoices);
}

extern "C" EMSCRIPTEN_KEEPALIVE double dora_web_love_audio_probe_frame()
{
	return static_cast<double>(SharedApplication.getFrame());
}

extern "C" EMSCRIPTEN_KEEPALIVE const char *dora_web_love_audio_probe_error()
{
	return probeError.c_str();
}
