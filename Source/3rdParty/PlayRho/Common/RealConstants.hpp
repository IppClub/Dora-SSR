/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

/**
 * @file
 * @brief Definitions file for constant expressions of type Real.
 * @details This file defines physically dimensionless or unitless constant expression
 *   quantities of the Real type.
 * @sa https://en.wikipedia.org/wiki/Dimensionless_quantity
 */

#ifndef PLAYRHO_COMMON_REALCONSTANTS_HPP
#define PLAYRHO_COMMON_REALCONSTANTS_HPP

#include "PlayRho/Defines.hpp"
#include "PlayRho/Common/Real.hpp"

namespace playrho {

/// @brief Pi.
///
/// @details An "irrational number" that's defined as the ratio of a circle's
///   circumference to its diameter.
///
/// @note While the include file definition of M_PI may be a POSIX compliance requirement
///   and initially attractive to use, it's apparently not a C++ standards requirement
///   and casually including it pollutes the name space of all code that uses this library.
///   Whatever the case, MSVC 2017 doesn't make it part of the <code>cmath</code> include
///   without enabling <code>_USE_MATH_DEFINES</code>. So rather than add yet more
///   C preprocessor macros to all sources that this library may be compiled with, it's
///   simply hard-coded in here instead using a C++ mechanism that also keeps it with the
///   enclosing name space.
/// @note Any narrowing is intentional.
///
/// @sa https://en.wikipedia.org/wiki/Pi
///
PLAYRHO_CONSTEXPR const auto Pi = Real(3.14159265358979323846264338327950288);

/// @brief Square root of two.
///
/// @sa https://en.wikipedia.org/wiki/Square_root_of_2
///
PLAYRHO_CONSTEXPR const auto SquareRootTwo =
    Real(1.414213562373095048801688724209698078569671875376948073176679737990732478462);

/// @defgroup DecimalUnitPrefices Decimal Unit Prefices
/// @brief Decimal unit prefices in the metric system for denoting a multiple, or
///   a fraction of, a unit.
/// @note <code>std::ratio</code> doesn't necessarily support larger sizes like Yotta
///    or bigger so floating-point literal notation is used instead.
/// @sa https://en.wikipedia.org/wiki/Metric_prefix
/// @{

/// @brief Centi- (1 x 10^-2).
/// @sa https://en.wikipedia.org/wiki/Centi-
PLAYRHO_CONSTEXPR const auto Centi = Real(1e-2);

/// @brief Deci- (1 x 10^-1).
/// @sa https://en.wikipedia.org/wiki/Deci-
PLAYRHO_CONSTEXPR const auto Deci = Real(1e-1);

/// @brief Kilo- (1 x 10^3).
/// @sa https://en.wikipedia.org/wiki/Kilo-
PLAYRHO_CONSTEXPR const auto Kilo = Real(1e3);

/// @brief Mega- (1 x 10^6).
/// @sa https://en.wikipedia.org/wiki/Mega-
PLAYRHO_CONSTEXPR const auto Mega = Real(1e6);

/// @brief Giga- (1 x 10^9).
/// @sa https://en.wikipedia.org/wiki/Giga-
PLAYRHO_CONSTEXPR const auto Giga = Real(1e9);

/// @brief Tera- (1 x 10^12).
/// @sa https://en.wikipedia.org/wiki/Tera-
PLAYRHO_CONSTEXPR const auto Tera = Real(1e12);

/// @brief Peta- (1 x 10^15).
/// @sa https://en.wikipedia.org/wiki/Peta-
PLAYRHO_CONSTEXPR const auto Peta = Real(1e15);

/// @brief Yotta- (1 x 10^24).
/// @sa https://en.wikipedia.org/wiki/Yotta-
PLAYRHO_CONSTEXPR const auto Yotta = Real(1e24);

/// @}

} // namespace playrho

#endif // PLAYRHO_COMMON_REALCONSTANTS_HPP
