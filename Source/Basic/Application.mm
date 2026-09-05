/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Application.h"

#if BX_PLATFORM_OSX || BX_PLATFORM_IOS

#import <Foundation/Foundation.h>

NS_DORA_BEGIN
std::string Application::getExecutablePath() const {
	@autoreleasepool {
		NSString* path = [NSBundle mainBundle].executablePath;
		return path == nil ? std::string() : std::string(path.UTF8String);
	}
}
NS_DORA_END

#endif // BX_PLATFORM_OSX || BX_PLATFORM_IOS

#if BX_PLATFORM_IOS

#include "SDL.h"
#include "SDL_syswm.h"
#import "3rdParty/SDL2/src/video/uikit/SDL_uikitappdelegate.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <QuartzCore/CAMetalLayer.h>
#import <UIKit/UIKit.h>


@interface DoraGameDocumentPicker : NSObject <UIDocumentPickerDelegate>
@property(nonatomic, copy) void (^completion)(NSString*);
- (void)copyURL:(NSURL*)url;
@end

@implementation DoraGameDocumentPicker
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController*)controller {
	if (self.completion) self.completion(@"");
	self.completion = nil;
}
- (void)documentPicker:(UIDocumentPickerViewController*)controller didPickDocumentsAtURLs:(NSArray<NSURL*>*)urls {
	NSURL* url = urls.firstObject;
	if (!url) { [self documentPickerWasCancelled:controller]; return; }
	[self copyURL:url];
}
- (void)copyURL:(NSURL*)url {
	BOOL scoped = [url startAccessingSecurityScopedResource];
	// Copy while access is granted, before the picker relinquishes the source URL.
	dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
		NSString* directory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"game-inbox"];
		NSFileManager* manager = [NSFileManager defaultManager];
		[manager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
		for (NSString* name in [manager contentsOfDirectoryAtPath:directory error:nil]) {
			NSString* old = [directory stringByAppendingPathComponent:name];
			NSDate* date = [[manager attributesOfItemAtPath:old error:nil] fileModificationDate];
			if (date && [date timeIntervalSinceNow] < -7 * 86400) [manager removeItemAtPath:old error:nil];
		}
		directory = [directory stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
		[manager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
		NSString* target = [directory stringByAppendingPathComponent:url.lastPathComponent];
		__block BOOL copied = NO;
		NSFileCoordinator* coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
		[coordinator coordinateReadingItemAtURL:url options:0 error:nil byAccessor:^(NSURL* readable) {
			NSDictionary* attrs = [manager attributesOfItemAtPath:readable.path error:nil];
			if (attrs && [attrs fileSize] <= 256ULL * 1024 * 1024) {
				copied = [manager copyItemAtPath:readable.path toPath:target error:nil];
			}
		}];
		if (scoped) [url stopAccessingSecurityScopedResource];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.completion) self.completion(copied ? target : @"");
			self.completion = nil;
		});
	});
}
@end

// UIKit can deliver a document before SDL_main initializes its event queue.
// Own that delivery at the application delegate and copy the granted URL before
// queuing it for Go, which also avoids relying on an external provider's lifetime.
@interface DoraGameAppDelegate : SDLUIKitDelegate
@end
@implementation DoraGameAppDelegate
- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id>*)options {
	if (!url.isFileURL) return [super application:application openURL:url options:options];
	DoraGameDocumentPicker* receiver = [[DoraGameDocumentPicker alloc] init];
	receiver.completion = ^(NSString* path) {
		if (path.length) Dora::Application::queueReceivedFile(std::string(path.UTF8String));
	};
	[receiver copyURL:url];
	return YES;
}
@end

// SDL explicitly supports selecting a delegate subclass through this category.
@interface SDLUIKitDelegate (DoraGameDelegate)
@end
@implementation SDLUIKitDelegate (DoraGameDelegate)
+ (NSString*)getAppDelegateClassName { return @"DoraGameAppDelegate"; }
@end

static DoraGameDocumentPicker* gameDocumentPicker;
static UIViewController* gamePresenter(SDL_Window* window) {
	SDL_SysWMinfo info;
	SDL_VERSION(&info.version);
	if (!SDL_GetWindowWMInfo(window, &info)) return nil;
	UIViewController* controller = info.info.uikit.window.rootViewController;
	while (controller.presentedViewController) controller = controller.presentedViewController;
	return controller;
}

NS_DORA_BEGIN
void Application::openFileDialog(bool folderOnly, const std::function<void(std::string)>& callback) {
	invokeInRender([this, folderOnly, callback]() {
		UIViewController* presenter = gamePresenter(_sdlWindow);
		if (folderOnly || !presenter || gameDocumentPicker.completion) {
			invokeInLogic([callback]() { callback(""); });
			return;
		}
		gameDocumentPicker = [[DoraGameDocumentPicker alloc] init];
		gameDocumentPicker.completion = ^(NSString* path) {
			std::string selected(path.UTF8String);
			invokeInLogic([callback, selected]() { callback(selected); });
		};
		UIDocumentPickerViewController* picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.zip-archive"] inMode:UIDocumentPickerModeImport];
		picker.delegate = gameDocumentPicker;
		[presenter presentViewController:picker animated:YES completion:nil];
	});
}

bool Application::shareFile(String path) {
	std::string filename = path.toString();
	if (![[NSFileManager defaultManager] fileExistsAtPath:@(filename.c_str())]) return false;
	invokeInRender([this, filename]() {
		UIViewController* presenter = gamePresenter(_sdlWindow);
		if (!presenter) return;
		NSURL* url = [NSURL fileURLWithPath:@(filename.c_str())];
		UIActivityViewController* activity = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
		activity.popoverPresentationController.sourceView = presenter.view;
		activity.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(presenter.view.bounds), CGRectGetMidY(presenter.view.bounds), 1, 1);
		[presenter presentViewController:activity animated:YES completion:nil];
	});
	return true;
}

bool Application::saveFileDialog(String path) {
	std::string filename = path.toString();
	if (![[NSFileManager defaultManager] fileExistsAtPath:@(filename.c_str())]) return false;
	invokeInRender([this, filename]() {
		UIViewController* presenter = gamePresenter(_sdlWindow);
		if (!presenter) return;
		UIDocumentPickerViewController* picker = [[UIDocumentPickerViewController alloc] initWithURL:[NSURL fileURLWithPath:@(filename.c_str())] inMode:UIDocumentPickerModeExportToService];
		[presenter presentViewController:picker animated:YES completion:nil];
	});
	return true;
}
NS_DORA_END

NS_DORA_BEGIN
Rect Application::getSafeArea() {
	@autoreleasepool {
		SDL_SysWMinfo wmi;
		SDL_VERSION(&wmi.version);
		if (!SDL_GetWindowWMInfo(_sdlWindow, &wmi)) {
			return Rect{0.0f, 0.0f, s_cast<float>(_visualWidth), s_cast<float>(_visualHeight)};
		}
		UIView* view = wmi.info.uikit.window.rootViewController.view;
		UIEdgeInsets insets = view.safeAreaInsets;
		return Rect{s_cast<float>(insets.left), s_cast<float>(insets.bottom),
			std::max(s_cast<float>(_visualWidth - insets.left - insets.right), 0.0f),
			std::max(s_cast<float>(_visualHeight - insets.top - insets.bottom), 0.0f)};
	}
}

bool Application::isReducedMotion() const noexcept {
	return UIAccessibilityIsReduceMotionEnabled();
}

void Application::vibrate(double seconds) {
	DORA_UNUSED_PARAM(seconds);
	@autoreleasepool {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	}
}

bool Application::hasBackgroundMusic() const {
	@autoreleasepool {
		AVAudioSession* session = [AVAudioSession sharedInstance];
		return session.secondaryAudioShouldBeSilencedHint;
	}
}

bool Application::setAudioMixWithSystem(bool mix) {
	@autoreleasepool {
		AVAudioSession* session = [AVAudioSession sharedInstance];
		NSString* category = mix ? AVAudioSessionCategoryAmbient : AVAudioSessionCategorySoloAmbient;
		NSError* error = nil;
		if (![session setCategory:category error:&error]) {
			Error("failed to set iOS audio mix policy: {}",
				error == nil ? "unknown AVAudioSession error" : error.localizedDescription.UTF8String);
			return false;
		}
		return true;
	}
}

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
