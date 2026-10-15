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

#ifndef PLAYRHO_DETAIL_CHECKEDMATH_HPP
#define PLAYRHO_DETAIL_CHECKEDMATH_HPP

/// @file
/// @brief Conventional math functions for the @c Checked class template.

#include <cmath> // for std::nextafter

// IWYU pragma: begin_exports

#include "playrho/detail/Checked.hpp"

// IWYU pragma: end_exports

namespace playrho::detail {

/// @defgroup CheckedMath Math Functions For Checked Types
/// @brief Common Mathematical Functions For Checked Types.
/// @see Checked
/// @see https://en.cppreference.com/w/cpp/numeric/math
/// @{

/// @brief Computes the absolute value.
/// @see https://en.cppreference.com/w/cpp/numeric/math/fabs
template <class ValueType, class Checker, bool NoExcept>
auto abs(const Checked<ValueType, Checker, NoExcept>& arg)
-> decltype(Checked<ValueType, Checker, false>(abs(arg.get())))
{
    using std::abs;
    return abs(arg.get());
}

/// @brief Next after function.
/// @see https://en.cppreference.com/w/cpp/numeric/math/nextafter
template <class ValueType, class Checker, bool NoExcept>
auto nextafter(const Checked<ValueType, Checker, NoExcept>& from, // force newline
               const Checked<ValueType, Checker, NoExcept>& to)
-> decltype(Checked<ValueType, Checker, false>(nextafter(from.get(), to.get())))
{
    using std::nextafter;
    return nextafter(from.get(), to.get());
}

/// @}

} // namespace playrho::detail

#endif // PLAYRHO_DETAIL_CHECKEDMATH_HPP
