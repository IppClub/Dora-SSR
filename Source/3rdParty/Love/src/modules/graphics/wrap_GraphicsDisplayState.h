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

#include "common/Color.h"
#include "common/math.h"
#include "common/runtime.h"

#include <string>

namespace love
{
namespace graphics
{

class GraphicsDisplayStateCommand
{
public:
	struct ColorMask
	{
		bool r;
		bool g;
		bool b;
		bool a;
	};
	enum LineStyle
	{
		LINE_ROUGH,
		LINE_SMOOTH,
	};
	enum LineJoin
	{
		LINE_JOIN_NONE,
		LINE_JOIN_MITER,
		LINE_JOIN_BEVEL,
	};
	enum FilterMode
	{
		FILTER_NONE,
		FILTER_LINEAR,
		FILTER_NEAREST,
	};
	enum BlendMode
	{
		BLEND_ALPHA,
		BLEND_ADD,
		BLEND_SUBTRACT,
		BLEND_MULTIPLY,
		BLEND_LIGHTEN,
		BLEND_DARKEN,
		BLEND_SCREEN,
		BLEND_REPLACE,
		BLEND_NONE,
	};
	enum BlendAlpha
	{
		BLENDALPHA_MULTIPLY,
		BLENDALPHA_PREMULTIPLIED,
	};
	enum CompareMode
	{
		COMPARE_LESS,
		COMPARE_LEQUAL,
		COMPARE_EQUAL,
		COMPARE_GEQUAL,
		COMPARE_GREATER,
		COMPARE_NOTEQUAL,
		COMPARE_ALWAYS,
		COMPARE_NEVER,
	};
	enum CullMode { CULL_NONE, CULL_BACK, CULL_FRONT };
	enum Winding { WINDING_CW, WINDING_CCW };
	enum StencilAction
	{
		STENCIL_REPLACE,
		STENCIL_INCREMENT,
		STENCIL_DECREMENT,
		STENCIL_INCREMENT_WRAP,
		STENCIL_DECREMENT_WRAP,
		STENCIL_INVERT,
	};
	struct Filter
	{
		FilterMode min = FILTER_LINEAR;
		FilterMode mag = FILTER_LINEAR;
		float anisotropy = 1.0f;
	};
	virtual ~GraphicsDisplayStateCommand() = default;
	virtual void setColor(Colorf color) = 0;
	virtual Colorf getColor() const = 0;
	virtual void setBackgroundColor(Colorf color) = 0;
	virtual Colorf getBackgroundColor() const = 0;
	virtual void setLineWidth(float width) = 0;
	virtual float getLineWidth() const = 0;
	virtual void setLineStyle(LineStyle style) = 0;
	virtual LineStyle getLineStyle() const = 0;
	virtual void setLineJoin(LineJoin join) = 0;
	virtual LineJoin getLineJoin() const = 0;
	virtual void setPointSize(float size) = 0;
	virtual float getPointSize() const = 0;
	virtual void setColorMask(ColorMask mask) = 0;
	virtual ColorMask getColorMask() const = 0;
	virtual void setWireframe(bool enabled) = 0;
	virtual bool isWireframe() const = 0;
	virtual void setScissor() = 0;
	virtual void setScissor(Rect rect) = 0;
	virtual void intersectScissor(Rect rect) = 0;
	virtual bool getScissor(Rect &rect) const = 0;
	virtual bool setDefaultFilter(Filter filter, std::string &error) = 0;
	virtual Filter getDefaultFilter() const = 0;
	virtual bool setDefaultMipmapFilter(FilterMode filter, float sharpness,
		std::string &error) = 0;
	virtual void getDefaultMipmapFilter(FilterMode &filter, float &sharpness) const = 0;
	virtual bool setBlendMode(BlendMode mode, BlendAlpha alphaMode,
		std::string &error) = 0;
	virtual BlendMode getBlendMode(BlendAlpha &alphaMode) const = 0;
	virtual void setDepthMode(CompareMode compare, bool write) = 0;
	virtual CompareMode getDepthMode(bool &write) const = 0;
	virtual void setMeshCullMode(CullMode mode) = 0;
	virtual CullMode getMeshCullMode() const = 0;
	virtual void setFrontFaceWinding(Winding winding) = 0;
	virtual Winding getFrontFaceWinding() const = 0;
	virtual void setStencilTest(CompareMode compare, int value) = 0;
	virtual CompareMode getStencilTest(int &value) const = 0;
	virtual bool beginStencilWrite(StencilAction action, int value,
		bool shouldClear, int clearValue, std::string &error) = 0;
	virtual void endStencilWrite() = 0;
};

int w_setColor(lua_State *L);
int w_getColor(lua_State *L);
int w_setBackgroundColor(lua_State *L);
int w_getBackgroundColor(lua_State *L);
int w_setLineWidth(lua_State *L);
int w_setLineStyle(lua_State *L);
int w_setLineJoin(lua_State *L);
int w_getLineWidth(lua_State *L);
int w_getLineStyle(lua_State *L);
int w_getLineJoin(lua_State *L);
int w_setPointSize(lua_State *L);
int w_getPointSize(lua_State *L);
int w_setColorMask(lua_State *L);
int w_getColorMask(lua_State *L);
int w_setWireframe(lua_State *L);
int w_isWireframe(lua_State *L);
int w_setScissor(lua_State *L);
int w_intersectScissor(lua_State *L);
int w_getScissor(lua_State *L);
int w_setDefaultFilter(lua_State *L);
int w_getDefaultFilter(lua_State *L);
int w_setDefaultMipmapFilter(lua_State *L);
int w_getDefaultMipmapFilter(lua_State *L);
int w_setBlendMode(lua_State *L);
int w_getBlendMode(lua_State *L);
int w_setDepthMode(lua_State *L);
int w_getDepthMode(lua_State *L);
int w_setMeshCullMode(lua_State *L);
int w_getMeshCullMode(lua_State *L);
int w_setFrontFaceWinding(lua_State *L);
int w_getFrontFaceWinding(lua_State *L);
int w_setStencilTest(lua_State *L);
int w_getStencilTest(lua_State *L);
int w_stencil(lua_State *L);

} // graphics
} // love
