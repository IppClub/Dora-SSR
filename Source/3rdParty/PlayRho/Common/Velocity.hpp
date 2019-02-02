/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COMMON_VELOCITY_HPP
#define PLAYRHO_COMMON_VELOCITY_HPP

#include "PlayRho/Common/Settings.hpp"
#include "PlayRho/Common/Vector2.hpp"
#include <utility>

namespace playrho {
namespace d2 {

class VelocityConstraint;

/// @brief 2-D velocity related data structure.
/// @note This data structure is 12-bytes (with 4-byte Real on at least one 64-bit platform).
struct Velocity
{
    LinearVelocity2 linear; ///< Linear velocity.
    AngularVelocity angular; ///< Angular velocity.
};

/// @brief Equality operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline bool operator==(const Velocity& lhs, const Velocity& rhs)
{
    return (lhs.linear == rhs.linear) && (lhs.angular == rhs.angular);
}

/// @brief Inequality operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline bool operator!=(const Velocity& lhs, const Velocity& rhs)
{
    return (lhs.linear != rhs.linear) || (lhs.angular != rhs.angular);
}

/// @brief Multiplication assignment operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity& operator*= (Velocity& lhs, const Real rhs)
{
    lhs.linear *= rhs;
    lhs.angular *= rhs;
    return lhs;
}

/// @brief Division assignment operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity& operator/= (Velocity& lhs, const Real rhs)
{
    lhs.linear /= rhs;
    lhs.angular /= rhs;
    return lhs;
}

/// @brief Addition assignment operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity& operator+= (Velocity& lhs, const Velocity& rhs)
{
    lhs.linear += rhs.linear;
    lhs.angular += rhs.angular;
    return lhs;
}

/// @brief Addition operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity operator+ (const Velocity& lhs, const Velocity& rhs)
{
    return Velocity{lhs.linear + rhs.linear, lhs.angular + rhs.angular};
}

/// @brief Subtraction assignment operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity& operator-= (Velocity& lhs, const Velocity& rhs)
{
    lhs.linear -= rhs.linear;
    lhs.angular -= rhs.angular;
    return lhs;
}

/// @brief Subtraction operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity operator- (const Velocity& lhs, const Velocity& rhs)
{
    return Velocity{lhs.linear - rhs.linear, lhs.angular - rhs.angular};
}

/// @brief Negation operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity operator- (const Velocity& value)
{
    return Velocity{-value.linear, -value.angular};
}

/// @brief Positive operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity operator+ (const Velocity& value)
{
    return value;
}

/// @brief Multiplication operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity operator* (const Velocity& lhs, const Real rhs)
{
    return Velocity{lhs.linear * rhs, lhs.angular * rhs};
}

/// @brief Multiplication operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity operator* (const Real lhs, const Velocity& rhs)
{
    return Velocity{rhs.linear * lhs, rhs.angular * lhs};
}

/// @brief Division operator.
/// @relatedalso Velocity
PLAYRHO_CONSTEXPR inline Velocity operator/ (const Velocity& lhs, const Real rhs)
{
    /*
     * While it can be argued that division operations shouldn't be supported due to
     * hardware support for division typically being significantly slower than hardware
     * support for multiplication, it can also be argued that it shouldn't be the
     * software developer's role to attempt to optimize what the compiler should be
     * much better at knowing how to optimize. So here the code chooses the latter
     * strategy which allows the intention to be clearer, and just passes the division
     * on down to the Vec2 and Angle types (rather than manually rewriting the divisions
     * as multiplications).
     */
    return Velocity{lhs.linear / rhs, lhs.angular / rhs};
}

/// @brief Velocity pair.
using VelocityPair = std::pair<Velocity, Velocity>;
    
/// @brief Calculates the "warm start" velocity deltas for the given velocity constraint.
VelocityPair CalcWarmStartVelocityDeltas(const VelocityConstraint& vc);

} // namespace d2

/// @brief Determines if the given value is valid.
/// @relatedalso d2::Velocity
template <>
PLAYRHO_CONSTEXPR inline bool IsValid(const d2::Velocity& value) noexcept
{
    return IsValid(value.linear) && IsValid(value.angular);
}

} // namespace playrho

#endif // PLAYRHO_COMMON_VELOCITY_HPP
