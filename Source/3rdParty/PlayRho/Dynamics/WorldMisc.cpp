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
#include <set>

using std::for_each;

namespace playrho {
namespace d2 {

using playrho::size;

void SetShapeDestructionListener(World& world, std::function<void(ShapeID)> listener) noexcept
{
    world.SetShapeDestructionListener(listener);
}

void SetDetachListener(World& world, std::function<void(std::pair<BodyID, ShapeID>)> listener) noexcept
{
    world.SetDetachListener(listener);
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
    conf.regVelocityIters = velocityIterations;
    conf.regPositionIters = positionIterations;
    conf.toiVelocityIters = velocityIterations;
    if (positionIterations == 0)
    {
        conf.toiPositionIters = 0;
    }
    conf.dtRatio = delta * world.GetInvDeltaTime();
    return world.Step(conf);
}

bool GetSubStepping(const World& world) noexcept
{
    return world.GetSubStepping();
}

void SetSubStepping(World& world, bool flag) noexcept
{
    world.SetSubStepping(flag);
}

const DynamicTree& GetTree(const World& world) noexcept
{
    return world.GetTree();
}

void ShiftOrigin(World& world, Length2 newOrigin)
{
    world.ShiftOrigin(newOrigin);
}

} // namespace d2
} // namespace playrho
