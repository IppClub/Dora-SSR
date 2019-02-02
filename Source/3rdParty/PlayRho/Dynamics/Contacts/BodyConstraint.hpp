/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#ifndef PLAYRHO_DYNAMICS_CONTACTS_BODYCONSTRAINT_HPP
#define PLAYRHO_DYNAMICS_CONTACTS_BODYCONSTRAINT_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Dynamics/MovementConf.hpp"
#include "PlayRho/Dynamics/Body.hpp"

namespace playrho {
namespace d2 {

    /// @brief Body Constraint.
    /// @details Body data related to constraint processing.
    /// @note Only position and velocity is independently changeable after construction.
    /// @note This data structure is 40-bytes large (with 4-byte Real on at least one
    ///   64-bit platform).
    class BodyConstraint
    {
    public:
        // Note: Seeing World.TilesComesToRest times of around 5686 ms with this setup.

        /// @brief Index type.
        using index_type = std::remove_const<decltype(MaxBodies)>::type;
        
        BodyConstraint() = default;
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline
        BodyConstraint(InvMass invMass, InvRotInertia invRotI, Length2 localCenter,
                         Position position, Velocity velocity) noexcept:
            m_position{position},
            m_velocity{velocity},
            m_localCenter{localCenter},
            m_invMass{invMass},
            m_invRotI{invRotI}
        {
            assert(IsValid(position));
            assert(IsValid(velocity));
            assert(IsValid(localCenter));
            assert(invMass >= InvMass{0});
            assert(invRotI >= InvRotInertia{0});
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
        /// @warning Behavior is undefined if the given value is not valid.
        BodyConstraint& SetPosition(Position value) noexcept;
        
        /// @brief Sets the velocity of the body.
        /// @param value A valid velocity value to set for the represented body.
        /// @warning Behavior is undefined if the given value is not valid.
        BodyConstraint& SetVelocity(Velocity value) noexcept;
        
    private:
        Position m_position; ///< Body position data.
        Velocity m_velocity; ///< Body velocity data.
        Length2 m_localCenter; ///< Local center of the associated body's sweep.
        InvMass m_invMass; ///< Inverse mass of associated body (a non-negative value).

        /// Inverse rotational inertia about the center of mass of the associated body
        /// (a non-negative value).
        InvRotInertia m_invRotI;
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
    
    inline BodyConstraint& BodyConstraint::SetPosition(Position value) noexcept
    {
        assert(IsValid(value));
        m_position = value;
        return *this;
    }
    
    inline BodyConstraint& BodyConstraint::SetVelocity(Velocity value) noexcept
    {
        assert(IsValid(value));
        m_velocity = value;
        return *this;
    }
    
    /// @brief Gets the <code>BodyConstraint</code> based on the given parameters.
    inline BodyConstraint GetBodyConstraint(const Body& body, Time time,
                                            MovementConf conf) noexcept
    {
        return BodyConstraint{
            body.GetInvMass(),
            body.GetInvRotInertia(),
            body.GetLocalCenter(),
            GetPosition1(body),
            Cap(GetVelocity(body, time), time, conf)
        };
    }

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_CONTACTS_BODYCONSTRAINT_HPP
