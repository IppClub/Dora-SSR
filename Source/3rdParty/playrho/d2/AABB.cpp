/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#include <cassert> // for assert

#include "playrho/BodyID.hpp"
#include "playrho/Contact.hpp"
#include "playrho/Settings.hpp" // for ChildCounter
#include "playrho/ShapeID.hpp"
#include "playrho/Templates.hpp" // for IsValid

#include "playrho/d2/AABB.hpp"
#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/Math.hpp"
#include "playrho/d2/RayCastInput.hpp"
#include "playrho/d2/Shape.hpp"
#include "playrho/d2/World.hpp"
#include "playrho/d2/WorldBody.hpp"
#include "playrho/d2/WorldShape.hpp"

namespace playrho::d2 {

AABB ComputeAABB(const DistanceProxy& proxy, const Transformation& xf) noexcept
{
    assert(IsValid(xf));
    auto result = AABB{};
    for (const auto& vertex : proxy.GetVertices()) {
        Include(result, Transform(vertex, xf));
    }
    return GetFattenedAABB(result, proxy.GetVertexRadius());
}

AABB ComputeAABB(const DistanceProxy& proxy, const Transformation& xfm0,
                 const Transformation& xfm1) noexcept
{
    assert(IsValid(xfm0));
    assert(IsValid(xfm1));
    auto result = AABB{};
    for (const auto& vertex : proxy.GetVertices()) {
        Include(result, Transform(vertex, xfm0));
        Include(result, Transform(vertex, xfm1));
    }
    return GetFattenedAABB(result, proxy.GetVertexRadius());
}

AABB ComputeAABB(const Shape& shape, const Transformation& xf)
{
    auto sum = AABB{};
    const auto childCount = GetChildCount(shape);
    for (auto i = decltype(childCount){0}; i < childCount; ++i) {
        Include(sum, ComputeAABB(GetChild(shape, i), xf));
    }
    return sum;
}

AABB ComputeAABB(const World& world, BodyID bodyID, ShapeID shapeID)
{
    return ComputeAABB(GetShape(world, shapeID), GetTransformation(world, bodyID));
}

AABB ComputeAABB(const World& world, BodyID id)
{
    auto sum = AABB{};
    const auto xf = GetTransformation(world, id);
    for (const auto& shapeId : GetShapes(world, id)) {
        Include(sum, ComputeAABB(GetShape(world, shapeId), xf));
    }
    return sum;
}

AABB ComputeIntersectingAABB(const World& world, // force newline
                             BodyID bA, ShapeID sA, ChildCounter iA, // force newline
                             BodyID bB, ShapeID sB, ChildCounter iB)
{
    const auto shapeA = GetShape(world, sA); // extends shape's lifetime for GetChild
    const auto shapeB = GetShape(world, sB); // extends shape's lifetime for GetChild
    const auto aabbA = ComputeAABB(GetChild(shapeA, iA), GetTransformation(world, bA));
    const auto aabbB = ComputeAABB(GetChild(shapeB, iB), GetTransformation(world, bB));
    return GetIntersectingAABB(aabbA, aabbB);
}

AABB ComputeIntersectingAABB(const World& world, const Contact& c)
{
    return ComputeIntersectingAABB(world, // force newline
                                   GetBodyA(c), GetShapeA(c), GetChildIndexA(c), // force newline
                                   GetBodyB(c), GetShapeB(c), GetChildIndexB(c));
}

AABB GetAABB(const RayCastInput& input) noexcept
{
    const auto totalDelta = input.p2 - input.p1;
    const auto fractDelta = input.maxFraction * totalDelta;
    return AABB{input.p1, input.p1 + fractDelta};
}

} // namespace playrho::d2
