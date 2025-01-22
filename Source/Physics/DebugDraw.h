/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Support/Common.h"
#include "Support/Geometry.h"

NS_DORA_BEGIN

namespace pr = playrho;
namespace pd = playrho::d2;

class Body;
class PhysicsWorld;
class DrawNode;
class Line;

class DebugDraw {
public:
	PROPERTY_READONLY(DrawNode*, Renderer);
	DebugDraw();
	virtual ~DebugDraw();
	void DrawWorld(PhysicsWorld* world);

public:
	static bool IsVisible(Body* body);
	void DrawPolygon(const pr::Length2* vertices, int vertexCount, const Color& color);
	void DrawSolidPolygon(const pr::Length2* vertices, int vertexCount, const Color& color);
	void DrawCircle(const pr::Length2& center, float radius, const Color& color);
	void DrawSolidCircle(const pr::Length2& center, float radius, const Color& color);
	void DrawSegment(const pr::Length2& p1, const pr::Length2& p2, const Color& color);

private:
	Ref<DrawNode> _drawNode;
	Ref<Line> _line;
};

NS_DORA_END
