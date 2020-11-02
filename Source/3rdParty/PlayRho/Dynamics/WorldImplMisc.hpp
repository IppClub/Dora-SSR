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

std::unique_ptr<WorldImpl> CreateWorldImpl(const WorldConf& def);

std::unique_ptr<WorldImpl> CreateWorldImpl(const WorldImpl& other);

void Clear(WorldImpl& world) noexcept;

void SetFixtureDestructionListener(WorldImpl& world,
                                   std::function<void(FixtureID)> listener) noexcept;

void SetJointDestructionListener(WorldImpl& world,
                                 std::function<void(JointID)> listener) noexcept;

void SetBeginContactListener(WorldImpl& world, std::function<void(ContactID)> listener) noexcept;

void SetEndContactListener(WorldImpl& world, std::function<void(ContactID)> listener) noexcept;

void SetPreSolveContactListener(WorldImpl& world,
                                std::function<void(ContactID, const Manifold&)> listener) noexcept;

void SetPostSolveContactListener(WorldImpl& world,
                                 std::function<void(ContactID, const ContactImpulsesList&, unsigned)> listener) noexcept;

BodyID CreateBody(WorldImpl& world, const BodyConf& def = GetDefaultBodyConf());

StepStats Step(WorldImpl& world, const StepConf& conf);

void ShiftOrigin(WorldImpl& world, Length2 newOrigin);

SizedRange<std::vector<BodyID>::const_iterator> GetBodies(const WorldImpl& world) noexcept;

SizedRange<std::vector<BodyID>::const_iterator>
GetBodiesForProxies(const WorldImpl& world) noexcept;

/// @copydoc WorldImpl::GetFixturesForProxies
/// @relatedalso WorldImpl
SizedRange<std::vector<FixtureID>::const_iterator>
GetFixturesForProxies(const WorldImpl& world) noexcept;

SizedRange<std::vector<JointID>::const_iterator> GetJoints(const WorldImpl& world) noexcept;

SizedRange<std::vector<KeyedContactPtr>::const_iterator>
GetContacts(const WorldImpl& world) noexcept;

bool IsLocked(const WorldImpl& world) noexcept;

bool IsStepComplete(const WorldImpl& world) noexcept;

bool GetSubStepping(const WorldImpl& world) noexcept;

void SetSubStepping(WorldImpl& world, bool value) noexcept;

Length GetMinVertexRadius(const WorldImpl& world) noexcept;

Length GetMaxVertexRadius(const WorldImpl& world) noexcept;

Frequency GetInvDeltaTime(const WorldImpl& world) noexcept;

const DynamicTree& GetTree(const WorldImpl& world) noexcept;

FixtureCounter GetShapeCount(const WorldImpl& world) noexcept;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDIMPLMISC_HPP
