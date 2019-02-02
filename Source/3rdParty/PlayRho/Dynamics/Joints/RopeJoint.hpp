/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_DYNAMICS_JOINTS_ROPEJOINT_HPP
#define PLAYRHO_DYNAMICS_JOINTS_ROPEJOINT_HPP

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/RopeJointConf.hpp"

namespace playrho {
namespace d2 {

/// @brief Rope joint.
///
/// @details A rope joint enforces a maximum distance between two points
///   on two bodies. It has no other effect.
///
/// @warning If you attempt to change the maximum length during the simulation
///   you will get some non-physical behavior. A model that would allow you to
///   dynamically modify the length would have some sponginess, so it was decided
///   not to implement it that way. See <code>DistanceJoint</code> if you want to dynamically
///   control length.
///
/// @ingroup JointsGroup
///
class RopeJoint : public Joint
{
public:
    
    /// @brief Initializing constructor.
    /// @attention To create or use the joint within a world instance, call that world
    ///   instance's create joint method instead of calling this constructor directly.
    /// @sa World::CreateJoint
    RopeJoint(const RopeJointConf& data);
    
    void Accept(JointVisitor& visitor) const override;
    void Accept(JointVisitor& visitor) override;

    Length2 GetAnchorA() const override;
    Length2 GetAnchorB() const override;

    Momentum2 GetLinearReaction() const override;
    AngularMomentum GetAngularReaction() const override;

    /// The local anchor point relative to body A's origin.
    Length2 GetLocalAnchorA() const { return m_localAnchorA; }

    /// The local anchor point relative to body B's origin.
    Length2 GetLocalAnchorB() const  { return m_localAnchorB; }

    /// @brief Sets the maximum length of the rope.
    void SetMaxLength(Length length) { m_maxLength = length; }

    /// @brief Gets the maximum length of the rope.
    Length GetMaxLength() const;

    /// @brief Gets the limit state.
    LimitState GetLimitState() const;

private:

    void InitVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step,
                                 const ConstraintSolverConf& conf) override;
    bool SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step) override;
    bool SolvePositionConstraints(BodyConstraintsMap& bodies,
                                  const ConstraintSolverConf& conf) const override;

    // Solver shared
    Length2 m_localAnchorA; ///< Local anchor A.
    Length2 m_localAnchorB; ///< Local anchor B.
    Length m_maxLength; ///< Max length.
    Length m_length = 0; ///< Length.
    Momentum m_impulse = 0_Ns; ///< Impulse.

    // Solver temp
    UnitVec m_u; ///< U direction.
    Length2 m_rA; ///< Relative A.
    Length2 m_rB; ///< Relative B.
    Mass m_mass = 0_kg; ///< Mass.
    LimitState m_state = e_inactiveLimit; ///< Limit state.
};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_ROPEJOINT_HPP
