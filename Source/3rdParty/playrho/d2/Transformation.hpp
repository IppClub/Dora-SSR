/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_D2_TRANSFORMATION_HPP
#define PLAYRHO_D2_TRANSFORMATION_HPP

/// @file
/// @brief Definition of the Transformation class and free functions directly associated with it.

// IWYU pragma: begin_exports

#include "playrho/Vector2.hpp"

#include "playrho/d2/UnitVec.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

struct BodyConf;

/// @brief Describes a geometric transformation.
/// @details A transformation contains translation and rotation. It's used to represent
///   the location and direction of things like bodies.
/// @note The default transformation is the identity transformation - the transformation
///   which neither translates nor rotates a location.
struct Transformation
{
    Length2 p = Length2{}; ///< Translational portion of the transformation.
    UnitVec q = UnitVec::GetRight(); ///< Rotational/directional portion of the transformation.
};

/// @brief Identity transformation value.
constexpr auto Transform_identity = Transformation{
    Length2{0_m, 0_m}, UnitVec::GetRight()
};

/// @brief Equality operator.
/// @relatedalso Transformation
constexpr bool operator== (const Transformation& lhs, const Transformation& rhs) noexcept
{
    return (lhs.p == rhs.p) && (lhs.q == rhs.q);
}

/// @brief Inequality operator.
/// @relatedalso Transformation
constexpr bool operator!= (const Transformation& lhs, const Transformation& rhs) noexcept
{
    return (lhs.p != rhs.p) || (lhs.q != rhs.q);
}

/// @brief Gets the location information from the given transformation.
constexpr Length2 GetLocation(const Transformation& value) noexcept
{
    return value.p;
}

/// @brief Gets the directional information from the given transformation.
constexpr UnitVec GetDirection(const Transformation& value) noexcept
{
    return value.q;
}

} // namespace playrho::d2

namespace playrho {

/// @brief Determines if the given value is valid.
/// @relatedalso d2::Transformation
constexpr auto IsValid(const d2::Transformation& value) noexcept -> bool
{
    return IsValid(value.p) && IsValid(value.q);
}

} // namespace playrho

#endif // PLAYRHO_D2_TRANSFORMATION_HPP
