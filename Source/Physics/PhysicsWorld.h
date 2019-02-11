/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "PlayRho/Collision/RayCastOutput.hpp"

namespace playrho {

template <>
bool Visit(const d2::DiskShapeConf& shape, void* userData);

template <>
bool Visit(const d2::EdgeShapeConf& shape, void* userData);

template <>
bool Visit(const d2::PolygonShapeConf& shape, void* userData);

template <>
bool Visit(const d2::ChainShapeConf& shape, void* userData);

template <>
bool Visit(const d2::MultiShapeConf& shape, void* userData);

} // namespace playrho

NS_DOROTHY_BEGIN

namespace pr = playrho;
namespace pd = playrho::d2;

class Body;
class Sensor;
class DebugDraw;

class ContactListener : public pd::ContactListener
{
public:
	virtual ~ContactListener();
	 virtual void BeginContact(pd::Contact& contact) override;
	 virtual void EndContact(pd::Contact& contact) override;
	/**
	 In subclass functions first call these functions from the base class,
	 then do some extra works.
	 */
	 virtual void PreSolve(pd::Contact& contact, const pd::Manifold& oldManifold) override;
	 virtual void PostSolve(pd::Contact& contact, const pd::ContactImpulsesList& impulses,
	 	iteration_type solved) override;
	 void SolveContacts();

	struct SensorPair
	{
		Sensor* sensor;
		Body* body;
		void retain();
		void release();
	};
	struct ContactPair
	{
		Body* bodyA;
		Body* bodyB;
		Vec2 point;
		Vec2 normal;
		void retain();
		void release();
	};
protected:
	vector<SensorPair> _sensorEnters;
	vector<SensorPair> _sensorLeaves;
	vector<ContactPair> _contactStarts;
	vector<ContactPair> _contactEnds;
};

class DestructionListener : public pd::DestructionListener
{
public:
	virtual void SayGoodbye(const pd::Joint& joint) noexcept override;
	virtual void SayGoodbye(const pd::Fixture& fixture) noexcept override;
};

class PhysicsWorld : public Node
{
public:
	virtual ~PhysicsWorld();
	PROPERTY_READONLY(pd::World*, PrWorld);
	PROPERTY_BOOL(ShowDebug);
	/**
	 Iterations affect PlayRho`s CPU cost greatly.
	 Lower these values to get better performance, higher values to get better simulation.
	 Default with the minimum value 1,1.
	 */
	void setIterations(int velocityIter, int positionIter);
	/**
	 You can change the contact listener with a subclass of ContactListener with
	 world->setContactListener(New<MyContactListener>());
	 */
	void setContactListener(Own<ContactListener>&& listener);

	virtual bool init() override;
	virtual bool update(double deltaTime) override;
	virtual void render() override;
	/**
	 Use this rect query at any time without worrying Box2D`s callback limits.
	 */
	bool query(const Rect& rect, const function<bool(Body*)>& callback);
	bool raycast(const Vec2& start, const Vec2& end, bool closest, const function<bool(Body*, const Vec2&, const Vec2&)>& callback);
	void setShouldContact(Uint8 groupA, Uint8 groupB, bool contact);
	bool getShouldContact(Uint8 groupA, Uint8 groupB) const;
	const pr::Filter& getFilter(Uint8 group) const;
	static inline float oVal(pr::Real value) { return float(value) * b2Factor; }
	static inline Vec2 oVal(const pr::Vec2& value) { return Vec2{value[0] * b2Factor, value[1] * b2Factor}; }
	static inline Vec2 oVal(const Vec2& value) { return value * b2Factor; }
	static inline pr::Real b2Val(float value) { return pr::Real(value / b2Factor); }
	static inline Vec2 b2Val(const pr::Vec2& value) { return Vec2{value[0] / b2Factor, value[1] / b2Factor}; }
	static inline Vec2 b2Val(const Vec2& value) { return value / b2Factor; }
	/**
	 b2Factor is used for converting PlayRho meters value to pixel value.
	 Default 100.0f is a good value since PlayRho can well simulate real life objects
	 between 0.1 to 10 meters. Use value 100.0f we can simulate game objects
	 between 10 to 1000 pixels that suites most games.
	 Better change this value before any physics body creation.
	 */
	static float b2Factor;
	enum { TotalGroups = 32 };
	CREATE_FUNC(PhysicsWorld);
protected:
	PhysicsWorld();
private:
	vector<Body*> _queryResultsOfCommonShapes;
	vector<Body*> _queryResultsOfChainsAndEdges;
private:
	struct RayCastData
	{
		RayCastData():body(nullptr),point{},normal{} {}
		Body* body;
		Vec2 point;
		Vec2 normal;
	} _rayCastResult;
	vector<RayCastData> _rayCastResults;
protected:
	Own<DebugDraw> _debugDraw;
private:
	pr::Filter _filters[TotalGroups];
	pd::World _world;
	pr::StepConf _stepConf;
	Own<ContactListener> _contactListner;
	Own<DestructionListener> _destructionListener;
	DORA_TYPE_OVERRIDE(PhysicsWorld);
};

NS_DOROTHY_END
