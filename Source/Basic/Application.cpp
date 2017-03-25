/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Application.h"
#include "Basic/AutoreleasePool.h"
#include "Basic/Director.h"
#include "bx/timer.h"

#if BX_PLATFORM_ANDROID
#include <jni.h>
extern "C" ANativeWindow* Android_JNI_GetNativeWindow();
#endif // BX_PLATFORM_ANDROID

NS_DOROTHY_BEGIN

bool BGFXDora::init()
{
	return bgfx::init();
}

BGFXDora::~BGFXDora()
{
	bgfx::shutdown();
}

Application::Application():
_frame(0),
_width(800),
_height(600),
_maxFPS(60),
_minFPS(30),
_deltaTime(0),
_cpuTime(0),
_totalTime(0),
_frequency(double(bx::getHPFrequency())),
_sdlWindow(nullptr)
{
	_lastTime = bx::getHPCounter() / _frequency;
}

int Application::getWidth() const
{
	return _width;
}

int Application::getHeight() const
{
	return _height;
}

void Application::setSeed(Uint32 var)
{
	_seed = var;
	std::srand(var);
}

Uint32 Application::getSeed() const
{
	return _seed;
}

void Application::setMaxFPS(Uint32 var)
{
	_maxFPS = var;
}

Uint32 Application::getMaxFPS() const
{
	return _maxFPS;
}

void Application::setMinFPS(Uint32 var)
{
	_minFPS = var;
}

Uint32 Application::getMinFPS() const
{
	return _minFPS;
}

Uint32 Application::getFrame() const
{
	return _frame;
}

SDL_Window* Application::getSDLWindow() const
{
	return _sdlWindow;
}

// This function runs in main thread, and do render work
int Application::run()
{
	Application::setSeed((unsigned int)std::time(nullptr));

	if (SDL_Init(SDL_INIT_GAMECONTROLLER|SDL_INIT_TIMER) != 0)
	{
		Log("SDL fail to initialize! %s", SDL_GetError());
		return 1;
	}

	Uint32 windowFlags = SDL_WINDOW_SHOWN | SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_INPUT_FOCUS | SDL_WINDOW_RESIZABLE;
#if BX_PLATFORM_IOS || BX_PLATFORM_ANDROID
	windowFlags |= SDL_WINDOW_FULLSCREEN;
#endif

	_sdlWindow = SDL_CreateWindow("Dorothy-SSR",
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
		_width, _height, windowFlags);
	if (!_sdlWindow)
	{
		Log("SDL fail to create window!");
		return 1;
	}

	Application::setupSdlWindow();

	// call this function here to disable default render threads creation of bgfx
	Application::renderFrame();

	// start running logic thread
	_logicThread.init(Application::mainLogic, this);

	SDL_Event event;
	bool running = true;
	while (running)
	{
		// handle SDL event in this main thread only
		while (SDL_PollEvent(&event))
		{
			switch (event.type)
			{
			case SDL_QUIT:
				running = false;
				break;
			case SDL_WINDOWEVENT:
			{
				switch (event.window.event)
				{
					case SDL_WINDOWEVENT_RESIZED:
					case SDL_WINDOWEVENT_SIZE_CHANGED:
#if BX_PLATFORM_ANDROID
						bgfx::PlatformData pd{};
						pd.nwh = Android_JNI_GetNativeWindow();
						bgfx::setPlatformData(pd);
#endif // BX_PLATFORM_ANDROID
						updateWindowSize();
						break;
				}
				break;
			}
			default:
				break;
			}
			_logicEvent.post("SDLEvent", event);
		}

		// poll events from logic thread
		for (Own<QEvent> event = _renderEvent.poll();
			event != nullptr;
			event = _renderEvent.poll())
		{
			switch (Switch::hash(event->getName()))
			{
				case "Quit"_hash:
				{
					SDL_Event ev;
					ev.quit.type = SDL_QUIT;
					SDL_PushEvent(&ev);
					break;
				}
				case "Invoke"_hash:
				{
					function<void()> func;
					event->get(func);
					func();
					break;
				}
				default:
					break;
			}
		}

		// do render staff and swap buffers
		Application::renderFrame();
	}

	// wait for render process to stop
	while (bgfx::RenderFrame::NoContext != Application::renderFrame());
	_logicThread.shutdown();

	SDL_DestroyWindow(_sdlWindow);
	SDL_Quit();

	return _logicThread.getExitCode();
}

void Application::updateDeltaTime()
{
	double currentTime = bx::getHPCounter() / _frequency;
	_deltaTime = currentTime - _lastTime;
	// in case of system timer api error
	if (_deltaTime < 0)
	{
		_deltaTime = 0;
		_lastTime = currentTime;
	}
}

#if BX_PLATFORM_ANDROID || BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS
void Application::updateWindowSize()
{
	SDL_GL_GetDrawableSize(_sdlWindow, &_width, &_height);
}
#endif // BX_PLATFORM_ANDROID || BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS

double Application::getEclapsedTime() const
{
	double currentTime = bx::getHPCounter() / _frequency;
	return std::max(currentTime - _lastTime, 0.0);
}

double Application::getLastTime() const
{
	return _lastTime;
}

double Application::getDeltaTime() const
{
	return _deltaTime;
}

double Application::getCPUTime() const
{
	return _cpuTime;
}

double Application::getTotalTime() const
{
	return _totalTime;
}

void Application::makeTimeNow()
{
	_totalTime += _deltaTime;
	_lastTime = bx::getHPCounter() / _frequency;
}

void Application::shutdown()
{
	_renderEvent.post("Quit"_slice);
}

void Application::invokeInRender(const function<void()>& func)
{
	_renderEvent.post("Invoke"_slice, func);
}

void Application::invokeInLogic(const function<void()>& func)
{
	_logicEvent.post("Invoke"_slice, func);
}

int Application::mainLogic(void* userData)
{
	Application* app = r_cast<Application*>(userData);
	
	if (!SharedBGFX.init())
	{
		Log("bgfx fail to initialize!");
		return 1;
	}

	SharedPoolManager.push();
	if (!SharedDirector.init())
	{
		Log("Director fail to initialize!");
		return 1;
	}

	SharedPoolManager.pop();

	app->_frame = bgfx::frame();

	// Update and invoke render apis
	app->updateDeltaTime();
	bool running = true;
	while (running)
	{
		SharedPoolManager.push();
		// poll events from render thread
		for (Own<QEvent> event = app->_logicEvent.poll();
			event != nullptr;
			event = app->_logicEvent.poll())
		{
			switch (Switch::hash(event->getName()))
			{
				case "SDLEvent"_hash:
				{
					SDL_Event sdlEvent;
					event->get(sdlEvent);
					switch (sdlEvent.type)
					{
						case SDL_QUIT:
							running = false;
							break;
						default:
							break;
					}
					SharedDirector.handleSDLEvent(sdlEvent);
					app->eventHandler(sdlEvent);
					break;
				}
				case "Invoke"_hash:
				{
					function<void()> func;
					event->get(func);
					func();
					break;
				}
				default:
					break;
			}
		}
		SharedDirector.mainLoop();
		SharedPoolManager.pop();

		app->_cpuTime = app->getEclapsedTime();

		// Advance to next frame. Rendering thread will be kicked to
		// process submitted rendering primitives.
		app->_frame = bgfx::frame();

		// limit for max FPS
		do {
			app->updateDeltaTime();
		} while (app->getDeltaTime() < 1.0/app->_maxFPS);
		app->makeTimeNow();
	}

	SharedPoolManager.push();
	Life::destroy("BGFXDora");
	SharedPoolManager.pop();
	return 0;
}

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID
bgfx::RenderFrame::Enum Application::renderFrame()
{
	return bgfx::renderFrame();
}
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID

const Slice Application::getPlatform() const
{
#if BX_PLATFORM_WINDOWS
	return "Windows"_slice;
#elif BX_PLATFORM_ANDROID
	return "Android"_slice;
#elif BX_PLATFORM_OSX
	return "macOS"_slice;
#elif BX_PLATFORM_IOS
	return "iOS"_slice;
#else
	return "Unknown"_slice;
#endif
}

#if BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID
void Application::setupSdlWindow()
{
	SDL_SysWMinfo wmi;
	SDL_VERSION(&wmi.version);
	SDL_GetWindowWMInfo(_sdlWindow, &wmi);
	bgfx::PlatformData pd{};
#if BX_PLATFORM_OSX
	pd.nwh = wmi.info.cocoa.window;
#elif BX_PLATFORM_WINDOWS
	pd.nwh = wmi.info.win.window;
#elif BX_PLATFORM_ANDROID
	pd.nwh = wmi.info.android.window;
#endif
	bgfx::setPlatformData(pd);
	updateWindowSize();
}
#endif // BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID

NS_DOROTHY_END

// Entry functions needed by SDL2
#if BX_PLATFORM_OSX || BX_PLATFORM_ANDROID || BX_PLATFORM_IOS
int main(int argc, char *argv[])
{
	return SharedApplication.run();
}
#endif // BX_PLATFORM_OSX || BX_PLATFORM_ANDROID || BX_PLATFORM_IOS

#if BX_PLATFORM_WINDOWS

#if DORA_DEBUG

#include "Common/Async.h"

NS_DOROTHY_BEGIN

class Console
{
public:
	~Console()
	{
		system("pause");
		FreeConsole();
	}
	inline void init()
	{
		AllocConsole();
		freopen("CONIN$", "r", stdin);
		freopen("CONOUT$", "w", stdout);
		freopen("CONOUT$", "w", stderr);
	}
	SINGLETON_REF(Console);
	SINGLETON_REF(AsyncLogThread, Console);
};
#define SharedConsole \
	Dorothy::Singleton<Dorothy::Console>::shared()

NS_DOROTHY_END
#endif // DORA_DEBUG

int CALLBACK WinMain(
	_In_ HINSTANCE hInstance,
	_In_ HINSTANCE hPrevInstance,
	_In_ LPSTR lpCmdLine,
	_In_ int nCmdShow)
{
#if DORA_DEBUG
	SharedConsole.init();
#endif
	return SharedApplication.run();
}
#endif // BX_PLATFORM_WINDOWS
