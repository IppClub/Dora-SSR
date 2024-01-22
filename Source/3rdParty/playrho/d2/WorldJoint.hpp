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

#ifndef PLAYRHO_D2_WORLDJOINT_HPP
#define PLAYRHO_D2_WORLDJOINT_HPP

/// @file
/// @brief Declarations of free functions of World for joints identified by <code>JointID</code>.
/// @details This is a collection of non-member non-friend functions - also called "free"
///   functions - that are related to joints within an instance of a <code>World</code>.
///   Many are just "wrappers" to similarly named member functions but some are additional
///   functionality built on those member functions. A benefit to using free functions that
///   are now just wrappers, is that of helping to isolate your code from future changes that
///   might occur to the underlying <code>World</code> member functions. Free functions in
///   this sense are "cheap" abstractions. While using these incurs extra run-time overhead
///   when compiled without any compiler optimizations enabled, enabling optimizations
///   should entirely eliminate that overhead.
/// @note The four basic categories of these functions are "CRUD": create, read, update,
///   and delete.
/// @see World, JointID.
/// @see https://en.wikipedia.org/wiki/Create,_read,_update_and_delete.

// IWYU pragma: begin_exports

#include "playrho/BodyID.hpp"
#include "playrho/JointID.hpp"
#include "playrho/LimitState.hpp"

#include "playrho/d2/Joint.hpp"
#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

class World;
struct JointConf;

/// @brief Gets the type of the joint.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
TypeID GetType(const World& world, JointID id);

/// @brief Gets collide connected for the specified joint.
/// @note Modifying the collide connect flag won't work correctly because
///   the flag is only checked when fixture AABBs begin to overlap.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
bool GetCollideConnected(const World& world, JointID id);

/// Is the joint motor enabled?
/// @throws std::out_of_range If given an invalid joint identifier.
/// @see EnableMotor(World& world, JointID joint, bool value)
/// @relatedalso World
bool IsMotorEnabled(const World& world, JointID id);

/// Enable/disable the joint motor.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
void EnableMotor(World& world, JointID id, bool value);

/// @brief Gets whether the identified joint's limit is enabled.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
bool IsLimitEnabled(const World& world, JointID id);

/// @brief Sets whether the identified joint's limit is enabled or not.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
void EnableLimit(World& world, JointID id, bool value);

/// @brief Gets the identifier of body-A of the identified joint.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
BodyID GetBodyA(const World& world, JointID id);

/// @brief Gets the identifier of body-B of the identified joint.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
BodyID GetBodyB(const World& world, JointID id);

/// Get the anchor point on body-A in local coordinates.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length2 GetLocalAnchorA(const World& world, JointID id);

/// Get the anchor point on body-B in local coordinates.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length2 GetLocalAnchorB(const World& world, JointID id);

/// @brief Gets the linear reaction on body-B at the joint anchor.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Momentum2 GetLinearReaction(const World& world, JointID id);

/// @brief Get the angular reaction on body-B for the identified joint.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
AngularMomentum GetAngularReaction(const World& world, JointID id);

/// @brief Gets the reference-angle property of the identified joint if it has it.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Angle GetReferenceAngle(const World& world, JointID id);

/// @brief Gets the local-X-axis-A property of the identified joint if it has it.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
UnitVec GetLocalXAxisA(const World& world, JointID id);

/// @brief Gets the local-Y-axis-A property of the identified joint if it has it.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
UnitVec GetLocalYAxisA(const World& world, JointID id);

/// @brief Gets the motor-speed property of the identied joint if it supports it.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
/// @see SetMotorSpeed(World& world, JointID id, AngularVelocity value)
AngularVelocity GetMotorSpeed(const World& world, JointID id);

/// @brief Sets the motor-speed property of the identied joint if it supports it.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
/// @see GetMotorSpeed(const World& world, JointID id)
void SetMotorSpeed(World& world, JointID id, AngularVelocity value);

/// @brief Gets the max motor torque.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Torque GetMaxMotorTorque(const World& world, JointID id);

/// Sets the maximum motor torque.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
void SetMaxMotorTorque(World& world, JointID id, Torque value);

/// @brief Gets the linear motor impulse of the identified joint if it supports that.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Momentum GetLinearMotorImpulse(const World& world, JointID id);

/// @brief Gets the angular motor impulse of the identified joint if it has this property.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
AngularMomentum GetAngularMotorImpulse(const World& world, JointID id);

/// @brief Gets the computed angular rotational inertia used by the joint.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
RotInertia GetAngularMass(const World& world, JointID id);

/// @brief Gets the frequency of the identified joint if it has this property.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Frequency GetFrequency(const World& world, JointID id);

/// @brief Sets the frequency of the identified joint if it has this property.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
void SetFrequency(World& world, JointID id, Frequency value);

/// @brief Gets the angular velocity of the identified joint if it has this property.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
AngularVelocity GetAngularVelocity(const World& world, JointID id);

/// @brief Gets the enabled/disabled state of the joint.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
bool IsEnabled(const World& world, JointID id);

/// @brief Gets the world index of the given joint.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
JointCounter GetWorldIndex(const World&, JointID id) noexcept;

/// Get the anchor point on body-A in world coordinates.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length2 GetAnchorA(const World& world, JointID id);

/// Get the anchor point on body-B in world coordinates.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length2 GetAnchorB(const World& world, JointID id);

/// @brief Gets the ratio property of the identified joint if it has it.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Real GetRatio(const World& world, JointID id);

/// @brief Gets the current joint translation.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length GetJointTranslation(const World& world, JointID id);

/// @brief Gets the angle property of the identified joint if it has it.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Angle GetAngle(const World& world, JointID id);

/// @brief Gets the current motor force for the given joint, given the inverse time step.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
inline Force GetMotorForce(const World& world, JointID id, Frequency inv_dt)
{
    return GetLinearMotorImpulse(world, id) * inv_dt;
}

/// @brief Gets the current motor torque for the given joint given the inverse time step.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
inline Torque GetMotorTorque(const World& world, JointID id, Frequency inv_dt)
{
    return GetAngularMotorImpulse(world, id) * inv_dt;
}

/// @brief Gets the target linear offset, in frame A.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length2 GetLinearOffset(const World& world, JointID id);

/// @brief Sets the target linear offset, in frame A.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
void SetLinearOffset(World& world, JointID id, const Length2& value);

/// @brief Gets the target angular offset.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Angle GetAngularOffset(const World& world, JointID id);

/// @brief Sets the target angular offset.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
void SetAngularOffset(World& world, JointID id, Angle value);

/// Get the first ground anchor.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length2 GetGroundAnchorA(const World& world, JointID id);

/// Get the second ground anchor.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length2 GetGroundAnchorB(const World& world, JointID id);

/// @brief Get the current length of the segment attached to body-A.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length GetCurrentLengthA(const World& world, JointID id);

/// @brief Get the current length of the segment attached to body-B.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length GetCurrentLengthB(const World& world, JointID id);

/// @brief Gets the target point.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Length2 GetTarget(const World& world, JointID id);

/// @brief Sets the target point.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
void SetTarget(World& world, JointID id, const Length2& value);

/// Get the lower joint limit.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Angle GetAngularLowerLimit(const World& world, JointID id);

/// Get the upper joint limit.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
Angle GetAngularUpperLimit(const World& world, JointID id);

/// Set the joint limits.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
void SetAngularLimits(World& world, JointID id, Angle lower, Angle upper);

/// @brief Shifts the origin of the identified joint.
/// @note This only effects joints having points in world coordinates.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
bool ShiftOrigin(World& world, JointID id, const Length2& value);

/// @brief Gets the damping ratio associated with the identified joint if it has one.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @throws std::invalid_argument If the identified joint's type doesn't support this.
/// @relatedalso World
Real GetDampingRatio(const World& world, JointID id);

/// @brief Gets the length associated with the identified joint if it has one.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @throws std::invalid_argument If the identified joint's type doesn't support this.
/// @relatedalso World
Length GetLength(const World& world, JointID id);

/// @brief Gets the joint's limit state if it has one.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @throws std::invalid_argument If the identified joint's type doesn't support this.
/// @relatedalso World
LimitState GetLimitState(const World& world, JointID id);

/// @brief Wakes up the joined bodies.
/// @throws WrongState if this function is called while the world is locked.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
void SetAwake(World& world, JointID id);

} // namespace playrho::d2

#endif // PLAYRHO_D2_WORLDJOINT_HPP
