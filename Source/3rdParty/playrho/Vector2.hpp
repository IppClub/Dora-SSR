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

#ifndef PLAYRHO_VECTOR2_HPP
#define PLAYRHO_VECTOR2_HPP

/// @file
/// @brief Definition of the @c Vector2 alias template and closely related code.

// IWYU pragma: begin_exports

#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Vector with 2-elements.
/// @note This is just a C++11 alias template for 2-element uses of the Vector template.
template <typename T>
using Vector2 = Vector<T, 2>;

/// @brief Vector with 2 Real elements.
/// @note This data structure is two-times the size of the <code>Real</code> type
///   (or 8 using Real of float).
using Vec2 = Vector2<Real>;

/// @brief 2-element vector of Length quantities.
/// @note Often used as a 2-dimensional distance or location vector.
using Length2 = Vector2<Length>;

/// @brief Invalid @c Length2 constant.
constexpr auto InvalidLength2 = Length2{Invalid<Length>, Invalid<Length>};

/// @brief 2-element vector of linear velocity (<code>LinearVelocity</code>) quantities.
/// @note Often used as a 2-dimensional speed vector.
using LinearVelocity2 = Vector2<LinearVelocity>;

/// @brief 2-element vector of linear acceleration (<code>LinearAcceleration</code>) quantities.
/// @note Often used as a 2-dimensional linear acceleration vector.
using LinearAcceleration2 = Vector2<LinearAcceleration>;

/// @brief 2-element vector of Force quantities.
/// @note Often used as a 2-dimensional force vector.
using Force2 = Vector2<Force>;

/// @brief 2-element vector of Mass quantities.
using Mass2 = Vector2<Mass>;

/// @brief 2-element vector of inverse mass (<code>InvMass</code>) quantities.
using InvMass2 = Vector2<InvMass>;

/// @brief 2-element vector of Momentum quantities.
/// @note Often used as a 2-dimensional momentum vector.
using Momentum2 = Vector2<Momentum>;

/// @brief Gets the given value as a 2-element vector of reals (<code>Vec2</code>).
constexpr auto GetVec2(const Vector2<Real>& value) -> Vec2
{
    return value;
}

/// @brief Gets value as 2-element vector of reals for any type having <code>value()</code> member function.
template <class T>
constexpr auto GetVec2(const Vector2<T>& value)
-> decltype(Vec2{static_cast<Real>(get<0>(value).value()), static_cast<Real>(get<1>(value).value())})
{
    return {static_cast<Real>(get<0>(value).value()), static_cast<Real>(get<1>(value).value())};
}

/// @brief Gets a vector counter-clockwise (reverse-clockwise) perpendicular to the given vector.
/// @details This takes a vector of form (x, y) and returns the vector (-y, x).
/// @param vector Vector to return a counter-clockwise perpendicular equivalent for.
/// @return A counter-clockwise 90-degree rotation of the given vector.
/// @see GetFwdPerpendicular.
template <class T>
constexpr auto GetRevPerpendicular(const Vector2<T>& vector) noexcept -> Vector2<T>
{
    // See http://mathworld.wolfram.com/PerpendicularVector.html
    return {-get<1>(vector), get<0>(vector)};
}

/// @brief Gets a vector clockwise (forward-clockwise) perpendicular to the given vector.
/// @details This takes a vector of form (x, y) and returns the vector (y, -x).
/// @param vector Vector to return a clockwise perpendicular equivalent for.
/// @return A clockwise 90-degree rotation of the given vector.
/// @see GetRevPerpendicular.
template <class T>
constexpr auto GetFwdPerpendicular(const Vector2<T>& vector) noexcept -> Vector2<T>
{
    // See http://mathworld.wolfram.com/PerpendicularVector.html
    return {get<1>(vector), -get<0>(vector)};
}

/// @brief Determines whether the given vector contains finite coordinates.
template <typename TYPE>
constexpr auto IsValid(const Vector2<TYPE>& value) noexcept -> bool
{
    return IsValid(get<0>(value)) && IsValid(get<1>(value));
}

namespace d2 {

/// @brief Earthly gravity in 2-dimensions.
/// @details Linear acceleration in 2-dimensions of an earthly object due to Earth's mass.
/// @see EarthlyLinearAcceleration
constexpr auto EarthlyGravity = LinearAcceleration2{0_mps2, EarthlyLinearAcceleration};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_VECTOR2_HPP
