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

#ifndef PLAYRHO_DYNAMICS_JOINTS_PRISMATICJOINT_HPP
#define PLAYRHO_DYNAMICS_JOINTS_PRISMATICJOINT_HPP

#include "PlayRho/Dynamics/Joints/Joint.hpp"
#include "PlayRho/Dynamics/Joints/PrismaticJointConf.hpp"
#include "PlayRho/Common/BoundedValue.hpp"

namespace playrho {
namespace d2 {

/// @brief Prismatic Joint.
///
/// @details This joint provides one degree of freedom: translation along an axis fixed
///   in body-A. Relative rotation is prevented.
///
/// @note You can use a joint limit to restrict the range of motion and a joint motor
///   to drive the motion or to model joint friction.
///
/// @ingroup JointsGroup
///
/// @image html prismaticJoint.gif
///
/// @sa https://en.wikipedia.org/wiki/Prismatic_joint
///
class PrismaticJoint : public Joint
{
public:
    
    /// @brief Initializing constructor.
    /// @attention To create or use the joint within a world instance, call that world
    ///   instance's create joint method instead of calling this constructor directly.
    /// @sa World::CreateJoint
    PrismaticJoint(const PrismaticJointConf& def);
    
    void Accept(JointVisitor& visitor) const override;
    void Accept(JointVisitor& visitor) override;

    Length2 GetAnchorA() const override;
    Length2 GetAnchorB() const override;

    Momentum2 GetLinearReaction() const override;
    AngularMomentum GetAngularReaction() const override;

    /// @brief Gets the local anchor point relative to body A's origin.
    Length2 GetLocalAnchorA() const { return m_localAnchorA; }

    /// @brief Gets the local anchor point relative to body B's origin.
    Length2 GetLocalAnchorB() const  { return m_localAnchorB; }

    /// @brief Gets local joint axis relative to body-A.
    UnitVec GetLocalAxisA() const { return m_localXAxisA; }

    /// @brief Gets the reference angle.
    Angle GetReferenceAngle() const { return m_referenceAngle; }

    /// @brief Is the joint limit enabled?
    bool IsLimitEnabled() const noexcept;

    /// Enable/disable the joint limit.
    void EnableLimit(bool flag) noexcept;

    /// @brief Gets the lower joint limit.
    Length GetLowerLimit() const noexcept;

    /// @brief Gets the upper joint limit.
    Length GetUpperLimit() const noexcept;

    /// @brief Sets the joint limits.
    void SetLimits(Length lower, Length upper) noexcept;

    /// Is the joint motor enabled?
    bool IsMotorEnabled() const noexcept;

    /// Enable/disable the joint motor.
    void EnableMotor(bool flag) noexcept;

    /// @brief Sets the motor speed.
    void SetMotorSpeed(AngularVelocity speed) noexcept;

    /// @brief Gets the motor speed.
    AngularVelocity GetMotorSpeed() const noexcept;

    /// @brief Sets the maximum motor force.
    void SetMaxMotorForce(Force force) noexcept;

    /// @brief Gets the maximum motor force.
    Force GetMaxMotorForce() const noexcept { return m_maxMotorForce; }

    /// @brief Gets the current motor impulse.
    Momentum GetMotorImpulse() const noexcept { return m_motorImpulse; }

    /// @brief Gets the current limit state.
    /// @note This will be <code>e_inactiveLimit</code> unless the joint limit has been
    ///   enabled.
    LimitState GetLimitState() const noexcept;
    
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
    Angle m_referenceAngle; ///< Reference angle.
    Vec3 m_impulse = Vec3{}; ///< Impulse.
    Momentum m_motorImpulse = 0; ///< Motor impulse.
    Length m_lowerTranslation; ///< Lower translation.
    Length m_upperTranslation; ///< Upper translation.
    Force m_maxMotorForce; ///< Max motor force.
    AngularVelocity m_motorSpeed; ///< Motor speed.
    bool m_enableLimit; ///< Enable limit. <code>true</code> if limit is enabled.
    bool m_enableMotor; ///< Enable motor. <code>true</code> if motor is enabled.
    LimitState m_limitState = e_inactiveLimit; ///< Limit state.

    // Solver temp
    UnitVec m_axis = UnitVec::GetZero(); ///< Axis.
    UnitVec m_perp = UnitVec::GetZero(); ///< Perpendicular.
    Length m_s1; ///< Location S-1.
    Length m_s2; ///< Location S-2.
    Length m_a1; ///< Location A-1.
    Length m_a2; ///< Location A-2.
    Mat33 m_K; ///< K matrix.
    Mass m_motorMass = 0_kg; ///< Motor mass.
};

inline Length PrismaticJoint::GetLowerLimit() const noexcept
{
    return m_lowerTranslation;
}

inline Length PrismaticJoint::GetUpperLimit() const noexcept
{
    return m_upperTranslation;
}

inline bool PrismaticJoint::IsLimitEnabled() const noexcept
{
    return m_enableLimit;
}

inline bool PrismaticJoint::IsMotorEnabled() const noexcept
{
    return m_enableMotor;
}

inline AngularVelocity PrismaticJoint::GetMotorSpeed() const noexcept
{
    return m_motorSpeed;
}

inline Joint::LimitState PrismaticJoint::GetLimitState() const noexcept
{
    return m_limitState;
}

/// @brief Get the current joint translation.
/// @relatedalso PrismaticJoint
Length GetJointTranslation(const PrismaticJoint& joint) noexcept;

/// @brief Get the current joint translation speed.
/// @relatedalso PrismaticJoint
LinearVelocity GetLinearVelocity(const PrismaticJoint& joint) noexcept;

/// @brief Gets the current motor force for the given joint, given the inverse time step.
/// @relatedalso PrismaticJoint
inline Force GetMotorForce(const PrismaticJoint& joint, Frequency inv_dt) noexcept
{
    return joint.GetMotorImpulse() * inv_dt;
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_PRISMATICJOINT_HPP
