#include "Const/Header.h"
#include "Basic/Application.h"

#if BX_PLATFORM_IOS
#import <QuartzCore/CAEAGLLayer.h>

NS_DOROTHY_BEGIN

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

NS_DOROTHY_END

#endif // BX_PLATFORM_IOS
