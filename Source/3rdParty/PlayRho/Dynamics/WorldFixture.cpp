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

#include "PlayRho/Dynamics/WorldFixture.hpp"

#include "PlayRho/Dynamics/World.hpp"

namespace playrho {
namespace d2 {

using playrho::size;

FixtureCounter GetFixtureCount(const World& world) noexcept
{
    auto sum = FixtureCounter{0};
    const auto bodies = world.GetBodies();
    for_each(begin(bodies), end(bodies), [&world,&sum](const auto &b) {
        sum += static_cast<FixtureCounter>(size(world.GetFixtures(b)));
    });
    return sum;
}

FixtureID CreateFixture(World& world, FixtureConf def, bool resetMassData)
{
    return world.CreateFixture(def, resetMassData);
}

FixtureID CreateFixture(World& world, BodyID id, const Shape& shape,
                        FixtureConf def, bool resetMassData)
{
    def.body = id;
    def.shape = shape;
    return CreateFixture(world, def, resetMassData);
}

bool Destroy(World& world, FixtureID id, bool resetMassData)
{
    return world.Destroy(id, resetMassData);
}

Filter GetFilterData(const World& world, FixtureID id)
{
    return GetFilterData(world.GetFixture(id));
}

void SetFilterData(World& world, FixtureID id, const Filter& value)
{
    auto fixture = world.GetFixture(id);
    SetFilterData(fixture, value);
    world.SetFixture(id, fixture);
    world.Refilter(id);
}

void Refilter(World& world, FixtureID id)
{
    world.Refilter(id);
}

BodyID GetBody(const World& world, FixtureID id)
{
    return GetBody(world.GetFixture(id));
}

Transformation GetTransformation(const World& world, FixtureID id)
{
    return world.GetTransformation(GetBody(world, id));
}

const Shape& GetShape(const World& world, FixtureID id)
{
    return GetShape(world.GetFixture(id));
}

bool IsSensor(const World& world, FixtureID id)
{
    return IsSensor(world.GetFixture(id));
}

void SetSensor(World& world, FixtureID id, bool value)
{
    auto fixture = world.GetFixture(id);
    SetSensor(fixture, value);
    world.SetFixture(id, fixture);
}

AreaDensity GetDensity(const World& world, FixtureID id)
{
    return GetDensity(world.GetFixture(id));
}

bool TestPoint(const World& world, FixtureID id, Length2 p)
{
    return TestPoint(GetShape(world, id), InverseTransform(p, GetTransformation(world, id)));
}

} // namespace d2
} // namespace playrho
