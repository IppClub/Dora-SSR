/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Support/Geometry.h"

struct b2JointDef;

NS_DORA_BEGIN

class Joint;
class Dictionary;

class JointDef : public Object {
public:
	Vec2 center;
	Vec2 position;
	float angle;
	JointDef();
	static JointDef* distance(
		bool collision,
		String bodyA,
		String bodyB,
		const Vec2& anchorA,
		const Vec2& anchorB,
		float frequency = 0.0f,
		float damping = 0.0f);
	static JointDef* friction(
		bool collision,
		String bodyA,
		String bodyB,
		const Vec2& worldPos,
		float maxForce,
		float maxTorque);
	static JointDef* gear(
		bool collision,
		String jointA,
		String jointB,
		float ratio = 1.0f);
	static JointDef* spring(
		bool collision,
		String bodyA,
		String bodyB,
		const Vec2& linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor = 1.0f);
	static JointDef* prismatic(
		bool collision,
		String bodyA,
		String bodyB,
		const Vec2& worldPos,
		float axisAngle,
		float lowerTranslation = 0.0f,
		float upperTranslation = 0.0f,
		float maxMotorForce = 0.0f,
		float motorSpeed = 0.0f);
	static JointDef* pulley(
		bool collision,
		String bodyA,
		String bodyB,
		const Vec2& anchorA,
		const Vec2& anchorB,
		const Vec2& groundAnchorA,
		const Vec2& groundAnchorB,
		float ratio = 1.0f);
	static JointDef* revolute(
		bool collision,
		String bodyA,
		String bodyB,
		const Vec2& worldPos,
		float lowerAngle = 0.0f,
		float upperAngle = 0.0f,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f);
	static JointDef* rope(
		bool collision,
		String bodyA,
		String bodyB,
		const Vec2& anchorA,
		const Vec2& anchorB,
		float maxLength);
	static JointDef* weld(
		bool collision,
		String bodyA,
		String bodyB,
		const Vec2& worldPos,
		float frequency = 0.0f,
		float damping = 0.0f);
	static JointDef* wheel(
		bool collision,
		String bodyA,
		String bodyB,
		const Vec2& worldPos,
		float axisAngle,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f,
		float frequency = 2.0f,
		float damping = 0.7f);
	virtual Joint* toJoint(Dictionary* itemDict) = 0;

protected:
	Vec2 r(const Vec2& target);
	Vec2 t(const Vec2& target);
	DORA_TYPE_OVERRIDE(JointDef);
};

class DistanceDef : public JointDef {
public:
	bool collision;
	std::string bodyA;
	std::string bodyB;
	Vec2 anchorA;
	Vec2 anchorB;
	float frequency;
	float damping;
	virtual Joint* toJoint(Dictionary* itemDict) override;
};

class FrictionDef : public JointDef {
public:
	bool collision;
	std::string bodyA;
	std::string bodyB;
	Vec2 worldPos;
	float maxForce;
	float maxTorque;
	virtual Joint* toJoint(Dictionary* itemDict) override;
};

class GearDef : public JointDef {
public:
	bool collision;
	std::string jointA;
	std::string jointB;
	float ratio;
	virtual Joint* toJoint(Dictionary* itemDict) override;
};

class SpringDef : public JointDef {
public:
	bool collision;
	std::string bodyA;
	std::string bodyB;
	Vec2 linearOffset;
	float angularOffset;
	float maxForce;
	float maxTorque;
	float correctionFactor;
	virtual Joint* toJoint(Dictionary* itemDict) override;
};

class PrismaticDef : public JointDef {
public:
	bool collision;
	std::string bodyA;
	std::string bodyB;
	Vec2 worldPos;
	float axisAngle;
	float lowerTranslation;
	float upperTranslation;
	float maxMotorForce;
	float motorSpeed;
	virtual Joint* toJoint(Dictionary* itemDict) override;
};

class PulleyDef : public JointDef {
public:
	bool collision;
	std::string bodyA;
	std::string bodyB;
	Vec2 anchorA;
	Vec2 anchorB;
	Vec2 groundAnchorA;
	Vec2 groundAnchorB;
	float ratio;
	virtual Joint* toJoint(Dictionary* itemDict) override;
};

class RevoluteDef : public JointDef {
public:
	bool collision;
	std::string bodyA;
	std::string bodyB;
	Vec2 worldPos;
	float lowerAngle;
	float upperAngle;
	float maxMotorTorque;
	float motorSpeed;
	virtual Joint* toJoint(Dictionary* itemDict) override;
};

class RopeDef : public JointDef {
public:
	bool collision;
	std::string bodyA;
	std::string bodyB;
	Vec2 anchorA;
	Vec2 anchorB;
	float maxLength;
	virtual Joint* toJoint(Dictionary* itemDict) override;
};

class WeldDef : public JointDef {
public:
	bool collision;
	std::string bodyA;
	std::string bodyB;
	Vec2 worldPos;
	float frequency;
	float damping;
	virtual Joint* toJoint(Dictionary* itemDict) override;
};

class WheelDef : public JointDef {
public:
	bool collision;
	std::string bodyA;
	std::string bodyB;
	Vec2 worldPos;
	float axisAngle;
	float maxMotorTorque;
	float motorSpeed;
	float frequency;
	float damping;
	virtual Joint* toJoint(Dictionary* itemDict) override;
};

NS_DORA_END
