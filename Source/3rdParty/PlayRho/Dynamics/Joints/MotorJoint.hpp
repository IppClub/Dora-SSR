/*
 * Original work Copyright (c) 2006-2012 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_DYNAMICS_JOINTS_MOTORJOINT_HPP
#define PLAYRHO_DYNAMICS_JOINTS_MOTORJOINT_HPP

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/MotorJointConf.hpp"

namespace playrho {
namespace d2 {

/// @brief Motor joint.
///
/// @details A motor joint is used to control the relative motion between two bodies. A
///   typical usage is to control the movement of a dynamic body with respect to the ground.
///
/// @ingroup JointsGroup
///
class MotorJoint : public Joint
{
public:
    
    /// @brief Initializing constructor.
    /// @attention To create or use the joint within a world instance, call that world
    ///   instance's create joint method instead of calling this constructor directly.
    /// @sa World::CreateJoint
    MotorJoint(const MotorJointConf& def);
    
    void Accept(JointVisitor& visitor) const override;
    void Accept(JointVisitor& visitor) override;

    Length2 GetAnchorA() const override;
    Length2 GetAnchorB() const override;

    Momentum2 GetLinearReaction() const override;
    AngularMomentum GetAngularReaction() const override;

    /// @brief Gets the target linear offset, in frame A.
    Length2 GetLinearOffset() const noexcept;

    /// @brief Sets the target linear offset, in frame A.
    void SetLinearOffset(const Length2 linearOffset);

    /// @brief Gets the target angular offset.
    Angle GetAngularOffset() const noexcept;

    /// @brief Sets the target angular offset.
    void SetAngularOffset(Angle angularOffset);

    /// @brief Gets the maximum friction force.
    NonNegative<Force> GetMaxForce() const noexcept;

    /// @brief Sets the maximum friction force.
    void SetMaxForce(NonNegative<Force> force);

    /// @brief Gets the maximum friction torque.
    NonNegative<Torque> GetMaxTorque() const noexcept;

    /// @brief Sets the maximum friction torque.
    void SetMaxTorque(NonNegative<Torque> torque);

    /// @brief Gets the position correction factor in the range [0,1].
    Real GetCorrectionFactor() const noexcept;

    /// @brief Sets the position correction factor in the range [0,1].
    void SetCorrectionFactor(Real factor);
    
    /// @brief Gets the linear error.
    /// @note This is calculated by the <code>InitVelocityConstraints</code> method.
    Length2 GetLinearError() const noexcept;

    /// @brief Gets the angular error.
    /// @note This is calculated by the <code>InitVelocityConstraints</code> method.
    Angle GetAngularError() const noexcept;

private:

    void InitVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step,
                                 const ConstraintSolverConf& conf) override;
    bool SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step) override;
    bool SolvePositionConstraints(BodyConstraintsMap& bodies,
                                  const ConstraintSolverConf& conf) const override;

    // Solver shared
    Length2 m_linearOffset{}; ///< Linear offset.
    Angle m_angularOffset{}; ///< Angular offset.
    Momentum2 m_linearImpulse{}; ///< Linear impulse.
    AngularMomentum m_angularImpulse{}; ///< Angular impulse.
    NonNegative<Force> m_maxForce = NonNegative<Force>{0_N}; ///< Max force.
    NonNegative<Torque> m_maxTorque = NonNegative<Torque>{0_Nm}; ///< Max torque.
    Real m_correctionFactor{}; ///< Correction factor.

    // Solver temp
    Length2 m_rA; ///< Relative A.
    Length2 m_rB; ///< Relative B.
    Length2 m_linearError{}; ///< Linear error.
    Angle m_angularError{0_deg}; ///< Angular error.
    Mass22 m_linearMass; ///< 2-by-2 linear mass matrix in kilograms.
    RotInertia m_angularMass; ///< Angular mass.
};

inline NonNegative<Force> MotorJoint::GetMaxForce() const noexcept
{
    return m_maxForce;
}

inline void MotorJoint::SetMaxForce(NonNegative<Force> force)
{
    m_maxForce = force;
}

inline NonNegative<Torque> MotorJoint::GetMaxTorque() const noexcept
{
    return m_maxTorque;
}

inline void MotorJoint::SetMaxTorque(NonNegative<Torque> torque)
{
    m_maxTorque = torque;
}

inline Length2 MotorJoint::GetLinearOffset() const noexcept
{
    return m_linearOffset;
}

inline Angle MotorJoint::GetAngularOffset() const noexcept
{
    return m_angularOffset;
}

inline Momentum2 MotorJoint::GetLinearReaction() const
{
    return m_linearImpulse;
}

inline AngularMomentum MotorJoint::GetAngularReaction() const
{
    return m_angularImpulse;
}

inline Real MotorJoint::GetCorrectionFactor() const noexcept
{
    return m_correctionFactor;
}

inline Length2 MotorJoint::GetLinearError() const noexcept
{
    return m_linearError;
}

inline Angle MotorJoint::GetAngularError() const noexcept
{
    return m_angularError;
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_MOTORJOINT_HPP
