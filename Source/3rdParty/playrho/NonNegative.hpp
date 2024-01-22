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

#ifndef PLAYRHO_NONNEGATIVE_HPP
#define PLAYRHO_NONNEGATIVE_HPP

/// @file
/// @brief Definition of the @c NonNegative value checked types.

#include <type_traits> // for std::is_default_constructible_v

// IWYU pragma: begin_exports

#include "playrho/detail/Checked.hpp"
#include "playrho/detail/NonNegativeChecker.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @ingroup CheckedTypes
/// @brief Non-negative constrained value type.
template <typename T>
using NonNegative = detail::Checked<T, detail::NonNegativeChecker<T>>;

/// @ingroup CheckedTypes
/// @brief Fast failing non-negative constrained value type.
template <typename T>
using NonNegativeFF = detail::Checked<T, detail::NonNegativeChecker<T>, true>;

// Confirm default constructability...
static_assert(std::is_default_constructible_v<NonNegative<float>>);
static_assert(!std::is_nothrow_default_constructible_v<NonNegative<float>>);
static_assert(!std::is_trivially_default_constructible_v<NonNegative<float>>);

// Confirm constructable traits from underlying type...
static_assert((std::is_constructible_v<NonNegative<float>, float>));
static_assert(!(std::is_nothrow_constructible_v<NonNegative<float>, float>));
static_assert(!(std::is_trivially_constructible_v<NonNegative<float>, float>));

// Confirm constructable traits from fail-fast type...
static_assert((std::is_constructible_v<NonNegative<float>, NonNegativeFF<float>>));
static_assert((std::is_nothrow_constructible_v<NonNegative<float>, NonNegativeFF<float>>));
static_assert(!(std::is_trivially_constructible_v<NonNegative<float>, NonNegativeFF<float>>));

// Confirm copy construction traits...
static_assert(std::is_copy_constructible_v<NonNegative<float>>);
static_assert(std::is_nothrow_copy_constructible_v<NonNegative<float>>);
static_assert(std::is_trivially_copy_constructible_v<NonNegative<float>>);

// Confirm move construction traits...
static_assert(std::is_move_constructible_v<NonNegative<float>>);
static_assert(std::is_nothrow_move_constructible_v<NonNegative<float>>);
static_assert(std::is_trivially_move_constructible_v<NonNegative<float>>);

// Confirm copy assignable traits...
static_assert(std::is_copy_assignable_v<NonNegative<float>>);
static_assert(std::is_nothrow_copy_assignable_v<NonNegative<float>>);
static_assert(std::is_trivially_copy_assignable_v<NonNegative<float>>);

// Confirm move assignable traits...
static_assert(std::is_move_assignable_v<NonNegative<float>>);
static_assert(std::is_nothrow_move_assignable_v<NonNegative<float>>);
static_assert(std::is_trivially_move_assignable_v<NonNegative<float>>);

// Confirm destruction traits...
static_assert(std::is_destructible_v<NonNegative<float>>);
static_assert(std::is_nothrow_destructible_v<NonNegative<float>>);
static_assert(std::is_trivially_destructible_v<NonNegative<float>>);

// Confirm convertability traits (repeat of above but for clarity)...
static_assert((std::is_convertible_v<NonNegative<float>, NonNegative<float>::underlying_type>));
static_assert((std::is_convertible_v<NonNegative<float>::underlying_type, NonNegative<float>>));

} // namespace playrho

#endif // PLAYRHO_NONNEGATIVE_HPP
