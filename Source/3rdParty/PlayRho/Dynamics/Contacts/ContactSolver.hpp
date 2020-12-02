/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include <vector>

namespace playrho {

struct StepConf;
struct ConstraintSolverConf;

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
Momentum SolveVelocityConstraint(d2::VelocityConstraint& vc,
                                 std::vector<d2::BodyConstraint>& bodies);

/// Solves the given position constraint.
/// @details
/// This pushes apart the two given positions for every point in the contact position constraint
/// and returns the minimum separation value from the position solver manifold for each point.
/// @see http://allenchou.net/2013/12/game-physics-resolution-contact-constraints/
/// @return Minimum separation distance of the position constraint's manifold points
///   (prior to "solving").
d2::PositionSolution SolvePositionConstraint(const d2::PositionConstraint& pc,
                                             bool moveA, bool moveB,
                                             const std::vector<d2::BodyConstraint>& bodies,
                                             const ConstraintSolverConf& conf);

} // namespace GaussSidel

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_CONTACTS_CONTACTSOLVER_HPP

