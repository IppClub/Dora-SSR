/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Application.h"
#include "Basic/IDEInput.h"
#include <objc/runtime.h>

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

#if BX_PLATFORM_OSX
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#include "SDL.h"
#include "SDL_syswm.h"
#include "Event/Event.h"

NS_DORA_BEGIN
// SDL's minimized flag can lag Cocoa during window animations. Query the
// native window so a repeated launch also restores a window in transition.
void activateGuiWindowMac(SDL_Window* window) {
	@autoreleasepool {
		SDL_SysWMinfo info{};
		SDL_VERSION(&info.version);
		if (!SDL_GetWindowWMInfo(window, &info)) return;
		NSWindow* native = info.info.cocoa.window;
		[NSApp unhide:nil];
		[NSApp activateIgnoringOtherApps:YES];
		if ([native isMiniaturized]) [native deminiaturize:nil];
		[native makeKeyAndOrderFront:nil];
	}
}
NS_DORA_END

static void compilerFailure(NSString* message) {
	std::string reason = message.UTF8String;
	Dora::Singleton<Dora::Application>::shared().invokeInLogic([reason]() {
		Dora::Event::send(std::string_view("AppCompilerFailure"), reason);
	});
}

@interface DoraCompilerNavigation : NSObject <WKNavigationDelegate, WKScriptMessageHandler>
@end
@implementation DoraCompilerNavigation
- (void)userContentController:(WKUserContentController*)controller didReceiveScriptMessage:(WKScriptMessage*)message {
	Info("compiler: {}", std::string([[message.body description] UTF8String]));
}
- (void)webView:(WKWebView*)view didFailProvisionalNavigation:(WKNavigation*)navigation withError:(NSError*)error {
	compilerFailure(error.localizedDescription);
}
- (void)webView:(WKWebView*)view didFailNavigation:(WKNavigation*)navigation withError:(NSError*)error {
	compilerFailure(error.localizedDescription);
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView*)view {
	compilerFailure(@"TypeScript compiler WebView process terminated");
}
- (void)webView:(WKWebView*)view decidePolicyForNavigationAction:(WKNavigationAction*)action decisionHandler:(void (^)(WKNavigationActionPolicy))handler {
	NSURL* url = action.request.URL;
	BOOL allowed = [url.host isEqualToString:@"localhost"] && url.port.intValue == 8866 && [url.path isEqualToString:@"/compiler.html"];
	handler(allowed ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}
@end

static WKWebView* compilerWebView;
static DoraCompilerNavigation* compilerNavigation;

static void ideState(NSString* state, NSString* message = @"") {
	std::string value = state.UTF8String, reason = message.UTF8String;
	Dora::Singleton<Dora::Application>::shared().invokeInLogic([value, reason]() {
		Dora::Event::send(std::string_view("AppIDEState"), value, reason);
	});
}

// This marker lets SDL leave embedded browser/control events to Cocoa.
@interface DoraIDEOverlay : NSView
@end
@implementation DoraIDEOverlay
- (NSView*)hitTest:(NSPoint)point {
 NSView* hit = [super hitTest:point];
 return hit == self ? nil : hit;
}
@end

@interface DoraIDEHost : NSObject <WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate, WKScriptMessageHandler>
@property(weak) NSWindow* window;
@property(strong) WKWebView* view;
@property(strong) DoraIDEOverlay* overlay;
@property(strong) NSStackView* menu;
@property(strong) NSButton* handle;
@property(strong) NSButton* switchButton;
@property(strong) NSButton* stopButton;
@property(strong) NSButton* reloadButton;
@property(copy) NSString* pendingRun;
@property BOOL loaded;
@property BOOL visible;
@property(strong) id keyMonitor;
@property BOOL toggleKeyHeld;
@property unsigned short toggleKeyCode;
- (instancetype)initWithWindow:(NSWindow*)window;
- (void)show;
- (void)hide;
- (void)stop;
- (void)releaseView;
- (void)reload;
- (void)detach;
@end

@implementation DoraIDEHost
- (NSButton*)button:(NSString*)title action:(SEL)action {
 NSButton* button = [NSButton buttonWithTitle:title target:self action:action];
 button.bordered = NO; button.wantsLayer = YES;
 button.identifier = @"DoraNativeUI";
 button.layer.backgroundColor = [NSColor colorWithWhite:0.21 alpha:1].CGColor;
 button.layer.cornerRadius = 6;
 button.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:NSColor.whiteColor, NSFontAttributeName:[NSFont systemFontOfSize:12]}];
 [button.heightAnchor constraintEqualToConstant:38].active = YES;
 return button;
}
- (void)setTitle:(NSString*)title forButton:(NSButton*)button {
 button.title = title;
 button.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:NSColor.whiteColor, NSFontAttributeName:[NSFont systemFontOfSize:button == _handle ? 8 : 12]}];
}
- (instancetype)initWithWindow:(NSWindow*)window {
 self = [super init];
 if (!self) return nil;
 _window = window;
 NSView* root = window.contentView;
 _overlay = [[DoraIDEOverlay alloc] initWithFrame:root.bounds];
 _overlay.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
 _menu = [NSStackView stackViewWithViews:@[]];
 _menu.orientation = NSUserInterfaceLayoutOrientationVertical;
 _menu.spacing = 8; _menu.edgeInsets = NSEdgeInsetsMake(12, 8, 12, 8);
 _menu.wantsLayer = YES;
 _menu.layer.backgroundColor = [NSColor colorWithWhite:0.17 alpha:0.53].CGColor;
 _menu.layer.cornerRadius = 18;
 _menu.identifier = @"DoraNativeUI"; _menu.hidden = YES;
 _switchButton = [self button:@"IDE" action:@selector(switchMode)];
 BOOL zh = [NSLocale.preferredLanguages.firstObject hasPrefix:@"zh"];
 _stopButton = [self button:zh ? @"关闭" : @"Close" action:@selector(stop)];
 _reloadButton = [self button:zh ? @"重载" : @"Reload" action:@selector(reload)];
 for (NSButton* button in @[_switchButton, _reloadButton, _stopButton]) {
  [_menu addArrangedSubview:button];
  [button.widthAnchor constraintEqualToAnchor:_menu.widthAnchor constant:-16].active = YES;
 }
 _handle = [NSButton buttonWithTitle:@"I\nD\nE" target:self action:@selector(toggleMenu)];
 _handle.bordered = NO; _handle.identifier = @"DoraNativeUI";
 _handle.wantsLayer = YES; _handle.layer.backgroundColor = [NSColor colorWithWhite:0.21 alpha:0.8].CGColor;
 _handle.layer.cornerRadius = 16; _handle.alphaValue = 0.24;
 [self setTitle:@"I\nD\nE" forButton:_handle];
 for (NSView* view in @[_menu, _handle]) { view.translatesAutoresizingMaskIntoConstraints = NO; [_overlay addSubview:view]; }
 [NSLayoutConstraint activateConstraints:@[
  [_handle.leadingAnchor constraintEqualToAnchor:_overlay.leadingAnchor],
  [_handle.centerYAnchor constraintEqualToAnchor:_overlay.centerYAnchor],
  [_handle.widthAnchor constraintEqualToConstant:20], [_handle.heightAnchor constraintEqualToConstant:60],
  [_menu.leadingAnchor constraintEqualToAnchor:_handle.trailingAnchor constant:2],
  [_menu.centerYAnchor constraintEqualToAnchor:_overlay.centerYAnchor], [_menu.widthAnchor constraintEqualToConstant:94]]];
 [root addSubview:_overlay];
 [self updateControls];
	// SDL supplies application/window menus, but no Edit menu. Use the Cocoa
	// responder chain for WebKit's clipboard and undo operations.
	if (![NSApp.mainMenu itemWithTitle:@"Edit"] && ![NSApp.mainMenu itemWithTitle:@"编辑"]) {
		NSMenuItem* editItem = [[NSMenuItem alloc] initWithTitle:zh ? @"编辑" : @"Edit" action:nil keyEquivalent:@""];
		NSMenu* edit = [[NSMenu alloc] initWithTitle:editItem.title];
		NSArray* titles = zh ? @[@"撤销", @"重做", @"剪切", @"复制", @"粘贴", @"全选"] : @[@"Undo", @"Redo", @"Cut", @"Copy", @"Paste", @"Select All"];
		NSArray* keys = @[@"z", @"z", @"x", @"c", @"v", @"a"];
		SEL selectors[] = {@selector(undo:), @selector(redo:), @selector(cut:), @selector(copy:), @selector(paste:), @selector(selectAll:)};
		for (NSUInteger i = 0; i < titles.count; ++i) {
			NSMenuItem* item = [edit addItemWithTitle:titles[i] action:selectors[i] keyEquivalent:keys[i]];
			if (i == 1) item.keyEquivalentModifierMask = NSEventModifierFlagCommand | NSEventModifierFlagShift;
		}
		editItem.submenu = edit;
		[NSApp.mainMenu insertItem:editItem atIndex:1];
	}

 [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(windowResigned:) name:NSWindowDidResignKeyNotification object:_window];
 __weak DoraIDEHost* weakSelf = self;
 NSEvent*(^keyHandler)(NSEvent*) = ^NSEvent*(NSEvent* event) {
  DoraIDEHost* host = weakSelf;
  if (!host || !Dora::Singleton<Dora::Application>::shared().isWebIDEEnabled() || event.window != host.window) return event;
  if (host.toggleKeyHeld && event.keyCode == host.toggleKeyCode) {
   if (event.type == NSEventTypeKeyUp) host.toggleKeyHeld = NO;
   return nil;
  }
  if (event.type != NSEventTypeKeyDown) return event;
  NSString* key = event.charactersIgnoringModifiers.lowercaseString;
  NSEventModifierFlags mods = event.modifierFlags & (NSEventModifierFlagCommand | NSEventModifierFlagShift | NSEventModifierFlagControl | NSEventModifierFlagOption);
  if (mods == (NSEventModifierFlagCommand | NSEventModifierFlagShift) && [key isEqualToString:@"h"]) {
   if (!event.isARepeat) { host.toggleKeyHeld = YES; host.toggleKeyCode = event.keyCode; [host switchMode]; }
   return nil;
  }
  if (!host.visible || !(event.modifierFlags & NSEventModifierFlagCommand)) return event;
  id responder = host.window.firstResponder;
  if ([responder conformsToProtocol:@protocol(NSTextInputClient)] && [(id<NSTextInputClient>)responder hasMarkedText]) return event;
  BOOL shift = (event.modifierFlags & NSEventModifierFlagShift) != 0;
  if (shift && [key isEqualToString:@"l"]) { [host reload]; return nil; }
  if ([key isEqualToString:@"w"]) {
   NSString* script = [NSString stringWithFormat:@"document.activeElement.dispatchEvent(new KeyboardEvent('keydown', {key:'w',code:'KeyW',metaKey:true,shiftKey:%@,bubbles:true,cancelable:true}))", shift ? @"true" : @"false"];
   [host.view evaluateJavaScript:script completionHandler:nil]; return nil;
  }
  return event;
 };
 const void* key = NSSelectorFromString(@"doraIDEKeyEvent:");
 BOOL(^consumeKey)(NSEvent*) = ^BOOL(NSEvent* event) {
  if (objc_getAssociatedObject(event, key)) return YES;
  if (keyHandler(event)) return NO;
  objc_setAssociatedObject(event, key, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  return YES;
 };
 // SDL translates keys before NSApplication's local monitors. Give it the
 // same handler so reserved keys never enter either the engine or WebKit.
 objc_setAssociatedObject(_window, key, consumeKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
 _keyMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskKeyDown | NSEventMaskKeyUp)
  handler:^NSEvent*(NSEvent* event) { return consumeKey(event) ? nil : event; }];
 return self;
}
- (void)windowResigned:(NSNotification*)notification { _toggleKeyHeld = NO; }
- (void)updateControls {
 BOOL zh = [NSLocale.preferredLanguages.firstObject hasPrefix:@"zh"];
 [self setTitle:_visible ? (zh ? @"引擎" : @"Engine") : @"IDE" forButton:_switchButton];
 [self setTitle:_visible ? @"M\nE\nN\nU" : @"I\nD\nE" forButton:_handle];
 _stopButton.hidden = !_visible;
 _reloadButton.hidden = !_visible;
}
- (void)collapseMenu {
 [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(collapseMenu) object:nil];
 _menu.hidden = YES;
 if (_visible) [_window makeFirstResponder:_view];
 else [_window makeFirstResponder:_window.contentView];
}
- (void)toggleMenu {
 if (!_visible) { [self show]; return; }
 if (!_menu.hidden) { [self collapseMenu]; return; }
 [self updateControls]; _menu.hidden = NO;
 [self performSelector:@selector(collapseMenu) withObject:nil afterDelay:3.5];
}
- (void)switchMode { if (_visible) [self hide]; else [self show]; }
- (void)ensureView {
 if (_view) return;
 WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
 config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];
 [config.userContentController addScriptMessageHandler:self name:@"doraIDERun"];
 if (@available(macOS 14.0, *)) config.preferences.inactiveSchedulingPolicy = WKInactiveSchedulingPolicyNone;
 NSView* root = _window.contentView;
 _view = [[WKWebView alloc] initWithFrame:root.bounds configuration:config];
 _view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
 _view.identifier = @"DoraNativeUI";
 _view.navigationDelegate = self; _view.UIDelegate = self;
 [root addSubview:_view positioned:NSWindowBelow relativeTo:_overlay];
}
- (void)cancelComposition {
 id responder = _window.firstResponder;
 NSTextInputContext* context = [responder isKindOfClass:[NSView class]] ? [(NSView*)responder inputContext] : nil;
 id<NSTextInputClient> client = context.client;
 if (!client && [responder conformsToProtocol:@protocol(NSTextInputClient)]) client = responder;
 if ([client hasMarkedText]) {
  [client setMarkedText:@"" selectedRange:NSMakeRange(0, 0) replacementRange:NSMakeRange(NSNotFound, 0)];
  [client unmarkText];
 }
 [context discardMarkedText];
}
- (void)show {
 _pendingRun = nil;
 if (!_visible) { [self cancelComposition]; Dora::notifyIDEInputFocus(true); }
 [self ensureView]; _visible = YES; _view.hidden = NO;
 Dora::Singleton<Dora::Application>::shared().setIDEWebViewVisible(true);
 [NSApp activateIgnoringOtherApps:YES];
 [_window makeKeyAndOrderFront:nil]; [_window makeFirstResponder:_view];
 if (!_loaded) { _loaded = YES; [_view loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8866/"]]]; }
 [self updateControls]; [self collapseMenu]; ideState(@"visible");
}
- (void)hide {
 _pendingRun = nil;
 if (_visible) { [self cancelComposition]; Dora::notifyIDEInputFocus(false); }
 _visible = NO; _view.hidden = YES;
 Dora::Singleton<Dora::Application>::shared().setIDEWebViewVisible(false);
 [self updateControls]; [self collapseMenu]; ideState(@"hidden");
}
- (void)releaseView {
 WKWebView* closing = _view;
 _view = nil; _loaded = NO;
 [closing stopLoading];
 [closing.configuration.userContentController removeScriptMessageHandlerForName:@"doraIDERun"];
 closing.navigationDelegate = nil; closing.UIDelegate = nil;
 [closing removeFromSuperview];
 // Stop reconnect timers and in-flight warmup before releasing the document.
 // WebKit can retain an old document while navigation/teardown is pending.
 [closing evaluateJavaScript:@"window.__doraIDEClosed=true;window.dispatchEvent(new Event('dora-ide-close'))"
  completionHandler:^(id value, NSError* error) {
   [closing stopLoading]; [closing loadHTMLString:@"" baseURL:nil];
  }];
}
- (void)stop {
 [self hide]; [self releaseView]; ideState(@"stopped");
}
- (void)reload { _loaded = NO; [self show]; }
- (void)detach {
 _pendingRun = nil;
 objc_setAssociatedObject(_window, NSSelectorFromString(@"doraIDEKeyEvent:"), nil, OBJC_ASSOCIATION_ASSIGN);
 [NSNotificationCenter.defaultCenter removeObserver:self];
 [NSObject cancelPreviousPerformRequestsWithTarget:self];
 if (_keyMonitor) [NSEvent removeMonitor:_keyMonitor]; _keyMonitor = nil;
 [self releaseView]; [_overlay removeFromSuperview];
}
- (void)userContentController:(WKUserContentController*)controller didReceiveScriptMessage:(WKScriptMessage*)message {
 if (message.webView != _view || !message.frameInfo.mainFrame || ![message.body isKindOfClass:NSString.class]) return;
 NSURL* url = message.frameInfo.request.URL;
 if (![url.host isEqualToString:@"localhost"] || url.port.intValue != 8866 || ![url.scheme isEqualToString:@"http"]) return;
 NSArray<NSString*>* parts = [message.body componentsSeparatedByString:@":"];
 if (parts.count != 3 || ![parts[0] isEqualToString:@"dora-ide-run"] || parts[2].length == 0) return;
 if ([parts[1] isEqualToString:@"start"]) { _pendingRun = _visible ? parts[2] : nil; return; }
 if (![_pendingRun isEqualToString:parts[2]]) return;
 if ([parts[1] isEqualToString:@"cancel"]) { _pendingRun = nil; return; }
 if (![parts[1] isEqualToString:@"success"]) return;
 // Leave the browser callback before changing focus and cancelling composition.
 dispatch_async(dispatch_get_main_queue(), ^{
  if (self.visible && [self.pendingRun isEqualToString:parts[2]] && Dora::Singleton<Dora::Application>::shared().isWebIDEEnabled()) [self hide];
 });
}
- (void)webView:(WKWebView*)view didFailProvisionalNavigation:(WKNavigation*)navigation withError:(NSError*)error {
	if (view == _view && error.code != NSURLErrorCancelled) ideState(@"failed", error.localizedDescription);
}
- (void)webView:(WKWebView*)view didFailNavigation:(WKNavigation*)navigation withError:(NSError*)error {
	if (view == _view && error.code != NSURLErrorCancelled) ideState(@"failed", error.localizedDescription);
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView*)view {
 if (view != _view) return;
	_loaded = NO;
	ideState(@"failed", @"Web IDE process terminated; reload to reconnect.");
}
- (void)webView:(WKWebView*)view decidePolicyForNavigationAction:(WKNavigationAction*)action decisionHandler:(void (^)(WKNavigationActionPolicy))handler {
	if (view != _view) { handler(WKNavigationActionPolicyCancel); return; }
	NSURL* url = action.request.URL;
 if (action.targetFrame.mainFrame) _pendingRun = nil;
	BOOL local = [url.host isEqualToString:@"localhost"] && url.port.intValue == 8866 && [url.scheme isEqualToString:@"http"];
	if ([url.absoluteString isEqualToString:@"about:blank"]) { handler(WKNavigationActionPolicyAllow); return; }
	if (@available(macOS 11.3, *)) {
		if (action.shouldPerformDownload && (local || [url.scheme isEqualToString:@"blob"])) { handler(WKNavigationActionPolicyDownload); return; }
	}
	if (local) handler(WKNavigationActionPolicyAllow);
	else {
		if ([url.scheme isEqualToString:@"https"] || [url.scheme isEqualToString:@"http"]) [[NSWorkspace sharedWorkspace] openURL:url];
		handler(WKNavigationActionPolicyCancel);
	}
}
- (void)webView:(WKWebView*)view decidePolicyForNavigationResponse:(WKNavigationResponse*)response decisionHandler:(void (^)(WKNavigationResponsePolicy))handler {
	if (@available(macOS 11.3, *)) {
		if (!response.canShowMIMEType) { handler(WKNavigationResponsePolicyDownload); return; }
	}
	handler(WKNavigationResponsePolicyAllow);
}
- (WKWebView*)webView:(WKWebView*)view createWebViewWithConfiguration:(WKWebViewConfiguration*)configuration forNavigationAction:(WKNavigationAction*)action windowFeatures:(WKWindowFeatures*)features {
	NSURL* url = action.request.URL;
	if ([url.host isEqualToString:@"localhost"] && url.port.intValue == 8866) [view loadRequest:action.request];
	else if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) [[NSWorkspace sharedWorkspace] openURL:url];
	return nil;
}
- (void)webView:(WKWebView*)view runOpenPanelWithParameters:(WKOpenPanelParameters*)parameters initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(NSArray<NSURL*>*))completionHandler {
	NSOpenPanel* panel = [NSOpenPanel openPanel];
	panel.allowsMultipleSelection = parameters.allowsMultipleSelection;
	panel.canChooseDirectories = parameters.allowsDirectories;
	panel.canChooseFiles = YES;
	[panel beginSheetModalForWindow:_window completionHandler:^(NSModalResponse result) { completionHandler(result == NSModalResponseOK ? panel.URLs : nil); }];
}
- (void)webView:(WKWebView*)view navigationAction:(WKNavigationAction*)action didBecomeDownload:(WKDownload*)download API_AVAILABLE(macos(11.3)) { download.delegate = self; }
- (void)webView:(WKWebView*)view navigationResponse:(WKNavigationResponse*)response didBecomeDownload:(WKDownload*)download API_AVAILABLE(macos(11.3)) { download.delegate = self; }
- (void)download:(WKDownload*)download decideDestinationUsingResponse:(NSURLResponse*)response suggestedFilename:(NSString*)filename completionHandler:(void (^)(NSURL*))completionHandler API_AVAILABLE(macos(11.3)) {
	NSSavePanel* panel = [NSSavePanel savePanel];
	panel.nameFieldStringValue = filename.lastPathComponent;
	[panel beginSheetModalForWindow:_window completionHandler:^(NSModalResponse result) { completionHandler(result == NSModalResponseOK ? panel.URL : nil); }];
}
- (void)download:(WKDownload*)download didFailWithError:(NSError*)error resumeData:(NSData*)resumeData API_AVAILABLE(macos(11.3)) {
	if (![error.domain isEqualToString:NSURLErrorDomain] || error.code != NSURLErrorCancelled)
		ideState(@"failed", error.localizedDescription);
}
- (void)webView:(WKWebView*)view runJavaScriptAlertPanelWithMessage:(NSString*)message initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(void))completionHandler {
	NSAlert* alert = [[NSAlert alloc] init]; alert.messageText = message;
	[alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse response) { completionHandler(); }];
}
- (void)webView:(WKWebView*)view runJavaScriptConfirmPanelWithMessage:(NSString*)message initiatedByFrame:(WKFrameInfo*)frame completionHandler:(void (^)(BOOL))completionHandler {
	NSAlert* alert = [[NSAlert alloc] init]; alert.messageText = message;
	[alert addButtonWithTitle:@"OK"]; [alert addButtonWithTitle:@"Cancel"];
	[alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse response) { completionHandler(response == NSAlertFirstButtonReturn); }];
}
@end
static DoraIDEHost* ideHost;
NS_DORA_BEGIN
void Application::setIDEWebView(const std::string& requestedAction) {
 if (requestedAction == "disable") { [ideHost hide]; closeIDEWebView(); ideState(@"stopped"); return; }
 if (!isWebIDEEnabled()) return;
 const std::string action = requestedAction == "toggle" ? (isIDEWebViewVisible() ? "hide" : "show") : requestedAction;
 if (!ideHost && (action == "attach" || action == "show" || action == "reload")) {
  SDL_SysWMinfo info; SDL_VERSION(&info.version);
  if (!SDL_GetWindowWMInfo(_sdlWindow, &info)) return;
  ideHost = [[DoraIDEHost alloc] initWithWindow:info.info.cocoa.window];
 }
 if (action == "show") [ideHost show];
 else if (action == "hide") [ideHost hide];
 else if (action == "stop") [ideHost stop];
 else if (action == "reload") [ideHost reload];
}
void Application::closeIDEWebView() { [ideHost detach]; ideHost = nil; setIDEWebViewVisible(false); }
void Application::pumpIDEWebViewEvents() {
	@autoreleasepool {
		// SDL's nonblocking event poll does not give WebKit/CA a waiting run-loop
		// turn. Service native sources and commit layers independently of bgfx.
		// Keep servicing pending WebKit completions after hiding/closing the IDE.
		// Poll without waiting when the engine owns the screen.
		if (isIDEWebViewVisible()) {
			// Native input and WebKit IPC can wake this wait immediately. The
			// short deadline also keeps engine frames and render commands moving
			// without alternating a bgfx timeout with a second Cocoa timeout.
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.004, true);
		} else {
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
		}
	}
}
NS_DORA_END
NS_DORA_BEGIN
void Application::closeCompilerWebView() {
	if (!compilerWebView) return;
	[compilerWebView.configuration.userContentController removeScriptMessageHandlerForName:@"compilerLog"];
	compilerWebView.navigationDelegate = nil;
	[compilerWebView stopLoading];
	[compilerWebView removeFromSuperview];
	compilerWebView = nil;
	compilerNavigation = nil;
	Info("TypeScript compiler WebView closed");
}

void Application::setCompilerWebView(const std::string& path, bool enabled) {
	if (path != "/compiler.html") return;
	if (!enabled) { closeCompilerWebView(); return; }
	if (compilerWebView) return;
	@autoreleasepool {
		SDL_SysWMinfo info;
		SDL_VERSION(&info.version);
		if (!SDL_GetWindowWMInfo(_sdlWindow, &info)) {
			compilerFailure(@"Cannot find compiler WebView host window");
			return;
		}
		WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
		config.websiteDataStore = [WKWebsiteDataStore nonPersistentDataStore];
		if (@available(macOS 14.0, *)) {
			config.preferences.inactiveSchedulingPolicy = WKInactiveSchedulingPolicyNone;
		}
		compilerNavigation = [[DoraCompilerNavigation alloc] init];
		[config.userContentController addScriptMessageHandler:compilerNavigation name:@"compilerLog"];
		NSString* logging = @"for (const level of ['info','warn','error']) { const original = console[level]; console[level] = (...args) => { window.webkit.messageHandlers.compilerLog.postMessage(level + ': ' + args.map(String).join(' ')); original.apply(console, args); }; } window.addEventListener('error', e => window.webkit.messageHandlers.compilerLog.postMessage('error: ' + e.message));";
		[config.userContentController addUserScript:[[WKUserScript alloc] initWithSource:logging injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
		compilerWebView = [[WKWebView alloc] initWithFrame:NSMakeRect(0, 0, 1, 1) configuration:config];
		compilerWebView.navigationDelegate = compilerNavigation;
		compilerWebView.alphaValue = 0;
		[info.info.cocoa.window.contentView addSubview:compilerWebView];
		[compilerWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8866/compiler.html"]]];
		Info("TypeScript compiler WebView started");
	}
}
NS_DORA_END
#endif

#if BX_PLATFORM_IOS

#include "SDL.h"
#include "SDL_syswm.h"
#import "3rdParty/SDL2/src/video/uikit/SDL_uikitappdelegate.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <QuartzCore/CAMetalLayer.h>
#import <Metal/Metal.h>
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
void Application::openFileDialog(bool folderOnly, const std::function<void(std::string)>& callback, String extensions) {
	DORA_UNUSED_PARAM(extensions); // The mobile document picker remains ZIP-only.
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

bool validateIOSMetalDevice(void *native, std::string &reason) {
    id<MTLDevice> device = (__bridge id<MTLDevice>)native;
    if (!device) {
        reason = "Dora requires a Metal device on iOS";
        return false;
    }
    if (![device supportsFamily:MTLGPUFamilyApple2]) {
        reason = "Dora requires an Apple2 or newer Metal GPU on iOS";
        return false;
    }
    // Optional embedded runtimes independently validate their GPU needs.
    return true;
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
