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

#ifndef PLAYRHO_D2_FRICTIONJOINTCONF_HPP
#define PLAYRHO_D2_FRICTIONJOINTCONF_HPP

/// @file
/// @brief Definition of the @c FrictionJointConf class and closely related code.

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

/// @example FrictionJoint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::FrictionJointConf</code>.

/// @brief Friction joint definition.
/// @details This is used for top-down friction. It provides 2-D translational friction
///   and angular friction.
/// @see Joint, World::CreateJoint
/// @ingroup JointsGroup
struct FrictionJointConf : public JointBuilder<FrictionJointConf> {
    /// @brief Super type.
    using super = JointBuilder<FrictionJointConf>;

    /// @brief Default max force.
    static constexpr auto DefaultMaxForce = NonNegativeFF<Force>(0_N);

    /// @brief Default max torque.
    static constexpr auto DefaultMaxTorque = NonNegativeFF<Torque>(0_Nm);

    /// @brief Default constructor.
    constexpr FrictionJointConf() noexcept = default;

    /// @brief Initializing constructor.
    /// @details Initialize the bodies and local anchors.
    /// @post <code>bodyA</code> will hold the value of <code>bA</code>.
    /// @post <code>bodyB</code> will hold the value of <code>bB</code>.
    /// @post <code>localAnchorA</code> will hold the value of <code>laA</code>.
    /// @post <code>localAnchorB</code> will hold the value of <code>laB</code>.
    /// @post All other member variables will be zero initialized.
    FrictionJointConf(BodyID bA, BodyID bB, // force line-break
                      const Length2& laA = Length2{}, // force line-break
                      const Length2& laB = Length2{}) noexcept;

    /// @brief Uses the given maximum force value.
    constexpr auto& UseMaxForce(NonNegative<Force> v) noexcept
    {
        maxForce = v;
        return *this;
    }

    /// @brief Uses the given maximum torque value.
    constexpr auto& UseMaxTorque(NonNegative<Torque> v) noexcept
    {
        maxTorque = v;
        return *this;
    }

    /// @brief Local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{};

    /// @brief Local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{};

    /// @brief Maximum friction force.
    NonNegative<Force> maxForce = DefaultMaxForce;

    /// @brief Maximum friction torque.
    NonNegative<Torque> maxTorque = DefaultMaxTorque;

    // Solver shared data - data saved & updated over multiple InitVelocityConstraints calls.
    Momentum2 linearImpulse = Momentum2{}; ///< Linear impulse.
    AngularMomentum angularImpulse = AngularMomentum{}; ///< Angular impulse.

    // Solver temp
    Length2 rA = {}; ///< Relative A.
    Length2 rB = {}; ///< Relative B.
    Mass22 linearMass = {}; ///< 2-by-2 linear mass matrix in kilograms.
    RotInertia angularMass = {}; ///< Angular mass.
};

/// @brief Equality operator.
constexpr bool operator==(const FrictionJointConf& lhs, const FrictionJointConf& rhs) noexcept
{
    return // First check base...
        (lhs.bodyA == rhs.bodyA) && (lhs.bodyB == rhs.bodyB) &&
        (lhs.collideConnected == rhs.collideConnected)
        // Now check rest...
        && (lhs.localAnchorA == rhs.localAnchorA) // line break
        && (lhs.localAnchorB == rhs.localAnchorB) // line break
        && (lhs.maxForce == rhs.maxForce) // line break
        && (lhs.maxTorque == rhs.maxTorque) // line break
        && (lhs.linearImpulse == rhs.linearImpulse) // line break
        && (lhs.angularImpulse == rhs.angularImpulse) // line break
        && (lhs.rA == rhs.rA) // line break
        && (lhs.rB == rhs.rB) // line break
        && (lhs.linearMass == rhs.linearMass) // line break
        && (lhs.angularMass == rhs.angularMass);
}

/// @brief Inequality operator.
constexpr bool operator!=(const FrictionJointConf& lhs, const FrictionJointConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the definition data for the given joint.
/// @throws std::bad_cast If the given joint's type is inappropriate for getting this value.
/// @relatedalso Joint
FrictionJointConf GetFrictionJointConf(const Joint& joint);

/// @brief Gets the confguration for the given parameters.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
FrictionJointConf GetFrictionJointConf(const World& world, BodyID bodyA, BodyID bodyB,
                                       const Length2& anchor);

/// @brief Gets the current linear reaction for the given configuration.
/// @relatedalso FrictionJointConf
constexpr Momentum2 GetLinearReaction(const FrictionJointConf& object) noexcept
{
    return object.linearImpulse;
}

/// @brief Gets the current angular reaction for the given configuration.
/// @relatedalso FrictionJointConf
constexpr AngularMomentum GetAngularReaction(const FrictionJointConf& object) noexcept
{
    return object.angularImpulse;
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso FrictionJointConf
constexpr bool ShiftOrigin(FrictionJointConf&, Length2) noexcept
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
/// @relatedalso FrictionJointConf
void InitVelocity(FrictionJointConf& object, const Span<BodyConstraint>& bodies,
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
/// @relatedalso FrictionJointConf
bool SolveVelocity(FrictionJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @note This is a no-op and always returns <code>true</code>.
/// @return <code>true</code>.
/// @relatedalso FrictionJointConf
bool SolvePosition(const FrictionJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Free function for getting the max force value of the given configuration.
/// @relatedalso FrictionJointConf
constexpr auto GetMaxForce(const FrictionJointConf& object) noexcept
{
    return object.maxForce;
}

/// @brief Free function for setting the max force value of the given configuration.
/// @relatedalso FrictionJointConf
constexpr void SetMaxForce(FrictionJointConf& object, NonNegative<Force> value) noexcept
{
    object.UseMaxForce(value);
}

/// @brief Free function for getting the max torque value of the given configuration.
/// @relatedalso FrictionJointConf
constexpr auto GetMaxTorque(const FrictionJointConf& object) noexcept
{
    return object.maxTorque;
}

/// @brief Free function for setting the max force value of the given configuration.
/// @relatedalso FrictionJointConf
constexpr auto SetMaxTorque(FrictionJointConf& object, NonNegative<Torque> value) noexcept
{
    object.UseMaxTorque(value);
}

} // namespace d2
} // namespace playrho

/// @brief Type info specialization for <code>playrho::d2::FrictionJointConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::FrictionJointConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::FrictionJointConf";
};

#endif // PLAYRHO_D2_FRICTIONJOINTCONF_HPP
