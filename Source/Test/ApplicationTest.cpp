/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Test/Test.h"
#include "Basic/Application.h"

NS_DORA_BEGIN

#if DORA_TEST

// Test that the Application window is NOT always on top by default
// This allows users to manage windows freely without being forced
// to keep the game engine window above all other windows.
// Users can still enable always-on-top via App.alwaysOnTop = true if needed.
DORA_TEST(Application, DefaultAlwaysOnTopShouldBeFalse) {
	// Verify that newly created Application instances default to alwaysOnTop = false
	// This test documents the expected behavior after fix for issue #43
	auto& app = SharedApplication;

	// Expected: alwaysOnTop should be false by default
	// This allows flexible window management
	DORA_ASSERT(!app.isAlwaysOnTop(), "Application should not be always-on-top by default");

	return true;
}

#endif // DORA_TEST

NS_DORA_END
