/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Lua/LuaHandler.h"
#include "Event/Event.h"

NS_DOROTHY_BEGIN

LuaHandler::LuaHandler(int handler):
_handler(handler)
{
	AssertIf(handler == 0, "invalid lua handler.");
}

LuaHandler::~LuaHandler()
{
	SharedLueEngine.removeScriptHandler(_handler);
}

bool LuaHandler::update(double deltaTime)
{
	SharedLueEngine.push(deltaTime);
	return SharedLueEngine.executeFunction(_handler, 1) != 0;
}

bool LuaHandler::equals(LuaHandler* other) const
{
	return SharedLueEngine.scriptHandlerEqual(_handler, other->_handler);
}

int LuaHandler::get() const
{
	return _handler;
}

void LuaFunction::operator()(Event* event) const
{
	if (_handler->get() > 0)
	{
		SharedLueEngine.executeFunction(_handler->get(), event->pushArgsToLua());
	}
}

NS_DOROTHY_END
