/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_D2_REVOLUTEJOINTCONF_HPP
#define PLAYRHO_D2_REVOLUTEJOINTCONF_HPP

/// @file
/// @brief Definition of the @c RevoluteJointConf class and closely related code.

// IWYU pragma: begin_exports

#include "playrho/LimitState.hpp"
#include "playrho/Span.hpp"
#include "playrho/TypeInfo.hpp"
#include "playrho/Vector3.hpp"

#include "playrho/d2/JointConf.hpp"
#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho {

struct ConstraintSolverConf;
struct StepConf;

namespace d2 {

class World;
class BodyConstraint;

/// @example RevoluteJoint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::RevoluteJointConf</code>.

/// @brief Revolute joint definition.
/// @details A revolute joint constrains two bodies to share a common point while they
///   are free to rotate about the point. The relative rotation about the shared point
///   is the joint angle. This requires defining an anchor point where the bodies are
///   joined. The definition uses local anchor points so that the initial configuration
///   can violate the constraint slightly. You also need to specify the initial relative
///   angle for joint limits. This helps when saving and loading a game.
/// @note The local anchor points are measured from the body's origin
///   rather than the center of mass because:
///    1. you might not know where the center of mass will be;
///    2. if you add/remove shapes from a body and recompute the mass,
///       the joints will be broken.
/// @note You can limit the relative rotation with a joint limit that specifies a
///   lower and upper angle. You can use a motor to drive the relative rotation about
///   the shared point. A maximum motor torque is provided so that infinite forces are
///   not generated.
/// @ingroup JointsGroup
/// @image html revoluteJoint.gif
/// @see https://en.wikipedia.org/wiki/Revolute_joint
/// @see Joint, World::CreateJoint
struct RevoluteJointConf : public JointBuilder<RevoluteJointConf> {
    /// @brief Super type.
    using super = JointBuilder<RevoluteJointConf>;

    /// @brief Default constructor.
    constexpr RevoluteJointConf() noexcept = default;

    /// @brief Initialize the bodies, anchors, and reference angle using a world anchor point.
    RevoluteJointConf(BodyID bA, BodyID bB, // force line-break
                      const Length2& laA = Length2{}, const Length2& laB = Length2{},
                      Angle ra = 0_deg) noexcept;

    /// @brief Uses the given enable limit state value.
    constexpr auto& UseEnableLimit(bool v) noexcept
    {
        enableLimit = v;
        return *this;
    }

    /// @brief Uses the given lower angle value.
    constexpr auto& UseLowerAngle(Angle v) noexcept
    {
        lowerAngle = v;
        return *this;
    }

    /// @brief Uses the given upper angle value.
    constexpr auto& UseUpperAngle(Angle v) noexcept
    {
        upperAngle = v;
        return *this;
    }

    /// @brief Uses the given enable motor state value.
    constexpr auto& UseEnableMotor(bool v) noexcept
    {
        enableMotor = v;
        return *this;
    }

    /// @brief Uses the given motor speed value.
    constexpr auto& UseMotorSpeed(AngularVelocity v) noexcept
    {
        motorSpeed = v;
        return *this;
    }

    /// @brief Uses the given max motor torque value.
    constexpr auto& UseMaxMotorTorque(Torque v) noexcept
    {
        maxMotorTorque = v;
        return *this;
    }

    /// @brief Local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{};

    /// @brief Local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{};

    /// @brief Impulse.
    /// @note Modified by: <code>InitVelocity</code>,
    ///   <code>SolveVelocityConstraints</code>.
    Vec3 impulse = Vec3{};

    /// @brief Motor impulse.
    /// @note Modified by: <code>InitVelocity</code>, <code>SolveVelocity</code>.
    AngularMomentum angularMotorImpulse = {};

    /// @brief Reference angle.
    /// @details This is the body-B angle minus body-A angle in the reference state (radians).
    Angle referenceAngle = 0_deg;

    /// @brief Flag to enable joint limits.
    bool enableLimit = false;

    /// @brief Lower angle for the joint limit.
    Angle lowerAngle = 0_deg;

    /// @brief Upper angle for the joint limit.
    Angle upperAngle = 0_deg;

    /// @brief Flag to enable the joint motor.
    bool enableMotor = false;

    /// @brief Desired motor speed.
    AngularVelocity motorSpeed = 0_rpm;

    /// @brief Maximum motor torque used to achieve the desired motor speed.
    Torque maxMotorTorque = 0_Nm;

    Length2 rA = {}; ///< Rotated delta of body A's local center from local anchor A.
    Length2 rB = {}; ///< Rotated delta of body B's local center from local anchor B.
    Mat33 mass = {}; ///< Effective mass for point-to-point constraint.
    RotInertia angularMass = {}; ///< Effective mass for motor/limit angular constraint.
    LimitState limitState = LimitState::e_inactiveLimit; ///< Limit state.
};

/// @brief Equality operator.
constexpr bool operator==(const RevoluteJointConf& lhs, const RevoluteJointConf& rhs) noexcept
{
    return // First check base...
        (lhs.bodyA == rhs.bodyA) && (lhs.bodyB == rhs.bodyB) &&
        (lhs.collideConnected == rhs.collideConnected)
        // Now check rest...
        && (lhs.localAnchorA == rhs.localAnchorA) && (lhs.localAnchorB == rhs.localAnchorB) &&
        (lhs.impulse == rhs.impulse) && (lhs.angularMotorImpulse == rhs.angularMotorImpulse) &&
        (lhs.referenceAngle == rhs.referenceAngle) && (lhs.enableLimit == rhs.enableLimit) &&
        (lhs.lowerAngle == rhs.lowerAngle) && (lhs.upperAngle == rhs.upperAngle) &&
        (lhs.enableMotor == rhs.enableMotor) && (lhs.motorSpeed == rhs.motorSpeed) &&
        (lhs.maxMotorTorque == rhs.maxMotorTorque) && (lhs.rA == rhs.rA) && (lhs.rB == rhs.rB) &&
        (lhs.mass == rhs.mass) && (lhs.angularMass == rhs.angularMass) &&
        (lhs.limitState == rhs.limitState);
}

/// @brief Inequality operator.
constexpr bool operator!=(const RevoluteJointConf& lhs, const RevoluteJointConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the definition data for the given joint.
/// @throws std::bad_cast If the given joint's type is inappropriate for getting this value.
/// @relatedalso Joint
RevoluteJointConf GetRevoluteJointConf(const Joint& joint);

/// @brief Gets the configuration for the given parameters.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
RevoluteJointConf GetRevoluteJointConf(const World& world, BodyID bodyA, BodyID bodyB,
                                       const Length2& anchor);

/// @brief Gets the current angle of the given configuration in the given world.
/// @param world The world the given joint configuration relates to.
/// @param conf Configuration of the joint to get the angle for.
/// @throws std::out_of_range If given an invalid body identifier in the joint configuration.
/// @relatedalso World
Angle GetAngle(const World& world, const RevoluteJointConf& conf);

/// @brief Gets the current angular velocity of the given configuration.
/// @param world The world the given joint configuration relates to.
/// @param conf Configuration of the joint to get the angular velocity for.
/// @throws std::out_of_range If given an invalid body identifier in the joint configuration.
/// @relatedalso World
AngularVelocity GetAngularVelocity(const World& world, const RevoluteJointConf& conf);

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso RevoluteJointConf
constexpr auto ShiftOrigin(RevoluteJointConf&, const Length2&) noexcept
{
    return false;
}

/// @brief Free function for getting the angular lower limit value of the given configuration.
/// @relatedalso RevoluteJointConf
constexpr Angle GetAngularLowerLimit(const RevoluteJointConf& conf) noexcept
{
    return conf.lowerAngle;
}

/// @brief Free function for getting the angular upper limit value of the given configuration.
/// @relatedalso RevoluteJointConf
constexpr Angle GetAngularUpperLimit(const RevoluteJointConf& conf) noexcept
{
    return conf.upperAngle;
}

/// @brief Gets the current linear reaction of the given configuration.
/// @relatedalso RevoluteJointConf
constexpr Momentum2 GetLinearReaction(const RevoluteJointConf& conf) noexcept
{
    return Momentum2{GetX(conf.impulse) * NewtonSecond, GetY(conf.impulse) * NewtonSecond};
}

/// @brief Gets the current angular reaction of the given configuration.
/// @relatedalso RevoluteJointConf
constexpr AngularMomentum GetAngularReaction(const RevoluteJointConf& conf) noexcept
{
    // AngularMomentum is L^2 M T^-1 QP^-1.
    return GetZ(conf.impulse) * SquareMeter * Kilogram / (Second * Radian);
}

/// @brief Initializes velocity constraint data based on the given solver data.
/// @note This MUST be called prior to calling <code>SolveVelocity</code>.
/// @param object Configuration object. <code>bodyA</code> and <code>bodyB</code> must index bodies within
///   the given <code>bodies</code> container or be the special body ID value of <code>InvalidBodyID</code>.
/// @param bodies Container of body constraints.
/// @param step Configuration for the step.
/// @param conf Constraint solver configuration.
/// @throws std::out_of_range If the given object's <code>bodyA</code> or <code>bodyB</code> values are not
///  <code>InvalidBodyID</code> and are not  indices within range of the given <code>bodies</code> container.
/// @see SolveVelocityConstraints.
/// @relatedalso RevoluteJointConf
void InitVelocity(RevoluteJointConf& object, const Span<BodyConstraint>& bodies,
                  const StepConf& step, const ConstraintSolverConf& conf);

/// @brief Solves velocity constraint.
/// @pre <code>InitVelocity</code> has been called.
/// @param object Configuration object. <code>bodyA</code> and <code>bodyB</code> must index bodies within
///   the given <code>bodies</code> container or be the special body ID value of <code>InvalidBodyID</code>.
/// @param bodies Container of body constraints.
/// @param step Configuration for the step.
/// @throws std::out_of_range If the given object's <code>bodyA</code> or <code>bodyB</code> values are not
///  <code>InvalidBodyID</code> and are not  indices within range of the given <code>bodies</code> container.
/// @see InitVelocity.
/// @return <code>true</code> if velocity is "solved", <code>false</code> otherwise.
/// @relatedalso RevoluteJointConf
bool SolveVelocity(RevoluteJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @param object Configuration object. <code>bodyA</code> and <code>bodyB</code> must index bodies within
///   the given <code>bodies</code> container or be the special body ID value of <code>InvalidBodyID</code>.
/// @param bodies Container of body constraints.
/// @param conf Constraint solver configuration.
/// @throws std::out_of_range If the given object's <code>bodyA</code> or <code>bodyB</code> values are not
///  <code>InvalidBodyID</code> and are not  indices within range of the given <code>bodies</code> container.
/// @return <code>true</code> if the position errors are within tolerance.
/// @relatedalso RevoluteJointConf
bool SolvePosition(const RevoluteJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Free function for setting the angular limits of the given configuration.
/// @relatedalso RevoluteJointConf
constexpr void SetAngularLimits(RevoluteJointConf& object, Angle lower, Angle upper) noexcept
{
    object.UseLowerAngle(lower).UseUpperAngle(upper);
}

/// @brief Free function for setting the max motor torque of the given configuration.
/// @relatedalso RevoluteJointConf
constexpr void SetMaxMotorTorque(RevoluteJointConf& object, Torque value)
{
    object.UseMaxMotorTorque(value);
}

} // namespace d2
} // namespace playrho

/// @brief Type info specialization for <code>d2::RevoluteJointConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::RevoluteJointConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::RevoluteJointConf";
};

#endif // PLAYRHO_D2_REVOLUTEJOINTCONF_HPP
