/*
 * Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COMMON_NONNEGATIVE_HPP
#define PLAYRHO_COMMON_NONNEGATIVE_HPP

#include "PlayRho/Common/CheckedValue.hpp"

namespace playrho {

/// @brief Non-negative constrained value checker.
template <typename T>
struct NonNegativeChecker {
    /// @brief Exception type possibly thrown by this checker.
    using exception_type = std::invalid_argument;

    /// @brief Valid value supplying functor.
    constexpr auto operator()() noexcept -> decltype(static_cast<T>(0))
    {
        return static_cast<T>(0);
    }

    /// @brief Value checking functor.
    /// @throws exception_type if given value is not valid.
    constexpr auto operator()(const T& v) -> decltype(!(v >= static_cast<T>(0)), T{v})
    {
        if (!(v >= static_cast<T>(0))) {
            throw exception_type("value not greater than nor equal to zero");
        }
        return v;
    }
};

/// @ingroup CheckedValues
/// @brief Non-negative constrained value type.
template <typename T>
using NonNegative = CheckedValue<T, NonNegativeChecker<T>>;

static_assert(std::is_default_constructible<NonNegative<int>>::value);

} // namespace playrho

#endif // PLAYRHO_COMMON_NONNEGATIVE_HPP
