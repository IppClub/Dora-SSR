/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
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

#include "playrho/to_underlying.hpp"

#include "playrho/d2/WorldJoint.hpp"
#include "playrho/d2/World.hpp"
#include "playrho/d2/Body.hpp" // for GetBody
#include "playrho/d2/Joint.hpp"

#include <algorithm>

namespace playrho::d2 {

TypeID GetType(const World& world, JointID id)
{
    return GetType(GetJoint(world, id));
}

bool GetCollideConnected(const World& world, JointID id)
{
    return GetCollideConnected(GetJoint(world, id));
}

BodyID GetBodyA(const World& world, JointID id)
{
    return GetBodyA(GetJoint(world, id));
}

BodyID GetBodyB(const World& world, JointID id)
{
    return GetBodyB(GetJoint(world, id));
}

Length2 GetLocalAnchorA(const World& world, JointID id)
{
    return GetLocalAnchorA(GetJoint(world, id));
}

Length2 GetLocalAnchorB(const World& world, JointID id)
{
    return GetLocalAnchorB(GetJoint(world, id));
}

Momentum2 GetLinearReaction(const World& world, JointID id)
{
    return GetLinearReaction(GetJoint(world, id));
}

AngularMomentum GetAngularReaction(const World& world, JointID id)
{
    return GetAngularReaction(GetJoint(world, id));
}

Angle GetReferenceAngle(const World& world, JointID id)
{
    return GetReferenceAngle(GetJoint(world, id));
}

void SetAwake(World& world, JointID id)
{
    const auto joint = GetJoint(world, id);
    const auto bA = GetBodyA(joint);
    const auto bB = GetBodyB(joint);
    if (bA != InvalidBodyID) {
        auto body = GetBody(world, bA);
        SetAwake(body);
        SetBody(world, bA, body);
    }
    if (bB != InvalidBodyID) {
        auto body = GetBody(world, bB);
        SetAwake(body);
        SetBody(world, bB, body);
    }
}

UnitVec GetLocalXAxisA(const World& world, JointID id)
{
    return GetLocalXAxisA(GetJoint(world, id));
}

UnitVec GetLocalYAxisA(const World& world, JointID id)
{
    return GetLocalYAxisA(GetJoint(world, id));
}

AngularVelocity GetMotorSpeed(const World& world, JointID id)
{
    return GetMotorSpeed(GetJoint(world, id));
}

void SetMotorSpeed(World& world, JointID id, AngularVelocity value)
{
    auto joint = GetJoint(world, id);
    SetMotorSpeed(joint, value);
    SetJoint(world, id, joint);
}

AngularMomentum GetAngularMotorImpulse(const World& world, JointID id)
{
    return GetAngularMotorImpulse(GetJoint(world, id));
}

RotInertia GetAngularMass(const World& world, JointID id)
{
    return GetAngularMass(GetJoint(world, id));
}

Torque GetMaxMotorTorque(const World& world, JointID id)
{
    return GetMaxMotorTorque(GetJoint(world, id));
}

void SetMaxMotorTorque(World& world, JointID id, Torque value)
{
    auto joint = GetJoint(world, id);
    SetMaxMotorTorque(joint, value);
    SetJoint(world, id, joint);
}

Frequency GetFrequency(const World& world, JointID id)
{
    return GetFrequency(GetJoint(world, id));
}

void SetFrequency(World& world, JointID id, Frequency value)
{
    auto joint = GetJoint(world, id);
    SetFrequency(joint, value);
    SetJoint(world, id, joint);
}

AngularVelocity GetAngularVelocity(const World& world, JointID id)
{
    const auto joint = GetJoint(world, id);
    return GetAngularVelocity(GetBody(world, GetBodyB(joint)))
         - GetAngularVelocity(GetBody(world, GetBodyA(joint)));
}

bool IsEnabled(const World& world, JointID id)
{
    const auto bA = GetBodyA(world, id);
    const auto bB = GetBodyB(world, id);
    return (bA == InvalidBodyID || IsEnabled(GetBody(world, bA)))
        && (bB == InvalidBodyID || IsEnabled(GetBody(world, bB)));
}

JointCounter GetWorldIndex(const World&, JointID id) noexcept
{
    return to_underlying(id);
}

Length2 GetAnchorA(const World& world, JointID id)
{
    const auto joint = GetJoint(world, id);
    const auto la = GetLocalAnchorA(joint);
    const auto body = GetBodyA(joint);
    return (body != InvalidBodyID)? Transform(la, GetTransformation(GetBody(world, body))): la;
}

Length2 GetAnchorB(const World& world, JointID id)
{
    const auto joint = GetJoint(world, id);
    const auto la = GetLocalAnchorB(joint);
    const auto body = GetBodyB(joint);
    return (body != InvalidBodyID)? Transform(la, GetTransformation(GetBody(world, body))): la;
}

Real GetRatio(const World& world, JointID id)
{
    return GetRatio(GetJoint(world, id));
}

Length GetJointTranslation(const World& world, JointID id)
{
    const auto joint = GetJoint(world, id);
    const auto pA = GetAnchorA(world, id);
    const auto pB = GetAnchorB(world, id);
    const auto uv = Rotate(GetLocalXAxisA(joint),
                           GetTransformation(GetBody(world, GetBodyA(joint))).q);
    return Dot(pB - pA, uv);
}

Angle GetAngle(const World& world, JointID id)
{
    const auto joint = GetJoint(world, id);
    return GetAngle(GetBody(world, GetBodyB(joint))) - GetAngle(GetBody(world, GetBodyA(joint)))
         - GetReferenceAngle(world, id);
}

bool IsLimitEnabled(const World& world, JointID id)
{
    return IsLimitEnabled(GetJoint(world, id));
}

void EnableLimit(World& world, JointID id, bool value)
{
    auto joint = GetJoint(world, id);
    EnableLimit(joint, value);
    SetJoint(world, id, joint);
}

bool IsMotorEnabled(const World& world, JointID id)
{
    return IsMotorEnabled(GetJoint(world, id));
}

void EnableMotor(World& world, JointID id, bool value)
{
    auto joint = GetJoint(world, id);
    EnableMotor(joint, value);
    SetJoint(world, id, joint);
}

Momentum GetLinearMotorImpulse(const World& world, JointID id)
{
    return GetLinearMotorImpulse(GetJoint(world, id));
}

Length2 GetLinearOffset(const World& world, JointID id)
{
    return GetLinearOffset(GetJoint(world, id));
}

void SetLinearOffset(World& world, JointID id, const Length2& value)
{
    auto joint = GetJoint(world, id);
    SetLinearOffset(joint, value);
    SetJoint(world, id, joint);
}

Angle GetAngularOffset(const World& world, JointID id)
{
    return GetAngularOffset(GetJoint(world, id));
}

void SetAngularOffset(World& world, JointID id, Angle value)
{
    auto joint = GetJoint(world, id);
    SetAngularOffset(joint, value);
    SetJoint(world, id, joint);
}

Length2 GetGroundAnchorA(const World& world,  JointID id)
{
    return GetGroundAnchorA(GetJoint(world, id));
}

Length2 GetGroundAnchorB(const World& world,  JointID id)
{
    return GetGroundAnchorB(GetJoint(world, id));
}

Length GetCurrentLengthA(const World& world, JointID id)
{
    return GetMagnitude(GetAnchorA(world, id) - GetGroundAnchorA(world, id));
}

Length GetCurrentLengthB(const World& world, JointID id)
{
    return GetMagnitude(GetAnchorB(world, id) - GetGroundAnchorB(world, id));
}

Length2 GetTarget(const World& world, JointID id)
{
    return GetTarget(GetJoint(world, id));
}

void SetTarget(World& world, JointID id, const Length2& value)
{
    auto joint = GetJoint(world, id);
    SetTarget(joint, value);
    SetJoint(world, id, joint);
}

Angle GetAngularLowerLimit(const World& world, JointID id)
{
    return GetAngularLowerLimit(GetJoint(world, id));
}

Angle GetAngularUpperLimit(const World& world, JointID id)
{
    return GetAngularUpperLimit(GetJoint(world, id));
}

void SetAngularLimits(World& world, JointID id, Angle lower, Angle upper)
{
    auto joint = GetJoint(world, id);
    SetAngularLimits(joint, lower, upper);
    SetJoint(world, id, joint);
}

bool ShiftOrigin(World& world, JointID id, const Length2& value)
{
    auto joint = GetJoint(world, id);
    const auto shifted = ShiftOrigin(joint, value);
    SetJoint(world, id, joint);
    return shifted;
}

Real GetDampingRatio(const World& world, JointID id)
{
    return GetDampingRatio(GetJoint(world, id));
}

Length GetLength(const World& world, JointID id)
{
    return GetLength(GetJoint(world, id));
}

LimitState GetLimitState(const World& world, JointID id)
{
    return GetLimitState(GetJoint(world, id));
}

} // namespace playrho::d2
