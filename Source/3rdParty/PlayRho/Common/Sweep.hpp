/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COMMON_SWEEP_HPP
#define PLAYRHO_COMMON_SWEEP_HPP

#include "PlayRho/Common/Position.hpp"
#include "PlayRho/Common/Settings.hpp"
#include "PlayRho/Common/Vector2.hpp"

namespace playrho {
namespace d2 {

/// @brief Description of a "sweep" of motion in 2-D space.
///
/// @details This describes the motion of a body/shape for TOI computation.
///   Shapes are defined with respect to the body origin, which may
///   not coincide with the center of mass. However, to support dynamics
///   we must interpolate the center of mass position.
///
/// @note This data structure is likely 36-bytes (at least on 64-bit platforms).
///
class Sweep
{
public:

    /// @brief Default constructor.
    Sweep() = default;
    
    /// @brief Copy constructor.
    PLAYRHO_CONSTEXPR inline Sweep(const Sweep& copy) = default;
    
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline Sweep(const Position p0, const Position p1,
                    const Length2 lc = Length2{0_m, 0_m},
                    Real a0 = 0) noexcept:
        pos0{p0}, pos1{p1}, localCenter{lc}, alpha0{a0}
    {
        assert(a0 >= 0);
        assert(a0 < 1);
    }
    
    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline explicit Sweep(const Position p,
                             const Length2 lc = Length2{0_m, 0_m}):
        Sweep{p, p, lc, 0}
    {
        // Intentionally empty.
    }
    
    /// @brief Gets the local center of mass position.
    /// @note This value can only be set via a sweep constructed using an initializing
    ///   constructor.
    Length2 GetLocalCenter() const noexcept { return localCenter; }
    
    /// @brief Gets the alpha 0 for this sweep.
    /// @return Value between 0 and less than 1.
    Real GetAlpha0() const noexcept { return alpha0; }
    
    /// @brief Advances the sweep by a factor of the difference between the given time alpha
    ///   and the sweep's alpha 0.
    /// @details This advances position 0 (<code>pos0</code>) of the sweep towards position
    ///   1 (<code>pos1</code>) by a factor of the difference between the given alpha and
    ///   the alpha 0.
    ///
    /// @param alpha Valid new time factor in [0,1) to update the sweep to. Behavior is
    ///   undefined if value is invalid.
    ///
    void Advance0(Real alpha) noexcept;
    
    /// @brief Resets the alpha 0 value back to zero.
    /// @post Getting the alpha 0 value after calling this method will return zero.
    void ResetAlpha0() noexcept;
    
    /// @brief Center world position and world angle at time "0".
    Position pos0;

    /// @brief Center world position and world angle at time "1".
    Position pos1;
    
private:
    /// @brief Local center of mass position.
    /// @note 8-bytes.
    Length2 localCenter = Length2{0_m, 0_m};
    
    /// @brief Fraction of the current time step in the range [0,1]
    /// @note <code>pos0.linear</code> and <code>pos0.angular</code> are the positions at
    ///   <code>alpha0</code>.
    /// @note 4-bytes.
    Real alpha0 = 0;
};

inline void Sweep::Advance0(const Real alpha) noexcept
{
    assert(IsValid(alpha));
    assert(alpha >= 0);
    assert(alpha < 1);
    assert(alpha0 < 1);
    
    const auto beta = (alpha - alpha0) / (1 - alpha0);
    pos0 = GetPosition(pos0, pos1, beta);
    alpha0 = alpha;
}

inline void Sweep::ResetAlpha0() noexcept
{
    alpha0 = 0;
}

// Free functions...

} // namespace d2

/// @brief Determines if the given value is valid.
/// @relatedalso d2::Transformation
template <>
PLAYRHO_CONSTEXPR inline bool IsValid(const d2::Sweep& value) noexcept
{
    return IsValid(value.pos0) && IsValid(value.pos1)
    && IsValid(value.GetLocalCenter()) && IsValid(value.GetAlpha0());
}

} // namespace playrho

#endif // PLAYRHO_COMMON_SWEEP_HPP
