/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/DebugDraw.h"
#include "Node/DrawNode.h"
#include "Physics/Body.h"
#include "Physics/PhysicsWorld.h"
#include "PlayRho/Dynamics/Joints/FunctionalJointVisitor.hpp"

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
}

DebugDraw::~DebugDraw()
{ }

bool DebugDraw::IsVisible(pd::Fixture* fixture)
{
	return IsVisible(fixture->GetBody());
}

bool DebugDraw::IsVisible(pd::Body* prBody)
{
	Body* body = r_cast<Body*>(prBody->GetUserData());
	Node* owner = s_cast<Node*>(body->getOwner());
	return body->isVisible() && (owner == nullptr || (owner->isVisible() && (owner->getParent() == nullptr || owner->getParent()->isVisible())));
}

void DebugDraw::DrawPolygon(const pr::Length2* oldVertices, int vertexCount, const Color& color)
{
	vector<Vec2> vertices(vertexCount + 1);
	for (int i = 0; i < vertexCount; i++)
	{
		vertices[i] = PhysicsWorld::oVal(oldVertices[i]);
	}
	vertices[vertexCount] = vertices[0];
	_line->add(vertices, color);
}

void DebugDraw::DrawSolidPolygon(const pr::Length2* oldVertices, int vertexCount, const Color& color)
{
	vector<Vec2> vertices(vertexCount + 1);
	for (int i = 0; i < vertexCount; i++)
	{
		vertices[i] = PhysicsWorld::oVal(oldVertices[i]);
	}
	vertices[vertexCount] = vertices[0];
	_drawNode->drawPolygon(vertices.data(), vertexCount, Color(
		s_cast<Uint8>(color.r * 0.5f),
		s_cast<Uint8>(color.g * 0.5f),
		s_cast<Uint8>(color.b * 0.5f),
		s_cast<Uint8>(color.a * 0.5f))
	);
	_line->add(vertices, color);
}

void DebugDraw::DrawCircle(const pr::Length2& center, float radius, const Color& color)
{
	const float k_segments = 16.0f;
	const int vertexCount = 16;
	const float k_increment = 2.0f * bx::kPi / k_segments;
	float theta = 0.0f;

	Vec2 pos{center[0], center[1]};
	Vec2 vertices[vertexCount + 1];
	for (int i = 0; i < k_segments; ++i)
	{
		Vec2 v = pos + Vec2{std::cos(theta), std::sin(theta)} * radius;
		vertices[i] = PhysicsWorld::oVal(Vec2{v.x, v.y});
		theta += k_increment;
	}
	vertices[vertexCount] = vertices[0];
	_line->add(vertices, vertexCount + 1, color);
}

void DebugDraw::DrawSolidCircle(const pr::Length2& center, float radius, const Color& color)
{
	const float k_segments = 16.0f;
	const int vertexCount = 16;
	const float k_increment = 2.0f * bx::kPi / k_segments;
	float theta = 0.0f;

	Vec2 pos{center[0], center[1]};
	Vec2 vertices[vertexCount + 1];
	for (int i = 0; i < k_segments; ++i)
	{
		Vec2 v = pos + Vec2{std::cos(theta), std::sin(theta)} * radius;
		vertices[i] = PhysicsWorld::oVal(Vec2{v.x, v.y});
		theta += k_increment;
	}
	_drawNode->drawPolygon(vertices, vertexCount, Color(
		s_cast<Uint8>(color.r * 0.5f),
		s_cast<Uint8>(color.g * 0.5f),
		s_cast<Uint8>(color.b * 0.5f),
		s_cast<Uint8>(color.a * 0.5f))
	);
	vertices[vertexCount] = vertices[0];
	_line->add(vertices, vertexCount + 1, color);
}

void DebugDraw::DrawSegment(const pr::Length2& p1, const pr::Length2& p2, const Color& color)
{
	Vec2 vertices[] = {PhysicsWorld::oVal(p1), PhysicsWorld::oVal(p2)};
	_line->add(vertices, 2, color);
}

NS_DOROTHY_END

using namespace playrho;
using namespace playrho::d2;

using Dorothy::DebugDraw;
using Dorothy::Color;

static void Draw(DebugDraw* drawer, const DistanceProxy& shape, Color color, Transformation xf)
{
    const auto vertexCount = shape.GetVertexCount();
    auto vertices = std::vector<Length2>(vertexCount);
    for (auto i = decltype(vertexCount){0}; i < vertexCount; ++i)
    {
        vertices[i] = Transform(shape.GetVertex(i), xf);
    }
    drawer->DrawSolidPolygon(&vertices[0], vertexCount, color);
}

static void Draw(DebugDraw* drawer, const DiskShapeConf& shape, Color color, Transformation xf)
{
    const auto center = Transform(shape.GetLocation(), xf);
    const auto radius = shape.GetRadius();
    drawer->DrawSolidCircle(center, radius, color);
    const auto axis = Rotate(Vec2{1, 0}, xf.q);
    drawer->DrawSegment(center, center + radius * axis, color);
}

static void Draw(DebugDraw* drawer, const EdgeShapeConf& shape, Color color, Transformation xf)
{
	Color ghostColor(s_cast<Uint8>(0.75f * color.r), s_cast<Uint8>(0.75f * color.g), s_cast<Uint8>(0.75f * color.b), color.a);
    const auto v1 = Transform(shape.GetVertexA(), xf);
    const auto v2 = Transform(shape.GetVertexB(), xf);
    drawer->DrawSegment(v1, v2, color);
	drawer->DrawCircle(v1, 0.05f, ghostColor);
	drawer->DrawCircle(v2, 0.05f, ghostColor);
}

static void Draw(DebugDraw* drawer, const ChainShapeConf& shape, Color color, Transformation xf)
{
    const auto count = shape.GetVertexCount();
	Color ghostColor(s_cast<Uint8>(0.75f * color.r), s_cast<Uint8>(0.75f * color.g), s_cast<Uint8>(0.75f * color.b), color.a);
    auto v1 = Transform(shape.GetVertex(0), xf);
    for (auto i = decltype(count){1}; i < count; ++i)
    {
        const auto v2 = Transform(shape.GetVertex(i), xf);
        drawer->DrawSegment(v1, v2, color);
        drawer->DrawCircle(v1, 0.05f, ghostColor);
        v1 = v2;
    }
}

static void Draw(DebugDraw* drawer, const PolygonShapeConf& shape, Color color, Transformation xf)
{
    Draw(drawer, GetChild(shape, 0), color, xf);
}

static void Draw(DebugDraw* drawer, const MultiShapeConf& shape, Color color, Transformation xf)
{
    const auto count = GetChildCount(shape);
    for (auto i = decltype(count){0}; i < count; ++i)
    {
        Draw(drawer, GetChild(shape, i), color, xf);
    }
}

struct VisitorData
{
    DebugDraw* drawer;
    Transformation xf;
    Color color;
};

namespace playrho {

template <>
bool Visit(const d2::DiskShapeConf& shape, void* userData)
{
    const auto data = static_cast<VisitorData*>(userData);
    Draw(data->drawer, shape, data->color, data->xf);
    return true;
}

template <>
bool Visit(const d2::EdgeShapeConf& shape, void* userData)
{
    const auto data = static_cast<VisitorData*>(userData);
    Draw(data->drawer, shape, data->color, data->xf);
    return true;
}

template <>
bool Visit(const d2::PolygonShapeConf& shape, void* userData)
{
    const auto data = static_cast<VisitorData*>(userData);
    Draw(data->drawer, shape, data->color, data->xf);
    return true;
}

template <>
bool Visit(const d2::ChainShapeConf& shape, void* userData)
{
    const auto data = static_cast<VisitorData*>(userData);
    Draw(data->drawer, shape, data->color, data->xf);
    return true;
}

template <>
bool Visit(const d2::MultiShapeConf& shape, void* userData)
{
    const auto data = static_cast<VisitorData*>(userData);
    Draw(data->drawer, shape, data->color, data->xf);
    return true;
}

} // namespace playrho

static void Draw(DebugDraw* drawer, const Fixture& fixture, const Color& color)
{
    const auto xf = GetTransformation(fixture);
    auto visitor = VisitorData{};
    visitor.drawer = drawer;
    visitor.xf = xf;
    visitor.color = color;
    Visit(fixture.GetShape(), &visitor);
}

const static Color disabledColor(Dorothy::Vec4{0.5f, 0.5f, 0.3f, 1.0f});
const static Color staticColor(Dorothy::Vec4{0.5f, 0.9f, 0.5f, 1.0f});
const static Color kinematicColor(Dorothy::Vec4{0.5f, 0.5f, 0.9f, 1.0f});
const static Color sleepColor(Dorothy::Vec4{0.6f, 0.6f, 0.6f, 1.0f});
const static Color activeColor(Dorothy::Vec4{0.9f, 0.7f, 0.7f, 1.0f});
const static Color sensorColor(Dorothy::Vec4{1.0f, 0.9f, 0.0f, 1.0f});

static const Color& GetColor(const Body& body)
{
    if (!body.IsEnabled())
    {
        return disabledColor;
    }
    if (body.GetType() == BodyType::Static)
    {
        return staticColor;
    }
    if (body.GetType() == BodyType::Kinematic)
    {
        return kinematicColor;
    }
    if (!body.IsAwake())
    {
        return sleepColor;
    }
	return activeColor;
}

static void Draw(DebugDraw* drawer, const Body& body)
{
    const auto bodyColor = GetColor(body);
    for (auto&& fixture: body.GetFixtures())
    {
		const auto& f = GetRef(fixture);
		auto color = f.IsSensor() ? sensorColor : bodyColor;
		Draw(drawer, f, color);
    }
}

static const Color jointColor(Dorothy::Vec4{0.5f, 0.8f, 0.8f, 1.0f});

static void Draw(DebugDraw* drawer, const Joint& joint)
{
    const auto p1 = joint.GetAnchorA();
    const auto p2 = joint.GetAnchorB();

    switch (GetType(joint))
    {
        case JointType::Distance:
            drawer->DrawSegment(p1, p2, jointColor);
            break;
        case JointType::Pulley:
		{
			const auto pulley = static_cast<const PulleyJoint&>(joint);
			const auto s1 = pulley.GetGroundAnchorA();
			const auto s2 = pulley.GetGroundAnchorB();
			drawer->DrawSegment(s1, p1, jointColor);
			drawer->DrawSegment(s2, p2, jointColor);
			drawer->DrawSegment(s1, s2, jointColor);
			break;
		}
        case JointType::Target:
            break;
        default:
        {
            const auto bodyA = joint.GetBodyA();
            const auto bodyB = joint.GetBodyB();
            const auto x1 = bodyA->GetTransformation().p;
            const auto x2 = bodyB->GetTransformation().p;
            drawer->DrawSegment(x1, p1, jointColor);
            drawer->DrawSegment(p1, p2, jointColor);
            drawer->DrawSegment(x2, p2, jointColor);
        }
    }
}

void DrawWorld(DebugDraw* drawer, const World& world)
{
	for (auto&& body: world.GetBodies())
	{
		if (DebugDraw::IsVisible(body))
		{
			const auto b = GetPtr(body);
			Draw(drawer, *b);
		}
	}
	for (auto&& j: world.GetJoints())
	{
		Draw(drawer, *j);
	}
}

NS_DOROTHY_BEGIN

void DebugDraw::DrawWorld(pd::World* world)
{
	_drawNode->clear();
	_line->clear();
	::DrawWorld(this, *world);
}

NS_DOROTHY_END
