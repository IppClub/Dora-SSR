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

#ifndef PLAYRHO_SHAPEID_HPP
#define PLAYRHO_SHAPEID_HPP

/// @file
/// @brief Definition of the @c ShapeID alias and closely related code.

// IWYU pragma: begin_exports

#include "playrho/detail/IndexingNamedType.hpp"
#include "playrho/Settings.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Shape identifier.
/// @details A strongly typed identifier for uniquely identifying shapes within
///   @c playrho::d2::World instances.
///   This is based on the @c playrho::ShapeCounter type as its underlying type.
///   These identifiers can be compared with other shape identifiers.
///   Two shape identifiers from the same world that compare equal for example,
///   identify the same shape within that world.
/// @see InvalidShapeID, ShapeCounter, BodyID, ContactID, JointID, d2::Shape, d2::World.
using ShapeID = detail::IndexingNamedType<ShapeCounter, struct ShapeIdentifier>;

/// @brief Invalid shape ID value.
/// @details A special, reserved value of a @c playrho::ShapeID that
///   represents/identifies an _invalid_ shape.
/// @see ShapeID, IsValid.
constexpr auto InvalidShapeID = ShapeID{static_cast<ShapeID::underlying_type>(-1)};

/// @brief Determines validity of given value by comparing against
///   @c playrho::InvalidShapeID .
/// @return true if not equal to @c playrho::InvalidShapeID , else false.
/// @see ShapeID, InvalidShapeID.
constexpr auto IsValid(const ShapeID& value) noexcept -> bool
{
    return value != InvalidShapeID;
}

} // namespace playrho

#endif // PLAYRHO_SHAPEID_HPP
