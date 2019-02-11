/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Support/Common.h"

NS_DOROTHY_BEGIN

Color3::Color3():
r(255),
g(255),
b(255)
{ }

Color3::Color3(Uint32 rgb):
r((rgb & 0x00FF0000) >> 16),
g((rgb & 0x0000FF00) >> 8),
b(rgb & 0x000000FF)
{ }

Color3::Color3(Uint8 r, Uint8 g, Uint8 b):
r(r),
g(g),
b(b)
{ }

Color3::Color3(const Vec3& vec):
r(s_cast<Uint8>(vec.x * 255.0f)),
g(s_cast<Uint8>(vec.y * 255.0f)),
b(s_cast<Uint8>(vec.z * 255.0f))
{ }

Uint32 Color3::toRGB() const
{
	return r << 16 | g << 8 | b;
}

Vec3 Color3::toVec3() const
{
	return Vec3{r / 255.0f, g / 255.0f, b / 255.0f};
}

Color::Color():
r(255),
g(255),
b(255),
a(255)
{ }

Color::Color(Color3 color, Uint8 a):
a(a),
r(color.r),
g(color.g),
b(color.b)
{ }

Color::Color(Uint32 argb):
a(argb >> 24),
r((argb & 0x00ff0000) >> 16),
g((argb & 0x0000ff00) >> 8),
b(argb & 0x000000ff)
{ }

Color::Color(Uint8 r, Uint8 g, Uint8 b, Uint8 a):
r(r),
g(g),
b(b),
a(a)
{ }

Color::Color(const Vec4& vec):
r(s_cast<Uint8>(vec.x * 255.0f)),
g(s_cast<Uint8>(vec.y * 255.0f)),
b(s_cast<Uint8>(vec.z * 255.0f)),
a(s_cast<Uint8>(vec.w * 255.0f))
{ }

Uint32 Color::toABGR() const
{
	return *r_cast<Uint32*>(c_cast<Color*>(this));
}

Uint32 Color::toRGBA() const
{
	return r << 24 | g << 16 | b << 8 | a;
}

Uint32 Color::toARGB() const
{
	return a << 24 | r << 16 | g << 8 | b;
}

Color3 Color::toColor3() const
{
	return Color3(r, g, b);
}

Vec4 Color::toVec4() const
{
	return Vec4{r / 255.0f, g / 255.0f, b / 255.0f, a / 255.0f};
}

void Color::setOpacity(float var)
{
	a = s_cast<Uint8>(Math::clamp(var, 0.0f, 1.0f) * 255.0f);
}

float Color::getOpacity() const
{
	return a / 255.0f;
}

Color& Color::operator=(const Color3& color)
{
	r = color.r;
	g = color.g;
	b = color.b;
	return *this;
}

Color& Color::operator=(const Color& color)
{
	r = color.r;
	g = color.g;
	b = color.b;
	a = color.a;
	return *this;
}

Color Color::convert(Uint32 abgr)
{
	return *r_cast<Color*>(&abgr);
}

Color Color::White;
Color Color::Black(0x0);

const BlendFunc BlendFunc::Default{BlendFunc::SrcAlpha, BlendFunc::InvSrcAlpha};

Uint64 BlendFunc::toValue()
{
	return BGFX_STATE_BLEND_FUNC(src, dst);
}

NS_DOROTHY_END
