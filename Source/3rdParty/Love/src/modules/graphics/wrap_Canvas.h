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

#pragma once

// LOVE
#include "common/runtime.h"
#include "common/Optional.h"
#include "Canvas.h"
#include "wrap_Texture.h"

namespace love
{
namespace graphics
{

//see Canvas.h
Canvas *luax_checkcanvas(lua_State *L, int idx);

class GraphicsCanvasCommand
{
public:
	enum TemporaryRenderTargetFlags
	{
		TEMPORARY_RT_DEPTH = 1 << 0,
		TEMPORARY_RT_STENCIL = 1 << 1,
	};
	struct RenderTarget
	{
		Canvas *canvas = nullptr;
		int slice = 0;
		int mipmap = 0;
		RenderTarget() = default;
		RenderTarget(Canvas *canvas, int slice) : canvas(canvas), slice(slice) { }
	};
	struct RenderTargets
	{
		std::vector<RenderTarget> colors;
		RenderTarget depthStencil;
		uint32 temporaryRTFlags = 0;
		const RenderTarget &getFirstTarget() const
		{
			return colors.empty() ? depthStencil : colors.front();
		}
	};
	virtual ~GraphicsCanvasCommand() = default;
	virtual Canvas *newCanvas(const Canvas::Settings &settings) = 0;
	virtual void renderTo(lua_State *L, Canvas *canvas, int slice,
		int functionIndex) = 0;
	virtual void stopStencilWrite() = 0;
	virtual void setCanvas(lua_State *L, const RenderTargets &targets) = 0;
	virtual RenderTargets getCanvas() const = 0;
	virtual void clear(Optional<Colorf> color, OptionalInt stencil,
		OptionalDouble depth) = 0;
	virtual void clear(const std::vector<Optional<Colorf>> &colors,
		OptionalInt stencil, OptionalDouble depth) = 0;
	virtual void discard(const std::vector<bool> &colorBuffers,
		bool depthStencil) = 0;
};

int w_setCanvas(lua_State *L);
int w_getCanvas(lua_State *L);
int w_clear(lua_State *L);
int w_discard(lua_State *L);

extern "C" int luaopen_canvas(lua_State *L);

} // graphics
} // love
