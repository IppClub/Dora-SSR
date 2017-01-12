/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/View.h"

NS_DOROTHY_BEGIN

View::View():
_flag(BGFX_RESET_NONE | BGFX_RESET_VSYNC),
_resetRequired(false),
_size(s_cast<float>(SharedApplication.getWidth()), s_cast<float>(SharedApplication.getHeight()))
{ }

Size View::getSize() const
{
	return _size;
}

void View::setVSync(bool var)
{
	if (var != isVSync())
	{
		if (var)
		{
			_flag |= BGFX_RESET_VSYNC;
		}
		else
		{
			_flag &= ~BGFX_RESET_VSYNC;
		}
		_resetRequired = true;
	}
}

bool View::isVSync() const
{
	return (_flag & BGFX_RESET_VSYNC) != 0;
}

void View::update()
{
	Size size(s_cast<float>(SharedApplication.getWidth()), s_cast<float>(SharedApplication.getHeight()));
	if (_size != size)
	{
		_size = size;
		_resetRequired = true;
	}
	if (_resetRequired)
	{
		_resetRequired = false;
		bgfx::reset(s_cast<uint32_t>(_size.width), s_cast<uint32_t>(_size.height), _flag);
	}
}

NS_DOROTHY_END
