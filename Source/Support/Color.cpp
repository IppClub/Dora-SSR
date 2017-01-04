/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Support/Color.h"

NS_DOROTHY_BEGIN

Color::Color():
r(255),
g(255),
b(255),
a(255)
{ }

Color::Color(Uint32 argb):
a(argb >> 24),
r((argb & 0x00FF0000) >> 16),
g((argb & 0x0000FF00) >> 8),
b(argb & 0x000000FF)
{ }

Color::Color(Uint8 r, Uint8 g, Uint8 b, Uint8 a):
r(r),
g(g),
b(b),
a(a)
{ }

Uint32 Color::toRGBA() const
{
	return *r_cast<Uint32*>(c_cast<Color*>(this));
}

void Color::setOpacity(float var)
{
	a = s_cast<Uint8>(Clamp(var, 0.0f, 1.0f) * 255.0f);
}

float Color::getOpacity() const
{
	return a / 255.0f;
}

bool Color::operator==(const Color& other) const
{
	return Color::toRGBA() == other.toRGBA();
}

bool Color::operator!=(const Color& other) const
{
	return Color::toRGBA() != other.toRGBA();
}

NS_DOROTHY_END
