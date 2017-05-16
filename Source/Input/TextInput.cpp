/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Input/TextInput.h"
#include "Event/Event.h"
#include "Basic/Application.h"

NS_DOROTHY_BEGIN

TextInput::TextInput()
{
	SharedApplication.eventHandler += std::make_pair(this, &TextInput::handleEvent);
}

TextInput::~TextInput()
{
	SharedApplication.eventHandler -= std::make_pair(this, &TextInput::handleEvent);
}

void TextInput::attachIME(const TextInputHandler& handler)
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

void TextInput::detachIME()
{
	if (_imeHandler)
	{
		Event detachEvent("DetachIME"_slice);
		_imeHandler(&detachEvent);
		_imeHandler = nullptr;
		SharedApplication.invokeInRender(SDL_StopTextInput);
	}
}

void TextInput::handleEvent(const SDL_Event& event)
{
	if (!_imeHandler && !KeyboadHandler) return;
	switch (event.type)
	{
		case SDL_KEYDOWN:
		{
			int key = event.key.keysym.sym & ~SDLK_SCANCODE_MASK;
			EventArgs<int> keyDown("KeyDown"_slice, key);
			KeyboadHandler(&keyDown);
			break;
		}
		case SDL_KEYUP:
		{
			int key = event.key.keysym.sym & ~SDLK_SCANCODE_MASK;
			EventArgs<int> keyUp("KeyUp"_slice, key);
			KeyboadHandler(&keyUp);
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
			EventArgs<Slice> textEditing("TextEditing"_slice, text);
			_imeHandler(&textEditing);
			break;
		}
		default:
			break;
	}
}

NS_DOROTHY_END
