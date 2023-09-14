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

#ifndef PLAYRHO_FINITE_HPP
#define PLAYRHO_FINITE_HPP

#include "playrho/CheckedValue.hpp"
#include "playrho/Math.hpp" // for playrho::isfinite

namespace playrho {

/// @brief Finite constrained value checker.
template <typename T>
struct FiniteChecker {

    /// @brief Default value supplying functor.
    constexpr auto operator()() noexcept(noexcept(static_cast<T>(0))) -> decltype(static_cast<T>(0))
    {
        return static_cast<T>(0);
    }

    /// @brief Value checking functor.
    auto operator()(const T& v) noexcept(noexcept(isfinite(v)))
        -> decltype(isfinite(v), static_cast<const char*>(nullptr))
    {
        if (!isfinite(v)) {
            return "value not finite";
        }
        return {};
    }
};

/// @ingroup CheckedValues
/// @brief Finite constrained value type.
template <typename T>
using Finite = CheckedValue<T, FiniteChecker<T>>;

/// @ingroup CheckedValues
/// @brief Fast failing finite constrained value type.
template <typename T>
using FiniteFF = CheckedValue<T, FiniteChecker<T>, true>;

static_assert(std::is_default_constructible<Finite<int>>::value);

} // namespace playrho

#endif // PLAYRHO_FINITE_HPP
