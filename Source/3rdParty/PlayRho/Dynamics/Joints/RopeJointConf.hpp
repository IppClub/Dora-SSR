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

#ifndef PLAYRHO_DYNAMICS_JOINTS_ROPEJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_ROPEJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Dynamics/Joints/LimitState.hpp"

namespace playrho {

struct ConstraintSolverConf;
struct StepConf;

namespace d2 {

class Joint;
class World;
class BodyConstraint;

/// @example RopeJoint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::RopeJointConf</code>.

/// @brief Rope joint definition.
/// @details A rope joint enforces a maximum distance between two points on two bodies.
///   It has no other effect. This requires two body anchor points and a maximum lengths.
/// @note By default the connected objects will not collide.
/// @warning If you attempt to change the maximum length during the simulation
///   you will get some non-physical behavior. A model that would allow you to
///   dynamically modify the length would have some sponginess, so it was decided
///   not to implement it that way. See <code>DistanceJoint</code> if you want to dynamically
///   control length.
/// @ingroup JointsGroup
/// @see collideConnected in JointConf.
/// @see Joint, World::CreateJoint
struct RopeJointConf : public JointBuilder<RopeJointConf> {
    /// @brief Super type.
    using super = JointBuilder<RopeJointConf>;

    /// @brief Default constructor.
    constexpr RopeJointConf() = default;

    /// @brief Initializing constructor.
    constexpr RopeJointConf(BodyID bodyA, BodyID bodyB) noexcept
        : super{super{}.UseBodyA(bodyA).UseBodyB(bodyB)}
    {
        // Intentionally empty.
    }

    /// @brief Uses the given max length value.
    constexpr auto& UseMaxLength(Length v) noexcept
    {
        maxLength = v;
        return *this;
    }

    /// The local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{-1_m, 0_m};

    /// The local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{+1_m, 0_m};

    /// The maximum length of the rope.
    Length maxLength = 0_m;

    Length length = 0; ///< Length.
    Momentum impulse = 0_Ns; ///< Impulse.

    // Solver temp
    UnitVec u; ///< U direction.
    Length2 rA = {}; ///< Relative A.
    Length2 rB = {}; ///< Relative B.
    Mass mass = 0_kg; ///< Mass.
    LimitState limitState = LimitState::e_inactiveLimit; ///< Limit state.
};

/// @brief Equality operator.
constexpr bool operator==(const RopeJointConf& lhs, const RopeJointConf& rhs) noexcept
{
    return // First check base...
        (lhs.bodyA == rhs.bodyA) && (lhs.bodyB == rhs.bodyB) &&
        (lhs.collideConnected == rhs.collideConnected)
        // Now check rest...
        && (lhs.localAnchorA == rhs.localAnchorA) && (lhs.localAnchorB == rhs.localAnchorB) &&
        (lhs.maxLength == rhs.maxLength) && (lhs.impulse == rhs.impulse) && (lhs.u == rhs.u) &&
        (lhs.rA == rhs.rA) && (lhs.rB == rhs.rB) && (lhs.mass == rhs.mass) &&
        (lhs.limitState == rhs.limitState);
}

/// @brief Inequality operator.
constexpr bool operator!=(const RopeJointConf& lhs, const RopeJointConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the definition data for the given joint.
/// @relatedalso Joint
RopeJointConf GetRopeJointConf(const Joint& joint) noexcept;

/// @brief Gets the current linear reaction of the given configuration.
/// @relatedalso RopeJointConf
constexpr Momentum2 GetLinearReaction(const RopeJointConf& object) noexcept
{
    return object.impulse * object.u;
}

/// @brief Gets the current angular reaction of the given configuration.
/// @relatedalso RopeJointConf
constexpr AngularMomentum GetAngularReaction(const RopeJointConf&) noexcept
{
    return AngularMomentum{0};
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso RopeJointConf
constexpr auto ShiftOrigin(RopeJointConf&, Length2) noexcept
{
    return false;
}

/// @brief Initializes velocity constraint data based on the given solver data.
/// @note This MUST be called prior to calling <code>SolveVelocity</code>.
/// @see SolveVelocity.
/// @relatedalso RopeJointConf
void InitVelocity(RopeJointConf& object, std::vector<BodyConstraint>& bodies, const StepConf& step,
                  const ConstraintSolverConf& conf);

/// @brief Solves velocity constraint.
/// @pre <code>InitVelocity</code> has been called.
/// @see InitVelocity.
/// @return <code>true</code> if velocity is "solved", <code>false</code> otherwise.
/// @relatedalso RopeJointConf
bool SolveVelocity(RopeJointConf& object, std::vector<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @return <code>true</code> if the position errors are within tolerance.
/// @relatedalso RopeJointConf
bool SolvePosition(const RopeJointConf& object, std::vector<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Free function for getting the maximum length value of the given configuration.
/// @relatedalso RopeJointConf
constexpr auto GetMaxLength(const RopeJointConf& object) noexcept
{
    return object.maxLength;
}

/// @brief Free function for setting the maximum length value of the given configuration.
/// @relatedalso RopeJointConf
constexpr auto SetMaxLength(RopeJointConf& object, Length value) noexcept
{
    object.UseMaxLength(value);
}

} // namespace d2

/// @brief Type info specialization for <code>d2::RopeJointConf</code>.
template <>
struct TypeInfo<d2::RopeJointConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::RopeJointConf";
};

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_ROPEJOINTCONF_HPP
