/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Application.h"

#include "Basic/AutoreleasePool.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Basic/View.h"
#include "Common/Async.h"
#include "Input/Controller.h"
#include "Physics/PhysicsWorld.h"

#include "Other/utf8.h"

#include "SDL.h"
#include "SDL_syswm.h"
#include "bx/timer.h"

#include <chrono>
#include <ctime>
#include <thread>

#define DORA_VERSION "1.3.4"_slice

#if BX_PLATFORM_ANDROID
#include <jni.h>
static std::string g_androidAPKPath;
extern "C" {
JNIEXPORT void JNICALL Java_org_ippclub_dorassr_MainActivity_nativeSetPath(JNIEnv* env, jclass cls, jstring apkPath) {
	const char* pathString = env->GetStringUTFChars(apkPath, NULL);
	g_androidAPKPath = pathString;
	env->ReleaseStringUTFChars(apkPath, pathString);
}
}
static float g_androidScreenDensity;
extern "C" {
JNIEXPORT void JNICALL Java_org_ippclub_dorassr_MainActivity_nativeSetScreenDensity(JNIEnv* env, jclass cls, jfloat screenDensity) {
	g_androidScreenDensity = s_cast<float>(screenDensity);
}
}
extern "C" ANativeWindow* Android_JNI_GetNativeWindow();
#endif // BX_PLATFORM_ANDROID

#if BX_PLATFORM_WINDOWS
#define DEFAULT_WIN_DPI 96
#endif // BX_PLATFORM_WINDOWS

NS_DORA_BEGIN

bool BGFXDora::init(const bgfx::PlatformData& data) {
	bgfx::Init init{};
	bx::memCopy(&init.platformData, &data, sizeof(bgfx::PlatformData));
	return bgfx::init(init);
}

BGFXDora::~BGFXDora() {
	bgfx::shutdown();
}

Application::Application()
	: _seed(0)
	, _idled(false)
	, _fpsLimited(true)
	, _renderRunning(true)
	, _logicRunning(true)
	, _frame(0)
	, _visualWidth(1280)
	, _visualHeight(720)
	, _winWidth(_visualWidth)
	, _winHeight(_visualHeight)
	, _bufferWidth(0)
	, _bufferHeight(0)
	, _targetFPS(60)
	, _maxFPS(60)
	, _deltaTime(0)
	, _cpuTime(0)
	, _totalTime(0)
	, _frequency(double(bx::getHPFrequency()))
	, _sdlWindow(nullptr)
	, _themeColor(0xfffac03d)
	, _winPosition{s_cast<float>(SDL_WINDOWPOS_CENTERED), s_cast<float>(SDL_WINDOWPOS_CENTERED)}
	, _platformData{} {
	_lastTime = bx::getHPCounter() / _frequency;
#if !BX_PLATFORM_LINUX
	auto locale = SDL_GetPreferredLocales();
	_locale = locale->language;
	SDL_free(locale);
#else
	_locale = "en"s;
#endif
}

const std::string& Application::getLocale() const {
	return _locale;
}

void Application::setLocale(String var) {
	_locale = var.toString();
	Event::send("AppLocale"_slice, _locale);
}

Size Application::getBufferSize() const {
	return Size{s_cast<float>(_bufferWidth), s_cast<float>(_bufferHeight)};
}

Size Application::getVisualSize() const {
	return Size{s_cast<float>(_visualWidth), s_cast<float>(_visualHeight)};
}

float Application::getDevicePixelRatio() const {
	return s_cast<float>(_bufferWidth) / _visualWidth;
}

void Application::setThemeColor(Color var) {
	_themeColor = var;
	Event::send("AppTheme", _themeColor.toARGB());
}

Color Application::getThemeColor() const {
	return _themeColor;
}

void Application::setSeed(uint32_t var) {
	_seed = var;
	_randomEngine.seed(var);
}

uint32_t Application::getSeed() const {
	return _seed;
}

uint32_t Application::getRand() {
	return _randomEngine();
}

uint32_t Application::getRandMin() const {
	return std::mt19937::min();
}

uint32_t Application::getRandMax() const {
	return std::mt19937::max();
}

void Application::setTargetFPS(uint32_t var) {
	_targetFPS = var;
}

uint32_t Application::getTargetFPS() const {
	return _targetFPS;
}

uint32_t Application::getMaxFPS() const {
	return _maxFPS;
}

void Application::setIdled(bool var) {
	_idled = var;
}

bool Application::isIdled() const {
	return _idled;
}

void Application::setFPSLimited(bool var) {
	_fpsLimited = var;
}

bool Application::isFPSLimited() const {
	return _fpsLimited;
}

void Application::setWinSize(Size var) {
	AssertIf(getPlatform() == "iOS"_slice || getPlatform() == "Android"_slice,
		"changing window size is not available on {}.", getPlatform().toString());
	if (var == Size::zero) {
		invokeInRender([&]() {
			SDL_SetWindowFullscreen(_sdlWindow, SDL_WINDOW_FULLSCREEN_DESKTOP);
		});
		Event::send("AppFullScreen"_slice, true);
	} else {
		invokeInRender([&, var]() {
			SDL_SetWindowFullscreen(_sdlWindow, 0);
			SDL_SetWindowSize(_sdlWindow, s_cast<int>(var.width), s_cast<int>(var.height));
			SDL_SetWindowPosition(_sdlWindow, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
		});
		_winPosition = {s_cast<float>(SDL_WINDOWPOS_CENTERED), s_cast<float>(SDL_WINDOWPOS_CENTERED)};
		Event::send("AppMoved"_slice);
		Event::send("AppFullScreen"_slice, false);
	}
}

Size Application::getWinSize() const {
	return Size{s_cast<float>(_winWidth), s_cast<float>(_winHeight)};
}

void Application::setWinPosition(const Vec2& var) {
	AssertIf(getPlatform() == "iOS"_slice || getPlatform() == "Android"_slice,
		"changing window position is not available on {}.", getPlatform().toString());
	_winPosition = var;
	invokeInRender([&, var]() {
		SDL_SetWindowFullscreen(_sdlWindow, 0);
		SDL_SetWindowPosition(_sdlWindow, s_cast<int>(var.x), s_cast<int>(var.y));
	});
}

const Vec2& Application::getWinPosition() const {
	return _winPosition;
}

uint32_t Application::getFrame() const {
	return _frame;
}

SDL_Window* Application::getSDLWindow() const {
	return _sdlWindow;
}

bool Application::isRenderRunning() const {
	return _renderRunning;
}

bool Application::isLogicRunning() const {
	return _logicRunning;
}

// This function runs in main (render) thread, and do render work
int Application::run() {
	Application::setSeed(s_cast<uint32_t>(std::time(nullptr)));

	if (SDL_Init(SDL_INIT_GAMECONTROLLER) != 0) {
		Error("SDL failed to initialize! {}", SDL_GetError());
		return 1;
	}

	SharedController.initInRender();

	SDL_SetHint(SDL_HINT_MOUSE_TOUCH_EVENTS, "1");
	SDL_SetHint(SDL_HINT_VIDEO_EXTERNAL_CONTEXT, "1");
	SDL_SetHint(SDL_HINT_IME_SHOW_UI, "1");

	uint32_t windowFlags = SDL_WINDOW_ALLOW_HIGHDPI | SDL_WINDOW_INPUT_FOCUS | SDL_WINDOW_RESIZABLE;
#if BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_LINUX
	windowFlags |= SDL_WINDOW_HIDDEN | SDL_WINDOW_ALWAYS_ON_TOP;
#elif BX_PLATFORM_IOS || BX_PLATFORM_ANDROID
	windowFlags |= SDL_WINDOW_FULLSCREEN | SDL_WINDOW_BORDERLESS;
#endif // BX_PLATFORM

	_sdlWindow = SDL_CreateWindow("Dora SSR",
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
		_winWidth, _winHeight, windowFlags);
	if (!_sdlWindow) {
		Error("SDL failed to create window! {}", SDL_GetError());
		return 1;
	}

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_LINUX
	int displayIndex = SDL_GetWindowDisplayIndex(_sdlWindow);
	SDL_Rect rect;
	if (SDL_GetDisplayBounds(displayIndex, &rect) == 0 && (_winWidth > rect.w || _winHeight > rect.h)) {
		_winWidth = rect.w;
		_winHeight = rect.h;
		SDL_SetWindowSize(_sdlWindow, _winWidth, _winHeight);
	}
#endif // BX_PLATFORM

	Application::setupSdlWindow();

	// call this function here to disable default render threads creation of bgfx
	bgfx::renderFrame();

	// start running logic thread
	_logicThread.init(Application::mainLogic, this);

	SDL_Event event;
	while (_renderRunning) {
		// do render staff and swap buffers
		bgfx::renderFrame();

		// handle SDL event in this main thread only
		while (SDL_PollEvent(&event)) {
			switch (event.type) {
				case SDL_QUIT:
					_renderRunning = false;
					break;
#if BX_PLATFORM_ANDROID
				case SDL_APP_DIDENTERFOREGROUND: {
					bgfx::PlatformData pd{};
					pd.nwh = Android_JNI_GetNativeWindow();
					if (pd.nwh) {
						bgfx::setPlatformData(pd);
					}
					break;
				}
#endif // BX_PLATFORM_ANDROID
				case SDL_WINDOWEVENT: {
					switch (event.window.event) {
						case SDL_WINDOWEVENT_RESIZED:
						case SDL_WINDOWEVENT_SIZE_CHANGED: {
#if BX_PLATFORM_ANDROID
							bgfx::PlatformData pd{};
							pd.nwh = Android_JNI_GetNativeWindow();
							if (pd.nwh) {
								bgfx::setPlatformData(pd);
							}
#endif // BX_PLATFORM_ANDROID
							updateWindowSize();
							break;
						}
						case SDL_WINDOWEVENT_MOVED:
							_winPosition = Vec2{s_cast<float>(event.window.data1), s_cast<float>(event.window.data2)};
							break;
					}
					break;
				}
#if BX_PLATFORM_ANDROID || BX_PLATFORM_IOS
				case SDL_TEXTEDITING: {
					event.edit.start = utf8_count_characters(event.edit.text);
					break;
				}
#endif // BX_PLATFORM_ANDROID || BX_PLATFORM_IOS
				case SDL_CONTROLLERAXISMOTION:
				case SDL_CONTROLLERBUTTONDOWN:
				case SDL_CONTROLLERBUTTONUP:
					SharedController.handleEventInRender(event);
					break;
				default:
					break;
			}
			_logicEvent.post("SDLEvent"_slice, event);
		}

		// poll events from logic thread
		for (Own<QEvent> event = _renderEvent.poll();
			 event != nullptr;
			 event = _renderEvent.poll()) {
			switch (Switch::hash(event->getName())) {
				case "Quit"_hash: {
					SDL_Event ev;
					ev.quit.type = SDL_QUIT;
					SDL_PushEvent(&ev);
					break;
				}
				case "Invoke"_hash: {
					std::function<void()> func;
					event->get(func);
					func();
					break;
				}
				default:
					break;
			}
		}
	}

	// wait for render process to stop
	while (bgfx::RenderFrame::NoContext != bgfx::renderFrame())
		;
	_logicThread.shutdown();

	SDL_DestroyWindow(_sdlWindow);
	SDL_Quit();

	return _logicThread.getExitCode();
}

void Application::updateDeltaTime() {
	double currentTime = getCurrentTime();
	_deltaTime = currentTime - _lastTime;
	// in case of system timer api error
	if (_deltaTime <= 0) {
		_deltaTime = 1.0 / _targetFPS;
		_lastTime = currentTime;
	}
}

#if BX_PLATFORM_ANDROID || BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_LINUX
void Application::updateWindowSize() {
#if BX_PLATFORM_OSX
	SDL_Metal_GetDrawableSize(_sdlWindow, &_bufferWidth, &_bufferHeight);
#else
	SDL_GL_GetDrawableSize(_sdlWindow, &_bufferWidth, &_bufferHeight);
#endif
	SDL_GetWindowSize(_sdlWindow, &_winWidth, &_winHeight);
	int displayIndex = SDL_GetWindowDisplayIndex(_sdlWindow);
	SDL_DisplayMode displayMode{SDL_PIXELFORMAT_UNKNOWN, 0, 0, 0, 0};
	SDL_GetCurrentDisplayMode(displayIndex, &displayMode);
	if (displayMode.refresh_rate > 0) {
		_maxFPS = displayMode.refresh_rate;
	}
#if BX_PLATFORM_WINDOWS
	float hdpi = DEFAULT_WIN_DPI, vdpi = DEFAULT_WIN_DPI;
	SDL_GetDisplayDPI(displayIndex, nullptr, &hdpi, &vdpi);
	_visualWidth = MulDiv(_winWidth, DEFAULT_WIN_DPI, s_cast<int>(hdpi));
	_visualHeight = MulDiv(_winHeight, DEFAULT_WIN_DPI, s_cast<int>(vdpi));
#elif BX_PLATFORM_ANDROID
	_visualWidth = s_cast<int>(_winWidth / g_androidScreenDensity);
	_visualHeight = s_cast<int>(_winHeight / g_androidScreenDensity);
#else
	_visualWidth = _winWidth;
	_visualHeight = _winHeight;
#endif
}
#endif // BX_PLATFORM_ANDROID || BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_LINUX

#if BX_PLATFORM_ANDROID
const std::string& Application::getAPKPath() const {
	return g_androidAPKPath;
}
#endif // BX_PLATFORM_ANDROID

double Application::getElapsedTime() const {
	double currentTime = getCurrentTime();
	return std::max(currentTime - _lastTime, 0.0);
}

double Application::getCurrentTime() const {
	return bx::getHPCounter() / _frequency;
}

double Application::getRunningTime() const {
	return getCurrentTime() - _startTime;
}

double Application::getLastTime() const {
	return _lastTime;
}

double Application::getDeltaTime() const {
	return _deltaTime;
}

double Application::getCPUTime() const {
	return _cpuTime;
}

double Application::getGPUTime() const {
	const bgfx::Stats* stats = bgfx::getStats();
	return std::abs(double(stats->gpuTimeEnd) - double(stats->gpuTimeBegin)) / double(stats->gpuTimerFreq);
}

double Application::getLogicTime() const {
	return _logicTime;
}

double Application::getRenderTime() const {
	return _renderTime;
}

double Application::getTotalTime() const {
	return _totalTime;
}

void Application::makeTimeNow() {
	_totalTime += _deltaTime;
	_lastTime = getCurrentTime();
}

void Application::shutdown() {
	switch (Switch::hash(getPlatform())) {
		case "Windows"_hash:
		case "macOS"_hash:
		case "Linux"_hash:
			_renderEvent.post("Quit"_slice);
			break;
	}
}

void Application::invokeInRender(const std::function<void()>& func) {
	_renderEvent.post("Invoke"_slice, func);
}

void Application::invokeInLogic(const std::function<void()>& func) {
	_logicEvent.post("Invoke"_slice, func);
}

int Application::mainLogic(Application* app) {
	app->_logicThreadID = std::this_thread::get_id();

	if (!SharedBGFX.init(app->_platformData)) {
		Error("bgfx failed to initialize!");
		return 1;
	}

	SharedPoolManager.push();
	if (!SharedDirector.init()) {
		Error("Director failed to initialize!");
		return 1;
	}
	app->_frame = bgfx::frame();

	app->makeTimeNow();
	app->_startTime = app->_lastTime;

#if BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_LINUX
	app->invokeInRender([app]() {
		SDL_ShowWindow(app->_sdlWindow);
	});
#endif
	SharedPoolManager.pop();

	while (app->_logicRunning) {
		auto startTime = app->getElapsedTime();

		SharedPoolManager.push();

		// poll events from render thread
		for (Own<QEvent> event = app->_logicEvent.poll();
			 event != nullptr;
			 event = app->_logicEvent.poll()) {
			switch (Switch::hash(event->getName())) {
				case "SDLEvent"_hash: {
					SDL_Event sdlEvent;
					event->get(sdlEvent);
					switch (sdlEvent.type) {
						case SDL_QUIT: {
							app->_logicRunning = false;
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
				case "Invoke"_hash: {
					std::function<void()> func;
					event->get(func);
					func();
					break;
				}
				default:
					break;
			}
		}

		SharedDirector.doLogic();

		app->_logicTime = app->getElapsedTime() - startTime;

		SharedDirector.doRender();
		SharedPoolManager.pop();

		app->_cpuTime = app->getElapsedTime() - startTime;
		app->_renderTime = app->_cpuTime - app->_logicTime;

		// advance to next frame. rendering thread will be kicked to
		// process submitted rendering primitives.
		app->_frame = bgfx::frame();

		double targetDeltaTime = 1.0 / app->_targetFPS;
		if (app->_idled) {
			app->updateDeltaTime();
			double idleTime = targetDeltaTime - app->getDeltaTime();
			if (idleTime > 0) {
				std::chrono::duration<double> time{idleTime};
				std::this_thread::sleep_for(time);
			}
			app->updateDeltaTime();
		} else if (app->_fpsLimited) {
			do {
				app->updateDeltaTime();
			} while (app->getDeltaTime() < targetDeltaTime);
		} else
			app->updateDeltaTime();
		app->makeTimeNow();
	}

	Life::destroy("BGFXDora"_slice);
	return 0;
}

int Application::mainLogic(bx::Thread* thread, void* userData) {
	DORA_UNUSED_PARAM(thread);
	Application* app = r_cast<Application*>(userData);
	try {
		return mainLogic(app);
	} catch (const std::runtime_error& e) {
		LogError(e.what());
		std::abort();
	}
}

const Slice Application::getPlatform() const {
#if BX_PLATFORM_WINDOWS
	return "Windows"_slice;
#elif BX_PLATFORM_ANDROID
	return "Android"_slice;
#elif BX_PLATFORM_OSX
	return "macOS"_slice;
#elif BX_PLATFORM_IOS
	return "iOS"_slice;
#elif BX_PLATFORM_LINUX
	return "Linux"_slice;
#else
	return "Unsupported"_slice;
#endif
}

const Slice Application::getVersion() const {
	return DORA_VERSION;
}

bool Application::isDebugging() const {
	return DORA_DEBUG ? true : false;
}

std::thread::id Application::getLogicThread() const {
	return _logicThreadID;
}

#if BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID || BX_PLATFORM_LINUX
void Application::setupSdlWindow() {
	SDL_SysWMinfo wmi;
	SDL_VERSION(&wmi.version);
	SDL_GetWindowWMInfo(_sdlWindow, &wmi);
#if BX_PLATFORM_OSX
	_platformData.nwh = wmi.info.cocoa.window;
#elif BX_PLATFORM_WINDOWS
	_platformData.nwh = wmi.info.win.window;
#elif BX_PLATFORM_ANDROID
	_platformData.nwh = wmi.info.android.window;
#elif BX_PLATFORM_LINUX
	_platformData.ndt = wmi.info.x11.display;
	_platformData.nwh = r_cast<void*>(wmi.info.x11.window);
#endif // BX_PLATFORM
#if BX_PLATFORM_WINDOWS
	int displayIndex = SDL_GetWindowDisplayIndex(_sdlWindow);
	float hdpi = DEFAULT_WIN_DPI, vdpi = DEFAULT_WIN_DPI;
	SDL_GetDisplayDPI(displayIndex, nullptr, &hdpi, &vdpi);
	SDL_DisplayMode displayMode{SDL_PIXELFORMAT_UNKNOWN, 0, 0, 0, 0};
	SDL_GetCurrentDisplayMode(displayIndex, &displayMode);
	int screenWidth = MulDiv(displayMode.w, DEFAULT_WIN_DPI, s_cast<int>(hdpi));
	int screenHeight = MulDiv(displayMode.h, DEFAULT_WIN_DPI, s_cast<int>(vdpi));
	_visualWidth = Math::clamp(_visualWidth, 0, screenWidth);
	_visualHeight = Math::clamp(_visualHeight, 0, screenHeight);
	if (hdpi != DEFAULT_WIN_DPI || vdpi != DEFAULT_WIN_DPI) {
		_winWidth = MulDiv(_visualWidth, s_cast<int>(hdpi), DEFAULT_WIN_DPI);
		_winHeight = MulDiv(_visualHeight, s_cast<int>(vdpi), DEFAULT_WIN_DPI);
		SDL_SetWindowSize(_sdlWindow, _winWidth, _winHeight);
		SDL_SetWindowPosition(_sdlWindow, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
	}
#endif // BX_PLATFORM_WINDOWS
	updateWindowSize();
}
#endif // BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID || BX_PLATFORM_LINUX

NS_DORA_END

// Entry functions needed by SDL2
#if BX_PLATFORM_OSX || BX_PLATFORM_ANDROID || BX_PLATFORM_IOS || BX_PLATFORM_LINUX
extern "C" int main(int argc, char* argv[]) {
	return SharedApplication.run();
}
#endif // BX_PLATFORM_OSX || BX_PLATFORM_ANDROID || BX_PLATFORM_IOS || BX_PLATFORM_LINUX

#if BX_PLATFORM_WINDOWS

#if DORA_WIN_CONSOLE

#include "Common/Async.h"

NS_DORA_BEGIN

class Console {
public:
	~Console() {
		system("pause");
		FreeConsole();
	}
	inline void init() {
		AllocConsole();
		freopen("CONIN$", "r", stdin);
		freopen("CONOUT$", "w", stdout);
		freopen("CONOUT$", "w", stderr);
	}
	SINGLETON_REF(Console);
	SINGLETON_REF(AsyncLogThread, Console);
};
#define SharedConsole \
	Dora::Singleton<Dora::Console>::shared()

NS_DORA_END
#endif // DORA_WIN_CONSOLE

int CALLBACK WinMain(
	_In_ HINSTANCE hInstance,
	_In_ HINSTANCE hPrevInstance,
	_In_ LPSTR lpCmdLine,
	_In_ int nCmdShow) {
#if DORA_WIN_CONSOLE
	SharedConsole.init();
#endif
	return SharedApplication.run();
}
#endif // BX_PLATFORM_WINDOWS

#include "Http/HttpServer.h"
#include "Lua/LuaEngine.h"
#include "SQLiteCpp/SQLiteCpp.h"
#include "imgui.h"
#include "implot.h"
#include "playrho/Defines.hpp"
#include "soloud.h"
#include "sqlite3.h"
#include "wasm3.h"
#include "yuescript/yue_compiler.h"

std::string Dora::Application::getDeps() const {
	return fmt::format(
		"- SDL2 {}.{}.{}\n"
		"- bgfx {}\n"
		"- Lua {}.{}.{}\n"
		"- Yuescript {}\n"
		"- Teal {}\n"
		"- PlayRho {}.{}.{}\n"
		"- soloud {}\n"
		"- DragonBones 5.6.3\n"
		"- Spine 4.1.4\n"
		"- ImGui {}\n"
		"- ImPlot {}\n"
		"- sqlite3 {}\n"
		"- SQLiteCpp {}\n"
		"- wasm3 {}\n"
		"- fmt {}\n"
		"- httplib {}",
		SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_PATCHLEVEL,
		BGFX_API_VERSION,
		LUA_VERSION_MAJOR, LUA_VERSION_MINOR, LUA_VERSION_RELEASE,
		yue::version,
		SharedLuaEngine.getTealVersion(),
		PLAYRHO_VERSION_MAJOR, PLAYRHO_VERSION_MINOR, PLAYRHO_VERSION_PATCH,
		SOLOUD_VERSION,
		IMGUI_VERSION,
		IMPLOT_VERSION,
		SQLITE_VERSION,
		SQLITECPP_VERSION,
		M3_VERSION,
		FMT_VERSION,
		HttpServer::getVersion());
}
