/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Collision/ShapeSeparation.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include <algorithm>

namespace playrho {
namespace d2 {

namespace {

/// @brief Gets the minimum separation information for the given vertices from the given
///  origin in the given direction.
/// @param direction Directional normal for face on first convex shape starting from origin.
/// @param origin Vertex from first convex shape from which the face normal originates.
/// @param vertices Vertices from second convex shape.
/// @return Minimum separation and index or indices of the vertex or edge respectively
///   for which that's found.
LengthIndices GetMinSeparationInfo(Length2 origin, UnitVec direction,
                                   Range<DistanceProxy::ConstVertexIterator> vertices)
{
    // Search for vertices most anti-parallel to directional normal from origin.
    // See: https://en.wikipedia.org/wiki/Antiparallel_(mathematics)#Antiparallel_vectors
    auto minSeparation = std::numeric_limits<Length>::infinity();
    auto first = InvalidVertex;
    auto second = InvalidVertex;
    auto i = VertexCounter{0};
    for (const auto& vertex: vertices)
    {
        const auto s = Dot(direction, vertex - origin);
        if (minSeparation > s)
        {
            // most anti-parallel so far is a vertex
            minSeparation = s;
            first = i;
            second = InvalidVertex;
        }
        else if (minSeparation == s)
        {
            // most anti-parallel so far is an edge
            second = i;
        }
        ++i;
    }
    return LengthIndices{minSeparation, {{first, second}}};
}

} // anonymous namespace

SeparationInfo GetMaxSeparation4x4(const DistanceProxy& proxy1, Transformation xf1,
                                   const DistanceProxy& proxy2, Transformation xf2)
{
    // Find the max separation between proxy1 and proxy2 using edge normals from proxy1.
    auto separation = -std::numeric_limits<Length>::infinity();
    auto firstIndex = InvalidVertex;
    auto secondIndices = VertexCounter2{{InvalidVertex, InvalidVertex}};
#if 1
    const auto xf = MulT(xf1, xf2);
    const Length2 p2vertices[4] = {
        Transform(proxy2.GetVertex(0), xf),
        Transform(proxy2.GetVertex(1), xf),
        Transform(proxy2.GetVertex(2), xf),
        Transform(proxy2.GetVertex(3), xf),
    };
    const auto vertices = Range<DistanceProxy::ConstVertexIterator>(p2vertices, p2vertices + 4);
#else
    const auto xf = MulT(xf2, xf1);
    const auto vertices = proxy2.GetVertices();
#endif
    for (auto i = VertexCounter{0}; i < VertexCounter{4}; ++i)
    {
        // Get proxy1 normal and vertex relative to proxy2.
#if 1
        const auto origin = proxy1.GetVertex(i);
        const auto normal = proxy1.GetNormal(i);
        const auto ap = GetMinSeparationInfo(origin, normal, vertices);
#else
        const auto origin = Transform(proxy1.GetVertex(i), xf);
        const auto normal = Rotate(proxy1.GetNormal(i), xf.q);
        const auto ap = GetMinIndexSeparation(origin, normal, vertices);
#endif
        if (separation < ap.distance)
        {
            separation = ap.distance;
            secondIndices = ap.indices;
            firstIndex = i;
        }
    }
    return SeparationInfo{separation, firstIndex, secondIndices};
}

SeparationInfo GetMaxSeparation(const DistanceProxy& proxy1, Transformation xf1,
                                const DistanceProxy& proxy2, Transformation xf2)
{
    // Find the max separation between proxy1 and proxy2 using edge normals from proxy1.
    auto separation = -std::numeric_limits<Length>::infinity();
    auto firstIndex = InvalidVertex;
    auto secondIndices = VertexCounter2{{InvalidVertex, InvalidVertex}};
    const auto count1 = proxy1.GetVertexCount();
    const auto xf = MulT(xf2, xf1);
    const auto proxy2vertices = proxy2.GetVertices();
    for (auto i = VertexCounter{0}; i < count1; ++i)
    {
        // Get proxy1 normal and vertex relative to proxy2.
        const auto origin = Transform(proxy1.GetVertex(i), xf);
        const auto normal = Rotate(proxy1.GetNormal(i), xf.q);
        const auto ap = GetMinSeparationInfo(origin, normal, proxy2vertices);
        if (separation < ap.distance)
        {
            separation = ap.distance;
            secondIndices = ap.indices;
            firstIndex = i;
        }
    }
    return SeparationInfo{separation, firstIndex, secondIndices};
}

SeparationInfo GetMaxSeparation(const DistanceProxy& proxy1, Transformation xf1,
                                const DistanceProxy& proxy2, Transformation xf2,
                                Length stop)
{
    // Find the max separation between proxy1 and proxy2 using edge normals from proxy1.
    auto separation = -std::numeric_limits<Length>::infinity();
    auto firstIndex = InvalidVertex;
    auto secondIndices = VertexCounter2{{InvalidVertex, InvalidVertex}};
    const auto xf = MulT(xf2, xf1);
    const auto count1 = proxy1.GetVertexCount();
    for (auto i = VertexCounter{0}; i < count1; ++i)
    {
        // Get proxy1 normal and vertex relative to proxy2.
        const auto origin = Transform(proxy1.GetVertex(i), xf);
        const auto normal = Rotate(proxy1.GetNormal(i), xf.q);
        const auto ap = GetMinSeparationInfo(origin, normal, proxy2.GetVertices());
        if (stop < ap.distance)
        {
            return SeparationInfo{ap.distance, i, ap.indices};
        }
        if (separation < ap.distance)
        {
            separation = ap.distance;
            secondIndices = ap.indices;
            firstIndex = i;
        }
    }
    return SeparationInfo{separation, firstIndex, secondIndices};
}

SeparationInfo GetMaxSeparation(const DistanceProxy& proxy1, const DistanceProxy& proxy2,
                                Length stop)
{
    // Find the max separation between proxy1 and proxy2 using edge normals from proxy1.
    auto separation = -std::numeric_limits<Length>::infinity();
    auto firstIndex = InvalidVertex;
    auto secondIndices = VertexCounter2{{InvalidVertex, InvalidVertex}};
    const auto count1 = proxy1.GetVertexCount();
    for (auto i = decltype(count1){0}; i < count1; ++i)
    {
        // Get proxy1 normal and vertex relative to proxy2.
        const auto origin = proxy1.GetVertex(i);
        const auto normal = proxy1.GetNormal(i);
        const auto ap = GetMinSeparationInfo(origin, normal, proxy2.GetVertices());
        if (stop < ap.distance)
        {
            return SeparationInfo{ap.distance, i, ap.indices};
        }
        if (separation < ap.distance)
        {
            separation = ap.distance;
            secondIndices = ap.indices;
            firstIndex = i;
        }
    }
    return SeparationInfo{separation, firstIndex, secondIndices};
}
    
} // namespace d2
} // namespace playrho
