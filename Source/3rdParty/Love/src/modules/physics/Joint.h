/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 **/

#ifndef LOVE_PHYSICS_JOINT_H
#define LOVE_PHYSICS_JOINT_H

// LOVE
#include "common/Object.h"
#include "common/StringMap.h"

struct lua_State;

namespace love
{
namespace physics
{

class Joint : public Object
{
public:

	static love::Type type;

	enum Type
	{
		JOINT_INVALID,
		JOINT_DISTANCE,
		JOINT_REVOLUTE,
		JOINT_PRISMATIC,
		JOINT_MOUSE,
		JOINT_PULLEY,
		JOINT_GEAR,
		JOINT_FRICTION,
		JOINT_WELD,
		JOINT_WHEEL,
		JOINT_ROPE,
		JOINT_MOTOR,
		JOINT_MAX_ENUM
	};

	enum class ScalarProperty
	{
		Length, Frequency, DampingRatio, JointAngle, JointSpeed,
		MaxMotorTorque, MotorSpeed, MotorTorque, LowerLimit, UpperLimit,
		ReferenceAngle, JointTranslation, MaxMotorForce, MotorForce,
		MaxForce, MaxTorque, MaxLength, LengthA, LengthB, Ratio,
		SpringFrequency, SpringDampingRatio, AngularOffset, CorrectionFactor,
	};

	enum class BooleanProperty
	{
		MotorEnabled, LimitsEnabled,
	};

	enum class VectorProperty
	{
		Axis, Target, LinearOffset,
	};


	virtual ~Joint();
	virtual Type getType() const = 0;
	virtual bool isValid() const = 0;
	virtual class Body *getBodyA() const = 0;
	virtual class Body *getBodyB() const = 0;
	virtual int getAnchors(lua_State *L) const = 0;
	virtual int getReactionForce(lua_State *L) const = 0;
	virtual float getReactionTorque(float inverseDeltaTime) const = 0;
	virtual bool getCollideConnected() const = 0;
	virtual int setUserData(lua_State *L) = 0;
	virtual int getUserData(lua_State *L) = 0;
	virtual void destroyJoint() = 0;
	virtual float getScalar(ScalarProperty property, float argument = 0.0f) const = 0;
	virtual void setScalar(ScalarProperty property, float value) = 0;
	virtual bool getBoolean(BooleanProperty property) const = 0;
	virtual void setBoolean(BooleanProperty property, bool value) = 0;
	virtual void getVector(VectorProperty property, float &x, float &y) const = 0;
	virtual void setVector(VectorProperty property, float x, float y) = 0;
	virtual void getLimits(float &lower, float &upper) const = 0;
	virtual void setLimits(float lower, float upper) = 0;
	virtual int getGroundAnchors(lua_State *L) const = 0;
	virtual void getJoints(Joint *&jointA, Joint *&jointB) const = 0;

	static bool getConstant(const char *in, Type &out);
	static bool getConstant(Type in, const char  *&out);

private:

	static StringMap<Type, JOINT_MAX_ENUM>::Entry typeEntries[];
	static StringMap<Type, JOINT_MAX_ENUM> types;
};

} // physics
} // love

#endif // LOVE_PHYSICS_JOINT_H
