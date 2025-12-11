/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Event/EventQueue.h"
#include "Support/Geometry.h"

#include "bx/thread.h"

#include <random>
#include <thread>

struct SDL_Window;
union SDL_Event;

extern "C" typedef int (*MainFunc)();

NS_DORA_BEGIN

typedef Acf::Delegate<void(const SDL_Event&)> SDLEventHandler;
typedef Acf::Delegate<void()> QuitHandler;

class Application : public NonCopyable {
public:
	virtual ~Application() { }
	PROPERTY_READONLY(uint32_t, Frame);
	PROPERTY_READONLY(Size, BufferSize);
	PROPERTY_READONLY(Size, VisualSize);
	PROPERTY_READONLY(float, DevicePixelRatio);
	PROPERTY_READONLY(double, LastTime);
	PROPERTY_READONLY(double, DeltaTime);
	PROPERTY_READONLY(double, ElapsedTime);
	PROPERTY_READONLY(double, CurrentTime);
	PROPERTY_READONLY(double, RunningTime);
	PROPERTY_READONLY(double, CPUTime);
	PROPERTY_READONLY(double, GPUTime);
	PROPERTY_READONLY(double, LogicTime);
	PROPERTY_READONLY(double, RenderTime);
	PROPERTY_READONLY(double, TotalTime);
	PROPERTY_READONLY(const Slice, Platform);
	PROPERTY_READONLY(const Slice, Version);
	PROPERTY_READONLY(std::string, Deps);
	PROPERTY_READONLY_CALL(uint32_t, Rand);
	PROPERTY_READONLY(uint32_t, RandMin);
	PROPERTY_READONLY(uint32_t, RandMax);
	PROPERTY_READONLY(SDL_Window*, SDLWindow);
	PROPERTY_READONLY_BOOL(RenderRunning);
	PROPERTY_READONLY_BOOL(LogicRunning);
	PROPERTY_READONLY_BOOL(Debugging);
	PROPERTY_READONLY(std::thread::id, LogicThread);
	PROPERTY_READONLY(uint32_t, MaxFPS);
	PROPERTY_STRING(Locale);
	PROPERTY(Color, ThemeColor);
	PROPERTY(uint32_t, TargetFPS);
	PROPERTY(uint32_t, Seed);
	PROPERTY(Size, WinSize);
	PROPERTY_CREF(Vec2, WinPosition);
	PROPERTY_BOOL(FPSLimited);
	PROPERTY_BOOL(Idled);
	PROPERTY_BOOL(FullScreen);
	PROPERTY_BOOL(AlwaysOnTop);
	PROPERTY_BOOL(DevMode);
	SDLEventHandler eventHandler;
	QuitHandler quitHandler;
	int run(MainFunc mainFunc = nullptr);
	void shutdown();
	void invokeInRender(const std::function<void()>& func);
	void invokeInLogic(const std::function<void()>& func);
	void openURL(String url);
	void openFileDialog(bool folderOnly, const std::function<void(std::string)>& callback);
	void install(String path);
	bool saveLog(String filename);
	static int mainLogic(bx::Thread* thread, void* userData);
	static int mainLogic(Application* app);
#if BX_PLATFORM_WINDOWS
	inline void* operator new(size_t i) {
		return _mm_malloc(i, 16);
	}
	inline void operator delete(void* p) {
		_mm_free(p);
	}
#elif BX_PLATFORM_ANDROID
	PROPERTY_READONLY_CREF(std::string, APKPath);
#endif // BX_PLATFORM
protected:
	Application();
	void updateDeltaTime();
	void updateWindowSize();
	void makeTimeNow();
	void setupSdlWindow();

private:
	bool _idled;
	bool _fpsLimited;
	bool _renderRunning;
	bool _logicRunning;
	bool _fullScreen;
	bool _alwaysOnTop;
	bool _devMode;
	int _visualWidth;
	int _visualHeight;
	int _winWidth;
	int _winHeight;
	int _bufferWidth;
	int _bufferHeight;
	Color _themeColor;
	uint32_t _seed;
	uint32_t _targetFPS;
	uint32_t _maxFPS;
	uint32_t _frame;
	const double _frequency;
	double _startTime;
	double _lastTime;
	double _deltaTime;
	double _cpuTime;
	double _totalTime;
	double _logicTime;
	double _renderTime;
	Vec2 _winPosition;
	std::string _locale;
	std::string _orientation;
	bx::Thread _logicThread;
	EventQueue _logicEvent;
	EventQueue _renderEvent;
	std::thread::id _logicThreadID;
	SDL_Window* _sdlWindow;
	std::mt19937 _randomEngine;
	bgfx::PlatformData _platformData;
	MainFunc _mainFunc;
	SINGLETON_REF(Application, Logger, AsyncLogThread);
};

#define SharedApplication \
	Dora::Singleton<Dora::Application>::shared()

class BGFXDora : public NonCopyable {
public:
	bool init(const bgfx::PlatformData& data);
	virtual ~BGFXDora();
	SINGLETON_REF(BGFXDora, Application);
};

#define SharedBGFX \
	Dora::Singleton<Dora::BGFXDora>::shared()

NS_DORA_END
