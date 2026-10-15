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

#ifndef PLAYRHO_UNITINTERVAL_HPP
#define PLAYRHO_UNITINTERVAL_HPP

/// @file
/// @brief Definition of the @c UnitInterval value checked types and related code.

#include <type_traits> // for std::is_default_constructible_v

// IWYU pragma: begin_exports

#include "playrho/detail/Checked.hpp"
#include "playrho/detail/UnitIntervalChecker.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @ingroup CheckedTypes
/// @brief Unit interval constrained value type.
template <typename T>
using UnitInterval = detail::Checked<T, detail::UnitIntervalChecker<T>>;

/// @ingroup CheckedTypes
/// @brief Fast failing unit interval constrained value type.
template <typename T>
using UnitIntervalFF = detail::Checked<T, detail::UnitIntervalChecker<T>, true>;

static_assert(std::is_default_constructible_v<UnitInterval<int>>);

} // namespace playrho

#endif // PLAYRHO_UNITINTERVAL_HPP
