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

#ifndef PLAYRHO_DYNAMICS_WORLDIMPLBODY_HPP
#define PLAYRHO_DYNAMICS_WORLDIMPLBODY_HPP

/// @file
/// Declarations of free functions of WorldImpl for bodies.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/Units.hpp"
#include "PlayRho/Common/Transformation.hpp"
#include "PlayRho/Common/Range.hpp" // for SizedRange
#include "PlayRho/Common/Velocity.hpp"
#include "PlayRho/Common/Vector2.hpp" // for Length2, LinearAcceleration2

#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/FixtureID.hpp"
#include "PlayRho/Dynamics/BodyType.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/Contacts/KeyedContactID.hpp"
#include "PlayRho/Dynamics/Joints/JointID.hpp"

#include "PlayRho/Collision/MassData.hpp"

#include <vector>

namespace playrho {
namespace d2 {

class WorldImpl;

/// @brief Gets the extent of the currently valid body range.
/// @note This is one higher than the maxium BodyID that is in range for body related
///   functions.
BodyCounter GetBodyRange(const WorldImpl& world) noexcept;

/// @brief Destroys the identified body.
/// @relatedalso WorldImpl
void Destroy(WorldImpl& world, BodyID id);

/// @brief Gets the body configuration for the identified body.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso WorldImpl
BodyConf GetBodyConf(const WorldImpl& world, BodyID id);

/// @brief Gets the type of the body.
/// @relatedalso WorldImpl
BodyType GetType(const WorldImpl& world, BodyID id);

/// @relatedalso WorldImpl
void SetType(WorldImpl& world, BodyID id, BodyType value);

/// @brief Is the body treated like a bullet for continuous collision detection?
/// @relatedalso WorldImpl
bool IsImpenetrable(const WorldImpl& world, BodyID id);

/// @relatedalso WorldImpl
void SetImpenetrable(WorldImpl& world, BodyID id);

/// @relatedalso WorldImpl
void UnsetImpenetrable(WorldImpl& world, BodyID id);

/// @brief Gets whether or not the identified body is allowed to sleep.
/// @relatedalso WorldImpl
bool IsSleepingAllowed(const WorldImpl& world, BodyID id);

/// @relatedalso WorldImpl
void SetSleepingAllowed(WorldImpl& world, BodyID id, bool value);

/// @relatedalso WorldImpl
Angle GetAngle(const WorldImpl& world, BodyID id);

/// @relatedalso WorldImpl
Transformation GetTransformation(const WorldImpl& world, BodyID id);

/// @relatedalso WorldImpl
void SetTransformation(WorldImpl& world, BodyID id, Transformation xfm);

/// @relatedalso WorldImpl
Velocity GetVelocity(const WorldImpl& world, BodyID id);

/// @brief Sets the body's velocity (linear and angular velocity).
/// @note This method does nothing if this body is not speedable.
/// @note A non-zero velocity will awaken this body.
/// @see SetAwake, SetUnderActiveTime.
/// @relatedalso WorldImpl
void SetVelocity(WorldImpl& world, BodyID id, const Velocity& value);

/// @brief Sleeps the body.
/// @relatedalso WorldImpl
void UnsetAwake(WorldImpl& world, BodyID id);

/// @brief Wakes up the body.
/// @relatedalso WorldImpl
void SetAwake(WorldImpl& world, BodyID id);

/// @relatedalso WorldImpl
bool IsAwake(const WorldImpl& world, BodyID id);

/// @brief Gets the linear damping of the body.
/// @relatedalso WorldImpl
Frequency GetLinearDamping(const WorldImpl& world, BodyID id);

/// @brief Sets the linear damping of the body.
/// @relatedalso WorldImpl
void SetLinearDamping(WorldImpl& world, BodyID id, NonNegative<Frequency> value);

/// @brief Gets the angular damping of the body.
/// @relatedalso WorldImpl
Frequency GetAngularDamping(const WorldImpl& world, BodyID id);

/// @brief Sets the angular damping of the body.
/// @relatedalso WorldImpl
void SetAngularDamping(WorldImpl& world, BodyID id, NonNegative<Frequency> value);

/// @brief Gets the local position of the center of mass of the specified body.
/// @relatedalso WorldImpl
Length2 GetLocalCenter(const WorldImpl& world, BodyID id);

/// @brief Get the world position of the center of mass of the specified body.
/// @relatedalso WorldImpl
Length2 GetWorldCenter(const WorldImpl& world, BodyID id);

/// @brief Gets this body's linear acceleration.
/// @relatedalso WorldImpl
LinearAcceleration2 GetLinearAcceleration(const WorldImpl& world, BodyID id);

/// @brief Gets this body's angular acceleration.
/// @relatedalso WorldImpl
AngularAcceleration GetAngularAcceleration(const WorldImpl& world, BodyID id);

/// @relatedalso WorldImpl
void SetAcceleration(WorldImpl& world, BodyID id,
                     LinearAcceleration2 linear, AngularAcceleration angular);

/// @relatedalso WorldImpl
void SetAcceleration(WorldImpl& world, BodyID id, Acceleration value);

/// @relatedalso WorldImpl
void SetAcceleration(WorldImpl& world, BodyID id, LinearAcceleration2 value);

/// @relatedalso WorldImpl
void SetAcceleration(WorldImpl& world, BodyID id, AngularAcceleration value);

/// @brief Sets the mass properties to override the mass properties of the fixtures.
/// @note This changes the center of mass position.
/// @note Creating or destroying fixtures can also alter the mass.
/// @note This function has no effect if the body isn't dynamic.
/// @param world The world of the identified body.
/// @param id Identification of body.
/// @param massData the mass properties.
/// @relatedalso WorldImpl
void SetMassData(WorldImpl& world, BodyID id, const MassData& massData);

/// @brief Computes the body's mass data.
/// @details This basically accumulates the mass data over all fixtures.
/// @note The center is the mass weighted sum of all fixture centers. Divide it by the
///   mass to get the averaged center.
/// @return accumulated mass data for all fixtures associated with the given body.
/// @relatedalso WorldImpl
MassData ComputeMassData(const WorldImpl& world, BodyID id);

/// @brief Resets the mass data properties.
/// @details This resets the mass data to the sum of the mass properties of the fixtures.
/// @note This method must be called after calling <code>CreateFixture</code> to update the
///   body mass data properties unless <code>SetMassData</code> is used.
/// @see SetMassData.
/// @relatedalso WorldImpl
inline void ResetMassData(WorldImpl& world, BodyID id)
{
    SetMassData(world, id, ComputeMassData(world, id));
}

/// @brief Gets the inverse total mass of the body.
/// @return Value of zero or more representing the body's inverse mass (in 1/kg).
/// @see SetMassData.
/// @relatedalso WorldImpl
InvMass GetInvMass(const WorldImpl& world, BodyID id);

/// @brief Gets the mass of the body.
/// @note This may be the total calculated mass or it may be the set mass of the body.
/// @return Value of zero or more representing the body's mass.
/// @see GetInvMass, SetMassData
/// @relatedalso WorldImpl
inline Mass GetMass(const WorldImpl& world, BodyID id)
{
    const auto invMass = GetInvMass(world, id);
    return (invMass != InvMass{0})? Mass{Real{1} / invMass}: 0_kg;
}

/// @brief Gets the inverse rotational inertia of the body.
/// @return Inverse rotational inertia (in 1/kg-m^2).
/// @relatedalso WorldImpl
InvRotInertia GetInvRotInertia(const WorldImpl& world, BodyID id);

/// @brief Gets the rotational inertia of the body.
/// @param world The world of the identified body.
/// @param id Body to get the rotational inertia for.
/// @return the rotational inertia.
/// @relatedalso WorldImpl
inline RotInertia GetRotInertia(const WorldImpl& world, BodyID id)
{
    return Real{1} / GetInvRotInertia(world, id);
}

/// @brief Gets the rotational inertia of the body about the local origin.
/// @return the rotational inertia.
/// @relatedalso WorldImpl
inline RotInertia GetLocalRotInertia(const WorldImpl& world, BodyID id)
{
    return GetRotInertia(world, id)
         + GetMass(world, id) * GetMagnitudeSquared(GetLocalCenter(world, id)) / SquareRadian;
}

/// @brief Gets the range of all joints attached to this body.
/// @relatedalso WorldImpl
SizedRange<std::vector<std::pair<BodyID, JointID>>::const_iterator>
GetJoints(const WorldImpl& world, BodyID id);

/// @brief Gets the range of all constant fixtures attached to the given body.
/// @relatedalso WorldImpl
SizedRange<std::vector<FixtureID>::const_iterator>
GetFixtures(const WorldImpl& world, BodyID id);

/// @relatedalso WorldImpl
void DestroyFixtures(WorldImpl& world, BodyID id);

/// @brief Gets the enabled/disabled state of the body.
/// @see SetEnabled.
/// @relatedalso WorldImpl
bool IsEnabled(const WorldImpl& world, BodyID id);

/// @brief Sets the enabled state of the body.
///
/// @details A disabled body is not simulated and cannot be collided with or woken up.
///   If you pass a flag of true, all fixtures will be added to the broad-phase.
///   If you pass a flag of false, all fixtures will be removed from the broad-phase
///   and all contacts will be destroyed. Fixtures and joints are otherwise unaffected.
///
/// @note A disabled body is still owned by a World object and remains in the world's
///   body container.
/// @note You may continue to create/destroy fixtures and joints on disabled bodies.
/// @note Fixtures on a disabled body are implicitly disabled and will not participate in
///   collisions, ray-casts, or queries.
/// @note Joints connected to a disabled body are implicitly disabled.
///
/// @throws WrongState If call would change body's state when world is locked.
///
/// @post <code>IsEnabled()</code> returns the state given to this function.
///
/// @see IsEnabled.
/// @relatedalso WorldImpl
void SetEnabled(WorldImpl& world, BodyID body, bool flag);

/// @brief Is identified body "speedable".
/// @details Is the body able to have a non-zero speed associated with it.
/// Kinematic and Dynamic bodies are speedable. Static bodies are not.
/// @relatedalso WorldImpl
bool IsSpeedable(const WorldImpl& world, BodyID id);

/// @brief Is identified body "accelerable"?
/// @details Indicates whether the body is accelerable, i.e. whether it is effected by
///   forces. Only Dynamic bodies are accelerable.
/// @return true if the body is accelerable, false otherwise.
/// @relatedalso WorldImpl
bool IsAccelerable(const WorldImpl& world, BodyID id);

/// @brief Gets the container of all contacts attached to this body.
/// @warning This collection changes during the time step and you may
///   miss some collisions if you don't use <code>ContactListener</code>.
/// @relatedalso WorldImpl
SizedRange<std::vector<KeyedContactPtr>::const_iterator>
GetContacts(const WorldImpl& world, BodyID id);

/// @brief Gets whether the body's mass-data is dirty.
/// @relatedalso WorldImpl
bool IsMassDataDirty(const WorldImpl& world, BodyID id);

/// @brief Gets whether the body has fixed rotation.
/// @see SetFixedRotation(WorldImpl& world, BodyID id, bool value).
/// @relatedalso WorldImpl
bool IsFixedRotation(const WorldImpl& world, BodyID id);

/// @brief Sets this body to have fixed rotation.
/// @note This causes the mass to be reset.
/// @see IsFixedRotation(const WorldImpl& world, BodyID id).
/// @relatedalso WorldImpl
void SetFixedRotation(WorldImpl& world, BodyID id, bool value);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDIMPLBODY_HPP
