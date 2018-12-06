/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

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

void PhysicsWorld::QueryAABB::setInfo(const Rect& rc)
{
	transform.Set(b2Vec2(b2Val(rc.getCenterX()), b2Val(rc.getCenterY())), 0);
	testShape.SetAsBox(b2Val(rc.size.width), b2Val(rc.size.height));
}
bool PhysicsWorld::QueryAABB::ReportFixture(b2Fixture* fixture)
{
	BLOCK_START
	{
		BREAK_IF(fixture->IsSensor());
		b2Shape* shape = fixture->GetShape();
		bool isCommonShape = shape->GetType() != b2Shape::e_chain && shape->GetType() != b2Shape::e_edge;
		BREAK_IF(isCommonShape && !b2TestOverlap(&testShape, 0, shape, 0, transform, fixture->GetBody()->GetTransform()));
		Body* body = r_cast<Body*>(fixture->GetBody()->GetUserData());
		vector<Body*>& results = isCommonShape ? resultsOfCommonShapes : resultsOfChainsAndEdges;
		if (results.empty() || results.back() != body)
		{
			results.push_back(body);
		}
	}
	BLOCK_END
	return true;
}

float32 PhysicsWorld::RayCast::ReportFixture(b2Fixture* fixture, const b2Vec2& point,
	const b2Vec2& normal, float32 fraction)
{
	result.body = r_cast<Body*>(fixture->GetBody()->GetUserData());
	result.point = point;
	result.normal = normal;
	if (closest)
	{
		return fraction;
	}
	else
	{
		results.push_back(result);
		return 1;
	}
}

float PhysicsWorld::b2Factor = 100.0f;

PhysicsWorld::PhysicsWorld():
_world(b2Vec2(0,-10)),
_velocityIterations(1),
_positionIterations(1),
_contactListner(new ContactListener()),
_contactFilter(new ContactFilter()),
_destructionListener(new DestructionListener())
{ }

PhysicsWorld::~PhysicsWorld()
{
	b2Body* b = nullptr;
	if (_world.GetBodyList())
	{
		RefVector<Body> bodies;
		while ((b = _world.GetBodyList()) != nullptr)
		{
			Body* body = r_cast<Body*>(b->GetUserData());
			if (body)
			{
				bodies.push_back(body);
				body->cleanup();
			}
		}
	}
}

bool PhysicsWorld::init()
{
	if (!Node::init()) return false;
	_world.SetContactFilter(_contactFilter);
	_world.SetContactListener(_contactListner);
	_world.SetDestructionListener(_destructionListener);
	for (int i = 0; i < 16; i++)
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
		_debugDraw->prepare();
		_world.DrawDebugData();
	}
}

b2World* PhysicsWorld::getB2World() const
{
	return c_cast<b2World*>(&_world);
}

void PhysicsWorld::setShowDebug(bool var)
{
	if (var)
	{
		if (!_world.GetDebugDraw())
		{
			_debugDraw = New<DebugDraw>();
			_world.SetDebugDraw(_debugDraw);
			addChild(_debugDraw->getRenderer(), INT_MAX, "DebugDraw"_slice);
		}
	}
	else if (_debugDraw)
	{
		_world.SetDebugDraw(nullptr);
		removeChild(_debugDraw->getRenderer());
		_debugDraw = nullptr;
	}
}

bool PhysicsWorld::isShowDebug() const
{
	return _world.GetDebugDraw() != nullptr;
}

void PhysicsWorld::setIterations(int velocityIter, int positionIter)
{
	_velocityIterations = velocityIter;
	_positionIterations = positionIter;
}

void PhysicsWorld::setGravity(const Vec2& gravity)
{
	_world.SetGravity(gravity);
}

Vec2 PhysicsWorld::getGravity() const
{
	return Vec2::from(_world.GetGravity());
}

bool PhysicsWorld::update(double deltaTime)
{
	if (isUpdating())
	{
		_world.Step(s_cast<float>(deltaTime), _velocityIterations, _positionIterations);
		for (b2Body* b = _world.GetBodyList(); b; b = b->GetNext())
		{
			if (b->IsActive())
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
	b2AABB aabb;
	aabb.lowerBound.Set(b2Val(rect.getLeft()), b2Val(rect.getBottom()));
	aabb.upperBound.Set(b2Val(rect.getRight()), b2Val(rect.getTop()));
	_queryCallback.setInfo(rect);
	_world.QueryAABB(&_queryCallback, aabb);
	bool result = false;
	for (Body* item : _queryCallback.resultsOfCommonShapes)
	{
		if (callback(item))
		{
			result = true;
			break;
		}
	}
	for (Body* item : _queryCallback.resultsOfChainsAndEdges)
	{
		if (callback(item))
		{
			result = true;
			break;
		}
	}
	_queryCallback.resultsOfChainsAndEdges.clear();
	_queryCallback.resultsOfCommonShapes.clear();
	return result;
}

bool PhysicsWorld::raycast(const Vec2& start, const Vec2& end, bool closest, const function<bool(Body*,const Vec2&,const Vec2&)>& callback)
{
	_rayCastCallBack.closest = closest;
	_world.RayCast(&_rayCastCallBack, PhysicsWorld::b2Val(start), PhysicsWorld::b2Val(end));
	bool result = false;
	if (closest)
	{
		RayCast::RayCastData& data = _rayCastCallBack.result;
		result = data.body ? callback(data.body, Vec2::from(oVal(data.point)), Vec2::from(data.normal)) : false;
		_rayCastCallBack.result.body = nullptr;
	}
	else
	{
		for (auto& item : _rayCastCallBack.results)
		{
			if (callback(item.body, Vec2::from(oVal(item.point)), Vec2::from(item.normal)))
			{
				result = true;
				break;
			}
		}
		_rayCastCallBack.results.clear();
	}
	return result;
}

void PhysicsWorld::setShouldContact(int groupA, int groupB, bool contact)
{
	b2Filter& filterA = _filters[groupA];
	b2Filter& filterB = _filters[groupB];
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
	for (b2Body* b = _world.GetBodyList(); b; b = b->GetNext())
	{
		b2Fixture* first = b->GetFixtureList();
		if (first)
		{
			int groupIndex = first->GetFilterData().groupIndex;
			if (groupIndex == groupA)
			{
				first->SetFilterData(_filters[groupA]);
			}
			else if (groupIndex == groupB)
			{
				first->SetFilterData(_filters[groupB]);
			}
			// Some shapes make the fixture list a circular list
			for (b2Fixture* f = first->GetNext();f && f != first;f = f->GetNext())
			{
				int groupIndex = f->GetFilterData().groupIndex;
				if (groupIndex == groupA)
				{
					f->SetFilterData(_filters[groupA]);
				}
				else if (groupIndex == groupB)
				{
					f->SetFilterData(_filters[groupB]);
				}
			}
		}
	}
}

bool PhysicsWorld::getShouldContact(int groupA, int groupB) const
{
	const b2Filter& filterA = _filters[groupA];
	const b2Filter& filterB = _filters[groupB];
	return (filterA.maskBits & filterB.categoryBits) && (filterA.categoryBits & filterB.maskBits);
}

const b2Filter& PhysicsWorld::getFilter(int group) const
{
	return _filters[group];
}

void PhysicsWorld::setContactListener(Own<ContactListener>&& listener )
{
	_contactListner = std::move(listener);
}

void PhysicsWorld::setContactFilter(Own<ContactFilter>&& filter )
{
	_contactFilter = std::move(filter);
}

void ContactListener::BeginContact(b2Contact* contact)
{
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
	Body* bodyA = (Body*)fixtureA->GetBody()->GetUserData();
	Body* bodyB = (Body*)fixtureB->GetBody()->GetUserData();
	if (!bodyA || !bodyB)
	{
		return;
	}
	if (fixtureA->IsSensor())
	{
		Sensor* sensor = (Sensor*)fixtureA->GetUserData();
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
		b2WorldManifold worldManifold;
		contact->GetWorldManifold(&worldManifold);
		Vec2 point = PhysicsWorld::oVal(worldManifold.points[0]);
		if (bodyA->isReceivingContact())
		{
			ContactPair pair = { bodyA, bodyB, point, Vec2::from(worldManifold.normal) };
			pair.retain();
			_contactStarts.push_back(pair);
		}
		if (bodyB->isReceivingContact())
		{
			ContactPair pair = { bodyB, bodyA, point, Vec2::from(worldManifold.normal) };
			pair.retain();
			_contactStarts.push_back(pair);
		}
	}
}

void ContactListener::EndContact(b2Contact* contact)
{
	b2Fixture* fixtureA = contact->GetFixtureA();
	b2Fixture* fixtureB = contact->GetFixtureB();
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
		Sensor* sensor = (Sensor*)fixtureB->GetUserData();
		if (sensor && bodyA && sensor->isEnabled())
		{
			SensorPair pair = {sensor, bodyA};
			pair.retain();
			_sensorLeaves.push_back(pair);
		}
	}
	else if (bodyA->isReceivingContact() || bodyB->isReceivingContact())
	{
		b2WorldManifold worldManifold;
		contact->GetWorldManifold(&worldManifold);
		Vec2 point = PhysicsWorld::oVal(worldManifold.points[0]);
		if (bodyA->isReceivingContact())
		{
			ContactPair pair = { bodyA, bodyB, point, Vec2::from(worldManifold.normal) };
			pair.retain();
			_contactEnds.push_back(pair);
		}
		if (bodyB->isReceivingContact())
		{
			ContactPair pair = { bodyB, bodyA, point, Vec2::from(worldManifold.normal) };
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

bool ContactFilter::ShouldCollide(b2Fixture* fixtureA, b2Fixture* fixtureB)
{
	const b2Filter& filterA = fixtureA->GetFilterData();
	const b2Filter& filterB = fixtureB->GetFilterData();
	return (filterA.maskBits & filterB.categoryBits) && (filterA.categoryBits & filterB.maskBits);
}

void DestructionListener::SayGoodbye(b2Joint* joint)
{
	Joint* jointItem = r_cast<Joint*>(joint->GetUserData());
	if (jointItem)
	{
		joint->SetUserData(nullptr);
		jointItem->_joint = nullptr;
	}
}

void DestructionListener::SayGoodbye(b2Fixture* fixture)
{ }

NS_DOROTHY_END
