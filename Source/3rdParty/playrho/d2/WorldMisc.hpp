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

#ifndef PLAYRHO_D2_WORLDMISC_HPP
#define PLAYRHO_D2_WORLDMISC_HPP

/// @file
/// @brief Declarations of free functions of World for unidentified information.

// IWYU pragma: begin_exports

#include "playrho/BodyID.hpp"
#include "playrho/JointID.hpp"
#include "playrho/ContactID.hpp"
#include "playrho/StepConf.hpp"
#include "playrho/StepStats.hpp"
#include "playrho/ShapeID.hpp"

#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

class World;
class DynamicTree;
class Manifold;
class ContactImpulsesList;

/// @brief Steps the world ahead by a given time amount.
///
/// @details Performs position and velocity updating, sleeping of non-moving bodies, updating
///   of the contacts, and notifying the contact listener of begin-contact, end-contact,
///   pre-solve, and post-solve events.
///   If the given velocity and position iterations are more than zero, this function also
///   respectively performs velocity and position resolution of the contacting bodies.
///
/// @note While body velocities are updated accordingly (per the sum of forces acting on them),
///   body positions (barring any collisions) are updated as if they had moved the entire time
///   step at those resulting velocities. In other words, a body initially at <code>p0</code>
///   going <code>v0</code> fast with a sum acceleration of <code>a</code>, after time
///   <code>t</code> and barring any collisions, will have a new velocity (<code>v1</code>) of
///   <code>v0 + (a * t)</code> and a new position (<code>p1</code>) of <code>p0 + v1 * t</code>.
///
/// @warning Varying the time step may lead to non-physical behaviors.
///
/// @post Static bodies are unmoved.
/// @post Kinetic bodies are moved based on their previous velocities.
/// @post Dynamic bodies are moved based on their previous velocities, gravity,
/// applied forces, applied impulses, masses, damping, and the restitution and friction values
/// of their fixtures when they experience collisions.
///
/// @param world World to step.
/// @param delta Time to simulate as a delta from the current state. This should not vary.
/// @param velocityIterations Number of iterations for the velocity constraint solver.
/// @param positionIterations Number of iterations for the position constraint solver.
///   The position constraint solver resolves the positions of bodies that overlap.
///
/// @relatedalso World
///
StepStats Step(World& world, Time delta,
               TimestepIters velocityIterations = StepConf::DefaultRegVelocityIters,
               TimestepIters positionIterations = StepConf::DefaultRegPositionIters);

} // namespace playrho::d2

#endif // PLAYRHO_D2_WORLDMISC_HPP
