/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
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
 */

#include <algorithm>

#include "playrho/Defines.hpp"
#include "playrho/to_underlying.hpp"

#include "playrho/d2/Joint.hpp"
#include "playrho/d2/DistanceJointConf.hpp"
#include "playrho/d2/FrictionJointConf.hpp"
#include "playrho/d2/GearJointConf.hpp"
#include "playrho/d2/MotorJointConf.hpp"
#include "playrho/d2/PrismaticJointConf.hpp"
#include "playrho/d2/PulleyJointConf.hpp"
#include "playrho/d2/RevoluteJointConf.hpp"
#include "playrho/d2/RopeJointConf.hpp"
#include "playrho/d2/TargetJointConf.hpp"
#include "playrho/d2/WeldJointConf.hpp"
#include "playrho/d2/WheelJointConf.hpp"
#include "playrho/d2/BodyConstraint.hpp"

namespace playrho {
namespace d2 {

static_assert(std::is_nothrow_default_constructible_v<Joint>,
              "Joint must be nothrow default constructible!");
static_assert(std::is_copy_constructible_v<Joint>, "Joint must be copy constructible!");
static_assert(std::is_nothrow_move_constructible_v<Joint>,
              "Joint must be nothrow move constructible!");
static_assert(std::is_copy_assignable_v<Joint>, "Joint must be copy assignable!");
static_assert(std::is_nothrow_move_assignable_v<Joint>,
              "Joint must be nothrow move assignable!");
static_assert(std::is_nothrow_destructible_v<Joint>, "Joint must be nothrow destructible!");

// Free functions...

BodyConstraint& At(const Span<BodyConstraint>& container, BodyID key)
{
    const auto index = to_underlying(key);
    if (index >= container.size()) {
        throw std::out_of_range{"invalid index"};
    }
    return container[index];
}

Length2 GetLocalAnchorA(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<DistanceJointConf>()) {
        return GetLocalAnchorA(TypeCast<DistanceJointConf>(object));
    }
    if (type == GetTypeID<FrictionJointConf>()) {
        return GetLocalAnchorA(TypeCast<FrictionJointConf>(object));
    }
    if (type == GetTypeID<GearJointConf>()) {
        return GetLocalAnchorA(TypeCast<GearJointConf>(object));
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetLocalAnchorA(TypeCast<PrismaticJointConf>(object));
    }
    if (type == GetTypeID<PulleyJointConf>()) {
        return GetLocalAnchorA(TypeCast<PulleyJointConf>(object));
    }
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetLocalAnchorA(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<RopeJointConf>()) {
        return GetLocalAnchorA(TypeCast<RopeJointConf>(object));
    }
    if (type == GetTypeID<WeldJointConf>()) {
        return GetLocalAnchorA(TypeCast<WeldJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return GetLocalAnchorA(TypeCast<WheelJointConf>(object));
    }
    // TODO: consider if throwing invalid_argument more appropriate.
    return Length2{};
}

Length2 GetLocalAnchorB(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<DistanceJointConf>()) {
        return GetLocalAnchorB(TypeCast<DistanceJointConf>(object));
    }
    if (type == GetTypeID<FrictionJointConf>()) {
        return GetLocalAnchorB(TypeCast<FrictionJointConf>(object));
    }
    if (type == GetTypeID<GearJointConf>()) {
        return GetLocalAnchorB(TypeCast<GearJointConf>(object));
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetLocalAnchorB(TypeCast<PrismaticJointConf>(object));
    }
    if (type == GetTypeID<PulleyJointConf>()) {
        return GetLocalAnchorB(TypeCast<PulleyJointConf>(object));
    }
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetLocalAnchorB(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<RopeJointConf>()) {
        return GetLocalAnchorB(TypeCast<RopeJointConf>(object));
    }
    if (type == GetTypeID<TargetJointConf>()) {
        return GetLocalAnchorB(TypeCast<TargetJointConf>(object));
    }
    if (type == GetTypeID<WeldJointConf>()) {
        return GetLocalAnchorB(TypeCast<WeldJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return GetLocalAnchorB(TypeCast<WheelJointConf>(object));
    }
    // TODO: consider if throwing invalid_argument more appropriate.
    return Length2{};
}

Momentum2 GetLinearReaction(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<DistanceJointConf>()) {
        return GetLinearReaction(TypeCast<DistanceJointConf>(object));
    }
    if (type == GetTypeID<FrictionJointConf>()) {
        return GetLinearReaction(TypeCast<FrictionJointConf>(object));
    }
    if (type == GetTypeID<GearJointConf>()) {
        return GetLinearReaction(TypeCast<GearJointConf>(object));
    }
    if (type == GetTypeID<MotorJointConf>()) {
        return GetLinearReaction(TypeCast<MotorJointConf>(object));
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetLinearReaction(TypeCast<PrismaticJointConf>(object));
    }
    if (type == GetTypeID<PulleyJointConf>()) {
        return GetLinearReaction(TypeCast<PulleyJointConf>(object));
    }
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetLinearReaction(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<RopeJointConf>()) {
        return GetLinearReaction(TypeCast<RopeJointConf>(object));
    }
    if (type == GetTypeID<TargetJointConf>()) {
        return GetLinearReaction(TypeCast<TargetJointConf>(object));
    }
    if (type == GetTypeID<WeldJointConf>()) {
        return GetLinearReaction(TypeCast<WeldJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return GetLinearReaction(TypeCast<WheelJointConf>(object));
    }
    // TODO: consider if throwing invalid_argument more appropriate.
    // throw std::invalid_argument("GetLinearReaction not supported by joint type");
    return {};
}

AngularMomentum GetAngularReaction(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<DistanceJointConf>()) {
        return GetAngularReaction(TypeCast<DistanceJointConf>(object));
    }
    if (type == GetTypeID<FrictionJointConf>()) {
        return GetAngularReaction(TypeCast<FrictionJointConf>(object));
    }
    if (type == GetTypeID<GearJointConf>()) {
        return GetAngularReaction(TypeCast<GearJointConf>(object));
    }
    if (type == GetTypeID<MotorJointConf>()) {
        return GetAngularReaction(TypeCast<MotorJointConf>(object));
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetAngularReaction(TypeCast<PrismaticJointConf>(object));
    }
    if (type == GetTypeID<PulleyJointConf>()) {
        return GetAngularReaction(TypeCast<PulleyJointConf>(object));
    }
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetAngularReaction(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<RopeJointConf>()) {
        return GetAngularReaction(TypeCast<RopeJointConf>(object));
    }
    if (type == GetTypeID<TargetJointConf>()) {
        return GetAngularReaction(TypeCast<TargetJointConf>(object));
    }
    if (type == GetTypeID<WeldJointConf>()) {
        return GetAngularReaction(TypeCast<WeldJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return GetAngularReaction(TypeCast<WheelJointConf>(object));
    }
    // TODO: consider if throwing invalid_argument more appropriate.
    // throw std::invalid_argument("GetAngularReaction not supported by joint type");
    return {};
}

Angle GetReferenceAngle(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetReferenceAngle(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetReferenceAngle(TypeCast<PrismaticJointConf>(object));
    }
    if (type == GetTypeID<WeldJointConf>()) {
        return GetReferenceAngle(TypeCast<WeldJointConf>(object));
    }
    throw std::invalid_argument("GetReferenceAngle not supported by joint type");
}

UnitVec GetLocalXAxisA(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<WheelJointConf>()) {
        return GetLocalXAxisA(TypeCast<WheelJointConf>(object));
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetLocalXAxisA(TypeCast<PrismaticJointConf>(object));
    }
    throw std::invalid_argument("GetLocalXAxisA not supported by joint type");
}

UnitVec GetLocalYAxisA(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<WheelJointConf>()) {
        return GetLocalYAxisA(TypeCast<WheelJointConf>(object));
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetLocalYAxisA(TypeCast<PrismaticJointConf>(object));
    }
    throw std::invalid_argument("GetLocalYAxisA not supported by joint type");
}

AngularVelocity GetMotorSpeed(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetMotorSpeed(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetMotorSpeed(TypeCast<PrismaticJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return GetMotorSpeed(TypeCast<WheelJointConf>(object));
    }
    throw std::invalid_argument("GetMotorSpeed not supported by joint type");
}

void SetMotorSpeed(Joint& object, AngularVelocity value)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        TypeCast<RevoluteJointConf&>(object).UseMotorSpeed(value);
        return;
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        TypeCast<PrismaticJointConf&>(object).UseMotorSpeed(value);
        return;
    }
    if (type == GetTypeID<WheelJointConf>()) {
        TypeCast<WheelJointConf&>(object).UseMotorSpeed(value);
        return;
    }
    throw std::invalid_argument("SetMotorSpeed not supported by joint type!");
}

RotInertia GetAngularMass(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<FrictionJointConf>()) {
        return GetAngularMass(TypeCast<FrictionJointConf>(object));
    }
    if (type == GetTypeID<MotorJointConf>()) {
        return GetAngularMass(TypeCast<MotorJointConf>(object));
    }
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetAngularMass(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return GetAngularMass(TypeCast<WheelJointConf>(object));
    }
    throw std::invalid_argument("GetAngularMass not supported by joint type");
}

Force GetMaxForce(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<FrictionJointConf>()) {
        return TypeCast<FrictionJointConf>(object).maxForce;
    }
    if (type == GetTypeID<MotorJointConf>()) {
        return TypeCast<MotorJointConf>(object).maxForce;
    }
    if (type == GetTypeID<TargetJointConf>()) {
        return TypeCast<TargetJointConf>(object).maxForce;
    }
    throw std::invalid_argument("GetMaxForce not supported by joint type");
}

Torque GetMaxTorque(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<FrictionJointConf>()) {
        return GetMaxTorque(TypeCast<FrictionJointConf>(object));
    }
    if (type == GetTypeID<MotorJointConf>()) {
        return GetMaxTorque(TypeCast<MotorJointConf>(object));
    }
    throw std::invalid_argument("GetMaxTorque not supported by joint type");
}

Force GetMaxMotorForce(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetMaxMotorForce(TypeCast<PrismaticJointConf>(object));
    }
    throw std::invalid_argument("GetMaxMotorForce not supported by joint type");
}

void SetMaxMotorForce(Joint& object, Force value)
{
    const auto type = GetType(object);
    if (type == GetTypeID<PrismaticJointConf>()) {
        TypeCast<PrismaticJointConf&>(object).UseMaxMotorForce(value);
        return;
    }
    throw std::invalid_argument("SetMaxMotorForce not supported by joint type!");
}

Torque GetMaxMotorTorque(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetMaxMotorTorque(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return GetMaxMotorTorque(TypeCast<WheelJointConf>(object));
    }
    throw std::invalid_argument("GetMaxMotorTorque not supported by joint type");
}

void SetMaxMotorTorque(Joint& object, Torque value)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        TypeCast<RevoluteJointConf&>(object).UseMaxMotorTorque(value);
        return;
    }
    if (type == GetTypeID<WheelJointConf>()) {
        TypeCast<WheelJointConf&>(object).UseMaxMotorTorque(value);
        return;
    }
    throw std::invalid_argument("SetMaxMotorTorque not supported by joint type!");
}

Real GetRatio(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<GearJointConf>()) {
        return GetRatio(TypeCast<GearJointConf>(object));
    }
    if (type == GetTypeID<PulleyJointConf>()) {
        return GetRatio(TypeCast<PulleyJointConf>(object));
    }
    throw std::invalid_argument("GetRatio not supported by joint type!");
}

Real GetDampingRatio(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<DistanceJointConf>()) {
        return GetDampingRatio(TypeCast<DistanceJointConf>(object));
    }
    if (type == GetTypeID<TargetJointConf>()) {
        return GetDampingRatio(TypeCast<TargetJointConf>(object));
    }
    if (type == GetTypeID<WeldJointConf>()) {
        return GetDampingRatio(TypeCast<WeldJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return GetDampingRatio(TypeCast<WheelJointConf>(object));
    }
    throw std::invalid_argument("GetRatio not supported by joint type!");
}

Frequency GetFrequency(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<DistanceJointConf>()) {
        return GetFrequency(TypeCast<DistanceJointConf>(object));
    }
    if (type == GetTypeID<TargetJointConf>()) {
        return GetFrequency(TypeCast<TargetJointConf>(object));
    }
    if (type == GetTypeID<WeldJointConf>()) {
        return GetFrequency(TypeCast<WeldJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return GetFrequency(TypeCast<WheelJointConf>(object));
    }
    throw std::invalid_argument("GetFrequency not supported by joint type");
}

void SetFrequency(Joint& object, Frequency value)
{
    const auto type = GetType(object);
    if (type == GetTypeID<DistanceJointConf>()) {
        TypeCast<DistanceJointConf&>(object).UseFrequency(value);
        return;
    }
    if (type == GetTypeID<TargetJointConf>()) {
        TypeCast<TargetJointConf&>(object).UseFrequency(value);
        return;
    }
    if (type == GetTypeID<WeldJointConf>()) {
        TypeCast<WeldJointConf&>(object).UseFrequency(value);
        return;
    }
    if (type == GetTypeID<WheelJointConf>()) {
        TypeCast<WheelJointConf&>(object).UseFrequency(value);
        return;
    }
    throw std::invalid_argument("SetFrequency not supported by joint type!");
}

AngularMomentum GetAngularMotorImpulse(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetAngularMotorImpulse(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return GetAngularReaction(TypeCast<WheelJointConf>(object));
    }
    throw std::invalid_argument("GetAngularMotorImpulse not supported by joint type");
}

Length2 GetTarget(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<TargetJointConf>()) {
        return GetTarget(TypeCast<TargetJointConf>(object));
    }
    throw std::invalid_argument("GetTarget not supported by joint type");
}

void SetTarget(Joint& object, const Length2& value)
{
    const auto type = GetType(object);
    if (type == GetTypeID<TargetJointConf>()) {
        TypeCast<TargetJointConf&>(object).UseTarget(value);
        return;
    }
    throw std::invalid_argument("SetTarget not supported by joint type");
}

Length GetLinearLowerLimit(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetLinearLowerLimit(TypeCast<PrismaticJointConf>(object));
    }
    throw std::invalid_argument("GetLinearLowerLimit not supported by joint type!");
}

Length GetLinearUpperLimit(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetLinearUpperLimit(TypeCast<PrismaticJointConf>(object));
    }
    throw std::invalid_argument("GetLinearUpperLimit not supported by joint type!");
}

void SetLinearLimits(Joint& object, Length lower, Length upper)
{
    const auto type = GetType(object);
    if (type == GetTypeID<PrismaticJointConf>()) {
        TypeCast<PrismaticJointConf&>(object).UseLowerLength(lower).UseUpperLength(upper);
        return;
    }
    throw std::invalid_argument("SetLinearLimits not supported by joint type!");
}

Angle GetAngularLowerLimit(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetAngularLowerLimit(TypeCast<RevoluteJointConf>(object));
    }
    throw std::invalid_argument("GetAngularLowerLimit not supported by joint type!");
}

Angle GetAngularUpperLimit(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetAngularUpperLimit(TypeCast<RevoluteJointConf>(object));
    }
    throw std::invalid_argument("GetAngularUpperLimit not supported by joint type!");
}

void SetAngularLimits(Joint& object, Angle lower, Angle upper)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        TypeCast<RevoluteJointConf&>(object).UseLowerAngle(lower).UseUpperAngle(upper);
        return;
    }
    throw std::invalid_argument("SetAngularLimits not supported by joint type!");
}

bool IsLimitEnabled(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        return IsLimitEnabled(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        return IsLimitEnabled(TypeCast<PrismaticJointConf>(object));
    }
    throw std::invalid_argument("IsLimitEnabled not supported by joint type!");
}

void EnableLimit(Joint& object, bool value)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        TypeCast<RevoluteJointConf&>(object).UseEnableLimit(value);
        return;
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        TypeCast<PrismaticJointConf&>(object).UseEnableLimit(value);
        return;
    }
    throw std::invalid_argument("EnableLimit not supported by joint type!");
}

bool IsMotorEnabled(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        return IsMotorEnabled(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        return IsMotorEnabled(TypeCast<PrismaticJointConf>(object));
    }
    if (type == GetTypeID<WheelJointConf>()) {
        return IsMotorEnabled(TypeCast<WheelJointConf>(object));
    }
    throw std::invalid_argument("IsMotorEnabled not supported by joint type!");
}

void EnableMotor(Joint& object, bool value)
{
    const auto type = GetType(object);
    if (type == GetTypeID<RevoluteJointConf>()) {
        TypeCast<RevoluteJointConf&>(object).UseEnableMotor(value);
        return;
    }
    if (type == GetTypeID<PrismaticJointConf>()) {
        TypeCast<PrismaticJointConf&>(object).UseEnableMotor(value);
        return;
    }
    if (type == GetTypeID<WheelJointConf>()) {
        TypeCast<WheelJointConf&>(object).UseEnableMotor(value);
        return;
    }
    throw std::invalid_argument("EnableMotor not supported by joint type!");
}

Length2 GetLinearOffset(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<MotorJointConf>()) {
        return GetLinearOffset(TypeCast<MotorJointConf>(object));
    }
    throw std::invalid_argument("GetLinearOffset not supported by joint type!");
}

void SetLinearOffset(Joint& object, const Length2& value)
{
    const auto type = GetType(object);
    if (type == GetTypeID<MotorJointConf>()) {
        TypeCast<MotorJointConf&>(object).UseLinearOffset(value);
        return;
    }
    throw std::invalid_argument("SetLinearOffset not supported by joint type!");
}

Angle GetAngularOffset(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<MotorJointConf>()) {
        return GetAngularOffset(TypeCast<MotorJointConf>(object));
    }
    throw std::invalid_argument("GetAngularOffset not supported by joint type!");
}

void SetAngularOffset(Joint& object, Angle value)
{
    const auto type = GetType(object);
    if (type == GetTypeID<MotorJointConf>()) {
        TypeCast<MotorJointConf&>(object).UseAngularOffset(value);
        return;
    }
    throw std::invalid_argument("SetAngularOffset not supported by joint type!");
}

LimitState GetLimitState(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetLimitState(TypeCast<PrismaticJointConf>(object));
    }
    if (type == GetTypeID<RevoluteJointConf>()) {
        return GetLimitState(TypeCast<RevoluteJointConf>(object));
    }
    if (type == GetTypeID<RopeJointConf>()) {
        return GetLimitState(TypeCast<RopeJointConf>(object));
    }
    throw std::invalid_argument("GetLimitState not supported by joint type!");
}

Length2 GetGroundAnchorA(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<PulleyJointConf>()) {
        return GetGroundAnchorA(TypeCast<PulleyJointConf>(object));
    }
    throw std::invalid_argument("GetGroundAnchorA not supported by joint type!");
}

Length2 GetGroundAnchorB(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<PulleyJointConf>()) {
        return GetGroundAnchorB(TypeCast<PulleyJointConf>(object));
    }
    throw std::invalid_argument("GetGroundAnchorB not supported by joint type!");
}

Momentum GetLinearMotorImpulse(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<PrismaticJointConf>()) {
        return GetLinearMotorImpulse(TypeCast<PrismaticJointConf>(object));
    }
    throw std::invalid_argument("GetLinearMotorImpulse not supported by joint type!");
}

Length GetLength(const Joint& object)
{
    const auto type = GetType(object);
    if (type == GetTypeID<DistanceJointConf>()) {
        return GetLength(TypeCast<DistanceJointConf>(object));
    }
    throw std::invalid_argument("GetLength not supported by joint type!");
}

} // namespace d2
} // namespace playrho
