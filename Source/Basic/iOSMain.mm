#include "Const/oHeader.h"
#if BX_PLATFORM_IOS
#include "SDL.h"
#include "SDL_syswm.h"
#include "bx/thread.h"
#include "App.h"
#import <QuartzCore/CAEAGLLayer.h>

NS_DOROTHY_BEGIN

class iOSApp : public App
{
public:
	virtual void setSdlWindow(SDL_Window* window) override
	{
		CGRect bounds = [UIScreen mainScreen].bounds;
		CGFloat scale = [UIScreen mainScreen].scale;
		winWidth = bounds.size.width * scale;
		winHeight = bounds.size.height * scale;
	
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
};

NS_DOROTHY_END

int main(int argc, char *argv[])
{
	Dorothy::iOSApp app;
	return app.run();
}

#endif // BX_PLATFORM_IOS
