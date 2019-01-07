/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/Joint.h"
#include "Physics/JointDef.h"
#include "Physics/Body.h"
#include "Physics/PhysicsWorld.h"
#include "Physics/Sensor.h"

NS_DOROTHY_BEGIN

Joint::~Joint()
{
	Joint::destroy();
}

b2Joint* Joint::getB2Joint()
{
	return _joint;
}

PhysicsWorld* Joint::getWorld()
{
	return _world;
}

void Joint::destroy()
{
	if (_world && _joint)
	{
		_world->getB2World()->DestroyJoint(_joint);
		_world = nullptr;
		_joint = nullptr;
	}
}

Joint* Joint::create(JointDef* def, Dictionary* itemDict)
{
	return def->toJoint(itemDict);
}

Joint* Joint::distance(
	bool collideConnected,
	Body* bodyA, Body* bodyB,
	const Vec2& anchorA, const Vec2& anchorB,
	float frequency, float damping)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	b2Body* bA = bodyA->getB2Body();
	b2Body* bB = bodyB->getB2Body();
	b2Vec2 aA = PhysicsWorld::b2Val(anchorA);
	b2Vec2 aB = PhysicsWorld::b2Val(anchorB);
	b2DistanceJointDef jointDef;
	jointDef.Initialize(bA, bB,
		bA->GetWorldPoint(aA),
		bB->GetWorldPoint(aB));
	jointDef.frequencyHz = frequency;
	jointDef.dampingRatio = damping;
	jointDef.collideConnected = collideConnected;
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

Joint* Joint::friction(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& worldAnchor,
	float maxForce,
	float maxTorque)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	b2Body* bA = bodyA->getB2Body();
	b2Body* bB = bodyB->getB2Body();
	b2Vec2 a = PhysicsWorld::b2Val(worldAnchor);
	b2FrictionJointDef jointDef;
	jointDef.Initialize(bA, bB, a);
	jointDef.maxForce = maxForce;
	jointDef.maxTorque = maxTorque;
	jointDef.collideConnected = collideConnected;
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

Joint* Joint::gear(
	bool collideConnected,
	Joint* jointA,
	Joint* jointB,
	float ratio)
{
	if (jointA->getWorld() != jointA->getWorld())
	{
		return nullptr;
	}
	b2GearJointDef jointDef;
	jointDef.joint1 = jointA->getB2Joint();
	jointDef.joint2 = jointB->getB2Joint();
	jointDef.bodyA = jointDef.joint1->GetBodyB();
	jointDef.bodyB = jointDef.joint2->GetBodyB();
	jointDef.ratio = ratio;
	jointDef.collideConnected = collideConnected;
	Joint* joint = Joint::create();
	joint->_world = jointA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

Joint* Joint::spring(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	Vec2 linearOffset,
	float angularOffset,
	float maxForce,
	float maxTorque,
	float correctionFactor)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	b2Body* bA = bodyA->getB2Body();
	b2Body* bB = bodyB->getB2Body();
	b2MotorJointDef jointDef;
	jointDef.Initialize(bA, bB);
	jointDef.linearOffset = PhysicsWorld::b2Val(linearOffset);
	jointDef.angularOffset = -bx::toRad(angularOffset);
	jointDef.maxForce = maxForce;
	jointDef.maxTorque = maxTorque;
	jointDef.correctionFactor = correctionFactor;
	jointDef.collideConnected = collideConnected;
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

MoveJoint* Joint::move(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& target,
	float maxForce,
	float frequency,
	float damping)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	b2Body* bA = bodyA->getB2Body();
	b2Body* bB = bodyB->getB2Body();
	b2MouseJointDef jointDef;
	jointDef.bodyA = bA;
	jointDef.bodyB = bB;
	jointDef.target = PhysicsWorld::b2Val(target);
	jointDef.maxForce = maxForce;
	jointDef.frequencyHz = frequency;
	jointDef.dampingRatio = damping;
	jointDef.collideConnected = collideConnected;
	MoveJoint* joint = MoveJoint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

MotorJoint* Joint::prismatic(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& worldAnchor,
	const Vec2& axis,
	float lowerTranslation,
	float upperTranslation,
	float maxMotorForce,
	float motorSpeed)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	b2Body* bA = bodyA->getB2Body();
	b2Body* bB = bodyB->getB2Body();
	b2Vec2 a = PhysicsWorld::b2Val(worldAnchor);
	b2PrismaticJointDef jointDef;
	jointDef.Initialize(bA, bB, a, axis);
	jointDef.lowerTranslation = PhysicsWorld::b2Val(lowerTranslation);
	jointDef.upperTranslation = PhysicsWorld::b2Val(upperTranslation);
	jointDef.enableLimit = (lowerTranslation || upperTranslation) && (lowerTranslation <= upperTranslation);
	jointDef.maxMotorForce = maxMotorForce;
	jointDef.motorSpeed = motorSpeed;
	jointDef.collideConnected = collideConnected;
	MotorJoint* joint = MotorJoint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

Joint* Joint::pulley(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& anchorA,
	const Vec2& anchorB,
	const Vec2& groundAnchorA,
	const Vec2& groundAnchorB,
	float32 ratio)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	b2Body* bA = bodyA->getB2Body();
	b2Body* bB = bodyB->getB2Body();
	b2Vec2 aA = PhysicsWorld::b2Val(anchorA);
	b2Vec2 aB = PhysicsWorld::b2Val(anchorB);
	aA = bA->GetWorldPoint(aA);
	aB = bB->GetWorldPoint(aB);
	b2Vec2 gA = PhysicsWorld::b2Val(groundAnchorA);
	b2Vec2 gB = PhysicsWorld::b2Val(groundAnchorB);
	b2PulleyJointDef jointDef;
	jointDef.Initialize(bA, bB, gA, gB, aA, aB, ratio);
	jointDef.collideConnected = collideConnected;
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

MotorJoint* Joint::revolute(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& worldPos,
	float lowerAngle,
	float upperAngle,
	float maxMotorTorque,
	float motorSpeed)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	b2Body* bA = bodyA->getB2Body();
	b2Body* bB = bodyB->getB2Body();
	b2Vec2 a = PhysicsWorld::b2Val(worldPos);
	lowerAngle = -bx::toRad(lowerAngle);
	upperAngle = -bx::toRad(upperAngle);
	motorSpeed = -bx::toRad(motorSpeed);
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(bA, bB, a);
	jointDef.lowerAngle = upperAngle;
	jointDef.upperAngle = lowerAngle;
	jointDef.enableLimit = (lowerAngle || upperAngle) && (lowerAngle >= upperAngle);
	jointDef.maxMotorTorque = maxMotorTorque;
	jointDef.motorSpeed = motorSpeed;
	jointDef.collideConnected = collideConnected;
	MotorJoint* joint = MotorJoint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

Joint* Joint::rope(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& anchorA,
	const Vec2& anchorB,
	float maxLength)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	b2Body* bA = bodyA->getB2Body();
	b2Body* bB = bodyB->getB2Body();
	b2Vec2 aA = PhysicsWorld::b2Val(anchorA);
	b2Vec2 aB = PhysicsWorld::b2Val(anchorB);
	b2RopeJointDef jointDef;
	jointDef.bodyA = bA;
	jointDef.bodyB = bB;
	jointDef.localAnchorA = aA;
	jointDef.localAnchorB = aB;
	jointDef.maxLength = PhysicsWorld::b2Val(maxLength);
	jointDef.collideConnected = collideConnected;
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

Joint* Joint::weld(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& worldPos,
	float frequency,
	float damping)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	b2Body* bA = bodyA->getB2Body();
	b2Body* bB = bodyB->getB2Body();
	b2Vec2 a = PhysicsWorld::b2Val(worldPos);
	b2WeldJointDef jointDef;
	jointDef.Initialize(bA, bB, a);
	jointDef.frequencyHz = frequency;
	jointDef.dampingRatio = damping;
	jointDef.collideConnected = collideConnected;
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

MotorJoint* Joint::wheel(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& worldPos,
	const Vec2& axis,
	float maxMotorTorque,
	float motorSpeed,
	float frequency,
	float damping)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	b2Body* bA = bodyA->getB2Body();
	b2Body* bB = bodyB->getB2Body();
	b2Vec2 a = PhysicsWorld::b2Val(worldPos);
	b2WheelJointDef jointDef;
	jointDef.Initialize(bA, bB, a, axis);
	jointDef.maxMotorTorque = maxMotorTorque;
	jointDef.motorSpeed = PhysicsWorld::b2Val(motorSpeed);
	jointDef.frequencyHz = frequency;
	jointDef.dampingRatio = damping;
	jointDef.collideConnected = collideConnected;
	MotorJoint* joint = MotorJoint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getB2World()->CreateJoint(&jointDef);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

void MoveJoint::setPosition(const Vec2& targetPos)
{
	if (!_joint) return;
	_position = targetPos;
	b2MouseJoint* joint = (b2MouseJoint*)_joint;
	joint->SetTarget(PhysicsWorld::b2Val(targetPos));
}

const Vec2& MoveJoint::getPosition() const
{
	return _position;
}

void MotorJoint::setEnabled(bool var)
{
	if (!_joint) return;
	switch (_joint->GetType())
	{
	case e_prismaticJoint:
		((b2PrismaticJoint*)_joint)->EnableMotor(var);
		break;
	case e_revoluteJoint:
		((b2RevoluteJoint*)_joint)->EnableMotor(var);
		break;
	case e_wheelJoint:
		((b2WheelJoint*)_joint)->EnableMotor(var);
		break;
    default:
        break;
	}
}

bool MotorJoint::isEnabled() const
{
	if (!_joint) return false;
	switch (_joint->GetType())
	{
	case e_prismaticJoint:
		return ((b2PrismaticJoint*)_joint)->IsMotorEnabled();
	case e_revoluteJoint:
		return ((b2RevoluteJoint*)_joint)->IsMotorEnabled();
	case e_wheelJoint:
		return ((b2WheelJoint*)_joint)->IsMotorEnabled();
    default:
        break;

	}
	return false;
}

void MotorJoint::setForce(float var)
{
	if (!_joint) return;
	var = std::max(var, 0.0f);
	switch (_joint->GetType())
	{
	case e_prismaticJoint:
		((b2PrismaticJoint*)_joint)->SetMaxMotorForce(var);
		break;
	case e_revoluteJoint:
		((b2RevoluteJoint*)_joint)->SetMaxMotorTorque(var);
		break;
	case e_wheelJoint:
		((b2WheelJoint*)_joint)->SetMaxMotorTorque(var);
        break;
    default:
        break;
	}
}

float MotorJoint::getForce() const
{
	if (!_joint) return 0.0f;
	switch (_joint->GetType())
	{
	case e_prismaticJoint:
		return ((b2PrismaticJoint*)_joint)->GetMaxMotorForce();
	case e_revoluteJoint:
		return ((b2RevoluteJoint*)_joint)->GetMaxMotorTorque();
	case e_wheelJoint:
		return ((b2WheelJoint*)_joint)->GetMaxMotorTorque();
    default:
		return 0.0f;
	}
}

void MotorJoint::setSpeed(float var)
{
	if (!_joint) return;
	var = -bx::toRad(var);
	switch (_joint->GetType())
	{
	case e_prismaticJoint:
		((b2PrismaticJoint*)_joint)->SetMotorSpeed(var);
		break;
	case e_revoluteJoint:
		((b2RevoluteJoint*)_joint)->SetMotorSpeed(var);
		break;
	case e_wheelJoint:
		((b2WheelJoint*)_joint)->SetMotorSpeed(var);
        break;
    default:
        break;
	}
}

float MotorJoint::getSpeed() const
{
	if (!_joint) return 0.0f;
	float speed = 0.0f;
	switch (_joint->GetType())
	{
	case e_prismaticJoint:
		speed = ((b2PrismaticJoint*)_joint)->GetMotorSpeed();
	case e_revoluteJoint:
		speed = ((b2RevoluteJoint*)_joint)->GetMotorSpeed();
	case e_wheelJoint:
		speed = ((b2WheelJoint*)_joint)->GetMotorSpeed();
    default:
        break;
	}
	return -bx::toDeg(speed);
}

void MotorJoint::reversePower()
{
	MotorJoint::setSpeed(-MotorJoint::getSpeed());
}

NS_DOROTHY_END
