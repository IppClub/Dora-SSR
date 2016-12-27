/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Director.h"
#include "bx/timer.h"

NS_DOROTHY_BEGIN

Director::Director()
{ }

bool Director::init()
{
	// Initialization
	bgfx::reset(SharedApplication.getWidth(), SharedApplication.getHeight(), BGFX_RESET_VSYNC);
	bgfx::setDebug(BGFX_DEBUG_TEXT);
	bgfx::setViewClear(0,
		BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH,
		0x303030ff, 1.0f, 0);
	return true;
}

void Director::mainLoop()
{
		bgfx::setViewRect(0, 0, 0, SharedApplication.getWidth(), SharedApplication.getHeight());

		// This dummy draw call is here to make sure that view 0 is cleared
		// if no other draw calls are submitted to view 0.
		bgfx::touch(0);

		// Use debug font to print information about this example.
		bgfx::dbgTextClear();
		bgfx::dbgTextPrintf(0, 1, 0x4f, "bgfx/examples/00-helloworld");
		bgfx::dbgTextPrintf(0, 2, 0x6f, "Description: Initialization and debug text.");

		bgfx::dbgTextPrintf(0, 4, 0x0f, "Color can be changed with ANSI \x1b[9;me\x1b[10;ms\x1b[11;mc\x1b[12;ma\x1b[13;mp\x1b[14;me\x1b[0m code too.");

		const bgfx::Stats* stats = bgfx::getStats();

		bgfx::dbgTextPrintf(0, 6, 0x0f, "Backbuffer %dW x %dH in pixels, debug text %dW x %dH in characters."
				, stats->width
				, stats->height
				, stats->textWidth
				, stats->textHeight);

		bgfx::dbgTextPrintf(0, 8, 0x0f, "Compute %d, Draw %d, CPU Time %.3f/%.3f, GPU Time %.3f"
				, stats->numCompute
				, stats->numDraw
				, SharedApplication.getUpdateTime()
				, (stats->cpuTimeEnd - stats->cpuTimeBegin) / double(stats->cpuTimerFreq)
				, (stats->gpuTimeEnd - stats->gpuTimeBegin) / double(stats->gpuTimerFreq));
}

void Director::handleSDLEvent(const SDL_Event& event)
{
	switch (event.type)
	{
		case SDL_QUIT:
			break;
		default:
			break;
	}
}

NS_DOROTHY_END
