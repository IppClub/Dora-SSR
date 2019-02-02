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

#ifndef PLAYRHO_DYNAMICS_CONTACTS_POSITIONCONSTRAINT_HPP
#define PLAYRHO_DYNAMICS_CONTACTS_POSITIONCONSTRAINT_HPP

#include "PlayRho/Collision/Manifold.hpp"
#include "PlayRho/Dynamics/Contacts/BodyConstraint.hpp"

namespace playrho {
namespace d2 {

    /// Contact Position Constraint.
    /// @note This structure is 88-bytes large on at least one 64-bit platform.
    class PositionConstraint
    {
    public:
        /// @brief Size type.
        using size_type = std::remove_const<decltype(MaxManifoldPoints)>::type;
        
        PositionConstraint() = default;
        
        /// @brief Initializing constructor.
        PositionConstraint(const Manifold& m,
                           BodyConstraint& bA, Length rA,
                           BodyConstraint& bB, Length rB):
            manifold{m}, m_bodyA{&bA}, m_bodyB{&bB}, m_radiusA{rA}, m_radiusB{rB}
        {
            assert(m.GetPointCount() > 0);
            assert(&bA != &bB);
            assert(rA >= 0_m);
            assert(rB >= 0_m);
        }
        
        Manifold manifold; ///< Copy of contact's manifold with 1 or more contact points (64-bytes).

        /// @brief Gets body A.
        BodyConstraint* GetBodyA() const noexcept { return m_bodyA; }
        
        /// @brief Gets body B.
        BodyConstraint* GetBodyB() const noexcept { return m_bodyB; }

        /// @brief Gets radius A.
        Length GetRadiusA() const noexcept { return m_radiusA; }
        
        /// @brief Gets radius B.
        Length GetRadiusB() const noexcept { return m_radiusB; }

    private:
        
        BodyConstraint* m_bodyA; ///< Body A data (8-bytes).
        
        BodyConstraint* m_bodyB; ///< Body B data (8-bytes).

        /// @brief "Radius" distance from the associated shape of fixture A.
        /// @note 0 or greater.
        Length m_radiusA; // 4-bytes.

        /// @brief "Radius" distance from the associated shape of fixture B.
        /// @note 0 or greater.
        Length m_radiusB; // 4-bytes.
    };

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_CONTACTS_POSITIONCONSTRAINT_HPP
