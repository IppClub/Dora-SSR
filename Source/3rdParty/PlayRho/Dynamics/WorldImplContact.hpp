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
class Contact;
class Manifold;

/// @brief Gets the extent of the currently valid contact range.
/// @note This is one higher than the maxium <code>ContactID</code> that is in range
///   for contact related functions.
/// @relatedalso WorldImpl
ContactCounter GetContactRange(const WorldImpl& world) noexcept;

/// @brief Gets the identified contact.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso WorldImpl
const Contact& GetContact(const WorldImpl& world, ContactID id);

/// @brief Sets the identified contact's state.
/// @throws std::out_of_range If given an invalid contact identifier.
/// @relatedalso WorldImpl
void SetContact(WorldImpl& world, ContactID id, const Contact& value);

/// @brief Gets the collision manifold for the identified contact.
const Manifold& GetManifold(const WorldImpl& world, ContactID id);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDIMPLCONTACT_HPP
