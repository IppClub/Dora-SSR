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

#ifndef PLAYRHO_D2_DISTANCEJOINTCONF_HPP
#define PLAYRHO_D2_DISTANCEJOINTCONF_HPP

/// @file
/// @brief Definition of the @c DistanceJointConf class and closely related code.

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

/// @example DistanceJoint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::DistanceJointConf</code>.

/// @brief Distance joint definition.
/// @details This requires defining an anchor point on both bodies and the non-zero
///   length of the distance joint. The definition uses local anchor points so that
///   the initial configuration can violate the constraint slightly. This helps when
///   saving and loading a game.
/// @warning Do not use a zero or short length.
/// @see Joint, World::CreateJoint
/// @ingroup JointsGroup
/// @image html distanceJoint.gif
struct DistanceJointConf : public JointBuilder<DistanceJointConf> {
    /// @brief Super type.
    using super = JointBuilder<DistanceJointConf>;

    /// @brief Default frequency.
    static constexpr auto DefaultFrequency = NonNegativeFF<Frequency>(0_Hz);

    /// @brief Default constructor.
    constexpr DistanceJointConf() noexcept = default;

    /// @brief Initializing constructor.
    /// @details Initialize the bodies, anchors, and length using the world anchors.
    DistanceJointConf(BodyID bA, BodyID bB, // force line-break
                      const Length2& laA = Length2{}, // force line-break
                      const Length2& laB = Length2{}, // force line-break
                      Length l = 1_m) noexcept;

    /// @brief Uses the given length.
    /// @note Manipulating the length when the frequency is zero can lead to non-physical behavior.
    constexpr auto& UseLength(Length v) noexcept
    {
        length = v;
        return *this;
    }

    /// @brief Uses the given frequency.
    constexpr auto& UseFrequency(NonNegative<Frequency> v) noexcept
    {
        frequency = v;
        return *this;
    }

    /// @brief Uses the given damping ratio.
    constexpr auto& UseDampingRatio(Real v) noexcept
    {
        dampingRatio = v;
        return *this;
    }

    /// @brief Local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{};

    /// @brief Local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{};

    /// @brief Natural length between the anchor points.
    Length length = 1_m;

    /// @brief Mass-spring-damper frequency.
    /// @note 0 disables softness.
    NonNegative<Frequency> frequency = DefaultFrequency;

    /// @brief Damping ratio.
    /// @note 0 = no damping, 1 = critical damping.
    Real dampingRatio = 0;

    // Solver shared.

    Momentum impulse = 0_Ns; ///< Impulse.

    // Solver temporary variables

    UnitVec u; ///< "u" directional.
    Length2 rA = {}; ///< Relative A position.
    Length2 rB = {}; ///< Relative B position.
    InvMass invGamma = {}; ///< Inverse gamma.
    LinearVelocity bias = {}; ///< Bias.
    Mass mass = 0_kg; ///< Mass.
};

/// @brief Equality operator.
constexpr bool operator==(const DistanceJointConf& lhs, const DistanceJointConf& rhs) noexcept
{
    return // First check base...
        (lhs.bodyA == rhs.bodyA) && (lhs.bodyB == rhs.bodyB) &&
        (lhs.collideConnected == rhs.collideConnected)
        // Now check rest...
        && (lhs.localAnchorA == rhs.localAnchorA) // line break
        && (lhs.localAnchorB == rhs.localAnchorB) // line break
        && (lhs.length == rhs.length) // line break
        && (lhs.frequency == rhs.frequency) // line break
        && (lhs.dampingRatio == rhs.dampingRatio) // line break
        && (lhs.impulse == rhs.impulse) // line break
        && (lhs.u == rhs.u) // line break
        && (lhs.rA == rhs.rA) // line break
        && (lhs.rB == rhs.rB) // line break
        && (lhs.invGamma == rhs.invGamma) // line break
        && (lhs.bias == rhs.bias) // line break
        && (lhs.mass == rhs.mass);
}

/// @brief Inequality operator.
constexpr bool operator!=(const DistanceJointConf& lhs, const DistanceJointConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the definition data for the given joint.
/// @param joint The joint to get the configuration for.
/// @throws std::bad_cast If the given joint's type is inappropriate for getting this value.
/// @relatedalso Joint
DistanceJointConf GetDistanceJointConf(const Joint& joint);

/// @brief Gets the configuration for a joint with the given parameters.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
DistanceJointConf GetDistanceJointConf(const World& world, // newline!
                                       BodyID bodyA, BodyID bodyB, // newline!
                                       const Length2& anchorA = Length2{}, // newline!
                                       const Length2& anchorB = Length2{});

/// @brief Gets the current linear reaction for the given configuration.
/// @relatedalso DistanceJointConf
constexpr Momentum2 GetLinearReaction(const DistanceJointConf& object) noexcept
{
    return object.impulse * object.u;
}

/// @brief Gets the current angular reaction for the given configuration.
/// @relatedalso DistanceJointConf
constexpr AngularMomentum GetAngularReaction(const DistanceJointConf&) noexcept
{
    return AngularMomentum{};
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso DistanceJointConf
constexpr bool ShiftOrigin(DistanceJointConf&, Length2) noexcept
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
/// @relatedalso DistanceJointConf
void InitVelocity(DistanceJointConf& object, const Span<BodyConstraint>& bodies,
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
/// @relatedalso DistanceJointConf
bool SolveVelocity(DistanceJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @param object Configuration object. <code>bodyA</code> and <code>bodyB</code> must index bodies within
///   the given <code>bodies</code> container or be the special body ID value of <code>InvalidBodyID</code>.
/// @param bodies Container of body constraints.
/// @param conf Constraint solver configuration.
/// @throws std::out_of_range If the given object's <code>bodyA</code> or <code>bodyB</code> values are not
///  <code>InvalidBodyID</code> and are not  indices within range of the given <code>bodies</code> container.
/// @return <code>true</code> if the position errors are within tolerance.
/// @relatedalso DistanceJointConf
bool SolvePosition(const DistanceJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Free function for setting the frequency value of the given configuration.
/// @relatedalso DistanceJointConf
constexpr void SetFrequency(DistanceJointConf& object, NonNegative<Frequency> value) noexcept
{
    object.UseFrequency(value);
}

/// @brief Free function for setting the damping ratio value of the given configuration.
/// @relatedalso DistanceJointConf
constexpr void SetDampingRatio(DistanceJointConf& object, Real value) noexcept
{
    object.UseDampingRatio(value);
}

/// @brief Free function for getting the length value of the given configuration.
/// @relatedalso DistanceJointConf
constexpr auto GetLength(const DistanceJointConf& object) noexcept
{
    return object.length;
}

/// @brief Free function for setting the length value of the given configuration.
/// @relatedalso DistanceJointConf
constexpr auto SetLength(DistanceJointConf& object, Length value) noexcept
{
    object.UseLength(value);
}

} // namespace d2
} // namespace playrho

/// @brief Type info specialization for <code>playrho::d2::DistanceJointConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::DistanceJointConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::DistanceJointConf";
};

#endif // PLAYRHO_D2_DISTANCEJOINTCONF_HPP
