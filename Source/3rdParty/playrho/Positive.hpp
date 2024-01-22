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

#ifndef PLAYRHO_POSITIVE_HPP
#define PLAYRHO_POSITIVE_HPP

/// @file
/// @brief Definition of the @c Positive value checked types and related code.

#include <limits> // for std::numeric_limits
#include <type_traits> // for std::is_default_constructible_v

// IWYU pragma: begin_exports

#include "playrho/detail/Checked.hpp"
#include "playrho/detail/PositiveChecker.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @ingroup CheckedTypes
/// @brief Positive constrained value type.
template <typename T>
using Positive = detail::Checked<T, detail::PositiveChecker<T>>;

/// @ingroup CheckedTypes
/// @brief Fast failing positive constrained value type.
template <typename T>
using PositiveFF = detail::Checked<T, detail::PositiveChecker<T>, true>;

static_assert(!std::is_default_constructible_v<Positive<int>>);

} // namespace playrho

/// @brief Specialization of <code>std::numeric_limits</code> class template.
/// @see https://en.cppreference.com/w/cpp/types/numeric_limits
template <class T>
class std::numeric_limits<::playrho::Positive<T>> {
public:
    static constexpr bool is_specialized = true; ///< Type is specialized.

    /// @brief Gets the min value available for the type.
    static constexpr auto min() noexcept
    {
        return ::playrho::Positive<T>(numeric_limits<T>::min());
    }

    /// @brief Gets the max value available for the type.
    static constexpr auto max() noexcept
    {
        return ::playrho::Positive<T>(numeric_limits<T>::max());
    }

    /// @brief Gets the lowest value available for the type.
    static constexpr auto lowest() noexcept
    {
        return ::playrho::Positive<T>(numeric_limits<T>::min());
    }

    /// @brief Number of radix digits that can be represented.
    static constexpr int digits = numeric_limits<T>::digits;

    /// @brief Number of decimal digits that can be represented.
    static constexpr int digits10 = numeric_limits<T>::digits10;

    /// @brief Number of decimal digits necessary to differentiate all values.
    static constexpr int max_digits10 = numeric_limits<T>::max_digits10;

    static constexpr bool is_signed = numeric_limits<T>::is_signed; ///< Identifies signed types.
    static constexpr bool is_integer = numeric_limits<T>::is_integer; ///< Identifies integer types.
    static constexpr bool is_exact = numeric_limits<T>::is_exact; ///< Identifies exact type.
    static constexpr int radix = numeric_limits<T>::radix; ///< Radix used by the type.

    /// @brief Gets the epsilon value for the type.
    static constexpr auto epsilon() noexcept
    {
        return ::playrho::Positive<T>(numeric_limits<T>::epsilon());
    }

    /// @brief Gets the round error value for the type.
    static constexpr auto round_error() noexcept
    {
        return ::playrho::Positive<T>(numeric_limits<T>::round_error());
    }

    /// @brief One more than smallest negative power of the radix that's a valid
    ///    normalized floating-point value.
    static constexpr int min_exponent = numeric_limits<T>::min_exponent;

    /// @brief Smallest negative power of ten that's a valid normalized floating-point value.
    static constexpr int min_exponent10 = numeric_limits<T>::min_exponent10;

    /// @brief One more than largest integer power of radix that's a valid finite
    ///   floating-point value.
    static constexpr int max_exponent = numeric_limits<T>::max_exponent;

    /// @brief Largest integer power of 10 that's a valid finite floating-point value.
    static constexpr int max_exponent10 = numeric_limits<T>::max_exponent10;

    static constexpr bool has_infinity = numeric_limits<T>::has_infinity; ///< Whether can represent infinity.
    static constexpr bool has_quiet_NaN = false; ///< Whether can represent quiet-NaN.
    static constexpr bool has_signaling_NaN = false; ///< Whether can represent signaling-NaN.
    static constexpr float_denorm_style has_denorm = numeric_limits<T>::has_denorm; ///< <code>Denorm</code> style used.
    static constexpr bool has_denorm_loss = numeric_limits<T>::has_denorm_loss; ///< Has <code>denorm</code> loss amount.

    /// @brief Gets the infinite value for the type.
    static constexpr auto infinity() noexcept
    {
        return ::playrho::Positive<T>(numeric_limits<T>::infinity());
    }

    /// @brief Gets the <code>denorm</code> value for the type.
    static constexpr auto denorm_min() noexcept
    {
        return ::playrho::Positive<T>(numeric_limits<T>::denorm_min());
    }

    static constexpr bool is_iec559 = false; ///< @brief Not an IEEE 754 floating-point type.
    static constexpr bool is_bounded = true; ///< Type bounded: has limited precision.
    static constexpr bool is_modulo = false; ///< Doesn't modulo arithmetic overflows.

    /// @brief Whether the type for which this is specialized can cause arithmetic operations to trap.
    static constexpr bool traps = numeric_limits<T>::traps;

    /// @brief Doesn't detect <code>tinyness</code> before rounding.
    static constexpr bool tinyness_before = numeric_limits<T>::tinyness_before;

    static constexpr float_round_style round_style = numeric_limits<T>::round_style; ///< Rounds down.
};

#endif // PLAYRHO_POSITIVE_HPP
