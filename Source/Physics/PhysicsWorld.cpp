/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Physics/PhysicsWorld.h"

#include "Basic/Application.h"
#include "Node/DrawNode.h"
#include "Physics/Body.h"
#include "Physics/DebugDraw.h"
#include "Physics/Joint.h"
#include "Physics/Sensor.h"
#include "playrho/d2/Distance.hpp"
#include "playrho/d2/DynamicTree.hpp"
#include "playrho/d2/Manifold.hpp"

NS_DORA_BEGIN

float PhysicsWorld::scaleFactor = 100.0f;

PhysicsWorld::PhysicsWorld() {
	_stepConf.regVelocityIters = 1;
	_stepConf.regPositionIters = 1;
	static_assert(sizeof(decltype(pr::Filter::categoryBits)) == 4, "filter category should be 32 bits");
	static_assert(sizeof(decltype(pr::Filter::maskBits)) == 4, "filter mask should be 32 bits");
	static_assert(sizeof(decltype(pr::Filter::groupIndex)) == 1, "filter group index should be 8 bits");
}

PhysicsWorld::~PhysicsWorld() {
	clearPhysics();
}

void PhysicsWorld::setupBeginContact() {
	pd::SetBeginContactListener(*_world, [this](pr::ContactID contact) {
		auto& world = *_world;
		if (!pd::IsEnabled(world, contact)) {
			return;
		}
		pr::ShapeID fixtureA = pd::GetShapeA(world, contact);
		pr::ShapeID fixtureB = pd::GetShapeB(world, contact);
		Body* bodyA = _bodyData[pd::GetBodyA(world, contact).get()];
		Body* bodyB = _bodyData[pd::GetBodyB(world, contact).get()];
		if (!bodyA || !bodyB) {
			return;
		}
		if (pd::IsSensor(world, fixtureA)) {
			Sensor* sensor = _fixtureData[fixtureA.get()];
			if (sensor && sensor->isEnabled() && !pd::IsSensor(world, fixtureB) && sensor->getOwner()) {
				SensorPair pair{MakeWRef(sensor->getOwner()), MakeWRef(sensor), MakeWRef(bodyB)};
				_sensorEnters.push_back(pair);
			}
		} else if (pd::IsSensor(world, fixtureB)) {
			Sensor* sensor = _fixtureData[fixtureB.get()];
			if (sensor && sensor->isEnabled() && sensor->getOwner()) {
				SensorPair pair{MakeWRef(sensor->getOwner()), MakeWRef(sensor), MakeWRef(bodyA)};
				_sensorEnters.push_back(pair);
			}
		} else {
			if (bodyA->isReceivingContact() || bodyB->isReceivingContact()) {
				if (bodyA->filterContact && !bodyA->filterContact(bodyB)) {
					pd::UnsetEnabled(world, contact);
				} else if (bodyB->filterContact && !bodyB->filterContact(bodyA)) {
					pd::UnsetEnabled(world, contact);
				}
				bool enabled = pd::IsEnabled(world, contact);
				pd::WorldManifold worldManifold = pd::GetWorldManifold(world, contact);
				Vec2 point = PhysicsWorld::Val(worldManifold.GetPoint(0));
				pd::UnitVec normal = worldManifold.GetNormal();
				if (bodyA->isReceivingContact()) {
					ContactPair pair{MakeWRef(bodyA), MakeWRef(bodyB), point, {normal[0], normal[1]}, enabled};
					_contactStarts.push_back(pair);
				}
				if (bodyB->isReceivingContact()) {
					ContactPair pair{MakeWRef(bodyB), MakeWRef(bodyA), point, {normal[0], normal[1]}, enabled};
					_contactStarts.push_back(pair);
				}
			}
		}
	});
}

void PhysicsWorld::setupEndContact() {
	pd::SetEndContactListener(*_world, [this](pr::ContactID contact) {
		auto& world = *_world;
		if (!pd::IsEnabled(world, contact)) {
			return;
		}
		pr::ShapeID fixtureA = pd::GetShapeA(world, contact);
		pr::ShapeID fixtureB = pd::GetShapeB(world, contact);
		Body* bodyA = _bodyData[pd::GetBodyA(world, contact).get()];
		Body* bodyB = _bodyData[pd::GetBodyB(world, contact).get()];
		if (pd::IsSensor(world, fixtureA)) {
			Sensor* sensor = _fixtureData[fixtureA.get()];
			if (sensor && bodyB && sensor->isEnabled() && !pd::IsSensor(world, fixtureB) && sensor->getOwner()) {
				SensorPair pair{MakeWRef(sensor->getOwner()), MakeWRef(sensor), MakeWRef(bodyB)};
				_sensorLeaves.push_back(pair);
			}
		} else if (pd::IsSensor(world, fixtureB)) {
			Sensor* sensor = _fixtureData[fixtureB.get()];
			if (sensor && bodyA && sensor->isEnabled() && sensor->getOwner()) {
				SensorPair pair{MakeWRef(sensor->getOwner()), MakeWRef(sensor), MakeWRef(bodyA)};
				_sensorLeaves.push_back(pair);
			}
		} else if ((bodyA && bodyB) && (bodyA->isReceivingContact() || bodyB->isReceivingContact())) {
			pd::WorldManifold worldManifold = pd::GetWorldManifold(world, contact);
			Vec2 point = PhysicsWorld::Val(worldManifold.GetPoint(0));
			if (bodyA->isReceivingContact()) {
				pd::UnitVec normal = worldManifold.GetNormal();
				ContactPair pair{MakeWRef(bodyA), MakeWRef(bodyB), point, {normal[0], normal[1]}};
				_contactEnds.push_back(pair);
			}
			if (bodyB->isReceivingContact()) {
				pd::UnitVec normal = worldManifold.GetNormal();
				ContactPair pair{MakeWRef(bodyB), MakeWRef(bodyA), point, {normal[0], normal[1]}};
				_contactEnds.push_back(pair);
			}
		}
	});
}

bool PhysicsWorld::init() {
	if (!Node::init()) return false;
	_world = New<pd::World>();
	setupBeginContact();
	setupEndContact();
	for (int i = 0; i < TotalGroups; i++) {
		_filters[i].groupIndex = i;
		_filters[i].categoryBits = 1 << i;
		_filters[i].maskBits = 0;
		setShouldContact(i, i, true);
	}
	Node::scheduleFixedUpdate();
	return true;
}

void PhysicsWorld::render() {
	if (_debugDraw) {
		_debugDraw->DrawWorld(this);
	}
	Node::render();
}

void PhysicsWorld::clearPhysics() {
	if (_world) {
		RefVector<Body> bodies;
		for (pr::BodyID b : pd::GetBodies(*_world)) {
			Body* body = _bodyData[b.get()];
			if (body) bodies.push_back(body);
		}
		for (Body* b : bodies) {
			b->clearPhysics();
		}
		_world = nullptr;
	}
}

void PhysicsWorld::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		clearPhysics();
		Node::cleanup();
	}
}

pd::World* PhysicsWorld::getPrWorld() const noexcept {
	return _world.get();
}

void PhysicsWorld::setShowDebug(bool var) {
	if (var) {
		if (!_debugDraw) {
			_debugDraw = New<DebugDraw>();
			addChild(_debugDraw->getRenderer(), INT_MAX, "DebugDraw"_slice);
		}
	} else if (_debugDraw) {
		removeChild(_debugDraw->getRenderer());
		_debugDraw = nullptr;
	}
	Node::setShowDebug(var);
}

void PhysicsWorld::setIterations(int velocityIter, int positionIter) {
	_stepConf.regVelocityIters = velocityIter;
	_stepConf.regPositionIters = positionIter;
	_stepConf.toiVelocityIters = velocityIter;
	if (positionIter == 0) {
		_stepConf.toiPositionIters = 0;
	}
}

void PhysicsWorld::doUpdate(double deltaTime) {
	if (!_world) return;
	auto& world = *_world;
	{
		PROFILE("Physics"_slice);
		_stepConf.deltaTime = s_cast<pr::Time>(deltaTime);
		_stepConf.dtRatio = _stepConf.deltaTime * pd::GetInvDeltaTime(world);
		pd::Step(world, _stepConf);
		const auto& bodies = pd::GetBodies(world);
		for (pr::BodyID b : bodies) {
			if (pd::IsEnabled(world, b)) {
				Body* body = _bodyData[b.get()];
				body->updatePhysics();
			}
		}
	}
	solveContacts();
}

bool PhysicsWorld::fixedUpdate(double deltaTime) {
	if (isFixedUpdating()) {
		doUpdate(deltaTime);
	}
	return Node::fixedUpdate(deltaTime);
}

bool PhysicsWorld::update(double deltaTime) {
	if (isUpdating() && !isFixedUpdating()) {
		doUpdate(deltaTime);
	}
	return Node::update(deltaTime);
}

void PhysicsWorld::setFixtureData(pr::ShapeID f, Sensor* sensor) {
	if (_fixtureData.size() < f.get() + 1u) {
		_fixtureData.resize(f.get() + 1u);
	}
	_fixtureData[f.get()] = sensor;
}

Sensor* PhysicsWorld::getFixtureData(pr::ShapeID fixture) const {
	return _fixtureData[fixture.get()];
}

void PhysicsWorld::setBodyData(pr::BodyID b, Body* body) {
	if (_bodyData.size() < b.get() + 1u) {
		_bodyData.resize(b.get() + 1u);
	}
	_bodyData[b.get()] = body;
}

Body* PhysicsWorld::getBodyData(pr::BodyID body) const {
	return _bodyData[body.get()];
}

void PhysicsWorld::setJointData(pr::JointID j, Joint* joint) {
	if (_jointData.size() < j.get() + 1u) {
		_jointData.resize(j.get() + 1u);
	}
	_jointData[j.get()] = joint;
}

Joint* PhysicsWorld::getJointData(pr::JointID joint) const {
	return _jointData[joint.get()];
}

bool PhysicsWorld::query(const Rect& rect, const std::function<bool(Body*)>& callback) {
	AssertUnless(_world, "accessing invalid physics world.");
	auto& world = *_world;
	pd::AABB aabb{
		pd::AABB::Location{
			prVal(rect.getLeft()),
			prVal(rect.getBottom())},
		pd::AABB::Location{
			prVal(rect.getRight()),
			prVal(rect.getTop())}};
	pd::Transformation transform{
		pr::Length2{
			prVal(rect.getCenterX()),
			prVal(rect.getCenterY())}};
	pd::Shape testShape = pd::Shape{
		pd::PolygonShapeConf{
			prVal(rect.size.width),
			prVal(rect.size.height)}};
	pd::Query(pd::GetTree(world), aabb, [&](pr::BodyID bodyID, pr::ShapeID shapeID, const pr::ChildCounter) {
		BLOCK_START {
			BREAK_IF(pd::IsSensor(world, shapeID));
			const auto shapeType = pd::GetType(world, shapeID);
			bool isCommonShape = shapeType != pr::GetTypeID<pd::ChainShapeConf>() && shapeType != pr::GetTypeID<pd::EdgeShapeConf>();
			const auto shape = pd::GetShape(world, shapeID);
			BREAK_IF(isCommonShape && !pd::TestOverlap(pd::GetChild(testShape, 0), transform, pd::GetChild(shape, 0), pd::GetTransformation(world, bodyID)));
			Body* body = _bodyData[bodyID.get()];
			std::vector<Body*>& results = isCommonShape ? _queryResultsOfCommonShapes : _queryResultsOfChainsAndEdges;
			if (body && (results.empty() || results.back() != body)) {
				results.push_back(body);
			}
		}
		BLOCK_END
		return true;
	});
	bool result = false;
	for (Body* item : _queryResultsOfCommonShapes) {
		if (callback(item)) {
			result = true;
			break;
		}
	}
	for (Body* item : _queryResultsOfChainsAndEdges) {
		if (callback(item)) {
			result = true;
			break;
		}
	}
	_queryResultsOfCommonShapes.clear();
	_queryResultsOfChainsAndEdges.clear();
	return result;
}

bool PhysicsWorld::raycast(const Vec2& start, const Vec2& end, bool closest, const std::function<bool(Body*, const Vec2&, const Vec2&)>& callback) {
	AssertUnless(_world, "accessing invalid physics world.");
	auto& world = *_world;
	pd::RayCastInput input{prVal(start), prVal(end), pr::Real{1}};
	bool result = false;
	pd::RayCast(world, input, [&](pr::BodyID body, pr::ShapeID fixture, pr::ChildCounter child, pr::Length2 point, pd::UnitVec normal) {
		Body* node = _bodyData[body.get()];
		if (!node) return pr::RayCastOpcode::ResetRay;
		_rayCastResult.body = node;
		_rayCastResult.point = Val(pr::Vec2{point[0], point[1]});
		_rayCastResult.normal = Val(pr::Vec2{normal[0], normal[1]});
		if (closest) {
			return pr::RayCastOpcode::Terminate;
		} else {
			_rayCastResults.push_back(_rayCastResult);
			return pr::RayCastOpcode::ResetRay;
		}
	});
	if (closest) {
		result = _rayCastResult.body ? callback(_rayCastResult.body, _rayCastResult.point, _rayCastResult.normal) : false;
		_rayCastResult.body = nullptr;
	} else {
		for (auto& item : _rayCastResults) {
			if (callback(item.body, item.point, item.normal)) {
				result = true;
				break;
			}
		}
		_rayCastResults.clear();
	}
	return result;
}

void PhysicsWorld::setShouldContact(uint8_t groupA, uint8_t groupB, bool contact) {
	AssertIf(groupA >= TotalGroups || groupB >= TotalGroups, "Body group should be less than {}.", s_cast<int>(TotalGroups));
	AssertUnless(_world, "accessing invalid physics world.");
	auto& world = *_world;
	pr::Filter& filterA = _filters[groupA];
	pr::Filter& filterB = _filters[groupB];
	if (contact) {
		filterA.maskBits |= filterB.categoryBits;
		filterB.maskBits |= filterA.categoryBits;
	} else {
		filterA.maskBits &= (~filterB.categoryBits);
		filterB.maskBits &= (~filterA.categoryBits);
	}
	for (pr::BodyID body : pd::GetBodies(world)) {
		for (pr::ShapeID f : pd::GetShapes(world, body)) {
			int groupIndex = pd::GetFilterData(world, f).groupIndex;
			if (groupIndex == groupA) {
				pd::SetFilterData(world, f, _filters[groupA]);
			} else if (groupIndex == groupB) {
				pd::SetFilterData(world, f, _filters[groupB]);
			}
		}
	}
}

bool PhysicsWorld::getShouldContact(uint8_t groupA, uint8_t groupB) const {
	AssertIf(groupA >= TotalGroups || groupB >= TotalGroups, "Body group should be less than {}.", s_cast<int>(TotalGroups));
	const pr::Filter& filterA = _filters[groupA];
	const pr::Filter& filterB = _filters[groupB];
	return (filterA.maskBits & filterB.categoryBits) && (filterA.categoryBits & filterB.maskBits);
}

const pr::Filter& PhysicsWorld::getFilter(uint8_t group) const {
	AssertIf(group >= TotalGroups, "Body group should be less than {}.", s_cast<int>(TotalGroups));
	return _filters[group];
}

void PhysicsWorld::solveContacts() {
	if (!_contactStarts.empty()) {
		for (ContactPair& pair : _contactStarts) {
			if (pair.bodyA && pair.bodyB) {
				pair.bodyA->contactStart(pair.bodyB, pair.point, pair.normal, pair.enabled);
			}
		}
		_contactStarts.clear();
	}
	if (!_contactEnds.empty()) {
		for (ContactPair& pair : _contactEnds) {
			if (pair.bodyA && pair.bodyB) {
				pair.bodyA->contactEnd(pair.bodyB, pair.point, pair.normal);
			}
		}
		_contactEnds.clear();
	}
	if (!_sensorEnters.empty()) {
		for (SensorPair& pair : _sensorEnters) {
			if (pair.owner && pair.sensor && pair.body && pair.sensor->isEnabled()) {
				pair.sensor->add(pair.body);
			}
		}
		_sensorEnters.clear();
	}
	if (!_sensorLeaves.empty()) {
		for (SensorPair& pair : _sensorLeaves) {
			if (pair.owner && pair.sensor && pair.body && pair.sensor->isEnabled()) {
				pair.sensor->remove(pair.body);
			}
		}
		_sensorLeaves.clear();
	}
}

NS_DORA_END
