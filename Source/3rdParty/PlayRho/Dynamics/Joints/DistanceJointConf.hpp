/*
 * Original work Copyright (c) 2006-2007 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_DYNAMICS_JOINTS_DISTANCEJOINTCONF_HPP
#define PLAYRHO_DYNAMICS_JOINTS_DISTANCEJOINTCONF_HPP

#include "PlayRho/Dynamics/Joints/JointConf.hpp"
#include "PlayRho/Common/NonNegative.hpp"
#include "PlayRho/Common/Math.hpp"

namespace playrho {

struct ConstraintSolverConf;
struct StepConf;

namespace d2 {

class World;
class BodyConstraint;

/// @brief Distance joint definition.
/// @details This requires defining an anchor point on both bodies and the non-zero
///   length of the distance joint. The definition uses local anchor points so that
///   the initial configuration can violate the constraint slightly. This helps when
///   saving and loading a game.
/// @warning Do not use a zero or short length.
/// @see Joint, World::CreateJoint
/// @ingroup JointsGroup
/// @image html distanceJoint.gif
struct DistanceJointConf : public JointBuilder<DistanceJointConf>
{
    /// @brief Super type.
    using super = JointBuilder<DistanceJointConf>;

    /// @brief Default constructor.
    constexpr DistanceJointConf() = default;

    /// @brief Copy constructor.
    DistanceJointConf(const DistanceJointConf& copy) = default;

    /// @brief Initializing constructor.
    /// @details Initialize the bodies, anchors, and length using the world anchors.
    DistanceJointConf(BodyID bA, BodyID bB,
                      Length2 laA = Length2{}, Length2 laB = Length2{}, Length l = 1_m) noexcept;

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
    /// @note 8-bytes (with 4-byte Real).
    Length2 localAnchorA = Length2{};
    
    /// @brief Local anchor point relative to body B's origin.
    /// @note 8-bytes (with 4-byte Real).
    Length2 localAnchorB = Length2{};
    
    /// @brief Natural length between the anchor points.
    /// @note 4-bytes (with 4-byte Real).
    Length length = 1_m;
    
    /// @brief Mass-spring-damper frequency.
    /// @note 0 disables softness.
    /// @note 4-bytes (with 4-byte Real).
    NonNegative<Frequency> frequency{};
    
    /// @brief Damping ratio.
    /// @note 0 = no damping, 1 = critical damping.
    /// @note 4-bytes (with 4-byte Real).
    Real dampingRatio = 0;

    // Solver shared.

    Momentum impulse = 0_Ns; ///< Impulse. 4-bytes (with 4-byte Real).

    // Solver temp (4 * 3 + 8 * 3 = 36 bytes minimally).

    UnitVec u; ///< "u" directional. 8-bytes (with 4-byte Real).
    Length2 rA = {}; ///< Relative A position. 8-bytes (with 4-byte Real).
    Length2 rB = {}; ///< Relative B position. 8-bytes (with 4-byte Real).
    InvMass invGamma = {}; ///< Inverse gamma. 4-bytes (with 4-byte Real).
    LinearVelocity bias = {}; ///< Bias. 4-bytes (with 4-byte Real).
    Mass mass = 0_kg; ///< Mass. 4-bytes (with 4-byte Real).
};

/// @brief Gets the definition data for the given joint.
/// @relatedalso Joint
DistanceJointConf GetDistanceJointConf(const Joint& joint) noexcept;

/// @brief Gets the configuration for the given parameters.
/// @relatedalso World
DistanceJointConf GetDistanceJointConf(const World& world, BodyID bodyA, BodyID bodyB,
                                       Length2 anchorA = Length2{}, Length2 anchorB = Length2{});

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
    return AngularMomentum{0};
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso DistanceJointConf
constexpr bool ShiftOrigin(DistanceJointConf&, Length2) noexcept
{
    return false;
}

/// @brief Initializes velocity constraint data based on the given solver data.
/// @note This MUST be called prior to calling <code>SolveVelocity</code>.
/// @see SolveVelocity.
/// @relatedalso DistanceJointConf
void InitVelocity(DistanceJointConf& object, std::vector<BodyConstraint>& bodies,
                  const StepConf& step,
                  const ConstraintSolverConf& conf);

/// @brief Solves velocity constraint.
/// @pre <code>InitVelocity</code> has been called.
/// @see InitVelocity.
/// @return <code>true</code> if velocity is "solved", <code>false</code> otherwise.
/// @relatedalso DistanceJointConf
bool SolveVelocity(DistanceJointConf& object, std::vector<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @return <code>true</code> if the position errors are within tolerance.
/// @relatedalso DistanceJointConf
bool SolvePosition(const DistanceJointConf& object, std::vector<BodyConstraint>& bodies,
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

/// @brief Type info specialization for <code>d2::DistanceJointConf</code>.
template <>
struct TypeInfo<d2::DistanceJointConf>
{
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::DistanceJointConf";
};

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_JOINTS_DISTANCEJOINTCONF_HPP
