/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Physics/JointDef.h"
#include "Physics/Joint.h"
#include "Physics/Body.h"
#include "Support/Dictionary.h"

NS_DOROTHY_BEGIN

JointDef::JointDef(): angle(0) { }

JointDef* JointDef::distance(
	bool collision,
	String bodyA,
	String bodyB,
	const Vec2& anchorA,
	const Vec2& anchorB,
	float frequency,
	float damping)
{
	DistanceDef* def = new DistanceDef();
	def->collision = collision;
	def->bodyA = bodyA;
	def->bodyB = bodyB;
	def->anchorA = anchorA;
	def->anchorB = anchorB;
	def->frequency = frequency;
	def->damping = damping;
	def->autorelease();
	return def;
}

JointDef* JointDef::friction(
	bool collision,
	String bodyA,
	String bodyB,
	const Vec2& worldPos,
	float maxForce,
	float maxTorque)
{
	FrictionDef* def = new FrictionDef();
	def->collision = collision;
	def->bodyA = bodyA;
	def->bodyB = bodyB;
	def->worldPos = worldPos;
	def->maxForce = maxForce;
	def->maxTorque = maxTorque;
	def->autorelease();
	return def;
}

JointDef* JointDef::gear(
	bool collision,
	String jointA,
	String jointB,
	float ratio)
{
	GearDef* def = new GearDef();
	def->collision = collision;
	def->jointA = jointA;
	def->jointB = jointB;
	def->ratio = ratio;
	def->autorelease();
	return def;
}

JointDef* JointDef::spring(
	bool collision,
	String bodyA,
	String bodyB,
	const Vec2& linearOffset,
	float angularOffset,
	float maxForce,
	float maxTorque,
	float correctionFactor)
{
	SpringDef* def = new SpringDef();
	def->collision = collision;
	def->bodyA = bodyA;
	def->bodyB = bodyB;
	def->linearOffset = linearOffset;
	def->angularOffset = angularOffset;
	def->maxForce = maxForce;
	def->maxTorque = maxTorque;
	def->correctionFactor = correctionFactor;
	def->autorelease();
	return def;
}

JointDef* JointDef::prismatic(
	bool collision,
	String bodyA,
	String bodyB,
	const Vec2& worldPos,
	float axisAngle,
	float lowerTranslation,
	float upperTranslation,
	float maxMotorForce,
	float motorSpeed)
{
	PrismaticDef* def = new PrismaticDef();
	def->collision = collision;
	def->bodyA = bodyA;
	def->bodyB = bodyB;
	def->worldPos = worldPos;
	def->axisAngle = axisAngle;
	def->lowerTranslation = lowerTranslation;
	def->upperTranslation = upperTranslation;
	def->maxMotorForce = maxMotorForce;
	def->motorSpeed = motorSpeed;
	def->autorelease();
	return def;
}

JointDef* JointDef::pulley(
	bool collision,
	String bodyA,
	String bodyB,
	const Vec2& anchorA,
	const Vec2& anchorB,
	const Vec2& groundAnchorA,
	const Vec2& groundAnchorB,
	float ratio)
{
	PulleyDef* def = new PulleyDef();
	def->collision = collision;
	def->bodyA = bodyA;
	def->bodyB = bodyB;
	def->anchorA = anchorA;
	def->anchorB = anchorB;
	def->groundAnchorA = groundAnchorA;
	def->groundAnchorB = groundAnchorB;
	def->ratio = ratio;
	def->autorelease();
	return def;
}

JointDef* JointDef::revolute(
	bool collision,
	String bodyA,
	String bodyB,
	const Vec2& worldPos,
	float lowerAngle,
	float upperAngle,
	float maxMotorTorque,
	float motorSpeed)
{
	RevoluteDef* def = new RevoluteDef();
	def->collision = collision;
	def->bodyA = bodyA;
	def->bodyB = bodyB;
	def->worldPos = worldPos;
	def->lowerAngle = lowerAngle;
	def->upperAngle = upperAngle;
	def->maxMotorTorque = maxMotorTorque;
	def->motorSpeed = motorSpeed;
	def->autorelease();
	return def;
}

JointDef* JointDef::rope(
	bool collision,
	String bodyA,
	String bodyB,
	const Vec2& anchorA,
	const Vec2& anchorB,
	float maxLength)
{
	RopeDef* def = new RopeDef();
	def->collision = collision;
	def->bodyA = bodyA;
	def->bodyB = bodyB;
	def->anchorA = anchorA;
	def->anchorB = anchorB;
	def->maxLength = maxLength;
	def->autorelease();
	return def;
}

JointDef* JointDef::weld(
	bool collision,
	String bodyA,
	String bodyB,
	const Vec2& worldPos,
	float frequency,
	float damping)
{
	WeldDef* def = new WeldDef();
	def->collision = collision;
	def->bodyA = bodyA;
	def->bodyB = bodyB;
	def->worldPos = worldPos;
	def->frequency = frequency;
	def->damping = damping;
	def->autorelease();
	return def;
}

JointDef* JointDef::wheel(
	bool collision,
	String bodyA,
	String bodyB,
	const Vec2& worldPos,
	float axisAngle,
	float maxMotorTorque,
	float motorSpeed,
	float frequency,
	float damping)
{
	WheelDef* def = new WheelDef();
	def->collision = collision;
	def->bodyA = bodyA;
	def->bodyB = bodyB;
	def->worldPos = worldPos;
	def->axisAngle = axisAngle;
	def->maxMotorTorque = maxMotorTorque;
	def->motorSpeed = motorSpeed;
	def->frequency = frequency;
	def->damping = damping;
	def->autorelease();
	return def;
}

Vec2 JointDef::r(const Vec2& target)
{
	if (angle)
	{
		float realAngle = -bx::toRad(angle) + std::atan2(target.y, target.x);
		float length = target.length();
		return Vec2{length * std::cos(realAngle), length * std::sin(realAngle)};
	}
	return target;
}

Vec2 JointDef::t(const Vec2& target)
{
	Vec2 pos = target - center;
	return r(pos) + position;
}

Joint* DistanceDef::toJoint(Dictionary* itemDict)
{
	Body* targetA = DoraCast<Body>(itemDict->get(bodyA).get());
	Body* targetB = DoraCast<Body>(itemDict->get(bodyB).get());
	if (targetA && targetB)
	{
		return Joint::distance(collision, targetA, targetB, anchorA, anchorB, frequency, damping);
	}
	return nullptr;
}

Joint* FrictionDef::toJoint(Dictionary* itemDict)
{
	Body* targetA = DoraCast<Body>(itemDict->get(bodyA).get());
	Body* targetB = DoraCast<Body>(itemDict->get(bodyB).get());
	if (targetA && targetB)
	{
		return Joint::friction(collision, targetA, targetB, t(worldPos), maxForce, maxTorque);
	}
	return nullptr;
}

Joint* GearDef::toJoint(Dictionary* itemDict)
{
	Joint* targetA = DoraCast<Joint>(itemDict->get(jointA).get());
	Joint* targetB = DoraCast<Joint>(itemDict->get(jointB).get());
	if (targetA && targetB)
	{
		return Joint::gear(collision, targetA, targetB, ratio);
	}
	return nullptr;
}

Joint* SpringDef::toJoint(Dictionary* itemDict)
{
	Body* targetA = DoraCast<Body>(itemDict->get(bodyA).get());
	Body* targetB = DoraCast<Body>(itemDict->get(bodyB).get());
	if (targetA && targetB)
	{
		return Joint::spring(collision, targetA, targetB, linearOffset, angularOffset, maxForce, maxTorque, correctionFactor);
	}
	return nullptr;
}

Joint* PrismaticDef::toJoint(Dictionary* itemDict)
{
	Body* targetA = DoraCast<Body>(itemDict->get(bodyA).get());
	Body* targetB = DoraCast<Body>(itemDict->get(bodyB).get());
	if (targetA && targetB)
	{
		return Joint::prismatic(collision, targetA, targetB, t(worldPos), axisAngle, lowerTranslation, upperTranslation, maxMotorForce, motorSpeed);
	}
	return nullptr;
}

Joint* PulleyDef::toJoint(Dictionary* itemDict)
{
	Body* targetA = DoraCast<Body>(itemDict->get(bodyA).get());
	Body* targetB = DoraCast<Body>(itemDict->get(bodyB).get());
	if (targetA && targetB)
	{
		return Joint::pulley(collision, targetA, targetB, anchorA, anchorB, t(groundAnchorA), t(groundAnchorB), ratio);
	}
	return nullptr;
}

Joint* RevoluteDef::toJoint(Dictionary* itemDict)
{
	Body* targetA = DoraCast<Body>(itemDict->get(bodyA).get());
	Body* targetB = DoraCast<Body>(itemDict->get(bodyB).get());
	if (targetA && targetB)
	{
		return Joint::revolute(collision, targetA, targetB, t(worldPos), lowerAngle + angle, upperAngle + angle, maxMotorTorque, motorSpeed);
	}
	return nullptr;
}

Joint* RopeDef::toJoint(Dictionary* itemDict)
{
	Body* targetA = DoraCast<Body>(itemDict->get(bodyA).get());
	Body* targetB = DoraCast<Body>(itemDict->get(bodyB).get());
	if (targetA && targetB)
	{
		return Joint::rope(collision, targetA, targetB, anchorA, anchorB, maxLength);
	}
	return nullptr;
}

Joint* WeldDef::toJoint(Dictionary* itemDict)
{
	Body* targetA = DoraCast<Body>(itemDict->get(bodyA).get());
	Body* targetB = DoraCast<Body>(itemDict->get(bodyB).get());
	if (targetA && targetB)
	{
		return Joint::weld(collision, targetA, targetB, t(worldPos), frequency, damping);
	}
	return nullptr;
}

Joint* WheelDef::toJoint(Dictionary* itemDict)
{
	Body* targetA = DoraCast<Body>(itemDict->get(bodyA).get());
	Body* targetB = DoraCast<Body>(itemDict->get(bodyB).get());
	if (targetA && targetB)
	{
		return Joint::wheel(collision, targetA, targetB, t(worldPos), axisAngle, maxMotorTorque, motorSpeed, frequency, damping);
	}
	return nullptr;
}

NS_DOROTHY_END
