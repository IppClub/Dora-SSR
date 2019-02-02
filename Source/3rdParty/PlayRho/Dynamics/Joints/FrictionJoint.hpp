/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_DYNAMICS_JOINTS_FRICTIONJOINT_HPP
#define PLAYRHO_DYNAMICS_JOINTS_FRICTIONJOINT_HPP

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/FrictionJointConf.hpp"
#include "PlayRho/Common/BoundedValue.hpp"

namespace playrho {
namespace d2 {

/// @brief Friction joint.
///
/// @details This is used for top-down friction. It provides 2-D translational friction
///   and angular friction.
///
/// @ingroup JointsGroup
///
class FrictionJoint : public Joint
{
public:
    
    /// @brief Initializing constructor.
    /// @attention To create or use the joint within a world instance, call that world
    ///   instance's create joint method instead of calling this constructor directly.
    /// @sa World::CreateJoint
    FrictionJoint(const FrictionJointConf& def);

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

    /// Set the maximum friction force in N.
    void SetMaxForce(NonNegative<Force> force);

    /// Get the maximum friction force in N.
    NonNegative<Force> GetMaxForce() const;

    /// Set the maximum friction torque in N*m.
    void SetMaxTorque(NonNegative<Torque> torque);

    /// Get the maximum friction torque in N*m.
    NonNegative<Torque> GetMaxTorque() const;

private:

    void InitVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step,
                                 const ConstraintSolverConf& conf) override;
    bool SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step) override;
    bool SolvePositionConstraints(BodyConstraintsMap& bodies,
                                  const ConstraintSolverConf& conf) const override;

    Length2 m_localAnchorA; ///< Local anchor A.
    Length2 m_localAnchorB; ///< Local anchor B.
    NonNegative<Force> m_maxForce = NonNegative<Force>{0_N}; ///< Max force.
    NonNegative<Torque> m_maxTorque = NonNegative<Torque>{0_Nm}; ///< Max torque.

    // Solver shared data - data saved & updated over multiple InitVelocityConstraints calls.
    Momentum2 m_linearImpulse = Momentum2{}; ///< Linear impulse.
    AngularMomentum m_angularImpulse = AngularMomentum{0}; ///< Angular impulse.

    // Solver temp
    Length2 m_rA; ///< Relative A.
    Length2 m_rB; ///< Relative B.
    Mass22 m_linearMass; ///< 2-by-2 linear mass matrix in kilograms.
    RotInertia m_angularMass; ///< Angular mass.
};

inline void FrictionJoint::SetMaxForce(NonNegative<Force> force)
{
    m_maxForce = force;
}

inline NonNegative<Force> FrictionJoint::GetMaxForce() const
{
    return m_maxForce;
}

inline void FrictionJoint::SetMaxTorque(NonNegative<Torque> torque)
{
    m_maxTorque = torque;
}

inline NonNegative<Torque> FrictionJoint::GetMaxTorque() const
{
    return m_maxTorque;
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_FRICTIONJOINT_HPP
