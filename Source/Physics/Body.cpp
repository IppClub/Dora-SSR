/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

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
_prBody(nullptr),
_bodyDef(bodyDef),
_world(world),
_group(0)
{
	AssertIf(world == nullptr, "init Body with invalid PhysicsWorld.");
	bodyDef->getConf()->UseLocation(PhysicsWorld::b2Val(pos + bodyDef->offset));
	bodyDef->getConf()->UseAngle(-bx::toRad(rot + bodyDef->angleOffset));
}

Body::~Body()
{
	if (_prBody)
	{
		_world->getPrWorld()->Destroy(_prBody);
		_prBody = nullptr;
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
	_prBody = _world->getPrWorld()->CreateBody(*_bodyDef->getConf());
	_prBody->SetUserData(r_cast<void*>(this));
	Node::setPosition(PhysicsWorld::oVal(_bodyDef->getConf()->location));
	for (FixtureDef& fixtureDef : _bodyDef->getFixtureConfs())
	{
		if (fixtureDef.conf.isSensor)
		{
			Body::attachSensor(s_cast<int>(r_cast<intptr_t>(fixtureDef.conf.userData)), &fixtureDef);
		}
		else
		{
			Body::attachFixture(&fixtureDef);
		}
	}
	return true;
}

void Body::onEnter()
{
	Node::onEnter();
	_prBody->SetEnabled(true);
}

void Body::onExit()
{
	Node::onExit();
	_prBody->SetEnabled(false); // Set enable false to trigger sensor`s body leave event.
}

void Body::cleanup()
{
	Node::cleanup();
	if (_prBody)
	{
		_world->getPrWorld()->Destroy(_prBody);
		_prBody = nullptr;
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

pd::Body* Body::getPrBody() const
{
	return _prBody;
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
	if (_sensors && sensor && sensor->getFixture()->GetBody() == _prBody)
	{
		_prBody->Destroy(sensor->getFixture());
		_sensors->remove(sensor);
		return true;
	}
	return false;
}

void Body::setVelocity(float x, float y)
{
	pd::SetLinearVelocity(*_prBody, pr::LinearVelocity2{PhysicsWorld::b2Val(x), PhysicsWorld::b2Val(y)});
}

void Body::setVelocity(const Vec2& velocity)
{
	Body::setVelocity(velocity.x, velocity.y);
}

Vec2 Body::getVelocity() const
{
	return PhysicsWorld::oVal(_prBody->GetVelocity().linear);
}

void Body::setAngularRate(float var)
{
	pd::SetAngularVelocity(*_prBody, -bx::toRad(var));
}

float Body::getAngularRate() const
{
	return -bx::toDeg(_prBody->GetVelocity().angular);
}

void Body::setLinearDamping(float var)
{
	_prBody->SetLinearDamping(var);
}

float Body::getLinearDamping() const
{
	return _prBody->GetLinearDamping();
}

void Body::setAngularDamping(float var)
{
	_prBody->SetAngularDamping(var);
}

float Body::getAngularDamping() const
{
	return _prBody->GetAngularDamping();
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
	return 1.0f / _prBody->GetInvMass();
}

void Body::setGroup(Uint8 group)
{
	AssertIf(group >= PhysicsWorld::TotalGroups, "Body group should be less than {}.", PhysicsWorld::TotalGroups);
	_group = group;
	for (pd::Fixture* f : _prBody->GetFixtures())
	{
		f->SetFilterData(_world->getFilter(group));
	}
}

Uint8 Body::getGroup() const
{
	return _group;
}

void Body::applyLinearImpulse(const Vec2& impulse, const Vec2& pos)
{
	pd::ApplyLinearImpulse(*_prBody, PhysicsWorld::b2Val(impulse), PhysicsWorld::b2Val(pos));
}

void Body::applyAngularImpulse(float impulse)
{
	pd::ApplyAngularImpulse(*_prBody, PhysicsWorld::b2Val(impulse));
}

pd::Fixture* Body::attachFixture(FixtureDef* fixtureDef)
{
	pd::Fixture* fixture = _prBody->CreateFixture(
		fixtureDef->shape,
		fixtureDef->conf.UseFilter(_world->getFilter(_group))
			.UseIsSensor(false)
			.UseUserData(nullptr)
	);
	return fixture;
}

pd::Fixture* Body::attach(FixtureDef* fixtureDef)
{
	pd::Fixture* fixture = Body::attachFixture(fixtureDef);
	/* cleanup temp vertices */
	if (pd::GetUseType(fixtureDef->shape) == pd::ShapeType<pd::ChainShapeConf>())
	{
		fixtureDef->shape = pd::Shape{};
	}
	return fixture;
}

Sensor* Body::attachSensor(int tag, FixtureDef* fixtureDef)
{
	pd::Shape shape = fixtureDef->shape;
	pd::FixtureConf conf = fixtureDef->conf
		.UseFilter(_world->getFilter(_group))
		.UseIsSensor(true);
	pd::Fixture* fixture = _prBody->CreateFixture(shape, conf);
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

void Body::setVelocityX(float x)
{
	auto v = _prBody->GetVelocity().linear;
	pd::SetLinearVelocity(*_prBody, pr::LinearVelocity2{PhysicsWorld::b2Val(x), v[1]});
}

float Body::getVelocityX() const
{
	return PhysicsWorld::oVal(_prBody->GetVelocity().linear[0]);
}

void Body::setVelocityY(float y)
{
	auto v = _prBody->GetVelocity().linear;
	pd::SetLinearVelocity(*_prBody, pr::LinearVelocity2{v[0], PhysicsWorld::b2Val(y)});
}

float Body::getVelocityY() const
{
	return PhysicsWorld::oVal(_prBody->GetVelocity().linear[1]);
}

void Body::setPosition(const Vec2& var)
{
	if (var != Node::getPosition())
	{
		Node::setPosition(var);
		_prBody->SetTransform(PhysicsWorld::b2Val(var), _prBody->GetAngle());
	}
}

void Body::setAngle(float var)
{
	if (var != Node::getAngle())
	{
		Node::setAngle(var);
		_prBody->SetTransform(_prBody->GetLocation(), -bx::toRad(var));
	}
}

Rect Body::getBoundingBox()
{
	pd::AABB aabb = pd::ComputeAABB(*_prBody);
	Vec2 lower = PhysicsWorld::oVal(pr::detail::GetLowerBound(aabb));
	Vec2 upper = PhysicsWorld::oVal(pr::detail::GetUpperBound(aabb));
	return Rect(lower.x, lower.y, upper.x - lower.x, upper.y - lower.y);
}

void Body::setReceivingContact(bool var)
{
	_flags.set(Body::ReceivingContact, var);
}

bool Body::isReceivingContact() const
{
	return _flags.isOn(Body::ReceivingContact);
}

bool Body::isEmittingEvent() const
{
	return _flags.isOn(Body::EmittingEvent);
}

void Body::onSensorAdded(Sensor* sensor, Body* body)
{
	sensor->bodyEnter += std::make_pair(this, &Body::onBodyEnter);
	sensor->bodyLeave += std::make_pair(this, &Body::onBodyLeave);
}

void Body::onBodyEnter(Sensor* sensor, Body* other)
{
	emit("BodyEnter"_slice, other, sensor);
}

void Body::onBodyLeave(Sensor* sensor, Body* other)
{
	emit("BodyLeave"_slice, other, sensor);
}

void Body::onContactStart(Body* other, const Vec2& point, const Vec2& normal)
{
	emit("ContactStart"_slice, other, point, normal);
}

void Body::onContactEnd(Body* other, const Vec2& point, const Vec2& normal)
{
	emit("ContactEnd"_slice, other, point, normal);
}

void Body::setEmittingEvent(bool var)
{
	if (isEmittingEvent() == var) return;
	_flags.set(Body::EmittingEvent, var);
	if (var)
	{
		ARRAY_START(Sensor, sensor, _sensors)
		{
			sensor->bodyEnter += std::make_pair(this, &Body::onBodyEnter);
			sensor->bodyLeave += std::make_pair(this, &Body::onBodyLeave);
		}
		ARRAY_END
		sensorAdded += std::make_pair(this, &Body::onSensorAdded);
		contactStart += std::make_pair(this, &Body::onContactStart);
		contactEnd += std::make_pair(this, &Body::onContactEnd);
	}
	else
	{
		ARRAY_START(Sensor, sensor, _sensors)
		{
			sensor->bodyEnter -= std::make_pair(this, &Body::onBodyEnter);
			sensor->bodyLeave -= std::make_pair(this, &Body::onBodyLeave);
		}
		ARRAY_END
		sensorAdded -= std::make_pair(this, &Body::onSensorAdded);
		contactStart -= std::make_pair(this, &Body::onContactStart);
		contactEnd -= std::make_pair(this, &Body::onContactEnd);
	}
}

void Body::updatePhysics()
{
	if (_prBody->IsAwake())
	{
		Vec2 pos = PhysicsWorld::oVal(_prBody->GetLocation());
		/* Here only Node::setPosition(const Vec2& var) work for modify Node`s position.
		 Other positioning functions have been overriden by Body`s.
		*/
		Node::setPosition(pos);
		float angle = _prBody->GetAngle();
		Node::setAngle(-bx::toDeg(angle));
	}
}

NS_DOROTHY_END
