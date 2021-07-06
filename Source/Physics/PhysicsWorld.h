/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "PlayRho/Collision/RayCastOutput.hpp"

NS_DOROTHY_BEGIN

namespace pr = playrho;
namespace pd = playrho::d2;

class Body;
class Sensor;
class Joint;
class DebugDraw;

class PhysicsWorld : public Node
{
public:
	virtual ~PhysicsWorld();
	PROPERTY_READONLY_REF(pd::World, PrWorld);
	PROPERTY_BOOL(ShowDebug);
	/**
	 Iterations affect PlayRho`s CPU cost greatly.
	 Lower these values to get better performance, higher values to get better simulation.
	 Default with the minimum value 1,1.
	 */
	void setIterations(int velocityIter, int positionIter);

	virtual bool init() override;
	void doUpdate(double deltaTime);
	virtual bool fixedUpdate(double deltaTime) override;
	virtual bool update(double deltaTime) override;
	virtual void render() override;

	void setFixtureData(pr::ShapeID fixture, Sensor* sensor);
	Sensor* getFixtureData(pr::ShapeID fixture) const;

	void setBodyData(pr::BodyID b, Body* body);
	Body* getBodyData(pr::BodyID body) const;

	void setJointData(pr::JointID j, Joint* joint);
	Joint* getJointData(pr::JointID joint) const;

	/**
	 Use this rect query at any time without worrying Box2D`s callback limits.
	 */
	bool query(const Rect& rect, const std::function<bool(Body*)>& callback);
	bool raycast(const Vec2& start, const Vec2& end, bool closest, const std::function<bool(Body*, const Vec2&, const Vec2&)>& callback);
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	bool getShouldContact(uint8_t groupA, uint8_t groupB) const;
	const pr::Filter& getFilter(uint8_t group) const;
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
	enum { TotalGroups = sizeof(pr::Filter::bits_type) * 8 };
	CREATE_FUNC(PhysicsWorld);
protected:
	PhysicsWorld();
private:
	void setupBeginContact();
	void setupEndContact();
	void setupPreSolve();
	void solveContacts();
	std::vector<Body*> _queryResultsOfCommonShapes;
	std::vector<Body*> _queryResultsOfChainsAndEdges;
private:
	struct RayCastData
	{
		RayCastData():body(nullptr),point{},normal{} {}
		Body* body;
		Vec2 point;
		Vec2 normal;
	} _rayCastResult;
	std::vector<RayCastData> _rayCastResults;
protected:
	Own<DebugDraw> _debugDraw;
private:
	pr::Filter _filters[TotalGroups];
	pd::World _world;
	pr::StepConf _stepConf;

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
	std::vector<SensorPair> _sensorEnters;
	std::vector<SensorPair> _sensorLeaves;
	std::vector<ContactPair> _contactStarts;
	std::vector<ContactPair> _contactEnds;
	std::vector<Body*> _bodyData;
	std::vector<Sensor*> _fixtureData;
	std::vector<Joint*> _jointData;
	DORA_TYPE_OVERRIDE(PhysicsWorld);
};

NS_DOROTHY_END
