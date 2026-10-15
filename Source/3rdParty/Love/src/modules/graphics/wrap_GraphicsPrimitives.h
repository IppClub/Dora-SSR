/** Copyright (c) 2006-2023 LOVE Development Team. */
#pragma once

#include "common/Color.h"
#include "common/Vector.h"
#include "common/runtime.h"

#include <vector>

namespace love::graphics
{

class GraphicsPrimitivesCommand
{
public:
	enum class DrawMode { Line, Fill };
	enum class ArcMode { Open, Closed, Pie };
	virtual ~GraphicsPrimitivesCommand() = default;
	virtual void points(const std::vector<Vector2> &positions,
		const std::vector<Colorf> &colors) = 0;
	virtual void polyline(const std::vector<Vector2> &vertices) = 0;
	virtual void rectangle(DrawMode mode, float x, float y, float width, float height,
		float radiusX, float radiusY, int points) = 0;
	virtual void circle(DrawMode mode, float x, float y, float radius, int points) = 0;
	virtual void ellipse(DrawMode mode, float x, float y, float radiusX, float radiusY,
		int points) = 0;
	virtual void arc(DrawMode drawMode, ArcMode arcMode, float x, float y, float radius,
		float angle1, float angle2, int points) = 0;
	virtual void polygon(DrawMode mode, const std::vector<Vector2> &vertices) = 0;
};

LOVE_EXPORT int w_points(lua_State *L);
LOVE_EXPORT int w_line(lua_State *L);
LOVE_EXPORT int w_rectangle(lua_State *L);
LOVE_EXPORT int w_circle(lua_State *L);
LOVE_EXPORT int w_ellipse(lua_State *L);
LOVE_EXPORT int w_arc(lua_State *L);
LOVE_EXPORT int w_polygon(lua_State *L);

}
