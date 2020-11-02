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

#include "PlayRho/Dynamics/WorldMisc.hpp"

#include "PlayRho/Dynamics/World.hpp"
#include "PlayRho/Dynamics/WorldBody.hpp"

#include "PlayRho/Dynamics/BodyConf.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include "PlayRho/Dynamics/MovementConf.hpp"

#include <algorithm> // for std::for_each

using std::for_each;

namespace playrho {
namespace d2 {

using playrho::size;

void SetFixtureDestructionListener(World& world, std::function<void(FixtureID)> listener) noexcept
{
    world.SetFixtureDestructionListener(listener);
}

void SetJointDestructionListener(World& world, std::function<void(JointID)> listener) noexcept
{
    world.SetJointDestructionListener(listener);
}

void SetBeginContactListener(World& world, std::function<void(ContactID)> listener) noexcept
{
    world.SetBeginContactListener(listener);
}

void SetEndContactListener(World& world, std::function<void(ContactID)> listener) noexcept
{
    world.SetEndContactListener(listener);
}

void SetPreSolveContactListener(World& world,
                                std::function<void(ContactID, const Manifold&)> listener) noexcept
{
    world.SetPreSolveContactListener(listener);
}

void SetPostSolveContactListener(World& world,
                                 std::function<void(ContactID, const ContactImpulsesList&,
                                                    unsigned)> listener) noexcept
{
    world.SetPostSolveContactListener(listener);
}

void Clear(World& world) noexcept
{
    world.Clear();
}

Length GetMinVertexRadius(const World& world) noexcept
{
    return world.GetMinVertexRadius();
}

Length GetMaxVertexRadius(const World& world) noexcept
{
    return world.GetMaxVertexRadius();
}

StepStats Step(World& world, const StepConf& conf)
{
    return world.Step(conf);
}

StepStats Step(World& world, Time delta, TimestepIters velocityIterations,
               TimestepIters positionIterations)
{
    StepConf conf;
    conf.deltaTime = delta;
    conf.regVelocityIterations = velocityIterations;
    conf.regPositionIterations = positionIterations;
    conf.toiVelocityIterations = velocityIterations;
    if (positionIterations == 0)
    {
        conf.toiPositionIterations = 0;
    }
    conf.dtRatio = delta * world.GetInvDeltaTime();
    return world.Step(conf);
}

const DynamicTree& GetTree(const World& world) noexcept
{
    return world.GetTree();
}

FixtureCounter GetShapeCount(const World& world) noexcept
{
    return world.GetShapeCount();
}

} // namespace d2
} // namespace playrho
