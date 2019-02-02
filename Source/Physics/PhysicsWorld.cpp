/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/PhysicsWorld.h"
#include "Physics/Body.h"
#include "Physics/Sensor.h"
#include "Physics/Joint.h"
#include "Physics/DebugDraw.h"
#include "Node/DrawNode.h"

NS_DOROTHY_BEGIN

void ContactListener::SensorPair::retain()
{
	sensor->getOwner()->retain();
	sensor->retain();
	body->retain();
}

void ContactListener::SensorPair::release()
{
	sensor->getOwner()->release();
	sensor->release();
	body->release();
}

void ContactListener::ContactPair::retain()
{
	bodyA->retain();
	bodyB->retain();
}

void ContactListener::ContactPair::release()
{
	bodyA->release();
	bodyB->release();
}

float PhysicsWorld::b2Factor = 100.0f;

PhysicsWorld::PhysicsWorld():
_world{},
_contactListner(new ContactListener()),
_destructionListener(new DestructionListener())
{
	_stepConf.regVelocityIterations = 1;
	_stepConf.regPositionIterations = 1;
}

PhysicsWorld::~PhysicsWorld()
{
	RefVector<Body> bodies;
	for (pd::Body* b : _world.GetBodies())
	{
			Body* body = r_cast<Body*>(b->GetUserData());
			if (body) bodies.push_back(body);
	}
	for (Body* b : bodies)
	{
		b->cleanup();
	}
}

bool PhysicsWorld::init()
{
	if (!Node::init()) return false;
	_world.SetContactListener(_contactListner);
	_world.SetDestructionListener(_destructionListener);
	for (int i = 0; i < TotalGroups; i++)
	{
		_filters[i].groupIndex = i;
		_filters[i].categoryBits = 1<<i;
		_filters[i].maskBits = 0;
	}
	Node::scheduleUpdate();
	return true;
}

void PhysicsWorld::render()
{
	if (_debugDraw)
	{
		_debugDraw->DrawWorld(&_world);
	}
}

pd::World* PhysicsWorld::getPrWorld() const
{
	return c_cast<pd::World*>(&_world);
}

void PhysicsWorld::setShowDebug(bool var)
{
	if (var)
	{
		if (!_debugDraw)
		{
			_debugDraw = New<DebugDraw>();
			addChild(_debugDraw->getRenderer(), INT_MAX, "DebugDraw"_slice);
		}
	}
	else if (_debugDraw)
	{
		removeChild(_debugDraw->getRenderer());
		_debugDraw = nullptr;
	}
}

bool PhysicsWorld::isShowDebug() const
{
	return _debugDraw != nullptr;
}

void PhysicsWorld::setIterations(int velocityIter, int positionIter)
{
	_stepConf.regVelocityIterations = velocityIter;
	_stepConf.regPositionIterations = positionIter;
}

void PhysicsWorld::setGravity(const Vec2& gravity)
{
	//_world.SetGravity(gravity);
}

Vec2 PhysicsWorld::getGravity() const
{
	return Vec2::zero;//Vec2::from(_world.GetGravity());
}

bool PhysicsWorld::update(double deltaTime)
{
	if (isUpdating())
	{
		_stepConf.SetTime(deltaTime);
		_world.Step(_stepConf);
		for (pd::Body* b : _world.GetBodies())
		{
			if (b->IsEnabled())
			{
				Body* body = r_cast<Body*>(b->GetUserData());
				body->updatePhysics();
			}
		}
		_contactListner->SolveContacts();
	}
	bool result = Node::update(deltaTime);
	return !isUpdating() && result;
}

bool PhysicsWorld::query(const Rect& rect, const function<bool(Body*)>& callback)
{
	pd::AABB aabb{
		pd::AABB::Location{
			b2Val(rect.getLeft()),
			b2Val(rect.getBottom())
		},
		pd::AABB::Location{
			b2Val(rect.getRight()),
			b2Val(rect.getTop())
		}
	};
	pd::Transformation transform{
		pr::Length2{
			b2Val(rect.getCenterX()),
			b2Val(rect.getCenterY())
		}
	};
	pd::Shape testShape = pd::Shape{
		pd::PolygonShapeConf{
			b2Val(rect.size.width),
			b2Val(rect.size.height)
		}
	};
	pd::Query(_world.GetTree(), aabb, [&](pd::Fixture* fixture, const pr::ChildCounter)
	{
		BLOCK_START
		{
			BREAK_IF(fixture->IsSensor());
			const pd::Shape shape = fixture->GetShape();
			int shapeType = pd::GetUseTypeInfo(shape);
			bool isCommonShape = shapeType != pd::ShapeType<pd::ChainShapeConf>() && shapeType != pd::ShapeType<pd::EdgeShapeConf>();
			BREAK_IF(isCommonShape && !pd::TestOverlap(pd::GetChild(testShape, 0), transform, pd::GetChild(shape, 0), fixture->GetBody()->GetTransformation()));
			Body* body = r_cast<Body*>(fixture->GetBody()->GetUserData());
			vector<Body*>& results = isCommonShape ? _queryResultsOfCommonShapes : _queryResultsOfChainsAndEdges;
			if (results.empty() || results.back() != body)
			{
				results.push_back(body);
			}
		}
		BLOCK_END
		return true;
	});
	bool result = false;
	for (Body* item : _queryResultsOfCommonShapes)
	{
		if (callback(item))
		{
			result = true;
			break;
		}
	}
	for (Body* item : _queryResultsOfChainsAndEdges)
	{
		if (callback(item))
		{
			result = true;
			break;
		}
	}
	_queryResultsOfCommonShapes.clear();
	_queryResultsOfChainsAndEdges.clear();
	return result;
}

bool PhysicsWorld::raycast(const Vec2& start, const Vec2& end, bool closest, const function<bool(Body*,const Vec2&,const Vec2&)>& callback)
{
	pd::RayCastInput input{b2Val(start),b2Val(end),pr::Real{1}};
	bool result = false;
	pd::RayCast(_world.GetTree(), input, [&](pd::Fixture* fixture, pr::ChildCounter child, pr::Length2 point, pd::UnitVec normal)
	{
		_rayCastResult.body = r_cast<Body*>(fixture->GetBody()->GetUserData());
		_rayCastResult.point = oVal({point[0], point[1]});
		_rayCastResult.normal = oVal({normal[0], normal[1]});
		if (closest)
		{
			return pr::RayCastOpcode::Terminate;
		}
		else
		{
			_rayCastResults.push_back(_rayCastResult);
			return pr::RayCastOpcode::ResetRay;
		}
	});
	if (closest)
	{
		result = _rayCastResult.body ? callback(_rayCastResult.body, _rayCastResult.point, _rayCastResult.normal) : false;
		_rayCastResult.body = nullptr;
	}
	else
	{
		for (auto& item : _rayCastResults)
		{
			if (callback(item.body, item.point, item.normal))
			{
				result = true;
				break;
			}
		}
		_rayCastResults.clear();
	}
	return result;
}

void PhysicsWorld::setShouldContact(Uint8 groupA, Uint8 groupB, bool contact)
{
	AssertIf(groupA >= TotalGroups || groupB >= TotalGroups, "Body group should be less than {}.", TotalGroups);
	pr::Filter& filterA = _filters[groupA];
	pr::Filter& filterB = _filters[groupB];
	if (contact)
	{
		filterA.maskBits |= filterB.categoryBits;
		filterB.maskBits |= filterA.categoryBits;
	}
	else
	{
		filterA.maskBits &= (~filterB.categoryBits);
		filterB.maskBits &= (~filterA.categoryBits);
	}
	for (pd::Body* body : _world.GetBodies())
	{
		for (pd::Fixture* fixture : body->GetFixtures())
		{
			int groupIndex = fixture->GetFilterData().groupIndex;
			if (groupIndex == groupA)
			{
				fixture->SetFilterData(_filters[groupA]);
			}
			else if (groupIndex == groupB)
			{
				fixture->SetFilterData(_filters[groupB]);
			}
		}
	}
}

bool PhysicsWorld::getShouldContact(Uint8 groupA, Uint8 groupB) const
{
	AssertIf(groupA >= TotalGroups || groupB >= TotalGroups, "Body group should be less than {}.", TotalGroups);
	const pr::Filter& filterA = _filters[groupA];
	const pr::Filter& filterB = _filters[groupB];
	return (filterA.maskBits & filterB.categoryBits) && (filterA.categoryBits & filterB.maskBits);
}

const pr::Filter& PhysicsWorld::getFilter(Uint8 group) const
{
	AssertIf(group >= TotalGroups, "Body group should be less than {}.", TotalGroups);
	return _filters[group];
}

void PhysicsWorld::setContactListener(Own<ContactListener>&& listener)
{
	_contactListner = std::move(listener);
}

void ContactListener::PreSolve(pd::Contact& contact, const pd::Manifold& oldManifold)
{
	pd::Fixture* fixtureA = contact.GetFixtureA();
	pd::Fixture* fixtureB = contact.GetFixtureB();
	Body* bodyA = s_cast<Body*>(fixtureA->GetBody()->GetUserData());
	Body* bodyB = s_cast<Body*>(fixtureB->GetBody()->GetUserData());
	if (!bodyA || !bodyB) return;
	if (!bodyA->isReceivingContact() && !bodyB->isReceivingContact()) return;
	if (bodyA->isReceivingContact() && bodyA->filterContact && !bodyA->filterContact(bodyB))
	{
		contact.UnsetEnabled();
	}
	if (bodyB->isReceivingContact() && bodyB->filterContact && !bodyB->filterContact(bodyA))
	{
		contact.UnsetEnabled();
	}
	if (!contact.IsEnabled())
	{
		pd::WorldManifold worldManifold = pd::GetWorldManifold(contact);
		Vec2 point = PhysicsWorld::oVal(worldManifold.GetPoint(0));
		if (bodyA->isReceivingContact())
		{
			pd::UnitVec normal = worldManifold.GetNormal();
			ContactPair pair = { bodyA, bodyB, point, {normal[0],normal[1]} };
			pair.retain();
			_contactStarts.push_back(pair);
		}
		if (bodyB->isReceivingContact())
		{
			pd::UnitVec normal = worldManifold.GetNormal();
			ContactPair pair = { bodyB, bodyA, point, {normal[0],normal[1]} };
			pair.retain();
			_contactStarts.push_back(pair);
		}
	}
}

void ContactListener::PostSolve(pd::Contact& contact, const pd::ContactImpulsesList& impulses,
	 	iteration_type solved)
{ }

void ContactListener::BeginContact(pd::Contact& contact)
{
	pd::Fixture* fixtureA = contact.GetFixtureA();
	pd::Fixture* fixtureB = contact.GetFixtureB();
	Body* bodyA = r_cast<Body*>(fixtureA->GetBody()->GetUserData());
	Body* bodyB = r_cast<Body*>(fixtureB->GetBody()->GetUserData());
	if (!bodyA || !bodyB)
	{
		return;
	}
	if (fixtureA->IsSensor())
	{
		Sensor* sensor = r_cast<Sensor*>(fixtureA->GetUserData());
		if (sensor && sensor->isEnabled() && !fixtureB->IsSensor())
		{
			SensorPair pair = {sensor, bodyB};
			pair.retain();
			_sensorEnters.push_back(pair);
		}
	}
	else if (fixtureB->IsSensor())
	{
		Sensor* sensor = (Sensor*)fixtureB->GetUserData();
		if (sensor && sensor->isEnabled())
		{
			SensorPair pair = {sensor, bodyA};
			pair.retain();
			_sensorEnters.push_back(pair);
		}
	}
	else if (bodyA->isReceivingContact() || bodyB->isReceivingContact())
	{
		pd::WorldManifold worldManifold = pd::GetWorldManifold(contact);
		Vec2 point = PhysicsWorld::oVal(worldManifold.GetPoint(0));
		if (bodyA->isReceivingContact())
		{
			pd::UnitVec normal = worldManifold.GetNormal();
			ContactPair pair = { bodyA, bodyB, point, {normal[0],normal[1]} };
			pair.retain();
			_contactStarts.push_back(pair);
		}
		if (bodyB->isReceivingContact())
		{
			pd::UnitVec normal = worldManifold.GetNormal();
			ContactPair pair = { bodyB, bodyA, point, {normal[0],normal[1]} };
			pair.retain();
			_contactStarts.push_back(pair);
		}
	}
}

void ContactListener::EndContact(pd::Contact& contact)
{
	pd::Fixture* fixtureA = contact.GetFixtureA();
	pd::Fixture* fixtureB = contact.GetFixtureB();
	Body* bodyA = r_cast<Body*>(fixtureA->GetBody()->GetUserData());
	Body* bodyB = r_cast<Body*>(fixtureB->GetBody()->GetUserData());
	if (fixtureA->IsSensor())
	{
		Sensor* sensor = r_cast<Sensor*>(fixtureA->GetUserData());
		if (sensor && bodyB && sensor->isEnabled() && !fixtureB->IsSensor())
		{
			SensorPair pair = {sensor, bodyB};
			pair.retain();
			_sensorLeaves.push_back(pair);
		}
	}
	else if (fixtureB->IsSensor())
	{
		Sensor* sensor = r_cast<Sensor*>(fixtureB->GetUserData());
		if (sensor && bodyA && sensor->isEnabled())
		{
			SensorPair pair = {sensor, bodyA};
			pair.retain();
			_sensorLeaves.push_back(pair);
		}
	}
	else if (bodyA->isReceivingContact() || bodyB->isReceivingContact())
	{
		pd::WorldManifold worldManifold = pd::GetWorldManifold(contact);
		Vec2 point = PhysicsWorld::oVal(worldManifold.GetPoint(0));
		if (bodyA->isReceivingContact())
		{
			pd::UnitVec normal = worldManifold.GetNormal();
			ContactPair pair = { bodyA, bodyB, point, {normal[0],normal[1]} };
			pair.retain();
			_contactEnds.push_back(pair);
		}
		if (bodyB->isReceivingContact())
		{
			pd::UnitVec normal = worldManifold.GetNormal();
			ContactPair pair = { bodyB, bodyA, point, {normal[0],normal[1]} };
			pair.retain();
			_contactEnds.push_back(pair);
		}
	}
}

void ContactListener::SolveContacts()
{
	if (!_contactStarts.empty())
	{
		for (ContactPair& pair : _contactStarts)
		{
			pair.bodyA->contactStart(pair.bodyB, pair.point, pair.normal);
			pair.release();
		}
		_contactStarts.clear();
	}
	if (!_contactEnds.empty())
	{
		for (ContactPair& pair : _contactEnds)
		{
			pair.bodyA->contactEnd(pair.bodyB, pair.point, pair.normal);
			pair.release();
		}
		_contactEnds.clear();
	}
	if (!_sensorEnters.empty())
	{
		for (SensorPair& pair: _sensorEnters)
		{
			if (pair.sensor->isEnabled())
			{
				pair.sensor->add(pair.body);
			}
			pair.release();
		}
		_sensorEnters.clear();
	}
	if (!_sensorLeaves.empty())
	{
		for (SensorPair& pair: _sensorLeaves)
		{
			if (pair.sensor->isEnabled())
			{
				pair.sensor->remove(pair.body);
			}
			pair.release();
		}
		_sensorLeaves.clear();
	}
}

ContactListener::~ContactListener()
{
	for (SensorPair& pair: _sensorEnters)
	{
		pair.release();
	}
	for (SensorPair& pair: _sensorLeaves)
	{
		pair.release();
	}
}

void DestructionListener::SayGoodbye(const pd::Joint& joint) noexcept
{ }

void DestructionListener::SayGoodbye(const pd::Fixture& fixture) noexcept
{ }

NS_DOROTHY_END
