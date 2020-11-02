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

#ifndef PLAYRHO_DYNAMICS_WORLDIMPLCONTACT_HPP
#define PLAYRHO_DYNAMICS_WORLDIMPLCONTACT_HPP

/// @file
/// Declarations of free functions of WorldImpl for contacts.

#include "PlayRho/Common/Real.hpp"

#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/FixtureID.hpp"
#include "PlayRho/Dynamics/Contacts/ContactID.hpp"

namespace playrho {
namespace d2 {

class WorldImpl;
class Manifold;

/// @brief Gets the awake status of the specified contact.
/// @see SetAwake(WorldImpl& world, ContactID id)
/// @relatedalso WorldImpl
bool IsAwake(const WorldImpl& world, ContactID id);

/// @brief Sets awake the bodies of the fixtures of the given contact.
/// @see IsAwake(const WorldImpl& world, ContactID id)
/// @relatedalso WorldImpl
void SetAwake(WorldImpl& world, ContactID id);

/// @brief Is this contact touching?
/// @details
/// Touching is defined as either:
///   1. This contact's manifold has more than 0 contact points, or
///   2. This contact has sensors and the two shapes of this contact are found to be
///      overlapping.
/// @return true if this contact is said to be touching, false otherwise.
/// @relatedalso WorldImpl
bool IsTouching(const WorldImpl& world, ContactID id);

/// @brief Whether or not the contact needs filtering.
/// @relatedalso WorldImpl
bool NeedsFiltering(const WorldImpl& world, ContactID id);

/// @brief Whether or not the contact needs updating.
/// @relatedalso WorldImpl
bool NeedsUpdating(const WorldImpl& world, ContactID id);

/// @brief Whether or not the contact has a valid TOI.
/// @relatedalso WorldImpl
bool HasValidToi(const WorldImpl& world, ContactID id);

/// @brief Gets the time of impact (TOI) as a fraction.
/// @note This is only valid if a TOI has been set.
/// @return Time of impact fraction in the range of 0 to 1 if set (where 1
///   means no actual impact in current time slot), otherwise undefined.
/// @relatedalso WorldImpl
Real GetToi(const WorldImpl& world, ContactID id);

/// @relatedalso WorldImpl
BodyID GetBodyA(const WorldImpl& world, ContactID id);

/// @relatedalso WorldImpl
BodyID GetBodyB(const WorldImpl& world, ContactID id);

/// @brief Gets fixture A of the given contact.
/// @relatedalso WorldImpl
FixtureID GetFixtureA(const WorldImpl& world, ContactID id);

/// @brief Gets fixture B of the given contact.
/// @relatedalso WorldImpl
FixtureID GetFixtureB(const WorldImpl& world, ContactID id);

/// @brief Get the child primitive index for fixture A.
/// @relatedalso WorldImpl
ChildCounter GetChildIndexA(const WorldImpl& world, ContactID id);

/// @brief Get the child primitive index for fixture B.
/// @relatedalso WorldImpl
ChildCounter GetChildIndexB(const WorldImpl& world, ContactID id);

/// @relatedalso WorldImpl
TimestepIters GetToiCount(const WorldImpl& world, ContactID id);

/// @relatedalso WorldImpl
Real GetDefaultFriction(const WorldImpl& world, ContactID id);

/// @relatedalso WorldImpl
Real GetDefaultRestitution(const WorldImpl& world, ContactID id);

/// @brief Gets the friction used with the specified contact.
/// @see SetFriction(ContactID id, Real value)
Real GetFriction(const WorldImpl& world, ContactID id);

/// @brief Sets the friction value for the specified contact.
/// @details Overrides the default friction mixture.
/// @note You can call this in "pre-solve" listeners.
/// @note This value persists until set or reset.
/// @warning Behavior is undefined if given a negative friction value.
/// @param value Co-efficient of friction value of zero or greater.
void SetFriction(WorldImpl& world, ContactID id, Real value);

/// @brief Gets the restitution used with the specified contact.
/// @see SetRestitution(ContactID id, Real value)
Real GetRestitution(const WorldImpl& world, ContactID id);

/// @brief Sets the restitution value for the specified contact.
/// @details This override the default restitution mixture.
/// @note You can call this in "pre-solve" listeners.
/// @note The value persists until you set or reset.
void SetRestitution(WorldImpl& world, ContactID id, Real value);

/// @brief Gets the collision manifold for the identified contact.
const Manifold& GetManifold(const WorldImpl& world, ContactID id);

/// @relatedalso WorldImpl
LinearVelocity GetTangentSpeed(const WorldImpl& world, ContactID id);

/// @relatedalso WorldImpl
void SetTangentSpeed(WorldImpl& world, ContactID id, LinearVelocity value);

/// @relatedalso WorldImpl
bool IsEnabled(const WorldImpl& world, ContactID id);

/// @relatedalso WorldImpl
void SetEnabled(WorldImpl& world, ContactID id);

/// @relatedalso WorldImpl
void UnsetEnabled(WorldImpl& world, ContactID id);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDIMPLCONTACT_HPP
