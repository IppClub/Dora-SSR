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

#ifndef PLAYRHO_TOICONF_HPP
#define PLAYRHO_TOICONF_HPP

/// @file
/// @brief Definitions of @c ToiConf class and closely related code.

#include <type_traits> // for std::remove_const_t

// IWYU pragma: begin_exports

#include "playrho/NonNegative.hpp"
#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/UnitInterval.hpp"
#include "playrho/Units.hpp"

// IWYU pragma: end_exports

namespace playrho {

struct StepConf;

/// @brief Time of impact configuration.
///
/// @details These parameters effect time of impact calculations by limiting the definitions
///    of time and impact. If total radius is expressed as TR, and target depth as TD, then:
///    the max target distance is (TR - TD) + tolerance; and the min target distance is
///    (TR - TD) - tolerance.
///
/// @note Max target distance must be less than or equal to the total radius as the target
///   range has to be chosen such that the contact manifold will have a greater than zero
///   contact point count.
/// @note A max target of <code>totalRadius - DefaultLinearSlop * x</code> where
///   <code>x is <= 1</code> is increasingly slower as x goes below 1.
/// @note Min target distance needs to be significantly less than the max target distance and
///   significantly more than 0.
///
/// @see SolvePositionConstraints
/// @see SolveTOIPositionConstraints
///
struct ToiConf {
    /// @brief Root iteration type.
    using root_iter_type = std::remove_const_t<decltype(DefaultMaxToiRootIters)>;

    /// @brief TOI iteration type.
    using toi_iter_type = std::remove_const_t<decltype(DefaultMaxToiIters)>;

    /// @brief Distance iteration type.
    using dist_iter_type = std::remove_const_t<decltype(DefaultMaxDistanceIters)>;

    /// @brief Default target depth.
    static constexpr auto DefaultTargetDepth = NonNegative<Length>{DefaultLinearSlop * Real(3)};

    /// @brief Default tolerance.
    static constexpr auto DefaultTolerance = NonNegative<Length>{DefaultLinearSlop / Real(4)};

    /// @brief Default time max.
    static constexpr auto DefaultTimeMax = UnitIntervalFF<Real>(Real(1));

    /// @brief Uses the given time max value.
    constexpr ToiConf& UseTimeMax(UnitInterval<Real> value) noexcept;

    /// @brief Uses the given target depth value.
    constexpr ToiConf& UseTargetDepth(NonNegative<Length> value) noexcept;

    /// @brief Uses the given tolerance value.
    constexpr ToiConf& UseTolerance(NonNegative<Length> value) noexcept;

    /// @brief Uses the given max root iterations value.
    constexpr ToiConf& UseMaxRootIters(root_iter_type value) noexcept;

    /// @brief Uses the given max TOI iterations value.
    constexpr ToiConf& UseMaxToiIters(toi_iter_type value) noexcept;

    /// @brief Uses the given max distance iterations value.
    constexpr ToiConf& UseMaxDistIters(dist_iter_type value) noexcept;

    /// @brief Time max expressed as a unit interval between 0 and 1 inclusive.
    UnitInterval<Real> timeMax = DefaultTimeMax;

    /// @brief Targeted depth of impact.
    /// @note Value should be less than twice the minimum vertex radius of any shape.
    NonNegative<Length> targetDepth = DefaultTargetDepth;

    /// @brief Tolerance.
    /// @details Provides a +/- range from the target depth that defines a minimum and
    ///   maximum target depth within which inclusively, time of impact calculating code
    ///   is expected to return a "touching" status.
    /// @note Use the default value unless you really know what you're doing.
    /// @note A value of 0 requires a TOI at exactly the target depth. This is ill-advised.
    NonNegative<Length> tolerance = DefaultTolerance;

    /// @brief Maximum number of root finder iterations.
    /// @details This is the maximum number of iterations for calculating the 1-dimensional
    ///   root of <code>f(t) - (totalRadius - targetDepth) < tolerance</code>
    /// where <code>f(t)</code> is the distance between the shapes at time <code>t</code>,
    /// and <code>totalRadius</code> is the sum of the vertex radiuses of 2 distance proxies.
    /// @note This value never needs to be more than the number of iterations needed to
    ///    achieve full machine precision.
    root_iter_type maxRootIters = DefaultMaxToiRootIters;

    toi_iter_type maxToiIters = DefaultMaxToiIters; ///< Max time of impact iterations.

    dist_iter_type maxDistIters = DefaultMaxDistanceIters; ///< Max distance iterations.
};

constexpr ToiConf& ToiConf::UseTimeMax(UnitInterval<Real> value) noexcept
{
    timeMax = value;
    return *this;
}

constexpr ToiConf& ToiConf::UseTargetDepth(NonNegative<Length> value) noexcept
{
    targetDepth = value;
    return *this;
}

constexpr ToiConf& ToiConf::UseTolerance(NonNegative<Length> value) noexcept
{
    tolerance = value;
    return *this;
}

constexpr ToiConf& ToiConf::UseMaxRootIters(root_iter_type value) noexcept
{
    maxRootIters = value;
    return *this;
}

constexpr ToiConf& ToiConf::UseMaxToiIters(toi_iter_type value) noexcept
{
    maxToiIters = value;
    return *this;
}

constexpr ToiConf& ToiConf::UseMaxDistIters(dist_iter_type value) noexcept
{
    maxDistIters = value;
    return *this;
}

/// @brief Gets the default time of impact configuration.
/// @relatedalso ToiConf
constexpr auto GetDefaultToiConf()
{
    return ToiConf{};
}

/// @brief Gets the time of impact configuration for the given step configuration.
/// @relatedalso ToiConf
ToiConf GetToiConf(const StepConf& conf) noexcept;

} // namespace playrho

#endif // PLAYRHO_TOICONF_HPP
