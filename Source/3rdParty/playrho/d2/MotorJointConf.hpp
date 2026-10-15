/*
 * Original work Copyright (c) 2006-2012 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_D2_MOTORJOINTCONF_HPP
#define PLAYRHO_D2_MOTORJOINTCONF_HPP

/// @file
/// @brief Definition of the @c MotorJointConf class and closely related code.

// IWYU pragma: begin_exports

#include "playrho/NonNegative.hpp"
#include "playrho/Span.hpp"
#include "playrho/TypeInfo.hpp"

#include "playrho/d2/JointConf.hpp"
#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho {

struct ConstraintSolverConf;
struct StepConf;

namespace d2 {

class World;
class BodyConstraint;

/// @example MotorJoint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::MotorJointConf</code>.

/// @brief Motor joint definition.
/// @details A motor joint is used to control the relative motion between two bodies. A
///   typical usage is to control the movement of a dynamic body with respect to the ground.
/// @see Joint, World::CreateJoint
/// @ingroup JointsGroup
struct MotorJointConf : public JointBuilder<MotorJointConf> {
    /// @brief Super type.
    using super = JointBuilder<MotorJointConf>;

    /// @brief Default max force.
    static constexpr auto DefaultMaxForce = NonNegativeFF<Force>(1_N);

    /// @brief Default max torque.
    static constexpr auto DefaultMaxTorque = NonNegativeFF<Torque>(1_Nm);

    /// @brief Default correction factor.
    static constexpr auto DefaultCorrectionFactor = Real(0.3);

    /// @brief Default constructor.
    constexpr MotorJointConf() noexcept = default;

    /// @brief Initialize the bodies and offsets using the current transforms.
    MotorJointConf(BodyID bA, BodyID bB, // force line-break
                   const Length2& lo = Length2{}, Angle ao = 0_deg) noexcept;

    /// @brief Uses the given linear offset value.
    constexpr auto& UseLinearOffset(const Length2& v) noexcept
    {
        linearOffset = v;
        return *this;
    }

    /// @brief Uses the given angular offset value.
    constexpr auto& UseAngularOffset(Angle v) noexcept
    {
        angularOffset = v;
        return *this;
    }

    /// @brief Uses the given maximum force value.
    constexpr auto& UseMaxForce(NonNegative<Force> v) noexcept
    {
        maxForce = v;
        return *this;
    }

    /// @brief Uses the given max torque value.
    constexpr auto& UseMaxTorque(NonNegative<Torque> v) noexcept
    {
        maxTorque = v;
        return *this;
    }

    /// @brief Uses the given correction factor.
    constexpr auto& UseCorrectionFactor(Real v) noexcept
    {
        correctionFactor = v;
        return *this;
    }

    /// @brief Position of body-B minus the position of body-A, in body-A's frame.
    Length2 linearOffset = Length2{};

    /// @brief Angle of body-B minus angle of body-A.
    Angle angularOffset = 0_deg;

    Momentum2 linearImpulse{}; ///< Linear impulse.
    AngularMomentum angularImpulse{}; ///< Angular impulse.

    /// @brief Maximum motor force.
    NonNegative<Force> maxForce = DefaultMaxForce;

    /// @brief Maximum motor torque.
    NonNegative<Torque> maxTorque = DefaultMaxTorque;

    /// @brief Position correction factor in the range [0,1].
    Real correctionFactor = DefaultCorrectionFactor;

    // Solver temp
    Length2 rA = {}; ///< Relative A.
    Length2 rB = {}; ///< Relative B.
    Length2 linearError{}; ///< Linear error.
    Angle angularError = 0_deg; ///< Angular error.
    Mass22 linearMass = {}; ///< 2-by-2 linear mass matrix in kilograms.
    RotInertia angularMass = {}; ///< Angular mass.
};

/// @brief Equality operator.
constexpr bool operator==(const MotorJointConf& lhs, const MotorJointConf& rhs) noexcept
{
    return // First check base...
        (lhs.bodyA == rhs.bodyA) && (lhs.bodyB == rhs.bodyB) &&
        (lhs.collideConnected == rhs.collideConnected)
        // Now check rest...
        && (lhs.linearOffset == rhs.linearOffset) // line break
        && (lhs.angularOffset == rhs.angularOffset) // line break
        && (lhs.maxForce == rhs.maxForce) // line break
        && (lhs.maxTorque == rhs.maxTorque) // line break
        && (lhs.correctionFactor == rhs.correctionFactor) // line break
        && (lhs.rA == rhs.rA) // line break
        && (lhs.rB == rhs.rB) // line break
        && (lhs.linearError == rhs.linearError) // line break
        && (lhs.angularError == rhs.angularError) // line break
        && (lhs.linearMass == rhs.linearMass) // line break
        && (lhs.angularMass == rhs.angularMass);
}

/// @brief Inequality operator.
constexpr bool operator!=(const MotorJointConf& lhs, const MotorJointConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the definition data for the given joint.
/// @throws std::bad_cast If the given joint's type is inappropriate for getting this value.
/// @relatedalso Joint
MotorJointConf GetMotorJointConf(const Joint& joint);

/// @brief Gets the confguration for the given parameters.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
MotorJointConf GetMotorJointConf(const World& world, BodyID bA, BodyID bB);

/// @brief Gets the local anchor A.
/// @relatedalso MotorJointConf
constexpr auto GetLocalAnchorA(const MotorJointConf&) noexcept
{
    return Length2{};
}

/// @brief Gets the local anchor B.
/// @relatedalso MotorJointConf
constexpr auto GetLocalAnchorB(const MotorJointConf&) noexcept
{
    return Length2{};
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto ShiftOrigin(MotorJointConf&, const Length2&) noexcept
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
/// @relatedalso MotorJointConf
void InitVelocity(MotorJointConf& object, const Span<BodyConstraint>& bodies, const StepConf& step,
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
/// @relatedalso MotorJointConf
bool SolveVelocity(MotorJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @note This is a no-op and always returns <code>true</code>.
/// @return <code>true</code>.
/// @relatedalso MotorJointConf
bool SolvePosition(const MotorJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Free function for getting the maximum force value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto GetMaxForce(const MotorJointConf& object) noexcept
{
    return object.maxForce;
}

/// @brief Free function for setting the maximum force value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto SetMaxForce(MotorJointConf& object, NonNegative<Force> value) noexcept
{
    object.UseMaxForce(value);
}

/// @brief Free function for getting the maximum torque value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto GetMaxTorque(const MotorJointConf& object) noexcept
{
    return object.maxTorque;
}

/// @brief Free function for setting the maximum torque value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto SetMaxTorque(MotorJointConf& object, NonNegative<Torque> value) noexcept
{
    object.UseMaxTorque(value);
}

/// @brief Free function for getting the linear error value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto GetLinearError(const MotorJointConf& object) noexcept
{
    return object.linearError;
}

/// @brief Free function for getting the angular error value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto GetAngularError(const MotorJointConf& object) noexcept
{
    return object.angularError;
}

/// @brief Free function for getting the linear offset value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto GetLinearOffset(const MotorJointConf& object) noexcept
{
    return object.linearOffset;
}

/// @brief Free function for setting the linear offset value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto SetLinearOffset(MotorJointConf& object, const Length2& value) noexcept
{
    object.UseLinearOffset(value);
}

/// @brief Free function for getting the angular offset value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto GetAngularOffset(const MotorJointConf& object) noexcept
{
    return object.angularOffset;
}

/// @brief Free function for setting the angular offset value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto SetAngularOffset(MotorJointConf& object, Angle value) noexcept
{
    object.UseAngularOffset(value);
}

/// @brief Free function for getting the correction factor value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto GetCorrectionFactor(const MotorJointConf& object) noexcept
{
    return object.correctionFactor;
}

/// @brief Free function for setting the correction factor value of the given configuration.
/// @relatedalso MotorJointConf
constexpr auto SetCorrectionFactor(MotorJointConf& object, Real value) noexcept
{
    object.UseCorrectionFactor(value);
}

} // namespace d2
} // namespace playrho

/// @brief Type info specialization for <code>playrho::d2::MotorJointConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::MotorJointConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::MotorJointConf";
};

#endif // PLAYRHO_D2_MOTORJOINTCONF_HPP
