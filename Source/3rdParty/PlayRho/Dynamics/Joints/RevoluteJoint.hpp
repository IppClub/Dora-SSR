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

#ifndef PLAYRHO_DYNAMICS_JOINTS_REVOLUTEJOINT_HPP
#define PLAYRHO_DYNAMICS_JOINTS_REVOLUTEJOINT_HPP

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/RevoluteJointConf.hpp"

namespace playrho {
namespace d2 {

/// @brief Revolute Joint.
///
/// @details A revolute joint constrains two bodies to share a common point while they
/// are free to rotate about the point. The relative rotation about the shared
/// point is the joint angle.
///
/// @note You can limit the relative rotation with a joint limit that specifies a
///   lower and upper angle. You can use a motor to drive the relative rotation about
///   the shared point. A maximum motor torque is provided so that infinite forces are
///   not generated.
///
/// @ingroup JointsGroup
///
/// @image html revoluteJoint.gif
///
/// @sa https://en.wikipedia.org/wiki/Revolute_joint
///
class RevoluteJoint : public Joint
{
public:
    
    /// @brief Initializing constructor.
    /// @attention To create or use the joint within a world instance, call that world
    ///   instance's create joint method instead of calling this constructor directly.
    /// @sa World::CreateJoint
    RevoluteJoint(const RevoluteJointConf& def);
    
    void Accept(JointVisitor& visitor) const override;
    void Accept(JointVisitor& visitor) override;

    Length2 GetAnchorA() const override;
    Length2 GetAnchorB() const override;

    /// The local anchor point relative to body A's origin.
    Length2 GetLocalAnchorA() const noexcept { return m_localAnchorA; }

    /// The local anchor point relative to body B's origin.
    Length2 GetLocalAnchorB() const noexcept { return m_localAnchorB; }

    /// Get the reference angle.
    Angle GetReferenceAngle() const noexcept { return m_referenceAngle; }

    /// Is the joint limit enabled?
    bool IsLimitEnabled() const noexcept;

    /// Enable/disable the joint limit.
    void EnableLimit(bool flag);

    /// Get the lower joint limit.
    Angle GetLowerLimit() const noexcept;

    /// Get the upper joint limit.
    Angle GetUpperLimit() const noexcept;

    /// Set the joint limits.
    void SetLimits(Angle lower, Angle upper);

    /// Is the joint motor enabled?
    bool IsMotorEnabled() const noexcept;

    /// Enable/disable the joint motor.
    void EnableMotor(bool flag);

    /// Set the angular motor speed.
    void SetMotorSpeed(AngularVelocity speed);

    /// Gets the angular motor speed.
    AngularVelocity GetMotorSpeed() const noexcept;

    /// Set the maximum motor torque.
    void SetMaxMotorTorque(Torque torque);

    /// @brief Gets the max motor torque.
    Torque GetMaxMotorTorque() const noexcept;

    /// Get the linear reaction.
    Momentum2 GetLinearReaction() const override;

    /// Get the angular reaction due to the joint limit.
    AngularMomentum GetAngularReaction() const override;

    /// @brief Gets the current motor impulse.
    AngularMomentum GetMotorImpulse() const noexcept;
    
    /// @brief Gets the current limit state.
    /// @note This will be <code>e_inactiveLimit</code> unless the joint limit has been
    ///   enabled.
    LimitState GetLimitState() const noexcept;

private:
    
    void InitVelocityConstraints(BodyConstraintsMap& bodies,
                                 const StepConf& step, const ConstraintSolverConf& conf) override;

    bool SolveVelocityConstraints(BodyConstraintsMap& bodies, const StepConf& step) override;
    
    bool SolvePositionConstraints(BodyConstraintsMap& bodies,
                                  const ConstraintSolverConf& conf) const override;

    // Solver shared
    Length2 m_localAnchorA; ///< Local anchor A.
    Length2 m_localAnchorB; ///< Local anchor B.

    /// @brief Impulse.
    /// @note Modified by: <code>InitVelocityConstraints</code>,
    ///   <code>SolveVelocityConstraints</code>.
    Vec3 m_impulse = Vec3{};
    
    /// @brief Motor impulse.
    /// @note Modified by: <code>InitVelocityConstraints</code>,
    ///   <code>SolveVelocityConstraints</code>.
    AngularMomentum m_motorImpulse = 0;

    bool m_enableMotor; ///< Enable motor. <code>true</code> if motor is enabled.
    Torque m_maxMotorTorque; ///< Max motor torque.
    AngularVelocity m_motorSpeed; ///< Motor speed.

    bool m_enableLimit; ///< Enable limit. <code>true</code> if limit is enabled.
    Angle m_referenceAngle; ///< Reference angle.
    Angle m_lowerAngle; ///< Lower angle.
    Angle m_upperAngle; ///< Upper angle.

    // Solver cached temporary data. Values set by by InitVelocityConstraints.

    Length2 m_rA; ///< Rotated delta of body A's local center from local anchor A.
    Length2 m_rB; ///< Rotated delta of body B's local center from local anchor B.
    Mat33 m_mass; ///< Effective mass for point-to-point constraint.
    RotInertia m_motorMass; ///< Effective mass for motor/limit angular constraint.
    LimitState m_limitState = e_inactiveLimit; ///< Limit state.
};

inline bool RevoluteJoint::IsLimitEnabled() const noexcept
{
    return m_enableLimit;
}

inline Angle RevoluteJoint::GetLowerLimit() const noexcept
{
    return m_lowerAngle;
}

inline Angle RevoluteJoint::GetUpperLimit() const noexcept
{
    return m_upperAngle;
}

inline bool RevoluteJoint::IsMotorEnabled() const noexcept
{
    return m_enableMotor;
}

inline AngularVelocity RevoluteJoint::GetMotorSpeed() const noexcept
{
    return m_motorSpeed;
}

inline Torque RevoluteJoint::GetMaxMotorTorque() const noexcept
{
    return m_maxMotorTorque;
}

inline Joint::LimitState RevoluteJoint::GetLimitState() const noexcept
{
    return m_limitState;
}

inline AngularMomentum RevoluteJoint::GetMotorImpulse() const noexcept
{
    return m_motorImpulse;
}

// Free functions...

/// @brief Gets the current joint angle.
/// @relatedalso RevoluteJoint
Angle GetJointAngle(const RevoluteJoint& joint);
    
/// @brief Gets the current joint angle speed.
/// @relatedalso RevoluteJoint
AngularVelocity GetAngularVelocity(const RevoluteJoint& joint);

/// @brief Gets the current motor torque for the given joint given the inverse time step.
/// @relatedalso RevoluteJoint
inline Torque GetMotorTorque(const RevoluteJoint& joint, Frequency inv_dt) noexcept
{
    return joint.GetMotorImpulse() * inv_dt;
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_REVOLUTEJOINT_HPP
