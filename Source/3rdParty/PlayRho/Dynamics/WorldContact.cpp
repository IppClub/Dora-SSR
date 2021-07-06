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
#include "PlayRho/Dynamics/WorldBody.hpp"
#include "PlayRho/Dynamics/WorldShape.hpp"
#include "PlayRho/Dynamics/Body.hpp" // for GetBody
#include "PlayRho/Dynamics/Contacts/Contact.hpp"

#include "PlayRho/Collision/Manifold.hpp"
#include "PlayRho/Collision/WorldManifold.hpp"

namespace playrho {
namespace d2 {

ContactCounter GetContactRange(const World& world) noexcept
{
    return world.GetContactRange();
}

std::vector<KeyedContactPtr> GetContacts(const World& world) noexcept
{
    return world.GetContacts();
}

const Contact& GetContact(const World& world, ContactID id)
{
    return world.GetContact(id);
}

void SetContact(World& world, ContactID id, const Contact& value)
{
    world.SetContact(id, value);
}

bool IsTouching(const World& world, ContactID id)
{
    return IsTouching(GetContact(world, id));
}

bool IsAwake(const World& world, ContactID id)
{
    return IsActive(GetContact(world, id));
}

void SetAwake(World& world, ContactID id)
{
    // Note awakening bodies wakens the contact.
    SetAwake(world, GetBodyA(world, id));
    SetAwake(world, GetBodyB(world, id));
}

ChildCounter GetChildIndexA(const World& world, ContactID id)
{
    return GetChildIndexA(GetContact(world, id));
}

ChildCounter GetChildIndexB(const World& world, ContactID id)
{
    return GetChildIndexB(GetContact(world, id));
}

ShapeID GetShapeA(const World& world, ContactID id)
{
    return GetShapeA(GetContact(world, id));
}

ShapeID GetShapeB(const World& world, ContactID id)
{
    return GetShapeB(GetContact(world, id));
}

BodyID GetBodyA(const World& world, ContactID id)
{
    return GetBodyA(GetContact(world, id));
}

BodyID GetBodyB(const World& world, ContactID id)
{
    return GetBodyB(GetContact(world, id));
}

TimestepIters GetToiCount(const World& world, ContactID id)
{
    return GetToiCount(GetContact(world, id));
}

bool NeedsFiltering(const World& world, ContactID id)
{
    return NeedsFiltering(GetContact(world, id));
}

bool NeedsUpdating(const World& world, ContactID id)
{
    return NeedsUpdating(GetContact(world, id));
}

bool HasValidToi(const World& world, ContactID id)
{
    return HasValidToi(GetContact(world, id));
}

Real GetToi(const World& world, ContactID id)
{
    return GetToi(GetContact(world, id));
}

Real GetFriction(const World& world, ContactID id)
{
    return GetFriction(GetContact(world, id));
}

Real GetRestitution(const World& world, ContactID id)
{
    return GetRestitution(GetContact(world, id));
}

void SetFriction(World& world, ContactID id, Real value)
{
    auto contact = GetContact(world, id);
    SetFriction(contact, value);
    SetContact(world, id, contact);
}

void SetRestitution(World& world, ContactID id, Real value)
{
    auto contact = GetContact(world, id);
    SetRestitution(contact, value);
    SetContact(world, id, contact);
}

const Manifold& GetManifold(const World& world, ContactID id)
{
    return world.GetManifold(id);
}

LinearVelocity GetTangentSpeed(const World& world, ContactID id)
{
    return GetTangentSpeed(GetContact(world, id));
}

void SetTangentSpeed(World& world, ContactID id, LinearVelocity value)
{
    auto contact = GetContact(world, id);
    SetTangentSpeed(contact, value);
    SetContact(world, id, contact);
}

bool IsEnabled(const World& world, ContactID id)
{
    return IsEnabled(GetContact(world, id));
}

void SetEnabled(World& world, ContactID id)
{
    auto contact = GetContact(world, id);
    SetEnabled(contact);
    SetContact(world, id, contact);
}

void UnsetEnabled(World& world, ContactID id)
{
    auto contact = GetContact(world, id);
    UnsetEnabled(contact);
    SetContact(world, id, contact);
}

Real GetDefaultFriction(const World& world, ContactID id)
{
    const auto& c = world.GetContact(id);
    return GetDefaultFriction(world.GetShape(GetShapeA(c)), world.GetShape(GetShapeB(c)));
}

Real GetDefaultRestitution(const World& world, ContactID id)
{
    const auto& c = world.GetContact(id);
    return GetDefaultRestitution(world.GetShape(GetShapeA(c)), world.GetShape(GetShapeB(c)));
}

WorldManifold GetWorldManifold(const World& world, ContactID id)
{
    return GetWorldManifold(world, GetContact(world, id), GetManifold(world, id));
}

ContactCounter GetTouchingCount(const World& world) noexcept
{
    const auto contacts = world.GetContacts();
    return static_cast<ContactCounter>(count_if(cbegin(contacts), cend(contacts),
                                                [&](const auto &c) {
        return IsTouching(world, std::get<ContactID>(c));
    }));
}

} // namespace d2
} // namespace playrho
