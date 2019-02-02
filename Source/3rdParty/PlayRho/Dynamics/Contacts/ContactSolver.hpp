/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#ifndef PLAYRHO_DYNAMICS_CONTACTS_CONTACTSOLVER_HPP
#define PLAYRHO_DYNAMICS_CONTACTS_CONTACTSOLVER_HPP

#include "PlayRho/Common/Math.hpp"

namespace playrho {

class StepConf;

namespace d2 {

class VelocityConstraint;
class PositionConstraint;
class BodyConstraint;

/// @brief Solution for position constraint.
struct PositionSolution
{
    Position pos_a; ///< Position A.
    Position pos_b; ///< Position B.
    Length min_separation; ///< Min separation.
};

/// @brief Addition operator.
inline PositionSolution operator+ (PositionSolution lhs, PositionSolution rhs)
{
    return PositionSolution{
        lhs.pos_a + rhs.pos_a,
        lhs.pos_b + rhs.pos_b,
        lhs.min_separation + rhs.min_separation
    };
}

/// @brief Subtraction operator.
inline PositionSolution operator- (PositionSolution lhs, PositionSolution rhs)
{
    return PositionSolution{
        lhs.pos_a - rhs.pos_a,
        lhs.pos_b - rhs.pos_b,
        lhs.min_separation - rhs.min_separation
    };
}

} // namespace d2

/// Constraint solver configuration data.
/// @details
/// Defines how a constraint solver should resolve a given constraint.
/// @sa SolvePositionConstraint.
struct ConstraintSolverConf
{
    /// @brief Uses the given resolution rate.
    ConstraintSolverConf& UseResolutionRate(Real value) noexcept;
    
    /// @brief Uses the given linear slop.
    ConstraintSolverConf& UseLinearSlop(Length value) noexcept;
    
    /// @brief Uses the given angular slop.
    ConstraintSolverConf& UseAngularSlop(Angle value) noexcept;
    
    /// @brief Uses the given max linear correction.
    ConstraintSolverConf& UseMaxLinearCorrection(Length value) noexcept;
    
    /// @brief Uses the given max angular correction.
    ConstraintSolverConf& UseMaxAngularCorrection(Angle value) noexcept;
    
    /// Resolution rate.
    /// @details
    /// Defines the percentage of the overlap that should get resolved in a single solver call.
    /// Value greater than zero and less than or equal to one.
    /// Ideally this would be 1 so that overlap is removed in one time step.
    /// However using values close to 1 often leads to overshoot.
    /// @note Recommended values are: <code>0.2</code> for solving regular constraints
    ///   or <code>0.75</code> for solving TOI constraints.
    Real resolutionRate = Real(0.2);
    
    /// Linear slop.
    /// @note The negative of this amount is the maximum amount of separation to create.
    /// @note Recommended value: <code>DefaultLinearSlop</code>.
    Length linearSlop = DefaultLinearSlop;
    
    /// Angular slop.
    /// @note Recommended value: <code>DefaultAngularSlop</code>.
    Angle angularSlop = DefaultAngularSlop;
    
    /// Maximum linear correction.
    /// @details
    /// Maximum amount of overlap to resolve in a single solver call. Helps prevent overshoot.
    /// @note Recommended value: <code>linearSlop * 40</code>.
    Length maxLinearCorrection = DefaultLinearSlop * Real{20};
    
    /// Maximum angular correction.
    /// @details Maximum angular position correction used when solving constraints.
    /// Helps to prevent overshoot.
    /// @note Recommended value: <code>angularSlop * 4</code>.
    Angle maxAngularCorrection = DefaultAngularSlop * Real{4};
};

inline ConstraintSolverConf& ConstraintSolverConf::UseResolutionRate(Real value) noexcept
{
    resolutionRate = value;
    return *this;
}

inline ConstraintSolverConf& ConstraintSolverConf::UseLinearSlop(Length value) noexcept
{
    linearSlop = value;
    return *this;
}

inline ConstraintSolverConf& ConstraintSolverConf::UseAngularSlop(Angle value) noexcept
{
    angularSlop = value;
    return *this;
}

inline ConstraintSolverConf& ConstraintSolverConf::UseMaxLinearCorrection(Length value) noexcept
{
    maxLinearCorrection = value;
    return *this;
}

inline ConstraintSolverConf& ConstraintSolverConf::UseMaxAngularCorrection(Angle value) noexcept
{
    maxAngularCorrection = value;
    return *this;
}

/// @brief Gets the default position solver configuration.
inline ConstraintSolverConf GetDefaultPositionSolverConf()
{
    return ConstraintSolverConf{}.UseResolutionRate(Real(0.2));
}

/// @brief Gets the default TOI position solver configuration.
inline ConstraintSolverConf GetDefaultToiPositionSolverConf()
{
    // For solving TOI events, use a faster/higher resolution rate than normally used.
    return ConstraintSolverConf{}.UseResolutionRate(Real(0.75));
}

/// @brief Gets the regular phase constraint solver configuration for the given step configuration.
ConstraintSolverConf GetRegConstraintSolverConf(const StepConf& conf) noexcept;

/// @brief Gets the TOI phase constraint solver configuration for the given step configuration.
ConstraintSolverConf GetToiConstraintSolverConf(const StepConf& conf) noexcept;

namespace GaussSeidel {

/// Solves the velocity constraint.
///
/// @details This updates the tangent and normal impulses of the velocity constraint
///   points of the given velocity constraint and updates the given velocities.
///
/// @warning Behavior is undefined unless the velocity constraint point count is 1 or 2.
/// @note Linear velocity is only changed if the inverse mass of either body is non-zero.
/// @note Angular velocity is only changed if the inverse rotational inertia of either
///   body is non-zero.
/// @note Inlining this function may yield a 10% speed boost in the
///   <code>World.TilesComesToRest</code> unit test.
///
/// @pre The velocity constraint must have a valid normal, a valid tangent,
///   valid point relative positions, and valid velocity biases.
///
Momentum SolveVelocityConstraint(d2::VelocityConstraint& vc);

/// Solves the given position constraint.
/// @details
/// This pushes apart the two given positions for every point in the contact position constraint
/// and returns the minimum separation value from the position solver manifold for each point.
/// @sa http://allenchou.net/2013/12/game-physics-resolution-contact-constraints/
/// @return Minimum separation distance of the position constraint's manifold points
///   (prior to "solving").
d2::PositionSolution SolvePositionConstraint(const d2::PositionConstraint& pc,
                                     const bool moveA, const bool moveB,
                                     ConstraintSolverConf conf);

} // namespace GaussSidel

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_CONTACTS_CONTACTSOLVER_HPP

