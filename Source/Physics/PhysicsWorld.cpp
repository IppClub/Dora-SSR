/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

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
#include "Basic/Application.h"
#include "Event/Event.h"
#include "PlayRho/Collision/Manifold.hpp"
#include "PlayRho/Collision/DynamicTree.hpp"
#include "PlayRho/Collision/Distance.hpp"

NS_DOROTHY_BEGIN

void PhysicsWorld::SensorPair::retain()
{
	sensor->getOwner()->retain();
	sensor->retain();
	body->retain();
}

void PhysicsWorld::SensorPair::release()
{
	sensor->getOwner()->release();
	sensor->release();
	body->release();
}

void PhysicsWorld::ContactPair::retain()
{
	bodyA->retain();
	bodyB->retain();
}

void PhysicsWorld::ContactPair::release()
{
	bodyA->release();
	bodyB->release();
}

float PhysicsWorld::b2Factor = 100.0f;

PhysicsWorld::PhysicsWorld():
_world{}
{
	_stepConf.regVelocityIters = 1;
	_stepConf.regPositionIters = 1;
}

PhysicsWorld::~PhysicsWorld()
{
	RefVector<Body> bodies;
	for (pr::BodyID b : _world.GetBodies())
	{
		Body* body = _bodyData[b.get()];
		if (body) bodies.push_back(body);
	}
	for (Body* b : bodies)
	{
		b->cleanup();
	}
	for (auto& pair : _sensorEnters)
	{
		pair.release();
	}
	for (auto& pair : _sensorLeaves)
	{
		pair.release();
	}
	for (auto& pair : _contactStarts)
	{
		pair.release();
	}
	for (auto& pair : _contactEnds)
	{
		pair.release();
	}
}

void PhysicsWorld::setupBeginContact()
{
	_world.SetBeginContactListener([this](pr::ContactID contact)
	{
		pr::ShapeID fixtureA = pd::GetShapeA(_world, contact);
		pr::ShapeID fixtureB = pd::GetShapeB(_world, contact);
		Body* bodyA = _bodyData[pd::GetBodyA(_world, contact).get()];
		Body* bodyB = _bodyData[pd::GetBodyB(_world, contact).get()];
		if (!bodyA || !bodyB) return;
		if (pd::IsSensor(_world, fixtureA))
		{
			Sensor* sensor = _fixtureData[fixtureA.get()];
			if (sensor && sensor->isEnabled() &&
				!pd::IsSensor(_world, fixtureB))
			{
				SensorPair pair{sensor, bodyB};
				pair.retain();
				_sensorEnters.push_back(pair);
			}
		}
		else if (pd::IsSensor(_world, fixtureB))
		{
			Sensor* sensor = _fixtureData[fixtureB.get()];
			if (sensor && sensor->isEnabled())
			{
				SensorPair pair{sensor, bodyA};
				pair.retain();
				_sensorEnters.push_back(pair);
			}
		}
		else if (bodyA->isReceivingContact() ||
			bodyB->isReceivingContact())
		{
			pd::WorldManifold worldManifold = pd::GetWorldManifold(_world, contact);
			Vec2 point = PhysicsWorld::oVal(worldManifold.GetPoint(0));
			if (bodyA->isReceivingContact())
			{
				pd::UnitVec normal = worldManifold.GetNormal();
				ContactPair pair{ bodyA, bodyB, point, {normal[0], normal[1]} };
				pair.retain();
				_contactStarts.push_back(pair);
			}
			if (bodyB->isReceivingContact())
			{
				pd::UnitVec normal = worldManifold.GetNormal();
				ContactPair pair{ bodyB, bodyA, point, {normal[0], normal[1]} };
				pair.retain();
				_contactStarts.push_back(pair);
			}
		}
	});
}

void PhysicsWorld::setupEndContact()
{
	_world.SetEndContactListener([this](pr::ContactID contact)
	{
		pr::ShapeID fixtureA = pd::GetShapeA(_world, contact);
		pr::ShapeID fixtureB = pd::GetShapeB(_world, contact);
		Body* bodyA = _bodyData[pd::GetBodyA(_world, contact).get()];
		Body* bodyB = _bodyData[pd::GetBodyB(_world, contact).get()];
		if (pd::IsSensor(_world, fixtureA))
		{
			Sensor* sensor = _fixtureData[fixtureA.get()];
			if (sensor && bodyB && sensor->isEnabled() &&
				!pd::IsSensor(_world, fixtureB))
			{
				SensorPair pair{sensor, bodyB};
				pair.retain();
				_sensorLeaves.push_back(pair);
			}
		}
		else if (pd::IsSensor(_world, fixtureB))
		{
			Sensor* sensor = _fixtureData[fixtureB.get()];
			if (sensor && bodyA && sensor->isEnabled())
			{
				SensorPair pair{sensor, bodyA};
				pair.retain();
				_sensorLeaves.push_back(pair);
			}
		}
		else if ((bodyA && bodyB) && (bodyA->isReceivingContact() ||
			bodyB->isReceivingContact()))
		{
			pd::WorldManifold worldManifold = pd::GetWorldManifold(_world, contact);
			Vec2 point = PhysicsWorld::oVal(worldManifold.GetPoint(0));
			if (bodyA->isReceivingContact())
			{
				pd::UnitVec normal = worldManifold.GetNormal();
				ContactPair pair{ bodyA, bodyB, point, {normal[0], normal[1]} };
				pair.retain();
				_contactEnds.push_back(pair);
			}
			if (bodyB->isReceivingContact())
			{
				pd::UnitVec normal = worldManifold.GetNormal();
				ContactPair pair{ bodyB, bodyA, point, {normal[0], normal[1]} };
				pair.retain();
				_contactEnds.push_back(pair);
			}
		}
	});
}

void PhysicsWorld::setupPreSolve()
{
	_world.SetPreSolveContactListener([this](pr::ContactID contact, const pd::Manifold&)
	{
		Body* bodyA = _bodyData[pd::GetBodyA(_world, contact).get()];
		Body* bodyB = _bodyData[pd::GetBodyB(_world, contact).get()];
		if (!bodyA || !bodyB) return;
		if (!bodyA->isReceivingContact() && !bodyB->isReceivingContact()) return;
		if (bodyA->isReceivingContact() && bodyA->filterContact && !bodyA->filterContact(bodyB))
		{
			pd::UnsetEnabled(_world, contact);
		}
		else if (bodyB->isReceivingContact() && bodyB->filterContact && !bodyB->filterContact(bodyA))
		{
			pd::UnsetEnabled(_world, contact);
		}
	if (!pd::IsEnabled(_world, contact))
	{
		pd::WorldManifold worldManifold = pd::GetWorldManifold(_world, contact);
		Vec2 point = PhysicsWorld::oVal(worldManifold.GetPoint(0));
		if (bodyA->isReceivingContact())
		{
			pd::UnitVec normal = worldManifold.GetNormal();
			ContactPair pair{ bodyA, bodyB, point, {normal[0], normal[1]} };
			pair.retain();
			_contactStarts.push_back(pair);
		}
		if (bodyB->isReceivingContact())
		{
			pd::UnitVec normal = worldManifold.GetNormal();
			ContactPair pair{ bodyB, bodyA, point, {normal[0], normal[1]} };
			pair.retain();
			_contactStarts.push_back(pair);
		}
	}
	});
}

bool PhysicsWorld::init()
{
	if (!Node::init()) return false;
	setupBeginContact();
	setupEndContact();
	setupPreSolve();
	for (int i = 0; i < TotalGroups; i++)
	{
		_filters[i].groupIndex = i;
		_filters[i].categoryBits = 1<<i;
		_filters[i].maskBits = 0;
	}
	Node::scheduleUpdateFixed();
	return true;
}

void PhysicsWorld::render()
{
	if (_debugDraw)
	{
		_debugDraw->DrawWorld(this);
	}
}

pd::World& PhysicsWorld::getPrWorld()
{
	return _world;
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
	_stepConf.regVelocityIters = velocityIter;
	_stepConf.regPositionIters = positionIter;
	_stepConf.toiVelocityIters = velocityIter;
	if (positionIter == 0)
	{
		_stepConf.toiPositionIters = 0;
	}
}

void PhysicsWorld::doUpdate(double deltaTime)
{
	double start = SharedApplication.getEclapsedTime();
	_stepConf.deltaTime = s_cast<pr::Time>(deltaTime);
	_stepConf.dtRatio = _stepConf.deltaTime * _world.GetInvDeltaTime();
	_world.Step(_stepConf);
	const auto& bodies = _world.GetBodies();
	for (pr::BodyID b : bodies)
	{
		if (pd::IsEnabled(_world, b))
		{
			Body* body = _bodyData[b.get()];
			body->updatePhysics();
		}
	}
	Event::send("_TIMECOST_"_slice,
		"Physics"_slice.toString(),
		SharedApplication.getEclapsedTime() - start);
	solveContacts();
}

bool PhysicsWorld::fixedUpdate(double deltaTime)
{
	if (isFixedUpdating())
	{
		doUpdate(deltaTime);
	}
	return Node::fixedUpdate(deltaTime);
}

bool PhysicsWorld::update(double deltaTime)
{
	if (isUpdating() && !isFixedUpdating())
	{
		doUpdate(deltaTime);
	}
	return Node::update(deltaTime);
}

void PhysicsWorld::setFixtureData(pr::ShapeID f, Sensor* sensor)
{
	if (_fixtureData.size() < f.get() + 1u)
	{
		_fixtureData.resize(f.get() + 1u);
	}
	_fixtureData[f.get()] = sensor;
}

Sensor* PhysicsWorld::getFixtureData(pr::ShapeID fixture) const
{
	return _fixtureData[fixture.get()];
}

void PhysicsWorld::setBodyData(pr::BodyID b, Body* body)
{
	if (_bodyData.size() < b.get() + 1u)
	{
		_bodyData.resize(b.get() + 1u);
	}
	_bodyData[b.get()] = body;
}

Body* PhysicsWorld::getBodyData(pr::BodyID body) const
{
	return _bodyData[body.get()];
}

void PhysicsWorld::setJointData(pr::JointID j, Joint* joint)
{
	if (_jointData.size() < j.get() + 1u)
	{
		_jointData.resize(j.get() + 1u);
	}
	_jointData[j.get()] = joint;
}

Joint* PhysicsWorld::getJointData(pr::JointID joint) const
{
	return _jointData[joint.get()];
}

bool PhysicsWorld::query(const Rect& rect, const std::function<bool(Body*)>& callback)
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
	pd::Query(_world.GetTree(), aabb, [&](pr::BodyID bodyID, pr::ShapeID shapeID, const pr::ChildCounter)
	{
		BLOCK_START
		{
			BREAK_IF(pd::IsSensor(_world, shapeID));
			const auto shapeType = pd::GetType(_world, shapeID);
			bool isCommonShape = shapeType != pr::GetTypeID<pd::ChainShapeConf>() && shapeType != pr::GetTypeID<pd::EdgeShapeConf>();
			BREAK_IF(isCommonShape &&
				!pd::TestOverlap(pd::GetChild(testShape, 0), transform, pd::GetChild(pd::GetShape(_world, shapeID), 0),
				pd::GetTransformation(_world, bodyID)));
			Body* body = _bodyData[bodyID.get()];
			std::vector<Body*>& results = isCommonShape ? _queryResultsOfCommonShapes : _queryResultsOfChainsAndEdges;
			if (body && (results.empty() || results.back() != body))
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

bool PhysicsWorld::raycast(const Vec2& start, const Vec2& end, bool closest, const std::function<bool(Body*,const Vec2&,const Vec2&)>& callback)
{
	pd::RayCastInput input{b2Val(start), b2Val(end), pr::Real{1}};
	bool result = false;
	pd::RayCast(_world, input, [&](pr::BodyID body, pr::ShapeID fixture, pr::ChildCounter child, pr::Length2 point, pd::UnitVec normal)
	{
		Body* node = _bodyData[body.get()];
		if (!node) return pr::RayCastOpcode::ResetRay;
		_rayCastResult.body = node;
		_rayCastResult.point = oVal(pr::Vec2{point[0], point[1]});
		_rayCastResult.normal = oVal(pr::Vec2{normal[0], normal[1]});
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

void PhysicsWorld::setShouldContact(uint8_t groupA, uint8_t groupB, bool contact)
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
	for (pr::BodyID body : _world.GetBodies())
	{
		for (pr::ShapeID f : pd::GetShapes(_world, body))
		{
			int groupIndex = pd::GetFilterData(_world, f).groupIndex;
			if (groupIndex == groupA)
			{
				pd::SetFilterData(_world, f, _filters[groupA]);
			}
			else if (groupIndex == groupB)
			{
				pd::SetFilterData(_world, f, _filters[groupB]);
			}
		}
	}
}

bool PhysicsWorld::getShouldContact(uint8_t groupA, uint8_t groupB) const
{
	AssertIf(groupA >= TotalGroups || groupB >= TotalGroups, "Body group should be less than {}.", TotalGroups);
	const pr::Filter& filterA = _filters[groupA];
	const pr::Filter& filterB = _filters[groupB];
	return (filterA.maskBits & filterB.categoryBits) && (filterA.categoryBits & filterB.maskBits);
}

const pr::Filter& PhysicsWorld::getFilter(uint8_t group) const
{
	AssertIf(group >= TotalGroups, "Body group should be less than {}.", TotalGroups);
	return _filters[group];
}

void PhysicsWorld::solveContacts()
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

NS_DOROTHY_END
