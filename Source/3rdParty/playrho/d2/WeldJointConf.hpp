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

#ifndef PLAYRHO_D2_WELDJOINTCONF_HPP
#define PLAYRHO_D2_WELDJOINTCONF_HPP

/// @file
/// @brief Definition of the @c WeldJointConf class and closely related code.

// IWYU pragma: begin_exports

#include "playrho/NonNegative.hpp"
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

/// @example WeldJoint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::WeldJointConf</code>.

/// @brief Weld joint definition.
/// @note A weld joint essentially glues two bodies together. A weld joint may
///   distort somewhat because the island constraint solver is approximate.
/// @note You need to specify local anchor points where they are attached and the
///   relative body angle.
/// @note The position of the anchor points is important for computing the reaction torque.
/// @ingroup JointsGroup
/// @see Joint, World::CreateJoint
struct WeldJointConf : public JointBuilder<WeldJointConf> {
    /// @brief Super type.
    using super = JointBuilder<WeldJointConf>;

    /// @brief Default frequency.
    static constexpr auto DefaultFrequency = NonNegativeFF<Frequency>(0_Hz);

    /// @brief Default constructor.
    constexpr WeldJointConf() noexcept = default;

    /// @brief Initializing constructor.
    /// @details Initializes the bodies, anchors, and reference angle using a world
    ///   anchor point.
    /// @param bA Identifier of body A.
    /// @param bB Identifier of body B.
    /// @param laA Local anchor A location in world coordinates.
    /// @param laB Local anchor B location in world coordinates.
    /// @param ra Reference angle.
    /// @post <code>bodyA</code> will have the value of <code>bA</code>.
    /// @post <code>bodyB</code> will have the value of <code>bB</code>.
    /// @post <code>localAnchorA</code> will have the value of <code>laA</code>.
    /// @post <code>localAnchorB</code> will have the value of <code>laB</code>.
    /// @post <code>referenceAngle</code> will have the value of <code>ra</code>.
    WeldJointConf(BodyID bA, BodyID bB, // force line-break
                  const Length2& laA = Length2{}, const Length2& laB = Length2{},
                  Angle ra = 0_deg) noexcept;

    /// @brief Uses the given frequency value.
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

    /// The local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{};

    /// The local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{};

    /// The body-B angle minus body-A angle in the reference state (radians).
    Angle referenceAngle = 0_deg;

    /// @brief Mass-spring-damper frequency.
    /// @note Rotation only.
    /// @note Disable softness with a value of 0.
    NonNegative<Frequency> frequency = DefaultFrequency;

    /// @brief Damping ratio.
    /// @note 0 = no damping, 1 = critical damping.
    Real dampingRatio = 0;

    // Solver shared
    Vec3 impulse = Vec3{}; ///< Impulse.

    // Solver temp
    InvRotInertia gamma = {}; ///< Gamma.
    AngularVelocity bias = {}; ///< Bias.
    Length2 rA = {}; ///< Relative A.
    Length2 rB = {}; ///< Relative B.
    Mat33 mass = {}; ///< Mass.
};

/// @brief Equality operator.
constexpr bool operator==(const WeldJointConf& lhs, const WeldJointConf& rhs) noexcept
{
    return // First check base...
        (lhs.bodyA == rhs.bodyA) && (lhs.bodyB == rhs.bodyB) &&
        (lhs.collideConnected == rhs.collideConnected)
        // Now check rest...
        && (lhs.localAnchorA == rhs.localAnchorA) && (lhs.localAnchorB == rhs.localAnchorB) &&
        (lhs.referenceAngle == rhs.referenceAngle) && (lhs.frequency == rhs.frequency) &&
        (lhs.dampingRatio == rhs.dampingRatio) && (lhs.impulse == rhs.impulse) &&
        (lhs.gamma == rhs.gamma) && (lhs.bias == rhs.bias) && (lhs.rA == rhs.rA) &&
        (lhs.rB == rhs.rB) && (lhs.mass == rhs.mass);
}

/// @brief Inequality operator.
constexpr bool operator!=(const WeldJointConf& lhs, const WeldJointConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the definition data for the given joint.
/// @throws std::bad_cast If the given joint's type is inappropriate for getting this value.
/// @relatedalso Joint
WeldJointConf GetWeldJointConf(const Joint& joint);

/// @brief Gets the configuration for the given parameters.
/// @throws std::out_of_range If given an invalid body identifier.
/// @relatedalso World
WeldJointConf GetWeldJointConf(const World& world, BodyID bodyA, BodyID bodyB,
                               const Length2& anchor = Length2{});

/// @brief Gets the current linear reaction of the given configuration.
/// @relatedalso WeldJointConf
constexpr Momentum2 GetLinearReaction(const WeldJointConf& object) noexcept
{
    return Momentum2{GetX(object.impulse) * NewtonSecond, GetY(object.impulse) * NewtonSecond};
}

/// @brief Gets the current angular reaction of the given configuration.
/// @relatedalso WeldJointConf
constexpr AngularMomentum GetAngularReaction(const WeldJointConf& object) noexcept
{
    // AngularMomentum is L^2 M T^-1 QP^-1
    return AngularMomentum{GetZ(object.impulse) * SquareMeter * Kilogram / (Second * Radian)};
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso WeldJointConf
constexpr auto ShiftOrigin(WeldJointConf&, const Length2&) noexcept
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
/// @relatedalso WeldJointConf
void InitVelocity(WeldJointConf& object, const Span<BodyConstraint>& bodies, const StepConf& step,
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
/// @relatedalso WeldJointConf
bool SolveVelocity(WeldJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @param object Configuration object. <code>bodyA</code> and <code>bodyB</code> must index bodies within
///   the given <code>bodies</code> container or be the special body ID value of <code>InvalidBodyID</code>.
/// @param bodies Container of body constraints.
/// @param conf Constraint solver configuration.
/// @throws std::out_of_range If the given object's <code>bodyA</code> or <code>bodyB</code> values are not
///  <code>InvalidBodyID</code> and are not  indices within range of the given <code>bodies</code> container.
/// @return <code>true</code> if the position errors are within tolerance.
/// @relatedalso WeldJointConf
bool SolvePosition(const WeldJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Free function for setting the frequency of the given configuration.
/// @relatedalso WeldJointConf
constexpr void SetFrequency(WeldJointConf& object, NonNegative<Frequency> value) noexcept
{
    object.UseFrequency(value);
}

/// @brief Free function for setting the damping ratio of the given configuration.
/// @relatedalso WeldJointConf
constexpr void SetDampingRatio(WeldJointConf& object, Real value) noexcept
{
    object.UseDampingRatio(value);
}

} // namespace d2
} // namespace playrho

/// @brief Type info specialization for <code>d2::WeldJointConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::WeldJointConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::WeldJointConf";
};

#endif // PLAYRHO_D2_WELDJOINTCONF_HPP
