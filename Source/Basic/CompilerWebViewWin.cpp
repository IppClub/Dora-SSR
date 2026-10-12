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
#pragma pop_macro("interface")
#include <filesystem>

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
#endif
