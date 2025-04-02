/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Input/Keyboard.h"

#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Event/Event.h"

#include "SDL.h"

NS_DORA_BEGIN

Keyboard::Keyboard()
	: _oldCodeStates(SDL_NUM_SCANCODES, false)
	, _newCodeStates(SDL_NUM_SCANCODES, false)
	, _oldKeyStates(SDL_NUM_SCANCODES, false)
	, _newKeyStates(SDL_NUM_SCANCODES, false)
	, _keyNames(SDL_NUM_SCANCODES)
	, _codeNames(SDL_NUM_SCANCODES) {
}

Keyboard::~Keyboard() { }

bool Keyboard::init() {
	_keyNames[SDLK_RETURN] = "Return"s;
	_keyNames[SDLK_ESCAPE] = "Escape"s;
	_keyNames[SDLK_BACKSPACE] = "BackSpace"s;
	_keyNames[SDLK_TAB] = "Tab"s;
	_keyNames[SDLK_SPACE] = "Space"s;
	_keyNames[SDLK_EXCLAIM] = "!"s;
	_keyNames[SDLK_QUOTEDBL] = "\""s;
	_keyNames[SDLK_HASH] = "#"s;
	_keyNames[SDLK_PERCENT] = "%"s;
	_keyNames[SDLK_DOLLAR] = "$"s;
	_keyNames[SDLK_AMPERSAND] = "&"s;
	_keyNames[SDLK_QUOTE] = "\'"s;
	_keyNames[SDLK_LEFTPAREN] = "("s;
	_keyNames[SDLK_RIGHTPAREN] = ")"s;
	_keyNames[SDLK_ASTERISK] = "*"s;
	_keyNames[SDLK_PLUS] = "+"s;
	_keyNames[SDLK_COMMA] = ","s;
	_keyNames[SDLK_MINUS] = "-"s;
	_keyNames[SDLK_PERIOD] = "."s;
	_keyNames[SDLK_SLASH] = "/"s;

	_keyNames[SDLK_1] = "1"s;
	_keyNames[SDLK_2] = "2"s;
	_keyNames[SDLK_3] = "3"s;
	_keyNames[SDLK_4] = "4"s;
	_keyNames[SDLK_5] = "5"s;
	_keyNames[SDLK_6] = "6"s;
	_keyNames[SDLK_7] = "7"s;
	_keyNames[SDLK_8] = "8"s;
	_keyNames[SDLK_9] = "9"s;
	_keyNames[SDLK_0] = "0"s;
	_keyNames[SDLK_COLON] = ":"s;
	_keyNames[SDLK_SEMICOLON] = ";"s;
	_keyNames[SDLK_LESS] = "<"s;
	_keyNames[SDLK_EQUALS] = "="s;
	_keyNames[SDLK_GREATER] = ">"s;
	_keyNames[SDLK_QUESTION] = "?"s;
	_keyNames[SDLK_AT] = "@"s;
	_keyNames[SDLK_LEFTBRACKET] = "["s;
	_keyNames[SDLK_BACKSLASH] = "\\"s;
	_keyNames[SDLK_RIGHTBRACKET] = "]"s;
	_keyNames[SDLK_CARET] = "^"s;
	_keyNames[SDLK_UNDERSCORE] = "_"s;
	_keyNames[SDLK_BACKQUOTE] = "`"s;

	_keyNames[SDLK_a] = "A"s;
	_keyNames[SDLK_b] = "B"s;
	_keyNames[SDLK_c] = "C"s;
	_keyNames[SDLK_d] = "D"s;
	_keyNames[SDLK_e] = "E"s;
	_keyNames[SDLK_f] = "F"s;
	_keyNames[SDLK_g] = "G"s;
	_keyNames[SDLK_h] = "H"s;
	_keyNames[SDLK_i] = "I"s;
	_keyNames[SDLK_j] = "J"s;
	_keyNames[SDLK_k] = "K"s;
	_keyNames[SDLK_l] = "L"s;
	_keyNames[SDLK_m] = "M"s;
	_keyNames[SDLK_n] = "N"s;
	_keyNames[SDLK_o] = "O"s;
	_keyNames[SDLK_p] = "P"s;
	_keyNames[SDLK_q] = "Q"s;
	_keyNames[SDLK_r] = "R"s;
	_keyNames[SDLK_s] = "S"s;
	_keyNames[SDLK_t] = "T"s;
	_keyNames[SDLK_u] = "U"s;
	_keyNames[SDLK_v] = "V"s;
	_keyNames[SDLK_w] = "W"s;
	_keyNames[SDLK_x] = "X"s;
	_keyNames[SDLK_y] = "Y"s;
	_keyNames[SDLK_z] = "Z"s;

	_keyNames[SDLK_DELETE] = "Delete"s;

	for (int i = 0; i < SDL_NUM_SCANCODES; i++) {
		if (!_keyNames[i].empty()) {
			_keyMap[_keyNames[i]] = i;
		}
	}

	_codeNames[SDL_SCANCODE_CAPSLOCK] = "CapsLock"s;

	_codeNames[SDL_SCANCODE_F1] = "F1"s;
	_codeNames[SDL_SCANCODE_F2] = "F2"s;
	_codeNames[SDL_SCANCODE_F3] = "F3"s;
	_codeNames[SDL_SCANCODE_F4] = "F4"s;
	_codeNames[SDL_SCANCODE_F5] = "F5"s;
	_codeNames[SDL_SCANCODE_F6] = "F6"s;
	_codeNames[SDL_SCANCODE_F7] = "F7"s;
	_codeNames[SDL_SCANCODE_F8] = "F8"s;
	_codeNames[SDL_SCANCODE_F9] = "F9"s;
	_codeNames[SDL_SCANCODE_F10] = "F10"s;
	_codeNames[SDL_SCANCODE_F11] = "F11"s;
	_codeNames[SDL_SCANCODE_F12] = "F12"s;

	_codeNames[SDL_SCANCODE_PRINTSCREEN] = "PrintScreen"s;
	_codeNames[SDL_SCANCODE_SCROLLLOCK] = "ScrollLock"s;
	_codeNames[SDL_SCANCODE_PAUSE] = "Pause"s;
	_codeNames[SDL_SCANCODE_INSERT] = "Insert"s;

	_codeNames[SDL_SCANCODE_HOME] = "Home"s;
	_codeNames[SDL_SCANCODE_PAGEUP] = "PageUp"s;
	_codeNames[SDL_SCANCODE_DELETE] = "Delete"s;
	_codeNames[SDL_SCANCODE_END] = "End"s;
	_codeNames[SDL_SCANCODE_PAGEDOWN] = "PageDown"s;
	_codeNames[SDL_SCANCODE_RIGHT] = "Right"s;
	_codeNames[SDL_SCANCODE_LEFT] = "Left"s;
	_codeNames[SDL_SCANCODE_DOWN] = "Down"s;
	_codeNames[SDL_SCANCODE_UP] = "Up"s;

	_codeNames[SDL_SCANCODE_KP_DIVIDE] = "/"s;
	_codeNames[SDL_SCANCODE_KP_MULTIPLY] = "*"s;
	_codeNames[SDL_SCANCODE_KP_MINUS] = "-"s;
	_codeNames[SDL_SCANCODE_KP_PLUS] = "+"s;
	_codeNames[SDL_SCANCODE_KP_ENTER] = "Return"s;
	_codeNames[SDL_SCANCODE_KP_1] = "1"s;
	_codeNames[SDL_SCANCODE_KP_2] = "2"s;
	_codeNames[SDL_SCANCODE_KP_3] = "3"s;
	_codeNames[SDL_SCANCODE_KP_4] = "4"s;
	_codeNames[SDL_SCANCODE_KP_5] = "5"s;
	_codeNames[SDL_SCANCODE_KP_6] = "6"s;
	_codeNames[SDL_SCANCODE_KP_7] = "7"s;
	_codeNames[SDL_SCANCODE_KP_8] = "8"s;
	_codeNames[SDL_SCANCODE_KP_9] = "9"s;
	_codeNames[SDL_SCANCODE_KP_0] = "0"s;
	_codeNames[SDL_SCANCODE_KP_PERIOD] = "."s;

	_codeNames[SDL_SCANCODE_APPLICATION] = "Application"s;

	_codeNames[SDL_SCANCODE_LCTRL] = "LCtrl"s;
	_codeNames[SDL_SCANCODE_LSHIFT] = "LShift"s;
	_codeNames[SDL_SCANCODE_LALT] = "LAlt"s;
	_codeNames[SDL_SCANCODE_LGUI] = "LGui"s;
	_codeNames[SDL_SCANCODE_RCTRL] = "RCtrl"s;
	_codeNames[SDL_SCANCODE_RSHIFT] = "RShift"s;
	_codeNames[SDL_SCANCODE_RALT] = "RAlt"s;
	_codeNames[SDL_SCANCODE_RGUI] = "RGui"s;

	for (int i = 0; i < SDL_NUM_SCANCODES; i++) {
		if (!_codeNames[i].empty()) {
			_codeMap[_codeNames[i]] = i;
		}
	}
	return true;
}

void Keyboard::clearChanges() {
	if (!_changedKeys.empty()) {
		for (auto symKey : _changedKeys) {
			if ((symKey & SDLK_SCANCODE_MASK) != 0) {
				uint32_t code = s_cast<uint32_t>(symKey) & ~SDLK_SCANCODE_MASK;
				_oldCodeStates[code] = _newCodeStates[code];
			} else {
				_oldKeyStates[symKey] = _newKeyStates[symKey];
			}
		}
		_changedKeys.clear();
	}
}

void Keyboard::attachIME(const KeyboardHandler& handler) {
	if (_imeHandler) {
		Event detachEvent("DetachIME"_slice);
		_imeHandler(&detachEvent);
	} else {
		SharedApplication.invokeInRender(SDL_StartTextInput);
	}
	_imeHandler = handler;
	Event attachEvent("AttachIME"_slice);
	_imeHandler(&attachEvent);
}

void Keyboard::detachIME() {
	if (_imeHandler) {
		Event detachEvent("DetachIME"_slice);
		_imeHandler(&detachEvent);
		_imeHandler = nullptr;
		SharedApplication.invokeInRender(SDL_StopTextInput);
	}
}

bool Keyboard::isIMEAttached() const {
	return !_imeHandler.IsEmpty();
}

void Keyboard::updateIMEPosHint(const Vec2& winPos) {
	int offsetY =
#if BX_PLATFORM_IOS || BX_PLATFORM_ANDROID
		45;
#else
		0;
#endif
	SDL_Rect rc = {s_cast<int>(winPos.x), s_cast<int>(winPos.y) + offsetY, 0, 0};
	SharedApplication.invokeInRender([rc]() {
		SDL_SetTextInputRect(c_cast<SDL_Rect*>(&rc));
	});
}

void Keyboard::handleEvent(const SDL_Event& event) {
	switch (event.type) {
		case SDL_KEYDOWN: {
			if (event.key.keysym.scancode != SDL_SCANCODE_UNKNOWN) {
				int key = event.key.keysym.scancode;
				Slice name = _codeNames[key];
				if (!name.empty()) {
					bool oldDown = _oldCodeStates[key];
					_newCodeStates[key] = true;
					if (!oldDown) {
						_changedKeys.push_back(event.key.keysym.sym);
						EventArgs<Slice> keyDown("KeyDown"_slice, name);
						handler(&keyDown);
					}
					EventArgs<Slice> keyPressed("KeyPressed"_slice, name);
					handler(&keyPressed);
				}
			}
			if (event.key.keysym.sym != SDLK_UNKNOWN && event.key.keysym.sym < SDL_NUM_SCANCODES) {
				int key = event.key.keysym.sym;
				Slice name = _keyNames[key];
				if (!name.empty()) {
					bool oldDown = _oldKeyStates[key];
					_newKeyStates[key] = true;
					if (!oldDown) {
						_changedKeys.push_back(event.key.keysym.sym);
						EventArgs<Slice> keyDown("KeyDown"_slice, name);
						handler(&keyDown);
					}
					EventArgs<Slice> keyPressed("KeyPressed"_slice, name);
					handler(&keyPressed);
				}
			}
			break;
		}
		case SDL_KEYUP: {
			if (event.key.keysym.scancode != SDL_SCANCODE_UNKNOWN) {
				int key = event.key.keysym.scancode;
				Slice name = _codeNames[key];
				if (!name.empty()) {
					bool oldDown = _oldCodeStates[key];
					_newCodeStates[key] = false;
					if (oldDown) {
						_changedKeys.push_back(event.key.keysym.sym);
						EventArgs<Slice> keyUp("KeyUp"_slice, name);
						handler(&keyUp);
					}
				}
			}
			if (event.key.keysym.sym != SDLK_UNKNOWN && event.key.keysym.sym < SDL_NUM_SCANCODES) {
				int key = event.key.keysym.sym;
				Slice name = _keyNames[key];
				if (!name.empty()) {
					bool oldDown = _oldKeyStates[key];
					_newKeyStates[key] = false;
					if (oldDown) {
						_changedKeys.push_back(event.key.keysym.sym);
						EventArgs<Slice> keyUp("KeyUp"_slice, name);
						handler(&keyUp);
					}
				}
			}
			break;
		}
		case SDL_TEXTINPUT: {
			Slice text(event.text.text);
			EventArgs<Slice> textInput("TextInput"_slice, text);
			_imeHandler(&textInput);
			break;
		}
		case SDL_TEXTEDITING: {
			Slice text(event.edit.text);
			EventArgs<Slice, int> textEditing("TextEditing"_slice, text, event.edit.start);
			_imeHandler(&textEditing);
			break;
		}
		default:
			break;
	}
}

bool Keyboard::isKeyDown(String name) const {
	auto it = _keyMap.find(name);
	if (it != _keyMap.end()) {
		return !_oldKeyStates[it->second] && _newKeyStates[it->second];
	}
	it = _codeMap.find(name);
	if (it != _codeMap.end()) {
		return !_oldCodeStates[it->second] && _newCodeStates[it->second];
	}
	Warn("invalid keyboard button name for \"{}\"", name.toString());
	return false;
}

bool Keyboard::isKeyUp(String name) const {
	auto it = _keyMap.find(name);
	if (it != _keyMap.end()) {
		return _oldKeyStates[it->second] && !_newKeyStates[it->second];
	}
	it = _codeMap.find(name);
	if (it != _codeMap.end()) {
		return _oldCodeStates[it->second] && !_newCodeStates[it->second];
	}
	Warn("invalid keyboard button name for \"{}\"", name.toString());
	return false;
}

bool Keyboard::isKeyPressed(String name) const {
	auto it = _keyMap.find(name);
	if (it != _keyMap.end()) {
		return _newKeyStates[it->second];
	}
	it = _codeMap.find(name);
	if (it != _codeMap.end()) {
		return _newCodeStates[it->second];
	}
	Warn("invalid keyboard button name for \"{}\"", name.toString());
	return false;
}

NS_DORA_END
