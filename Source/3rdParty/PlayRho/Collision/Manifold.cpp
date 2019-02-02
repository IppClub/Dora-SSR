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

#include "PlayRho/Collision/Manifold.hpp"
#include "PlayRho/Collision/Simplex.hpp"
#include "PlayRho/Collision/Distance.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/Collision.hpp"
#include "PlayRho/Collision/ShapeSeparation.hpp"
#include "PlayRho/Defines.hpp"

#include <array>
#include <bitset>
#include <algorithm>

#define PLAYRHO_MAGIC(x) (x)

namespace playrho {
namespace d2 {

namespace {

#ifdef DEFINE_GET_MANIFOLD
inline index_type GetEdgeIndex(VertexCounter i1, VertexCounter i2, VertexCounter count)
{
    if (GetModuloNext(i1, count) == i2)
    {
        return i1;
    }
    if (GetModuloNext(i2, count) == i1)
    {
        return i2;
    }
    return InvalidVertex;
}
#endif

using VertexCounterPair = std::pair<VertexCounter, VertexCounter>;
    
VertexCounterPair
GetMostAntiParallelEdge(UnitVec shape0_rel_n0, const Transformation& xf0,
                        const DistanceProxy& shape1, const Transformation& xf1,
                        const VertexCounter2 indices1) noexcept
{
    const auto firstIdx = std::get<0>(indices1);
    const auto secondIdx = std::get<1>(indices1);
    if (secondIdx == InvalidVertex)
    {
        // Gets most anti-parallel edge of either prevIdx or firstIdx.
        const auto normal = InverseRotate(Rotate(shape0_rel_n0, xf0.q), xf1.q);
        const auto count = shape1.GetVertexCount();
        const auto prevIdx = GetModuloPrev(firstIdx, count);
        const auto prevDot = Dot(normal, shape1.GetNormal(prevIdx));
        const auto currDot = Dot(normal, shape1.GetNormal(firstIdx));
        return (prevDot < currDot)?
            std::make_pair(prevIdx, firstIdx):
            std::make_pair(firstIdx, GetModuloNext(firstIdx, count));
    }
    return ((secondIdx > firstIdx) && ((firstIdx + 1) == secondIdx))?
        std::make_pair(firstIdx, secondIdx): std::make_pair(secondIdx, firstIdx);
}

ClipList GetClipPoints(Length2 shape0_abs_v0, Length2 shape0_abs_v1, VertexCounterPair shape0_e,
                       UnitVec shape0_abs_e0_dir,
                       Length2 shape1_abs_v0, Length2 shape1_abs_v1, VertexCounterPair shape1_e)
{
    // Gets the two vertices in world coordinates and their face-vertex contact features
    // of the incident edge of shape1
    const auto ie = ClipList{
        ClipVertex{shape1_abs_v0, GetFaceVertexContactFeature(shape0_e.first, shape1_e.first)},
        ClipVertex{shape1_abs_v1, GetFaceVertexContactFeature(shape0_e.first, shape1_e.second)}
    };
    const auto shape0_dp_v0_e0 = -Dot(shape0_abs_e0_dir, shape0_abs_v0);
    const auto shape0_dp_v1_e0 = +Dot(shape0_abs_e0_dir, shape0_abs_v1);

    const auto points = ClipSegmentToLine(ie, -shape0_abs_e0_dir, shape0_dp_v0_e0, shape0_e.first);
    return ClipSegmentToLine(points, +shape0_abs_e0_dir, shape0_dp_v1_e0, shape0_e.second);
}

} // anonymous namespace

Manifold GetManifold(bool flipped,
                     const DistanceProxy& shape0, const Transformation& xf0,
                     const VertexCounter idx0,
                     const DistanceProxy& shape1, const Transformation& xf1,
                     const VertexCounter2 indices1,
                     const Manifold::Conf conf)
{
    assert(shape0.GetVertexCount() > 1 && shape1.GetVertexCount() > 1);
    
    const auto r0 = shape0.GetVertexRadius();
    const auto r1 = shape1.GetVertexRadius();
    const auto totalRadius = Length{r0 + r1};
    
    const auto idx0Next = GetModuloNext(idx0, shape0.GetVertexCount());
    
    const auto shape0_rel_v0 = shape0.GetVertex(idx0);
    const auto shape0_rel_v1 = shape0.GetVertex(idx0Next);
    const auto shape0_abs_v0 = Transform(shape0_rel_v0, xf0);
    const auto shape0_abs_v1 = Transform(shape0_rel_v1, xf0);
    
    auto shape0_len_edge0 = GetMagnitudeSquared(shape0_rel_v1 - shape0_rel_v0);

    // Clip incident edge against extruded edge1 side edges.
    // Side offsets, extended by polytope skin thickness.
    
    const auto shape0_rel_n0 = shape0.GetNormal(idx0);
    const auto shape0_rel_e0_dir = GetRevPerpendicular(shape0_rel_n0);
    const auto shape1_e = GetMostAntiParallelEdge(shape0_rel_n0, xf0, shape1, xf1, indices1);
    const auto shape1_rel_v0 = shape1.GetVertex(shape1_e.first);
    const auto shape1_abs_v0 = Transform(shape1_rel_v0, xf1);
    const auto shape1_rel_v1 = shape1.GetVertex(shape1_e.second);
    const auto shape1_abs_v1 = Transform(shape1_rel_v1, xf1);
    {
        const auto shape0_abs_e0_dir = Rotate(shape0_rel_e0_dir, xf0.q);
        const auto clipPoints = GetClipPoints(shape0_abs_v0, shape0_abs_v1, std::make_pair(idx0, idx0Next),
                                              shape0_abs_e0_dir,
                                              shape1_abs_v0, shape1_abs_v1, shape1_e);
        if (size(clipPoints) == 2)
        {
            const auto abs_normal = GetFwdPerpendicular(shape0_abs_e0_dir);
            const auto rel_midpoint = (shape0_rel_v0 + shape0_rel_v1) / 2;
            const auto abs_offset = Dot(abs_normal, shape0_abs_v0); ///< Face offset.
            
            auto manifold = Manifold{};
            if (!flipped)
            {
                manifold = Manifold::GetForFaceA(GetFwdPerpendicular(shape0_rel_e0_dir), rel_midpoint);
                for (auto&& cp: clipPoints)
                {
                    if ((Dot(abs_normal, cp.v) - abs_offset) <= totalRadius)
                    {
                        manifold.AddPoint(Manifold::Point{InverseTransform(cp.v, xf1), cp.cf});
                    }
                }
            }
            else
            {
                manifold = Manifold::GetForFaceB(GetFwdPerpendicular(shape0_rel_e0_dir), rel_midpoint);
                for (auto&& cp: clipPoints)
                {
                    if ((Dot(abs_normal, cp.v) - abs_offset) <= totalRadius)
                    {
                        manifold.AddPoint(Manifold::Point{InverseTransform(cp.v, xf1), Flip(cp.cf)});
                    }
                }
            }
            if (manifold.GetPointCount() > 0)
            {
                return manifold;
            }
        }
    }
    
    // If the shapes are colliding, then they're colliding with each others corners.
    // Using a circles manifold, means these corners will repell each other with a normal
    // that's in the direction between the two vertices.
    // That's problematic though for things like polygons sliding over edges where a face
    // manifold that favors the primary edge can work better.
    // Use a threshold against the ratio of the square of the vertex radius to the square
    // of the length of the primary edge to determine whether to return a circles manifold
    // or a face manifold.
    const auto totalRadiusSquared = Square(totalRadius);
    const auto mustUseFaceManifold = shape0_len_edge0 > Square(conf.maxCirclesRatio * r0);
    if (GetMagnitudeSquared(shape0_abs_v0 - shape1_abs_v0) <= totalRadiusSquared)
    {
        // shape 1 vertex 1 is colliding with shape 2 vertex 1
        // shape 1 vertex 1 is the vertex at index idx0, or one before idx0Next.
        // shape 2 vertex 1 is the vertex at index shape1_e.first, or one before shape1_e.second.
        if (!flipped) // face A
        {
            // shape 1 is shape A.
            if (mustUseFaceManifold)
            {
                return Manifold::GetForFaceA(GetFwdPerpendicular(shape0_rel_e0_dir), idx0,
                                             shape0_rel_v0, ContactFeature::e_vertex,
                                             shape1_e.first, shape1_rel_v0);
            }
            return Manifold::GetForCircles(shape0_rel_v0, idx0, shape1_rel_v0, shape1_e.first);
        }
        // shape 2 is shape A.
        if (mustUseFaceManifold)
        {
            return Manifold::GetForFaceB(GetFwdPerpendicular(shape0_rel_e0_dir), idx0,
                                         shape0_rel_v0, ContactFeature::e_vertex,
                                         shape1_e.first, shape1_rel_v0);
        }
        return Manifold::GetForCircles(shape1_rel_v0, shape1_e.first, shape0_rel_v0, idx0);
    }
    else if (GetMagnitudeSquared(shape0_abs_v0 - shape1_abs_v1) <= totalRadiusSquared)
    {
        // shape 1 vertex 1 is colliding with shape 2 vertex 2
        if (!flipped)
        {
            if (mustUseFaceManifold)
            {
                return Manifold::GetForFaceA(GetFwdPerpendicular(shape0_rel_e0_dir), idx0,
                                             shape0_rel_v0, ContactFeature::e_vertex,
                                             shape1_e.second, shape1_rel_v1);
            }
            return Manifold::GetForCircles(shape0_rel_v0, idx0, shape1_rel_v1, shape1_e.second);
        }
        if (mustUseFaceManifold)
        {
            return Manifold::GetForFaceB(GetFwdPerpendicular(shape0_rel_e0_dir), idx0,
                                         shape0_rel_v0, ContactFeature::e_vertex,
                                         shape1_e.second, shape1_rel_v1);
        }
        return Manifold::GetForCircles(shape1_rel_v1, shape1_e.second, shape0_rel_v0, idx0);
    }
    else if (GetMagnitudeSquared(shape0_abs_v1 - shape1_abs_v1) <= totalRadiusSquared)
    {
        // shape 1 vertex 2 is colliding with shape 2 vertex 2
        if (!flipped)
        {
            if (mustUseFaceManifold)
            {
                return Manifold::GetForFaceA(GetFwdPerpendicular(shape0_rel_e0_dir), idx0Next,
                                             shape0_rel_v1, ContactFeature::e_vertex,
                                             shape1_e.second, shape1_rel_v1);
            }
            return Manifold::GetForCircles(shape0_rel_v1, idx0Next, shape1_rel_v1, shape1_e.second);
        }
        if (mustUseFaceManifold)
        {
            return Manifold::GetForFaceB(GetFwdPerpendicular(shape0_rel_e0_dir), idx0Next,
                                         shape0_rel_v1, ContactFeature::e_vertex,
                                         shape1_e.second, shape1_rel_v1);
        }
        return Manifold::GetForCircles(shape1_rel_v1, shape1_e.second, shape0_rel_v1, idx0Next);
    }
    else if (GetMagnitudeSquared(shape0_abs_v1 - shape1_abs_v0) <= totalRadiusSquared)
    {
        // shape 1 vertex 2 is colliding with shape 2 vertex 1
        if (!flipped)
        {
            if (mustUseFaceManifold)
            {
                return Manifold::GetForFaceA(GetFwdPerpendicular(shape0_rel_e0_dir), idx0Next,
                                             shape0_rel_v1, ContactFeature::e_vertex,
                                             shape1_e.first, shape1_rel_v0);
            }
            return Manifold::GetForCircles(shape0_rel_v1, idx0Next, shape1_rel_v0, shape1_e.first);
        }
        if (mustUseFaceManifold)
        {
            return Manifold::GetForFaceB(GetFwdPerpendicular(shape0_rel_e0_dir), idx0Next,
                                         shape0_rel_v1, ContactFeature::e_vertex,
                                         shape1_e.first, shape1_rel_v0);
        }
        return Manifold::GetForCircles(shape1_rel_v0, shape1_e.first, shape0_rel_v1, idx0Next);
    }
    return Manifold{};
}

Manifold GetManifold(bool flipped, Length totalRadius,
                     const DistanceProxy& shape, const Transformation& sxf,
                     Length2 point, const Transformation& xfm)
{
    // Computes the center of the circle in the frame of the polygon.
    const auto cLocal = InverseTransform(Transform(point, xfm), sxf); ///< Center of circle in frame of polygon.
    
    const auto vertexCount = shape.GetVertexCount();
    
    // Find edge that circle is closest to.
    auto indexOfMax = decltype(vertexCount){0};
    auto maxSeparation = -MaxFloat * Meter;
    {
        for (auto i = decltype(vertexCount){0}; i < vertexCount; ++i)
        {
            // Get circle's distance from vertex[i] in direction of normal[i].
            const auto s = Dot(shape.GetNormal(i), cLocal - shape.GetVertex(i));
            if (s > totalRadius)
            {
                // Early out - no contact.
                return Manifold{};
            }
            if (maxSeparation < s)
            {
                maxSeparation = s;
                indexOfMax = i;
            }
        }
    }
    const auto indexOfMax2 = GetModuloNext(indexOfMax, vertexCount);
    assert(maxSeparation <= totalRadius);
    
    // Vertices that subtend the incident face.
    const auto v1 = shape.GetVertex(indexOfMax);
    const auto v2 = shape.GetVertex(indexOfMax2);
    
    if (maxSeparation < 0_m)
    {
        const auto faceCenter = (v1 + v2) / Real{2};
        // Circle's center is inside the polygon and closest to edge[indexOfMax].
        if (!flipped)
        {
            return Manifold::GetForFaceA(shape.GetNormal(indexOfMax), indexOfMax, faceCenter,
                                         ContactFeature::e_vertex, 0, point);
        }
        return Manifold::GetForFaceB(shape.GetNormal(indexOfMax), indexOfMax, faceCenter,
                                     ContactFeature::e_vertex, 0, point);
    }
    
    // Circle's center is outside polygon and closest to edge[indexOfMax].
    // Compute barycentric coordinates.
    
    const auto cLocalV1 = cLocal - v1;
    if (Dot(cLocalV1, v2 - v1) <= 0_m2)
    {
        // Circle's center right of v1 (in direction of v1 to v2).
        if (GetMagnitudeSquared(cLocalV1) > Square(totalRadius))
        {
            return Manifold{};
        }
        if (!flipped)
        {
            return Manifold::GetForCircles(v1, indexOfMax, point, 0);
        }
        return Manifold::GetForCircles(point, 0, v1, indexOfMax);
    }
    
    const auto ClocalV2 = cLocal - v2;
    if (Dot(ClocalV2, v1 - v2) <= 0_m2)
    {
        // Circle's center left of v2 (in direction of v2 to v1).
        if (GetMagnitudeSquared(ClocalV2) > Square(totalRadius))
        {
            return Manifold{};
        }
        if (!flipped)
        {
            return Manifold::GetForCircles(v2, indexOfMax2, point, 0);
        }
        return Manifold::GetForCircles(point, 0, v2, indexOfMax2);
    }
    
    // Circle's center is between v1 and v2.
    const auto faceCenter = (v1 + v2) / Real{2};
    if (Dot(cLocal - faceCenter, shape.GetNormal(indexOfMax)) > totalRadius)
    {
        return Manifold{};
    }
    if (!flipped)
    {
        return Manifold::GetForFaceA(shape.GetNormal(indexOfMax), indexOfMax, faceCenter,
                                     ContactFeature::e_vertex, 0, point);
    }
    return Manifold::GetForFaceB(shape.GetNormal(indexOfMax), indexOfMax, faceCenter,
                                 ContactFeature::e_vertex, 0, point);
}

Manifold GetManifold(Length2 locationA, const Transformation& xfA,
                     Length2 locationB, const Transformation& xfB,
                     Length totalRadius) noexcept
{
    const auto pA = Transform(locationA, xfA);
    const auto pB = Transform(locationB, xfB);
    // Intermediary results here for debugging...
    const auto lenSq = GetMagnitudeSquared(pB - pA);
    const auto totSq = Square(totalRadius);
    return (lenSq > totSq)? Manifold{}: Manifold::GetForCircles(locationA, 0, locationB, 0);
}

/*
 * Definition of public CollideShapes functions.
 * All CollideShapes functions return a Manifold object.
 */

Manifold CollideShapes(const DistanceProxy& shapeA, const Transformation& xfA,
                       const DistanceProxy& shapeB, const Transformation& xfB,
                       Manifold::Conf conf)
{
    // Assumes called after detecting AABB overlap.
    // Find edge normal of max separation on A - return if separating axis is found
    // Find edge normal of max separation on B - return if separation axis is found
    // Choose reference edge as min(minA, minB)
    // Find incident edge
    // Clip
    
    const auto totalRadius = shapeA.GetVertexRadius() + shapeB.GetVertexRadius();
    const auto countA = shapeA.GetVertexCount();
    const auto countB = shapeB.GetVertexCount();
    
    enum: unsigned { ZeroOneVert = 0x0u, OneVertA = 0x1u, OneVertB = 0x2u };
    switch (((countA == 1)? OneVertA: ZeroOneVert) | ((countB == 1)? OneVertB: ZeroOneVert))
    {
        case OneVertA|OneVertB:
            return GetManifold(shapeA.GetVertex(0), xfA, shapeB.GetVertex(0), xfB, totalRadius);
        case OneVertA:
            return GetManifold(true, totalRadius, shapeB, xfB, shapeA.GetVertex(0), xfA);
        case OneVertB:
            return GetManifold(false, totalRadius, shapeA, xfA, shapeB.GetVertex(0), xfB);
    }
    
    const auto do4x4 = (countA == 4) && (countB == 4);
    
    const auto edgeSepA = do4x4?
        GetMaxSeparation4x4(shapeA, xfA, shapeB, xfB):
        GetMaxSeparation(shapeA, xfA, shapeB, xfB);
    if (edgeSepA.distance > totalRadius)
    {
        return Manifold{};
    }
    
    const auto edgeSepB = do4x4?
        GetMaxSeparation4x4(shapeB, xfB, shapeA, xfA):
        GetMaxSeparation(shapeB, xfB, shapeA, xfA);
    if (edgeSepB.distance > totalRadius)
    {
        return Manifold{};
    }
    
    const auto k_tol = PLAYRHO_MAGIC(conf.linearSlop / 10);
    return (edgeSepB.distance > (edgeSepA.distance + k_tol))?
        GetManifold(true,
                        shapeB, xfB, edgeSepB.firstShape,
                        shapeA, xfA, edgeSepB.secondShape,
                        conf):
        GetManifold(false,
                        shapeA, xfA, edgeSepA.firstShape,
                        shapeB, xfB, edgeSepA.secondShape,
                        conf);
}

#if 0
Manifold CollideCached(const DistanceProxy& shapeA, const Transformation& xfA,
                              const DistanceProxy& shapeB, const Transformation& xfB,
                              Manifold::Conf conf)
{
    // Find edge normal of max separation on A - return if separating axis is found
    // Find edge normal of max separation on B - return if separation axis is found
    // Choose reference edge as min(minA, minB)
    // Find incident edge
    // Clip
    
    const auto vertexCountShapeA = shapeA.GetVertexCount();
    const auto vertexCountShapeB = shapeB.GetVertexCount();
    if (vertexCountShapeA == 1)
    {
        if (vertexCountShapeB > 1)
        {
            return CollideShapes(Manifold::e_faceB, shapeB, xfB,
                                   shapeA.GetVertex(0), shapeA.GetVertexRadius(), xfA);
        }
        return CollideShapes(shapeA.GetVertex(0), shapeA.GetVertexRadius(), xfA,
                               shapeB.GetVertex(0), shapeB.GetVertexRadius(), xfB);
    }
    if (vertexCountShapeB == 1)
    {
        if (vertexCountShapeA > 1)
        {
            return CollideShapes(Manifold::e_faceA, shapeA, xfA,
                                   shapeB.GetVertex(0), shapeB.GetVertexRadius(), xfB);
        }
        return CollideShapes(shapeA.GetVertex(0), shapeA.GetVertexRadius(), xfA,
                               shapeB.GetVertex(0), shapeB.GetVertexRadius(), xfB);
    }

    const auto totalRadius = shapeA.GetVertexRadius() + shapeB.GetVertexRadius();

    IndexPairSeparation edgeSepA;
    IndexPairSeparation edgeSepB;

    if (vertexCountShapeA == 4 && vertexCountShapeB == 4)
    {
        Length2 verticesA[4];
        Length2 verticesB[4];
        UnitVec normalsA[4];
        UnitVec normalsB[4];
        
        verticesA[0] = Transform(shapeA.GetVertex(0), xfA);
        verticesA[1] = Transform(shapeA.GetVertex(1), xfA);
        verticesA[2] = Transform(shapeA.GetVertex(2), xfA);
        verticesA[3] = Transform(shapeA.GetVertex(3), xfA);
        
        normalsA[0] = Rotate(shapeA.GetNormal(0), xfA.q);
        normalsA[1] = Rotate(shapeA.GetNormal(1), xfA.q);
        normalsA[2] = Rotate(shapeA.GetNormal(2), xfA.q);
        normalsA[3] = Rotate(shapeA.GetNormal(3), xfA.q);

        verticesB[0] = Transform(shapeB.GetVertex(0), xfB);
        verticesB[1] = Transform(shapeB.GetVertex(1), xfB);
        verticesB[2] = Transform(shapeB.GetVertex(2), xfB);
        verticesB[3] = Transform(shapeB.GetVertex(3), xfB);

        normalsB[0] = Rotate(shapeB.GetNormal(0), xfB.q);
        normalsB[1] = Rotate(shapeB.GetNormal(1), xfB.q);
        normalsB[2] = Rotate(shapeB.GetNormal(2), xfB.q);
        normalsB[3] = Rotate(shapeB.GetNormal(3), xfB.q);
        
        const auto dpA = DistanceProxy{shapeA.GetVertexRadius(), vertexCountShapeA, verticesA, normalsA};
        const auto dpB = DistanceProxy{shapeB.GetVertexRadius(), vertexCountShapeB, verticesB, normalsB};
        edgeSepA = GetMaxSeparation(dpA, dpB, totalRadius);
        if (edgeSepA.separation > totalRadius)
        {
            return Manifold{};
        }
        edgeSepB = GetMaxSeparation(dpB, dpA, totalRadius);
        if (edgeSepB.separation > totalRadius)
        {
            return Manifold{};
        }
    }
    else
    {
        edgeSepA = GetMaxSeparation(shapeA, xfA, shapeB, xfB, totalRadius);
        if (edgeSepA.separation > totalRadius)
        {
            return Manifold{};
        }
        edgeSepB = GetMaxSeparation(shapeB, xfB, shapeA, xfA, totalRadius);
        if (edgeSepB.separation > totalRadius)
        {
            return Manifold{};
        }
    }
    
    PLAYRHO_CONSTEXPR const auto k_tol = PLAYRHO_MAGIC(DefaultLinearSlop / Real{10});
    return (edgeSepB.separation > (edgeSepA.separation + k_tol))?
    GetManifold(Manifold::e_faceB,
                shapeB, xfB, edgeSepB.index1,
                shapeA, xfA, edgeSepB.index2,
                conf):
    GetManifold(Manifold::e_faceA,
                shapeA, xfA, edgeSepA.index1,
                shapeB, xfB, edgeSepA.index2,
                conf);
}
#endif

#ifdef DEFINE_GET_MANIFOLD
Manifold GetManifold(const DistanceProxy& proxyA, const Transformation& transformA,
                     const DistanceProxy& proxyB, const Transformation& transformB)
{
    const auto distanceInfo = Distance(proxyA, transformA, proxyB, transformB);
    const auto totalRadius = proxyA.GetVertexRadius() + proxyB.GetVertexRadius();
    const auto witnessPoints = GetWitnessPoints(distanceInfo.simplex);

    const auto distance = sqrt(GetMagnitudeSquared(witnessPoints.a - witnessPoints.b));
    if (distance > totalRadius)
    {
        // no collision
        return Manifold{};
    }

    const auto a_count = proxyA.GetVertexCount();
    const auto b_count = proxyB.GetVertexCount();

    index_type a_indices_array[Simplex::MaxEdges];
    index_type b_indices_array[Simplex::MaxEdges];
    auto uniqA = std::size_t{0};
    auto uniqB = std::size_t{0};
    {
        std::bitset<MaxShapeVertices> a_indices_set;
        std::bitset<MaxShapeVertices> b_indices_set;
        for (auto&& e: distanceInfo.simplex.GetEdges())
        {
            const auto indexA = e.GetIndexA();
            if (!a_indices_set[indexA])
            {
                a_indices_set[indexA] = true;
                a_indices_array[uniqA] = indexA;
                ++uniqA;
            }
            const auto indexB = e.GetIndexB();
            if (!b_indices_set[indexB])
            {
                b_indices_set[indexB] = true;
                b_indices_array[uniqB] = indexB;
                ++uniqB;
            }
        }
    }

    assert(uniqA > 0 && uniqB > 0);

    std::sort(a_indices_array, a_indices_array + uniqA);
    std::sort(b_indices_array, b_indices_array + uniqB);

    if (uniqA < uniqB)
    {
        switch (uniqA)
        {
            case 1: // uniqB must be 2 or 3
            {
                const auto b_idx0 = GetEdgeIndex(b_indices_array[0], b_indices_array[1], b_count);
                assert(b_idx0 != InvalidVertex);
                const auto b_idx1 = GetModuloNext(b_idx0, b_count);
                const auto b_v0 = proxyB.GetVertex(b_idx0);
                const auto b_v1 = proxyB.GetVertex(b_idx1);
                const auto lp = (b_v0 + b_v1) / Real{2};
                const auto ln = GetFwdPerpendicular(GetUnitVector(b_v1 - b_v0));
                const auto mp0 = Manifold::Point{
                    proxyA.GetVertex(a_indices_array[0]),
                    ContactFeature{
                        ContactFeature::e_vertex,
                        a_indices_array[0],
                        ContactFeature::e_face,
                        b_idx0,
                    }
                };
                return Manifold::GetForFaceB(ln, lp, mp0);
            }
            case 2: // uniqB must be 3
            {
                auto mp0 = Manifold::Point{};
                auto mp1 = Manifold::Point{};
                mp0.contactFeature.typeA = ContactFeature::e_face;
                mp1.contactFeature.typeA = ContactFeature::e_face;
                const auto v0 = proxyA.GetVertex(a_indices_array[0]);
                const auto v1 = proxyA.GetVertex(a_indices_array[1]);
                const auto lp = (v0 + v1) / Real{2};
                const auto count = proxyA.GetVertexCount();
                if ((a_indices_array[1] - a_indices_array[0]) == 1)
                {
                    mp0.contactFeature.indexA = a_indices_array[0];
                    mp1.contactFeature.indexA = a_indices_array[0];
                    const auto ln = GetFwdPerpendicular(GetUnitVector(v1 - v0));
                    return Manifold::GetForFaceA(ln, lp, mp0, mp1);
                }
                else if (GetModuloNext(a_indices_array[1], count) == a_indices_array[0])
                {
                    mp0.contactFeature.indexA = a_indices_array[1];
                    mp1.contactFeature.indexA = a_indices_array[1];
                    const auto ln = GetFwdPerpendicular(GetUnitVector(v0 - v1));
                    return Manifold::GetForFaceA(ln, lp, mp0, mp1);
                }
                else
                {
                    //assert(false);
                }
                return Manifold{};
            }
            default:
                break;
        }
    }
    else if (uniqB < uniqA)
    {
        switch (uniqB)
        {
            case 1: // uniqA must be 2 or 3
            {
                const auto a_idx0 = GetEdgeIndex(a_indices_array[0],a_indices_array[1], a_count);
                assert(a_idx0 != InvalidVertex);
                const auto a_idx1 = GetModuloNext(a_idx0, a_count);
                const auto a_v0 = proxyA.GetVertex(a_idx0);
                const auto a_v1 = proxyA.GetVertex(a_idx1);
                const auto lp = (a_v0 + a_v1) / Real{2};
                const auto ln = GetFwdPerpendicular(GetUnitVector(a_v1 - a_v0));
                const auto mp0 = Manifold::Point{
                    proxyB.GetVertex(b_indices_array[0]),
                    ContactFeature{
                        ContactFeature::e_face,
                        a_idx0,
                        ContactFeature::e_vertex,
                        b_indices_array[0]
                    }
                };
                return Manifold::GetForFaceA(ln, lp, mp0);
            }
            case 2: // uniqA must be 3
            {
                auto mp0 = Manifold::Point{};
                auto mp1 = Manifold::Point{};
                mp0.contactFeature.typeB = ContactFeature::e_face;
                mp1.contactFeature.typeB = ContactFeature::e_face;
                const auto v0 = proxyB.GetVertex(b_indices_array[0]);
                const auto v1 = proxyB.GetVertex(b_indices_array[1]);
                const auto lp = (v0 + v1) / Real{2};
                const auto count = proxyB.GetVertexCount();
                if ((b_indices_array[1] - b_indices_array[0]) == 1)
                {
                    mp0.contactFeature.indexB = b_indices_array[0];
                    mp1.contactFeature.indexB = b_indices_array[0];
                    const auto ln = GetFwdPerpendicular(GetUnitVector(v1 - v0));
                    return Manifold::GetForFaceB(ln, lp, mp0, mp1);
                }
                else if (GetModuloNext(b_indices_array[1], count) == b_indices_array[0])
                {
                    mp0.contactFeature.indexB = b_indices_array[1];
                    mp1.contactFeature.indexB = b_indices_array[1];
                    const auto ln = GetFwdPerpendicular(GetUnitVector(v0 - v1));
                    return Manifold::GetForFaceB(ln, lp, mp0, mp1);
                }
                else
                {
                    //assert(false);
                }
                return Manifold{};
            }
            default:
                break;
        }
    }
    else // uniqA == uniqB
    {
        switch (uniqA)
        {
            case 1:
            {
                return Manifold::GetForCircles(proxyA.GetVertex(a_indices_array[0]), a_indices_array[0],
                                               proxyB.GetVertex(b_indices_array[0]), b_indices_array[0]);
            }
            case 2:
            {
                const auto v0 = proxyA.GetVertex(a_indices_array[0]);
                const auto v1 = proxyA.GetVertex(a_indices_array[1]);
                const auto lp = (v0 + v1) / Real{2};
                const auto count = proxyA.GetVertexCount();
                auto mp0 = Manifold::Point{};
                auto mp1 = Manifold::Point{};
                mp0.contactFeature.typeB = ContactFeature::e_vertex;
                mp0.contactFeature.indexB = b_indices_array[0];
                mp0.localPoint = proxyB.GetVertex(mp0.contactFeature.indexB);
                mp1.contactFeature.typeB = ContactFeature::e_vertex;
                mp1.contactFeature.indexB = b_indices_array[1];
                mp1.localPoint = proxyB.GetVertex(mp1.contactFeature.indexB);
                if ((a_indices_array[1] - a_indices_array[0]) == 1)
                {
                    mp0.contactFeature.typeA = ContactFeature::e_face;
                    mp0.contactFeature.indexA = a_indices_array[0];
                    mp1.contactFeature.typeA = ContactFeature::e_face;
                    mp1.contactFeature.indexA = a_indices_array[0];
                    const auto ln = GetFwdPerpendicular(GetUnitVector(v1 - v0));
                    return Manifold::GetForFaceA(ln, lp, mp0, mp1);
                }
                if (GetModuloNext(a_indices_array[1], count) == a_indices_array[0])
                {
                    mp0.contactFeature.typeA = ContactFeature::e_face;
                    mp0.contactFeature.indexA = a_indices_array[1];
                    mp1.contactFeature.typeA = ContactFeature::e_face;
                    mp1.contactFeature.indexA = a_indices_array[1];
                    const auto ln = GetFwdPerpendicular(GetUnitVector(v0 - v1));
                    return Manifold::GetForFaceA(ln, lp, mp0, mp1);
                }
                assert(false);
                break;
            }
            case 3:
            {
                const auto ln = UnitVec::GetLeft();
                const auto lp = Length2{};
                return Manifold::GetForFaceA(ln, lp);
            }
            default:
                break;
        }
    }

    return Manifold{};
}
#endif

const char* GetName(Manifold::Type type) noexcept
{
    switch (type)
    {
        case Manifold::e_unset: break;
        case Manifold::e_circles: return "circles";
        case Manifold::e_faceA: return "face-a";
        case Manifold::e_faceB: return "face-b";
    }
    assert(type == Manifold::e_unset);
    return "unset";
}

bool operator==(const Manifold::Point& lhs, const Manifold::Point& rhs) noexcept
{
    if (lhs.localPoint != rhs.localPoint)
    {
        return false;
    }
    if (lhs.contactFeature != rhs.contactFeature)
    {
        return false;
    }
    if (lhs.normalImpulse != rhs.normalImpulse)
    {
        return false;
    }
    if (lhs.tangentImpulse != rhs.tangentImpulse)
    {
        return false;
    }
    return true;
}

bool operator!=(const Manifold::Point& lhs, const Manifold::Point& rhs) noexcept
{
    return !(lhs == rhs);
}

bool operator==(const Manifold& lhs, const Manifold& rhs) noexcept
{
    if (lhs.GetType() != rhs.GetType())
    {
        return false;
    }
    if (lhs.GetPointCount() != rhs.GetPointCount())
    {
        return false;
    }

    switch (lhs.GetType())
    {
        case Manifold::e_unset:
            break;
        case Manifold::e_circles:
            if (lhs.GetLocalPoint() != rhs.GetLocalPoint())
            {
                return false;
            }
            break;
        case Manifold::e_faceA:
            if (lhs.GetLocalPoint() != rhs.GetLocalPoint())
            {
                return false;
            }
            if (lhs.GetLocalNormal() != rhs.GetLocalNormal())
            {
                return false;
            }
            break;
        case Manifold::e_faceB:
            if (lhs.GetLocalPoint() != rhs.GetLocalPoint())
            {
                return false;
            }
            if (lhs.GetLocalNormal() != rhs.GetLocalNormal())
            {
                return false;
            }
            break;
    }

    const auto count = lhs.GetPointCount();
    assert(count <= 2);
    switch (count)
    {
        case 0:
            break;
        case 1:
            if (lhs.GetPoint(0) != rhs.GetPoint(0))
            {
                return false;
            }
            break;
        case 2:
            if (lhs.GetPoint(0) != rhs.GetPoint(0))
            {
                if (lhs.GetPoint(0) != rhs.GetPoint(1))
                {
                    return false;
                }
                if (lhs.GetPoint(1) != rhs.GetPoint(0))
                {
                    return false;
                }
            }
            else if (lhs.GetPoint(1) != rhs.GetPoint(1))
            {
                return false;
            }
            break;
    }
    
    return true;
}

bool operator!=(const Manifold& lhs, const Manifold& rhs) noexcept
{
    return !(lhs == rhs);
}

#if 0
Length2 GetLocalPoint(const DistanceProxy& proxy, ContactFeature::Type type,
                      ContactFeature::Index index)
{
    switch (type)
    {
        case ContactFeature::e_vertex:
            return proxy.GetVertex(index);
        case ContactFeature::e_face:
        {
            return proxy.GetVertex(index);
        }
    }
    return GetInvalid<Length2>();
}
#endif

} // namespace d2
} // namespace playrho
