/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_D2_CONTACTSOLVER_HPP
#define PLAYRHO_D2_CONTACTSOLVER_HPP

/// @file
/// @brief Declarations of the velocity and position constraint solver functions.

// IWYU pragma: begin_exports

#include "playrho/Span.hpp"

#include "playrho/d2/Math.hpp"
#include "playrho/d2/PositionSolution.hpp"

// IWYU pragma: end_exports

namespace playrho {

struct ConstraintSolverConf;

namespace d2 {

class VelocityConstraint;
struct PositionConstraint;
class BodyConstraint;

} // namespace d2

namespace GaussSeidel {

/// @brief Solves the velocity constraint.
/// @details This updates the tangent and normal impulses of the velocity constraint
///   points of the given velocity constraint and updates the given velocities.
/// @note Linear velocity is only changed if the inverse mass of either body is non-zero.
/// @note Angular velocity is only changed if the inverse rotational inertia of either
///   body is non-zero.
/// @param vc Velocity constraint to solve for.
/// @param bodies Collection of bodies containing the two for the velocity constraint.
/// @pre @p vc must have a valid normal, a valid tangent, valid point relative positions,
///   valid velocity biases, and 1 or 2 point counts.
Momentum SolveVelocityConstraint(d2::VelocityConstraint& vc,
                                 const Span<d2::BodyConstraint>& bodies);

/// Solves the given position constraint.
/// @details
/// This pushes apart the two given positions for every point in the contact position constraint
/// and returns the minimum separation value from the position solver manifold for each point.
/// @see http://allenchou.net/2013/12/game-physics-resolution-contact-constraints/
/// @return Minimum separation distance of the position constraint's manifold points
///   (prior to "solving").
d2::PositionSolution SolvePositionConstraint(const d2::PositionConstraint& pc,
                                             bool moveA, bool moveB,
                                             const Span<d2::BodyConstraint>& bodies,
                                             const ConstraintSolverConf& conf);

} // namespace GaussSidel

} // namespace playrho

#endif // PLAYRHO_D2_CONTACTSOLVER_HPP

