/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Input/Keyboard.h"
#include "Event/Event.h"
#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"

NS_DOROTHY_BEGIN

Keyboard::Keyboard():
_oldCodeStates{},
_newCodeStates{},
_oldKeyStates{},
_newKeyStates{}
{
	SharedApplication.eventHandler += std::make_pair(this, &Keyboard::handleEvent);
}

Keyboard::~Keyboard()
{
	SharedApplication.eventHandler -= std::make_pair(this, &Keyboard::handleEvent);
}

bool Keyboard::init()
{
    _keyNames[SDLK_RETURN] = "Return"_slice;
    _keyNames[SDLK_ESCAPE] = "Escape"_slice;
    _keyNames[SDLK_BACKSPACE] = "BackSpace"_slice;
    _keyNames[SDLK_TAB] = "Tab"_slice;
    _keyNames[SDLK_SPACE] = "Space"_slice;
    _keyNames[SDLK_EXCLAIM] = "!"_slice;
    _keyNames[SDLK_QUOTEDBL] = "\""_slice;
    _keyNames[SDLK_HASH] = "#"_slice;
    _keyNames[SDLK_PERCENT] = "%"_slice;
    _keyNames[SDLK_DOLLAR] = "$"_slice;
    _keyNames[SDLK_AMPERSAND] = "&"_slice;
    _keyNames[SDLK_QUOTE] = "\'"_slice;
    _keyNames[SDLK_LEFTPAREN] = "("_slice;
    _keyNames[SDLK_RIGHTPAREN] = ")"_slice;
    _keyNames[SDLK_ASTERISK] = "*"_slice;
    _keyNames[SDLK_PLUS] = "+"_slice;
    _keyNames[SDLK_COMMA] = ","_slice;
    _keyNames[SDLK_MINUS] = "-"_slice;
    _keyNames[SDLK_PERIOD] = "."_slice;
    _keyNames[SDLK_SLASH] = "/"_slice;

	_keyNames[SDLK_1] = "1"_slice;
	_keyNames[SDLK_2] = "2"_slice;
	_keyNames[SDLK_3] = "3"_slice;
	_keyNames[SDLK_4] = "4"_slice;
	_keyNames[SDLK_5] = "5"_slice;
	_keyNames[SDLK_6] = "6"_slice;
	_keyNames[SDLK_7] = "7"_slice;
	_keyNames[SDLK_8] = "8"_slice;
	_keyNames[SDLK_9] = "9"_slice;
	_keyNames[SDLK_0] = "0"_slice;
	_keyNames[SDLK_COLON] = ":"_slice;
    _keyNames[SDLK_SEMICOLON] = ";"_slice;
    _keyNames[SDLK_LESS] = "<"_slice;
    _keyNames[SDLK_EQUALS] = "="_slice;
    _keyNames[SDLK_GREATER] = ">"_slice;
    _keyNames[SDLK_QUESTION] = "?"_slice;
    _keyNames[SDLK_AT] = "@"_slice;
    _keyNames[SDLK_LEFTBRACKET] = "["_slice;
    _keyNames[SDLK_BACKSLASH] = "\\"_slice;
    _keyNames[SDLK_RIGHTBRACKET] = "]"_slice;
    _keyNames[SDLK_CARET] = "^"_slice;
    _keyNames[SDLK_UNDERSCORE] = "_"_slice;
    _keyNames[SDLK_BACKQUOTE] = "`"_slice;

	_keyNames[SDLK_a] = "A"_slice;
	_keyNames[SDLK_b] = "B"_slice;
	_keyNames[SDLK_c] = "C"_slice;
	_keyNames[SDLK_d] = "D"_slice;
	_keyNames[SDLK_e] = "E"_slice;
	_keyNames[SDLK_f] = "F"_slice;
	_keyNames[SDLK_g] = "G"_slice;
	_keyNames[SDLK_h] = "H"_slice;
	_keyNames[SDLK_i] = "I"_slice;
	_keyNames[SDLK_j] = "J"_slice;
	_keyNames[SDLK_k] = "K"_slice;
	_keyNames[SDLK_l] = "L"_slice;
	_keyNames[SDLK_m] = "M"_slice;
	_keyNames[SDLK_n] = "N"_slice;
	_keyNames[SDLK_o] = "O"_slice;
	_keyNames[SDLK_p] = "P"_slice;
	_keyNames[SDLK_q] = "Q"_slice;
	_keyNames[SDLK_r] = "R"_slice;
	_keyNames[SDLK_s] = "S"_slice;
	_keyNames[SDLK_t] = "T"_slice;
	_keyNames[SDLK_u] = "U"_slice;
	_keyNames[SDLK_v] = "V"_slice;
	_keyNames[SDLK_w] = "W"_slice;
	_keyNames[SDLK_x] = "X"_slice;
	_keyNames[SDLK_y] = "Y"_slice;
	_keyNames[SDLK_z] = "Z"_slice;

	_keyNames[SDLK_DELETE] = "Delete"_slice;

	for (int i = 0; i < SDL_NUM_SCANCODES; i++)
	{
		if (!_keyNames[i].empty())
		{
			_keyMap[_keyNames[i]] = i;
		}
	}

	_codeNames[SDL_SCANCODE_CAPSLOCK] = "CapsLock"_slice;

	_codeNames[SDL_SCANCODE_F1] = "F1"_slice;
	_codeNames[SDL_SCANCODE_F2] = "F2"_slice;
	_codeNames[SDL_SCANCODE_F3] = "F3"_slice;
	_codeNames[SDL_SCANCODE_F4] = "F4"_slice;
	_codeNames[SDL_SCANCODE_F5] = "F5"_slice;
	_codeNames[SDL_SCANCODE_F6] = "F6"_slice;
	_codeNames[SDL_SCANCODE_F7] = "F7"_slice;
	_codeNames[SDL_SCANCODE_F8] = "F8"_slice;
	_codeNames[SDL_SCANCODE_F9] = "F9"_slice;
	_codeNames[SDL_SCANCODE_F10] = "F10"_slice;
	_codeNames[SDL_SCANCODE_F11] = "F11"_slice;
	_codeNames[SDL_SCANCODE_F12] = "F12"_slice;

	_codeNames[SDL_SCANCODE_PRINTSCREEN] = "PrintScreen"_slice;
	_codeNames[SDL_SCANCODE_SCROLLLOCK] = "ScrollLock"_slice;
	_codeNames[SDL_SCANCODE_PAUSE] = "Pause"_slice;
	_codeNames[SDL_SCANCODE_INSERT] = "Insert"_slice;

	_codeNames[SDL_SCANCODE_HOME] = "Home"_slice;
	_codeNames[SDL_SCANCODE_PAGEUP] = "PageUp"_slice;
	_codeNames[SDL_SCANCODE_DELETE] = "Delete"_slice;
	_codeNames[SDL_SCANCODE_END] = "End"_slice;
	_codeNames[SDL_SCANCODE_PAGEDOWN] = "PageDown"_slice;
	_codeNames[SDL_SCANCODE_RIGHT] = "Right"_slice;
	_codeNames[SDL_SCANCODE_LEFT] = "Left"_slice;
	_codeNames[SDL_SCANCODE_DOWN] = "Down"_slice;
	_codeNames[SDL_SCANCODE_UP] = "Up"_slice;

	_codeNames[SDL_SCANCODE_KP_DIVIDE] = "/"_slice;
	_codeNames[SDL_SCANCODE_KP_MULTIPLY] = "*"_slice;
	_codeNames[SDL_SCANCODE_KP_MINUS] = "-"_slice;
	_codeNames[SDL_SCANCODE_KP_PLUS] = "+"_slice;
	_codeNames[SDL_SCANCODE_KP_ENTER] = "Return"_slice;
	_codeNames[SDL_SCANCODE_KP_1] = "1"_slice;
	_codeNames[SDL_SCANCODE_KP_2] = "2"_slice;
	_codeNames[SDL_SCANCODE_KP_3] = "3"_slice;
	_codeNames[SDL_SCANCODE_KP_4] = "4"_slice;
	_codeNames[SDL_SCANCODE_KP_5] = "5"_slice;
	_codeNames[SDL_SCANCODE_KP_6] = "6"_slice;
	_codeNames[SDL_SCANCODE_KP_7] = "7"_slice;
	_codeNames[SDL_SCANCODE_KP_8] = "8"_slice;
	_codeNames[SDL_SCANCODE_KP_9] = "9"_slice;
	_codeNames[SDL_SCANCODE_KP_0] = "0"_slice;
	_codeNames[SDL_SCANCODE_KP_PERIOD] = "."_slice;

	_codeNames[SDL_SCANCODE_APPLICATION] = "Application"_slice;
	
	_codeNames[SDL_SCANCODE_LCTRL] = "LCtrl"_slice;
	_codeNames[SDL_SCANCODE_LSHIFT] = "LShift"_slice;
	_codeNames[SDL_SCANCODE_LALT] = "LAlt"_slice;
	_codeNames[SDL_SCANCODE_LGUI] = "LGui"_slice;
	_codeNames[SDL_SCANCODE_RCTRL] = "RCtrl"_slice;
	_codeNames[SDL_SCANCODE_RSHIFT] = "RShift"_slice;
	_codeNames[SDL_SCANCODE_RALT] = "RAlt"_slice;
	_codeNames[SDL_SCANCODE_RGUI] = "RGui"_slice;

	for (int i = 0; i < SDL_NUM_SCANCODES; i++)
	{
		if (!_codeNames[i].empty())
		{
			_codeMap[_codeNames[i]] = i;
		}
	}
	return true;
}

void Keyboard::update()
{
	if (!_changedKeys.empty())
	{
		for (auto symKey : _changedKeys)
		{
			if ((symKey & SDLK_SCANCODE_MASK) != 0)
			{
				Uint32 code = s_cast<Uint32>(symKey) & ~SDLK_SCANCODE_MASK;
				_oldCodeStates[code] = _newCodeStates[code];
			}
			else
			{
				_oldKeyStates[symKey] = _newKeyStates[symKey];
			}
		}
		_changedKeys.clear();
	}
}

void Keyboard::attachIME(const KeyboardHandler& handler)
{
	if (_imeHandler)
	{
		Event detachEvent("DetachIME"_slice);
		_imeHandler(&detachEvent);
	}
	else
	{
		SharedApplication.invokeInRender(SDL_StartTextInput);
	}
	_imeHandler = handler;
	Event attachEvent("AttachIME"_slice);
	_imeHandler(&attachEvent);
}

void Keyboard::detachIME()
{
	if (_imeHandler)
	{
		Event detachEvent("DetachIME"_slice);
		_imeHandler(&detachEvent);
		_imeHandler = nullptr;
		SharedApplication.invokeInRender(SDL_StopTextInput);
	}
}

bool Keyboard::isIMEAttached() const
{
	return !_imeHandler.IsEmpty();
}

void Keyboard::updateIMEPosHint(const Vec2& winPos)
{
	int offsetY =
#if BX_PLATFORM_IOS
		45;
#elif BX_PLATFORM_OSX || BX_PLATFORM_WINDOWS
		s_cast<int>(10.0f * SharedApplication.getDeviceRatio());
#else
		0;
#endif
	SDL_Rect rc = { s_cast<int>(winPos.x), s_cast<int>(winPos.y) + offsetY, 0, 0 };
	SharedApplication.invokeInRender([rc]()
	{
		SDL_SetTextInputRect(c_cast<SDL_Rect*>(&rc));
	});
}

void Keyboard::handleEvent(const SDL_Event& event)
{
	switch (event.type)
	{
		case SDL_MOUSEBUTTONDOWN:
		case SDL_FINGERDOWN:
		{
			detachIME();
			break;
		}
		case SDL_KEYDOWN:
		{
			Slice name;
			bool oldDown;
			if ((event.key.keysym.sym & SDLK_SCANCODE_MASK) != 0)
			{
				int key = event.key.keysym.sym & ~SDLK_SCANCODE_MASK;
				name = _codeNames[key];
				if (name.empty()) break;
				oldDown = _oldCodeStates[key];
				_newCodeStates[key] = true;
			}
			else
			{
				int key = event.key.keysym.sym;
				name = _keyNames[key];
				if (name.empty()) break;
				oldDown = _oldKeyStates[key];
				_newKeyStates[key] = true;
			}
			if (!oldDown)
			{
				_changedKeys.push_back(event.key.keysym.sym);
				EventArgs<Slice> keyDown("KeyDown"_slice, name);
				KeyHandler(&keyDown);
			}
			EventArgs<Slice> keyPressed("KeyPressed"_slice, name);
			KeyHandler(&keyPressed);
			break;
		}
		case SDL_KEYUP:
		{
			Slice name;
			bool oldDown;
			if ((event.key.keysym.sym & SDLK_SCANCODE_MASK) != 0)
			{
				int key = event.key.keysym.sym & ~SDLK_SCANCODE_MASK;
				name = _codeNames[key];
				if (name.empty()) break;
				oldDown = _oldCodeStates[key];
				_newCodeStates[key] = false;
			}
			else
			{
				int key = event.key.keysym.sym;
				name = _keyNames[key];
				if (name.empty()) break;
				oldDown = _oldKeyStates[key];
				_newKeyStates[key] = false;
			}
			if (oldDown)
			{
				_changedKeys.push_back(event.key.keysym.sym);
				EventArgs<Slice> keyUp("KeyUp"_slice, name);
				KeyHandler(&keyUp);
			}
			break;
		}
		case SDL_TEXTINPUT:
		{
			Slice text(event.text.text);
			EventArgs<Slice> textInput("TextInput"_slice, text);
			_imeHandler(&textInput);
			break;
		}
		case SDL_TEXTEDITING:
		{
			Slice text(event.edit.text);
			EventArgs<Slice,int> textEditing("TextEditing"_slice, text, event.edit.start);
			_imeHandler(&textEditing);
			break;
		}
		default:
			break;
	}
}

bool Keyboard::isKeyDown(String name) const
{
	auto it = _keyMap.find(name);
	if (it != _keyMap.end())
	{
		return !_oldKeyStates[it->second] && _newKeyStates[it->second];
	}
	it = _codeMap.find(name);
	if (it != _codeMap.end())
	{
		return !_oldCodeStates[it->second] && _newCodeStates[it->second];
	}
	Warn("invalid keyboard button name for \"{}\"", name);
	return false;
}

bool Keyboard::isKeyUp(String name)  const
{
	auto it = _keyMap.find(name);
	if (it != _keyMap.end())
	{
		return _oldKeyStates[it->second] && !_newKeyStates[it->second];
	}
	it = _codeMap.find(name);
	if (it != _codeMap.end())
	{
		return _oldCodeStates[it->second] && !_newCodeStates[it->second];
	}
	Warn("invalid keyboard button name for \"{}\"", name);
	return false;
}

bool Keyboard::isKeyPressed(String name) const
{
	auto it = _keyMap.find(name);
	if (it != _keyMap.end())
	{
		return _newKeyStates[it->second];
	}
	it = _codeMap.find(name);
	if (it != _codeMap.end())
	{
		return _newCodeStates[it->second];
	}
	Warn("invalid keyboard button name for \"{}\"", name);
	return false;
}

NS_DOROTHY_END
