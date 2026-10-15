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

#ifndef PLAYRHO_JOINTID_HPP
#define PLAYRHO_JOINTID_HPP

/// @file
/// @brief Definition of the @c JointID alias and closely related code.

// IWYU pragma: begin_exports

#include "playrho/detail/IndexingNamedType.hpp"
#include "playrho/Settings.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Joint identifier.
/// @details A strongly typed identifier for uniquely identifying joints within
///   @c playrho::d2::World instances.
///   This is based on the @c playrho::JointCounter type as its underlying type.
///   These identifiers can be compared with other joint identifiers.
///   Two joint identifiers from the same world that compare equal for example,
///   identify the same joint within that world.
/// @see InvalidJointID, JointCounter, BodyID, ContactID, ShapeID, d2::Joint, d2::World.
using JointID = detail::IndexingNamedType<JointCounter, struct JointIdentifier>;

/// @brief Invalid joint ID value.
/// @details A special, reserved value of a @c playrho::JointID that
///   represents/identifies an _invalid_ joint.
/// @see JointID, IsValid.
constexpr auto InvalidJointID = JointID{static_cast<JointID::underlying_type>(-1)};

/// @brief Determines validity of given value by comparing against
///   @c playrho::InvalidJointID .
/// @return true if not equal to @c playrho::InvalidJointID , else false.
/// @see JointID, InvalidJointID.
constexpr auto IsValid(const JointID& value) noexcept -> bool
{
    return value != InvalidJointID;
}

} // namespace playrho

#endif // PLAYRHO_JOINTID_HPP
