/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/BodyDef.h"
#include "Physics/World.h"
#include "Physics/Body.h"

NS_DOROTHY_BEGIN

b2ChainShape BodyDef::_chainShape;
b2CircleShape BodyDef::_circleShape;
b2PolygonShape BodyDef::_polygenShape;
b2FixtureDef BodyDef::_fixtureDef;

BodyDef::BodyDef():
b2BodyDef(),
angleOffset(0),
offset(Vec2::zero),
facePos(Vec2::zero)
{
	active = false;
}

BodyDef::~BodyDef()
{
	BodyDef::clearFixtures();
}

void BodyDef::attachPolygon(const Vec2& center, float width, float height, float angle, float density, float friction, float restitution)
{
	b2PolygonShape* shape = new b2PolygonShape();
	shape->SetAsBox(World::b2Val(width * 0.5f),
		World::b2Val(height * 0.5f),
		World::b2Val(center),
		-bx::toRad(angle));
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->density = density;
	fixtureDef->friction = friction;
	fixtureDef->restitution = restitution;
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachPolygon(float width, float height, float density, float friction, float restitution)
{
	b2PolygonShape* shape = new b2PolygonShape();
	shape->SetAsBox(World::b2Val(width * 0.5f), World::b2Val(height * 0.5f));
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->density = density;
	fixtureDef->friction = friction;
	fixtureDef->restitution = restitution;
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachPolygon(const vector<Vec2>& vertices, float density, float friction, float restitution)
{
	b2PolygonShape* shape = new b2PolygonShape();
	int length = s_cast<int>(vertices.size());
	b2Vec2 vs[b2_maxPolygonVertices];
	for (int i = 0; i < length; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	shape->Set(vs, length);
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->density = density;
	fixtureDef->friction = friction;
	fixtureDef->restitution = restitution;
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachPolygon(const Vec2 vertices[], int count, float density, float friction, float restitution)
{
	count = std::min(count, b2_maxPolygonVertices);
	b2PolygonShape* shape = new b2PolygonShape();
	b2Vec2 vs[b2_maxPolygonVertices];
	for (int i = 0; i < count; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	shape->Set(vs, count);
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->density = density;
	fixtureDef->friction = friction;
	fixtureDef->restitution = restitution;
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachLoop(const vector<Vec2>& vertices, float friction, float restitution)
{
	b2ChainShape* shape = new b2ChainShape();
	int length = s_cast<int>(vertices.size());
	auto vs = NewArray<b2Vec2>(length);
	for (int i = 0; i < length; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	shape->CreateLoop(vs, length);
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->friction = friction;
	fixtureDef->restitution = restitution;
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachLoop(const Vec2 vertices[], int count, float friction, float restitution)
{
	b2ChainShape* shape = new b2ChainShape();
	auto vs = NewArray<b2Vec2>(count);
	for (int i = 0; i < count; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	shape->CreateLoop(vs, count);
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->friction = friction;
	fixtureDef->restitution = restitution;
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachCircle(const Vec2& center, float radius, float density, float friction, float restitution)
{
	b2CircleShape* shape = new b2CircleShape();
	shape->m_p = World::b2Val(center);
	shape->m_radius = World::b2Val(radius);
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->density = density;
	fixtureDef->friction = friction;
	fixtureDef->restitution = restitution;
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachCircle(float radius, float density, float friction, float restitution)
{
	BodyDef::attachCircle(Vec2::zero, radius, density, friction, restitution);
}

void BodyDef::attachChain(const vector<Vec2>& vertices, float friction, float restitution)
{
	b2ChainShape* shape = new b2ChainShape();
	int length = s_cast<int>(vertices.size());
	auto vs = NewArray<b2Vec2>(length);
	for (int i = 0; i < length; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	shape->CreateChain(vs, length);
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->friction = friction;
	fixtureDef->restitution = restitution;
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachChain(const Vec2 vertices[], int count, float friction, float restitution)
{
	b2ChainShape* shape = new b2ChainShape();
	auto vs = NewArray<b2Vec2>(count);
	for (int i = 0; i < count; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	shape->CreateChain(vs, count);
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->friction = friction;
	fixtureDef->restitution = restitution;
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachPolygonSensor(int tag, float width, float height)
{
	BodyDef::attachPolygonSensor(tag, width, height, Vec2::zero, 0);
}

void BodyDef::attachPolygonSensor(int tag, float width, float height, const Vec2& center, float angle)
{
	b2PolygonShape* shape = new b2PolygonShape();
	shape->SetAsBox(World::b2Val(width * 0.5f),
		World::b2Val(height * 0.5f),
		World::b2Val(center),
		-bx::toRad(angle));
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->isSensor = true;
	fixtureDef->userData = r_cast<void*>(s_cast<intptr_t>(tag));
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachPolygonSensor(int tag, const vector<Vec2>& vertices)
{
	b2PolygonShape* shape = new b2PolygonShape();
	int length = s_cast<int>(vertices.size());
	b2Vec2 vs[b2_maxPolygonVertices];
	for (int i = 0; i < length; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	shape->Set(vs, length);
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->isSensor = true;
	fixtureDef->userData = r_cast<void*>(s_cast<intptr_t>(tag));
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachPolygonSensor(int tag, const Vec2 vertices[], int count)
{
	b2PolygonShape* shape = new b2PolygonShape();
	b2Vec2 vs[b2_maxPolygonVertices];
	for (int i = 0; i < count; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	shape->Set(vs, count);
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->isSensor = true;
	fixtureDef->userData = r_cast<void*>(s_cast<intptr_t>(tag));
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachCircleSensor(int tag, const Vec2& center, float radius)
{
	b2CircleShape* shape = new b2CircleShape();
	shape->m_p = World::b2Val(center);
	shape->m_radius = World::b2Val(radius);
	b2FixtureDef* fixtureDef = new b2FixtureDef();
	fixtureDef->shape = shape;
	fixtureDef->isSensor = true;
	fixtureDef->userData = r_cast<void*>(s_cast<intptr_t>(tag));
	_fixtureDefs.push_back(MakeOwn(fixtureDef));
}

void BodyDef::attachCircleSensor(int tag, float radius)
{
	BodyDef::attachCircleSensor(tag, Vec2::zero, radius);
}

b2FixtureDef* BodyDef::polygon(const Vec2& center, float width, float height, float angle, float density, float friction, float restitution)
{
	_polygenShape.SetAsBox(World::b2Val(width * 0.5f), World::b2Val(height * 0.5f), World::b2Val(center), -bx::toRad(angle));
	_fixtureDef.shape = &_polygenShape;
	_fixtureDef.density = density;
	_fixtureDef.friction = friction;
	_fixtureDef.restitution = restitution;
	return &_fixtureDef;
}

b2FixtureDef* BodyDef::polygon(float width, float height, float density, float friction, float restitution)
{
	_polygenShape.SetAsBox(World::b2Val(width * 0.5f), World::b2Val(height * 0.5f));
	_fixtureDef.shape = &_polygenShape;
	_fixtureDef.density = density;
	_fixtureDef.friction = friction;
	_fixtureDef.restitution = restitution;
	return &_fixtureDef;
}

b2FixtureDef* BodyDef::polygon(const vector<Vec2>& vertices, float density, float friction, float restitution)
{
	int length = s_cast<int>(vertices.size());
	b2Vec2 vs[b2_maxPolygonVertices];
	for (int i = 0; i < length; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	_polygenShape.Set(vs, length);
	_fixtureDef.shape = &_polygenShape;
	_fixtureDef.density = density;
	_fixtureDef.friction = friction;
	_fixtureDef.restitution = restitution;
	return &_fixtureDef;
}

b2FixtureDef* BodyDef::polygon(const Vec2 vertices[], int count, float density, float friction, float restitution)
{
	b2Vec2 vs[b2_maxPolygonVertices];
	for (int i = 0; i < count; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	_polygenShape.Set(vs, count);
	_fixtureDef.shape = &_polygenShape;
	_fixtureDef.density = density;
	_fixtureDef.friction = friction;
	_fixtureDef.restitution = restitution;
	return &_fixtureDef;
}

b2FixtureDef* BodyDef::loop(const vector<Vec2>& vertices, float friction, float restitution)
{
	_chainShape.ClearVertices();
	int length = s_cast<int>(vertices.size());
	auto vs = NewArray<b2Vec2>(length);
	for (int i = 0; i < length; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	_chainShape.CreateLoop(vs, length);
	_fixtureDef.shape = &_chainShape;
	_fixtureDef.friction = friction;
	_fixtureDef.restitution = restitution;
	return &_fixtureDef;
}

b2FixtureDef* BodyDef::loop(const Vec2 vertices[], int count, float friction, float restitution)
{
	_chainShape.ClearVertices();
	auto vs = NewArray<b2Vec2>(count);
	for (int i = 0; i < count; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	_chainShape.CreateLoop(vs, count);
	_fixtureDef.shape = &_chainShape;
	_fixtureDef.friction = friction;
	_fixtureDef.restitution = restitution;
	return &_fixtureDef;
}

b2FixtureDef* BodyDef::circle(const Vec2& center, float radius, float density, float friction, float restitution)
{
	_circleShape.m_p = World::b2Val(center);
	_circleShape.m_radius = World::b2Val(radius);
	_fixtureDef.shape = &_circleShape;
	_fixtureDef.density = density;
	_fixtureDef.friction = friction;
	_fixtureDef.restitution = restitution;
	return &_fixtureDef;
}

b2FixtureDef* BodyDef::circle(float radius, float density, float friction, float restitution)
{
	return BodyDef::circle(Vec2::zero, radius, density, friction, restitution);
}

b2FixtureDef* BodyDef::chain(const vector<Vec2>& vertices, float friction, float restitution)
{
	_chainShape.ClearVertices();
	int length = s_cast<int>(vertices.size());
	auto vs = NewArray<b2Vec2>(length);
	for (int i = 0; i < length; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	_chainShape.CreateChain(vs, length);
	_fixtureDef.shape = &_chainShape;
	_fixtureDef.friction = friction;
	_fixtureDef.restitution = restitution;
	return &_fixtureDef;
}

b2FixtureDef* BodyDef::chain(const Vec2 vertices[], int count, float friction, float restitution)
{
	_chainShape.ClearVertices();
	auto vs = NewArray<b2Vec2>(count);
	for (int i = 0; i < count; i++)
	{
		vs[i] = World::b2Val(vertices[i]);
	}
	_chainShape.CreateChain(vs, count);
	_fixtureDef.shape = &_chainShape;
	_fixtureDef.friction = friction;
	_fixtureDef.restitution = restitution;
	return &_fixtureDef;
}

const OwnVector<b2FixtureDef>& BodyDef::getFixtureDefs() const
{
	return _fixtureDefs;
}

void BodyDef::clearFixtures()
{
	for (b2FixtureDef* fixtureDef : _fixtureDefs)
	{
		delete fixtureDef->shape;
		fixtureDef->shape = nullptr;
	}
	_fixtureDefs.clear();
}

void BodyDef::setDensity(float var)
{
	for (b2FixtureDef* fixtureDef : _fixtureDefs)
	{
		if (!fixtureDef->isSensor)
		{
			fixtureDef->density = var;
		}
	}
}
void BodyDef::setFriction(float var)
{
	for (b2FixtureDef* fixtureDef : _fixtureDefs)
	{
		if (!fixtureDef->isSensor)
		{
			fixtureDef->friction = var;
		}
	}
}
void BodyDef::setRestitution(float var)
{
	for (b2FixtureDef* fixtureDef : _fixtureDefs)
	{
		if (!fixtureDef->isSensor)
		{
			fixtureDef->restitution = var;
		}
	}
}

NS_DOROTHY_END
