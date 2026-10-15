/** Copyright (c) 2006-2023 LOVE Development Team. */
#pragma once

#include "common/runtime.h"

#include <array>
#include <cstdint>
#include <string>
#include <utility>
#include <vector>

namespace love::graphics
{

class GraphicsCapabilitiesCommand
{
public:
	using BoolFields = std::vector<std::pair<std::string, bool>>;
	using NumberFields = std::vector<std::pair<std::string, double>>;
	using RendererInfo = std::array<std::string, 4>;
	using Stats = std::vector<std::pair<std::string, std::uint64_t>>;
	virtual ~GraphicsCapabilitiesCommand() = default;
	virtual BoolFields getSupported() const = 0;
	virtual BoolFields getTextureTypes() const = 0;
	virtual BoolFields getImageFormats() const = 0;
	virtual BoolFields getCanvasFormats(bool readable) const = 0;
	virtual BoolFields getTextureFormats(bool canvas, int readable,
		bool computeWrite, bool shaderAtomics) const = 0;
	virtual RendererInfo getRendererInfo() const = 0;
	virtual NumberFields getSystemLimits() const = 0;
	virtual Stats getStats() const = 0;
};

LOVE_EXPORT int w_getSupported(lua_State *L);
LOVE_EXPORT int w_getTextureTypes(lua_State *L);
LOVE_EXPORT int w_getImageFormats(lua_State *L);
LOVE_EXPORT int w_getCanvasFormats(lua_State *L);
LOVE_EXPORT int w_getTextureFormats(lua_State *L);
LOVE_EXPORT int w_getRendererInfo(lua_State *L);
LOVE_EXPORT int w_getSystemLimits(lua_State *L);
LOVE_EXPORT int w_getStats(lua_State *L);

}
