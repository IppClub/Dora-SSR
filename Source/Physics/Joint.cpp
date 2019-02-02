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

pd::Joint* Joint::getPrJoint()
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
		_world->getPrWorld()->Destroy(_joint);
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
	pd::Body* bA = bodyA->getPrBody();
	pd::Body* bB = bodyB->getPrBody();
	pr::Vec2 aA = PhysicsWorld::b2Val(anchorA);
	pr::Vec2 aB = PhysicsWorld::b2Val(anchorB);
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(
		pd::DistanceJointConf{
			bA, bB,
			pd::GetWorldPoint(*bA, aA),
			pd::GetWorldPoint(*bB, aB)
		}
		.UseCollideConnected(collideConnected)
		.UseFrequency(frequency)
		.UseDampingRatio(damping)
	);
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
	pd::Body* bA = bodyA->getPrBody();
	pd::Body* bB = bodyB->getPrBody();
	pr::Vec2 a = PhysicsWorld::b2Val(worldAnchor);
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(
		pd::FrictionJointConf{bA, bB, a}
			.UseMaxForce(maxForce)
			.UseMaxTorque(maxTorque)
			.UseCollideConnected(collideConnected)
	);
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
	pd::Joint* jA = jointA->getPrJoint();
	pd::Joint* jB = jointB->getPrJoint();
	Joint* joint = Joint::create();
	joint->_world = jointA->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(
		pd::GearJointConf{jA, jB}
			.UseBodyA(jA->GetBodyB())
			.UseBodyB(jB->GetBodyB())
			.UseRatio(ratio)
			.UseCollideConnected(collideConnected)
	);
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
	pd::Body* bA = bodyA->getPrBody();
	pd::Body* bB = bodyB->getPrBody();
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(
		pd::MotorJointConf{bA, bB}
			.UseLinearOffset(PhysicsWorld::b2Val(linearOffset))
			.UseAngularOffset(-bx::toRad(angularOffset))
			.UseMaxForce(maxForce)
			.UseMaxTorque(maxTorque)
			.UseCorrectionFactor(correctionFactor)
			.UseCollideConnected(collideConnected)
	);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

MoveJoint* Joint::move(
	bool collideConnected,
	Body* body,
	const Vec2& target,
	float maxForce,
	float frequency,
	float damping)
{
	pd::Body* b = body->getPrBody();
	MoveJoint* joint = MoveJoint::create();
	joint->_world = body->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(
		pd::TargetJointConf{b}
			.UseTarget(PhysicsWorld::b2Val(target))
			.UseFrequency(frequency)
			.UseMaxForce(maxForce)
			.UseDampingRatio(damping)
			.UseCollideConnected(collideConnected)
	);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

MotorJoint* Joint::prismatic(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& worldAnchor,
	float axisAngle,
	float lowerTranslation,
	float upperTranslation,
	float maxMotorForce,
	float motorSpeed)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	pd::Body* bA = bodyA->getPrBody();
	pd::Body* bB = bodyB->getPrBody();
	pr::Vec2 a = PhysicsWorld::b2Val(worldAnchor);
	pd::PrismaticJointConf conf = pd::PrismaticJointConf{bA, bB, a, pd::UnitVec::Get(-bx::toRad(axisAngle))}
		.UseLowerTranslation(PhysicsWorld::b2Val(lowerTranslation))
		.UseUpperTranslation(PhysicsWorld::b2Val(upperTranslation))
		.UseEnableLimit((lowerTranslation || upperTranslation) && (lowerTranslation <= upperTranslation))
		.UseCollideConnected(collideConnected);
	conf.maxMotorForce = maxMotorForce;
	conf.motorSpeed = motorSpeed;
	MotorJoint* joint = MotorJoint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(conf);
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
	float ratio)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	pd::Body* bA = bodyA->getPrBody();
	pd::Body* bB = bodyB->getPrBody();
	pr::Vec2 aA = pd::GetWorldPoint(*bA, PhysicsWorld::b2Val(anchorA));
	pr::Vec2 aB = pd::GetWorldPoint(*bB, PhysicsWorld::b2Val(anchorB));
	pr::Vec2 gA = PhysicsWorld::b2Val(groundAnchorA);
	pr::Vec2 gB = PhysicsWorld::b2Val(groundAnchorB);
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(
		pd::PulleyJointConf{bA, bB, gA, gB, aA, aB}
			.UseRatio(ratio)
			.UseCollideConnected(collideConnected)
	);
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
	pd::Body* bA = bodyA->getPrBody();
	pd::Body* bB = bodyB->getPrBody();
	pr::Vec2 a = PhysicsWorld::b2Val(worldPos);
	lowerAngle = -bx::toRad(lowerAngle);
	upperAngle = -bx::toRad(upperAngle);
	motorSpeed = -bx::toRad(motorSpeed);
	pd::RevoluteJointConf conf = pd::RevoluteJointConf{bA, bB, a}
		.UseLowerAngle(-bx::toRad(lowerAngle))
		.UseUpperAngle(-bx::toRad(upperAngle))
		.UseEnableLimit((lowerAngle || upperAngle) && (lowerAngle >= upperAngle))
		.UseCollideConnected(collideConnected);
	conf.maxMotorTorque = maxMotorTorque;
	conf.motorSpeed = motorSpeed;
	MotorJoint* joint = MotorJoint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(conf);
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
	pd::Body* bA = bodyA->getPrBody();
	pd::Body* bB = bodyB->getPrBody();
	pr::Vec2 aA = PhysicsWorld::b2Val(anchorA);
	pr::Vec2 aB = PhysicsWorld::b2Val(anchorB);
	pd::RopeJointConf conf{bA, bB};
	conf.localAnchorA = aA;
	conf.localAnchorB = aB;
	conf.maxLength = PhysicsWorld::b2Val(maxLength);
	conf.UseCollideConnected(collideConnected);
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(conf);
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
	pd::Body* bA = bodyA->getPrBody();
	pd::Body* bB = bodyB->getPrBody();
	pr::Vec2 a = PhysicsWorld::b2Val(worldPos);
	Joint* joint = Joint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(
		pd::WeldJointConf{bA, bB, a}
			.UseFrequency(frequency)
			.UseDampingRatio(damping)
			.UseCollideConnected(collideConnected)
	);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

MotorJoint* Joint::wheel(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& worldPos,
	float axisAngle,
	float maxMotorTorque,
	float motorSpeed,
	float frequency,
	float damping)
{
	if (bodyA->getWorld() != bodyB->getWorld())
	{
		return nullptr;
	}
	pd::Body* bA = bodyA->getPrBody();
	pd::Body* bB = bodyB->getPrBody();
	pr::Vec2 a = PhysicsWorld::b2Val(worldPos);
	MotorJoint* joint = MotorJoint::create();
	joint->_world = bodyA->getWorld();
	joint->_joint = joint->_world->getPrWorld()->CreateJoint(
		pd::WheelJointConf{bA, bB, a, pd::UnitVec::Get(-bx::toRad(axisAngle))}
			.UseDampingRatio(damping)
			.UseFrequency(frequency)
			.UseMotorSpeed(PhysicsWorld::b2Val(motorSpeed))
			.UseMaxMotorTorque(maxMotorTorque)
			.UseCollideConnected(collideConnected)
	);
	joint->_joint->SetUserData(r_cast<void*>(joint));
	return joint;
}

void MoveJoint::setPosition(const Vec2& targetPos)
{
	if (!_joint) return;
	_position = targetPos;
	pd::TargetJoint* joint = s_cast<pd::TargetJoint*>(_joint);
	joint->SetTarget(PhysicsWorld::b2Val(targetPos));
}

const Vec2& MoveJoint::getPosition() const
{
	return _position;
}

void MotorJoint::setEnabled(bool var)
{
	if (!_joint) return;
	switch (pd::GetType(*_joint))
	{
	case pd::JointType::Prismatic:
		s_cast<pd::PrismaticJoint*>(_joint)->EnableMotor(var);
		break;
	case pd::JointType::Revolute:
		s_cast<pd::RevoluteJoint*>(_joint)->EnableMotor(var);
		break;
	case pd::JointType::Wheel:
		s_cast<pd::WheelJoint*>(_joint)->EnableMotor(var);
		break;
    default:
        break;
	}
}

bool MotorJoint::isEnabled() const
{
	if (!_joint) return false;
	switch (pd::GetType(*_joint))
	{
	case pd::JointType::Prismatic:
		return s_cast<pd::PrismaticJoint*>(_joint)->IsMotorEnabled();
	case pd::JointType::Revolute:
		return s_cast<pd::RevoluteJoint*>(_joint)->IsMotorEnabled();
	case pd::JointType::Wheel:
		return s_cast<pd::WheelJoint*>(_joint)->IsMotorEnabled();
    default:
		return false;
	}
}

void MotorJoint::setForce(float var)
{
	if (!_joint) return;
	var = std::max(var, 0.0f);
	switch (pd::GetType(*_joint))
	{
	case pd::JointType::Prismatic:
		s_cast<pd::PrismaticJoint*>(_joint)->SetMaxMotorForce(var);
		break;
	case pd::JointType::Revolute:
		s_cast<pd::RevoluteJoint*>(_joint)->SetMaxMotorTorque(var);
		break;
	case pd::JointType::Wheel:
		s_cast<pd::WheelJoint*>(_joint)->SetMaxMotorTorque(var);
		break;
    default:
        break;
	}
}

float MotorJoint::getForce() const
{
	if (!_joint) return 0.0f;
	switch (pd::GetType(*_joint))
	{
	case pd::JointType::Prismatic:
		return s_cast<pd::PrismaticJoint*>(_joint)->GetMaxMotorForce();
	case pd::JointType::Revolute:
		return s_cast<pd::RevoluteJoint*>(_joint)->GetMaxMotorTorque();
	case pd::JointType::Wheel:
		return s_cast<pd::WheelJoint*>(_joint)->GetMaxMotorTorque();
    default:
        return 0.0f;
	}
}

void MotorJoint::setSpeed(float var)
{
	if (!_joint) return;
	switch (pd::GetType(*_joint))
	{
	case pd::JointType::Prismatic:
		s_cast<pd::PrismaticJoint*>(_joint)->SetMotorSpeed(var);
		break;
	case pd::JointType::Revolute:
		s_cast<pd::RevoluteJoint*>(_joint)->SetMotorSpeed(-bx::toRad(var));
		break;
	case pd::JointType::Wheel:
		s_cast<pd::WheelJoint*>(_joint)->SetMotorSpeed(-bx::toRad(var));
		break;
    default:
        break;
	}
}

float MotorJoint::getSpeed() const
{
	if (!_joint) return 0.0f;
	switch (pd::GetType(*_joint))
	{
	case pd::JointType::Prismatic:
		return s_cast<pd::PrismaticJoint*>(_joint)->GetMotorSpeed();
	case pd::JointType::Revolute:
		return -bx::toDeg(s_cast<pd::RevoluteJoint*>(_joint)->GetMotorSpeed());
	case pd::JointType::Wheel:
		return -bx::toDeg(s_cast<pd::WheelJoint*>(_joint)->GetMotorSpeed());
    default:
        return 0.0f;
	}
}

void MotorJoint::reversePower()
{
	MotorJoint::setSpeed(-MotorJoint::getSpeed());
}

NS_DOROTHY_END
