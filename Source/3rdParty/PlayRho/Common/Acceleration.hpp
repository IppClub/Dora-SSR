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

#ifndef PLAYRHO_COMMON_ACCELERATION_HPP
#define PLAYRHO_COMMON_ACCELERATION_HPP

#include "PlayRho/Common/Settings.hpp"
#include "PlayRho/Common/Vector2.hpp"

namespace playrho {
namespace d2 {

    /// @brief 2-D acceleration related data structure.
    /// @note This data structure is 12-bytes (with 4-byte Real on at least one 64-bit platform).
    struct Acceleration
    {
        LinearAcceleration2 linear; ///< Linear acceleration.
        AngularAcceleration angular; ///< Angular acceleration.
    };
    
    /// @brief Equality operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline bool operator==(const Acceleration& lhs, const Acceleration& rhs)
    {
        return (lhs.linear == rhs.linear) && (lhs.angular == rhs.angular);
    }
    
    /// @brief Inequality operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline bool operator!=(const Acceleration& lhs, const Acceleration& rhs)
    {
        return (lhs.linear != rhs.linear) || (lhs.angular != rhs.angular);
    }
    
    /// @brief Multiplication assignment operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration& operator*= (Acceleration& lhs, const Real rhs)
    {
        lhs.linear *= rhs;
        lhs.angular *= rhs;
        return lhs;
    }
    
    /// @brief Division assignment operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration& operator/= (Acceleration& lhs, const Real rhs)
    {
        lhs.linear /= rhs;
        lhs.angular /= rhs;
        return lhs;
    }
    
    /// @brief Addition assignment operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration& operator+= (Acceleration& lhs, const Acceleration& rhs)
    {
        lhs.linear += rhs.linear;
        lhs.angular += rhs.angular;
        return lhs;
    }
    
    /// @brief Addition operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration operator+ (const Acceleration& lhs, const Acceleration& rhs)
    {
        return Acceleration{lhs.linear + rhs.linear, lhs.angular + rhs.angular};
    }
    
    /// @brief Subtraction assignment operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration& operator-= (Acceleration& lhs, const Acceleration& rhs)
    {
        lhs.linear -= rhs.linear;
        lhs.angular -= rhs.angular;
        return lhs;
    }
    
    /// @brief Subtraction operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration operator- (const Acceleration& lhs, const Acceleration& rhs)
    {
        return Acceleration{lhs.linear - rhs.linear, lhs.angular - rhs.angular};
    }
    
    /// @brief Negation operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration operator- (const Acceleration& value)
    {
        return Acceleration{-value.linear, -value.angular};
    }
    
    /// @brief Positive operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration operator+ (const Acceleration& value)
    {
        return value;
    }
    
    /// @brief Multiplication operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration operator* (const Acceleration& lhs, const Real rhs)
    {
        return Acceleration{lhs.linear * rhs, lhs.angular * rhs};
    }
    
    /// @brief Multiplication operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration operator* (const Real lhs, const Acceleration& rhs)
    {
        return Acceleration{rhs.linear * lhs, rhs.angular * lhs};
    }
    
    /// @brief Division operator.
    /// @relatedalso Acceleration
    PLAYRHO_CONSTEXPR inline Acceleration operator/ (const Acceleration& lhs, const Real rhs)
    {
        const auto inverseRhs = Real{1} / rhs;
        return Acceleration{lhs.linear * inverseRhs, lhs.angular * inverseRhs};
    }
    
} // namespace d2

/// @brief Determines if the given value is valid.
/// @relatedalso playrho::d2::Acceleration
template <>
PLAYRHO_CONSTEXPR inline bool IsValid(const d2::Acceleration& value) noexcept
{
    return IsValid(value.linear) && IsValid(value.angular);
}

} // namespace playrho

#endif // PLAYRHO_COMMON_ACCELERATION_HPP

