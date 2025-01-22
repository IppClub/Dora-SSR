/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Physics/DebugDraw.h"

#include "Node/DrawNode.h"
#include "Physics/Body.h"
#include "Physics/PhysicsWorld.h"

NS_DORA_BEGIN

DrawNode* DebugDraw::getRenderer() const noexcept {
	return _drawNode;
}

DebugDraw::DebugDraw()
	: _drawNode(DrawNode::create())
	, _line(Line::create()) {
	_drawNode->addChild(_line);
}

DebugDraw::~DebugDraw() { }

bool DebugDraw::IsVisible(Body* body) {
	if (!body) return true;
	Node* owner = s_cast<Node*>(body->getOwner());
	return body->isVisible() && (owner == nullptr || (owner->isVisible() && (owner->getParent() == nullptr || owner->getParent()->isVisible())));
}

void DebugDraw::DrawPolygon(const pr::Length2* oldVertices, int vertexCount, const Color& color) {
	std::vector<Vec2> vertices(vertexCount + 1);
	for (int i = 0; i < vertexCount; i++) {
		vertices[i] = PhysicsWorld::Val(oldVertices[i]);
	}
	vertices[vertexCount] = vertices[0];
	_line->add(vertices, color);
}

void DebugDraw::DrawSolidPolygon(const pr::Length2* oldVertices, int vertexCount, const Color& color) {
	std::vector<Vec2> vertices(vertexCount + 1);
	for (int i = 0; i < vertexCount; i++) {
		vertices[i] = PhysicsWorld::Val(oldVertices[i]);
	}
	vertices[vertexCount] = vertices[0];
	_drawNode->drawPolygon(vertices.data(), vertexCount, Color(s_cast<uint8_t>(color.r * 0.5f), s_cast<uint8_t>(color.g * 0.5f), s_cast<uint8_t>(color.b * 0.5f), s_cast<uint8_t>(color.a * 0.5f)));
	_line->add(vertices, color);
}

void DebugDraw::DrawCircle(const pr::Length2& center, float radius, const Color& color) {
	const float k_segments = 16.0f;
	const int vertexCount = 16;
	const float k_increment = 2.0f * bx::kPi / k_segments;
	float theta = 0.0f;

	Vec2 pos{center[0], center[1]};
	Vec2 vertices[vertexCount + 1];
	for (int i = 0; i < k_segments; ++i) {
		Vec2 v = pos + Vec2{std::cos(theta), std::sin(theta)} * radius;
		vertices[i] = PhysicsWorld::Val(Vec2{v.x, v.y});
		theta += k_increment;
	}
	vertices[vertexCount] = vertices[0];
	_line->add(vertices, vertexCount + 1, color);
}

void DebugDraw::DrawSolidCircle(const pr::Length2& center, float radius, const Color& color) {
	const float k_segments = 16.0f;
	const int vertexCount = 16;
	const float k_increment = 2.0f * bx::kPi / k_segments;
	float theta = 0.0f;

	Vec2 pos{center[0], center[1]};
	Vec2 vertices[vertexCount + 1];
	for (int i = 0; i < k_segments; ++i) {
		Vec2 v = pos + Vec2{std::cos(theta), std::sin(theta)} * radius;
		vertices[i] = PhysicsWorld::Val(Vec2{v.x, v.y});
		theta += k_increment;
	}
	_drawNode->drawPolygon(vertices, vertexCount, Color(s_cast<uint8_t>(color.r * 0.5f), s_cast<uint8_t>(color.g * 0.5f), s_cast<uint8_t>(color.b * 0.5f), s_cast<uint8_t>(color.a * 0.5f)));
	vertices[vertexCount] = vertices[0];
	_line->add(vertices, vertexCount + 1, color);
}

void DebugDraw::DrawSegment(const pr::Length2& p1, const pr::Length2& p2, const Color& color) {
	Vec2 vertices[] = {PhysicsWorld::Val(p1), PhysicsWorld::Val(p2)};
	_line->add(vertices, 2, color);
}

static void Draw(DebugDraw* drawer, const pd::DistanceProxy& shape, Color color, pd::Transformation xf) {
	const auto vertexCount = shape.GetVertexCount();
	auto vertices = std::vector<pr::Length2>(vertexCount);
	for (auto i = decltype(vertexCount){0}; i < vertexCount; ++i) {
		vertices[i] = Transform(shape.GetVertex(i), xf);
	}
	drawer->DrawSolidPolygon(&vertices[0], vertexCount, color);
}

static void Draw(DebugDraw* drawer, const pd::DiskShapeConf& shape, Color color, pd::Transformation xf) {
	const auto center = Transform(shape.GetLocation(), xf);
	const auto radius = shape.GetRadius();
	drawer->DrawSolidCircle(center, radius, color);
	const auto axis = pd::Rotate(pd::UnitVec::GetLeft(), xf.q);
	drawer->DrawSegment(center, center + radius * pr::Vec2{axis[0], axis[1]}, color);
}

static void Draw(DebugDraw* drawer, const pd::EdgeShapeConf& shape, Color color, pd::Transformation xf) {
	Color ghostColor(s_cast<uint8_t>(0.75f * color.r), s_cast<uint8_t>(0.75f * color.g), s_cast<uint8_t>(0.75f * color.b), color.a);
	const auto v1 = Transform(shape.GetVertexA(), xf);
	const auto v2 = Transform(shape.GetVertexB(), xf);
	drawer->DrawSegment(v1, v2, color);
	drawer->DrawCircle(v1, 0.05f, ghostColor);
	drawer->DrawCircle(v2, 0.05f, ghostColor);
}

static void Draw(DebugDraw* drawer, const pd::ChainShapeConf& shape, Color color, pd::Transformation xf) {
	const auto count = shape.GetVertexCount();
	Color ghostColor(s_cast<uint8_t>(0.75f * color.r), s_cast<uint8_t>(0.75f * color.g), s_cast<uint8_t>(0.75f * color.b), color.a);
	auto v1 = Transform(shape.GetVertex(0), xf);
	for (auto i = decltype(count){1}; i < count; ++i) {
		const auto v2 = Transform(shape.GetVertex(i), xf);
		drawer->DrawSegment(v1, v2, color);
		drawer->DrawCircle(v1, 0.05f, ghostColor);
		v1 = v2;
	}
}

static void Draw(DebugDraw* drawer, const pd::PolygonShapeConf& shape, Color color, pd::Transformation xf) {
	Draw(drawer, GetChild(shape, 0), color, xf);
}

static void Draw(DebugDraw* drawer, const pd::MultiShapeConf& shape, Color color, pd::Transformation xf) {
	const auto count = GetChildCount(shape);
	for (auto i = decltype(count){0}; i < count; ++i) {
		Draw(drawer, GetChild(shape, i), color, xf);
	}
}

static void Draw(DebugDraw* drawer, const pd::World& world, pr::ShapeID fixture, pr::BodyID body, const Color& color) {
	const auto xf = pd::GetTransformation(world, body);
	auto shape = pd::GetShape(world, fixture);
	if (pd::GetType(shape) == pr::GetTypeID<pd::DiskShapeConf>()) {
		Draw(drawer, pd::TypeCast<pd::DiskShapeConf>(shape), color, xf);
	} else if (pd::GetType(shape) == pr::GetTypeID<pd::EdgeShapeConf>()) {
		Draw(drawer, pd::TypeCast<pd::EdgeShapeConf>(shape), color, xf);
	} else if (pd::GetType(shape) == pr::GetTypeID<pd::PolygonShapeConf>()) {
		Draw(drawer, pd::TypeCast<pd::PolygonShapeConf>(shape), color, xf);
	} else if (pd::GetType(shape) == pr::GetTypeID<pd::ChainShapeConf>()) {
		Draw(drawer, pd::TypeCast<pd::ChainShapeConf>(shape), color, xf);
	} else if (pd::GetType(shape) == pr::GetTypeID<pd::MultiShapeConf>()) {
		Draw(drawer, pd::TypeCast<pd::MultiShapeConf>(shape), color, xf);
	}
}

const static Color disabledColor(Dora::Vec4{0.5f, 0.5f, 0.3f, 1.0f});
const static Color staticColor(Dora::Vec4{0.5f, 0.9f, 0.5f, 1.0f});
const static Color kinematicColor(Dora::Vec4{0.5f, 0.5f, 0.9f, 1.0f});
const static Color sleepColor(Dora::Vec4{0.6f, 0.6f, 0.6f, 1.0f});
const static Color activeColor(Dora::Vec4{0.9f, 0.7f, 0.7f, 1.0f});
const static Color sensorColor(Dora::Vec4{1.0f, 0.9f, 0.0f, 1.0f});

static const Color& GetColor(const pd::World& world, pr::BodyID body) {
	if (!pd::IsEnabled(world, body)) {
		return disabledColor;
	}
	switch (pd::GetType(world, body)) {
		case pr::BodyType::Static: return staticColor;
		case pr::BodyType::Kinematic: return kinematicColor;
		default:
			if (!pd::IsAwake(world, body)) {
				return sleepColor;
			}
			return activeColor;
	}
}

static void Draw(DebugDraw* drawer, const pd::World& world, pr::BodyID body) {
	const auto bodyColor = GetColor(world, body);
	for (auto f : pd::GetShapes(world, body)) {
		auto color = pd::IsSensor(world, f) ? sensorColor : bodyColor;
		Draw(drawer, world, f, body, color);
	}
}

static const Color jointColor(Dora::Vec4{0.5f, 0.8f, 0.8f, 1.0f});

static void Draw(DebugDraw* drawer, const pd::World& world, pr::JointID joint) {
	const auto p1 = pd::GetAnchorA(world, joint);
	const auto p2 = pd::GetAnchorB(world, joint);
	auto jointType = pd::GetType(world, joint);
	if (jointType == pr::GetTypeID<pd::DistanceJointConf>()) {
		drawer->DrawSegment(p1, p2, jointColor);
	} else if (jointType == pr::GetTypeID<pd::PulleyJointConf>()) {
		const auto s1 = pd::GetGroundAnchorA(world, joint);
		const auto s2 = pd::GetGroundAnchorB(world, joint);
		drawer->DrawSegment(s1, p1, jointColor);
		drawer->DrawSegment(s2, p2, jointColor);
		drawer->DrawSegment(s1, s2, jointColor);
	} else if (jointType == pr::GetTypeID<pd::TargetJointConf>()) {
		const auto x2 = pd::GetTarget(world, joint);
		drawer->DrawSegment(x2, p2, jointColor);
	} else {
		const auto bodyA = pd::GetBodyA(world, joint);
		const auto bodyB = pd::GetBodyB(world, joint);
		const auto x1 = pd::GetTransformation(world, bodyA).p;
		const auto x2 = pd::GetTransformation(world, bodyB).p;
		drawer->DrawSegment(x1, p1, jointColor);
		drawer->DrawSegment(p1, p2, jointColor);
		drawer->DrawSegment(x2, p2, jointColor);
	}
}

void DebugDraw::DrawWorld(PhysicsWorld* pworld) {
	_drawNode->clear();
	_line->clear();
	if (!pworld->getPrWorld()) {
		return;
	}
	auto& world = *pworld->getPrWorld();
	for (auto body : pd::GetBodies(world)) {
		if (DebugDraw::IsVisible(pworld->getBodyData(body))) {
			Draw(this, world, body);
		}
	}
	for (auto joint : pd::GetJoints(world)) {
		Draw(this, world, joint);
	}
}

NS_DORA_END
