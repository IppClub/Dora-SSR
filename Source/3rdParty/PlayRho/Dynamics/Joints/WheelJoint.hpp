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

#ifndef PLAYRHO_DYNAMICS_JOINTS_WHEELJOINT_HPP
#define PLAYRHO_DYNAMICS_JOINTS_WHEELJOINT_HPP

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/WheelJointConf.hpp"

namespace playrho {
namespace d2 {

/// @brief Wheel joint.
///
/// @details This joint provides two degrees of freedom: translation along an axis
///   fixed in body A and rotation in the plane. In other words, it is a point to
///   line constraint with a rotational motor and a linear spring/damper.
///
/// @note This joint is designed for vehicle suspensions.
///
/// @ingroup JointsGroup
///
/// @image html WheelJoint.png
///
class WheelJoint : public Joint
{
public:
    
    /// @brief Initializing constructor.
    /// @attention To create or use the joint within a world instance, call that world
    ///   instance's create joint method instead of calling this constructor directly.
    /// @sa World::CreateJoint
    WheelJoint(const WheelJointConf& def);
    
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

    /// The local joint axis relative to body-A.
    UnitVec GetLocalAxisA() const { return m_localXAxisA; }

    /// Is the joint motor enabled?
    bool IsMotorEnabled() const noexcept { return m_enableMotor; }

    /// Enable/disable the joint motor.
    void EnableMotor(bool flag);
    
    /// @brief Gets the computed motor mass.
    /// @note This is zero unless motor is enabled and either body has any rotational inertia.
    RotInertia GetMotorMass() const noexcept { return m_motorMass; }

    /// Set the angular motor speed.
    void SetMotorSpeed(AngularVelocity speed);

    /// Get the angular motor speed.
    AngularVelocity GetMotorSpeed() const;

    /// @brief Sets the maximum motor torque.
    void SetMaxMotorTorque(Torque torque);

    /// @brief Gets the maximum motor torque.
    Torque GetMaxMotorTorque() const;

    /// @brief Sets the spring frequency.
    /// @note Setting the frequency to zero disables the spring.
    void SetSpringFrequency(Frequency frequency);

    /// @brief Gets the spring frequency.
    Frequency GetSpringFrequency() const;

    /// @brief Sets the spring damping ratio
    void SetSpringDampingRatio(Real ratio);

    /// @brief Gets the spring damping ratio
    Real GetSpringDampingRatio() const;

private:

    void InitVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step,
                                 const ConstraintSolverConf& conf) override;
    bool SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step) override;
    bool SolvePositionConstraints(BodyConstraintsMap& bodies,
                                  const ConstraintSolverConf& conf) const override;

    // Solver shared
    Length2 m_localAnchorA; ///< Local anchor A.
    Length2 m_localAnchorB; ///< Local anchor B.
    UnitVec m_localXAxisA; ///< Local X axis A.
    UnitVec m_localYAxisA; ///< Local Y axis A.

    Frequency m_frequency; ///< Frequency.
    Real m_dampingRatio; ///< Damping ratio.

    Momentum m_impulse = 0; ///< Impulse.
    AngularMomentum m_motorImpulse = 0; ///< Motor impulse.
    Momentum m_springImpulse = 0; ///< Spring impulse.

    Torque m_maxMotorTorque; ///< Max motor torque.
    AngularVelocity m_motorSpeed; ///< Motor speed.
    bool m_enableMotor; ///< Enable motor. <code>true</code> if motor is enabled.

    // Solver temp    
    UnitVec m_ax; ///< Solver A X directional.
    UnitVec m_ay; ///< Solver A Y directional.

    Length m_sAx; ///< Solver A x location.
    Length m_sBx; ///< Solver B x location.
    Length m_sAy; ///< Solver A y location.
    Length m_sBy; ///< Solver B y location.

    Mass m_mass = 0_kg; ///< Mass.
    RotInertia m_motorMass = RotInertia{0}; ///< Motor mass.
    Mass m_springMass = 0_kg; ///< Spring mass.

    LinearVelocity m_bias = 0_mps; ///< Bias.
    InvMass m_gamma = InvMass{0}; ///< Gamma.
};

inline AngularMomentum WheelJoint::GetAngularReaction() const
{
    return m_motorImpulse;
}

inline AngularVelocity WheelJoint::GetMotorSpeed() const
{
    return m_motorSpeed;
}

inline Torque WheelJoint::GetMaxMotorTorque() const
{
    return m_maxMotorTorque;
}

inline void WheelJoint::SetSpringFrequency(Frequency hz)
{
    m_frequency = hz;
}

inline Frequency WheelJoint::GetSpringFrequency() const
{
    return m_frequency;
}

inline void WheelJoint::SetSpringDampingRatio(Real ratio)
{
    m_dampingRatio = ratio;
}

inline Real WheelJoint::GetSpringDampingRatio() const
{
    return m_dampingRatio;
}

// Free functions on WheelJoint instances.

/// @brief Get the current joint translation.
/// @relatedalso WheelJoint
Length GetJointTranslation(const WheelJoint& joint) noexcept;

/// @brief Get the current joint translation speed.
/// @relatedalso WheelJoint
AngularVelocity GetAngularVelocity(const WheelJoint& joint) noexcept;

/// @brief Gets the current motor torque for the given joint for the given the inverse time step.
inline Torque GetMotorTorque(const WheelJoint& joint, Frequency inv_dt) noexcept
{
    return joint.GetAngularReaction() * inv_dt;
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_WHEELJOINT_HPP
