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

#ifndef PLAYRHO_D2_WHEELJOINTCONF_HPP
#define PLAYRHO_D2_WHEELJOINTCONF_HPP

/// @file
/// @brief Definition of the @c WheelJointConf class and closely related code.

// IWYU pragma: begin_exports

#include "playrho/BodyID.hpp"
#include "playrho/NonNegative.hpp"
#include "playrho/Real.hpp"
#include "playrho/Span.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"

#include "playrho/detail/TypeInfo.hpp"

#include "playrho/d2/JointConf.hpp"
#include "playrho/d2/Math.hpp"
#include "playrho/d2/UnitVec.hpp"

// IWYU pragma: end_exports

namespace playrho {
struct ConstraintSolverConf;
struct StepConf;
}

namespace playrho::d2 {

class World;
class BodyConstraint;

/// @example WheelJoint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::WheelJointConf</code>.

/// @brief Wheel joint definition.
/// @details This joint provides two degrees of freedom: translation along an axis fixed
///   in body A and rotation in the plane. In other words, it is a point to line constraint
///   with a rotational motor and a linear spring/damper. This requires defining a line of
///   motion using an axis and an anchor point. The definition uses local anchor points and
///   a local axis so that the initial configuration can violate the constraint slightly.
///   The joint translation is zero when the local anchor points coincide in world space.
///   Using local anchors and a local axis helps when saving and loading a game.
/// @note This joint is designed for vehicle suspensions.
/// @ingroup JointsGroup
/// @image html WheelJoint.png
/// @see Joint, World::CreateJoint
struct WheelJointConf : public JointBuilder<WheelJointConf> {
    /// @brief Super type.
    using super = JointBuilder<WheelJointConf>;

    /// @brief Default frequency.
    static constexpr auto DefaultFrequency = NonNegative<Frequency>{2_Hz};

    /// @brief Default damping ratio.
    static constexpr auto DefaultDampingRatio = Real(0.7f);

    /// @brief Default constructor.
    constexpr WheelJointConf() noexcept = default;

    /// Initialize the bodies, anchors, axis, and reference angle using the world
    /// anchor and world axis.
    WheelJointConf(BodyID bA, BodyID bB, // force line-break
                   const Length2& laA = Length2{}, const Length2& laB = Length2{},
                   const UnitVec& axis = UnitVec::GetRight()) noexcept;

    /// @brief Uses the given enable motor state value.
    constexpr auto& UseEnableMotor(bool v) noexcept
    {
        enableMotor = v;
        return *this;
    }

    /// @brief Uses the given max motor toque value.
    constexpr auto& UseMaxMotorTorque(Torque v) noexcept
    {
        maxMotorTorque = v;
        return *this;
    }

    /// @brief Uses the given motor speed value.
    constexpr auto& UseMotorSpeed(AngularVelocity v) noexcept
    {
        motorSpeed = v;
        return *this;
    }

    /// @brief Uses the given frequency value.
    constexpr auto& UseFrequency(NonNegative<Frequency> v) noexcept
    {
        frequency = v;
        return *this;
    }

    /// @brief Uses the given damping ratio value.
    constexpr auto& UseDampingRatio(Real v) noexcept
    {
        dampingRatio = v;
        return *this;
    }

    /// The local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{};

    /// The local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{};

    /// The local X translation axis in body-A.
    UnitVec localXAxisA = UnitVec::GetRight();

    /// The local Y translation axis in body-A.
    UnitVec localYAxisA = GetRevPerpendicular(UnitVec::GetRight());

    /// Enable/disable the joint motor.
    bool enableMotor = false;

    /// The maximum motor torque.
    Torque maxMotorTorque = Torque{};

    /// The desired angular motor speed.
    AngularVelocity motorSpeed = 0_rpm;

    /// Suspension frequency, zero indicates no suspension
    NonNegative<Frequency> frequency = DefaultFrequency;

    /// Suspension damping ratio, one indicates critical damping
    Real dampingRatio = DefaultDampingRatio;

    Momentum impulse = 0_Ns; ///< Impulse.
    AngularMomentum angularImpulse = {}; ///< Angular impulse.
    Momentum springImpulse = 0_Ns; ///< Spring impulse.

    UnitVec ax; ///< Solver A X directional.
    UnitVec ay; ///< Solver A Y directional.

    Length sAx = 0_m; ///< Solver A x location.
    Length sBx = 0_m; ///< Solver B x location.
    Length sAy = 0_m; ///< Solver A y location.
    Length sBy = 0_m; ///< Solver B y location.

    Mass mass = 0_kg; ///< Mass.
    RotInertia angularMass = RotInertia{}; ///< Motor mass.
    Mass springMass = 0_kg; ///< Spring mass.

    LinearVelocity bias = 0_mps; ///< Bias.
    InvMass gamma = InvMass{}; ///< Gamma.
};

/// @brief Equality operator.
constexpr bool operator==(const WheelJointConf& lhs, const WheelJointConf& rhs) noexcept
{
    return // First check base...
        (lhs.bodyA == rhs.bodyA) && (lhs.bodyB == rhs.bodyB) &&
        (lhs.collideConnected == rhs.collideConnected)
        // Now check rest...
        && (lhs.localAnchorA == rhs.localAnchorA) // line break
        && (lhs.localAnchorB == rhs.localAnchorB) // line break
        && (lhs.localXAxisA == rhs.localXAxisA) // line break
        && (lhs.localYAxisA == rhs.localYAxisA) // line break
        && (lhs.enableMotor == rhs.enableMotor) // line break
        && (lhs.maxMotorTorque == rhs.maxMotorTorque) // line break
        && (lhs.motorSpeed == rhs.motorSpeed) // line break
        && (lhs.frequency == rhs.frequency) // line break
        && (lhs.dampingRatio == rhs.dampingRatio) // line break
        && (lhs.impulse == rhs.impulse) // line break
        && (lhs.angularImpulse == rhs.angularImpulse) // line break
        && (lhs.springImpulse == rhs.springImpulse) // line break
        && (lhs.ax == rhs.ax) // line break
        && (lhs.ay == rhs.ay) // line break
        && (lhs.sAx == rhs.sAx) // line break
        && (lhs.sBx == rhs.sBx) // line break
        && (lhs.sAy == rhs.sAy) // line break
        && (lhs.sBy == rhs.sBy) // line break
        && (lhs.mass == rhs.mass) // line break
        && (lhs.angularMass == rhs.angularMass) // line break
        && (lhs.springMass == rhs.springMass) // line break
        && (lhs.bias == rhs.bias) // line break
        && (lhs.gamma == rhs.gamma);
}

/// @brief Inequality operator.
constexpr bool operator!=(const WheelJointConf& lhs, const WheelJointConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the definition data for the given joint.
/// @throws std::bad_cast If the given joint's type is inappropriate for getting this value.
/// @relatedalso Joint
WheelJointConf GetWheelJointConf(const Joint& joint);

/// @brief Gets the definition data for the given parameters.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
WheelJointConf GetWheelJointConf(const World& world, BodyID bodyA, BodyID bodyB, // force line-break
                                 const Length2& anchor, const UnitVec& axis = UnitVec::GetRight());

/// @brief Gets the angular velocity for the given configuration within the specified world.
/// @param world The world the given joint configuration relates to.
/// @param conf Configuration of the joint to get the angular velocity for.
/// @throws std::out_of_range If given an invalid body identifier in the joint configuration.
/// @relatedalso World
AngularVelocity GetAngularVelocity(const World& world, const WheelJointConf& conf);

/// @brief Gets the current linear reaction for the given configuration.
/// @relatedalso WheelJointConf
constexpr Momentum2 GetLinearReaction(const WheelJointConf& object)
{
    return object.impulse * object.ay + object.springImpulse * object.ax;
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso WheelJointConf
constexpr auto ShiftOrigin(WheelJointConf&, const Length2&)
{
    return false;
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
/// @see SolveVelocity.
/// @relatedalso WheelJointConf
void InitVelocity(WheelJointConf& object, const Span<BodyConstraint>& bodies, const StepConf& step,
                  const ConstraintSolverConf& conf);

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
/// @relatedalso WheelJointConf
bool SolveVelocity(WheelJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @param object Configuration object. <code>bodyA</code> and <code>bodyB</code> must index bodies within
///   the given <code>bodies</code> container or be the special body ID value of <code>InvalidBodyID</code>.
/// @param bodies Container of body constraints.
/// @param conf Constraint solver configuration.
/// @throws std::out_of_range If the given object's <code>bodyA</code> or <code>bodyB</code> values are not
///  <code>InvalidBodyID</code> and are not  indices within range of the given <code>bodies</code> container.
/// @return <code>true</code> if the position errors are within tolerance.
/// @relatedalso WheelJointConf
bool SolvePosition(const WheelJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Sets the maximum motor torque for the given configuration.
/// @relatedalso WheelJointConf
constexpr void SetMaxMotorTorque(WheelJointConf& object, Torque value) noexcept
{
    object.UseMaxMotorTorque(value);
}

/// @brief Free function for setting the frequency of the given configuration.
/// @relatedalso WheelJointConf
constexpr void SetFrequency(WheelJointConf& object, NonNegative<Frequency> value) noexcept
{
    object.UseFrequency(value);
}

/// @brief Free function for setting the damping ratio of the given configuration.
/// @relatedalso WheelJointConf
constexpr void SetDampingRatio(WheelJointConf& object, Real value) noexcept
{
    object.UseDampingRatio(value);
}

} // namespace playrho::d2

/// @brief Type info specialization for <code>d2::WheelJointConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::WheelJointConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::WheelJointConf";
};

#endif // PLAYRHO_D2_WHEELJOINTCONF_HPP
