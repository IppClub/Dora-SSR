/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/DebugDraw.h"
#include "Node/DrawNode.h"
#include "Physics/Body.h"
#include "Physics/World.h"

NS_DOROTHY_BEGIN

DrawNode* DebugDraw::getRenderer() const
{
	return _drawNode;
}

DebugDraw::DebugDraw():
_drawNode(DrawNode::create()),
_line(Line::create())
{
	_drawNode->addChild(_line);
	SetFlags(e_jointBit | e_shapeBit);
}

void DebugDraw::prepare()
{
	_drawNode->clear();
	_line->clear();
}

bool DebugDraw::IsVisible(b2Fixture* fixture)
{
	return IsVisible(fixture->GetBody());
}

bool DebugDraw::IsVisible(b2Body* bodyB2)
{
	Body* body = r_cast<Body*>(bodyB2->GetUserData());
	Node* owner = s_cast<Node*>(body->getOwner());
	return body->isVisible() && (owner == nullptr || (owner->isVisible() && (owner->getParent() == nullptr || owner->getParent()->isVisible())));
}

void DebugDraw::DrawPolygon(const b2Vec2* oldVertices, int vertexCount, const b2Color& color)
{
	Vec2 vertices[b2_maxPolygonVertices + 1];
	for (int i = 0; i < vertexCount; i++)
	{
		vertices[i] = World::oVal(oldVertices[i]);
	}
	vertices[vertexCount] = vertices[0];
	_line->add(vertices, vertexCount + 1, Color(Vec4{color.r, color.g, color.b, 1.0f}));
}

void DebugDraw::DrawSolidPolygon(const b2Vec2* oldVertices, int vertexCount, const b2Color& color)
{
	Vec2 vertices[b2_maxPolygonVertices + 1];
	for (int i = 0; i < vertexCount; i++)
	{
		vertices[i] = World::oVal(oldVertices[i]);
	}
	vertices[vertexCount] = vertices[0];
	_drawNode->drawPolygon(vertices, vertexCount, Color(Vec4{color.r * 0.5f, color.g * 0.5f, color.b * 0.5f, 0.5f}));
	_line->add(vertices, vertexCount + 1, Color(Vec4{color.r, color.g, color.b, 1.0f}));
}

void DebugDraw::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	const int vertexCount = 16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;

	Vec2 vertices[vertexCount];
	for (int i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(std::cos(theta), std::sin(theta));
		vertices[i] = World::oVal(Vec2{v.x, v.y});
		theta += k_increment;
	}
	_line->add(vertices, vertexCount, Color(Vec4{color.r, color.g, color.b, 1.0f}));
}

void DebugDraw::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{
	const float32 k_segments = 16.0f;
	const int vertexCount = 16;
	const float32 k_increment = 2.0f * b2_pi / k_segments;
	float32 theta = 0.0f;

	Vec2 vertices[vertexCount + 2];
	for (int i = 0; i < k_segments; ++i)
	{
		b2Vec2 v = center + radius * b2Vec2(std::cos(theta), std::sin(theta));
		vertices[i] = World::oVal(Vec2{v.x, v.y});
		theta += k_increment;
	}
	vertices[vertexCount] = vertices[0];
	_drawNode->drawPolygon(vertices, vertexCount, Color(Vec4{color.r * 0.5f, color.g * 0.5f, color.b * 0.5f, 0.5f}));
	_line->add(vertices, vertexCount + 1, Color(Vec4{color.r, color.g, color.b, 1.0f}));
	vertices[0] = World::oVal(center);
	vertices[1] = World::oVal(center + radius * axis);
	_line->add(vertices, 2, Color(Vec4{color.r, color.g, color.b, 1.0f}));
}

void DebugDraw::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)
{
	Vec2 vertices[] = {World::oVal(p1), World::oVal(p2)};
	_line->add(vertices, 2, Color(Vec4{color.r, color.g, color.b, 1.0f}));
}

void DebugDraw::DrawTransform(const b2Transform& xf)
{
	b2Vec2 p1 = xf.p, p2;
	const float32 k_axisScale = 0.4f;
	p2 = p1 + k_axisScale * xf.q.GetXAxis();
	DrawSegment(p1, p2, b2Color(1, 0, 0));

	p2 = p1 + k_axisScale * xf.q.GetYAxis();
	DrawSegment(p1, p2, b2Color(0, 1, 0));
}

NS_DOROTHY_END
