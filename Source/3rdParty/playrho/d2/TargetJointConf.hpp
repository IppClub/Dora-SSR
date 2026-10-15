/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_D2_MOUSEJOINTCONF_HPP
#define PLAYRHO_D2_MOUSEJOINTCONF_HPP

/// @file
/// @brief Definition of the @c TargetJointConf class and closely related code.

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

class BodyConstraint;

/// @example TargetJoint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::TargetJointConf</code>.

/// @brief Target joint definition.
/// @details A target joint is used to make a point on a body track a specified world point.
///   This a soft constraint with a maximum force. This allows the constraint to stretch and
///   without applying huge forces.
/// @ingroup JointsGroup
/// @see Joint, World::CreateJoint
struct TargetJointConf : public JointBuilder<TargetJointConf> {
    /// @brief Super type.
    using super = JointBuilder<TargetJointConf>;

    /// @brief Default frequency.
    static constexpr auto DefaultFrequency = NonNegativeFF<Frequency>(5_Hz);

    /// @brief Default damping ratio.
    static constexpr auto DefaultDampingRatio = NonNegativeFF<Real>(static_cast<Real>(0.7f));

    /// @brief Default max force.
    static constexpr auto DefaultMaxForce = NonNegativeFF<Force>(0_N);

    /// @brief Default constructor.
    constexpr TargetJointConf() noexcept = default;

    /// @brief Initializing constructor.
    constexpr TargetJointConf(BodyID b) noexcept: super{super{}.UseBodyB(b)}
    {
        // Intentionally empty.
    }

    /// @brief Use value for target.
    constexpr auto& UseTarget(const Length2& v) noexcept
    {
        target = v;
        return *this;
    }

    /// @brief Use value for the "anchor" (in coordinates local to "body B").
    /// @note Typically this would be the value of:
    ///   <code>bodyB != InvalidBodyID
    ///     ? GetLocalPoint(GetBody(world, bodyB), target)
    ///     : Length2()</code>.
    constexpr auto& UseAnchor(const Length2& v) noexcept
    {
        localAnchorB = v;
        return *this;
    }

    /// @brief Use value for max force.
    constexpr auto& UseMaxForce(NonNegative<Force> v) noexcept
    {
        maxForce = v;
        return *this;
    }

    /// @brief Use value for frequency.
    constexpr auto& UseFrequency(NonNegative<Frequency> v) noexcept
    {
        frequency = v;
        return *this;
    }

    /// @brief Use value for damping ratio.
    constexpr auto& UseDampingRatio(NonNegative<Real> v) noexcept
    {
        dampingRatio = v;
        return *this;
    }

    /// The initial world target point. This is assumed
    /// to coincide with the body anchor initially.
    Length2 target = Length2{};

    /// Anchor point.
    Length2 localAnchorB = Length2{};

    /// Max force.
    /// @details
    /// The maximum constraint force that can be exerted
    /// to move the candidate body. Usually you will express
    /// as some multiple of the weight (multiplier * mass * gravity).
    /// @note This may not be negative.
    NonNegative<Force> maxForce = DefaultMaxForce;

    /// Frequency.
    /// @details The has to do with the response speed.
    /// @note This value may not be negative.
    NonNegative<Frequency> frequency = DefaultFrequency;

    /// The damping ratio. 0 = no damping, 1 = critical damping.
    NonNegative<Real> dampingRatio = DefaultDampingRatio;

    InvMass gamma = InvMass{}; ///< Gamma.

    Momentum2 impulse = Momentum2{}; ///< Impulse.

    // Solver variables. These are only valid after InitVelocityConstraints called.
    Length2 rB = {}; ///< Relative B.
    Mass22 mass = {}; ///< 2-by-2 mass matrix in kilograms.
    LinearVelocity2 C = {}; ///< Velocity constant.
};

/// @brief Equality operator.
constexpr bool operator==(const TargetJointConf& lhs, const TargetJointConf& rhs) noexcept
{
    return // First check base...
        (lhs.bodyA == rhs.bodyA) && (lhs.bodyB == rhs.bodyB) &&
        (lhs.collideConnected == rhs.collideConnected)
        // Now check rest...
        && (lhs.target == rhs.target) && (lhs.localAnchorB == rhs.localAnchorB) &&
        (lhs.maxForce == rhs.maxForce) && (lhs.frequency == rhs.frequency) &&
        (lhs.dampingRatio == rhs.dampingRatio) && (lhs.gamma == rhs.gamma) &&
        (lhs.impulse == rhs.impulse) && (lhs.rB == rhs.rB) && (lhs.mass == rhs.mass) &&
        (lhs.C == rhs.C);
}

/// @brief Inequality operator.
constexpr bool operator!=(const TargetJointConf& lhs, const TargetJointConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the definition data for the given joint.
/// @throws std::bad_cast If the given joint's type is inappropriate for getting this value.
/// @relatedalso Joint
TargetJointConf GetTargetJointConf(const Joint& joint);

/// @brief Gets the local anchar A for the given configuration.
/// @relatedalso TargetJointConf
constexpr auto GetLocalAnchorA(const TargetJointConf&) noexcept
{
    return Length2{};
}

/// @brief Gets the current linear reaction of the given configuration.
/// @relatedalso TargetJointConf
constexpr Momentum2 GetLinearReaction(const TargetJointConf& object)
{
    return object.impulse;
}

/// @brief Gets the current angular reaction of the given configuration.
/// @relatedalso TargetJointConf
constexpr AngularMomentum GetAngularReaction(const TargetJointConf&)
{
    return AngularMomentum{};
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso TargetJointConf
constexpr bool ShiftOrigin(TargetJointConf& object, const Length2& newOrigin)
{
    object.target -= newOrigin;
    return true;
}

/// @brief Free function for getting the target value of the given configuration.
/// @relatedalso TargetJointConf
constexpr auto GetTarget(const TargetJointConf& object) noexcept
{
    return object.target;
}

/// @brief Gets the effective mass matrix for the given configuration and body information.
/// @relatedalso TargetJointConf
Mass22 GetEffectiveMassMatrix(const TargetJointConf& object, const BodyConstraint& body) noexcept;

/// @brief Initializes velocity constraint data based on the given solver data.
/// @note This MUST be called prior to calling <code>SolveVelocity</code>.
/// @param object Configuration object. <code>bodyB</code> must index a body within
///   the given <code>bodies</code> container or be the special body ID value of <code>InvalidBodyID</code>.
/// @param bodies Container of body constraints.
/// @param step Configuration for the step.
/// @param conf Constraint solver configuration.
/// @throws std::out_of_range If the given object's <code>bodyB</code> value is not
///  <code>InvalidBodyID</code> and does not index within range of the given <code>bodies</code> container.
/// @see SolveVelocity.
/// @relatedalso TargetJointConf
void InitVelocity(TargetJointConf& object, const Span<BodyConstraint>& bodies,
                  const StepConf& step, const ConstraintSolverConf& conf);

/// @brief Solves velocity constraint.
/// @pre <code>InitVelocity</code> has been called.
/// @param object Configuration object. <code>bodyB</code> must index a body within
///   the given <code>bodies</code> container or be the special body ID value of <code>InvalidBodyID</code>.
/// @param bodies Container of body constraints.
/// @param step Configuration for the step.
/// @throws std::out_of_range If the given object's <code>bodyB</code> value is not
///  <code>InvalidBodyID</code> and does not index within range of the given <code>bodies</code> container.
/// @see InitVelocity.
/// @return <code>true</code> if velocity is "solved", <code>false</code> otherwise.
/// @relatedalso TargetJointConf
bool SolveVelocity(TargetJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @note This is a no-op and always returns <code>true</code>.
/// @return <code>true</code>.
/// @relatedalso TargetJointConf
bool SolvePosition(const TargetJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Free function for setting the target value of the given configuration.
/// @relatedalso TargetJointConf
constexpr void SetTarget(TargetJointConf& object, const Length2& value) noexcept
{
    object.UseTarget(value);
}

/// @brief Free function for getting the maximum force value of the given configuration.
/// @relatedalso TargetJointConf
constexpr auto GetMaxForce(const TargetJointConf& object) noexcept
{
    return object.maxForce;
}

/// @brief Free function for setting the maximum force value of the given configuration.
/// @relatedalso TargetJointConf
constexpr auto SetMaxForce(TargetJointConf& object, NonNegative<Force> value) noexcept
{
    object.UseMaxForce(value);
}

/// @brief Free function for setting the frequency value of the given configuration.
/// @relatedalso TargetJointConf
constexpr void SetFrequency(TargetJointConf& object, NonNegative<Frequency> value) noexcept
{
    object.UseFrequency(value);
}

/// @brief Free function for setting the damping ratio value of the given configuration.
/// @relatedalso TargetJointConf
constexpr void SetDampingRatio(TargetJointConf& object, Real value) noexcept
{
    object.UseDampingRatio(value);
}

} // namespace d2
} // namespace playrho

/// @brief Type info specialization for <code>d2::TargetJointConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::TargetJointConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::TargetJointConf";
};

#endif // PLAYRHO_D2_MOUSEJOINTCONF_HPP
