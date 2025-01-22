/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Application.h"

#if BX_PLATFORM_IOS

#include "SDL.h"
#include "SDL_syswm.h"

#import <QuartzCore/CAMetalLayer.h>

NS_DORA_BEGIN
void Application::updateWindowSize() {
	SDL_SysWMinfo wmi;
	SDL_VERSION(&wmi.version);
	SDL_GetWindowWMInfo(_sdlWindow, &wmi);
	CALayer* layer = wmi.info.uikit.window.rootViewController.view.layer;
	CGRect frame = layer.frame;
	for (NSUInteger i = 0; i < layer.sublayers.count; i++) {
		layer.sublayers[i].frame = frame;
	}
	[layer layoutSublayers];
	_winWidth = frame.size.width;
	_winHeight = frame.size.height;
	CGFloat scale = [UIScreen mainScreen].scale;
	_bufferWidth = _winWidth * scale;
	_bufferHeight = _winHeight * scale;
	SDL_DisplayMode displayMode{SDL_PIXELFORMAT_UNKNOWN, 0, 0, 0, 0};
	SDL_GetWindowDisplayMode(_sdlWindow, &displayMode);
	if (displayMode.refresh_rate > 0) {
		_maxFPS = displayMode.refresh_rate;
	}
	_visualWidth = _winWidth;
	_visualHeight = _winHeight;
}

void Application::setupSdlWindow() {
	SDL_SysWMinfo wmi;
	SDL_VERSION(&wmi.version);
	SDL_GetWindowWMInfo(_sdlWindow, &wmi);
	CALayer* layer = wmi.info.uikit.window.rootViewController.view.layer;
	CAMetalLayer* displayLayer = [[CAMetalLayer alloc] init];
	displayLayer.contentsScale = [UIScreen mainScreen].scale;
	displayLayer.frame = layer.frame;
	[layer addSublayer:displayLayer];
	[layer layoutSublayers];

	_platformData.ndt = NULL;
	_platformData.nwh = (__bridge void*)displayLayer;
	_platformData.context = NULL;
	_platformData.backBuffer = NULL;
	_platformData.backBufferDS = NULL;
	updateWindowSize();
}
NS_DORA_END

#endif // BX_PLATFORM_IOS
