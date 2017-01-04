/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

struct SDL_Window;

NS_DOROTHY_BEGIN

ENUM_START(TargetPlatform)
{
	Windows,
	Android,
	macOS,
	iOS,
	Unknown
}
ENUM_END(TargetPlatform)

class Application : public Object
{
public:
	PROPERTY_READONLY(int, Width);
	PROPERTY_READONLY(int, Height);
	PROPERTY_READONLY(double, LastTime);
	PROPERTY_READONLY(double, DeltaTime);
	PROPERTY_READONLY(double, EclapsedTime);
	PROPERTY_READONLY(double, CPUTime);
	PROPERTY_READONLY(TargetPlatform, Platform);
	PROPERTY(unsigned int, Seed);
	int run();
	void shutdown();
	static int mainLogic(void* userData);
protected:
	Application();
	void updateDeltaTime();
	void makeTimeNow();
	void setSdlWindow(SDL_Window* window);
	bgfx::RenderFrame::Enum renderFrame();
private:
	unsigned int _seed;
	int _width;
	int _height;
	const double _frequency;
	double _lastTime;
	double _deltaTime;
	double _cpuTime;
	bx::Thread _logicThread;
	EventQueue _logicEvent;
	EventQueue _renderEvent;
};

#define SharedApplication \
	silly::Singleton<Dorothy::Application, Dorothy::SingletonIndex::Application>::shared()

NS_DOROTHY_END
