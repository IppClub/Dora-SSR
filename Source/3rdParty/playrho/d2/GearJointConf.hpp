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

#ifndef PLAYRHO_D2_GEARJOINTCONF_HPP
#define PLAYRHO_D2_GEARJOINTCONF_HPP

/// @file
/// @brief Definition of the @c GearJointConf class and closely related code.

#include <variant>

// IWYU pragma: begin_exports

#include "playrho/JointID.hpp"
#include "playrho/Span.hpp"
#include "playrho/TypeInfo.hpp"

#include "playrho/d2/JointConf.hpp"
#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho {

struct ConstraintSolverConf;
struct StepConf;

namespace d2 {

class Joint;
class World;
class BodyConstraint;

/// @example GearJoint.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::GearJointConf</code>.

/// @brief Gear joint definition.
/// @details A gear joint is used to connect two joints together. Either joint can be
///   a revolute or prismatic joint. You specify a gear ratio to bind the motions together:
///      <code>coordinate1 + ratio * coordinate2 = constant</code>.
///   The ratio can be negative or positive. If one joint is a revolute joint and the other
///   joint is a prismatic joint, then the ratio will have units of length or units of 1/length.
/// @warning You have to manually destroy the gear joint if joint-1 or joint-2 is destroyed.
/// @see Joint, World::CreateJoint
/// @ingroup JointsGroup
/// @image html gearJoint.gif
struct GearJointConf : public JointBuilder<GearJointConf> {
    /// @brief Super type.
    using super = JointBuilder<GearJointConf>;

    /// @brief Prismatic specific data.
    struct PrismaticData {
        Length2 localAnchorA{}; ///< Local anchor A.
        Length2 localAnchorB{}; ///< Local anchor B.
        UnitVec localAxis; ///< Local axis.
    };

    /// @brief Revolute specific data.
    struct RevoluteData {
        Angle referenceAngle = 0_deg; ///< Reference angle between associated bodies.
    };

    /// @brief Type specific data type alias.
    using TypeData = std::variant<std::monostate, PrismaticData, RevoluteData>;

    /// @brief Default constructor.
    constexpr GearJointConf() noexcept = default;

    /// @brief Initializing constructor.
    GearJointConf(BodyID bA, BodyID bB, BodyID bC, BodyID bD) noexcept;

    /// @brief Uses the given ratio value.
    constexpr auto& UseRatio(Real v) noexcept
    {
        ratio = v;
        return *this;
    }

    /// @brief Identifier of body C.
    BodyID bodyC = InvalidBodyID;

    /// @brief Identifier of body D.
    BodyID bodyD = InvalidBodyID;

    TypeData typeDataAC; ///< Data for a revolute or prismatic joint between body A & C.
    TypeData typeDataBD; ///< Data for a revolute or prismatic joint between body B & D.

    /// The gear ratio.
    /// @see constant, GearJoint.
    Real ratio = Real{1};

    /// @brief Constant applied with the ratio.
    /// @note If this value is not finite, then position constraint solving will be skipped.
    /// @see ratio.
    Real constant = Real{0};

    Momentum impulse = 0_Ns; ///< Impulse.

    // Solver temp
    Vec2 JvAC = {}; ///< A-C directional data.
    Vec2 JvBD = {}; ///< B-D directional data.
    Length JwA = 0_m; ///< Data for calculating Body A velocity.
    Length JwB = 0_m; ///< Data for calculating Body B velocity.
    Length JwC = 0_m; ///< Data for calculating Body C velocity.
    Length JwD = 0_m; ///< Data for calculating Body D velocity.
    Real mass = 0; ///< Either linear mass or angular mass.
};

/// @brief Equals operator.
/// @relatedalso GearJointConf::PrismaticData
constexpr bool operator==(const GearJointConf::PrismaticData& lhs,
                          const GearJointConf::PrismaticData& rhs) noexcept
{
    return lhs.localAnchorA == rhs.localAnchorA && lhs.localAnchorB == rhs.localAnchorB &&
           lhs.localAxis == rhs.localAxis;
}

/// @brief Not equals operator.
/// @relatedalso GearJointConf::PrismaticData
constexpr bool operator!=(const GearJointConf::PrismaticData& lhs,
                          const GearJointConf::PrismaticData& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Equals operator.
/// @relatedalso GearJointConf::RevoluteData
constexpr bool operator==(const GearJointConf::RevoluteData& lhs,
                          const GearJointConf::RevoluteData& rhs) noexcept
{
    return lhs.referenceAngle == rhs.referenceAngle;
}

/// @brief Not equals operator.
/// @relatedalso GearJointConf::RevoluteData
constexpr bool operator!=(const GearJointConf::RevoluteData& lhs,
                          const GearJointConf::RevoluteData& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Equality operator.
constexpr bool operator==(const GearJointConf& lhs, const GearJointConf& rhs) noexcept
{
    return // First check base...
        (lhs.bodyA == rhs.bodyA) && (lhs.bodyB == rhs.bodyB) &&
        (lhs.collideConnected == rhs.collideConnected)
        // Now check rest...
        && (lhs.bodyC == rhs.bodyC) // line break
        && (lhs.bodyD == rhs.bodyD) // line break
        && (lhs.typeDataAC == rhs.typeDataAC) // line break
        && (lhs.typeDataBD == rhs.typeDataBD) // line break
        && (lhs.ratio == rhs.ratio) // line break
        && (lhs.constant == rhs.constant) // line break
        && (lhs.impulse == rhs.impulse) // line break
        && (lhs.JvAC == rhs.JvAC) // line break
        && (lhs.JvBD == rhs.JvBD) // line break
        && (lhs.JwA == rhs.JwA) // line break
        && (lhs.JwB == rhs.JwB) // line break
        && (lhs.JwC == rhs.JwC) // line break
        && (lhs.JwD == rhs.JwD) // line break
        && (lhs.mass == rhs.mass);
}

/// @brief Inequality operator.
constexpr bool operator!=(const GearJointConf& lhs, const GearJointConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the definition data for the given joint.
/// @throws std::bad_cast If the given joint's type is inappropriate for getting this value.
/// @relatedalso Joint
GearJointConf GetGearJointConf(const Joint& joint);

/// @brief Gets the configuration for the given parameters.
/// @throws std::out_of_range If given an invalid joint identifier.
/// @relatedalso World
GearJointConf GetGearJointConf(const World& world, JointID id1, JointID id2, Real ratio = Real{1});

/// @brief Gets the current linear reaction for the given configuration.
/// @relatedalso GearJointConf
constexpr Momentum2 GetLinearReaction(const GearJointConf& object)
{
    return object.impulse * object.JvAC;
}

/// @brief Gets the current angular reaction for the given configuration.
/// @relatedalso GearJointConf
constexpr AngularMomentum GetAngularReaction(const GearJointConf& object)
{
    return object.impulse * object.JwA / Radian;
}

/// @brief Shifts the origin notion of the given configuration.
/// @relatedalso GearJointConf
constexpr bool ShiftOrigin(GearJointConf&, const Length2&) noexcept
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
/// @relatedalso GearJointConf
void InitVelocity(GearJointConf& object, const Span<BodyConstraint>& bodies, const StepConf& step,
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
/// @relatedalso GearJointConf
bool SolveVelocity(GearJointConf& object, const Span<BodyConstraint>& bodies,
                   const StepConf& step);

/// @brief Solves the position constraint.
/// @param object Configuration object. <code>bodyA</code> and <code>bodyB</code> must index bodies within
///   the given <code>bodies</code> container or be the special body ID value of <code>InvalidBodyID</code>.
/// @param bodies Container of body constraints.
/// @param conf Constraint solver configuration.
/// @throws std::out_of_range If the given object's <code>bodyA</code> or <code>bodyB</code> values are not
///  <code>InvalidBodyID</code> and are not  indices within range of the given <code>bodies</code> container.
/// @return <code>true</code> if the position errors are within tolerance.
/// @relatedalso GearJointConf
bool SolvePosition(const GearJointConf& object, const Span<BodyConstraint>& bodies,
                   const ConstraintSolverConf& conf);

/// @brief Free function for getting the ratio value of the given configuration.
/// @relatedalso GearJointConf
constexpr auto GetRatio(const GearJointConf& object) noexcept
{
    return object.ratio;
}

/// @brief Free function for setting the ratio value of the given configuration.
/// @relatedalso GearJointConf
constexpr auto SetRatio(GearJointConf& object, Real value) noexcept
{
    object.UseRatio(value);
}

/// @brief Free function for getting the constant value of the given configuration.
/// @relatedalso GearJointConf
constexpr auto GetConstant(const GearJointConf& object) noexcept
{
    return object.constant;
}

/// @brief Free function for getting joint 1 type value of the given configuration.
/// @relatedalso GearJointConf
TypeID GetTypeAC(const GearJointConf& object) noexcept;

/// @brief Free function for getting joint 2 type value of the given configuration.
/// @relatedalso GearJointConf
TypeID GetTypeBD(const GearJointConf& object) noexcept;

/// @brief Gets the local anchor A property of the given joint.
Length2 GetLocalAnchorA(const GearJointConf& conf);

/// @brief Gets the local anchor B property of the given joint.
Length2 GetLocalAnchorB(const GearJointConf& conf);

} // namespace d2
} // namespace playrho

/// @brief Type info specialization for <code>playrho::d2::GearJointConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::GearJointConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::GearJointConf";
};

#endif // PLAYRHO_D2_GEARJOINTCONF_HPP
