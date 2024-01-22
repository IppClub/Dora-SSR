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

#ifndef PLAYRHO_D2_WORLDCONTACT_HPP
#define PLAYRHO_D2_WORLDCONTACT_HPP

/// @file
/// @brief Declarations of free functions of World for contacts identified by <code>ContactID</code>.
/// @details This is a collection of non-member non-friend functions - also called "free"
///   functions - that are related to contacts within an instance of a <code>World</code>.
///   Many are just "wrappers" to similarly named member functions but some are additional
///   functionality built on those member functions. A benefit to using free functions that
///   are now just wrappers, is that of helping to isolate your code from future changes that
///   might occur to the underlying <code>World</code> member functions. Free functions in
///   this sense are "cheap" abstractions. While using these incurs extra run-time overhead
///   when compiled without any compiler optimizations enabled, enabling optimizations
///   should entirely eliminate that overhead.
/// @note The four basic categories of these functions are "CRUD": create, read, update,
///   and delete.
/// @see World, ContactID.
/// @see https://en.wikipedia.org/wiki/Create,_read,_update_and_delete.

#include <map>
#include <optional>
#include <utility> // for std::pair

// IWYU pragma: begin_exports

#include "playrho/BodyID.hpp"
#include "playrho/ContactID.hpp"
#include "playrho/KeyedContactID.hpp"
#include "playrho/NonNegative.hpp"
#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/ShapeID.hpp"
#include "playrho/UnitInterval.hpp"
#include "playrho/Units.hpp"

#include "playrho/d2/WorldManifold.hpp"

// IWYU pragma: end_exports

namespace playrho {
struct Contactable;
}

namespace playrho::d2 {

class World;
class Manifold;

/// @example WorldContact.cpp
/// This is the <code>googletest</code> based unit testing file for the free function
///   interfaces to <code>playrho::d2::World</code> contact member functions and additional
///   functionality.

/// @brief Is this contact touching?
/// @details
/// Touching is defined as either:
///   1. This contact's manifold has more than 0 contact points, or
///   2. This contact has sensors and the two shapes of this contact are found to be
///      overlapping.
/// @return true if this contact is said to be touching, false otherwise.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
bool IsTouching(const World& world, ContactID id);

/// @brief Gets the awake status of the specified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see SetAwake.
/// @relatedalso World
bool IsAwake(const World& world, ContactID id);

/// @brief Sets awake the bodies of the given contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
void SetAwake(World& world, ContactID id);

/// @brief Gets the body-A of the identified contact if it has one.
/// @return Identification of the body-A or <code>InvalidBodyID</code>.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
BodyID GetBodyA(const World& world, ContactID id);

/// @brief Gets the body-B of the identified contact if it has one.
/// @return Identification of the body-B or <code>InvalidBodyID</code>.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
BodyID GetBodyB(const World& world, ContactID id);

/// @brief Gets shape A of the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
ShapeID GetShapeA(const World& world, ContactID id);

/// @brief Gets shape B of the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
ShapeID GetShapeB(const World& world, ContactID id);

/// @brief Gets the child primitive index A for the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
ChildCounter GetChildIndexA(const World& world, ContactID id);

/// @brief Gets the child primitive index B for the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
ChildCounter GetChildIndexB(const World& world, ContactID id);

/// @brief Gets the Time Of Impact (TOI) count.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
TimestepIters GetToiCount(const World& world, ContactID id);

/// @brief Whether or not the contact needs filtering.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
bool NeedsFiltering(const World& world, ContactID id);

/// @brief Whether or not the contact needs updating.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
bool NeedsUpdating(const World& world, ContactID id);

/// @brief Whether or not the contact has a valid TOI.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see GetToi.
/// @relatedalso World
bool HasValidToi(const World& world, ContactID id);

/// @brief Gets the time of impact (TOI) as a fraction or empty value.
/// @return Time of impact fraction in the range of 0 to 1 if set (where 1
///   means no actual impact in current time slot), otherwise empty.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see HasValidToi.
/// @relatedalso World
std::optional<UnitIntervalFF<Real>> GetToi(const World& world, ContactID id);

/// @brief Gets the default friction amount for the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see SetFriction.
/// @relatedalso World
Real GetDefaultFriction(const World& world, ContactID id);

/// @brief Gets the default restitution amount for the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see SetRestitution.
/// @relatedalso World
Real GetDefaultRestitution(const World& world, ContactID id);

/// @brief Gets the friction used with the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see SetFriction.
/// @relatedalso World
NonNegativeFF<Real> GetFriction(const World& world, ContactID id);

/// @brief Gets the restitution used with the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see SetRestitution(World& world, ContactID id, Real restitution)
/// @relatedalso World
Real GetRestitution(const World& world, ContactID id);

/// @brief Sets the friction value for the identified contact.
/// @note Overrides the default friction mixture. You can call this in "pre-solve"
///   listeners. This value persists until set or reset.
/// @param world The world in which the contact is identified in.
/// @param id Identifier of the contact whose friction value should be set.
/// @param friction Co-efficient of friction value of zero or greater.
/// @post <code>GetFriction(world, id)</code> returns the value set.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see GetFriction(const World&, ContactID).
/// @relatedalso World
void SetFriction(World& world, ContactID id, NonNegative<Real> friction);

/// @brief Sets the restitution value for the specified contact.
/// @details This override the default restitution mixture.
/// @note You can call this in "pre-solve" listeners.
/// @note The value persists until you set or reset.
/// @relatedalso World
void SetRestitution(World& world, ContactID id, Real restitution);

/// @brief Gets the world manifold for the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
WorldManifold GetWorldManifold(const World& world, ContactID id);

/// Resets the friction mixture to the default value.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
inline void ResetFriction(World& world, ContactID id)
{
    SetFriction(world, id, GetDefaultFriction(world, id));
}

/// Resets the restitution to the default value.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
inline void ResetRestitution(World& world, ContactID id)
{
    SetRestitution(world, id, GetDefaultRestitution(world, id));
}

/// @brief Gets the tangent speed of the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
LinearVelocity GetTangentSpeed(const World& world, ContactID id);

/// @brief Sets the desired tangent speed for a conveyor belt behavior.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
void SetTangentSpeed(World& world, ContactID id, LinearVelocity value);

/// @brief Gets the enabled status of the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
bool IsEnabled(const World& world, ContactID id);

/// @brief Sets the enabled status of the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
void SetEnabled(World& world, ContactID id);

/// @brief Unsets the enabled status of the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso World
void UnsetEnabled(World& world, ContactID id);

/// @brief Gets the touching count for the given world.
/// @details Basically a convenience function for iterating over all contact identifiers
///   returned from <code>GetContacts(const World&)</code> for the given world and counting
///   for how many <code>IsTouching(const World&, ContactID)</code> returns true.
/// @see GetContacts(const World&), IsTouching(const World&, ContactID).
/// @relatedalso World
ContactCounter GetTouchingCount(const World& world);

/// @brief Convenience function for setting/unsetting the enabled status of the identified
///   contact based on the value parameter.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @see IsEnabled(const World&, ContactID).
/// @relatedalso World
inline void SetEnabled(World& world, ContactID id, bool value)
{
    if (value) {
        SetEnabled(world, id);
    }
    else {
        UnsetEnabled(world, id);
    }
}

/// @brief Makes a map of contacts in the given world that are in the touching state.
/// @relatedalso World
auto MakeTouchingMap(const World &world)
    -> std::map<std::pair<Contactable, Contactable>, ContactID>;

/// @brief Determines whether the given worlds have the same touching contacts & manifolds.
/// @relatedalso World
auto SameTouching(const World& lhs, const World& rhs) -> bool;

} // namespace playrho::d2

#endif // PLAYRHO_D2_WORLDCONTACT_HPP
