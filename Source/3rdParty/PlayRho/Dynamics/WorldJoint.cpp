/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Dynamics/WorldJoint.hpp"

#include "PlayRho/Dynamics/World.hpp"

#include "PlayRho/Dynamics/Joints/Joint.hpp"

#include <algorithm>

namespace playrho {
namespace d2 {

SizedRange<std::vector<JointID>::const_iterator> GetJoints(const World& world) noexcept
{
    return world.GetJoints();
}

JointID CreateJoint(World& world, const Joint& def)
{
    return world.CreateJoint(def);
}

void Destroy(World& world, JointID id)
{
    world.Destroy(id);
}

const Joint& GetJoint(const World& world, JointID id)
{
    return world.GetJoint(id);
}

void SetJoint(World& world, JointID id, const Joint& def)
{
    world.SetJoint(id, def);
}

JointType GetType(const World& world, JointID id)
{
    return GetType(world.GetJoint(id));
}

bool GetCollideConnected(const World& world, JointID id)
{
    return GetCollideConnected(world.GetJoint(id));
}

BodyID GetBodyA(const World& world, JointID id)
{
    return GetBodyA(world.GetJoint(id));
}

BodyID GetBodyB(const World& world, JointID id)
{
    return GetBodyB(world.GetJoint(id));
}

Length2 GetLocalAnchorA(const World& world, JointID id)
{
    return GetLocalAnchorA(world.GetJoint(id));
}

Length2 GetLocalAnchorB(const World& world, JointID id)
{
    return GetLocalAnchorB(world.GetJoint(id));
}

Momentum2 GetLinearReaction(const World& world, JointID id)
{
    return GetLinearReaction(world.GetJoint(id));
}

AngularMomentum GetAngularReaction(const World& world, JointID id)
{
    return GetAngularReaction(world.GetJoint(id));
}

Angle GetReferenceAngle(const World& world, JointID id)
{
    return GetReferenceAngle(world.GetJoint(id));
}

void SetAwake(World& world, JointID id)
{
    const auto& joint = world.GetJoint(id);
    const auto bA = GetBodyA(joint);
    const auto bB = GetBodyB(joint);
    if (bA != InvalidBodyID)
    {
        world.SetAwake(bA);
    }
    if (bB != InvalidBodyID)
    {
        world.SetAwake(bB);
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
    return world.GetVelocity(GetBodyB(world, id)).angular
         - world.GetVelocity(GetBodyA(world, id)).angular;
}

bool IsEnabled(const World& world, JointID id)
{
    const auto bA = GetBodyA(world, id);
    const auto bB = GetBodyB(world, id);
    return (bA == InvalidBodyID || world.IsEnabled(bA))
        && (bB == InvalidBodyID || world.IsEnabled(bB));
}

JointCounter GetWorldIndex(const World& world, JointID id) noexcept
{
    const auto elems = world.GetJoints();
    const auto it = std::find(cbegin(elems), cend(elems), id);
    if (it != cend(elems))
    {
        return static_cast<JointCounter>(std::distance(cbegin(elems), it));
    }
    return JointCounter(-1);
}

Length2 GetAnchorA(const World& world, JointID id)
{
    const auto& joint = world.GetJoint(id);
    const auto la = GetLocalAnchorA(joint);
    const auto body = GetBodyA(joint);
    return (body != InvalidBodyID)? Transform(la, world.GetTransformation(body)): la;
}

Length2 GetAnchorB(const World& world, JointID id)
{
    const auto& joint = world.GetJoint(id);
    const auto la = GetLocalAnchorB(joint);
    const auto body = GetBodyB(joint);
    return (body != InvalidBodyID)? Transform(la, world.GetTransformation(body)): la;
}

Real GetRatio(const World& world, JointID id)
{
    return GetRatio(GetJoint(world, id));
}

Length GetJointTranslation(const World& world, JointID id)
{
    const auto pA = GetAnchorA(world, id);
    const auto pB = GetAnchorB(world, id);
    const auto uv = Rotate(GetLocalXAxisA(world, id),
                           world.GetTransformation(GetBodyA(world, id)).q);
    return Dot(pB - pA, uv);
}

Angle GetAngle(const World& world, JointID id)
{
    return world.GetAngle(GetBodyB(world, id)) - world.GetAngle(GetBodyA(world, id))
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

void SetLinearOffset(World& world, JointID id, Length2 value)
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

void SetTarget(World& world, JointID id, Length2 value)
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

bool ShiftOrigin(World& world, JointID id, Length2 value)
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

} // namespace d2
} // namespace playrho
