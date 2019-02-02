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

#ifndef PLAYRHO_DYNAMICS_JOINTS_PULLEYJOINT_HPP
#define PLAYRHO_DYNAMICS_JOINTS_PULLEYJOINT_HPP

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/PulleyJointConf.hpp"

namespace playrho {
namespace d2 {

/// @brief Pulley joint.
///
/// @details The pulley joint is connected to two bodies and two fixed ground points.
///   The pulley supports a ratio such that: <code>length1 + ratio * length2 <= constant</code>.
///
/// @note The force transmitted is scaled by the ratio.
///
/// @warning the pulley joint can get a bit squirrelly by itself. They often
///   work better when combined with prismatic joints. You should also cover the
///   the anchor points with static shapes to prevent one side from going to
///   zero length.
///
/// @ingroup JointsGroup
///
/// @image html pulleyJoint.gif
///
class PulleyJoint : public Joint
{
public:
    
    /// @brief Initializing constructor.
    /// @attention To create or use the joint within a world instance, call that world
    ///   instance's create joint method instead of calling this constructor directly.
    /// @sa World::CreateJoint
    PulleyJoint(const PulleyJointConf& data);
    
    void Accept(JointVisitor& visitor) const override;
    void Accept(JointVisitor& visitor) override;
    Length2 GetAnchorA() const override;
    Length2 GetAnchorB() const override;
    Momentum2 GetLinearReaction() const override;
    AngularMomentum GetAngularReaction() const override;
    bool ShiftOrigin(const Length2 newOrigin) override;

    /// @brief Gets the local anchor A.
    Length2 GetLocalAnchorA() const noexcept;

    /// @brief Gets the local anchor B.
    Length2 GetLocalAnchorB() const noexcept;
    
    /// Get the first ground anchor.
    Length2 GetGroundAnchorA() const noexcept;

    /// Get the second ground anchor.
    Length2 GetGroundAnchorB() const noexcept;

    /// Get the current length of the segment attached to body-A.
    Length GetLengthA() const noexcept;

    /// Get the current length of the segment attached to body-B.
    Length GetLengthB() const noexcept;

    /// Get the pulley ratio.
    Real GetRatio() const noexcept;

private:

    void InitVelocityConstraints(BodyConstraintsMap& bodies,
                                 const StepConf& step,
                                 const ConstraintSolverConf&) override;
    bool SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf&) override;
    bool SolvePositionConstraints(BodyConstraintsMap& bodies,
                                  const ConstraintSolverConf& conf) const override;

    Length2 m_groundAnchorA; ///< Ground anchor A.
    Length2 m_groundAnchorB; ///< Ground anchor B.
    Length2 m_localAnchorA; ///< Local anchor A.
    Length2 m_localAnchorB; ///< Local anchor B.
    Length m_lengthA; ///< Length A.
    Length m_lengthB; ///< Length B.
    Real m_ratio; ///< Ratio.
    Length m_constant; ///< Constant.
    
    // Solver shared (between calls to InitVelocityConstraints).
    Momentum m_impulse = 0_Ns; ///< Impulse.

    // Solver temp (recalculated every call to InitVelocityConstraints).
    UnitVec m_uA; ///< Unit vector A.
    UnitVec m_uB; ///< Unit vector B.
    Length2 m_rA; ///< Relative A.
    Length2 m_rB; ///< Relative B.
    Mass m_mass; ///< Mass.
};
    
inline Length2 PulleyJoint::GetLocalAnchorA() const noexcept
{
    return m_localAnchorA;
}

inline Length2 PulleyJoint::GetLocalAnchorB() const noexcept
{
    return m_localAnchorB;
}

inline Length2 PulleyJoint::GetGroundAnchorA() const noexcept
{
    return m_groundAnchorA;
}

inline Length2 PulleyJoint::GetGroundAnchorB() const noexcept
{
    return m_groundAnchorB;
}
    
inline Length PulleyJoint::GetLengthA() const noexcept
{
    return m_lengthA;
}

inline Length PulleyJoint::GetLengthB() const noexcept
{
    return m_lengthB;
}

inline Real PulleyJoint::GetRatio() const noexcept
{
    return m_ratio;
}

/// @brief Get the current length of the segment attached to body-A.
/// @relatedalso PulleyJoint
Length GetCurrentLengthA(const PulleyJoint& joint);

/// @brief Get the current length of the segment attached to body-B.
/// @relatedalso PulleyJoint
Length GetCurrentLengthB(const PulleyJoint& joint);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_PULLEYJOINT_HPP
