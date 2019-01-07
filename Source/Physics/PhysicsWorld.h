/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DOROTHY_BEGIN

class Body;
class Sensor;
class DebugDraw;

class ContactListener : public b2ContactListener
{
public:
	virtual ~ContactListener();
	/**
	 In subclass functions first call these functions from the base class,
	 then do some extra works.
	 */
	 virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold) override;
	 virtual void BeginContact(b2Contact* contact) override;
	 virtual void EndContact(b2Contact* contact) override;
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

class ContactFilter : public b2ContactFilter
{
	virtual bool ShouldCollide(b2Fixture* fixtureA, b2Fixture* fixtureB);
};

class DestructionListener : public b2DestructionListener
{
public:
	virtual void SayGoodbye(b2Joint* joint);
	virtual void SayGoodbye(b2Fixture* fixture);
};

class PhysicsWorld : public Node
{
public:
	virtual ~PhysicsWorld();
	PROPERTY_READONLY(b2World*, B2World);
	PROPERTY_BOOL(ShowDebug);
	/**
	 Iterations affect Box2D`s CPU cost greatly.
	 Lower these values to get better performance, higher values to get better simulation.
	 Default with the minimum value 1,1.
	 */
	void setIterations(int velocityIter, int positionIter);
	/**
	 You can change the contact listener with a subclass of ContactListener with
	 world->setContactListener(New<MyContactListener>());
	 */
	void setContactListener(Own<ContactListener>&& listener);
	/**
	 You can change the contact filter with a subclass of ContactFilter with
	 world->setContactFilter(New<MyContactFilter>());
	 */
	void setContactFilter(Own<ContactFilter>&& filter);
	void setGravity(const Vec2& gravity);
	Vec2 getGravity() const;

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
	const b2Filter& getFilter(Uint8 group) const;
	static inline float oVal(float value) { return value * b2Factor; }
	static inline Vec2 oVal(const b2Vec2& value) { return Vec2{value.x * b2Factor, value.y * b2Factor}; }
	static inline Vec2 oVal(const Vec2& value) { return value * b2Factor; }
	static inline float b2Val(float value) { return value / b2Factor; }
	static inline Vec2 b2Val(const b2Vec2& value) { return Vec2{value.x / b2Factor, value.y / b2Factor}; }
	static inline Vec2 b2Val(const Vec2& value) { return value / b2Factor; }
	/**
	 b2Factor is used for converting Box2D meters value to pixel value.
	 Default 100.0f is a good value since Box2D can well simulate real life objects
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
	class QueryAABB : public b2QueryCallback
	{
	public:
		void setInfo(const Rect& rc);
		vector<Body*> resultsOfCommonShapes;
		vector<Body*> resultsOfChainsAndEdges;
		virtual bool ReportFixture(b2Fixture* fixture);
	private:
		b2PolygonShape testShape;
		b2Transform transform;
	} _queryCallback;
	class RayCast : public b2RayCastCallback
	{
	public:
		struct RayCastData
		{
			RayCastData():body(nullptr),point{},normal{} {}
			Body* body;
			b2Vec2 point;
			b2Vec2 normal;
		} result;
		vector<RayCastData> results;
		bool closest;
		virtual float32 ReportFixture(b2Fixture* fixture, const b2Vec2& point,
			const b2Vec2& normal, float32 fraction);
	} _rayCastCallBack;
protected:
	Own<DebugDraw> _debugDraw;
private:
	b2Filter _filters[TotalGroups];
	b2World _world;
	Own<ContactListener> _contactListner;
	Own<ContactFilter> _contactFilter;
	Own<DestructionListener> _destructionListener;
	int _velocityIterations;
	int _positionIterations;
	DORA_TYPE_OVERRIDE(PhysicsWorld);
};

NS_DOROTHY_END
