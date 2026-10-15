/** Copyright (c) 2006-2023 LOVE Development Team. */
#pragma once

#include "Font.h"
#include "common/Matrix.h"
#include "common/runtime.h"

namespace love::graphics
{

class GraphicsPrintCommand
{
public:
	virtual ~GraphicsPrintCommand() = default;
	virtual void print(const std::vector<Font::ColoredString> &text, Font *font,
		const Matrix4 &transform) = 0;
	virtual void printf(const std::vector<Font::ColoredString> &text, Font *font,
		float wrap, Font::AlignMode align, const Matrix4 &transform) = 0;
};

LOVE_EXPORT int w_print(lua_State *L);
LOVE_EXPORT int w_printf(lua_State *L);

}
