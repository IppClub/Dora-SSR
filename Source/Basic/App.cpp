//
//  App.cpp
//  Dorothy
//
//  Created by Li Jin on 2016/12/7.
//  Copyright © 2016年 Dorothy. All rights reserved.
//

#include "Const/Header.h"
#include "App.h"
#include "bx/timer.h"

#include <iostream>
using std::cout;

NS_DOROTHY_BEGIN

int App::winWidth = 800;
int App::winHeight = 600;
bool App::running = true;

// This function runs in main thread, and do render work
int App::run()
{
	SDL_Init(SDL_INIT_EVENTS);

	Uint32 windowFlags = SDL_WINDOW_SHOWN | SDL_WINDOW_ALLOW_HIGHDPI;
#if BX_PLATFORM_IOS || BX_PLATFORM_ANDROID
	windowFlags |= SDL_WINDOW_FULLSCREEN;
#endif

	SDL_Window* window = SDL_CreateWindow("Study BGFX & SDL",
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
		winWidth, winHeight, windowFlags);

	setSdlWindow(window);

	bgfx::renderFrame();

	bx::Thread thread;
	thread.init(App::mainLogic);

	SDL_Event event;
	while (running)
	{
		// do render staff and swap buffers
		bgfx::renderFrame();
		// handle SDL event in this main thread only
		while(SDL_PollEvent(&event))
		{
			switch (event.type)
			{
			case SDL_QUIT:
    			running = false;
    			break;
			default:
				break;
			}
		}
	}

	// wait for render process to stop
	while (bgfx::RenderFrame::NoContext != bgfx::renderFrame());
	thread.shutdown();

	SDL_DestroyWindow(window);
	SDL_Quit();

	return thread.getExitCode();
}

void App::setSdlWindow(SDL_Window* window)
{
	SDL_SysWMinfo wmi;
	SDL_VERSION(&wmi.version);
	SDL_GetWindowWMInfo(window, &wmi);

	bgfx::PlatformData pd;
#if BX_PLATFORM_OSX
	pd.ndt = NULL;
	pd.nwh = wmi.info.cocoa.window;
#elif BX_PLATFORM_WINDOWS
	pd.ndt = NULL;
	pd.nwh = wmi.info.win.window;
#elif BX_PLATFORM_ANDROID
	pd.ndt = NULL;
	pd.nwh = wmi.info.android.window;
	SDL_GL_GetDrawableSize(window, &winWidth, &winHeight);
#endif
	pd.context = NULL;
	pd.backBuffer = NULL;
	pd.backBufferDS = NULL;
	bgfx::setPlatformData(pd);
}

double App::getDeltaTime()
{
	int64_t now = bx::getHPCounter();
	static int64_t last = now;
	const int64_t frameTime = now - last;
	last = now;
	const int64_t freq = bx::getHPFrequency();
	const double seconds = frameTime/double(freq);
	return seconds;
}

struct Visitor
{
	template<typename T>
	void operator()(const T& element)
	{
		cout << element << "\n";
	}
	void operator()(const char* element)
	{
		cout << element << "\n";
	}
};

int App::mainLogic(void* userData)
{
	// Initialization
	bgfx::init();
	bgfx::reset(winWidth, winHeight, BGFX_RESET_VSYNC);
	bgfx::setDebug(BGFX_DEBUG_TEXT);
	bgfx::setViewClear(0,
		BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH,
		0x303030ff, 1.0f, 0);
	bgfx::frame();

	SharedPoolManager.push();

	// I have a tuple
	auto item = ::std::make_tuple(998, 233, "a pen");

	// Em, start iteration
	TupleForeach(item, Visitor());
	TupleForeach(std::tuple<>(), Visitor());

	Event::addListener("test", [](Event* event)
	{
		Slice msg;
		Event::retrieve(event, msg);
		Log("Event!!! %s", msg);
	});

	//Event::send("test", Slice("info1"));
	//Event::send("test", Slice("msg2"));

	Event::addListener("UserEvent", [](Event* event)
	{
		Log("Recieve user event from Lua!");
	});
	SharedLueEngine.executeScriptFile("Script/main");

	SharedPoolManager.pop();

	// Update and invoke render apis
	double deltaTime = 0;
	while (running)
	{
		deltaTime += getDeltaTime();
		if (deltaTime < 1.0/60)
		{
			continue;
		}
		else
		{
			deltaTime = 0;
		}

		SharedPoolManager.push();
		bgfx::setViewRect(0, 0, 0, winWidth, winHeight);

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

		// Advance to next frame. Rendering thread will be kicked to
		// process submitted rendering primitives.
		bgfx::frame();
		SharedPoolManager.pop();
	}

	// Shut down frameworks
	bgfx::shutdown();
	SDL_Event event;
	SDL_QuitEvent& qev = event.quit;
	qev.type = SDL_QUIT;
	SDL_PushEvent(&event);
	return 0;
}

NS_DOROTHY_END

// Entry functions needed by SDL2
#if BX_PLATFORM_OSX || BX_PLATFORM_ANDROID
int main(int argc, char *argv[])
{
	Dorothy::App app;
	return app.run();
}
#elif BX_PLATFORM_WINDOWS
int CALLBACK WinMain(
	_In_ HINSTANCE hInstance,
	_In_ HINSTANCE hPrevInstance,
	_In_ LPSTR lpCmdLine,
	_In_ int nCmdShow)
{
#ifndef NDEBUG
	AllocConsole();
	freopen("CONIN$", "r", stdin);
	freopen("CONOUT$", "w", stdout);
	freopen("CONOUT$", "w", stderr);
#endif

	Dorothy::App app;
	int result = app.run();

#ifndef NDEBUG
	FreeConsole();
#endif

	return result;
}
#endif // BX_PLATFORM_
