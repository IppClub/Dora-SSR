/*
 * Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_CONTACTID_HPP
#define PLAYRHO_CONTACTID_HPP

/// @file
/// @brief Definition of the @c ContactID alias and closely related code.

// IWYU pragma: begin_exports

#include "playrho/detail/IndexingNamedType.hpp"

#include "playrho/Settings.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Contact identifier.
/// @details A strongly typed identifier for uniquely identifying contacts within
///   @c playrho::d2::World instances.
///   This is based on the @c playrho::ContactCounter type as its underlying type.
///   These identifiers can be compared with other contact identifiers.
///   Two contact identifiers from the same world that compare equal for example,
///   identify the same contact within that world.
/// @see InvalidContactID, Contact, ContactCounter, BodyID, JointID, ShapeID, d2::World.
using ContactID = detail::IndexingNamedType<ContactCounter, struct ContactIdentifier>;

/// @brief Invalid contact ID value.
/// @details A special, reserved value of a @c playrho::ContactID that
///   represents/identifies an _invalid_ contact.
/// @see ContactID, IsValid.
constexpr auto InvalidContactID = ContactID{static_cast<ContactID::underlying_type>(-1)};

/// @brief Determines validity of given value by comparing against
///   @c playrho::InvalidContactID .
/// @return true if not equal to @c playrho::InvalidContactID , else false.
/// @see ContactID, InvalidContactID.
constexpr auto IsValid(const ContactID& value) noexcept -> bool
{
    return value != InvalidContactID;
}

} // namespace playrho

#endif // PLAYRHO_CONTACTID_HPP
