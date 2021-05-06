/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

union SDL_Event;

NS_DOROTHY_BEGIN

class Event;

typedef Acf::Delegate<void(Event*)> KeyboardHandler;

class Keyboard
{
public:
	virtual ~Keyboard();
	bool init();
	void attachIME(const KeyboardHandler& handler);
	void detachIME();
	bool isIMEAttached() const;
	void updateIMEPosHint(const Vec2& pos);
	bool isKeyDown(String name) const;
	bool isKeyUp(String name) const;
	bool isKeyPressed(String name) const;
	KeyboardHandler KeyHandler;
	void clearChanges();
protected:
	Keyboard();
	void handleEvent(const SDL_Event& event);
private:
	std::vector<int> _changedKeys;
	std::vector<bool> _oldKeyStates;
	std::vector<bool> _newKeyStates;
	std::vector<bool> _oldCodeStates;
	std::vector<bool> _newCodeStates;
	std::vector<Slice> _keyNames;
	std::vector<Slice> _codeNames;
	std::unordered_map<std::string,int> _keyMap;
	std::unordered_map<std::string,int> _codeMap;
	KeyboardHandler _imeHandler;
	SINGLETON_REF(Keyboard, Director);
};

#define SharedKeyboard \
	Dorothy::Singleton<Dorothy::Keyboard>::shared()

NS_DOROTHY_END
