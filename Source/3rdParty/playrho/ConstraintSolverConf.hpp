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

#ifndef PLAYRHO_CONSTRAINTSOLVERCONF_HPP
#define PLAYRHO_CONSTRAINTSOLVERCONF_HPP

/// @file
/// @brief Definition of the <code>ConstraintSolverConf</code> class and closely related code.

// IWYU pragma: begin_exports

#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/Units.hpp"

// IWYU pragma: end_exports

namespace playrho {

struct StepConf;

/// @brief Constraint solver configuration data.
/// @details Defines how a constraint solver should resolve a given constraint.
/// @see SolvePositionConstraint.
struct ConstraintSolverConf {

    /// @brief Default regular resolution rate.
    static constexpr auto DefaultRegResolutionRate = Real(0.2);

    /// @brief Default time of impact (TOI) resolution rate.
    static constexpr auto DefaultToiResolutionRate = Real(0.75);

    /// @brief Default linear slop.
    static constexpr auto DefaultLinearSlop = ::playrho::DefaultLinearSlop;

    /// @brief Default angular slop.
    static constexpr auto DefaultAngularSlop = ::playrho::DefaultAngularSlop;

    /// @brief Default max linear correction.
    static constexpr auto DefaultMaxLinearCorrection = DefaultLinearSlop * Real{20};

    /// @brief Default max angular correction.
    static constexpr auto DefaultMaxAngularCorrection = DefaultAngularSlop * Real{4};

    /// @brief Uses the given resolution rate.
    constexpr ConstraintSolverConf& UseResolutionRate(Real value) noexcept
    {
        resolutionRate = value;
        return *this;
    }

    /// @brief Uses the given linear slop.
    constexpr ConstraintSolverConf& UseLinearSlop(Length value) noexcept
    {
        linearSlop = value;
        return *this;
    }

    /// @brief Uses the given angular slop.
    constexpr ConstraintSolverConf& UseAngularSlop(Angle value) noexcept
    {
        angularSlop = value;
        return *this;
    }

    /// @brief Uses the given max linear correction.
    constexpr ConstraintSolverConf& UseMaxLinearCorrection(Length value) noexcept
    {
        maxLinearCorrection = value;
        return *this;
    }

    /// @brief Uses the given max angular correction.
    constexpr ConstraintSolverConf& UseMaxAngularCorrection(Angle value) noexcept
    {
        maxAngularCorrection = value;
        return *this;
    }

    /// Resolution rate.
    /// @details
    /// Defines the percentage of the overlap that should get resolved in a single solver call.
    /// Value greater than zero and less than or equal to one.
    /// Ideally this would be 1 so that overlap is removed in one time step.
    /// However using values close to 1 often leads to overshoot.
    /// @note Recommended values are: <code>0.2</code> for solving regular constraints
    ///   or <code>0.75</code> for solving TOI constraints.
    Real resolutionRate = DefaultRegResolutionRate;

    /// Linear slop.
    /// @note The negative of this amount is the maximum amount of separation to create.
    /// @note Recommended value: <code>DefaultLinearSlop</code>.
    Length linearSlop = DefaultLinearSlop;

    /// Angular slop.
    /// @note Recommended value: <code>DefaultAngularSlop</code>.
    Angle angularSlop = DefaultAngularSlop;

    /// Maximum linear correction.
    /// @details
    /// Maximum amount of overlap to resolve in a single solver call. Helps prevent overshoot.
    /// @note Recommended value: <code>linearSlop * 40</code>.
    Length maxLinearCorrection = DefaultMaxLinearCorrection;

    /// Maximum angular correction.
    /// @details Maximum angular position correction used when solving constraints.
    /// Helps to prevent overshoot.
    /// @note Recommended value: <code>angularSlop * 4</code>.
    Angle maxAngularCorrection = DefaultMaxAngularCorrection;
};

/// @brief Gets the default position solver configuration.
constexpr ConstraintSolverConf GetDefaultPositionSolverConf() noexcept
{
    return ConstraintSolverConf{}.UseResolutionRate(ConstraintSolverConf::DefaultRegResolutionRate);
}

/// @brief Gets the default TOI position solver configuration.
constexpr ConstraintSolverConf GetDefaultToiPositionSolverConf() noexcept
{
    // For solving TOI events, use a faster/higher resolution rate than normally used.
    return ConstraintSolverConf{}.UseResolutionRate(ConstraintSolverConf::DefaultToiResolutionRate);
}

/// @brief Gets the regular phase constraint solver configuration for the given step configuration.
ConstraintSolverConf GetRegConstraintSolverConf(const StepConf& conf) noexcept;

/// @brief Gets the TOI phase constraint solver configuration for the given step configuration.
ConstraintSolverConf GetToiConstraintSolverConf(const StepConf& conf) noexcept;

} // namespace playrho

#endif // PLAYRHO_CONSTRAINTSOLVERCONF_HPP
