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
	_line->add(vertices, Color(color.r, color.g, color.b, 255));
}

void DebugDraw::DrawSolidPolygon(const pr::Length2* oldVertices, int vertexCount, const Color& color)
{
	vector<Vec2> vertices(vertexCount + 1);
	for (int i = 0; i < vertexCount; i++)
	{
		vertices[i] = PhysicsWorld::oVal(oldVertices[i]);
	}
	vertices[vertexCount] = vertices[0];
	_drawNode->drawPolygon(vertices.data(), vertexCount, Color(Vec4{color.r * 0.5f, color.g * 0.5f, color.b * 0.5f, 0.5f}));
	_line->add(vertices, Color(color.r, color.g, color.b, 255));
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
	_line->add(vertices, vertexCount + 1, Color(color.r, color.g, color.b, 255));
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
	_drawNode->drawPolygon(vertices, vertexCount, Color(Vec4{color.r * 0.5f, color.g * 0.5f, color.b * 0.5f, 0.5f}));
	vertices[vertexCount] = vertices[0];
	_line->add(vertices, vertexCount + 1, Color(color.r, color.g, color.b, 255));
}

void DebugDraw::DrawSegment(const pr::Length2& p1, const pr::Length2& p2, const Color& color)
{
	Vec2 vertices[] = {PhysicsWorld::oVal(p1), PhysicsWorld::oVal(p2)};
	_line->add(vertices, 2, Color(color.r, color.g, color.b, 255));
}

NS_DOROTHY_END

using namespace playrho;
using namespace playrho::d2;

using Dorothy::DebugDraw;
using Dorothy::Color;

static void DrawCorner(DebugDraw* drawer, Length2 p, Length r, Angle a0, Angle a1, Color color)
{
    const auto angleDiff = GetRevRotationalAngle(a0, a1);
    auto lastAngle = 0_deg;
    for (auto angle = 5_deg; angle < angleDiff; angle += 5_deg)
    {
        const auto c0 = p + r * UnitVec::Get(a0 + lastAngle);
        const auto c1 = p + r * UnitVec::Get(a0 + angle);
        drawer->DrawSegment(c0, c1, color);
        lastAngle = angle;
    }
    {
        const auto c0 = p + r * UnitVec::Get(a0 + lastAngle);
        const auto c1 = p + r * UnitVec::Get(a1);
        drawer->DrawSegment(c0, c1, color);
    }
}

static void Draw(DebugDraw* drawer, const DistanceProxy& shape, Color color, bool skins, Transformation xf)
{
    const auto vertexCount = shape.GetVertexCount();
    auto vertices = std::vector<Length2>(vertexCount);
    for (auto i = decltype(vertexCount){0}; i < vertexCount; ++i)
    {
        vertices[i] = Transform(shape.GetVertex(i), xf);
    }
    const auto fillColor = Color(0.5f * color.r, 0.5f * color.g, 0.5f * color.b, 0.5f * 255);
    drawer->DrawSolidPolygon(&vertices[0], vertexCount, fillColor);
    drawer->DrawPolygon(&vertices[0], vertexCount, color);

    if (!skins)
    {
        return;
    }

    const auto skinColor = Color(color.r * 0.6f, color.g * 0.6f, color.b * 0.6f, 255);
    const auto r = GetVertexRadius(shape);
    for (auto i = decltype(vertexCount){0}; i < vertexCount; ++i)
    {
        if (i > 0)
        {
            const auto worldNormal0 = Rotate(shape.GetNormal(i - 1), xf.q);
            const auto p0 = vertices[i-1] + worldNormal0 * r;
            const auto p1 = vertices[i] + worldNormal0 * r;
            drawer->DrawSegment(p0, p1, skinColor);
            const auto normal1 = shape.GetNormal(i);
            const auto worldNormal1 = Rotate(normal1, xf.q);
            const auto angle0 = GetAngle(worldNormal0);
            const auto angle1 = GetAngle(worldNormal1);
            DrawCorner(drawer, vertices[i], r, angle0, angle1, skinColor);
        }
    }
    if (vertexCount > 1)
    {
        const auto worldNormal0 = Rotate(shape.GetNormal(vertexCount - 1), xf.q);
        drawer->DrawSegment(vertices[vertexCount - 1] + worldNormal0 * r, vertices[0] + worldNormal0 * r, skinColor);
        const auto worldNormal1 = Rotate(shape.GetNormal(0), xf.q);
        const auto angle0 = GetAngle(worldNormal0);
        const auto angle1 = GetAngle(worldNormal1);
        DrawCorner(drawer, vertices[0], r, angle0, angle1, skinColor);
    }
    else if (vertexCount == 1)
    {
        DrawCorner(drawer, vertices[0], r, 0_deg, 360_deg, skinColor);
    }
}

static void Draw(DebugDraw* drawer, const DiskShapeConf& shape, Color color, Transformation xf)
{
    const auto center = Transform(shape.GetLocation(), xf);
    const auto radius = shape.GetRadius();
    const auto fillColor = Color(0.5f * color.r, 0.5f * color.g, 0.5f * color.b, 0.5f * 255);
    drawer->DrawSolidCircle(center, radius, fillColor);
    drawer->DrawCircle(center, radius, color);

    // Draw a line fixed in the circle to animate rotation.
    const auto axis = Rotate(Vec2{1, 0}, xf.q);
    drawer->DrawSegment(center, center + radius * axis, color);
}

static void Draw(DebugDraw* drawer, const EdgeShapeConf& shape, Color color, bool skins, Transformation xf)
{
    const auto v1 = Transform(shape.GetVertexA(), xf);
    const auto v2 = Transform(shape.GetVertexB(), xf);
    drawer->DrawSegment(v1, v2, color);

    if (skins)
    {
        const auto r = GetVertexRadius(shape);
        if (r > 0_m)
        {
            const auto skinColor = Color(color.r * 0.6f, color.g * 0.6f, color.b * 0.6f, 255);
            const auto worldNormal0 = GetFwdPerpendicular(GetUnitVector(v2 - v1));
            const auto offset = worldNormal0 * r;
            drawer->DrawSegment(v1 + offset, v2 + offset, skinColor);
            drawer->DrawSegment(v1 - offset, v2 - offset, skinColor);

            const auto angle0 = GetAngle(worldNormal0);
            const auto angle1 = GetAngle(-worldNormal0);
            DrawCorner(drawer, v2, r, angle0, angle1, skinColor);
            DrawCorner(drawer, v1, r, angle1, angle0, skinColor);
        }
    }
}

static void Draw(DebugDraw* drawer, const ChainShapeConf& shape, Color color, bool skins, Transformation xf)
{
    const auto count = shape.GetVertexCount();
    const auto r = GetVertexRadius(shape);
    const auto skinColor = Color(color.r * 0.6f, color.g * 0.6f, color.b * 0.6f, 255);

    auto v1 = Transform(shape.GetVertex(0), xf);
    for (auto i = decltype(count){1}; i < count; ++i)
    {
        const auto v2 = Transform(shape.GetVertex(i), xf);
        drawer->DrawSegment(v1, v2, color);
        if (skins && r > 0_m)
        {
            const auto worldNormal0 = GetFwdPerpendicular(GetUnitVector(v2 - v1));
            const auto offset = worldNormal0 * r;
            drawer->DrawSegment(v1 + offset, v2 + offset, skinColor);
            drawer->DrawSegment(v1 - offset, v2 - offset, skinColor);
            const auto angle0 = GetAngle(worldNormal0);
            const auto angle1 = GetAngle(-worldNormal0);
            DrawCorner(drawer, v2, r, angle0, angle1, skinColor);
            DrawCorner(drawer, v1, r, angle1, angle0, skinColor);
        }
        v1 = v2;
    }
}

static void Draw(DebugDraw* drawer, const PolygonShapeConf& shape, Color color, bool skins, Transformation xf)
{
    Draw(drawer, GetChild(shape, 0), color, skins, xf);
}

static void Draw(DebugDraw* drawer, const MultiShapeConf& shape, Color color, bool skins, Transformation xf)
{
    const auto count = GetChildCount(shape);
    for (auto i = decltype(count){0}; i < count; ++i)
    {
        Draw(drawer, GetChild(shape, i), color, skins, xf);
    }
}

struct VisitorData
{
    DebugDraw* drawer;
    Transformation xf;
    Color color;
    bool skins;
};

template <class T>
inline void ForAll(World& world, const std::function<void(T& e)>& action);

template <>
inline void ForAll(World& world, const std::function<void(RevoluteJoint& e)>& action)
{
    auto visitor = FunctionalJointVisitor{}.Use(action);
    const auto range = world.GetJoints();
    std::for_each(begin(range), end(range), [&](Joint* j) {
        j->Accept(visitor);
    });
}

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
    Draw(data->drawer, shape, data->color, data->skins, data->xf);
    return true;
}

template <>
bool Visit(const d2::PolygonShapeConf& shape, void* userData)
{
    const auto data = static_cast<VisitorData*>(userData);
    Draw(data->drawer, shape, data->color, data->skins, data->xf);
    return true;
}

template <>
bool Visit(const d2::ChainShapeConf& shape, void* userData)
{
    const auto data = static_cast<VisitorData*>(userData);
    Draw(data->drawer, shape, data->color, data->skins, data->xf);
    return true;
}

template <>
bool Visit(const d2::MultiShapeConf& shape, void* userData)
{
    const auto data = static_cast<VisitorData*>(userData);
    Draw(data->drawer, shape, data->color, data->skins, data->xf);
    return true;
}

} // namespace playrho

static void Draw(DebugDraw* drawer, const Fixture& fixture, const Color& color, bool skins)
{
    const auto xf = GetTransformation(fixture);
    auto visitor = VisitorData{};
    visitor.drawer = drawer;
    visitor.xf = xf;
    visitor.color = color;
    visitor.skins = skins;
    Visit(fixture.GetShape(), &visitor);
}

static Color GetColor(const Body& body)
{
    if (!body.IsEnabled())
    {
        return Color{Dorothy::Vec4{0.5f, 0.5f, 0.3f, 1.0f}};
    }
    if (body.GetType() == BodyType::Static)
    {
        return Color{Dorothy::Vec4{0.5f, 0.9f, 0.5f, 1.0f}};
    }
    if (body.GetType() == BodyType::Kinematic)
    {
        return Color{Dorothy::Vec4{0.5f, 0.5f, 0.9f, 1.0f}};
    }
    if (!body.IsAwake())
    {
        return Color{Dorothy::Vec4{0.75f, 0.75f, 0.75f, 1.0f}};
    }
    return Color{Dorothy::Vec4{0.9f, 0.7f, 0.7f, 1.0f}};
}

static void Draw(DebugDraw* drawer, const Body& body, bool skins)
{
    const auto bodyColor = GetColor(body);
    for (auto&& fixture: body.GetFixtures())
    {
        const auto& f = GetRef(fixture);
        auto color = bodyColor;
        Draw(drawer, f, color, skins);
    }
}

static void Draw(DebugDraw* drawer, const Joint& joint)
{
    const auto p1 = joint.GetAnchorA();
    const auto p2 = joint.GetAnchorB();

    const Color color(Dorothy::Vec4{0.5f, 0.8f, 0.8f, 1.0f});

    switch (GetType(joint))
    {
        case JointType::Distance:
            drawer->DrawSegment(p1, p2, color);
            break;

        case JointType::Pulley:
        {
            const auto pulley = static_cast<const PulleyJoint&>(joint);
            const auto s1 = pulley.GetGroundAnchorA();
            const auto s2 = pulley.GetGroundAnchorB();
            drawer->DrawSegment(s1, p1, color);
            drawer->DrawSegment(s2, p2, color);
            drawer->DrawSegment(s1, s2, color);
        }
            break;

        case JointType::Target:
            // don't draw this
            break;

        default:
        {
            const auto bodyA = joint.GetBodyA();
            const auto bodyB = joint.GetBodyB();
            const auto x1 = bodyA->GetTransformation().p;
            const auto x2 = bodyB->GetTransformation().p;
            drawer->DrawSegment(x1, p1, color);
            drawer->DrawSegment(p1, p2, color);
            drawer->DrawSegment(x2, p2, color);
        }
    }
}
/*
static void Draw(DebugDraw* drawer, const AABB& aabb, const Color& color)
{
    Length2 vs[4];
    vs[0] = Length2{aabb.ranges[0].GetMin(), aabb.ranges[1].GetMin()};
    vs[1] = Length2{aabb.ranges[0].GetMax(), aabb.ranges[1].GetMin()};
    vs[2] = Length2{aabb.ranges[0].GetMax(), aabb.ranges[1].GetMax()};
    vs[3] = Length2{aabb.ranges[0].GetMin(), aabb.ranges[1].GetMax()};
    drawer->DrawPolygon(vs, 4, color);
}
*/

void DrawWorld(DebugDraw* drawer, const World& world)
{
	for (auto&& body: world.GetBodies())
	{
		const auto b = GetPtr(body);
		Draw(drawer, *b, true);
	}
	for (auto&& j: world.GetJoints())
	{
		Draw(drawer, *j);
	}
/*
    if (settings.drawAABBs)
    {
        const auto color = Color{0.9f, 0.3f, 0.9f};
        const auto root = world.GetTree().GetRootIndex();
        if (root != DynamicTree::GetInvalidSize())
        {
            const auto worldAabb = world.GetTree().GetAABB(root);
            Draw(drawer, worldAabb, color);
            Query(world.GetTree(), worldAabb, [&](DynamicTree::Size id) {
                Draw(drawer, world.GetTree().GetAABB(id), color);
                return DynamicTreeOpcode::Continue;
            });
        }
    }
    if (settings.drawCOMs)
    {
        const auto k_axisScale = 0.4_m;
        const auto red = Color{1.0f, 0.0f, 0.0f};
        const auto green = Color{0.0f, 1.0f, 0.0f};
        for (auto&& body: world.GetBodies())
        {
            const auto b = GetPtr(body);
            const auto massScale = std::pow(static_cast<float>(StripUnit(GetMass(*b))), 1.0f/3);
            auto xf = b->GetTransformation();
            xf.p = b->GetWorldCenter();
            const auto p1 = xf.p;
            drawer.DrawSegment(p1, p1 + massScale * k_axisScale * GetXAxis(xf.q), red);
            drawer.DrawSegment(p1, p1 + massScale * k_axisScale * GetYAxis(xf.q), green);
        }
    }
*/
}

NS_DOROTHY_BEGIN

void DebugDraw::DrawWorld(pd::World* world)
{
	_drawNode->clear();
	_line->clear();
	::DrawWorld(this, *world);
}

NS_DOROTHY_END
