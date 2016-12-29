#include "Const/Header.h"
#include "Basic/Application.h"

NS_DOROTHY_BEGIN

#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
bgfx::RenderFrame::Enum Application::renderFrame()
{
	bgfx::RenderFrame::Enum result;
	@autoreleasepool
	{
		result = bgfx::renderFrame();
	}
	return result;
}
#endif // BX_PLATFORM_OSX || BX_PLATFORM_IOS

#if BX_PLATFORM_IOS
#import <QuartzCore/CAEAGLLayer.h>

void Application::setSdlWindow(SDL_Window* window)
{
	CGRect bounds = [UIScreen mainScreen].bounds;
	CGFloat scale = [UIScreen mainScreen].scale;
	_width = bounds.size.width * scale;
	_height = bounds.size.height * scale;

	SDL_SysWMinfo wmi;
	SDL_VERSION(&wmi.version);
	SDL_GetWindowWMInfo(window, &wmi);

	CALayer* layer = wmi.info.uikit.window.rootViewController.view.layer;
	CAEAGLLayer* displayLayer = [[CAEAGLLayer alloc] init];
	displayLayer.contentsScale = scale;
	displayLayer.frame = bounds;
	[layer addSublayer:displayLayer];
	[layer layoutSublayers];

	bgfx::PlatformData pd;
	pd.ndt = NULL;
	pd.nwh = (__bridge void *)displayLayer;
	pd.context = NULL;
	pd.backBuffer = NULL;
	pd.backBufferDS = NULL;
	bgfx::setPlatformData(pd);
}
#endif // BX_PLATFORM_IOS

NS_DOROTHY_END
