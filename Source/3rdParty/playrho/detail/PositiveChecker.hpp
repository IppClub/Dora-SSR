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

#ifndef PLAYRHO_DETAIL_POSITIVECHECKER_HPP
#define PLAYRHO_DETAIL_POSITIVECHECKER_HPP

/// @file
/// @brief Definition of the @c PositiveChecker class template.

// IWYU pragma: private, include "playrho/Positive.hpp"

namespace playrho::detail {

/// @brief Positive constrained value checker.
/// @note This is meant to be used as a checker with types like <code>Checked</code>.
/// @tparam T Underlying type for this checker.
/// @ingroup Checkers
/// @see Checked.
template <typename T>
struct PositiveChecker {

    /// @brief Value checking functor.
    /// @return Null string if given value is greater than zero, else
    ///   a non-null string explanation.
    constexpr auto operator()(const T& v) const noexcept
        -> decltype(v > T{}, static_cast<const char*>(nullptr))
    {
        if (!(v > T{})) {
            return "value not greater than zero";
        }
        return {};
    }
};

} // namespace playrho::detail

#endif // PLAYRHO_DETAIL_POSITIVECHECKER_HPP
