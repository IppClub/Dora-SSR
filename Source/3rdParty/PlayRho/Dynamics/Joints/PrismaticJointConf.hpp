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

#ifndef PLAYRHO_DYNAMICS_JOINTS_PRISMATICJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_PRISMATICJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"

#include "PlayRho/Dynamics/Joints/LimitState.hpp"
#include "PlayRho/Common/Math.hpp"

namespace playrho {

struct ConstraintSolverConf;
struct StepConf;

namespace d2 {

class World;
class BodyConstraint;

/// @brief Prismatic joint definition.
/// @details This joint provides one degree of freedom: translation along an axis fixed in
///   body-A. Relative rotation is prevented. This requires defining a line of motion using
///   an axis and an anchor point. The definition uses local anchor points and a local axis
///   so that the initial configuration can violate the constraint slightly. The joint
///   translation is zero when the local anchor points coincide in world space. Using local
///   anchors and a local axis helps when saving and loading a game.
/// @note You can use a joint limit to restrict the range of motion and a joint motor
///   to drive the motion or to model joint friction.
/// @ingroup JointsGroup
/// @image html prismaticJoint.gif
/// @see https://en.wikipedia.org/wiki/Prismatic_joint
/// @see Joint, World::CreateJoint
struct PrismaticJointConf : public JointBuilder<PrismaticJointConf>
{
    /// @brief Super type.
    using super = JointBuilder<PrismaticJointConf>;

    /// @brief Default constructor.
    constexpr PrismaticJointConf() = default;

    /// @brief Copy constructor.
    PrismaticJointConf(const PrismaticJointConf& copy) = default;

    /// @brief Initializing constructor.
    /// @details Initializes the bodies, anchors, axis, and reference angle using the world
    ///   anchor and unit world axis.
    PrismaticJointConf(BodyID bA, BodyID bB,
                       Length2 laA = Length2{}, Length2 laB = Length2{},
                       UnitVec axisA = UnitVec::GetRight(), Angle angle = 0_deg) noexcept;

    /// @brief Uses the given enable limit state value.
    constexpr auto& UseEnableLimit(bool v) noexcept
    {
        enableLimit = v;
        return *this;
    }

    /// @brief Uses the given lower translation value.
    constexpr auto& UseLowerLength(Length v) noexcept
    {
        lowerTranslation = v;
        return *this;
    }

    /// @brief Uses the given upper translation value.
    constexpr auto& UseUpperLength(Length v) noexcept
    {
        upperTranslation = v;
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

    /// @brief Uses the given max motor force value.
    constexpr auto& UseMaxMotorForce(Force v) noexcept
    {
        maxMotorForce = v;
        return *this;
    }

    /// The local anchor point relative to body A's origin.
    Length2 localAnchorA = Length2{};

    /// The local anchor point relative to body B's origin.
    Length2 localAnchorB = Length2{};

    /// The local translation unit axis in body A.
    UnitVec localXAxisA = UnitVec::GetRight();

    UnitVec localYAxisA = GetRevPerpendicular(UnitVec::GetRight());

    /// The constrained angle between the bodies: body B's angle minus body A's angle.
    Angle referenceAngle = 0_deg;

    Vec3 impulse = Vec3{}; ///< Impulse.

    Momentum motorImpulse = 0; ///< Motor impulse.

    /// Enable/disable the joint limit.
    bool enableLimit = false;

    /// The lower translation limit.
    Length lowerTranslation = 0_m;

    /// The upper translation limit.
    Length upperTranslation = 0_m;

    /// Enable/disable the joint motor.
    bool enableMotor = false;

    /// The maximum motor force.
    Force maxMotorForce = 0_N;

    /// The desired angular motor speed.
    AngularVelocity motorSpeed = 0_rpm;

    LimitState limitState = LimitState::e_inactiveLimit; ///< Limit state.

    // Solver temp
    UnitVec axis = UnitVec::GetZero(); ///< Axis.
    UnitVec perp = UnitVec::GetZero(); ///< Perpendicular.
    Length s1 = 0_m; ///< Location S-1.
    Length s2 = 0_m; ///< Location S-2.
    Length a1 = 0_m; ///< Location A-1.
    Length a2 = 0_m; ///< Location A-2.
    Mat33 K = {}; ///< K matrix.
    Mass motorMass = 0_kg; ///< Motor mass.
};

/// @brief Gets the definition data for the given joint.
/// @relatedalso Joint
PrismaticJointConf GetPrismaticJointConf(const Joint& joint);

/// @brief Gets the configuration for the given parameters.
/// @relatedalso World
PrismaticJointConf GetPrismaticJointConf(const World& world,
                                         BodyID bA, BodyID bB,
                                         const Length2 anchor,
                                         const UnitVec axis);

/// @brief Gets the current linear velocity of the given configuration.
/// @relatedalso World
LinearVelocity GetLinearVelocity(const World& world, const PrismaticJointConf& joint) noexcept;

/// @brief Free function for getting the linear lower limit value of the given configuration.
/// @relatedalso PrismaticJointConf
constexpr auto GetLinearLowerLimit(const PrismaticJointConf& conf) noexcept
{
    return conf.lowerTranslation;
}

/// @brief Free function for getting the linear upper limit value of the given configuration.
/// @relatedalso PrismaticJointConf
constexpr auto GetLinearUpperLimit(const PrismaticJointConf& conf) noexcept
{
    return conf.upperTranslation;
}

/// @brief Free function for setting the linear limits of the given configuration.
/// @relatedalso PrismaticJointConf
constexpr void SetLinearLimits(PrismaticJointConf& conf, Length lower, Length upper) noexcept
{
    conf.UseLowerLength(lower).UseUpperLength(upper);
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso PrismaticJointConf
constexpr auto ShiftOrigin(PrismaticJointConf&, Length2) noexcept
{
    return false;
}

/// @brief Gets the current linear reaction of the given configuration.
/// @relatedalso PrismaticJointConf
Momentum2 GetLinearReaction(const PrismaticJointConf& conf);

/// @brief Gets the current angular reaction of the given configuration.
/// @relatedalso PrismaticJointConf
AngularMomentum GetAngularReaction(const PrismaticJointConf& conf);

/// @brief Initializes velocity constraint data based on the given solver data.
/// @note This MUST be called prior to calling <code>SolveVelocity</code>.
/// @see SolveVelocityConstraints.
/// @relatedalso PrismaticJointConf
void InitVelocity(PrismaticJointConf& object, std::vector<BodyConstraint>& bodies,
                  const StepConf& step,
                  const ConstraintSolverConf& conf);

/// @brief Solves velocity constraint.
/// @pre <code>InitVelocity</code> has been called.
/// @see InitVelocity.
/// @return <code>true</code> if velocity is "solved", <code>false</code> otherwise.
/// @relatedalso PrismaticJointConf
bool SolveVelocity(PrismaticJointConf& object, std::vector<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @return <code>true</code> if the position errors are within tolerance.
/// @relatedalso PrismaticJointConf
bool SolvePosition(const PrismaticJointConf& object, std::vector<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Free function for setting the maximum motor torque value of the given configuration.
/// @relatedalso PrismaticJointConf
constexpr void SetMaxMotorForce(PrismaticJointConf& object, Force value)
{
    object.UseMaxMotorForce(value);
}

} // namespace d2

/// @brief Type info specialization for <code>d2::PrismaticJointConf</code>.
template <>
struct TypeInfo<d2::PrismaticJointConf>
{
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::PrismaticJointConf";
};

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_PRISMATICJOINTCONF_HPP
