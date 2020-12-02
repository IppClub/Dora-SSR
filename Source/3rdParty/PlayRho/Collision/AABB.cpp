/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#include "PlayRho/Collision/AABB.hpp"
#include "PlayRho/Collision/RayCastInput.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"
#include "PlayRho/Dynamics/Contacts/Contact.hpp"
#include "PlayRho/Dynamics/WorldFixture.hpp"
#include "PlayRho/Dynamics/WorldBody.hpp"

/// @file
/// Definitions for the AABB class.

namespace playrho {
namespace d2 {

AABB ComputeAABB(const DistanceProxy& proxy, const Transformation& xf) noexcept
{
    assert(IsValid(xf));
    auto result = AABB{};
    for (const auto& vertex: proxy.GetVertices())
    {
        Include(result, Transform(vertex, xf));
    }
    return GetFattenedAABB(result, proxy.GetVertexRadius());
}

AABB ComputeAABB(const DistanceProxy& proxy,
                 const Transformation& xfm0, const Transformation& xfm1) noexcept
{
    assert(IsValid(xfm0));
    assert(IsValid(xfm1));
    auto result = AABB{};
    for (const auto& vertex: proxy.GetVertices())
    {
        Include(result, Transform(vertex, xfm0));
        Include(result, Transform(vertex, xfm1));
    }
    return GetFattenedAABB(result, proxy.GetVertexRadius());
}

AABB ComputeAABB(const Shape& shape, const Transformation& xf) noexcept
{
    auto sum = AABB{};
    const auto childCount = GetChildCount(shape);
    for (auto i = decltype(childCount){0}; i < childCount; ++i)
    {
        Include(sum, ComputeAABB(GetChild(shape, i), xf));
    }
    return sum;
}

AABB ComputeAABB(const World& world, FixtureID id)
{
    return ComputeAABB(GetShape(world, id), GetTransformation(world, GetBody(world, id)));
}

AABB ComputeAABB(const World& world, BodyID id)
{
    auto sum = AABB{};
    const auto xf = GetTransformation(world, id);
    for (const auto& f: GetFixtures(world, id))
    {
        Include(sum, ComputeAABB(GetShape(world, f), xf));
    }
    return sum;
}

AABB ComputeIntersectingAABB(const World& world,
                             FixtureID fA, ChildCounter iA,
                             FixtureID fB, ChildCounter iB) noexcept
{
    const auto xA = GetTransformation(world, GetBody(world, fA));
    const auto xB = GetTransformation(world, GetBody(world, fB));
    const auto childA = GetChild(GetShape(world, fA), iA);
    const auto childB = GetChild(GetShape(world, fB), iB);
    const auto aabbA = ComputeAABB(childA, xA);
    const auto aabbB = ComputeAABB(childB, xB);
    return GetIntersectingAABB(aabbA, aabbB);
}

AABB ComputeIntersectingAABB(const World& world, const Contact& contact)
{
    return ComputeIntersectingAABB(world,
                                   contact.GetFixtureA(), contact.GetChildIndexA(),
                                   contact.GetFixtureB(), contact.GetChildIndexB());
}

AABB GetAABB(const RayCastInput& input) noexcept
{
    const auto totalDelta = input.p2 - input.p1;
    const auto fractDelta = input.maxFraction * totalDelta;
    return AABB{input.p1, input.p1 + fractDelta};
}

} // namespace d2
} // namespace playrho
