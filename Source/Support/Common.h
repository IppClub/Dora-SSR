/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

NS_DORA_BEGIN

struct Color3 {
	uint8_t r;
	uint8_t g;
	uint8_t b;
	Color3();
	Color3(uint32_t rgb);
	Color3(uint8_t r, uint8_t g, uint8_t b);
	Color3(float r, float g, float b);
	Color3(const Vec3& vec);
	uint32_t toRGB() const;
	Vec3 toVec3() const;
};

struct Color {
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
	Color();
	Color(Color3 color, uint8_t a = 0);
	Color(Color3 color, float a = 0.0f);
	Color(uint32_t argb);
	Color(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
	Color(float r, float g, float b, float a);
	Color(const Vec4& vec);
	uint32_t toABGR() const;
	uint32_t toRGBA() const;
	uint32_t toARGB() const;
	Color3 toColor3() const;
	Vec4 toVec4() const;
	PROPERTY(float, Opacity);
	Color& operator=(const Color3& color);
	Color& operator=(const Color& color);
	static Color convert(uint32_t abgr);
	static Color White;
	static Color Black;
};

class BlendFunc {
public:
	enum {
		One = uint64_t(BGFX_STATE_BLEND_ONE),
		Zero = uint64_t(BGFX_STATE_BLEND_ZERO),
		SrcColor = uint64_t(BGFX_STATE_BLEND_SRC_COLOR),
		SrcAlpha = uint64_t(BGFX_STATE_BLEND_SRC_ALPHA),
		DstColor = uint64_t(BGFX_STATE_BLEND_DST_COLOR),
		DstAlpha = uint64_t(BGFX_STATE_BLEND_DST_ALPHA),
		InvSrcColor = uint64_t(BGFX_STATE_BLEND_INV_SRC_COLOR),
		InvSrcAlpha = uint64_t(BGFX_STATE_BLEND_INV_SRC_ALPHA),
		InvDstColor = uint64_t(BGFX_STATE_BLEND_INV_DST_COLOR),
		InvDstAlpha = uint64_t(BGFX_STATE_BLEND_INV_DST_ALPHA)
	};
	BlendFunc(uint64_t src, uint64_t dst);
	BlendFunc(uint64_t srcC, uint64_t dstC, uint64_t srcA, uint64_t dstA);
	BlendFunc(uint64_t blendState);
	uint64_t toValue() const;
	static const BlendFunc Default;

private:
	uint64_t _value;
};

NS_DORA_END
