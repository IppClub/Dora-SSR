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

#include "wrap_Joint.h"
#include "Body.h"

#include <cmath>

namespace love
{
namespace physics
{

Joint *luax_checkjoint(lua_State *L, int idx)
{
	Joint *joint = luax_checktype<Joint>(L, idx);
	if (!joint->isValid())
		luaL_error(L, "Attempt to use destroyed joint.");
	return joint;
}

int w_Joint_getType(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	Joint::Type value = Joint::JOINT_INVALID;
	luax_catchexcept(L, [&]() { value = joint->getType(); });
	const char *name = "";
	Joint::getConstant(value, name);
	lua_pushstring(L, name);
	return 1;
}

int w_Joint_getBodies(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	Body *bodyA = nullptr;
	Body *bodyB = nullptr;
	luax_catchexcept(L, [&]() {
		bodyA = joint->getBodyA();
		bodyB = joint->getBodyB();
	});
	luax_pushtype(L, bodyA);
	luax_pushtype(L, bodyB);
	return 2;
}

int w_Joint_getAnchors(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	lua_remove(L, 1);
	int result = 0;
	luax_catchexcept(L, [&]() { result = joint->getAnchors(L); });
	return result;
}

int w_Joint_getReactionForce(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	lua_remove(L, 1);
	int result = 0;
	luax_catchexcept(L, [&]() { result = joint->getReactionForce(L); });
	return result;
}

int w_Joint_getReactionTorque(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	const float inverseDeltaTime = (float) luaL_checknumber(L, 2);
	float value = 0.0f;
	luax_catchexcept(L, [&]() { value = joint->getReactionTorque(inverseDeltaTime); });
	lua_pushnumber(L, value);
	return 1;
}

int w_Joint_getCollideConnected(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	bool value = false;
	luax_catchexcept(L, [&]() { value = joint->getCollideConnected(); });
	luax_pushboolean(L, value);
	return 1;
}

int w_Joint_setUserData(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	lua_remove(L, 1);
	int result = 0;
	luax_catchexcept(L, [&]() { result = joint->setUserData(L); });
	return result;
}

int w_Joint_getUserData(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	lua_remove(L, 1);
	int result = 0;
	luax_catchexcept(L, [&]() { result = joint->getUserData(L); });
	return result;
}

int w_Joint_destroy(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	luax_catchexcept(L, [&]() { joint->destroyJoint(); });
	return 0;
}

int w_Joint_isDestroyed(lua_State *L)
{
	Joint *joint = luax_checktype<Joint>(L, 1);
	luax_pushboolean(L, !joint->isValid());
	return 1;
}

using Scalar = Joint::ScalarProperty;
using Boolean = Joint::BooleanProperty;
using Vector = Joint::VectorProperty;

static float checkFinite(lua_State *L, int index, const char *message)
{
	const float value = (float) luaL_checknumber(L, index);
	luaL_argcheck(L, std::isfinite(value), index, message);
	return value;
}

static float checkNonNegative(lua_State *L, int index, const char *message)
{
	const float value = checkFinite(L, index, message);
	luaL_argcheck(L, value >= 0.0f, index, message);
	return value;
}

static int getScalar(lua_State *L, Scalar property, bool hasArgument = false)
{
	Joint *joint = luax_checkjoint(L, 1);
	const float argument = hasArgument
		? checkNonNegative(L, 2, "inverse delta time must be finite and non-negative") : 0.0f;
	float value = 0.0f;
	luax_catchexcept(L, [&]() { value = joint->getScalar(property, argument); });
	lua_pushnumber(L, value);
	return 1;
}

static int setScalar(lua_State *L, Scalar property, float value)
{
	Joint *joint = luax_checkjoint(L, 1);
	luax_catchexcept(L, [&]() { joint->setScalar(property, value); });
	return 0;
}

int w_Joint_getLength(lua_State *L) { return getScalar(L, Scalar::Length); }
int w_Joint_setLength(lua_State *L) { return setScalar(L, Scalar::Length,
	checkNonNegative(L, 2, "length must be finite and non-negative")); }
int w_Joint_getFrequency(lua_State *L) { return getScalar(L, Scalar::Frequency); }
int w_Joint_setFrequency(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	const float value = checkFinite(L, 2, "frequency must be finite");
	const bool positive = joint->getType() == Joint::JOINT_MOUSE;
	luaL_argcheck(L, positive ? value > 0.0f : value >= 0.0f, 2,
		positive ? "frequency must be finite and positive"
			: "frequency must be finite and non-negative");
	luax_catchexcept(L, [&]() { joint->setScalar(Scalar::Frequency, value); });
	return 0;
}
int w_Joint_getDampingRatio(lua_State *L) { return getScalar(L, Scalar::DampingRatio); }
int w_Joint_setDampingRatio(lua_State *L) { return setScalar(L, Scalar::DampingRatio,
	checkNonNegative(L, 2, "damping ratio must be finite and non-negative")); }
int w_Joint_getJointAngle(lua_State *L) { return getScalar(L, Scalar::JointAngle); }
int w_Joint_getJointSpeed(lua_State *L) { return getScalar(L, Scalar::JointSpeed); }

int w_Joint_setMotorEnabled(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	luaL_checktype(L, 2, LUA_TBOOLEAN);
	luax_catchexcept(L, [&]() { joint->setBoolean(Boolean::MotorEnabled,
		lua_toboolean(L, 2) != 0); });
	return 0;
}
int w_Joint_isMotorEnabled(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	bool value = false;
	luax_catchexcept(L, [&]() { value = joint->getBoolean(Boolean::MotorEnabled); });
	luax_pushboolean(L, value);
	return 1;
}
int w_Joint_setMaxMotorTorque(lua_State *L) { return setScalar(L, Scalar::MaxMotorTorque,
	checkNonNegative(L, 2, "maximum motor torque must be finite and non-negative")); }
int w_Joint_getMaxMotorTorque(lua_State *L) { return getScalar(L, Scalar::MaxMotorTorque); }
int w_Joint_setMotorSpeed(lua_State *L) { return setScalar(L, Scalar::MotorSpeed,
	checkFinite(L, 2, "motor speed must be finite")); }
int w_Joint_getMotorSpeed(lua_State *L) { return getScalar(L, Scalar::MotorSpeed); }
int w_Joint_getMotorTorque(lua_State *L) { return getScalar(L, Scalar::MotorTorque, true); }

int w_Joint_setLimitsEnabled(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	luaL_checktype(L, 2, LUA_TBOOLEAN);
	luax_catchexcept(L, [&]() { joint->setBoolean(Boolean::LimitsEnabled,
		lua_toboolean(L, 2) != 0); });
	return 0;
}
int w_Joint_areLimitsEnabled(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	bool value = false;
	luax_catchexcept(L, [&]() { value = joint->getBoolean(Boolean::LimitsEnabled); });
	luax_pushboolean(L, value);
	return 1;
}
int w_Joint_setLimits(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	const float lower = checkFinite(L, 2, "limits must be finite");
	const float upper = checkFinite(L, 3, "limits must be finite");
	luaL_argcheck(L, lower <= upper, 2, "lower limit must not exceed upper limit");
	luax_catchexcept(L, [&]() { joint->setLimits(lower, upper); });
	return 0;
}
int w_Joint_setUpperLimit(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	const float value = checkFinite(L, 2, "upper limit must be finite");
	float lower = 0.0f, upper = 0.0f;
	luax_catchexcept(L, [&]() { joint->getLimits(lower, upper); });
	luaL_argcheck(L, lower <= value, 2, "upper limit must not be below lower limit");
	luax_catchexcept(L, [&]() { joint->setLimits(lower, value); });
	return 0;
}
int w_Joint_setLowerLimit(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	const float value = checkFinite(L, 2, "lower limit must be finite");
	float lower = 0.0f, upper = 0.0f;
	luax_catchexcept(L, [&]() { joint->getLimits(lower, upper); });
	luaL_argcheck(L, value <= upper, 2, "lower limit must not exceed upper limit");
	luax_catchexcept(L, [&]() { joint->setLimits(value, upper); });
	return 0;
}
int w_Joint_getLowerLimit(lua_State *L) { return getScalar(L, Scalar::LowerLimit); }
int w_Joint_getUpperLimit(lua_State *L) { return getScalar(L, Scalar::UpperLimit); }
int w_Joint_getLimits(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1);
	float lower = 0.0f, upper = 0.0f;
	luax_catchexcept(L, [&]() { joint->getLimits(lower, upper); });
	lua_pushnumber(L, lower); lua_pushnumber(L, upper);
	return 2;
}
int w_Joint_getReferenceAngle(lua_State *L) { return getScalar(L, Scalar::ReferenceAngle); }
int w_Joint_getJointTranslation(lua_State *L) { return getScalar(L, Scalar::JointTranslation); }
int w_Joint_setMaxMotorForce(lua_State *L) { return setScalar(L, Scalar::MaxMotorForce,
	checkNonNegative(L, 2, "maximum motor force must be finite and non-negative")); }
int w_Joint_getMaxMotorForce(lua_State *L) { return getScalar(L, Scalar::MaxMotorForce); }
int w_Joint_getMotorForce(lua_State *L) { return getScalar(L, Scalar::MotorForce, true); }

int w_Joint_getAxis(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1); float x = 0.0f, y = 0.0f;
	luax_catchexcept(L, [&]() { joint->getVector(Vector::Axis, x, y); });
	lua_pushnumber(L, x); lua_pushnumber(L, y); return 2;
}
int w_Joint_setMaxForce(lua_State *L) { return setScalar(L, Scalar::MaxForce,
	checkNonNegative(L, 2, "maximum force must be finite and non-negative")); }
int w_Joint_getMaxForce(lua_State *L) { return getScalar(L, Scalar::MaxForce); }
int w_Joint_setMaxTorque(lua_State *L) { return setScalar(L, Scalar::MaxTorque,
	checkNonNegative(L, 2, "maximum torque must be finite and non-negative")); }
int w_Joint_getMaxTorque(lua_State *L) { return getScalar(L, Scalar::MaxTorque); }
int w_Joint_getMaxLength(lua_State *L) { return getScalar(L, Scalar::MaxLength); }
int w_Joint_setMaxLength(lua_State *L) { return setScalar(L, Scalar::MaxLength,
	checkNonNegative(L, 2, "maximum length must be finite and non-negative")); }

int w_Joint_getGroundAnchors(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1); int result = 0;
	luax_catchexcept(L, [&]() { result = joint->getGroundAnchors(L); });
	return result;
}
int w_Joint_getLengthA(lua_State *L) { return getScalar(L, Scalar::LengthA); }
int w_Joint_getLengthB(lua_State *L) { return getScalar(L, Scalar::LengthB); }
int w_Joint_getRatio(lua_State *L) { return getScalar(L, Scalar::Ratio); }
int w_Joint_setRatio(lua_State *L) { return setScalar(L, Scalar::Ratio,
	checkFinite(L, 2, "ratio must be finite")); }
int w_Joint_setSpringFrequency(lua_State *L) { return setScalar(L, Scalar::SpringFrequency,
	checkNonNegative(L, 2, "spring frequency must be finite and non-negative")); }
int w_Joint_getSpringFrequency(lua_State *L) { return getScalar(L, Scalar::SpringFrequency); }
int w_Joint_setSpringDampingRatio(lua_State *L) { return setScalar(L,
	Scalar::SpringDampingRatio, checkNonNegative(L, 2,
		"spring damping ratio must be finite and non-negative")); }
int w_Joint_getSpringDampingRatio(lua_State *L) { return getScalar(L, Scalar::SpringDampingRatio); }

static int getVector(lua_State *L, Vector property)
{
	Joint *joint = luax_checkjoint(L, 1); float x = 0.0f, y = 0.0f;
	luax_catchexcept(L, [&]() { joint->getVector(property, x, y); });
	lua_pushnumber(L, x); lua_pushnumber(L, y); return 2;
}
static int setVector(lua_State *L, Vector property, const char *message)
{
	Joint *joint = luax_checkjoint(L, 1);
	const float x = checkFinite(L, 2, message), y = checkFinite(L, 3, message);
	luax_catchexcept(L, [&]() { joint->setVector(property, x, y); });
	return 0;
}
int w_Joint_setTarget(lua_State *L) { return setVector(L, Vector::Target,
	"target coordinates must be finite"); }
int w_Joint_getTarget(lua_State *L) { return getVector(L, Vector::Target); }
int w_Joint_setLinearOffset(lua_State *L) { return setVector(L, Vector::LinearOffset,
	"linear offset must be finite"); }
int w_Joint_getLinearOffset(lua_State *L) { return getVector(L, Vector::LinearOffset); }
int w_Joint_setAngularOffset(lua_State *L) { return setScalar(L, Scalar::AngularOffset,
	checkFinite(L, 2, "angular offset must be finite")); }
int w_Joint_getAngularOffset(lua_State *L) { return getScalar(L, Scalar::AngularOffset); }
int w_Joint_setCorrectionFactor(lua_State *L)
{
	const float value = checkFinite(L, 2, "correction factor must be finite");
	luaL_argcheck(L, value >= 0.0f && value <= 1.0f, 2,
		"correction factor must be between 0 and 1");
	return setScalar(L, Scalar::CorrectionFactor, value);
}
int w_Joint_getCorrectionFactor(lua_State *L) { return getScalar(L, Scalar::CorrectionFactor); }
int w_Joint_getJoints(lua_State *L)
{
	Joint *joint = luax_checkjoint(L, 1), *jointA = nullptr, *jointB = nullptr;
	luax_catchexcept(L, [&]() { joint->getJoints(jointA, jointB); });
	luax_pushtype(L, jointA); luax_pushtype(L, jointB); return 2;
}

static const luaL_Reg functions[] =
{
	{ "getType", w_Joint_getType },
	{ "getBodies", w_Joint_getBodies },
	{ "getAnchors", w_Joint_getAnchors },
	{ "getReactionForce", w_Joint_getReactionForce },
	{ "getReactionTorque", w_Joint_getReactionTorque },
	{ "getCollideConnected", w_Joint_getCollideConnected },
	{ "setUserData", w_Joint_setUserData },
	{ "getUserData", w_Joint_getUserData },
	{ "destroy", w_Joint_destroy },
	{ "isDestroyed", w_Joint_isDestroyed },
	{ "getLength", w_Joint_getLength }, { "setLength", w_Joint_setLength },
	{ "getFrequency", w_Joint_getFrequency }, { "setFrequency", w_Joint_setFrequency },
	{ "getDampingRatio", w_Joint_getDampingRatio }, { "setDampingRatio", w_Joint_setDampingRatio },
	{ "getJointAngle", w_Joint_getJointAngle }, { "getJointSpeed", w_Joint_getJointSpeed },
	{ "setMotorEnabled", w_Joint_setMotorEnabled }, { "isMotorEnabled", w_Joint_isMotorEnabled },
	{ "setMaxMotorTorque", w_Joint_setMaxMotorTorque }, { "getMaxMotorTorque", w_Joint_getMaxMotorTorque },
	{ "setMotorSpeed", w_Joint_setMotorSpeed }, { "getMotorSpeed", w_Joint_getMotorSpeed },
	{ "getMotorTorque", w_Joint_getMotorTorque }, { "setLimitsEnabled", w_Joint_setLimitsEnabled },
	{ "areLimitsEnabled", w_Joint_areLimitsEnabled }, { "hasLimitsEnabled", w_Joint_areLimitsEnabled },
	{ "setUpperLimit", w_Joint_setUpperLimit }, { "setLowerLimit", w_Joint_setLowerLimit },
	{ "setLimits", w_Joint_setLimits }, { "getUpperLimit", w_Joint_getUpperLimit },
	{ "getLowerLimit", w_Joint_getLowerLimit }, { "getLimits", w_Joint_getLimits },
	{ "getReferenceAngle", w_Joint_getReferenceAngle },
	{ "getJointTranslation", w_Joint_getJointTranslation },
	{ "setMaxMotorForce", w_Joint_setMaxMotorForce }, { "getMaxMotorForce", w_Joint_getMaxMotorForce },
	{ "getMotorForce", w_Joint_getMotorForce }, { "getAxis", w_Joint_getAxis },
	{ "setMaxForce", w_Joint_setMaxForce }, { "getMaxForce", w_Joint_getMaxForce },
	{ "setMaxTorque", w_Joint_setMaxTorque }, { "getMaxTorque", w_Joint_getMaxTorque },
	{ "getMaxLength", w_Joint_getMaxLength }, { "setMaxLength", w_Joint_setMaxLength },
	{ "getGroundAnchors", w_Joint_getGroundAnchors }, { "getLengthA", w_Joint_getLengthA },
	{ "getLengthB", w_Joint_getLengthB }, { "getRatio", w_Joint_getRatio },
	{ "setSpringFrequency", w_Joint_setSpringFrequency }, { "getSpringFrequency", w_Joint_getSpringFrequency },
	{ "setSpringDampingRatio", w_Joint_setSpringDampingRatio },
	{ "getSpringDampingRatio", w_Joint_getSpringDampingRatio },
	{ "setTarget", w_Joint_setTarget }, { "getTarget", w_Joint_getTarget },
	{ "setLinearOffset", w_Joint_setLinearOffset }, { "getLinearOffset", w_Joint_getLinearOffset },
	{ "setAngularOffset", w_Joint_setAngularOffset }, { "getAngularOffset", w_Joint_getAngularOffset },
	{ "setCorrectionFactor", w_Joint_setCorrectionFactor },
	{ "getCorrectionFactor", w_Joint_getCorrectionFactor },
	{ "setRatio", w_Joint_setRatio }, { "getJoints", w_Joint_getJoints },
	{ nullptr, nullptr },
};

extern "C" int luaopen_joint(lua_State *L)
{
	return luax_register_type(L, &Joint::type, functions, nullptr);
}

} // physics
} // love
