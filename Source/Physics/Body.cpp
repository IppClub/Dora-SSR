/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/Body.h"
#include "Physics/BodyDef.h"
#include "Physics/PhysicsWorld.h"
#include "Physics/Sensor.h"

NS_DOROTHY_BEGIN

Body::Body(BodyDef* bodyDef, PhysicsWorld* world, const Vec2& pos, float rot):
_bodyB2(nullptr),
_bodyDef(bodyDef),
_world(world),
_group(0),
_receivingContact(false)
{
	bodyDef->position = PhysicsWorld::b2Val(pos + bodyDef->offset);
	bodyDef->angle = -bx::toRad(rot + bodyDef->angleOffset);
}

Body::~Body()
{
	if (_bodyB2)
	{
		_world->getB2World()->DestroyBody(_bodyB2);
		_bodyB2 = nullptr;
	}
	ARRAY_START(Sensor, sensor, _sensors)
	{
		sensor->bodyEnter.Clear();
		sensor->bodyLeave.Clear();
	}
	ARRAY_END
	contactStart.Clear();
	contactEnd.Clear();
}

bool Body::init()
{
	if (!Node::init()) return false;
	_bodyB2 = _world->getB2World()->CreateBody(_bodyDef);
	_bodyB2->SetUserData(r_cast<void*>(this));
	Node::setPosition(PhysicsWorld::oVal(_bodyDef->position));
	for (b2FixtureDef* fixtureDef : _bodyDef->getFixtureDefs())
	{
		if (fixtureDef->isSensor)
		{
			Body::attachSensor(s_cast<int>(r_cast<intptr_t>(fixtureDef->userData)), fixtureDef);
		}
		else
		{
			Body::attachFixture(fixtureDef);
		}
	}
	return true;
}

void Body::onEnter()
{
	Node::onEnter();
	_bodyB2->SetActive(true);
}

void Body::onExit()
{
	Node::onExit();
	_bodyB2->SetActive(false); // Set active false to trigger sensor`s body leave event.
}

void Body::cleanup()
{
	Node::cleanup();
	if (_bodyB2)
	{
		_world->getB2World()->DestroyBody(_bodyB2);
		_bodyB2 = nullptr;
	}
	if (_sensors)
	{
		ARRAY_START(Sensor, sensor, _sensors)
		{
			sensor->bodyEnter.Clear();
			sensor->bodyLeave.Clear();
			sensor->setEnabled(false);
			sensor->getSensedBodies()->clear();
		}
		ARRAY_END
		_sensors->clear();
	}
	contactStart.Clear();
	contactEnd.Clear();
}

BodyDef* Body::getBodyDef() const
{
	return _bodyDef;
}

PhysicsWorld* Body::getWorld() const
{
	return _world;
}

b2Body* Body::getB2Body() const
{
	return _bodyB2;
}

Sensor* Body::getSensorByTag(int tag)
{
	ARRAY_START(Sensor, sensor, _sensors)
	{
		if (sensor->getTag() == tag)
		{
			return sensor;
		}
	}
	ARRAY_END
	return nullptr;
}

bool Body::removeSensorByTag(int tag)
{
	Sensor* sensor = Body::getSensorByTag(tag);
	return Body::removeSensor(sensor);
}

bool Body::removeSensor(Sensor* sensor)
{
	if (_sensors && sensor && sensor->getFixture()->GetBody() == _bodyB2)
	{
		_bodyB2->DestroyFixture(sensor->getFixture());
		_sensors->remove(sensor);
		return true;
	}
	return false;
}

void Body::setVelocity(float x, float y)
{
	_bodyB2->SetLinearVelocity(b2Vec2(PhysicsWorld::b2Val(x), PhysicsWorld::b2Val(y)));
}

void Body::setVelocity(const Vec2& velocity)
{
	_bodyB2->SetLinearVelocity(PhysicsWorld::b2Val(velocity));
}

Vec2 Body::getVelocity() const
{
	return PhysicsWorld::oVal(_bodyB2->GetLinearVelocity());
}

void Body::setAngularRate(float var)
{
	_bodyB2->SetAngularVelocity(-bx::toRad(var));
}

float Body::getAngularRate() const
{
	return -bx::toDeg(_bodyB2->GetAngularVelocity());
}

void Body::setLinearDamping(float var)
{
	_bodyB2->SetLinearDamping(var);
}

float Body::getLinearDamping() const
{
	return _bodyB2->GetLinearDamping();
}

void Body::setAngularDamping(float var)
{
	_bodyB2->SetAngularDamping(var);
}

float Body::getAngularDamping() const
{
	return _bodyB2->GetAngularDamping();
}

void Body::setOwner(Object* owner)
{
	_owner = owner;
}

Object* Body::getOwner() const
{
	return _owner;
}

float Body::getMass() const
{
	return _bodyB2->GetMass();
}

void Body::setGroup(int group)
{
	_group = group;
	for (b2Fixture* f = _bodyB2->GetFixtureList();f;f = f->GetNext())
	{
		f->SetFilterData(_world->getFilter(group));
	}
}

int Body::getGroup() const
{
	return _group;
}

void Body::applyLinearImpulse(const Vec2& impulse, const Vec2& pos)
{
	_bodyB2->ApplyLinearImpulse(PhysicsWorld::b2Val(impulse), PhysicsWorld::b2Val(pos), true);
}

void Body::applyAngularImpulse(float impulse)
{
	_bodyB2->ApplyAngularImpulse(PhysicsWorld::b2Val(impulse), true);
}

b2Fixture* Body::attachFixture(b2FixtureDef* fixtureDef)
{
	fixtureDef->filter = _world->getFilter(_group);
	fixtureDef->isSensor = false;
	b2Fixture* fixture = _bodyB2->CreateFixture(fixtureDef);
	return fixture;
}

b2Fixture* Body::attach( b2FixtureDef* fixtureDef )
{
	b2Fixture* fixture = Body::attachFixture(fixtureDef);
	/* cleanup temp vertices */
	if (fixtureDef->shape->m_type == b2Shape::e_chain)
	{
		b2ChainShape* chain = (b2ChainShape*)fixtureDef->shape;
		chain->ClearVertices();
	}
	return fixture;
}

Sensor* Body::attachSensor( int tag, b2FixtureDef* fixtureDef )
{
	fixtureDef->filter = _world->getFilter(_group);
	fixtureDef->isSensor = true;
	b2Fixture* fixture = _bodyB2->CreateFixture(fixtureDef);
	Sensor* sensor = Sensor::create(this, tag, fixture);
	fixture->SetUserData(r_cast<void*>(sensor));
	if (!_sensors) _sensors = Array::create();
	_sensors->add(sensor);
	sensorAdded(sensor, this);
	return sensor;
}

bool Body::isSensor() const
{
	return _sensors && _sensors->getCount() > 0;
}

void Body::eachSensor(const SensorHandler& func)
{
	ARRAY_START(Sensor, sensor, _sensors)
	{
		func(sensor, this);
	}
	ARRAY_END
}

void Body::setVelocityX( float x )
{
	_bodyB2->SetLinearVelocityX(PhysicsWorld::b2Val(x));
}

float Body::getVelocityX() const
{
	return PhysicsWorld::oVal(_bodyB2->GetLinearVelocityX());
}

void Body::setVelocityY( float y )
{
	_bodyB2->SetLinearVelocityY(PhysicsWorld::b2Val(y));
}

float Body::getVelocityY() const
{
	return PhysicsWorld::oVal(_bodyB2->GetLinearVelocityY());
}

void Body::setPosition(const Vec2& var)
{
	if (var != Node::getPosition())
	{
		Node::setPosition(var);
		_bodyB2->SetTransform(PhysicsWorld::b2Val(var), _bodyB2->GetAngle());
	}
}

void Body::setAngle(float var)
{
	if (var != Node::getAngle())
	{
		Node::setAngle(var);
		_bodyB2->SetTransform(_bodyB2->GetPosition(), -bx::toRad(var));
	}
}

Rect Body::getBoundingBox()
{
	b2AABB aabb = {
		b2Vec2_zero,
		b2Vec2_zero
	};
	b2Fixture* f = _bodyB2->GetFixtureList();
	if (f && f->GetChildCount() > 0)
	{
		aabb = f->GetAABB(0);
	}
	for (b2Fixture* f = _bodyB2->GetFixtureList(); f; f = f->GetNext())
	{
		for (int32 i = 0; i < f->GetChildCount(); ++i)
		{
			const b2AABB& ab = f->GetAABB(i);
			aabb.lowerBound.x = std::min(aabb.lowerBound.x, ab.lowerBound.x);
			aabb.lowerBound.y = std::min(aabb.lowerBound.y, ab.lowerBound.y);
			aabb.upperBound.x = std::max(aabb.upperBound.x, ab.upperBound.x);
			aabb.upperBound.y = std::max(aabb.upperBound.y, ab.upperBound.y);
		}
	}
	Vec2 lower = PhysicsWorld::oVal(aabb.lowerBound);
	Vec2 upper = PhysicsWorld::oVal(aabb.upperBound);
	return Rect(lower.x, lower.y, upper.x - lower.x, upper.y - lower.y);
}

void Body::setReceivingContact(bool var)
{
	_receivingContact = var;
}

bool Body::isReceivingContact() const
{
	return _receivingContact;
}

void Body::updatePhysics()
{
	if (_bodyB2->IsAwake())
	{
		const b2Vec2& pos = _bodyB2->GetPosition();
		/* Here only Node::setPosition(const Vec2& var) work for modify Node`s position.
		 Other positioning functions have been overriden by Body`s.
		*/
		Node::setPosition(Vec2{PhysicsWorld::oVal(pos.x), PhysicsWorld::oVal(pos.y)});
		float angle = _bodyB2->GetAngle();
		Node::setAngle(-bx::toDeg(angle));
	}
}

NS_DOROTHY_END
