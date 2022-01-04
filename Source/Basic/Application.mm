/* Copyright (c) 2022 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Application.h"

#if BX_PLATFORM_IOS

#include "SDL_syswm.h"
#include "SDL.h"

#import <QuartzCore/CAMetalLayer.h>

NS_DOROTHY_BEGIN
void Application::updateWindowSize()
{
	CGRect bounds = [UIScreen mainScreen].bounds;
	CGFloat scale = [UIScreen mainScreen].scale;
	_bufferWidth = bounds.size.width * scale;
	_bufferHeight = bounds.size.height * scale;
	SDL_GetWindowSize(_sdlWindow, &_winWidth, &_winHeight);
	SDL_DisplayMode displayMode{SDL_PIXELFORMAT_UNKNOWN, 0, 0, 0, 0};
	SDL_GetWindowDisplayMode(_sdlWindow, &displayMode);
	if (displayMode.refresh_rate > 0)
	{
		_maxFPS = displayMode.refresh_rate;
	}
	_visualWidth = _winWidth;
	_visualHeight = _winHeight;
}

void Application::setupSdlWindow()
{
	SDL_SysWMinfo wmi;
	SDL_VERSION(&wmi.version);
	SDL_GetWindowWMInfo(_sdlWindow, &wmi);

	CALayer* layer = wmi.info.uikit.window.rootViewController.view.layer;
	CAMetalLayer* displayLayer = [[CAMetalLayer alloc] init];
	
	CGRect bounds = [UIScreen mainScreen].bounds;
	CGFloat scale = [UIScreen mainScreen].scale;
	displayLayer.contentsScale = scale;
	displayLayer.frame = bounds;
	[layer addSublayer:displayLayer];
	[layer layoutSublayers];

	bgfx::PlatformData pd;
	pd.ndt = NULL;
	pd.nwh = (__bridge void*)displayLayer;
	pd.context = NULL;
	pd.backBuffer = NULL;
	pd.backBufferDS = NULL;
	bgfx::setPlatformData(pd);
	updateWindowSize();
}
NS_DOROTHY_END

#endif // BX_PLATFORM_IOS
