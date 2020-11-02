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

#include "PlayRho/Dynamics/WorldContact.hpp"

#include "PlayRho/Dynamics/World.hpp"

#include "PlayRho/Collision/Manifold.hpp"

namespace playrho {
namespace d2 {

SizedRange<std::vector<KeyedContactPtr>::const_iterator>
GetContacts(const World& world) noexcept
{
    return world.GetContacts();
}

bool IsTouching(const World& world, ContactID id)
{
    return world.IsTouching(id);
}

bool IsAwake(const World& world, ContactID id)
{
    return world.IsAwake(id);
}

void SetAwake(World& world, ContactID id)
{
    world.SetAwake(id);
}

ChildCounter GetChildIndexA(const World& world, ContactID id)
{
    return world.GetChildIndexA(id);
}

ChildCounter GetChildIndexB(const World& world, ContactID id)
{
    return world.GetChildIndexB(id);
}

FixtureID GetFixtureA(const World& world, ContactID id)
{
    return world.GetFixtureA(id);
}

FixtureID GetFixtureB(const World& world, ContactID id)
{
    return world.GetFixtureB(id);
}

BodyID GetBodyA(const World& world, ContactID id)
{
    return world.GetBodyA(id);
}

BodyID GetBodyB(const World& world, ContactID id)
{
    return world.GetBodyB(id);
}

TimestepIters GetToiCount(const World& world, ContactID id)
{
    return world.GetToiCount(id);
}

bool NeedsFiltering(const World& world, ContactID id)
{
    return world.NeedsFiltering(id);
}

bool NeedsUpdating(const World& world, ContactID id)
{
    return world.NeedsUpdating(id);
}

bool HasValidToi(const World& world, ContactID id)
{
    return world.HasValidToi(id);
}

Real GetToi(const World& world, ContactID id)
{
    return world.GetToi(id);
}

Real GetDefaultFriction(const World& world, ContactID id)
{
    return world.GetDefaultFriction(id);
}

Real GetDefaultRestitution(const World& world, ContactID id)
{
    return world.GetDefaultRestitution(id);
}

Real GetFriction(const World& world, ContactID id)
{
    return world.GetFriction(id);
}

Real GetRestitution(const World& world, ContactID id)
{
    return world.GetRestitution(id);
}

void SetFriction(World& world, ContactID id, Real friction)
{
    world.SetFriction(id, friction);
}

void SetRestitution(World& world, ContactID id, Real restitution)
{
    world.SetRestitution(id, restitution);
}

const Manifold& GetManifold(const World& world, ContactID id)
{
    return world.GetManifold(id);
}

WorldManifold GetWorldManifold(const World& world, ContactID id)
{
    const auto bA = GetBodyA(world, id);
    const auto fA = GetFixtureA(world, id);
    const auto iA = GetChildIndexA(world, id);
    const auto bB = GetBodyB(world, id);
    const auto fB = GetFixtureB(world, id);
    const auto iB = GetChildIndexB(world, id);
    const auto manifold = GetManifold(world, id);
    const auto xfA = world.GetTransformation(bA);
    const auto radiusA = GetVertexRadius(GetShape(world.GetFixture(fA)), iA);
    const auto xfB = world.GetTransformation(bB);
    const auto radiusB = GetVertexRadius(GetShape(world.GetFixture(fB)), iB);
    return GetWorldManifold(manifold, xfA, radiusA, xfB, radiusB);
}

LinearVelocity GetTangentSpeed(const World& world, ContactID id)
{
    return world.GetTangentSpeed(id);
}

void SetTangentSpeed(World& world, ContactID id, LinearVelocity value)
{
    world.SetTangentSpeed(id, value);
}

bool IsEnabled(const World& world, ContactID id)
{
    return world.IsEnabled(id);
}

void SetEnabled(World& world, ContactID id)
{
    world.SetEnabled(id);
}

void UnsetEnabled(World& world, ContactID id)
{
    world.UnsetEnabled(id);
}

ContactCounter GetTouchingCount(const World& world) noexcept
{
    const auto contacts = world.GetContacts();
    return static_cast<ContactCounter>(count_if(cbegin(contacts), cend(contacts),
                                                [&](const auto &c) {
        return world.IsTouching(std::get<ContactID>(c));
    }));
}

} // namespace d2
} // namespace playrho
