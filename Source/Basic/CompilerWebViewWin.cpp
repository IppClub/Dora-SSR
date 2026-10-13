/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#if BX_PLATFORM_WINDOWS
#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Event/Event.h"
#include "SDL.h"
#include "SDL_syswm.h"
// The engine's lean Windows headers do not expose MIDL's interface macro.
#pragma push_macro("interface")
#ifndef interface
#define interface struct
#endif
#include <WebView2.h>
#include <WebView2EnvironmentOptions.h>
#include <wrl.h>
#include <shellapi.h>
#include <shobjidl.h>
#pragma pop_macro("interface")
#include <filesystem>
#include <deque>

namespace {
using Microsoft::WRL::Callback;
using Microsoft::WRL::ComPtr;
ComPtr<ICoreWebView2Controller> compilerController;
ComPtr<ICoreWebView2> compilerView;
uint64_t compilerGeneration = 0;
bool compilerRequested = false;
bool compilerCOM = false;

void compilerFailure(const std::string& message) {
	Dora::Singleton<Dora::Application>::shared().invokeInLogic([message]() {
		Dora::Event::send(std::string_view("AppCompilerFailure"), message);
	});
}
}

NS_DORA_BEGIN
void Application::closeCompilerWebView() {
	++compilerGeneration;
	compilerRequested = false;
	if (compilerController) compilerController->Close();
	compilerView.Reset();
	compilerController.Reset();
	if (compilerCOM) { CoUninitialize(); compilerCOM = false; }
	Info("TypeScript compiler WebView closed");
}

void Application::setCompilerWebView(const std::string& path, bool enabled) {
	if (path != "/compiler.html") return;
	if (!enabled) { closeCompilerWebView(); return; }
	if (compilerRequested) return;
	const HRESULT initialized = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
	if (FAILED(initialized)) {
		compilerFailure("Cannot initialize WebView2 on the window STA thread");
		return;
	}
	compilerCOM = true;
	auto options = Microsoft::WRL::Make<CoreWebView2EnvironmentOptions>();
	options->put_ReleaseChannels(COREWEBVIEW2_RELEASE_CHANNELS_STABLE);
	LPWSTR version = nullptr;
	const HRESULT available = GetAvailableCoreWebView2BrowserVersionStringWithOptions(nullptr, options.Get(), &version);
	CoTaskMemFree(version);
	if (FAILED(available)) {
		closeCompilerWebView();
		compilerFailure("WebView2 Runtime is not installed. Install Microsoft Evergreen WebView2 Runtime or connect Web IDE.");
		return;
	}
	SDL_SysWMinfo info;
	SDL_VERSION(&info.version);
	if (!SDL_GetWindowWMInfo(_sdlWindow, &info)) {
		closeCompilerWebView();
		compilerFailure("Cannot find compiler WebView2 host window");
		return;
	}
	const HWND parent = info.info.win.window;
	// Workspace paths may point at network shares. WebView2's user data stays
	// in the local application profile independently of the current project.
	const auto profile = (std::filesystem::u8path(SharedContent.getAppPath()) / "compiler-webview2").wstring();
	compilerRequested = true;
	const uint64_t generation = ++compilerGeneration;
	// Null browserExecutableFolder selects the installed shared Runtime. Never
	// distribute a browser or search private Edge installation directories.
	const HRESULT started = CreateCoreWebView2EnvironmentWithOptions(nullptr, profile.c_str(), options.Get(),
		Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
			[generation, parent](HRESULT result, ICoreWebView2Environment* environment) -> HRESULT {
				if (generation != compilerGeneration) return S_OK;
				if (FAILED(result) || !environment) {
					compilerFailure("Failed to initialize the installed WebView2 Runtime");
					return S_OK;
				}
				const HRESULT creating = environment->CreateCoreWebView2Controller(parent,
					Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
						[generation](HRESULT result, ICoreWebView2Controller* controller) -> HRESULT {
							if (generation != compilerGeneration) {
								if (controller) controller->Close();
								return S_OK;
							}
							if (FAILED(result) || !controller) {
								compilerFailure("Failed to create compiler WebView2 controller");
								return S_OK;
							}
							compilerController = controller;
							if (FAILED(controller->get_CoreWebView2(&compilerView)) || !compilerView) {
								compilerFailure("Cannot obtain compiler WebView2 instance");
								return S_OK;
							}
							controller->put_Bounds(RECT{0, 0, 1, 1});
							controller->put_IsVisible(FALSE);
							ComPtr<ICoreWebView2Settings> settings;
							if (SUCCEEDED(compilerView->get_Settings(&settings)) && settings) {
								settings->put_AreDevToolsEnabled(FALSE);
								settings->put_AreDefaultContextMenusEnabled(FALSE);
							}
							EventRegistrationToken token;
							compilerView->add_NavigationStarting(Callback<ICoreWebView2NavigationStartingEventHandler>(
								[](ICoreWebView2*, ICoreWebView2NavigationStartingEventArgs* args) -> HRESULT {
									LPWSTR uri = nullptr;
									args->get_Uri(&uri);
									const bool allowed = uri && std::wstring(uri) == L"http://localhost:8866/compiler.html";
									CoTaskMemFree(uri);
									args->put_Cancel(!allowed);
									return S_OK;
								}).Get(), &token);
							compilerView->add_NavigationCompleted(Callback<ICoreWebView2NavigationCompletedEventHandler>(
								[generation](ICoreWebView2*, ICoreWebView2NavigationCompletedEventArgs* args) -> HRESULT {
									if (generation != compilerGeneration) return S_OK;
									BOOL success = FALSE;
									args->get_IsSuccess(&success);
									if (!success) compilerFailure("Failed to load TypeScript compiler page");
									return S_OK;
								}).Get(), &token);
							compilerView->add_ProcessFailed(Callback<ICoreWebView2ProcessFailedEventHandler>(
								[generation](ICoreWebView2*, ICoreWebView2ProcessFailedEventArgs*) -> HRESULT {
									if (generation == compilerGeneration) compilerFailure("TypeScript compiler WebView2 process failed");
									return S_OK;
								}).Get(), &token);
							const HRESULT navigated = compilerView->Navigate(L"http://localhost:8866/compiler.html");
							if (FAILED(navigated)) compilerFailure("Cannot navigate to TypeScript compiler page");
							Info("TypeScript compiler WebView started");
							return S_OK;
						}).Get());
				if (FAILED(creating)) compilerFailure("Cannot create compiler WebView2 controller");
				return S_OK;
			}).Get());
	if (FAILED(started)) compilerFailure("Cannot start the installed WebView2 Runtime");
}
NS_DORA_END


namespace {
HWND ideWindow = nullptr, ideHandle = nullptr, ideMenu = nullptr, ideStatus = nullptr;
WNDPROC ideOriginalProc = nullptr;
bool ideVisible = false;
constexpr UINT_PTR ideMenuTimer = 0xD04A;
HFONT ideFont = nullptr;
ComPtr<ICoreWebView2Controller> ideController;
ComPtr<ICoreWebView2> ideView;
uint64_t ideGeneration = 0;
bool ideCOM = false, ideStarting = false, ideLoaded = false, ideSessionRequested = false;
constexpr UINT ideDownloadMessage = WM_APP + 61;
constexpr UINT ideResetMessage = WM_APP + 62;
uint64_t ideResetGeneration = 0;
struct IDEDownload {
	ComPtr<ICoreWebView2DownloadStartingEventArgs> args;
	ComPtr<ICoreWebView2Deferral> deferral;
};
std::deque<IDEDownload> ideDownloads;
UINT ideWindowDPI(HWND window) {
	using GetDPI = UINT(WINAPI*)(HWND);
	static auto getDPI = reinterpret_cast<GetDPI>(GetProcAddress(GetModuleHandleW(L"user32.dll"), "GetDpiForWindow"));
	const UINT dpi = getDPI ? getDPI(window) : 96;
	return dpi ? dpi : 96;
}

void ideState(const std::string& state, const std::string& message = {}) {
	Dora::Singleton<Dora::Application>::shared().invokeInLogic([state, message]() {
		Dora::Event::send(std::string_view("AppIDEState"), state, message);
	});
	if (message.empty() && ideStatus) { SetWindowTextW(ideStatus, L""); ShowWindow(ideStatus, SW_HIDE); }
	if (!message.empty()) {
		std::wstring text = std::filesystem::u8path(message).wstring();
		if (ideStatus) { SetWindowTextW(ideStatus, text.c_str()); ShowWindow(ideStatus, ideVisible ? SW_SHOW : SW_HIDE); }
		Error("Web IDE: {}", message);
	}
}
void ideLayout() {
 if (!ideWindow) return;
 const UINT dpi = ideWindowDPI(ideWindow);
 const auto dip = [dpi](int value) { return MulDiv(value, dpi, 96); };
 RECT bounds; GetClientRect(ideWindow, &bounds);
 if (ideController) ideController->put_Bounds(bounds);
 // Keep the switching entry reachable when a saved window size extends
 // beyond the current monitor, without changing the user's window settings.
 RECT visible = bounds, screen = bounds;
 MapWindowPoints(ideWindow, nullptr, reinterpret_cast<POINT*>(&screen), 2);
 MONITORINFO monitor{sizeof(MONITORINFO)};
 if (GetMonitorInfoW(MonitorFromWindow(ideWindow, MONITOR_DEFAULTTONEAREST), &monitor)) {
  RECT clipped;
  if (IntersectRect(&clipped, &screen, &monitor.rcWork)) {
   MapWindowPoints(nullptr, ideWindow, reinterpret_cast<POINT*>(&clipped), 2);
   visible = clipped;
  }
 }
 const int rows = ideVisible || ideLoaded ? 2 : 1;
 SetWindowPos(ideHandle, HWND_TOP, visible.right - dip(20), (visible.top + visible.bottom - dip(60)) / 2, dip(20), dip(60), SWP_NOACTIVATE);
 SetWindowPos(ideMenu, HWND_TOP, std::max(visible.left, visible.right - dip(116)), (visible.top + visible.bottom - dip(24 + 46 * rows)) / 2, dip(94), dip(24 + 46 * rows), SWP_NOACTIVATE);
 SetWindowPos(ideStatus, HWND_TOP, dip(24), dip(12), std::max(1L, bounds.right - dip(48)), dip(32), SWP_NOACTIVATE);
 if (ideFont) DeleteObject(ideFont);
 ideFont = CreateFontW(-dip(12), 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, DEFAULT_CHARSET,
  OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, L"Segoe UI");
 SendMessageW(ideStatus, WM_SETFONT, (WPARAM)ideFont, TRUE);
 InvalidateRect(ideHandle, nullptr, TRUE); InvalidateRect(ideMenu, nullptr, TRUE);
}
void ideAction(const std::string& action);
void ideCollapseMenu() {
 KillTimer(ideWindow, ideMenuTimer); ShowWindow(ideMenu, SW_HIDE);
 if (ideVisible && ideController) ideController->MoveFocus(COREWEBVIEW2_MOVE_FOCUS_REASON_PROGRAMMATIC);
 else if (ideWindow) SetFocus(ideWindow);
}
LRESULT CALLBACK ideOverlayProc(HWND window, UINT message, WPARAM wParam, LPARAM lParam) {
 const bool menu = window == ideMenu;
 const UINT dpi = ideWindowDPI(window);
 const auto dip = [dpi](int value) { return MulDiv(value, dpi, 96); };
 switch (message) {
  case WM_PAINT: {
   PAINTSTRUCT paint; HDC dc = BeginPaint(window, &paint);
   RECT bounds; GetClientRect(window, &bounds);
   HBRUSH background = CreateSolidBrush(RGB(43, 43, 43));
   FillRect(dc, &bounds, background); DeleteObject(background);
   SetBkMode(dc, TRANSPARENT); SetTextColor(dc, RGB(242, 242, 242));
   HFONT font = menu ? ideFont : CreateFontW(-dip(8),0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,DEFAULT_PITCH,L"Segoe UI");
   HGDIOBJ previous = SelectObject(dc, font);
   if (!menu) DrawTextW(dc, ideVisible ? L"M\nE\nN\nU" : L"I\nD\nE", -1, &bounds, DT_CENTER | DT_NOCLIP);
   else {
    const bool zh = std::string(Dora::Singleton<Dora::Application>::shared().getLocale()).starts_with("zh");
    const wchar_t* labels[] = {ideVisible ? (zh ? L"引擎" : L"Engine") : L"IDE", ideVisible ? (zh ? L"重载" : L"Reload") : (zh ? L"停止" : L"Stop")};
    for (int i = 0; i < (ideVisible || ideLoaded ? 2 : 1); ++i) {
     RECT row{dip(8),dip(12+46*i),bounds.right-dip(8),dip(50+46*i)};
     HBRUSH button = CreateSolidBrush(RGB(54,54,54)); FillRect(dc,&row,button); DeleteObject(button);
     DrawTextW(dc, labels[i],-1,&row,DT_CENTER|DT_VCENTER|DT_SINGLELINE);
    }
   }
   SelectObject(dc, previous); if (!menu) DeleteObject(font);
   EndPaint(window, &paint); return 0;
  }
  case WM_LBUTTONUP:
   if (!menu) {
    if (IsWindowVisible(ideMenu)) ideCollapseMenu();
    else { ideLayout(); ShowWindow(ideMenu, SW_SHOWNOACTIVATE); SetTimer(ideWindow,ideMenuTimer,3500,nullptr); }
   } else {
    const int y = (short)HIWORD(lParam);
    const int row = (y - dip(12)) / dip(46);
    if (y >= dip(12) && row == 0) Dora::Singleton<Dora::Application>::shared().setIDEWebView(ideVisible ? "hide" : "show");
    else if (row == 1 && (ideVisible || ideLoaded)) Dora::Singleton<Dora::Application>::shared().setIDEWebView(ideVisible ? "reload" : "stop");
    ideCollapseMenu();
   }
   return 0;
 }
 return DefWindowProcW(window,message,wParam,lParam);
}

void ideSaveDownload(IDEDownload& task) {
	ComPtr<IFileSaveDialog> dialog;
	HRESULT result = CoCreateInstance(CLSID_FileSaveDialog, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&dialog));
	LPWSTR suggested = nullptr;
	task.args->get_ResultFilePath(&suggested);
	if (SUCCEEDED(result)) {
		std::wstring filename = suggested ? std::filesystem::path(suggested).filename().wstring() : L"download";
		dialog->SetFileName(filename.c_str());
		dialog->SetOptions(FOS_OVERWRITEPROMPT | FOS_FORCEFILESYSTEM | FOS_PATHMUSTEXIST);
		result = dialog->Show(ideWindow);
		if (SUCCEEDED(result)) {
			ComPtr<IShellItem> item;
			LPWSTR path = nullptr;
			result = dialog->GetResult(&item);
			if (SUCCEEDED(result)) result = item->GetDisplayName(SIGDN_FILESYSPATH, &path);
			if (SUCCEEDED(result)) task.args->put_ResultFilePath(path);
			CoTaskMemFree(path);
		}
	}
	CoTaskMemFree(suggested);
	if (FAILED(result)) task.args->put_Cancel(TRUE);
	task.args->put_Handled(TRUE);
	task.deferral->Complete();
}
LRESULT CALLBACK ideWindowProc(HWND window, UINT message, WPARAM wParam, LPARAM lParam) {
 switch (message) {
  case WM_TIMER: if (wParam == ideMenuTimer) { ideCollapseMenu(); return 0; } break;
  case WM_COMMAND:
   if (LOWORD(wParam) == 101) { ideAction("hide"); return 0; }
   if (LOWORD(wParam) == 103) { Dora::Singleton<Dora::Application>::shared().setIDEWebView("reload"); return 0; }
   break;
  case WM_SIZE: case WM_DPICHANGED: {
   LRESULT result = CallWindowProcW(ideOriginalProc, window, message, wParam, lParam);
   ideLayout(); return result;
  }
  case WM_MOVE: {
   LRESULT result = CallWindowProcW(ideOriginalProc, window, message, wParam, lParam);
   if (ideController) ideController->NotifyParentWindowPositionChanged();
   ideLayout(); return result;
  }
  case WM_SETFOCUS:
   if (ideVisible && ideController) { ideController->MoveFocus(COREWEBVIEW2_MOVE_FOCUS_REASON_PROGRAMMATIC); return 0; }
   break;
  case ideDownloadMessage:
   if (!ideDownloads.empty()) { auto task = std::move(ideDownloads.front()); ideDownloads.pop_front(); ideSaveDownload(task); }
   return 0;
  case ideResetMessage:
   if (ideResetGeneration == ideGeneration) {
    ++ideGeneration;
    for (auto& task : ideDownloads) { task.args->put_Cancel(TRUE); task.deferral->Complete(); }
    ideDownloads.clear();
    if (ideController) ideController->Close();
    ideView.Reset(); ideController.Reset(); ideStarting = false; ideLoaded = false;
   }
   return 0;
 }
 return CallWindowProcW(ideOriginalProc, window, message, wParam, lParam);
}
void ideAction(const std::string& action) {
 if (!ideWindow) return;
 if (action == "hide" || action == "stop") {
  ideVisible = false;
  if (action == "stop") {
   ideSessionRequested = false; ideLoaded = false;
   if (ideView) { ideView->Stop(); ideView->Navigate(L"about:blank"); }
  }
  if (ideController) ideController->put_IsVisible(FALSE);
  ShowWindow(ideStatus, SW_HIDE);
  ideLayout(); ideCollapseMenu(); ideState(action == "stop" ? "stopped" : "hidden"); return;
 }
 if (action == "show" || action == "reload") {
  ideSessionRequested = true; ideVisible = true;
  ShowWindow(ideWindow, SW_SHOW); SetForegroundWindow(ideWindow);
  if (ideController) { ideController->put_IsVisible(TRUE); ideController->MoveFocus(COREWEBVIEW2_MOVE_FOCUS_REASON_PROGRAMMATIC); }
  if (ideView && (!ideLoaded || action == "reload")) { ideLoaded = true; ideView->Navigate(L"http://localhost:8866/"); }
  ideLayout(); ideCollapseMenu(); ideState("visible");
 }
}
bool ideLocalURL(const std::wstring& url) {
	return url == L"about:blank" || url == L"http://localhost:8866" || url.starts_with(L"http://localhost:8866/") || url.starts_with(L"blob:http://localhost:8866/");
}
void ideExternalURL(const std::wstring& url) {
	if (url.starts_with(L"https://") || url.starts_with(L"http://")) ShellExecuteW(ideWindow, L"open", url.c_str(), nullptr, nullptr, SW_SHOWNORMAL);
}
}
NS_DORA_BEGIN
bool Application::isIDEWebViewVisible() const { return ideVisible; }
void Application::closeIDEWebView() {
	++ideGeneration;
	for (auto& task : ideDownloads) { task.args->put_Cancel(TRUE); task.deferral->Complete(); }
	ideDownloads.clear();
	if (ideController) ideController->Close();
	ideView.Reset(); ideController.Reset();
	if (ideWindow) {
  KillTimer(ideWindow, ideMenuTimer);
  if (ideOriginalProc) SetWindowLongPtrW(ideWindow, GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(ideOriginalProc));
 }
 if (ideHandle) DestroyWindow(ideHandle);
 if (ideMenu) DestroyWindow(ideMenu);
 if (ideStatus) DestroyWindow(ideStatus);
 ideHandle = ideMenu = ideStatus = nullptr; ideOriginalProc = nullptr; ideVisible = false;
	if (ideFont) DeleteObject(ideFont);
	ideFont = nullptr;
	ideWindow = nullptr; ideStarting = false; ideLoaded = false; ideSessionRequested = false;
	if (ideCOM) { CoUninitialize(); ideCOM = false; }
}
void Application::setIDEWebView(const std::string& action) {
	if (action != "attach" && action != "show" && action != "reload") { ideAction(action); return; }
	if (!ideWindow) {
		if (FAILED(CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED))) { ideState("failed", "Cannot initialize Web IDE on the window STA thread"); return; }
		ideCOM = true;
  SDL_SysWMinfo info; SDL_VERSION(&info.version);
  if (!SDL_GetWindowWMInfo(_sdlWindow, &info)) { closeIDEWebView(); return; }
  ideWindow = info.info.win.window;
  ideOriginalProc = reinterpret_cast<WNDPROC>(SetWindowLongPtrW(ideWindow, GWLP_WNDPROC, reinterpret_cast<LONG_PTR>(ideWindowProc)));
  WNDCLASSW type{}; type.lpfnWndProc = ideOverlayProc; type.hInstance = GetModuleHandleW(nullptr);
  type.hCursor = LoadCursor(nullptr, IDC_HAND); type.lpszClassName = L"DoraWebIDESidePane";
  RegisterClassW(&type);
  ideHandle = CreateWindowExW(WS_EX_LAYERED | WS_EX_NOACTIVATE, type.lpszClassName, L"IDE", WS_CHILD | WS_VISIBLE,
   0,0,20,60,ideWindow,nullptr,type.hInstance,nullptr);
  DWORD overlayError = ideHandle ? ERROR_SUCCESS : GetLastError();
  ideMenu = CreateWindowExW(WS_EX_LAYERED | WS_EX_NOACTIVATE, type.lpszClassName, L"IDE Menu", WS_CHILD,
   0,0,94,116,ideWindow,nullptr,type.hInstance,nullptr);
  if (!ideMenu && !overlayError) overlayError = GetLastError();
  if (!ideHandle || !ideMenu) {
   closeIDEWebView();
   ideState("failed", "Cannot create Web IDE switching controls: " + std::to_string(overlayError));
   return;
  }
  SetLayeredWindowAttributes(ideHandle,0,61,LWA_ALPHA);
  SetLayeredWindowAttributes(ideMenu,0,224,LWA_ALPHA);
  ideStatus = CreateWindowW(L"STATIC",L"",WS_CHILD,24,12,400,32,ideWindow,nullptr,type.hInstance,nullptr);
  ideLayout();
 }
	if (action == "attach") return;
	ideAction(action);
	if (ideView || ideStarting) return;
	ideStarting = true;
	const uint64_t generation = ++ideGeneration;
	auto options = Microsoft::WRL::Make<CoreWebView2EnvironmentOptions>();
	options->put_ReleaseChannels(COREWEBVIEW2_RELEASE_CHANNELS_STABLE);
	const auto profile = (std::filesystem::u8path(SharedContent.getAppPath()) / "ide-webview2").wstring();
	const HRESULT started = CreateCoreWebView2EnvironmentWithOptions(nullptr, profile.c_str(), options.Get(),
		Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>([generation](HRESULT result, ICoreWebView2Environment* environment) -> HRESULT {
			if (generation != ideGeneration) return S_OK;
			if (FAILED(result) || !environment) { ideStarting = false; ideState("failed", "Cannot start the installed WebView2 Runtime. Install Evergreen Runtime or use an external browser."); return S_OK; }
			const HRESULT creating = environment->CreateCoreWebView2Controller(ideWindow,
				Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>([generation](HRESULT result, ICoreWebView2Controller* controller) -> HRESULT {
					if (generation != ideGeneration) { if (controller) controller->Close(); return S_OK; }
					ideStarting = false;
					if (FAILED(result) || !controller) { ideState("failed", "Cannot create Web IDE WebView2 controller"); return S_OK; }
					ideController = controller;
					if (FAILED(controller->get_CoreWebView2(&ideView)) || !ideView) { ideState("failed", "Cannot obtain Web IDE WebView2"); return S_OK; }
					ComPtr<ICoreWebView2Settings> settings;
					if (SUCCEEDED(ideView->get_Settings(&settings)) && settings) {
						ComPtr<ICoreWebView2Settings3> keys;
						if (SUCCEEDED(settings.As(&keys))) keys->put_AreBrowserAcceleratorKeysEnabled(FALSE);
					}
					ideLayout();
					EventRegistrationToken token;
					ideView->add_NavigationStarting(Callback<ICoreWebView2NavigationStartingEventHandler>([generation](ICoreWebView2*, ICoreWebView2NavigationStartingEventArgs* args) -> HRESULT {
						if (generation != ideGeneration) { args->put_Cancel(TRUE); return S_OK; }
						LPWSTR uri = nullptr; args->get_Uri(&uri); std::wstring url = uri ? uri : L""; CoTaskMemFree(uri);
						if (!ideLocalURL(url)) { args->put_Cancel(TRUE); ideExternalURL(url); }
						return S_OK;
					}).Get(), &token);
					ideView->add_NewWindowRequested(Callback<ICoreWebView2NewWindowRequestedEventHandler>([generation](ICoreWebView2*, ICoreWebView2NewWindowRequestedEventArgs* args) -> HRESULT {
						args->put_Handled(TRUE);
						if (generation != ideGeneration) return S_OK;
						LPWSTR uri = nullptr; args->get_Uri(&uri); std::wstring url = uri ? uri : L""; CoTaskMemFree(uri);
						if (ideLocalURL(url)) ideView->Navigate(url.c_str()); else ideExternalURL(url); return S_OK;
					}).Get(), &token);
					ideView->add_ProcessFailed(Callback<ICoreWebView2ProcessFailedEventHandler>([generation](ICoreWebView2*, ICoreWebView2ProcessFailedEventArgs* args) -> HRESULT {
						if (generation == ideGeneration) {
							ideLoaded = false; ideState("failed", "Web IDE process failed; reload to reconnect.");
							COREWEBVIEW2_PROCESS_FAILED_KIND kind;
							if (SUCCEEDED(args->get_ProcessFailedKind(&kind)) && kind == COREWEBVIEW2_PROCESS_FAILED_KIND_BROWSER_PROCESS_EXITED) {
								ideResetGeneration = generation; PostMessageW(ideWindow, ideResetMessage, 0, 0);
							}
						}
						return S_OK;
					}).Get(), &token);
					ideController->add_AcceleratorKeyPressed(Callback<ICoreWebView2AcceleratorKeyPressedEventHandler>([generation](ICoreWebView2Controller*, ICoreWebView2AcceleratorKeyPressedEventArgs* args) -> HRESULT {
						if (generation != ideGeneration) return S_OK;
						COREWEBVIEW2_KEY_EVENT_KIND kind; UINT key;
						args->get_KeyEventKind(&kind); args->get_VirtualKey(&key);
						if ((kind == COREWEBVIEW2_KEY_EVENT_KIND_KEY_DOWN || kind == COREWEBVIEW2_KEY_EVENT_KIND_SYSTEM_KEY_DOWN) && (GetKeyState(VK_CONTROL) & 0x8000) && !(GetKeyState(VK_MENU) & 0x8000)) {
							const bool shift = (GetKeyState(VK_SHIFT) & 0x8000) != 0;
							if (shift && (key == 'H' || key == 'L')) { args->put_Handled(TRUE); PostMessageW(ideWindow, WM_COMMAND, key == 'H' ? 101 : 103, 0); }
						}
						return S_OK;
					}).Get(), &token);
					ComPtr<ICoreWebView2_4> downloads;
					if (SUCCEEDED(ideView.As(&downloads))) downloads->add_DownloadStarting(Callback<ICoreWebView2DownloadStartingEventHandler>([generation](ICoreWebView2*, ICoreWebView2DownloadStartingEventArgs* args) -> HRESULT {
						if (generation != ideGeneration) { args->put_Cancel(TRUE); return S_OK; }
						IDEDownload task; task.args = args; args->GetDeferral(&task.deferral);
						if (task.deferral) { ideDownloads.push_back(std::move(task)); PostMessageW(ideWindow, ideDownloadMessage, 0, 0); }
						return S_OK;
					}).Get(), &token);
					// Native browser child HWND owns text/IME input. Only host window
					// commands are intercepted; editing/save/run shortcuts reach the IDE.
					if (ideSessionRequested) {
						ideLoaded = true;
						ideView->Navigate(L"http://localhost:8866/");
					}
					if (ideVisible) ideAction("show");
					return S_OK;
				}).Get());
			if (FAILED(creating)) { ideStarting = false; ideState("failed", "Cannot create Web IDE controller"); }
			return S_OK;
		}).Get());
	if (FAILED(started)) { ideStarting = false; ideState("failed", "Cannot initialize installed WebView2 Runtime"); }
}
NS_DORA_END
#endif
