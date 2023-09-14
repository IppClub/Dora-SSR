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

#ifndef PLAYRHO_NONZERO_HPP
#define PLAYRHO_NONZERO_HPP

#include "playrho/CheckedValue.hpp"

namespace playrho {

/// @brief Non-zero constrained value checker.
template <typename T>
struct NonZeroChecker {

    /// @brief Value checking functor.
    constexpr auto operator()(const T& v) noexcept
        -> decltype(!(v != static_cast<T>(0)), static_cast<const char*>(nullptr))
    {
        if (!(v != static_cast<T>(0))) {
            return "value not non-zero";
        }
        return {};
    }
};

/// @ingroup CheckedValues
/// @brief Non-zero constrained value type.
template <typename T>
using NonZero = std::enable_if_t<!std::is_pointer<T>::value, CheckedValue<T, NonZeroChecker<T>>>;

/// @ingroup CheckedValues
/// @brief Fast failing non-zero constrained value type.
template <typename T>
using NonZeroFF = std::enable_if_t<!std::is_pointer<T>::value, CheckedValue<T, NonZeroChecker<T>, true>>;

static_assert(!std::is_default_constructible<NonZero<int>>::value);

/// @ingroup CheckedValues
/// @brief Non-null constrained value type.
template <typename T>
using NonNull = std::enable_if_t<std::is_pointer<T>::value, CheckedValue<T, NonZeroChecker<T>>>;

/// @ingroup CheckedValues
/// @brief Fast failing non-null constrained value type.
template <typename T>
using NonNullFF = std::enable_if_t<std::is_pointer<T>::value, CheckedValue<T, NonZeroChecker<T>, true>>;

static_assert(!std::is_default_constructible<NonNull<int*>>::value);

} // namespace playrho

#endif // PLAYRHO_NONZERO_HPP
