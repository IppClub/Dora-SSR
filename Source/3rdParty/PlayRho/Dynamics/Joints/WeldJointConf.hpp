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

#ifndef PLAYRHO_DYNAMICS_JOINTS_WELDJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_WELDJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"

#include "PlayRho/Common/Math.hpp"

namespace playrho {

struct ConstraintSolverConf;
struct StepConf;

namespace d2 {

class World;
class BodyConstraint;

/// @brief Weld joint definition.
/// @note A weld joint essentially glues two bodies together. A weld joint may
///   distort somewhat because the island constraint solver is approximate.
/// @note You need to specify local anchor points where they are attached and the
///   relative body angle.
/// @note The position of the anchor points is important for computing the reaction torque.
/// @ingroup JointsGroup
/// @see Joint, World::CreateJoint
struct WeldJointConf : public JointBuilder<WeldJointConf>
{
    /// @brief Super type.
    using super = JointBuilder<WeldJointConf>;

    /// @brief Default constructor.
    constexpr WeldJointConf() = default;

    /// @brief Initializing constructor.
    /// @details Initializes the bodies, anchors, and reference angle using a world
    ///   anchor point.
    /// @param bodyA Body A.
    /// @param laA Local anchor A location in world coordinates.
    /// @param bodyB Body B.
    /// @param laB Local anchor B location in world coordinates.
    /// @param ra Reference angle.
    WeldJointConf(BodyID bodyA, BodyID bodyB,
                  Length2 laA = Length2{}, Length2 laB = Length2{}, Angle ra = 0_deg) noexcept;

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
    NonNegative<Frequency> frequency{}; // 0_Hz

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

/// @brief Gets the definition data for the given joint.
/// @relatedalso Joint
WeldJointConf GetWeldJointConf(const Joint& joint);

/// @brief Gets the configuration for the given parameters.
/// @relatedalso World
WeldJointConf GetWeldJointConf(const World& world, BodyID bodyA, BodyID bodyB,
                               const Length2 anchor = Length2{});

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
constexpr auto ShiftOrigin(WeldJointConf&, Length2) noexcept
{
    return false;
}

/// @brief Initializes velocity constraint data based on the given solver data.
/// @note This MUST be called prior to calling <code>SolveVelocity</code>.
/// @see SolveVelocity.
/// @relatedalso WeldJointConf
void InitVelocity(WeldJointConf& object, std::vector<BodyConstraint>& bodies,
                  const StepConf& step,
                  const ConstraintSolverConf& conf);

/// @brief Solves velocity constraint.
/// @pre <code>InitVelocity</code> has been called.
/// @see InitVelocity.
/// @return <code>true</code> if velocity is "solved", <code>false</code> otherwise.
/// @relatedalso WeldJointConf
bool SolveVelocity(WeldJointConf& object, std::vector<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @return <code>true</code> if the position errors are within tolerance.
/// @relatedalso WeldJointConf
bool SolvePosition(const WeldJointConf& object, std::vector<BodyConstraint>& bodies,
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

/// @brief Type info specialization for <code>d2::WeldJointConf</code>.
template <>
struct TypeInfo<d2::WeldJointConf>
{
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::WeldJointConf";
};

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_WELDJOINTCONF_HPP
