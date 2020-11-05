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

#ifndef PLAYRHO_DYNAMICS_WORLDIMPLMISC_HPP
#define PLAYRHO_DYNAMICS_WORLDIMPLMISC_HPP

/// @file
/// Declarations of free functions of WorldImpl.

#include "PlayRho/Common/Units.hpp" // for Length, Frequency, etc.
#include "PlayRho/Common/Vector2.hpp" // for Length2
#include "PlayRho/Common/Range.hpp" // for SizedRange

#include "PlayRho/Dynamics/StepStats.hpp"
#include "PlayRho/Dynamics/BodyID.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/FixtureID.hpp"
#include "PlayRho/Dynamics/Contacts/ContactID.hpp"
#include "PlayRho/Dynamics/Contacts/KeyedContactID.hpp" // for KeyedContactPtr
#include "PlayRho/Dynamics/Joints/JointID.hpp"

#include <functional> // for std::function
#include <memory> // for std::unique_ptr
#include <vector>

namespace playrho {

struct StepConf;

namespace d2 {

class WorldImpl;
class Manifold;
struct JointConf;
class DynamicTree;
struct WorldConf;
class ContactImpulsesList;

/// @brief Creates a new world with the given configuration.
std::unique_ptr<WorldImpl> CreateWorldImpl(const WorldConf& def);

/// @brief Creates a new world that's a copy of the given world.
std::unique_ptr<WorldImpl> CreateWorldImpl(const WorldImpl& other);

/// @brief Clears the given world.
/// @relatedalso WorldImpl
void Clear(WorldImpl& world) noexcept;

/// @brief Registers a destruction listener for fixtures.
/// @relatedalso WorldImpl
void SetFixtureDestructionListener(WorldImpl& world,
                                   std::function<void(FixtureID)> listener) noexcept;

/// @brief Registers a destruction listener for joints.
/// @relatedalso WorldImpl
void SetJointDestructionListener(WorldImpl& world,
                                 std::function<void(JointID)> listener) noexcept;

/// @brief Registers a begin contact event listener.
/// @relatedalso WorldImpl
void SetBeginContactListener(WorldImpl& world, std::function<void(ContactID)> listener) noexcept;

/// @brief Registers an end contact event listener.
/// @relatedalso WorldImpl
void SetEndContactListener(WorldImpl& world, std::function<void(ContactID)> listener) noexcept;

/// @brief Registers a pre-solve contact event listener.
/// @relatedalso WorldImpl
void SetPreSolveContactListener(WorldImpl& world,
                                std::function<void(ContactID, const Manifold&)> listener) noexcept;

/// @brief Registers a post-solve contact event listener.
/// @relatedalso WorldImpl
void SetPostSolveContactListener(WorldImpl& world,
                                 std::function<void(ContactID, const ContactImpulsesList&, unsigned)> listener) noexcept;

/// @brief Steps the given world the specified amount.
/// @relatedalso WorldImpl
StepStats Step(WorldImpl& world, const StepConf& conf);

/// @brief Shifts the world origin.
/// @note Useful for large worlds.
/// @note The body shift formula is: <code>position -= newOrigin</code>.
/// @post The "origin" of this world's bodies, joints, and the board-phase dynamic tree
///   have been translated per the shift amount and direction.
/// @param world The world whose origin should be shifted.
/// @param newOrigin the new origin with respect to the old origin
/// @throws WrongState if this method is called while the world is locked.
/// @relatedalso WorldImpl
void ShiftOrigin(WorldImpl& world, Length2 newOrigin);

/// @brief Gets the bodies of the specified world.
/// @relatedalso WorldImpl
SizedRange<std::vector<BodyID>::const_iterator> GetBodies(const WorldImpl& world) noexcept;

/// @brief Gets the bodies-for-proxies range for this world.
/// @details Provides insight on what bodies have been queued for proxy processing
///   during the next call to the world step method.
/// @see WorldImpl::Step.
/// @relatedalso WorldImpl
SizedRange<std::vector<BodyID>::const_iterator>
GetBodiesForProxies(const WorldImpl& world) noexcept;

/// @brief Gets the fixtures-for-proxies range for this world.
/// @details Provides insight on what fixtures have been queued for proxy processing
///   during the next call to the world step method.
/// @see Step.
/// @relatedalso WorldImpl
SizedRange<std::vector<FixtureID>::const_iterator>
GetFixturesForProxies(const WorldImpl& world) noexcept;

/// @brief Gets the joints of the specified world.
/// @relatedalso WorldImpl
SizedRange<std::vector<JointID>::const_iterator> GetJoints(const WorldImpl& world) noexcept;

/// @brief Gets the contacts of the specified world.
/// @relatedalso WorldImpl
SizedRange<std::vector<KeyedContactPtr>::const_iterator>
GetContacts(const WorldImpl& world) noexcept;

/// @brief Is the world locked (in the middle of a time step).
/// @relatedalso WorldImpl
bool IsLocked(const WorldImpl& world) noexcept;

/// @brief Whether or not "step" is complete.
/// @details The "step" is completed when there are no more TOI events for the current time
///   step.
/// @return <code>true</code> unless sub-stepping is enabled and the step method returned
///   without finishing all of its sub-steps.
/// @see GetSubStepping, SetSubStepping.
/// @relatedalso WorldImpl
bool IsStepComplete(const WorldImpl& world) noexcept;

/// @brief Gets whether or not sub-stepping is enabled.
/// @see SetSubStepping, IsStepComplete.
/// @relatedalso WorldImpl
bool GetSubStepping(const WorldImpl& world) noexcept;

/// @brief Enables/disables single stepped continuous physics.
/// @note This is not normally used. Enabling sub-stepping is meant for testing.
/// @post The <code>GetSubStepping()</code> method will return the value this method was
///   called with.
/// @see IsStepComplete, GetSubStepping.
/// @relatedalso WorldImpl
void SetSubStepping(WorldImpl& world, bool value) noexcept;

/// @brief Gets the minimum vertex radius that shapes in this world can be.
/// @relatedalso WorldImpl
Length GetMinVertexRadius(const WorldImpl& world) noexcept;

/// @brief Gets the maximum vertex radius that shapes in this world can be.
/// @relatedalso WorldImpl
Length GetMaxVertexRadius(const WorldImpl& world) noexcept;

/// @brief Gets the inverse delta time.
/// @details Gets the inverse delta time that was set on construction or assignment, and
///   updated on every call to the <code>Step()</code> method having a non-zero delta-time.
/// @see Step.
/// @relatedalso WorldImpl
Frequency GetInvDeltaTime(const WorldImpl& world) noexcept;

/// @brief Gets access to the broad-phase dynamic tree information.
/// @relatedalso WorldImpl
const DynamicTree& GetTree(const WorldImpl& world) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDIMPLMISC_HPP
