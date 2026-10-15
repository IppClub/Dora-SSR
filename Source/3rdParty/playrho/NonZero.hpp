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

/// @file
/// @brief Definition of the @c NonZero value checked types.

#include <type_traits> // for std::is_default_constructible_v, std::enable_if_t

// IWYU pragma: begin_exports

#include "playrho/detail/Checked.hpp"
#include "playrho/detail/NonZeroChecker.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @ingroup CheckedTypes
/// @brief Non-zero constrained value type.
template <typename T>
using NonZero = std::enable_if_t<!std::is_pointer_v<T>, detail::Checked<T, detail::NonZeroChecker<T>>>;

/// @ingroup CheckedTypes
/// @brief Fast failing non-zero constrained value type.
template <typename T>
using NonZeroFF = std::enable_if_t<!std::is_pointer_v<T>, detail::Checked<T, detail::NonZeroChecker<T>, true>>;

static_assert(!std::is_default_constructible_v<NonZero<int>>);

/// @ingroup CheckedTypes
/// @brief Non-null constrained value type.
template <typename T>
using NonNull = std::enable_if_t<std::is_pointer_v<T>, detail::Checked<T, detail::NonZeroChecker<T>>>;

/// @ingroup CheckedTypes
/// @brief Fast failing non-null constrained value type.
template <typename T>
using NonNullFF = std::enable_if_t<std::is_pointer_v<T>, detail::Checked<T, detail::NonZeroChecker<T>, true>>;

static_assert(!std::is_default_constructible_v<NonNull<int*>>);

} // namespace playrho

#endif // PLAYRHO_NONZERO_HPP
