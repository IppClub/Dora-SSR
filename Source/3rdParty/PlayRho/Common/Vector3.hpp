/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COMMON_VECTOR3_HPP
#define PLAYRHO_COMMON_VECTOR3_HPP

#include "PlayRho/Common/Settings.hpp"
#include "PlayRho/Common/Vector.hpp"

namespace playrho {

/// @brief Vector with 3-elements.
/// @note This is just a C++11 alias template for 3-element uses of the Vector template.
template <typename T>
using Vector3 = Vector<T, 3>;

/// A 3-dimensional column vector with 3 elements.
/// @note This data structure is 3 times the size of <code>Real</code> -
///   i.e. 12-bytes (with 4-byte Real).
using Vec3 = Vector3<Real>;

/// @brief 3-element vector of Mass quantities.
using Mass3 = Vector3<Mass>;

/// @brief 3-element vector of inverse mass (<code>InvMass</code>) quantities.
using InvMass3 = Vector3<InvMass>;

/// @brief Gets an invalid value for the 3-element vector of real (<code>Vec3</code>) type.
template <>
PLAYRHO_CONSTEXPR inline Vec3 GetInvalid() noexcept
{
    return Vec3{GetInvalid<Real>(), GetInvalid<Real>(), GetInvalid<Real>()};
}

/// @brief Determines whether the given vector contains finite coordinates.
template <>
PLAYRHO_CONSTEXPR inline bool IsValid(const Vec3& value) noexcept
{
    return IsValid(get<0>(value)) && IsValid(get<1>(value)) && IsValid(get<2>(value));
}

} // namespace playrho

#endif // PLAYRHO_COMMON_VECTOR3_HPP
