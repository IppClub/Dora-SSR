/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Sprite.h"

extern "C" {
#include "3rdParty/tic80/tic80.h"
}

NS_DORA_BEGIN

class TIC80AudioSource;
class Scheduler;

class TIC80Node : public Sprite {
public:
	virtual ~TIC80Node();
	virtual bool init() override;
	virtual void cleanup() override;
	virtual bool update(double deltaTime) override;

	CREATE_FUNC_NULLABLE(TIC80Node);

protected:
	TIC80Node(String cartFile);

private:
	void updateTexture();
	void setupInputHandlers();
	void handleKeyboardEvent(Event* event);
	void handleControllerEvent(Event* event);
	void handleTouchEvent(Event* event);
	tic_key mapKeyNameToTIC80Key(String keyName);

	tic80* _tic80;
	std::string _cartFile;
	tic80_input _currentInput;
	uint32_t _audioHandle;
	Own<TIC80AudioSource> _audioSource;
	Ref<Scheduler> _scheduler;
	StringMap<int> _keyMap;
	u64 _counterStart;
	std::mutex _audioMutex; // Protect _tic80->samples.buffer access

	DORA_TYPE_OVERRIDE(TIC80Node);
};

NS_DORA_END

