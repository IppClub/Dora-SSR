/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_D2_SWEEP_HPP
#define PLAYRHO_D2_SWEEP_HPP

/// @file
/// @brief Definition of the @c Sweep class and closely related code.

// IWYU pragma: begin_exports

#include "playrho/ZeroToUnderOne.hpp"

#include "playrho/d2/Position.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief Description of a "sweep" of motion in 2-D space.
/// @details This describes the motion of a body/shape for TOI computation.
///   Shapes are defined with respect to the body origin, which may
///   not coincide with the center of mass. However, to support dynamics
///   we must interpolate the center of mass position.
struct Sweep
{
    /// @brief Default constructor.
    /// @post <code>pos0</code> is the value of <code>Position{}</code>.
    /// @post <code>pos1</code> is the value of <code>Position{}</code>.
    /// @post <code>localCenter</code> is the value of <code>Length2{}</code>.
    /// @post <code>alpha0</code> is zero.
    constexpr Sweep() = default;

    /// @brief Initializing constructor.
    /// @param p0 Value for position 0.
    /// @param p1 Value for position 1.
    /// @param lc Local center.
    /// @param a0 Alpha 0 for the sweep.
    /// @post <code>pos0</code> is the value of @p p0 .
    /// @post <code>pos1</code> is the value of @p p1 .
    /// @post <code>localCenter</code> is the value of @p lc .
    /// @post <code>alpha0</code> is the value of @p a0 .
    constexpr Sweep(const Position& p0, const Position& p1, const Length2& lc = Length2{0_m, 0_m},
                    ZeroToUnderOneFF<Real> a0 = {}) noexcept
        : pos0{p0}, pos1{p1}, localCenter{lc}, alpha0{a0}
    {
    }

    /// @brief Initializing constructor.
    /// @post <code>pos0</code> is the value of @p p .
    /// @post <code>pos1</code> is the value of @p p .
    /// @post <code>localCenter</code> is the value of @p lc .
    /// @post <code>alpha0</code> is zero.
    constexpr explicit Sweep(const Position& p, const Length2& lc = Length2{0_m, 0_m})
        : Sweep{p, p, lc, ZeroToUnderOneFF<Real>{}}
    {
        // Intentionally empty.
    }

    /// @brief Center world position and world angle at time "0".
    Position pos0{};

    /// @brief Center world position and world angle at time "1".
    Position pos1{};

    /// @brief Local center of mass position.
    Length2 localCenter = Length2{0_m, 0_m};

    /// @brief Alpha 0 of this sweep.
    /// @details Fraction of the current time step in the range [0,1)
    /// @note <code>pos0.linear</code> and <code>pos0.angular</code> are the positions at
    ///   <code>alpha0</code>.
    ZeroToUnderOneFF<Real> alpha0;
};

// Free functions...

/// @brief Advances the sweep by a factor of the difference between the given time alpha
///   and the sweep's alpha 0.
/// @details This advances position 0 (<code>pos0</code>) of the sweep towards position
///   1 (<code>pos1</code>) by a factor of the difference between the given alpha and
///   the alpha 0. This **does not** change the sweep's position 1.
/// @param sweep The sweep to return an advancement of.
/// @param alpha Valid new time factor in [0,1) to update the sweep to.
Sweep Advance0(const Sweep& sweep, ZeroToUnderOneFF<Real> alpha) noexcept;

/// @brief Equals operator.
/// @relatedalso Sweep
constexpr bool operator==(const Sweep& lhs, const Sweep& rhs)
{
    return lhs.pos0 == rhs.pos0 && //
           lhs.pos1 == rhs.pos1 && //
           lhs.localCenter == rhs.localCenter && //
           lhs.alpha0 == rhs.alpha0;
}

/// @brief Not-equals operator.
/// @relatedalso Sweep
constexpr bool operator!=(const Sweep& lhs, const Sweep& rhs)
{
    return !(lhs == rhs);
}

/// @brief Convenience function for setting the sweep's local center.
/// @relatedalso Sweep
inline void SetLocalCenter(Sweep& sweep, const Length2& value) noexcept
{
    sweep = Sweep{sweep.pos0, sweep.pos1, value, sweep.alpha0};
}

} // namespace playrho::d2

namespace playrho {

/// @brief Determines if the given value is valid.
/// @relatedalso d2::Sweep
constexpr auto IsValid(const d2::Sweep& value) noexcept -> bool
{
    return IsValid(value.pos0) && IsValid(value.pos1) && IsValid(value.localCenter) &&
           IsValid(value.alpha0);
}

} // namespace playrho

#endif // PLAYRHO_D2_SWEEP_HPP
