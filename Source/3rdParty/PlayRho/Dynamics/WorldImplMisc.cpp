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

#include "PlayRho/Dynamics/WorldImplMisc.hpp"

#include "PlayRho/Dynamics/WorldImpl.hpp"
#include "PlayRho/Dynamics/WorldConf.hpp"
#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/ContactImpulsesList.hpp"
#include "PlayRho/Dynamics/Body.hpp" // for WorldImpl not being incomplete
#include "PlayRho/Dynamics/Joints/Joint.hpp" // for WorldImpl not being incomplete
#include "PlayRho/Dynamics/Contacts/Contact.hpp" // for WorldImpl not being incomplete
#include "PlayRho/Collision/Manifold.hpp" // for WorldImpl not being incomplete
#include "PlayRho/Collision/Shapes/Shape.hpp" // for WorldImpl not being incomplete

namespace playrho {
namespace d2 {

std::unique_ptr<WorldImpl> CreateWorldImpl(const WorldConf& def)
{
    return std::make_unique<WorldImpl>(def);
}

std::unique_ptr<WorldImpl> CreateWorldImpl(const WorldImpl& other)
{
    return std::make_unique<WorldImpl>(other);
}

void Clear(WorldImpl& world) noexcept
{
    world.Clear();
}

void SetShapeDestructionListener(WorldImpl& world, std::function<void(ShapeID)> listener) noexcept
{
    world.SetShapeDestructionListener(listener);
}

void SetDetachListener(WorldImpl& world, std::function<void(std::pair<BodyID, ShapeID>)> listener) noexcept
{
    world.SetDetachListener(listener);
}

void SetJointDestructionListener(WorldImpl& world,
                                 std::function<void(JointID)> listener) noexcept
{
    world.SetJointDestructionListener(listener);
}

void SetBeginContactListener(WorldImpl& world, std::function<void(ContactID)> listener) noexcept
{
    world.SetBeginContactListener(listener);
}

void SetEndContactListener(WorldImpl& world, std::function<void(ContactID)> listener) noexcept
{
    world.SetEndContactListener(listener);
}

void SetPreSolveContactListener(WorldImpl& world,
                                std::function<void(ContactID, const Manifold&)> listener) noexcept
{
    world.SetPreSolveContactListener(listener);
}

void SetPostSolveContactListener(WorldImpl& world,
                                 std::function<void(ContactID, const ContactImpulsesList&, unsigned)> listener) noexcept
{
    world.SetPostSolveContactListener(listener);
}

StepStats Step(WorldImpl& world, const StepConf& conf)
{
    return world.Step(conf);
}

void ShiftOrigin(WorldImpl& world, Length2 newOrigin)
{
    world.ShiftOrigin(newOrigin);
}

std::vector<BodyID> GetBodies(const WorldImpl& world) noexcept
{
    return world.GetBodies();
}

std::vector<BodyID> GetBodiesForProxies(const WorldImpl& world) noexcept
{
    return world.GetBodiesForProxies();
}

std::vector<JointID> GetJoints(const WorldImpl& world) noexcept
{
    return world.GetJoints();
}

std::vector<KeyedContactPtr> GetContacts(const WorldImpl& world) noexcept
{
    return world.GetContacts();
}

bool IsLocked(const WorldImpl& world) noexcept
{
    return world.IsLocked();
}

bool IsStepComplete(const WorldImpl& world) noexcept
{
    return world.IsStepComplete();
}

bool GetSubStepping(const WorldImpl& world) noexcept
{
    return world.GetSubStepping();
}

void SetSubStepping(WorldImpl& world, bool value) noexcept
{
    world.SetSubStepping(value);
}

Length GetMinVertexRadius(const WorldImpl& world) noexcept
{
    return world.GetMinVertexRadius();
}

Length GetMaxVertexRadius(const WorldImpl& world) noexcept
{
    return world.GetMaxVertexRadius();
}

Frequency GetInvDeltaTime(const WorldImpl& world) noexcept
{
    return world.GetInvDeltaTime();
}

const DynamicTree& GetTree(const WorldImpl& world) noexcept
{
    return world.GetTree();
}

std::vector<std::pair<BodyID, ShapeID>> GetFixturesForProxies(const WorldImpl& world) noexcept
{
    return world.GetFixturesForProxies();
}

} // namespace d2
} // namespace playrho
