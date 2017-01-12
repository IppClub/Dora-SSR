/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Director.h"
#include "bx/timer.h"

NS_DOROTHY_BEGIN

Director::Director():
_scheduler(Scheduler::create()),
_systemScheduler(Scheduler::create()),
_entryStack(Array::create())
{ }

bool Director::init()
{
	bgfx::reset(SharedApplication.getWidth(), SharedApplication.getHeight(), BGFX_RESET_VSYNC);
	bgfx::setDebug(BGFX_DEBUG_TEXT);
	bgfx::setViewClear(0,
		BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH,
		0x303030ff, 1.0f, 0);
	SharedLueEngine.executeScriptFile("Script/main.lua");
	return true;
}

void Director::setScheduler(Scheduler* scheduler)
{
	_scheduler = scheduler ? scheduler : Scheduler::create();
}

Scheduler* Director::getScheduler() const
{
	return _scheduler;
}

Scheduler* Director::getSystemScheduler() const
{
	return _systemScheduler;
}

double Director::getDeltaTime() const
{
	// only accept frames drop to 30 FPS
	return std::min(SharedApplication.getDeltaTime(), 1.0/30);
}

Array* Director::getEntries() const
{
	return _entryStack;
}

Node* Director::getCurrentEntry() const
{
	return _entryStack->isEmpty() ? nullptr : _entryStack->getLast().to<Node>();
}

void Director::mainLoop()
{
	SharedView.update();
	bgfx::setViewRect(0, 0, 0, bgfx::BackbufferRatio::Equal);
	bgfx::touch(0);
	bgfx::dbgTextClear();
	const bgfx::Stats* stats = bgfx::getStats();
	bgfx::dbgTextPrintf(0, 1, 0x0f, "Backbuffer %dW x %dH in pixels, debug text %dW x %dH in characters."
			, stats->width
			, stats->height
			, stats->textWidth
			, stats->textHeight);
	bgfx::dbgTextPrintf(0, 3, 0x0f, "Compute %d, Draw %d, CPU Time %.3f/%.3f, GPU Time %.3f, MultiThreaded %s"
			, stats->numCompute
			, stats->numDraw
			, SharedApplication.getCPUTime()
			, SharedApplication.getDeltaTime()
			, (std::max(stats->gpuTimeEnd, stats->gpuTimeBegin) - std::min(stats->gpuTimeEnd, stats->gpuTimeBegin)) / double(stats->gpuTimerFreq)
			, (bgfx::getCaps()->supported & BGFX_CAPS_RENDERER_MULTITHREADED) ? "true" : "false");

	_systemScheduler->update(SharedApplication.getDeltaTime());
	_scheduler->update(SharedApplication.getDeltaTime());
	if (!_entryStack->isEmpty())
	{
		Node* currentEntry = _entryStack->getLast().to<Node>();
		currentEntry->visit();
	}
}

void Director::setEntry(Node* entry)
{
	_entryStack->removeIf([entry](const Ref<>& item)
	{
		return item == entry;
	});
	pushEntry(entry);
}

void Director::pushEntry(Node* entry)
{
	if (!_entryStack->isEmpty())
	{
		if (entry == _entryStack->getLast())
		{
			Log("target entry pushed is already running!");
			return;
		}
		Node* last = _entryStack->getLast().to<Node>();
		last->onExit();
	}
	_entryStack->add(entry);
	entry->onEnter();
}

Ref<Node> Director::popEntry()
{
	if (_entryStack->isEmpty())
	{
		Log("pop from an empty entry stack.");
		return Ref<Node>();
	}
	Ref<Node> last(_entryStack->removeLast().to<Node>());
	last->onExit();
	if (!_entryStack->contains(last))
	{
		last->cleanup();
	}
	if (!_entryStack->isEmpty())
	{
		Node* current = _entryStack->getLast().to<Node>();
		current->onEnter();
	}
	return last;
}

void Director::popToEntry(Node* entry)
{
	if (_entryStack->isEmpty())
	{
		Log("pop from an empty entry stack.");
		return;
	}
	if (_entryStack->contains(entry))
	{
		while (_entryStack->getLast() != entry)
		{
			popEntry();
		}
		return;
	}
	Log("entry to pop is not in entry stack.");
}

void Director::popToRootEntry()
{
	if (_entryStack->isEmpty())
	{
		Log("pop from an empty entry stack.");
		return;
	}
	popToEntry(_entryStack->getFirst().to<Node>());
}

void Director::swapEntry(Node* entryA, Node* entryB)
{
	AssertUnless(_entryStack->contains(entryA) && _entryStack->contains(entryB), "entry to swap is not in entry stack.");
	Node* currentEntry = getCurrentEntry();
	Node* entryToEnter = nullptr;
	Node* entryToExit = nullptr;
	if (entryA == currentEntry)
	{
		entryToEnter = entryB;
		entryToExit = entryA;
	}
	if (entryB == currentEntry)
	{
		entryToEnter = entryA;
		entryToExit = entryB;
	}
	_entryStack->swap(entryA, entryB);
	if (entryToExit) entryToExit->onExit();
	if (entryToEnter) entryToEnter->onEnter();
}

void Director::clearEntry()
{
	while (!_entryStack->isEmpty())
	{
		popEntry();
	}
}

void Director::handleSDLEvent(const SDL_Event& event)
{
	switch (event.type)
	{
		// User-requested quit
		case SDL_QUIT:
			Event::send("AppQuit"_slice);
			clearEntry();
			break;
		// The application is being terminated by the OS.
		case SDL_APP_TERMINATING:
			Event::send("AppQuit"_slice);
			break;
		// The application is low on memory, free memory if possible.
		case SDL_APP_LOWMEMORY:
			Event::send("AppLowMemory"_slice);
			break;
		// The application is about to enter the background.
		case SDL_APP_WILLENTERBACKGROUND:
			Event::send("AppWillEnterBackground"_slice);
			break;
		case SDL_APP_DIDENTERBACKGROUND:
			Event::send("AppDidEnterBackground"_slice);
			break;
		case SDL_APP_WILLENTERFOREGROUND:
			Event::send("AppWillEnterForeground"_slice);
			break;
		case SDL_APP_DIDENTERFOREGROUND:
			Event::send("AppDidEnterForeground"_slice);
			break;
		case SDL_WINDOWEVENT:
			break;
		case SDL_SYSWMEVENT:
			break;
		case SDL_KEYDOWN:
			break;
		case SDL_KEYUP:
			break;
		case SDL_TEXTEDITING:
			break;
		case SDL_TEXTINPUT:
			break;
		case SDL_KEYMAPCHANGED:
			break;
		case SDL_MOUSEMOTION:
			break;
		case SDL_MOUSEBUTTONDOWN:
			break;
		case SDL_MOUSEBUTTONUP:
			break;
		case SDL_MOUSEWHEEL:
			break;
		case SDL_JOYAXISMOTION:
			break;
		case SDL_JOYBALLMOTION:
			break;
		case SDL_JOYHATMOTION:
			break;
		case SDL_JOYBUTTONDOWN:
			break;
		case SDL_JOYBUTTONUP:
			break;
		case SDL_JOYDEVICEADDED:
			break;
		case SDL_JOYDEVICEREMOVED:
			break;
		case SDL_CONTROLLERAXISMOTION:
			break;
		case SDL_CONTROLLERBUTTONDOWN:
			break;
		case SDL_CONTROLLERBUTTONUP:
			break;
		case SDL_CONTROLLERDEVICEADDED:
			break;
		case SDL_CONTROLLERDEVICEREMOVED:
			break;
		case SDL_CONTROLLERDEVICEREMAPPED:
			break;
		case SDL_FINGERDOWN:
			break;
		case SDL_FINGERUP:
			break;
		case SDL_FINGERMOTION:
			break;
		case SDL_DOLLARGESTURE:
			break;
		case SDL_DOLLARRECORD:
			break;
		case SDL_MULTIGESTURE:
			break;
		case SDL_CLIPBOARDUPDATE:
			break;
		case SDL_DROPFILE:
			break;
		case SDL_DROPTEXT:
			break;
		case SDL_DROPBEGIN:
			break;
		case SDL_DROPCOMPLETE:
			break;
		case SDL_AUDIODEVICEADDED:
			break;
		case SDL_AUDIODEVICEREMOVED:
			break;
		default:
			break;
	}
}

NS_DOROTHY_END
