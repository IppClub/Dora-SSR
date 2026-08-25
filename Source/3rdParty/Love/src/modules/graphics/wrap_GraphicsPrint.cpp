/** Copyright (c) 2006-2023 LOVE Development Team. */
#include "wrap_GraphicsPrint.h"

#include "common/Module.h"
#include "math/Transform.h"
#include "wrap_Font.h"
#include "wrap_GraphicsTransform.h"

namespace love::graphics
{

static GraphicsPrintCommand *printCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsPrintCommand *>(module);
	if (!command) luaL_error(L, "love.graphics has no state-local print command adapter");
	return command;
}

int w_print(lua_State *L)
{
	std::vector<Font::ColoredString> text;
	luax_checkcoloredstring(L, 1, text);
	Font *font = nullptr;
	int startIndex = 2;
	if (luax_istype(L, 2, Font::type))
	{
		font = luax_checkfont(L, 2);
		startIndex = 3;
	}
	luax_checkstandardtransform(L, startIndex, [&](const Matrix4 &matrix)
	{
		luax_catchexcept(L, [&](){ printCommand(L)->print(text, font, matrix); });
	});
	return 0;
}

int w_printf(lua_State *L)
{
	std::vector<Font::ColoredString> text;
	luax_checkcoloredstring(L, 1, text);
	Font *font = nullptr;
	int startIndex = 2;
	if (luax_istype(L, startIndex, Font::type)) font = luax_checkfont(L, startIndex++);

	Font::AlignMode align = Font::ALIGN_LEFT;
	int formatIndex = startIndex + 2;
	Matrix4 matrix;
	if (luax_istype(L, startIndex, math::Transform::type))
	{
		matrix = luax_totype<math::Transform>(L, startIndex)->getMatrix();
		formatIndex = startIndex + 1;
	}
	else
	{
		const float x = static_cast<float>(luaL_checknumber(L, startIndex));
		const float y = static_cast<float>(luaL_checknumber(L, startIndex + 1));
		const float angle = static_cast<float>(luaL_optnumber(L, startIndex + 4, 0));
		const float sx = static_cast<float>(luaL_optnumber(L, startIndex + 5, 1));
		const float sy = static_cast<float>(luaL_optnumber(L, startIndex + 6, sx));
		const float ox = static_cast<float>(luaL_optnumber(L, startIndex + 7, 0));
		const float oy = static_cast<float>(luaL_optnumber(L, startIndex + 8, 0));
		const float kx = static_cast<float>(luaL_optnumber(L, startIndex + 9, 0));
		const float ky = static_cast<float>(luaL_optnumber(L, startIndex + 10, 0));
		matrix = Matrix4(x, y, angle, sx, sy, ox, oy, kx, ky);
	}
	const float wrap = static_cast<float>(luaL_checknumber(L, formatIndex));
	const char *value = lua_isnoneornil(L, formatIndex + 1)
		? nullptr : luaL_checkstring(L, formatIndex + 1);
	if (value && !Font::getConstant(value, align))
		return luax_enumerror(L, "alignment", Font::getConstants(align), value);
	luax_catchexcept(L, [&](){ printCommand(L)->printf(text, font, wrap, align, matrix); });
	return 0;
}

}
