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

#ifndef PLAYRHO_D2_BODYCONSTRAINT_HPP
#define PLAYRHO_D2_BODYCONSTRAINT_HPP

/// @file
/// @brief Definition of the @c BodyConstraint class and closely related code.

#include <cassert> // for assert

// IWYU pragma: begin_exports

#include "playrho/MovementConf.hpp"

#include "playrho/d2/Body.hpp" // for GetInvMass & other Body helpers
#include "playrho/d2/Position.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

class Body;

/// @brief Constraint for a body.
/// @details Data related to body constraint processing.
/// @note Only position and velocity is independently changeable after construction.
class BodyConstraint
{
public:
    BodyConstraint() = default;

    /// @brief Initializing constructor.
    /// @param invMass Inverse mass.
    /// @param invRotI Inverse rotational inertia.
    /// @param localCenter Local center.
    /// @param position Position of the body.
    /// @param velocity Velocity of the body.
    /// @pre @p position, @p velocity, and @p locatCenter are all valid.
    /// @pre @p invMass and @p invRotI are greater-than or equal-to zero.
    constexpr
    BodyConstraint(InvMass invMass, InvRotInertia invRotI, const Length2& localCenter,
                   const Position& position, const Velocity& velocity) noexcept:
        m_position{position},
        m_velocity{velocity},
        m_localCenter{localCenter},
        m_invMass{invMass},
        m_invRotI{invRotI}
    {
        assert(IsValid(position));
        assert(IsValid(velocity));
        assert(IsValid(localCenter));
        assert(invMass >= InvMass{});
        assert(invRotI >= InvRotInertia{});
    }

    /// @brief Gets the inverse mass of this body representation.
    /// @return Value >= 0.
    InvMass GetInvMass() const noexcept;

    /// @brief Gets the inverse rotational inertia of this body representation.
    /// @return Value >= 0.
    InvRotInertia GetInvRotInertia() const noexcept;

    /// @brief Gets the location of the body's center of mass in local coordinates.
    Length2 GetLocalCenter() const noexcept;

    /// @brief Gets the position of the body.
    Position GetPosition() const noexcept;

    /// @brief Gets the velocity of the body.
    Velocity GetVelocity() const noexcept;

    /// @brief Sets the position of the body.
    /// @param value A valid position value to set for the represented body.
    /// @pre @p value is valid - i.e. <code>IsValid(value)</code> is true.
    /// @post <code>GetPosition()</code> returns the value to be set.
    /// @see GetPosition.
    BodyConstraint& SetPosition(const Position& value) noexcept;

    /// @brief Sets the velocity of the body.
    /// @param value A valid velocity value to set for the represented body.
    /// @pre @p value is valid - i.e. <code>IsValid(value)</code> is true.
    /// @post <code>GetVelocity()</code> returns the value to be set.
    /// @see GetVelocity.
    BodyConstraint& SetVelocity(const Velocity& value) noexcept;

private:
    Position m_position; ///< Position data of body.
    Velocity m_velocity; ///< Velocity data of body.
    Length2 m_localCenter{}; ///< Local center of the associated body's sweep.
    InvMass m_invMass{}; ///< Inverse mass of associated body (a non-negative value).

    /// Inverse rotational inertia about the center of mass of the associated body
    /// (a non-negative value).
    InvRotInertia m_invRotI{};
};

inline InvMass BodyConstraint::GetInvMass() const noexcept
{
    return m_invMass;
}

inline InvRotInertia BodyConstraint::GetInvRotInertia() const noexcept
{
    return m_invRotI;
}

inline Length2 BodyConstraint::GetLocalCenter() const noexcept
{
    return m_localCenter;
}

inline Position BodyConstraint::GetPosition() const noexcept
{
    return m_position;
}

inline Velocity BodyConstraint::GetVelocity() const noexcept
{
    return m_velocity;
}

inline BodyConstraint& BodyConstraint::SetPosition(const Position& value) noexcept
{
    assert(IsValid(value));
    m_position = value;
    return *this;
}

inline BodyConstraint& BodyConstraint::SetVelocity(const Velocity& value) noexcept
{
    assert(IsValid(value));
    m_velocity = value;
    return *this;
}

/// @brief Gets the <code>BodyConstraint</code> based on the given parameters.
inline BodyConstraint GetBodyConstraint(const Body& body, Time time,
                                        const MovementConf& conf) noexcept
{
    return BodyConstraint{
        GetInvMass(body),
        GetInvRotInertia(body),
        GetLocalCenter(body),
        GetPosition1(body),
        Cap(GetVelocity(body, time), time, conf)
    };
}

} // namespace playrho::d2

#endif // PLAYRHO_D2_BODYCONSTRAINT_HPP
