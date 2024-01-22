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

#ifndef PLAYRHO_DETAIL_UNITINTERVALCHECKER_HPP
#define PLAYRHO_DETAIL_UNITINTERVALCHECKER_HPP

/// @file
/// @brief Definition of the @c UnitIntervalChecker class template.

// IWYU pragma: private, include "playrho/UnitInterval.hpp"

namespace playrho::detail {

/// @brief Unit-interval constrained value checker.
/// @details Provides functors ensuring values are:
///   greater-than or equal-to zero, and less-than or equal-to one. By definition, this
///   is called the "closed interval [0, 1]".
/// @note This is meant to be used as a checker with types like <code>Checked</code>.
/// @tparam T Underlying type for this checker.
/// @ingroup Checkers
/// @see Checked.
/// @see https://en.wikipedia.org/wiki/Unit_interval.
template <typename T>
struct UnitIntervalChecker {

    /// @brief Default value supplying functor.
    /// @return Zero casted to the checked type.
    constexpr auto operator()() const noexcept -> decltype(static_cast<T>(0))
    {
        return static_cast<T>(0);
    }

    /// @brief Value checking functor.
    /// @return @c nullptr if the given value is within 0 and 1 inclusively, else a
    ///   non-null pointer to the C-style nul-terminated string indicating whether the
    ///   value is less than zero or greater than 1.
    constexpr auto operator()(const T& v) const noexcept
        -> decltype((v >= static_cast<T>(0)) && (v <= static_cast<T>(1)), static_cast<const char*>(nullptr))
    {
        if (!(v >= static_cast<T>(0))) {
            return "value not greater than nor equal to zero";
        }
        if (!(v <= static_cast<T>(1))) {
            return "value not less than nor equal to one";
        }
        return {};
    }
};

} // namespace playrho::detail

#endif // PLAYRHO_DETAIL_UNITINTERVALCHECKER_HPP
