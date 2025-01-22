/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Physics/Joint.h"

#include "Physics/Body.h"
#include "Physics/JointDef.h"
#include "Physics/PhysicsWorld.h"
#include "Physics/Sensor.h"
#include "playrho/d2/Joint.hpp"

NS_DORA_BEGIN

Joint::~Joint() {
	Joint::destroy();
}

pr::JointID Joint::getPrJoint() {
	return _joint;
}

PhysicsWorld* Joint::getPhysicsWorld() {
	return _world;
}

void Joint::destroy() {
	if (_world && _world->getPrWorld() && pr::IsValid(_joint)) {
		pd::Destroy(*_world->getPrWorld(), _joint);
		_world->setJointData(_joint, nullptr);
		_world = nullptr;
		_joint = pr::InvalidJointID;
	}
}

Joint* Joint::create(NotNull<JointDef, 1> def, NotNull<Dictionary, 2> itemDict) {
	return def->toJoint(itemDict);
}

Joint* Joint::create() {
	return Object::createNotNull<Joint>();
}

Joint* Joint::distance(
	bool collideConnected,
	Body* bodyA, Body* bodyB,
	const Vec2& anchorA, const Vec2& anchorB,
	float frequency, float damping) {
	if (bodyA->getPhysicsWorld() != bodyB->getPhysicsWorld()) {
		return nullptr;
	}
	pr::BodyID bA = bodyA->getPrBody();
	pr::BodyID bB = bodyB->getPrBody();
	pr::Vec2 aA = PhysicsWorld::prVal(anchorA);
	pr::Vec2 aB = PhysicsWorld::prVal(anchorB);
	auto world = bodyA->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	Joint* joint = Joint::create();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld,
		pd::DistanceJointConf{
			bA, bB,
			pd::GetWorldPoint(prWorld, bA, aA),
			pd::GetWorldPoint(prWorld, bB, aB)}
			.UseCollideConnected(collideConnected)
			.UseFrequency(frequency)
			.UseDampingRatio(damping));
	joint->_world->setJointData(joint->_joint, joint);
	return joint;
}

Joint* Joint::friction(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& worldAnchor,
	float maxForce,
	float maxTorque) {
	if (bodyA->getPhysicsWorld() != bodyB->getPhysicsWorld()) {
		return nullptr;
	}
	pr::BodyID bA = bodyA->getPrBody();
	pr::BodyID bB = bodyB->getPrBody();
	pr::Vec2 a = PhysicsWorld::prVal(worldAnchor);
	auto world = bodyA->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	Joint* joint = Joint::create();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld,
		pd::FrictionJointConf{bA, bB, a}
			.UseMaxForce(maxForce)
			.UseMaxTorque(maxTorque)
			.UseCollideConnected(collideConnected));
	joint->_world->setJointData(joint->_joint, joint);
	return joint;
}

Joint* Joint::gear(
	bool collideConnected,
	Joint* jointA,
	Joint* jointB,
	float ratio) {
	if (jointA->getPhysicsWorld() != jointA->getPhysicsWorld()) {
		return nullptr;
	}
	pr::JointID jA = jointA->getPrJoint();
	pr::JointID jB = jointB->getPrJoint();
	auto world = jointA->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	Joint* joint = Joint::create();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld,
		pd::GetGearJointConf(prWorld, jA, jB, ratio)
			.UseCollideConnected(collideConnected));
	joint->_world->setJointData(joint->_joint, joint);
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
	float correctionFactor) {
	if (bodyA->getPhysicsWorld() != bodyB->getPhysicsWorld()) {
		return nullptr;
	}
	pr::BodyID bA = bodyA->getPrBody();
	pr::BodyID bB = bodyB->getPrBody();
	auto world = bodyA->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	Joint* joint = Joint::create();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld,
		pd::MotorJointConf{bA, bB}
			.UseLinearOffset(PhysicsWorld::prVal(linearOffset))
			.UseAngularOffset(-bx::toRad(angularOffset))
			.UseMaxForce(maxForce)
			.UseMaxTorque(maxTorque)
			.UseCorrectionFactor(correctionFactor)
			.UseCollideConnected(collideConnected));
	world->setJointData(joint->_joint, joint);
	return joint;
}

MoveJoint* Joint::move(
	bool collideConnected,
	Body* body,
	const Vec2& target,
	float maxForce,
	float frequency,
	float damping) {
	pr::BodyID b = body->getPrBody();
	MoveJoint* joint = MoveJoint::create();
	auto world = body->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld,
		pd::TargetJointConf{b}
			.UseTarget(PhysicsWorld::prVal(target))
			.UseFrequency(frequency)
			.UseMaxForce(maxForce)
			.UseDampingRatio(damping)
			.UseCollideConnected(collideConnected));
	world->setJointData(joint->_joint, joint);
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
	float motorSpeed) {
	if (bodyA->getPhysicsWorld() != bodyB->getPhysicsWorld()) {
		return nullptr;
	}
	pr::BodyID bA = bodyA->getPrBody();
	pr::BodyID bB = bodyB->getPrBody();
	auto world = bodyA->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	pr::Vec2 a = PhysicsWorld::prVal(worldAnchor);
	pd::PrismaticJointConf conf = pd::GetPrismaticJointConf(prWorld,
		bA, bB, a, pd::UnitVec::Get(-bx::toRad(axisAngle)))
									  .UseLowerLength(PhysicsWorld::prVal(lowerTranslation))
									  .UseUpperLength(PhysicsWorld::prVal(upperTranslation))
									  .UseEnableLimit((lowerTranslation || upperTranslation) && (lowerTranslation <= upperTranslation))
									  .UseCollideConnected(collideConnected);
	conf.maxMotorForce = maxMotorForce;
	conf.motorSpeed = motorSpeed;
	MotorJoint* joint = MotorJoint::create();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld, conf);
	world->setJointData(joint->_joint, joint);
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
	float ratio) {
	if (bodyA->getPhysicsWorld() != bodyB->getPhysicsWorld()) {
		return nullptr;
	}
	pr::BodyID bA = bodyA->getPrBody();
	pr::BodyID bB = bodyB->getPrBody();
	auto world = bodyA->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	pr::Vec2 aA = pd::GetWorldPoint(prWorld, bA, PhysicsWorld::prVal(anchorA));
	pr::Vec2 aB = pd::GetWorldPoint(prWorld, bB, PhysicsWorld::prVal(anchorB));
	pr::Vec2 gA = PhysicsWorld::prVal(groundAnchorA);
	pr::Vec2 gB = PhysicsWorld::prVal(groundAnchorB);
	Joint* joint = Joint::create();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld,
		pd::PulleyJointConf{bA, bB, gA, gB, aA, aB}
			.UseRatio(ratio)
			.UseCollideConnected(collideConnected));
	world->setJointData(joint->_joint, joint);
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
	float motorSpeed) {
	if (bodyA->getPhysicsWorld() != bodyB->getPhysicsWorld()) {
		return nullptr;
	}
	pr::BodyID bA = bodyA->getPrBody();
	pr::BodyID bB = bodyB->getPrBody();
	pr::Vec2 a = PhysicsWorld::prVal(worldPos);
	lowerAngle = -bx::toRad(lowerAngle);
	upperAngle = -bx::toRad(upperAngle);
	motorSpeed = -bx::toRad(motorSpeed);
	auto world = bodyA->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	pd::RevoluteJointConf conf = pd::RevoluteJointConf{bA, bB, a}
									 .UseLowerAngle(-bx::toRad(lowerAngle))
									 .UseUpperAngle(-bx::toRad(upperAngle))
									 .UseEnableLimit((lowerAngle || upperAngle) && (lowerAngle >= upperAngle))
									 .UseCollideConnected(collideConnected);
	conf.maxMotorTorque = maxMotorTorque;
	conf.motorSpeed = motorSpeed;
	MotorJoint* joint = MotorJoint::create();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld, conf);
	world->setJointData(joint->_joint, joint);
	return joint;
}

Joint* Joint::rope(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& anchorA,
	const Vec2& anchorB,
	float maxLength) {
	if (bodyA->getPhysicsWorld() != bodyB->getPhysicsWorld()) {
		return nullptr;
	}
	pr::BodyID bA = bodyA->getPrBody();
	pr::BodyID bB = bodyB->getPrBody();
	pr::Vec2 aA = PhysicsWorld::prVal(anchorA);
	pr::Vec2 aB = PhysicsWorld::prVal(anchorB);
	auto world = bodyA->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	pd::RopeJointConf conf{bA, bB};
	conf.localAnchorA = aA;
	conf.localAnchorB = aB;
	conf.maxLength = PhysicsWorld::prVal(maxLength);
	conf.UseCollideConnected(collideConnected);
	Joint* joint = Joint::create();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld, conf);
	world->setJointData(joint->_joint, joint);
	return joint;
}

Joint* Joint::weld(
	bool collideConnected,
	Body* bodyA,
	Body* bodyB,
	const Vec2& worldPos,
	float frequency,
	float damping) {
	if (bodyA->getPhysicsWorld() != bodyB->getPhysicsWorld()) {
		return nullptr;
	}
	pr::BodyID bA = bodyA->getPrBody();
	pr::BodyID bB = bodyB->getPrBody();
	pr::Vec2 a = PhysicsWorld::prVal(worldPos);
	auto world = bodyA->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	Joint* joint = Joint::create();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld,
		pd::WeldJointConf{bA, bB, a}
			.UseFrequency(frequency)
			.UseDampingRatio(damping)
			.UseCollideConnected(collideConnected));
	world->setJointData(joint->_joint, joint);
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
	float damping) {
	if (bodyA->getPhysicsWorld() != bodyB->getPhysicsWorld()) {
		return nullptr;
	}
	pr::BodyID bA = bodyA->getPrBody();
	pr::BodyID bB = bodyB->getPrBody();
	pr::Vec2 a = PhysicsWorld::prVal(worldPos);
	auto world = bodyA->getPhysicsWorld();
	if (!world || !world->getPrWorld()) {
		return nullptr;
	}
	auto& prWorld = *world->getPrWorld();
	MotorJoint* joint = MotorJoint::create();
	joint->_world = world;
	joint->_joint = pd::CreateJoint(prWorld,
		pd::GetWheelJointConf(prWorld, bA, bB, a, pd::UnitVec::Get(-bx::toRad(axisAngle)))
			.UseDampingRatio(damping)
			.UseFrequency(frequency)
			.UseMotorSpeed(PhysicsWorld::prVal(motorSpeed))
			.UseMaxMotorTorque(maxMotorTorque)
			.UseCollideConnected(collideConnected));
	world->setJointData(joint->_joint, joint);
	return joint;
}

void MoveJoint::setPosition(const Vec2& targetPos) {
	if (_joint == pr::InvalidJointID) return;
	if (!_world || !_world->getPrWorld()) {
		return;
	}
	_position = targetPos;
	pd::SetTarget(*_world->getPrWorld(), _joint, PhysicsWorld::prVal(targetPos));
}

const Vec2& MoveJoint::getPosition() const noexcept {
	return _position;
}

void MotorJoint::setEnabled(bool var) {
	if (_joint == pr::InvalidJointID) return;
	if (!_world || !_world->getPrWorld()) {
		return;
	}
	pd::EnableMotor(*_world->getPrWorld(), _joint, var);
}

bool MotorJoint::isEnabled() const noexcept {
	if (_joint == pr::InvalidJointID) return false;
	if (!_world || !_world->getPrWorld()) {
		return false;
	}
	return pd::IsMotorEnabled(*_world->getPrWorld(), _joint);
}

void MotorJoint::setForce(float var) {
	if (_joint == pr::InvalidJointID) return;
	if (!_world || !_world->getPrWorld()) {
		return;
	}
	var = std::max(var, 0.0f);
	auto& world = *_world->getPrWorld();
	auto joint = pd::GetJoint(world, _joint);
	pd::SetMaxMotorForce(joint, var);
	pd::SetJoint(world, _joint, joint);
}

float MotorJoint::getForce() const noexcept {
	if (_joint == pr::InvalidJointID) return 0.0f;
	if (!_world || !_world->getPrWorld()) {
		return 0.0f;
	}
	auto& world = *_world->getPrWorld();
	return pd::GetMaxMotorForce(pd::GetJoint(world, _joint));
}

void MotorJoint::setSpeed(float var) {
	if (_joint == pr::InvalidJointID) return;
	if (!_world || !_world->getPrWorld()) {
		return;
	}
	pd::SetMotorSpeed(*_world->getPrWorld(), _joint, var);
}

float MotorJoint::getSpeed() const noexcept {
	if (_joint == pr::InvalidJointID) return 0.0f;
	if (!_world || !_world->getPrWorld()) {
		return 0.0f;
	}
	return pd::GetMotorSpeed(*_world->getPrWorld(), _joint);
}

void MotorJoint::reversePower() {
	MotorJoint::setSpeed(-MotorJoint::getSpeed());
}

NS_DORA_END
