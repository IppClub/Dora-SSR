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

#ifndef PLAYRHO_DETAIL_FINITECHECKER_HPP
#define PLAYRHO_DETAIL_FINITECHECKER_HPP

/// @file
/// @brief Definition of the @c FiniteChecker class template.

// IWYU pragma: begin_exports

// IWYU pragma: private, include "playrho/Finite.hpp"

#include "playrho/Math.hpp" // for playrho::isfinite

// IWYU pragma: end_exports

namespace playrho::detail {

/// @brief Finite constrained value checker.
/// @note This is meant to be used as a checker with types like <code>Checked</code>.
/// @tparam T Underlying type for this checker.
/// @ingroup Checkers
/// @see Checked.
template <typename T>
struct FiniteChecker {

    /// @brief Default value supplying functor.
    /// @return Always returns the zero initialized value of the underlying type.
    constexpr auto operator()() const noexcept(noexcept(static_cast<T>(0))) -> decltype(T{})
    {
        return T{};
    }

    /// @brief Value checking functor.
    /// @return Null string if given value is finite, else
    ///   a non-null string explanation.
    auto operator()(const T& v) const noexcept(noexcept(isfinite(v)))
        -> decltype(isfinite(v), static_cast<const char*>(nullptr))
    {
        if (!isfinite(v)) {
            return "value not finite";
        }
        return {};
    }
};

} // namespace playrho::detail

#endif // PLAYRHO_DETAIL_FINITECHECKER_HPP
