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

#ifndef PLAYRHO_DYNAMICS_JOINTS_WELDJOINT_HPP
#define PLAYRHO_DYNAMICS_JOINTS_WELDJOINT_HPP

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/WeldJointConf.hpp"

namespace playrho {
namespace d2 {

/// @brief Weld joint.
///
/// @details A weld joint essentially glues two bodies together. A weld joint may
///   distort somewhat because the island constraint solver is approximate.
///
/// @ingroup JointsGroup
///
class WeldJoint : public Joint
{
public:
    
    /// @brief Initializing constructor.
    /// @attention To create or use the joint within a world instance, call that world
    ///   instance's create joint method instead of calling this constructor directly.
    /// @sa World::CreateJoint
    WeldJoint(const WeldJointConf& def);
    
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

    /// Get the reference angle.
    Angle GetReferenceAngle() const { return m_referenceAngle; }

    /// @brief Sets frequency.
    void SetFrequency(Frequency frequency) { m_frequency = frequency; }

    /// @brief Gets the frequency.
    Frequency GetFrequency() const { return m_frequency; }

    /// @brief Sets damping ratio.
    void SetDampingRatio(Real ratio) { m_dampingRatio = ratio; }

    /// @brief Gets damping ratio.
    Real GetDampingRatio() const { return m_dampingRatio; }

private:

    void InitVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step,
                                 const ConstraintSolverConf&) override;
    bool SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step) override;
    bool SolvePositionConstraints(BodyConstraintsMap& bodies,
                                  const ConstraintSolverConf& conf) const override;

    Length2 m_localAnchorA; ///< Local anchor A.
    Length2 m_localAnchorB; ///< Local anchor B.
    Angle m_referenceAngle; ///< Reference angle.
    Frequency m_frequency; ///< Frequency.
    Real m_dampingRatio; ///< Damping ratio.

    // Solver shared
    Vec3 m_impulse = Vec3{}; ///< Impulse.

    // Solver temp
    InvRotInertia m_gamma; ///< Gamma.
    AngularVelocity m_bias; ///< Bias.
    Length2 m_rA; ///< Relative A.
    Length2 m_rB; ///< Relative B.
    Mat33 m_mass; ///< Mass.
};

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_WELDJOINT_HPP
