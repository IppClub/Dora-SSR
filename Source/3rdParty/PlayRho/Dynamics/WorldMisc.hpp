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

#ifndef PLAYRHO_DYNAMICS_WORLDMISC_HPP
#define PLAYRHO_DYNAMICS_WORLDMISC_HPP

/// @file
/// Declarations of free functions of World for unidentified information.

#include "PlayRho/Common/Math.hpp"

#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/Joints/JointID.hpp"
#include "PlayRho/Dynamics/Contacts/ContactID.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/StepStats.hpp"
#include "PlayRho/Collision/Shapes/ShapeID.hpp"

#include <utility> // for std::pair

namespace playrho {
namespace d2 {

class World;
class DynamicTree;
class Manifold;
class ContactImpulsesList;

/// @brief Sets the shape destruction lister.
/// @relatedalso World
void SetShapeDestructionListener(World& world, std::function<void(ShapeID)> listener) noexcept;

/// @brief Sets the detach lister.
/// @relatedalso World
void SetDetachListener(World& world, std::function<void(std::pair<BodyID, ShapeID>)> listener) noexcept;

/// @brief Sets the joint destruction lister.
/// @relatedalso World
void SetJointDestructionListener(World& world, std::function<void(JointID)> listener) noexcept;

/// @brief Sets the begin-contact lister.
/// @relatedalso World
void SetBeginContactListener(World& world, std::function<void(ContactID)> listener) noexcept;

/// @brief Sets the end-contact lister.
/// @relatedalso World
void SetEndContactListener(World& world, std::function<void(ContactID)> listener) noexcept;

/// @brief Sets the pre-solve-contact lister.
/// @relatedalso World
void SetPreSolveContactListener(World& world,
                                std::function<void(ContactID, const Manifold&)> listener) noexcept;

/// @brief Sets the post-solve-contact lister.
/// @relatedalso World
void SetPostSolveContactListener(World& world,
                                 std::function<void(ContactID, const ContactImpulsesList&,
                                                    unsigned)> listener) noexcept;

/// @brief Clears this world.
/// @note This calls the joint and fixture destruction listeners (if they're set)
///   before clearing anything.
/// @post The contents of this world have all been destroyed and this world's internal
///   state is reset as though it had just been constructed.
/// @relatedalso World
void Clear(World& world) noexcept;

/// @brief Steps the given world the specified amount.
/// @relatedalso World
StepStats Step(World& world, const StepConf& conf = StepConf{});

/// @brief Steps the world ahead by a given time amount.
///
/// @details Performs position and velocity updating, sleeping of non-moving bodies, updating
///   of the contacts, and notifying the contact listener of begin-contact, end-contact,
///   pre-solve, and post-solve events.
///   If the given velocity and position iterations are more than zero, this method also
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
               TimestepIters velocityIterations = 8,
               TimestepIters positionIterations = 3);

/// @brief Gets whether or not sub-stepping is enabled.
/// @see SetSubStepping, IsStepComplete.
/// @relatedalso World
bool GetSubStepping(const World& world) noexcept;

/// @brief Enables/disables single stepped continuous physics.
/// @note This is not normally used. Enabling sub-stepping is meant for testing.
/// @post The <code>GetSubStepping()</code> method will return the value this method was
///   called with.
/// @see IsStepComplete, GetSubStepping.
/// @relatedalso World
void SetSubStepping(World& world, bool flag) noexcept;

/// @brief Gets the dynamic tree of the given world.
/// @relatedalso World
const DynamicTree& GetTree(const World& world) noexcept;

/// @brief Gets the min vertex radius that shapes for the given world are allowed to be.
/// @relatedalso World
Length GetMinVertexRadius(const World& world) noexcept;

/// @brief Gets the max vertex radius that shapes for the given world are allowed to be.
/// @relatedalso World
Length GetMaxVertexRadius(const World& world) noexcept;

/// @brief Shifts the world origin.
/// @note Useful for large worlds.
/// @note The body shift formula is: <code>position -= newOrigin</code>.
/// @post The "origin" of this world's bodies, joints, and the board-phase dynamic tree
///   have been translated per the shift amount and direction.
/// @param world The world whose origin should be shifted.
/// @param newOrigin the new origin with respect to the old origin
/// @throws WrongState if this method is called while the world is locked.
/// @relatedalso World
void ShiftOrigin(World& world, Length2 newOrigin);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDMISC_HPP
