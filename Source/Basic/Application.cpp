/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Application.h"
#include "Basic/AutoreleasePool.h"
#include "Basic/Director.h"
#include "Basic/View.h"
#include "Basic/Scheduler.h"
#include "bx/timer.h"
#include <ctime>
#include "Other/utf8.h"

#if BX_PLATFORM_ANDROID
#include <jni.h>
static string g_androidAPKPath;
extern "C" {
	JNIEXPORT void JNICALL Java_com_luvfight_dorothy_MainActivity_nativeSetPath(JNIEnv* env, jclass cls, jstring apkPath)
	{
		const char* pathString = env->GetStringUTFChars(apkPath, NULL);
		g_androidAPKPath = pathString;
		env->ReleaseStringUTFChars(apkPath, pathString);
	}
}
static float g_androidScreenDensity;
extern "C" {
	JNIEXPORT void JNICALL Java_com_luvfight_dorothy_MainActivity_nativeSetScreenDensity(JNIEnv* env, jclass cls, jfloat screenDensity)
	{
		g_androidScreenDensity = s_cast<float>(screenDensity);
	}
}
extern "C" ANativeWindow* Android_JNI_GetNativeWindow();
#endif // BX_PLATFORM_ANDROID

#if BX_PLATFORM_WINDOWS
#define DEFAULT_WIN_DPI 96
#endif // BX_PLATFORM_WINDOWS

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
_seed(0),
_fpsLimited(false),
_frame(0),
_visualWidth(1024),
_visualHeight(768),
_winWidth(_visualWidth),
_winHeight(_visualHeight),
_bufferWidth(0),
_bufferHeight(0),
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

Size Application::getBufferSize() const
{
	return Size{s_cast<float>(_bufferWidth), s_cast<float>(_bufferHeight)};
}

Size Application::getVisualSize() const
{
	return Size{s_cast<float>(_visualWidth), s_cast<float>(_visualHeight)};
}

Size Application::getWinSize() const
{
	return Size{s_cast<float>(_winWidth), s_cast<float>(_winHeight)};
}

float Application::getDeviceRatio() const
{
	return s_cast<float>(_bufferWidth) / _visualWidth;
}

void Application::setSeed(Uint32 var)
{
	_seed = var;
	_randomEngine.seed(var);
}

Uint32 Application::getSeed() const
{
	return _seed;
}

Uint32 Application::getRand()
{
	return _randomEngine();
}

Uint32 Application::getRandMin() const
{
	return std::mt19937::min();
}

Uint32 Application::getRandMax() const
{
	return std::mt19937::max();
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

void Application::setFPSLimited(bool var)
{
	_fpsLimited = var;
}

bool Application::isFPSLimited() const
{
	return _fpsLimited;
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
	Application::setSeed(s_cast<Uint32>(std::time(nullptr)));

	if (SDL_Init(SDL_INIT_GAMECONTROLLER|SDL_INIT_TIMER) != 0)
	{
		Error("SDL failed to initialize! {}", SDL_GetError());
		return 1;
	}

	Uint32 windowFlags = SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_INPUT_FOCUS | SDL_WINDOW_RESIZABLE;
#if BX_PLATFORM_WINDOWS
	windowFlags |= SDL_WINDOW_HIDDEN;
#elif BX_PLATFORM_IOS || BX_PLATFORM_ANDROID
	windowFlags |= SDL_WINDOW_FULLSCREEN;
#endif
	_sdlWindow = SDL_CreateWindow("Dorothy SSR",
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
		_winWidth, _winHeight, windowFlags);
	if (!_sdlWindow)
	{
		Error("SDL failed to create window!");
		return 1;
	}
	Application::setupSdlWindow();
#if BX_PLATFORM_OSX
	SDL_HideWindow(_sdlWindow);
#endif

	// call this function here to disable default render threads creation of bgfx
	bgfx::renderFrame();

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
#if BX_PLATFORM_ANDROID || BX_PLATFORM_IOS
			case SDL_TEXTEDITING:
			{
				event.edit.start = utf8_count_characters(event.edit.text);
				break;
			}
#endif // BX_PLATFORM_ANDROID || BX_PLATFORM_IOS
			default:
				break;
			}
			_logicEvent.post("SDLEvent"_slice, event);
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
		bgfx::renderFrame();
	}

	// wait for render process to stop
	while (bgfx::RenderFrame::NoContext != bgfx::renderFrame());
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
	SDL_GL_GetDrawableSize(_sdlWindow, &_bufferWidth, &_bufferHeight);
	SDL_GetWindowSize(_sdlWindow, &_winWidth, &_winHeight);
#if BX_PLATFORM_WINDOWS
	float hdpi = DEFAULT_WIN_DPI, vdpi = DEFAULT_WIN_DPI;
	SDL_GetDisplayDPI(0, nullptr, &hdpi, &vdpi);
	_visualWidth = MulDiv(_winWidth, DEFAULT_WIN_DPI, s_cast<int>(hdpi));
	_visualHeight = MulDiv(_winHeight, DEFAULT_WIN_DPI, s_cast<int>(vdpi));
#elif BX_PLATFORM_ANDROID
	_visualWidth = s_cast<int>(_winWidth / g_androidScreenDensity);
	_visualHeight = s_cast<int>(_winHeight / g_androidScreenDensity);
#else
	_visualWidth = _winWidth;
	_visualHeight = _winHeight;
#endif // BX_PLATFORM_WINDOWS
}
#endif // BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS

#if BX_PLATFORM_ANDROID
const string& Application::getAPKPath() const
{
	return g_androidAPKPath;
}
#endif // BX_PLATFORM_ANDROID

double Application::getEclapsedTime() const
{
	double currentTime = bx::getHPCounter() / _frequency;
	return std::max(currentTime - _lastTime, 0.0);
}

double Application::getCurrentTime() const
{
	return bx::getHPCounter() / _frequency;
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
	switch (Switch::hash(getPlatform()))
	{
		case "Windows"_hash:
		case "macOS"_hash:
			_renderEvent.post("Quit"_slice);
			break;
	}
}

void Application::invokeInRender(const function<void()>& func)
{
	_renderEvent.post("Invoke"_slice, func);
}

void Application::invokeInLogic(const function<void()>& func)
{
	_logicEvent.post("Invoke"_slice, func);
}

int Application::mainLogic(bx::Thread* thread, void* userData)
{
	DORA_UNUSED_PARAM(thread);
	Application* app = r_cast<Application*>(userData);

	if (!SharedBGFX.init())
	{
		Error("bgfx failed to initialize!");
		return 1;
	}

	// pass one frame
	SharedView.pushName("Main"_slice, [](){});
	app->_frame = bgfx::frame();
	app->updateDeltaTime();
	app->makeTimeNow();

	SharedPoolManager.push();
	if (!SharedDirector.init())
	{
		Error("Director failed to initialize!");
		return 1;
	}
	Timer::create()->start(0, [app]()
	{
		app->invokeInRender([app]()
		{
			SDL_ShowWindow(app->_sdlWindow);
		});
	});
	SharedPoolManager.pop();

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
						{
							running = false;
							app->quitHandler();
							// Info("singleton reference tree:\n{}", Life::getRefTree());
							break;
						}
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

		// advance to next frame. rendering thread will be kicked to
		// process submitted rendering primitives.
		app->_frame = bgfx::frame();

		// limit for max FPS
		if (app->_fpsLimited)
		{
			do
			{
				app->updateDeltaTime();
			}
			while (app->getDeltaTime() < 1.0/app->_maxFPS);
		}
		else app->updateDeltaTime();
		app->makeTimeNow();
	}

	Life::destroy("BGFXDora"_slice);
	return 0;
}

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
#endif // BX_PLATFORM
#if BX_PLATFORM_WINDOWS
	float hdpi = DEFAULT_WIN_DPI, vdpi = DEFAULT_WIN_DPI;
	SDL_GetDisplayDPI(0, nullptr, &hdpi, &vdpi);
	SDL_DisplayMode displayMode{};
	SDL_GetCurrentDisplayMode(0, &displayMode);
	int screenWidth = MulDiv(displayMode.w, DEFAULT_WIN_DPI, s_cast<int>(hdpi));
	int screenHeight = MulDiv(displayMode.h, DEFAULT_WIN_DPI, s_cast<int>(vdpi));
	_visualWidth = Math::clamp(_visualWidth, 0, screenWidth);
	_visualHeight = Math::clamp(_visualHeight, 0, screenHeight);
	if (hdpi != DEFAULT_WIN_DPI || vdpi != DEFAULT_WIN_DPI)
	{
		_winWidth = MulDiv(_visualWidth, s_cast<int>(hdpi), DEFAULT_WIN_DPI);
		_winHeight = MulDiv(_visualHeight, s_cast<int>(vdpi), DEFAULT_WIN_DPI);
		SDL_SetWindowSize(_sdlWindow, _winWidth, _winHeight);
		SDL_SetWindowPosition(_sdlWindow, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
	}
#endif // BX_PLATFORM_WINDOWS
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
		exit(0); // or FreeConsole();
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
