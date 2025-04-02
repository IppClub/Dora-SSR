/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Support/Common.h"

NS_DORA_BEGIN

Color3::Color3()
	: r(255)
	, g(255)
	, b(255) { }

Color3::Color3(uint32_t rgb)
	: r((rgb & 0x00ff0000) >> 16)
	, g((rgb & 0x0000ff00) >> 8)
	, b(rgb & 0x000000ff) { }

Color3::Color3(uint8_t r, uint8_t g, uint8_t b)
	: r(r)
	, g(g)
	, b(b) { }

Color3::Color3(float r, float g, float b)
	: r(s_cast<uint8_t>(std::round(r)))
	, g(s_cast<uint8_t>(std::round(g)))
	, b(s_cast<uint8_t>(std::round(b))) { }

Color3::Color3(const Vec3& vec)
	: r(s_cast<uint8_t>(std::round(vec.x * 255.0f)))
	, g(s_cast<uint8_t>(std::round(vec.y * 255.0f)))
	, b(s_cast<uint8_t>(std::round(vec.z * 255.0f))) { }

uint32_t Color3::toRGB() const {
	return r << 16 | g << 8 | b;
}

Vec3 Color3::toVec3() const {
	return Vec3{r / 255.0f, g / 255.0f, b / 255.0f};
}

Color::Color()
	: r(255)
	, g(255)
	, b(255)
	, a(255) { }

Color::Color(Color3 color, uint8_t a)
	: a(a)
	, r(color.r)
	, g(color.g)
	, b(color.b) { }

Color::Color(Color3 color, float a)
	: a(s_cast<uint8_t>(std::round(a)))
	, r(s_cast<uint8_t>(std::round(color.r)))
	, g(s_cast<uint8_t>(std::round(color.g)))
	, b(s_cast<uint8_t>(std::round(color.b))) { }

Color::Color(uint32_t argb)
	: a(argb >> 24)
	, r((argb & 0x00ff0000) >> 16)
	, g((argb & 0x0000ff00) >> 8)
	, b(argb & 0x000000ff) { }

Color::Color(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
	: r(r)
	, g(g)
	, b(b)
	, a(a) { }

Color::Color(float r, float g, float b, float a)
	: r(s_cast<uint8_t>(r))
	, g(s_cast<uint8_t>(g))
	, b(s_cast<uint8_t>(b))
	, a(s_cast<uint8_t>(a)) { }

Color::Color(const Vec4& vec)
	: r(s_cast<uint8_t>(std::round(vec.x * 255.0f)))
	, g(s_cast<uint8_t>(std::round(vec.y * 255.0f)))
	, b(s_cast<uint8_t>(std::round(vec.z * 255.0f)))
	, a(s_cast<uint8_t>(std::round(vec.w * 255.0f))) { }

uint32_t Color::toABGR() const {
	return *r_cast<uint32_t*>(c_cast<Color*>(this));
}

uint32_t Color::toRGBA() const {
	return r << 24 | g << 16 | b << 8 | a;
}

uint32_t Color::toARGB() const {
	return a << 24 | r << 16 | g << 8 | b;
}

Color3 Color::toColor3() const {
	return Color3(r, g, b);
}

Vec4 Color::toVec4() const {
	return Vec4{r / 255.0f, g / 255.0f, b / 255.0f, a / 255.0f};
}

void Color::setOpacity(float var) {
	a = s_cast<uint8_t>(std::round(Math::clamp(var, 0.0f, 1.0f) * 255.0f));
}

float Color::getOpacity() const noexcept {
	return a / 255.0f;
}

Color& Color::operator=(const Color3& color) {
	r = color.r;
	g = color.g;
	b = color.b;
	return *this;
}

Color& Color::operator=(const Color& color) {
	r = color.r;
	g = color.g;
	b = color.b;
	a = color.a;
	return *this;
}

Color Color::convert(uint32_t abgr) {
	return *r_cast<Color*>(&abgr);
}

Color Color::White;
Color Color::Black(0x0);

const BlendFunc BlendFunc::Default{
	BGFX_STATE_BLEND_FUNC_SEPARATE(
		BGFX_STATE_BLEND_SRC_ALPHA,
		BGFX_STATE_BLEND_INV_SRC_ALPHA,
		BGFX_STATE_BLEND_ONE,
		BGFX_STATE_BLEND_INV_SRC_ALPHA)};

BlendFunc::BlendFunc(uint64_t src, uint64_t dst)
	: _value(BGFX_STATE_BLEND_FUNC(src, dst)) { }

BlendFunc::BlendFunc(uint64_t srcC, uint64_t dstC, uint64_t srcA, uint64_t dstA)
	: _value(BGFX_STATE_BLEND_FUNC_SEPARATE(srcC, dstC, srcA, dstA)) { }

BlendFunc::BlendFunc(uint64_t blendState)
	: _value(blendState) { }

uint64_t BlendFunc::toValue() const {
	return _value;
}

NS_DORA_END
