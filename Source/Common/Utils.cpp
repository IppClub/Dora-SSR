/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Common/Utils.h"
#include "Basic/Application.h"
#include "Lua/ToLua/tolua++.h"

NS_DOROTHY_BEGIN

int doraType = TOLUA_REG_INDEX_TYPE; // 1:UBOX 2:CALLBACK 3:LUA_TYPE

namespace Math
{
	float rand0to1()
	{
		auto& app = SharedApplication;
		return s_cast<float>(s_cast<double>(app.getRand() - app.getRandMin()) / app.getRandMax());
	}

	float rand1to1()
	{
		return 2.0f * rand0to1() - 1.0f;
	}
}


Flag::Flag(Uint32 flags):_flags(flags)
{ }

void Flag::setOn(Uint32 type)
{
	_flags |= type;
}

void Flag::setOff(Uint32 type)
{
	_flags &= ~type;
}

void Flag::setFlag(Uint32 type, bool value)
{
	if (value)
	{
		_flags |= type;
	}
	else
	{
		_flags &= ~type;
	}
}

void Flag::toggle(Uint32 type)
{
	setFlag(type, !isOn(type));
}

bool Flag::isOn(Uint32 type) const
{
	return (_flags & type) != 0;
}

bool Flag::isOff(Uint32 type) const
{
	return (_flags & type) == 0;
}

NS_DOROTHY_END
