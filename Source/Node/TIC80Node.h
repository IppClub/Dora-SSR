/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Sprite.h"

NS_DORA_BEGIN

class TIC80Impl {
public:
	virtual ~TIC80Impl() { }
};

class Scheduler;

class TIC80Node : public Sprite {
public:
	virtual bool init() override;
	virtual void cleanup() override;
	virtual bool update(double deltaTime) override;

	/// Extract code text from a TIC-80 cart file
	static std::string codeFromCart(String cartFile);

	/// Merge resource cart and code file into a .tic cart file
	static bool mergeTic(String outputFile, String resourceCartFile, String codeFile);

	/// Merge PNG cover, resource cart, and optional code file into a .png cart file
	static bool mergePng(String outputFile, String coverPngFile, String resourceCartFile, String codeFile = Slice::Empty);

	CREATE_FUNC_NULLABLE(TIC80Node);

protected:
	TIC80Node(String cartFile, String codeFile = Slice::Empty);

private:
	void updateTexture();
	void setupInputHandlers();
	void handleKeyboardEvent(Event* event);
	void handleControllerEvent(Event* event);
	void handleTouchEvent(Event* event);
	uint8_t mapKeyNameToTIC80Key(String keyName);

	std::string _cartFile;
	std::string _codeFile;
	Own<TIC80Impl> _tic80;
	uint32_t _audioHandle;
	Ref<Scheduler> _scheduler;
	StringMap<int> _keyMap;
	std::mutex _audioMutex; // Protect _tic80->samples.buffer access

	DORA_TYPE_OVERRIDE(TIC80Node);
};

NS_DORA_END
