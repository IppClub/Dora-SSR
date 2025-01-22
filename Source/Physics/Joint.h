/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

NS_DORA_BEGIN

namespace pr = playrho;
namespace pd = playrho::d2;

class Body;
class PhysicsWorld;
class JointDef;
class MoveJoint;
class MotorJoint;
class Dictionary;

class Joint : public Object {
public:
	virtual ~Joint();
	static Joint* distance(
		bool collideConnected,
		Body* bodyA,
		Body* bodyB,
		const Vec2& anchorA,
		const Vec2& anchorB,
		float frequency = 0.0f,
		float damping = 0.0f);
	static Joint* friction(
		bool collideConnected,
		Body* bodyA,
		Body* bodyB,
		const Vec2& worldPos,
		float maxForce,
		float maxTorque);
	static Joint* gear(
		bool collideConnected,
		Joint* jointA,
		Joint* jointB,
		float ratio = 1.0f);
	static Joint* spring(
		bool collideConnected,
		Body* bodyA,
		Body* bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor = 1.0f);
	static MoveJoint* move(
		bool collideConnected,
		Body* body,
		const Vec2& targetPos,
		float maxForce,
		float frequency = 5.0f,
		float damping = 0.7f);
	static MotorJoint* prismatic(
		bool collideConnected,
		Body* bodyA,
		Body* bodyB,
		const Vec2& worldPos,
		float axisAngle,
		float lowerTranslation = 0.0f,
		float upperTranslation = 0.0f,
		float maxMotorForce = 0.0f,
		float motorSpeed = 0.0f);
	static Joint* pulley(
		bool collideConnected,
		Body* bodyA,
		Body* bodyB,
		const Vec2& anchorA,
		const Vec2& anchorB,
		const Vec2& groundAnchorA,
		const Vec2& groundAnchorB,
		float ratio = 1.0f);
	static MotorJoint* revolute(
		bool collideConnected,
		Body* bodyA,
		Body* bodyB,
		const Vec2& worldPos,
		float lowerAngle = 0.0f,
		float upperAngle = 0.0f,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f);
	static Joint* rope(
		bool collideConnected,
		Body* bodyA,
		Body* bodyB,
		const Vec2& anchorA,
		const Vec2& anchorB,
		float maxLength);
	static Joint* weld(
		bool collideConnected,
		Body* bodyA,
		Body* bodyB,
		const Vec2& worldPos,
		float frequency = 0.0f,
		float damping = 0.0f);
	static MotorJoint* wheel(
		bool collideConnected,
		Body* bodyA,
		Body* bodyB,
		const Vec2& worldPos,
		float axisAngle,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f,
		float frequency = 2.0f,
		float damping = 0.7f);
	pr::JointID getPrJoint();
	PhysicsWorld* getPhysicsWorld();
	void destroy();
	static Joint* create(NotNull<JointDef, 1> def, NotNull<Dictionary, 2> itemDict);
	static Joint* create();

protected:
	Joint()
		: _joint(pr::InvalidJointID) { }

protected:
	WRef<PhysicsWorld> _world;
	pr::JointID _joint;
	friend class DestructionListener;
	friend class Object;
	DORA_TYPE_OVERRIDE(Joint);
};

class MoveJoint : public Joint {
public:
	PROPERTY_CREF(Vec2, Position);
	CREATE_FUNC_NOT_NULL(MoveJoint);

protected:
	MoveJoint()
		: _position(Vec2::zero) { }

private:
	Vec2 _position;
	DORA_TYPE_OVERRIDE(MoveJoint);
};

class MotorJoint : public Joint {
public:
	PROPERTY(float, Force);
	PROPERTY(float, Speed);
	PROPERTY_BOOL(Enabled);
	void reversePower();
	CREATE_FUNC_NOT_NULL(MotorJoint);
	DORA_TYPE_OVERRIDE(MotorJoint);
};

NS_DORA_END
