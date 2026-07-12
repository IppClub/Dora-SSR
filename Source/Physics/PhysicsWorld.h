/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "playrho/d2/RayCastOutput.hpp"

NS_DORA_BEGIN

namespace pr = playrho;
namespace pd = playrho::d2;

class Body;
class Sensor;
class Joint;
class DebugDraw;
class Node3D;

enum class BodyType3D : uint8_t {
	Static,
	Kinematic,
	Dynamic,
};

class PhysicsWorld3D;
class Body3D;
class CharacterController3D;
class PhysicsShape3D;
class Constraint3D;
class PhysicsShape3DCache;

using Contact3DHandler = std::function<void(Body3D*, const Vec3&, const Vec3&)>;

class Body3D : public Object {
public:
	virtual ~Body3D();
	PROPERTY_READONLY(Node3D*, Node);
	PROPERTY_READONLY(PhysicsWorld3D*, PhysicsWorld);
	PROPERTY_READONLY(BodyType3D, Type);
	uint8_t getTypeValue() const noexcept;
	PROPERTY_CREF(Vec3, LinearVelocity);
	PROPERTY_CREF(Vec3, AngularVelocity);
	PROPERTY(uint8_t, CollisionLayer);
	PROPERTY(uint32_t, CollisionMask);
	PROPERTY_BOOL(Sensor);
	void applyForce(const Vec3& force);
	void applyImpulse(const Vec3& impulse);
	void onContactEnter(const Contact3DHandler& handler);
	void onContactStay(const Contact3DHandler& handler);
	void onContactExit(const Contact3DHandler& handler);
	void destroy();
	virtual void cleanup() override;

protected:
	Body3D(NotNull<PhysicsWorld3D, 1> world, NotNull<Node3D, 2> node, BodyType3D type, uint64_t handle);

private:
	enum class DebugShape : uint8_t {
		Bounds,
		Box,
		Sphere,
		Capsule,
	};
	void clearPhysics();
	void dispatchContact(uint8_t eventType, Body3D* other, const Vec3& point, const Vec3& normal);
	WRef<PhysicsWorld3D> _world;
	WRef<Node3D> _node;
	BodyType3D _type;
	uint64_t _handle;
	mutable Vec3 _linearVelocity;
	mutable Vec3 _angularVelocity;
	uint8_t _collisionLayer;
	uint32_t _collisionMask;
	bool _sensor;
	DebugShape _debugShape;
	Vec3 _debugSize;
	Contact3DHandler _contactEnter;
	Contact3DHandler _contactStay;
	Contact3DHandler _contactExit;
	friend class PhysicsWorld3D;
	friend class Object;
	DORA_TYPE_OVERRIDE(Body3D);
};

class CharacterController3D : public Object {
public:
	virtual ~CharacterController3D();
	PROPERTY_READONLY(Node3D*, Node);
	PROPERTY_READONLY(PhysicsWorld3D*, PhysicsWorld);
	PROPERTY_CREF(Vec3, DesiredVelocity);
	PROPERTY_READONLY_CREF(Vec3, Velocity);
	PROPERTY_READONLY_CREF(Vec3, GroundNormal);
	PROPERTY_READONLY_BOOL(Grounded);
	PROPERTY(uint8_t, CollisionLayer);
	PROPERTY(uint32_t, CollisionMask);
	void jump(float speed);
	void destroy();
	virtual void cleanup() override;

protected:
	CharacterController3D(NotNull<PhysicsWorld3D, 1> world, NotNull<Node3D, 2> node, uint64_t handle);

private:
	void clearPhysics();
	void refreshState() const;
	WRef<PhysicsWorld3D> _world;
	WRef<Node3D> _node;
	uint64_t _handle;
	Vec3 _desiredVelocity;
	mutable Vec3 _velocity;
	mutable Vec3 _groundNormal;
	mutable uint8_t _groundState;
	uint8_t _collisionLayer;
	uint32_t _collisionMask;
	friend class PhysicsWorld3D;
	friend class Object;
	DORA_TYPE_OVERRIDE(CharacterController3D);
};

class PhysicsShape3D : public Object {
public:
	virtual ~PhysicsShape3D();
	PROPERTY_READONLY_BOOL(Built);
	bool addChild(NotNull<PhysicsShape3D, 1> shape, const Vec3& position, const Vec3& eulerAngles);
	bool addChild(NotNull<PhysicsShape3D, 1> shape, const Vec3& position);
	bool build();
	virtual void cleanup() override;
	static PhysicsShape3D* createBox(const Vec3& halfExtent);
	static PhysicsShape3D* createSphere(float radius);
	static PhysicsShape3D* createCapsule(float halfHeight, float radius);
	static PhysicsShape3D* createCompound();
	static void loadMeshAsync(String filename, const std::function<void(PhysicsShape3D*)>& handler);
	static void loadConvexHullAsync(String filename, const std::function<void(PhysicsShape3D*)>& handler);

protected:
	PhysicsShape3D(uint64_t handle, bool built);

private:
	void clearPhysics();
	uint64_t _handle;
	bool _built;
	std::vector<Ref<PhysicsShape3D>> _children;
	friend class PhysicsWorld3D;
	friend class PhysicsShape3DCache;
	friend class Object;
	DORA_TYPE_OVERRIDE(PhysicsShape3D);
};

class Constraint3D : public Object {
public:
	virtual ~Constraint3D();
	PROPERTY_READONLY(PhysicsWorld3D*, PhysicsWorld);
	PROPERTY_READONLY(Body3D*, FirstBody);
	PROPERTY_READONLY(Body3D*, SecondBody);
	void destroy();
	virtual void cleanup() override;

protected:
	Constraint3D(NotNull<PhysicsWorld3D, 1> world, NotNull<Body3D, 2> firstBody, NotNull<Body3D, 3> secondBody, uint64_t handle);

private:
	void clearPhysics();
	bool references(Body3D* body) const;
	WRef<PhysicsWorld3D> _world;
	WRef<Body3D> _firstBody;
	WRef<Body3D> _secondBody;
	uint64_t _handle;
	friend class PhysicsWorld3D;
	friend class Object;
	DORA_TYPE_OVERRIDE(Constraint3D);
};

class PhysicsWorld3D : public Node {
public:
	static constexpr uint8_t Static = s_cast<uint8_t>(BodyType3D::Static);
	static constexpr uint8_t Kinematic = s_cast<uint8_t>(BodyType3D::Kinematic);
	static constexpr uint8_t Dynamic = s_cast<uint8_t>(BodyType3D::Dynamic);
	virtual ~PhysicsWorld3D();
	PROPERTY_CREF(Vec3, Gravity);
	Body3D* createBox(NotNull<Node3D, 1> node, const Vec3& halfExtent, BodyType3D type = BodyType3D::Dynamic);
	Body3D* createBox(NotNull<Node3D, 1> node, const Vec3& halfExtent, uint8_t type);
	Body3D* createSphere(NotNull<Node3D, 1> node, float radius, BodyType3D type = BodyType3D::Dynamic);
	Body3D* createSphere(NotNull<Node3D, 1> node, float radius, uint8_t type);
	Body3D* createCapsule(NotNull<Node3D, 1> node, float halfHeight, float radius, BodyType3D type = BodyType3D::Dynamic);
	Body3D* createCapsule(NotNull<Node3D, 1> node, float halfHeight, float radius, uint8_t type);
	Body3D* makeBox(NotNull<Node3D, 1> node, const Vec3& halfExtent, uint8_t type);
	Body3D* makeSphere(NotNull<Node3D, 1> node, float radius, uint8_t type);
	Body3D* makeCapsule(NotNull<Node3D, 1> node, float halfHeight, float radius, uint8_t type);
	Body3D* createBody(NotNull<Node3D, 1> node, NotNull<PhysicsShape3D, 2> shape, BodyType3D type = BodyType3D::Dynamic);
	Body3D* createBody(NotNull<Node3D, 1> node, NotNull<PhysicsShape3D, 2> shape, uint8_t type);
	Body3D* makeBody(NotNull<Node3D, 1> node, NotNull<PhysicsShape3D, 2> shape, uint8_t type);
	CharacterController3D* createCharacter(NotNull<Node3D, 1> node, float halfHeight, float radius, float maxSlopeAngle = 50.0f, float stepHeight = 0.4f);
	CharacterController3D* makeCharacter(NotNull<Node3D, 1> node, float halfHeight, float radius, float maxSlopeAngle, float stepHeight);
	Constraint3D* createFixedConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& anchor);
	Constraint3D* createDistanceConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& firstAnchor, const Vec3& secondAnchor, float minDistance, float maxDistance);
	Constraint3D* createHingeConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& anchor, const Vec3& axis, float minAngle = -180.0f, float maxAngle = 180.0f);
	Constraint3D* makeFixedConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& anchor);
	Constraint3D* makeDistanceConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& firstAnchor, const Vec3& secondAnchor, float minDistance, float maxDistance);
	Constraint3D* makeHingeConstraint(NotNull<Body3D, 1> firstBody, NotNull<Body3D, 2> secondBody, const Vec3& anchor, const Vec3& axis, float minAngle, float maxAngle);
	void destroyBody(NotNull<Body3D, 1> body);
	void destroyCharacter(NotNull<CharacterController3D, 1> character);
	void destroyConstraint(NotNull<Constraint3D, 1> constraint);
	bool raycast(const Vec3& origin, const Vec3& direction, float distance, const std::function<bool(Body3D*, const Vec3&, const Vec3&, float)>& callback);
	bool overlapSphere(const Vec3& center, float radius, const std::function<bool(Body3D*)>& callback);
	virtual bool init() override;
	virtual bool fixedUpdate(double deltaTime) override;
	virtual void render() override;
	virtual void cleanup() override;
	virtual void setShowDebug(bool var) override;
	CREATE_FUNC_NOT_NULL(PhysicsWorld3D);

protected:
	PhysicsWorld3D();

private:
	Body3D* addBody(Node3D* node, BodyType3D type, uint64_t handle);
	Constraint3D* addConstraint(Body3D* firstBody, Body3D* secondBody, uint64_t handle);
	void destroyConstraintsFor(Body3D* body);
	Body3D* getBody(uint64_t handle) const;
	void dispatchContacts();
	void queueDebugBounds();
	void clearPhysics();
	uint64_t _handle;
	Vec3 _gravity;
	std::vector<Ref<Body3D>> _bodies;
	std::unordered_map<uint64_t, Body3D*> _bodyMap;
	std::vector<Ref<CharacterController3D>> _characters;
	std::vector<Ref<Constraint3D>> _constraints;
	friend class Body3D;
	friend class CharacterController3D;
	friend class Constraint3D;
	DORA_TYPE_OVERRIDE(PhysicsWorld3D);
};

class PhysicsWorld : public Node {
public:
	virtual ~PhysicsWorld();
	PROPERTY_READONLY(pd::World*, PrWorld);

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
	virtual void cleanup() override;
	virtual void setShowDebug(bool var) override;

	void setFixtureData(pr::ShapeID fixture, Sensor* sensor);
	Sensor* getFixtureData(pr::ShapeID fixture) const;

	void setBodyData(pr::BodyID b, Body* body);
	Body* getBodyData(pr::BodyID body) const;

	void setJointData(pr::JointID j, Joint* joint);
	Joint* getJointData(pr::JointID joint) const;

	/**
	 Use this rect query at any time without worrying physics engine callback limits.
	 */
	bool query(const Rect& rect, const std::function<bool(Body*)>& callback);
	bool raycast(const Vec2& start, const Vec2& end, bool closest, const std::function<bool(Body*, const Vec2&, const Vec2&)>& callback);
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	bool getShouldContact(uint8_t groupA, uint8_t groupB) const;
	const pr::Filter& getFilter(uint8_t group) const;
	static inline float Val(pr::Real value) { return float(value) * scaleFactor; }
	static inline Vec2 Val(const pr::Vec2& value) { return Vec2{value[0] * scaleFactor, value[1] * scaleFactor}; }
	static inline Vec2 Val(const Vec2& value) { return value * scaleFactor; }
	static inline pr::Real prVal(float value) { return pr::Real(value / scaleFactor); }
	static inline Vec2 prVal(const pr::Vec2& value) { return Vec2{value[0] / scaleFactor, value[1] / scaleFactor}; }
	static inline Vec2 prVal(const Vec2& value) { return value / scaleFactor; }
	/**
	 scaleFactor is used for converting PlayRho meters value to pixel value.
	 Default 100.0f is a good value since PlayRho can well simulate real life objects
	 between 0.1 to 10 meters. Use value 100.0f we can simulate game objects
	 between 10 to 1000 pixels that suites most games.
	 Better change this value before any physics body creation.
	 */
	static float scaleFactor;
	enum { TotalGroups = sizeof(pr::Filter::bits_type) * 8 };
	CREATE_FUNC_NOT_NULL(PhysicsWorld);

protected:
	PhysicsWorld();

private:
	void setupBeginContact();
	void setupEndContact();
	void setupPreSolve();
	void solveContacts();
	void clearPhysics();
	std::vector<Body*> _queryResultsOfCommonShapes;
	std::vector<Body*> _queryResultsOfChainsAndEdges;

private:
	struct RayCastData {
		RayCastData()
			: body(nullptr)
			, point{}
			, normal{} { }
		Body* body;
		Vec2 point;
		Vec2 normal;
	} _rayCastResult;
	std::vector<RayCastData> _rayCastResults;

protected:
	Own<DebugDraw> _debugDraw;

private:
	pr::Filter _filters[TotalGroups];
	Own<pd::World> _world;
	pr::StepConf _stepConf;

	struct SensorPair {
		WRef<Body> owner;
		WRef<Sensor> sensor;
		WRef<Body> body;
	};
	struct ContactPair {
		WRef<Body> bodyA;
		WRef<Body> bodyB;
		Vec2 point;
		Vec2 normal;
		bool enabled = true;
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

NS_DORA_END
