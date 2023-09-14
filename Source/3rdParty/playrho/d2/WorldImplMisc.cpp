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

#include "playrho/d2/WorldImplMisc.hpp"

#include "playrho/d2/WorldImpl.hpp"
#include "playrho/d2/WorldConf.hpp"
#include "playrho/d2/BodyConf.hpp"
#include "playrho/d2/ContactImpulsesList.hpp"
#include "playrho/d2/Body.hpp" // for WorldImpl not being incomplete
#include "playrho/d2/Joint.hpp" // for WorldImpl not being incomplete
#include "playrho/Contact.hpp" // for WorldImpl not being incomplete
#include "playrho/d2/Manifold.hpp" // for WorldImpl not being incomplete
#include "playrho/d2/Shape.hpp" // for WorldImpl not being incomplete

#include <utility> // for std::move

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
    world.SetShapeDestructionListener(std::move(listener));
}

void SetDetachListener(WorldImpl& world, std::function<void(std::pair<BodyID, ShapeID>)> listener) noexcept
{
    world.SetDetachListener(std::move(listener));
}

void SetJointDestructionListener(WorldImpl& world,
                                 std::function<void(JointID)> listener) noexcept
{
    world.SetJointDestructionListener(std::move(listener));
}

void SetBeginContactListener(WorldImpl& world, std::function<void(ContactID)> listener) noexcept
{
    world.SetBeginContactListener(std::move(listener));
}

void SetEndContactListener(WorldImpl& world, std::function<void(ContactID)> listener) noexcept
{
    world.SetEndContactListener(std::move(listener));
}

void SetPreSolveContactListener(WorldImpl& world,
                                std::function<void(ContactID, const Manifold&)> listener) noexcept
{
    world.SetPreSolveContactListener(std::move(listener));
}

void SetPostSolveContactListener(WorldImpl& world,
                                 std::function<void(ContactID, const ContactImpulsesList&, unsigned)> listener) noexcept
{
    world.SetPostSolveContactListener(std::move(listener));
}

StepStats Step(WorldImpl& world, const StepConf& conf)
{
    return world.Step(conf);
}

void ShiftOrigin(WorldImpl& world, const Length2& newOrigin)
{
    world.ShiftOrigin(newOrigin);
}

const std::vector<BodyID>& GetBodies(const WorldImpl& world) noexcept
{
    return world.GetBodies();
}

const std::vector<BodyID>& GetBodiesForProxies(const WorldImpl& world) noexcept
{
    return world.GetBodiesForProxies();
}

const std::vector<JointID>& GetJoints(const WorldImpl& world) noexcept
{
    return world.GetJoints();
}

std::vector<KeyedContactID> GetContacts(const WorldImpl& world)
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

const std::vector<std::pair<BodyID, ShapeID>>& GetFixturesForProxies(const WorldImpl& world) noexcept
{
    return world.GetFixturesForProxies();
}

} // namespace d2
} // namespace playrho
