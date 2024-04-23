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

#ifndef PLAYRHO_VECTOR3_HPP
#define PLAYRHO_VECTOR3_HPP

/// @file
/// @brief Definition of the @c Vector3 alias template and closely related code.

// IWYU pragma: begin_exports

#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Vector with 3-elements.
/// @note This is just a C++11 alias template for 3-element uses of the Vector template.
template <typename T>
using Vector3 = Vector<T, 3>;

/// A 3-dimensional column vector with 3 elements.
using Vec3 = Vector3<Real>;

/// @brief 3-element vector of Mass quantities.
using Mass3 = Vector3<Mass>;

/// @brief 3-element vector of inverse mass (<code>InvMass</code>) quantities.
using InvMass3 = Vector3<InvMass>;

/// @brief Determines whether the given vector contains finite coordinates.
constexpr auto IsValid(const Vec3& value) noexcept -> bool
{
    return IsValid(get<0>(value)) && IsValid(get<1>(value)) && IsValid(get<2>(value));
}

} // namespace playrho

#endif // PLAYRHO_VECTOR3_HPP
