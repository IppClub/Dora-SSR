/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Event/EventQueue.h"
#include "Support/Geometry.h"
#include <random>

struct SDL_Window;
union SDL_Event;

NS_DOROTHY_BEGIN

typedef Delegate<void(const SDL_Event&)> SDLEventHandler;
typedef Delegate<void()> QuitHandler;

class Application
{
public:
	virtual ~Application() { }
	PROPERTY_READONLY(Uint32, Frame);
	PROPERTY_READONLY(Size, WinSize);
	PROPERTY_READONLY(Size, BufferSize);
	PROPERTY_READONLY(Size, VisualSize);
	PROPERTY_READONLY(float, DeviceRatio);
	PROPERTY_READONLY(double, LastTime);
	PROPERTY_READONLY(double, DeltaTime);
	PROPERTY_READONLY(double, EclapsedTime);
	PROPERTY_READONLY(double, CurrentTime);
	PROPERTY_READONLY(double, CPUTime);
	PROPERTY_READONLY(double, TotalTime);
	PROPERTY_READONLY(const Slice, Platform);
	PROPERTY_READONLY(const Slice, Version);
	PROPERTY_READONLY_CALL(Uint32, Rand);
	PROPERTY_READONLY(Uint32, RandMin);
	PROPERTY_READONLY(Uint32, RandMax);
	PROPERTY_READONLY(SDL_Window*, SDLWindow);
	PROPERTY_READONLY_BOOL(RenderRunning);
	PROPERTY_READONLY_BOOL(LogicRunning);
	PROPERTY_READONLY_BOOL(Debugging);
	PROPERTY(Uint32, MaxFPS);
	PROPERTY(Uint32, MinFPS);
	PROPERTY(Uint32, Seed);
	PROPERTY_BOOL(FPSLimited);
	SDLEventHandler eventHandler;
	QuitHandler quitHandler;
	int run();
	void shutdown();
	void invokeInRender(const function<void()>& func);
	void invokeInLogic(const function<void()>& func);
	static int mainLogic(bx::Thread* thread, void* userData);
#if BX_PLATFORM_WINDOWS
	inline void* operator new(size_t i)
	{
		return _mm_malloc(i, 16);
	}
	inline void operator delete(void* p)
	{
		_mm_free(p);
	}
#elif BX_PLATFORM_ANDROID
	PROPERTY_READONLY_CREF(string, APKPath);
#endif // BX_PLATFORM
protected:
	Application();
	void updateDeltaTime();
	void updateWindowSize();
	void makeTimeNow();
	void setupSdlWindow();
private:
	bool _fpsLimited;
	bool _renderRunning;
	bool _logicRunning;
	int _visualWidth;
	int _visualHeight;
	int _winWidth;
	int _winHeight;
	int _bufferWidth;
	int _bufferHeight;
	Uint32 _seed;
	Uint32 _maxFPS;
	Uint32 _minFPS;
	uint32_t _frame;
	const double _frequency;
	double _lastTime;
	double _deltaTime;
	double _cpuTime;
	double _totalTime;
	bx::Thread _logicThread;
	EventQueue _logicEvent;
	EventQueue _renderEvent;
	SDL_Window* _sdlWindow;
	std::mt19937 _randomEngine;
	SINGLETON_REF(Application, AsyncLogThread);
};

#define SharedApplication \
	Dorothy::Singleton<Dorothy::Application>::shared()

class BGFXDora
{
public:
	bool init();
	virtual ~BGFXDora();
	SINGLETON_REF(BGFXDora, Application);
};

#define SharedBGFX \
	Dorothy::Singleton<Dorothy::BGFXDora>::shared()

NS_DOROTHY_END
