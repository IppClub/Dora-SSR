/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_JOINTS_PULLEYJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_PULLEYJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"

#include "PlayRho/Common/Math.hpp"

namespace playrho {

struct ConstraintSolverConf;
struct StepConf;

namespace d2 {

class Joint;
class World;
class BodyConstraint;

/// @example PulleyJoint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::PulleyJointConf</code>.

/// @brief Pulley joint definition.
/// @details The pulley joint is connected to two bodies and two fixed ground points.
///   The pulley supports a ratio such that: <code>length1 + ratio * length2 <= constant</code>.
/// @note The force transmitted is scaled by the ratio.
/// @warning the pulley joint can get a bit squirrelly by itself. They often
///   work better when combined with prismatic joints. You should also cover the
///   the anchor points with static shapes to prevent one side from going to
///   zero length.
/// @ingroup JointsGroup
/// @image html pulleyJoint.gif
/// @see Joint, World::CreateJoint
struct PulleyJointConf : public JointBuilder<PulleyJointConf> {
    /// @brief Super type.
    using super = JointBuilder<PulleyJointConf>;

    /// @brief Default ground anchor A.
    static constexpr Length2 DefaultGroundAnchorA = Length2{-1_m, +1_m};

    /// @brief Default ground anchor B.
    static constexpr Length2 DefaultGroundAnchorB = Length2{+1_m, +1_m};

    /// @brief Default local anchor A.
    static constexpr Length2 DefaultLocalAnchorA = Length2{-1_m, 0_m};

    /// @brief Default local anchor B.
    static constexpr Length2 DefaultLocalAnchorB = Length2{+1_m, 0_m};

    /// @brief Default constructor.
    PulleyJointConf() noexcept : super{super{}.UseCollideConnected(true)} {}

    /// Initialize the bodies, anchors, lengths, max lengths, and ratio using the world anchors.
    PulleyJointConf(BodyID bodyA, BodyID bodyB, Length2 groundAnchorA = DefaultGroundAnchorA,
                    Length2 groundAnchorB = DefaultGroundAnchorB,
                    Length2 anchorA = DefaultLocalAnchorA, Length2 anchorB = DefaultLocalAnchorB,
                    Length lA = 0_m, Length lB = 0_m);

    /// @brief Uses the given ratio value.
    constexpr auto& UseRatio(Real v) noexcept
    {
        ratio = v;
        return *this;
    }

    /// The first ground anchor in world coordinates. This point never moves.
    Length2 groundAnchorA = DefaultGroundAnchorA;

    /// The second ground anchor in world coordinates. This point never moves.
    Length2 groundAnchorB = DefaultGroundAnchorB;

    /// The local anchor point relative to body A's origin.
    Length2 localAnchorA = DefaultLocalAnchorA;

    /// The local anchor point relative to body B's origin.
    Length2 localAnchorB = DefaultLocalAnchorB;

    /// The a reference length for the segment attached to body-A.
    Length lengthA = 0_m;

    /// The a reference length for the segment attached to body-B.
    Length lengthB = 0_m;

    /// The pulley ratio, used to simulate a block-and-tackle.
    Real ratio = 1;

    // Solver shared (between calls to InitVelocityConstraints).
    Momentum impulse = 0_Ns; ///< Impulse.

    // Solver temp (recalculated every call to InitVelocityConstraints).
    UnitVec uA; ///< Unit vector A.
    UnitVec uB; ///< Unit vector B.
    Length2 rA{}; ///< Relative A.
    Length2 rB{}; ///< Relative B.
    Mass mass = 0_kg; ///< Mass.
};

/// @brief Equality operator.
constexpr bool operator==(const PulleyJointConf& lhs, const PulleyJointConf& rhs) noexcept
{
    return // First check base...
        (lhs.bodyA == rhs.bodyA) && (lhs.bodyB == rhs.bodyB) &&
        (lhs.collideConnected == rhs.collideConnected)
        // Now check rest...
        && (lhs.groundAnchorA == rhs.groundAnchorA) // line break
        && (lhs.groundAnchorB == rhs.groundAnchorB) // line break
        && (lhs.localAnchorA == rhs.localAnchorA) // line break
        && (lhs.localAnchorB == rhs.localAnchorB) // line break
        && (lhs.lengthA == rhs.lengthA) // line break
        && (lhs.lengthB == rhs.lengthB) // line break
        && (lhs.ratio == rhs.ratio) // line break
        && (lhs.impulse == rhs.impulse) // line break
        && (lhs.uA == rhs.uA) // line break
        && (lhs.uB == rhs.uB) // line break
        && (lhs.rA == rhs.rA) // line break
        && (lhs.rB == rhs.rB) // line break
        && (lhs.mass == rhs.mass);
}

/// @brief Inequality operator.
constexpr bool operator!=(const PulleyJointConf& lhs, const PulleyJointConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the definition data for the given joint.
/// @relatedalso Joint
PulleyJointConf GetPulleyJointConf(const Joint& joint);

/// @brief Gets the configuration for the given parameters.
/// @relatedalso World
PulleyJointConf GetPulleyJointConf(const World& world, BodyID bA, BodyID bB, Length2 groundA,
                                   Length2 groundB, Length2 anchorA, Length2 anchorB);

/// @brief Gets the current linear reaction of the given configuration.
/// @relatedalso PulleyJointConf
constexpr Momentum2 GetLinearReaction(const PulleyJointConf& object) noexcept
{
    return object.impulse * object.uB;
}

/// @brief Gets the current angular reaction of the given configuration.
/// @relatedalso PulleyJointConf
constexpr AngularMomentum GetAngularReaction(const PulleyJointConf&) noexcept
{
    return AngularMomentum{0};
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso PulleyJointConf
bool ShiftOrigin(PulleyJointConf& object, Length2 newOrigin) noexcept;

/// @brief Initializes velocity constraint data based on the given solver data.
/// @note This MUST be called prior to calling <code>SolveVelocity</code>.
/// @see SolveVelocity.
/// @relatedalso PulleyJointConf
void InitVelocity(PulleyJointConf& object, std::vector<BodyConstraint>& bodies,
                  const StepConf& step, const ConstraintSolverConf& conf);

/// @brief Solves velocity constraint.
/// @pre <code>InitVelocity</code> has been called.
/// @see InitVelocity.
/// @return <code>true</code> if velocity is "solved", <code>false</code> otherwise.
/// @relatedalso PulleyJointConf
bool SolveVelocity(PulleyJointConf& object, std::vector<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @return <code>true</code> if the position errors are within tolerance.
/// @relatedalso PulleyJointConf
bool SolvePosition(const PulleyJointConf& object, std::vector<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Free function for getting the length A value of the given configuration.
/// @relatedalso PulleyJointConf
constexpr auto GetLengthA(const PulleyJointConf& object) noexcept
{
    return object.lengthA;
}

/// @brief Free function for getting the length B value of the given configuration.
/// @relatedalso PulleyJointConf
constexpr auto GetLengthB(const PulleyJointConf& object) noexcept
{
    return object.lengthB;
}

/// @brief Free function for setting the ratio value of the given configuration.
/// @relatedalso PulleyJointConf
constexpr auto SetRatio(PulleyJointConf& object, Real value) noexcept
{
    object.UseRatio(value);
}

} // namespace d2

/// @brief Type info specialization for <code>d2::PulleyJointConf</code>.
template <>
struct TypeInfo<d2::PulleyJointConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::PulleyJointConf";
};

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_PULLEYJOINTCONF_HPP
