/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 **/

#include "wrap_Canvas.h"

namespace love
{
namespace graphics
{

Canvas *luax_checkcanvas(lua_State *L, int idx)
{
	return luax_checktype<Canvas>(L, idx);
}

static GraphicsCanvasCommand *canvasCommand(lua_State *L)
{
	auto *module = luax_getmodule(L, Module::M_GRAPHICS);
	auto *command = dynamic_cast<GraphicsCanvasCommand *>(module);
	if (command == nullptr)
		luaL_error(L, "love.graphics has no state-local Canvas command adapter");
	return command;
}

static GraphicsCanvasCommand::RenderTarget checkRenderTarget(lua_State *L, int idx)
{
	lua_rawgeti(L, idx, 1);
	GraphicsCanvasCommand::RenderTarget target(luax_checkcanvas(L, -1), 0);
	lua_pop(L, 1);

	TextureType type = target.canvas->getTextureType();
	if (type == TEXTURE_2D_ARRAY || type == TEXTURE_VOLUME)
		target.slice = luax_checkintflag(L, idx, "layer") - 1;
	else if (type == TEXTURE_CUBE)
		target.slice = luax_checkintflag(L, idx, "face") - 1;

	target.mipmap = luax_intflag(L, idx, "mipmap", 1) - 1;
	return target;
}

int w_setCanvas(lua_State *L)
{
	auto *command = canvasCommand(L);
	command->stopStencilWrite();

	if (lua_isnoneornil(L, 1))
	{
		command->setCanvas(L, {});
		return 0;
	}

	const bool isTable = lua_istable(L, 1);
	GraphicsCanvasCommand::RenderTargets targets;
	if (isTable)
	{
		lua_rawgeti(L, 1, 1);
		const bool tableOfTables = lua_istable(L, -1);
		lua_pop(L, 1);

		for (int index = 1; index <= (int) luax_objlen(L, 1); ++index)
		{
			lua_rawgeti(L, 1, index);
			if (tableOfTables)
				targets.colors.push_back(checkRenderTarget(L, -1));
			else
			{
				targets.colors.emplace_back(luax_checkcanvas(L, -1), 0);
				if (targets.colors.back().canvas->getTextureType() != TEXTURE_2D)
					return luaL_error(L,
						"Non-2D canvases must use the table-of-tables variant of setCanvas.");
			}
			lua_pop(L, 1);
		}

		lua_getfield(L, 1, "depthstencil");
		const int depthStencilType = lua_type(L, -1);
		if (depthStencilType == LUA_TTABLE)
			targets.depthStencil = checkRenderTarget(L, -1);
		else if (depthStencilType == LUA_TBOOLEAN)
			targets.temporaryRTFlags |= luax_toboolean(L, -1)
				? (GraphicsCanvasCommand::TEMPORARY_RT_DEPTH
					| GraphicsCanvasCommand::TEMPORARY_RT_STENCIL) : 0;
		else if (depthStencilType != LUA_TNONE && depthStencilType != LUA_TNIL)
			targets.depthStencil.canvas = luax_checkcanvas(L, -1);
		lua_pop(L, 1);

		if (targets.depthStencil.canvas == nullptr
			&& (targets.temporaryRTFlags & GraphicsCanvasCommand::TEMPORARY_RT_DEPTH) == 0)
			targets.temporaryRTFlags |= luax_boolflag(L, 1, "depth", false)
				? GraphicsCanvasCommand::TEMPORARY_RT_DEPTH : 0;
		if (targets.depthStencil.canvas == nullptr
			&& (targets.temporaryRTFlags & GraphicsCanvasCommand::TEMPORARY_RT_STENCIL) == 0)
			targets.temporaryRTFlags |= luax_boolflag(L, 1, "stencil", false)
				? GraphicsCanvasCommand::TEMPORARY_RT_STENCIL : 0;
	}
	else
	{
		for (int index = 1; index <= lua_gettop(L); ++index)
		{
			GraphicsCanvasCommand::RenderTarget target(luax_checkcanvas(L, index), 0);
			const TextureType type = target.canvas->getTextureType();
			if (index == 1 && type != TEXTURE_2D)
			{
				target.slice = (int) luaL_checkinteger(L, index + 1) - 1;
				target.mipmap = (int) luaL_optinteger(L, index + 2, 1) - 1;
				targets.colors.push_back(target);
				break;
			}
			else if (type == TEXTURE_2D && lua_isnumber(L, index + 1))
			{
				target.mipmap = (int) luaL_optinteger(L, index + 1, 1) - 1;
				++index;
			}
			if (index > 1 && type != TEXTURE_2D)
				return luaL_error(L,
					"This variant of setCanvas only supports 2D texture types.");
			targets.colors.push_back(target);
		}
	}

	luax_catchexcept(L, [&]()
	{
		if (targets.getFirstTarget().canvas != nullptr)
			command->setCanvas(L, targets);
		else
			command->setCanvas(L, {});
	});
	return 0;
}

static void pushRenderTarget(lua_State *L,
	const GraphicsCanvasCommand::RenderTarget &target)
{
	lua_createtable(L, 1, 2);
	luax_pushtype(L, target.canvas);
	lua_rawseti(L, -2, 1);
	const TextureType type = target.canvas->getTextureType();
	if (type == TEXTURE_2D_ARRAY || type == TEXTURE_VOLUME)
	{
		lua_pushnumber(L, target.slice + 1);
		lua_setfield(L, -2, "layer");
	}
	else if (type == TEXTURE_CUBE)
	{
		lua_pushnumber(L, target.slice + 1);
		lua_setfield(L, -2, "face");
	}
	lua_pushnumber(L, target.mipmap + 1);
	lua_setfield(L, -2, "mipmap");
}

int w_getCanvas(lua_State *L)
{
	auto targets = canvasCommand(L)->getCanvas();
	const int count = (int) targets.colors.size();
	if (count == 0)
	{
		lua_pushnil(L);
		return 1;
	}

	bool tableVariant = targets.depthStencil.canvas != nullptr;
	if (!tableVariant)
		for (const auto &target : targets.colors)
			if (target.mipmap != 0 || target.canvas->getTextureType() != TEXTURE_2D)
			{
				tableVariant = true;
				break;
			}

	if (tableVariant)
	{
		lua_createtable(L, count, 0);
		for (int index = 0; index < count; ++index)
		{
			pushRenderTarget(L, targets.colors[index]);
			lua_rawseti(L, -2, index + 1);
		}
		if (targets.depthStencil.canvas != nullptr)
		{
			pushRenderTarget(L, targets.depthStencil);
			lua_setfield(L, -2, "depthstencil");
		}
		return 1;
	}

	for (const auto &target : targets.colors)
		luax_pushtype(L, target.canvas);
	return count;
}

int w_clear(lua_State *L)
{
	Optional<Colorf> color(Colorf(0.0f, 0.0f, 0.0f, 0.0f));
	std::vector<Optional<Colorf>> colors;
	OptionalInt stencil(0);
	OptionalDouble depth(1.0);

	int argumentType = lua_type(L, 1);
	int startIndex = -1;
	if (argumentType == LUA_TTABLE)
	{
		const int maximum = lua_gettop(L);
		colors.reserve(maximum);
		for (int index = 0; index < maximum; ++index)
		{
			argumentType = lua_type(L, index + 1);
			if (argumentType == LUA_TNUMBER || argumentType == LUA_TBOOLEAN)
			{
				startIndex = index + 1;
				break;
			}
			else if (argumentType == LUA_TNIL || argumentType == LUA_TNONE
				|| luax_objlen(L, index + 1) == 0)
			{
				colors.push_back(Optional<Colorf>());
				continue;
			}
			for (int component = 1; component <= 4; ++component)
				lua_rawgeti(L, index + 1, component);
			Optional<Colorf> attachmentColor;
			attachmentColor.hasValue = true;
			attachmentColor.value.r = (float) luaL_checknumber(L, -4);
			attachmentColor.value.g = (float) luaL_checknumber(L, -3);
			attachmentColor.value.b = (float) luaL_checknumber(L, -2);
			attachmentColor.value.a = (float) luaL_optnumber(L, -1, 1.0);
			colors.push_back(attachmentColor);
			lua_pop(L, 4);
		}
	}
	else if (argumentType == LUA_TBOOLEAN)
	{
		color.hasValue = luax_toboolean(L, 1);
		startIndex = 2;
	}
	else if (argumentType != LUA_TNONE && argumentType != LUA_TNIL)
	{
		color.hasValue = true;
		color.value.r = (float) luaL_checknumber(L, 1);
		color.value.g = (float) luaL_checknumber(L, 2);
		color.value.b = (float) luaL_checknumber(L, 3);
		color.value.a = (float) luaL_optnumber(L, 4, 1.0);
		startIndex = 5;
	}

	if (startIndex >= 0)
	{
		argumentType = lua_type(L, startIndex);
		if (argumentType == LUA_TBOOLEAN)
			stencil.hasValue = luax_toboolean(L, startIndex);
		else if (argumentType == LUA_TNUMBER)
			stencil.value = (int) luaL_checkinteger(L, startIndex);
		argumentType = lua_type(L, startIndex + 1);
		if (argumentType == LUA_TBOOLEAN)
			depth.hasValue = luax_toboolean(L, startIndex + 1);
		else if (argumentType == LUA_TNUMBER)
			depth.value = luaL_checknumber(L, startIndex + 1);
	}

	auto *command = canvasCommand(L);
	luax_catchexcept(L, [&]()
	{
		if (colors.empty())
			command->clear(color, stencil, depth);
		else
			command->clear(colors, stencil, depth);
	});
	return 0;
}

int w_discard(lua_State *L)
{
	std::vector<bool> colorBuffers;
	if (lua_istable(L, 1))
	{
		for (size_t index = 1; index <= luax_objlen(L, 1); ++index)
		{
			lua_rawgeti(L, 1, index);
			colorBuffers.push_back(luax_optboolean(L, -1, true));
			lua_pop(L, 1);
		}
	}
	else
	{
		const bool discardColor = luax_optboolean(L, 1, true);
		const size_t count = std::max((size_t) 1,
			canvasCommand(L)->getCanvas().colors.size());
		colorBuffers = std::vector<bool>(count, discardColor);
	}
	const bool depthStencil = luax_optboolean(L, 2, true);
	canvasCommand(L)->discard(colorBuffers, depthStencil);
	return 0;
}

int w_Canvas_getMSAA(lua_State *L)
{
	Canvas *canvas = luax_checkcanvas(L, 1);
	lua_pushinteger(L, canvas->getMSAA());
	return 1;
}

int w_Canvas_renderTo(lua_State *L)
{
	Canvas *canvas = luax_checkcanvas(L, 1);
	int startidx = 2;
	int slice = 0;
	if (canvas->getTextureType() != TEXTURE_2D)
	{
		slice = (int) luaL_checkinteger(L, 2) - 1;
		startidx++;
	}
	luaL_checktype(L, startidx, LUA_TFUNCTION);
	luax_catchexcept(L, [&]()
	{
		auto *module = luax_getmodule(L, Module::M_GRAPHICS);
		auto *command = dynamic_cast<GraphicsCanvasCommand *>(module);
		if (command == nullptr)
			throw love::Exception(
				"love.graphics has no state-local Canvas command adapter");
		command->renderTo(L, canvas, slice, startidx);
	});
	return 0;
}

int w_Canvas_newImageData(lua_State *L)
{
	Canvas *canvas = luax_checkcanvas(L, 1);
	love::image::Image *image = luax_getmodule<love::image::Image>(L, love::image::Image::type);

	int slice = 0;
	if (canvas->getTextureType() != TEXTURE_2D)
		slice = (int) luaL_checkinteger(L, 2) - 1;
	int mipmap = (int) luaL_optinteger(L, 3, 1) - 1;
	Rect rect = {0, 0, canvas->getPixelWidth(mipmap),
		canvas->getPixelHeight(mipmap)};

	if (!lua_isnoneornil(L, 4))
	{
		rect.x = (int) luaL_checkinteger(L, 4);
		rect.y = (int) luaL_checkinteger(L, 5);
		rect.w = (int) luaL_checkinteger(L, 6);
		rect.h = (int) luaL_checkinteger(L, 7);
	}

	love::image::ImageData *img = nullptr;
	luax_catchexcept(L, [&](){ img = canvas->newImageData(image, slice, mipmap, rect); });

	luax_pushtype(L, img);
	img->release();
	return 1;
}

int w_Canvas_generateMipmaps(lua_State *L)
{
	Canvas *c = luax_checkcanvas(L, 1);
	luax_catchexcept(L, [&]() { c->generateMipmaps(); });
	return 0;
}

int w_Canvas_getMipmapMode(lua_State *L)
{
	Canvas *c = luax_checkcanvas(L, 1);
	const char *str;
	if (!Canvas::getConstant(c->getMipmapMode(), str))
		return luax_enumerror(L, "mipmap mode", Canvas::getConstants(Canvas::MIPMAPS_MAX_ENUM), str);

	lua_pushstring(L, str);
	return 1;
}

static const luaL_Reg w_Canvas_functions[] =
{
	{ "getMSAA", w_Canvas_getMSAA },
	{ "renderTo", w_Canvas_renderTo },
	{ "newImageData", w_Canvas_newImageData },
	{ "generateMipmaps", w_Canvas_generateMipmaps },
	{ "getMipmapMode", w_Canvas_getMipmapMode },
	{ 0, 0 }
};

extern "C" int luaopen_canvas(lua_State *L)
{
	return luax_register_type(L, &Canvas::type, w_Texture_functions, w_Canvas_functions, nullptr);
}

} // graphics
} // love
