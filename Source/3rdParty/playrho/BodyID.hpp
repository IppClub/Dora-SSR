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

#ifndef PLAYRHO_BODYID_HPP
#define PLAYRHO_BODYID_HPP

/// @file
/// @brief Definition of the <code>BodyID</code> alias and closely related code.

// IWYU pragma: begin_exports

#include "playrho/detail/IndexingNamedType.hpp"
#include "playrho/Settings.hpp" // for BodyCounter

// IWYU pragma: end_exports

namespace playrho {

/// @brief Body identifier.
/// @details A strongly typed identifier for uniquely identifying bodes within
///   @c playrho::d2::World instances.
///   This is based on the @c playrho::BodyCounter type as its underlying type.
///   These identifiers can be compared with other body identifiers.
///   Two body identifiers from the same world that compare equal for example,
///   identify the same body within that world.
/// @see InvalidBodyID, BodyCounter, ContactID, JointID, ShapeID, d2::Body, d2::World.
using BodyID = detail::IndexingNamedType<BodyCounter, struct BodyIdentifier>;

/// @brief Invalid body ID value.
/// @details A special, reserved value of a @c playrho::BodyID that
///   represents/identifies an _invalid_ body.
/// @see BodyID, IsValid.
constexpr auto InvalidBodyID = BodyID{static_cast<BodyID::underlying_type>(-1)};

/// @brief Determines validity of given value by comparing against
///   @c playrho::InvalidBodyID .
/// @return true if not equal to @c playrho::InvalidBodyID , else false.
/// @see BodyID, InvalidBodyID.
constexpr auto IsValid(const BodyID& value) noexcept -> bool
{
    return value != InvalidBodyID;
}

} // namespace playrho

#endif // PLAYRHO_BODYID_HPP
