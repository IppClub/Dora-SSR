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

#ifndef PLAYRHO_DETAIL_UNITVECTORCHECKER_HPP
#define PLAYRHO_DETAIL_UNITVECTORCHECKER_HPP

#include <cmath> // for std::nextafter

#include "playrho/Units.hpp" // for StripUnit

namespace playrho::detail {

/// @brief Unit magnitude constrained value checker.
/// @note This is meant to be used as a checker with types like <code>Checked</code>.
/// @tparam T Underlying type for this checker.
/// @ingroup Checkers
/// @see Checked.
template <typename T>
struct UnitMagnitudeChecker {

    /// @brief Value checking functor.
    /// @return Null string if given value is valid, else
    ///   a non-null string explanation.
    auto operator()(const T& v) const noexcept
        -> decltype(begin(v), end(v), StripUnit(*begin(v)), static_cast<const char*>(nullptr))
    {
        static constexpr auto one = Real(1);
        auto sum = std::decay_t<decltype(*begin(v))>{};
        for (const auto& element: v) {
            sum += element * element;
        }
        // Tolerance of 2 ULPs per accuracy cos/sin generally provide!
        if (std::nextafter(std::nextafter(Real(StripUnit(sum)), one), one) != one) {
            return "value not of unit magnitude";
        }
        return {};
    }
};

} // namespace playrho::detail


#endif // PLAYRHO_DETAIL_UNITVECTORCHECKER_HPP
