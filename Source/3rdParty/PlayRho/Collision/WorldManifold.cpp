/*
 * Original work Copyright (c) 2007-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include "PlayRho/Collision/WorldManifold.hpp"
#include "PlayRho/Collision/Manifold.hpp"
#include "PlayRho/Dynamics/Contacts/Contact.hpp"
#include "PlayRho/Dynamics/Body.hpp"
#include "PlayRho/Dynamics/Fixture.hpp"

namespace playrho {
namespace d2 {

namespace {

inline WorldManifold GetForCircles(const Manifold& manifold,
                                   const Transformation xfA, const Length radiusA,
                                   const Transformation xfB, const Length radiusB)
{
    assert(manifold.GetPointCount() == 1);

    const auto pointA = Transform(manifold.GetLocalPoint(), xfA);
    const auto pointB = Transform(manifold.GetPoint(0).localPoint, xfB);
    const auto normal = GetUnitVector(pointB - pointA, UnitVec::GetRight());
    const auto cA = pointA + (radiusA * normal);
    const auto cB = pointB - (radiusB * normal);
    const auto p0 = (cA + cB) / Real{2};
    const auto c0 = manifold.GetContactImpulses(0);
    const auto s0 = Dot(cB - cA, normal);
    return WorldManifold{normal, WorldManifold::PointData{p0, c0, s0}};
}

inline WorldManifold GetForFaceA(const Manifold& manifold,
                                 const Transformation xfA, const Length radiusA,
                                 const Transformation xfB, const Length radiusB)
{
    const auto normal = Rotate(manifold.GetLocalNormal(), xfA.q);
    const auto planePoint = Transform(manifold.GetLocalPoint(), xfA);
    const auto pointFn = [&](Manifold::size_type index) {
        const auto impulses = manifold.GetContactImpulses(index);
        const auto clipPoint = Transform(manifold.GetPoint(index).localPoint, xfB);
        const auto cA = clipPoint + (radiusA - Dot(clipPoint - planePoint, normal)) * normal;
        const auto cB = clipPoint - (radiusB * normal);
        return WorldManifold::PointData{(cA + cB) / Real{2}, impulses, Dot(cB - cA, normal)};
    };
    
    assert(manifold.GetPointCount() <= 2);
    
    switch (manifold.GetPointCount())
    {
        case 1: return WorldManifold{normal, pointFn(0)};
        case 2: return WorldManifold{normal, pointFn(0), pointFn(1)};
        default: break; // should never be reached
    }
    
    // should never be reached
    return WorldManifold{normal};
}

inline WorldManifold GetForFaceB(const Manifold& manifold,
                                 const Transformation xfA, const Length radiusA,
                                 const Transformation xfB, const Length radiusB)
{
    const auto normal = Rotate(manifold.GetLocalNormal(), xfB.q);
    const auto planePoint = Transform(manifold.GetLocalPoint(), xfB);
    const auto pointFn = [&](Manifold::size_type index) {
        const auto impulses = manifold.GetContactImpulses(index);
        const auto clipPoint = Transform(manifold.GetPoint(index).localPoint, xfA);
        const auto cB = clipPoint + (radiusB - Dot(clipPoint - planePoint, normal)) * normal;
        const auto cA = clipPoint - (radiusA * normal);
        return WorldManifold::PointData{(cA + cB) / Real{2}, impulses, Dot(cA - cB, normal)};
    };
    
    assert(manifold.GetPointCount() <= 2);
    
    // Negate normal given to world manifold constructor to ensure it points from A to B.
    switch (manifold.GetPointCount())
    {
        case 1: return WorldManifold{-normal, pointFn(0)};
        case 2: return WorldManifold{-normal, pointFn(0), pointFn(1)};
        default: break; // should never be reached
    }
    
    // should never be reached
    return WorldManifold{-normal};
}
    
} // anonymous namespace

WorldManifold GetWorldManifold(const Manifold& manifold,
                               Transformation xfA, Length radiusA,
                               Transformation xfB, Length radiusB)
{
    const auto type = manifold.GetType();

    assert((type == Manifold::e_circles) || (type == Manifold::e_faceA) ||
           (type == Manifold::e_faceB) || (type == Manifold::e_unset));
    
    switch (type)
    {
        case Manifold::e_circles: return GetForCircles(manifold, xfA, radiusA, xfB, radiusB);
        case Manifold::e_faceA: return GetForFaceA(manifold, xfA, radiusA, xfB, radiusB);
        case Manifold::e_faceB: return GetForFaceB(manifold, xfA, radiusA, xfB, radiusB);
        default: break;
    }
    
    // When type == Manifold::e_unset (or is an undefined value & NDEBUG is defined)...
    return WorldManifold{};
}

WorldManifold GetWorldManifold(const Contact& contact)
{
    const auto fA = contact.GetFixtureA();
    const auto iA = contact.GetChildIndexA();
    const auto xfA = GetTransformation(*fA);
    const auto radiusA = GetVertexRadius(fA->GetShape(), iA);

    const auto fB = contact.GetFixtureB();
    const auto iB = contact.GetChildIndexB();
    const auto xfB = GetTransformation(*fB);
    const auto radiusB = GetVertexRadius(fB->GetShape(), iB);

    return GetWorldManifold(contact.GetManifold(), xfA, radiusA, xfB, radiusB);
}

} /* namespace d2 */
} /* namespace playrho */
