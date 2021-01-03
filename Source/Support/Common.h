/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

NS_DOROTHY_BEGIN

struct Color3
{
	Uint8 r;
	Uint8 g;
	Uint8 b;
	Color3();
	Color3(Uint32 rgb);
	Color3(Uint8 r, Uint8 g, Uint8 b);
	Color3(const Vec3& vec);
	Uint32 toRGB() const;
	Vec3 toVec3() const;
};

struct Color
{
	Uint8 r;
	Uint8 g;
	Uint8 b;
	Uint8 a;
	Color();
	Color(Color3 color, Uint8 a = 0);
	Color(Uint32 argb);
	Color(Uint8 r, Uint8 g, Uint8 b, Uint8 a);
	Color(const Vec4& vec);
	Uint32 toABGR() const;
	Uint32 toRGBA() const;
	Uint32 toARGB() const;
	Color3 toColor3() const;
	Vec4 toVec4() const;
	PROPERTY(float, Opacity);
	Color& operator=(const Color3& color);
	Color& operator=(const Color& color);
	static Color convert(Uint32 abgr);
	static Color White;
	static Color Black;
};

struct BlendFunc
{
	Uint32 src;
	Uint32 dst;
	enum
	{
		One = Uint32(BGFX_STATE_BLEND_ONE),
		Zero = Uint32(BGFX_STATE_BLEND_ZERO),
		SrcColor = Uint32(BGFX_STATE_BLEND_SRC_COLOR),
		SrcAlpha = Uint32(BGFX_STATE_BLEND_SRC_ALPHA),
		DstColor = Uint32(BGFX_STATE_BLEND_DST_COLOR),
		DstAlpha = Uint32(BGFX_STATE_BLEND_DST_ALPHA),
		InvSrcColor = Uint32(BGFX_STATE_BLEND_INV_SRC_COLOR),
		InvSrcAlpha = Uint32(BGFX_STATE_BLEND_INV_SRC_ALPHA),
		InvDstColor = Uint32(BGFX_STATE_BLEND_INV_DST_COLOR),
		InvDstAlpha = Uint32(BGFX_STATE_BLEND_INV_DST_ALPHA)
	};
	Uint64 toValue();
	static const BlendFunc Default;
};

NS_DOROTHY_END
