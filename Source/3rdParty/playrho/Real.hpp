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

#ifndef PLAYRHO_REAL_HPP
#define PLAYRHO_REAL_HPP

/**
 * @file
 * @brief Real number definition file.
 */

#include <limits> // for std::numeric_limits

// IWYU pragma: begin_exports

#include "playrho/Templates.hpp" // for IsArithmeticV

// IWYU pragma: end_exports

// Any header(s) for a user defined arithmetic type for Real go here...

namespace playrho {

/// @brief Real-number type.
///
/// @details This is the number type underlying numerical calculations conceptually
///   involving real-numbers. Ideally the implementation of this type doesn't suffer
///   from things like: catastrophic cancellation, catastrophic division, overflows,
///   nor underflows.
///
/// @note This can be implemented using any of the fundamental floating point types
///   (<code>float</code>, <code>double</code>, or <code>long double</code>).
/// @note This can also be implemented using a <code>LiteralType</code> that has
///   necessary support: all common mathematical functions, support for infinity and
///   NaN, and a specialization of the @c std::numeric_limits class template for it.
///
/// @note Regarding division:
///  - While dividing 1 by a real, caching the result, and then doing multiplications
///    with the result may well be faster (than repeatedly dividing), dividing 1 by
///    the real can also result in an underflow situation that's then compounded
///    every time it's multiplied with other values.
///  - Meanwhile, dividing every time by a real isolates any underflows to the
///    particular division where underflow occurs.
///
/// @warning The note regarding division applies even more so when using a
///   fixed-point type (for <code>Real</code>).
///
/// @see https://en.cppreference.com/w/cpp/language/types
/// @see https://en.cppreference.com/w/cpp/types/is_floating_point
/// @see https://en.cppreference.com/w/cpp/named_req/LiteralType
///
using Real = float;

static_assert(IsArithmeticV<Real>);

// Requirements on Real per std::numeric_limits...
static_assert(!std::numeric_limits<Real>::is_integer);
static_assert(std::numeric_limits<Real>::is_signed);
static_assert(std::numeric_limits<Real>::has_infinity);
static_assert(std::numeric_limits<Real>::has_signaling_NaN || std::numeric_limits<Real>::has_quiet_NaN);

} // namespace playrho

#endif // PLAYRHO_REAL_HPP
