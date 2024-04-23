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
#include <utility> // for std::make_pair

#include "playrho/Math.hpp" // for GetModuloNext and more
#include "playrho/StepConf.hpp"
#include "playrho/Templates.hpp" // for size

#include "playrho/d2/Distance.hpp"
#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/Manifold.hpp"
#include "playrho/d2/ShapeSeparation.hpp"
#include "playrho/d2/Simplex.hpp"

#define PLAYRHO_MAGIC(x) (x)

namespace playrho::d2 {

namespace {

/// @brief Clip vertex.
/// @details Used for computing contact manifolds.
struct ClipVertex
{
    Length2 v; ///< Vertex of edge or polygon.
    ContactFeature cf; ///< Contact feature information.
};

/// @brief Clip list for <code>ClipSegmentToLine</code>.
/// @see ClipSegmentToLine.
using ClipList = ArrayList<ClipVertex, MaxManifoldPoints>;

/// Clipping for contact manifolds.
/// @details This returns an array of points from the given line that are inside of the plane as
///   defined by a given normal and offset.
/// @param vIn Clip list of two points defining the line.
/// @param normal Normal of the plane with which to determine intersection.
/// @param offset Offset of the plane with which to determine intersection.
/// @param indexA Index of vertex A.
/// @return List of zero one or two clip points.
ClipList ClipSegmentToLine(const ClipList& vIn, const UnitVec& normal, Length offset,
                           ContactFeature::Index indexA)
{
    ClipList vOut;

    if (size(vIn) == 2) // must have two points (for a segment)
    {
        // Use Sutherland-Hodgman clipping:
        //   (https://en.wikipedia.org/wiki/Sutherland%E2%80%93Hodgman_algorithm ).

        // Calculate the distance of end points to the line
        const auto distance0 = Dot(normal, vIn[0].v) - offset;
        const auto distance1 = Dot(normal, vIn[1].v) - offset;

        // If the points are behind the plane...
        // Ideally they are. Then we get face-vertex contact features which are simpler to
        // calculate. Note that it also helps to avoid changing the contact feature from the
        // given clip vertices. So the code here also accepts distances that are just slightly
        // over zero.
        if (distance0 <= 0_m || AlmostZero(StripUnit(distance0)))
        {
            vOut.push_back(vIn[0]);
        }
        if (distance1 <= 0_m || AlmostZero(StripUnit(distance1)))
        {
            vOut.push_back(vIn[1]);
        }

        // If we didn't already find two points & the points are on different sides of the plane...
        if (size(vOut) < 2 && signbit(StripUnit(distance0)) != signbit(StripUnit(distance1)))
        {
            // Neither distance0 nor distance1 is 0 and either one or the other is negative (but not both).
            // Find intersection point of edge and plane
            // Vertex A is hitting edge B.
            const auto interp = distance0 / (distance0 - distance1);
            const auto vertex = vIn[0].v + (vIn[1].v - vIn[0].v) * interp;
            vOut.push_back(ClipVertex{vertex, GetVertexFaceContactFeature(indexA, vIn[0].cf.indexB)});
        }
    }

    return vOut;
}

constexpr auto face = ContactFeature::e_face;
constexpr auto vertex = ContactFeature::e_vertex;

#ifdef DEFINE_GET_MANIFOLD
inline index_type GetEdgeIndex(VertexCounter i1, VertexCounter i2, VertexCounter count)
{
    if (GetModuloNext(i1, count) == i2) {
        return i1;
    }
    if (GetModuloNext(i2, count) == i1) {
        return i2;
    }
    return InvalidVertex;
}
#endif

using VertexCounterPair = std::pair<VertexCounter, VertexCounter>;

VertexCounterPair GetMostAntiParallelEdge(const UnitVec& shape0_rel_n0, const Transformation& xf0,
                                          const DistanceProxy& shape1, const Transformation& xf1,
                                          const VertexCounter2 indices1) noexcept
{
    const auto firstIdx = std::get<0>(indices1);
    const auto secondIdx = std::get<1>(indices1);
    if (secondIdx == InvalidVertex) {
        // Gets most anti-parallel edge of either prevIdx or firstIdx.
        const auto normal = InverseRotate(Rotate(shape0_rel_n0, xf0.q), xf1.q);
        const auto count = shape1.GetVertexCount();
        const auto prevIdx = GetModuloPrev(firstIdx, count);
        const auto prevDot = Dot(normal, shape1.GetNormal(prevIdx));
        const auto currDot = Dot(normal, shape1.GetNormal(firstIdx));
        return (prevDot < currDot) ? std::make_pair(prevIdx, firstIdx)
                                   : std::make_pair(firstIdx, GetModuloNext(firstIdx, count));
    }
    return ((secondIdx > firstIdx) && ((firstIdx + 1) == secondIdx))
               ? std::make_pair(firstIdx, secondIdx)
               : std::make_pair(secondIdx, firstIdx);
}

ClipList GetClipPoints(const Length2& shape0_abs_v0, const Length2& shape0_abs_v1, VertexCounterPair shape0_e,
                       const UnitVec& shape0_abs_e0_dir, const Length2& shape1_abs_v0,
                       const Length2& shape1_abs_v1, VertexCounterPair shape1_e)
{
    // Gets the two vertices in world coordinates and their face-vertex contact features
    // of the incident edge of shape1
    const auto ie = ClipList{
        ClipVertex{shape1_abs_v0, GetFaceVertexContactFeature(shape0_e.first, shape1_e.first)},
        ClipVertex{shape1_abs_v1, GetFaceVertexContactFeature(shape0_e.first, shape1_e.second)}};
    const auto shape0_dp_v0_e0 = -Dot(shape0_abs_e0_dir, shape0_abs_v0);
    const auto shape0_dp_v1_e0 = +Dot(shape0_abs_e0_dir, shape0_abs_v1);
    const auto points = ClipSegmentToLine(ie, -shape0_abs_e0_dir, shape0_dp_v0_e0, shape0_e.first);
    return ClipSegmentToLine(points, +shape0_abs_e0_dir, shape0_dp_v1_e0, shape0_e.second);
}

} // anonymous namespace

Manifold::Conf GetManifoldConf(const StepConf& conf) noexcept
{
    auto manifoldConf = Manifold::Conf{};
    manifoldConf.linearSlop = conf.linearSlop;
    manifoldConf.maxCirclesRatio = conf.maxCirclesRatio;
    return manifoldConf;
}

Manifold GetManifold(bool flipped, // NOLINT(readability-function-cognitive-complexity)
                     const DistanceProxy& shape0,
                     const Transformation& xf0,
                     const VertexCounter idx0,
                     const DistanceProxy& shape1,
                     const Transformation& xf1,
                     const VertexCounter2 indices1,
                     const Manifold::Conf& conf)
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

    const auto shape0_len_edge0 = GetMagnitudeSquared(shape0_rel_v1 - shape0_rel_v0);

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
        const auto clipPoints =
            GetClipPoints(shape0_abs_v0, shape0_abs_v1, std::make_pair(idx0, idx0Next),
                          shape0_abs_e0_dir, shape1_abs_v0, shape1_abs_v1, shape1_e);
        if (size(clipPoints) == 2) {
            const auto abs_normal = GetFwdPerpendicular(shape0_abs_e0_dir);
            const auto rel_midpoint = (shape0_rel_v0 + shape0_rel_v1) / Real{2};
            const auto abs_offset = Dot(abs_normal, shape0_abs_v0); ///< Face offset.
            const auto normal = GetFwdPerpendicular(shape0_rel_e0_dir);
            auto manifold = !flipped
                ? Manifold::GetForFaceA(normal, rel_midpoint)
                : Manifold::GetForFaceB(normal, rel_midpoint);
            for (auto&& cp : clipPoints) {
                if ((Dot(abs_normal, cp.v) - abs_offset) <= totalRadius) {
                    manifold.AddPoint({InverseTransform(cp.v, xf1), flipped? Flip(cp.cf): cp.cf});
                }
            }
            if (manifold.GetPointCount() > 0) {
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
    if (GetMagnitudeSquared(shape0_abs_v0 - shape1_abs_v0) <= totalRadiusSquared) {
        // shape 0 vertex 0 is colliding with shape 1 vertex 0
        // shape 0 vertex 0 is the vertex at index idx0, or one before idx0Next.
        // shape 1 vertex 0 is the vertex at index shape1_e.first, or one before shape1_e.second.
        if (mustUseFaceManifold) {
            return !flipped
                ? Manifold::GetForFaceA(GetFwdPerpendicular(shape0_rel_e0_dir), shape0_rel_v0,
                                        {shape1_rel_v0, {face, idx0, vertex, shape1_e.first}})
                : Manifold::GetForFaceB(GetFwdPerpendicular(shape0_rel_e0_dir), shape0_rel_v0,
                                        {shape1_rel_v0, {vertex, shape1_e.first, face, idx0}});
        }
        return !flipped
            ? Manifold::GetForCircles(shape0_rel_v0, idx0, shape1_rel_v0, shape1_e.first)
            : Manifold::GetForCircles(shape1_rel_v0, shape1_e.first, shape0_rel_v0, idx0);
    }
    if (GetMagnitudeSquared(shape0_abs_v1 - shape1_abs_v1) <= totalRadiusSquared) {
        // shape 0 vertex 1 is colliding with shape 1 vertex 1
        if (mustUseFaceManifold) {
            return !flipped
                ? Manifold::GetForFaceA(GetFwdPerpendicular(shape0_rel_e0_dir), shape0_rel_v1,
                                        {shape1_rel_v1, {face, idx0Next, vertex, shape1_e.second}})
                : Manifold::GetForFaceB(GetFwdPerpendicular(shape0_rel_e0_dir), shape0_rel_v1,
                                        {shape1_rel_v1, {vertex, shape1_e.second, face, idx0Next}});
        }
        return !flipped
            ? Manifold::GetForCircles(shape0_rel_v1, idx0Next, shape1_rel_v1, shape1_e.second)
            : Manifold::GetForCircles(shape1_rel_v1, shape1_e.second, shape0_rel_v1, idx0Next);
    }
    if (GetMagnitudeSquared(shape0_abs_v0 - shape1_abs_v1) <= totalRadiusSquared) {
        // shape 0 vertex 0 is colliding with shape 1 vertex 1
        if (mustUseFaceManifold) {
            return !flipped
                ? Manifold::GetForFaceA(GetFwdPerpendicular(shape0_rel_e0_dir), shape0_rel_v0,
                                        {shape1_rel_v1, {face, idx0, vertex, shape1_e.second}})
                : Manifold::GetForFaceB(GetFwdPerpendicular(shape0_rel_e0_dir), shape0_rel_v0,
                                        {shape1_rel_v1, {vertex, shape1_e.second, face, idx0}});
        }
        return !flipped
            ? Manifold::GetForCircles(shape0_rel_v0, idx0, shape1_rel_v1, shape1_e.second)
            : Manifold::GetForCircles(shape1_rel_v1, shape1_e.second, shape0_rel_v0, idx0);
    }
    if (GetMagnitudeSquared(shape0_abs_v1 - shape1_abs_v0) <= totalRadiusSquared) {
        // shape 0 vertex 1 is colliding with shape 1 vertex 0
        if (mustUseFaceManifold) {
            return !flipped
                ? Manifold::GetForFaceA(GetFwdPerpendicular(shape0_rel_e0_dir), shape0_rel_v1,
                                        {shape1_rel_v0, {face, idx0Next, vertex, shape1_e.first}})
                : Manifold::GetForFaceB(GetFwdPerpendicular(shape0_rel_e0_dir), shape0_rel_v1,
                                        {shape1_rel_v0, {vertex, shape1_e.first, face, idx0Next}});
        }
        return !flipped
            ? Manifold::GetForCircles(shape0_rel_v1, idx0Next, shape1_rel_v0, shape1_e.first)
            : Manifold::GetForCircles(shape1_rel_v0, shape1_e.first, shape0_rel_v1, idx0Next);
    }
    return {};
}

Manifold GetManifold(bool flipped, Length totalRadius, const DistanceProxy& shape,
                     const Transformation& sxf, const Length2& point, const Transformation& xfm)
{
    const auto vertexCount = shape.GetVertexCount();
    assert(vertexCount > 0);

    // Computes the center of the circle in the frame of the polygon.
    const auto cLocal =
        InverseTransform(Transform(point, xfm), sxf); ///< Center of circle in frame of polygon.

    // Find edge that circle is closest to.
    auto indexOfMax = decltype(vertexCount){0};
    auto maxSeparation = -MaxFloat * Meter;
    {
        for (auto i = decltype(vertexCount){0}; i < vertexCount; ++i) {
            // Get circle's distance from vertex[i] in direction of normal[i].
            const auto s = Dot(shape.GetNormal(i), cLocal - shape.GetVertex(i));
            if (s > totalRadius) {
                // Early out - no contact.
                return {};
            }
            if (maxSeparation < s) {
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

    if (maxSeparation < 0_m) {
        const auto faceCenter = (v1 + v2) / Real{2};
        // Circle's center is inside the polygon and closest to edge[indexOfMax].
        return !flipped
            ? Manifold::GetForFaceA(shape.GetNormal(indexOfMax), faceCenter,
                                    {point, {face, indexOfMax, vertex, 0}})
            : Manifold::GetForFaceB(shape.GetNormal(indexOfMax), faceCenter,
                                    {point, {vertex, 0, face, indexOfMax}});
    }

    // Circle's center is outside polygon and closest to edge[indexOfMax].
    // Compute barycentric coordinates.

    const auto cLocalV1 = cLocal - v1;
    if (Dot(cLocalV1, v2 - v1) <= 0_m2) {
        // Circle's center right of v1 (in direction of v1 to v2).
        if (GetMagnitudeSquared(cLocalV1) > Square(totalRadius)) {
            return {};
        }
        return !flipped
            ? Manifold::GetForCircles(v1, indexOfMax, point, 0)
            : Manifold::GetForCircles(point, 0, v1, indexOfMax);
    }

    const auto ClocalV2 = cLocal - v2;
    if (Dot(ClocalV2, v1 - v2) <= 0_m2) {
        // Circle's center left of v2 (in direction of v2 to v1).
        if (GetMagnitudeSquared(ClocalV2) > Square(totalRadius)) {
            return {};
        }
        return !flipped
            ? Manifold::GetForCircles(v2, indexOfMax2, point, 0)
            : Manifold::GetForCircles(point, 0, v2, indexOfMax2);
    }

    // Circle's center is between v1 and v2.
    const auto faceCenter = (v1 + v2) / Real{2};
    if (Dot(cLocal - faceCenter, shape.GetNormal(indexOfMax)) > totalRadius) {
        return {};
    }
    return !flipped
        ? Manifold::GetForFaceA(shape.GetNormal(indexOfMax), faceCenter,
                                {point, {face, indexOfMax, vertex, 0}})
        : Manifold::GetForFaceB(shape.GetNormal(indexOfMax), faceCenter,
                                {point, {vertex, 0, face, indexOfMax}});
}

Manifold GetManifold(const Length2& locationA, const Transformation& xfA, // force line-break
                     const Length2& locationB, const Transformation& xfB, // force line-break
                     Length totalRadius) noexcept
{
    const auto pA = Transform(locationA, xfA);
    const auto pB = Transform(locationB, xfB);
    const auto lenSq = GetMagnitudeSquared(pB - pA);
    const auto totSq = Square(totalRadius);
    if (lenSq > totSq) {
        return {};
    }
    return Manifold::GetForCircles(locationA, 0, locationB, 0);
}

/*
 * Definition of public CollideShapes functions.
 * All CollideShapes functions return a Manifold object.
 */

Manifold CollideShapes(const DistanceProxy& shapeA, const Transformation& xfA, //
                       const DistanceProxy& shapeB, const Transformation& xfB, //
                       const Manifold::Conf& conf)
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

    enum : unsigned { ZeroOneVert = 0x0u, OneVertA = 0x1u, OneVertB = 0x2u };
    switch (((countA == 1) ? OneVertA : ZeroOneVert) | ((countB == 1) ? OneVertB : ZeroOneVert)) {
    case OneVertA | OneVertB:
        return GetManifold(shapeA.GetVertex(0), xfA, shapeB.GetVertex(0), xfB, totalRadius);
    case OneVertA:
        return GetManifold(true, totalRadius, shapeB, xfB, shapeA.GetVertex(0), xfA);
    case OneVertB:
        return GetManifold(false, totalRadius, shapeA, xfA, shapeB.GetVertex(0), xfB);
    }

    const auto do4x4 = (countA == 4) && (countB == 4);

    const auto edgeSepA = do4x4 ? GetMaxSeparation4x4(shapeA, xfA, shapeB, xfB)
                                : GetMaxSeparation(shapeA, xfA, shapeB, xfB);
    if (edgeSepA.distance > totalRadius) {
        return {};
    }

    const auto edgeSepB = do4x4 ? GetMaxSeparation4x4(shapeB, xfB, shapeA, xfA)
                                : GetMaxSeparation(shapeB, xfB, shapeA, xfA);
    if (edgeSepB.distance > totalRadius) {
        return {};
    }

    const auto k_tol = PLAYRHO_MAGIC(conf.linearSlop / 10);
    return (edgeSepB.distance > (edgeSepA.distance + k_tol))
               ? GetManifold(true, shapeB, xfB, edgeSepB.firstShape, shapeA, xfA,
                             edgeSepB.secondShape, conf)
               : GetManifold(false, shapeA, xfA, edgeSepA.firstShape, shapeB, xfB,
                             edgeSepA.secondShape, conf);
}

#ifdef DEFINE_GET_MANIFOLD
Manifold GetManifold(const DistanceProxy& proxyA, const Transformation& transformA,
                     const DistanceProxy& proxyB, const Transformation& transformB)
{
    const auto distanceInfo = Distance(proxyA, transformA, proxyB, transformB);
    const auto totalRadius = proxyA.GetVertexRadius() + proxyB.GetVertexRadius();
    const auto witnessPoints = GetWitnessPoints(distanceInfo.simplex);

    const auto distance = sqrt(GetMagnitudeSquared(witnessPoints.a - witnessPoints.b));
    if (distance > totalRadius) {
        // no collision
        return {};
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
        for (auto&& e : distanceInfo.simplex.GetEdges()) {
            const auto indexA = e.GetIndexA();
            if (!a_indices_set[indexA]) {
                a_indices_set[indexA] = true;
                a_indices_array[uniqA] = indexA;
                ++uniqA;
            }
            const auto indexB = e.GetIndexB();
            if (!b_indices_set[indexB]) {
                b_indices_set[indexB] = true;
                b_indices_array[uniqB] = indexB;
                ++uniqB;
            }
        }
    }

    assert(uniqA > 0 && uniqB > 0);

    std::sort(a_indices_array, a_indices_array + uniqA);
    std::sort(b_indices_array, b_indices_array + uniqB);

    if (uniqA < uniqB) {
        switch (uniqA) {
        case 1: // uniqB must be 2 or 3
        {
            const auto b_idx0 = GetEdgeIndex(b_indices_array[0], b_indices_array[1], b_count);
            assert(b_idx0 != InvalidVertex);
            const auto b_idx1 = GetModuloNext(b_idx0, b_count);
            const auto b_v0 = proxyB.GetVertex(b_idx0);
            const auto b_v1 = proxyB.GetVertex(b_idx1);
            const auto lp = (b_v0 + b_v1) / Real{2};
            const auto ln = GetFwdPerpendicular(GetUnitVector(b_v1 - b_v0));
            const auto mp0 =
                Manifold::Point{proxyA.GetVertex(a_indices_array[0]),
                                {vertex, a_indices_array[0], face, b_idx0}};
            return Manifold::GetForFaceB(ln, lp, mp0);
        }
        case 2: // uniqB must be 3
        {
            auto mp0 = Manifold::Point{};
            auto mp1 = Manifold::Point{};
            mp0.contactFeature.typeA = face;
            mp1.contactFeature.typeA = face;
            const auto v0 = proxyA.GetVertex(a_indices_array[0]);
            const auto v1 = proxyA.GetVertex(a_indices_array[1]);
            const auto lp = (v0 + v1) / Real{2};
            const auto count = proxyA.GetVertexCount();
            if ((a_indices_array[1] - a_indices_array[0]) == 1) {
                mp0.contactFeature.indexA = a_indices_array[0];
                mp1.contactFeature.indexA = a_indices_array[0];
                const auto ln = GetFwdPerpendicular(GetUnitVector(v1 - v0));
                return Manifold::GetForFaceA(ln, lp, mp0, mp1);
            }
            else if (GetModuloNext(a_indices_array[1], count) == a_indices_array[0]) {
                mp0.contactFeature.indexA = a_indices_array[1];
                mp1.contactFeature.indexA = a_indices_array[1];
                const auto ln = GetFwdPerpendicular(GetUnitVector(v0 - v1));
                return Manifold::GetForFaceA(ln, lp, mp0, mp1);
            }
            else {
                // assert(false);
            }
            return {};
        }
        default:
            break;
        }
    }
    else if (uniqB < uniqA) {
        switch (uniqB) {
        case 1: // uniqA must be 2 or 3
        {
            const auto a_idx0 = GetEdgeIndex(a_indices_array[0], a_indices_array[1], a_count);
            assert(a_idx0 != InvalidVertex);
            const auto a_idx1 = GetModuloNext(a_idx0, a_count);
            const auto a_v0 = proxyA.GetVertex(a_idx0);
            const auto a_v1 = proxyA.GetVertex(a_idx1);
            const auto lp = (a_v0 + a_v1) / Real{2};
            const auto ln = GetFwdPerpendicular(GetUnitVector(a_v1 - a_v0));
            const auto mp0 =
                Manifold::Point{proxyB.GetVertex(b_indices_array[0]),
                                {face, a_idx0, vertex, b_indices_array[0]}};
            return Manifold::GetForFaceA(ln, lp, mp0);
        }
        case 2: // uniqA must be 3
        {
            auto mp0 = Manifold::Point{};
            auto mp1 = Manifold::Point{};
            mp0.contactFeature.typeB = face;
            mp1.contactFeature.typeB = face;
            const auto v0 = proxyB.GetVertex(b_indices_array[0]);
            const auto v1 = proxyB.GetVertex(b_indices_array[1]);
            const auto lp = (v0 + v1) / Real{2};
            const auto count = proxyB.GetVertexCount();
            if ((b_indices_array[1] - b_indices_array[0]) == 1) {
                mp0.contactFeature.indexB = b_indices_array[0];
                mp1.contactFeature.indexB = b_indices_array[0];
                const auto ln = GetFwdPerpendicular(GetUnitVector(v1 - v0));
                return Manifold::GetForFaceB(ln, lp, mp0, mp1);
            }
            else if (GetModuloNext(b_indices_array[1], count) == b_indices_array[0]) {
                mp0.contactFeature.indexB = b_indices_array[1];
                mp1.contactFeature.indexB = b_indices_array[1];
                const auto ln = GetFwdPerpendicular(GetUnitVector(v0 - v1));
                return Manifold::GetForFaceB(ln, lp, mp0, mp1);
            }
            else {
                // assert(false);
            }
            return {};
        }
        default:
            break;
        }
    }
    else // uniqA == uniqB
    {
        switch (uniqA) {
        case 1: {
            return Manifold::GetForCircles(proxyA.GetVertex(a_indices_array[0]), a_indices_array[0],
                                           proxyB.GetVertex(b_indices_array[0]),
                                           b_indices_array[0]);
        }
        case 2: {
            const auto v0 = proxyA.GetVertex(a_indices_array[0]);
            const auto v1 = proxyA.GetVertex(a_indices_array[1]);
            const auto lp = (v0 + v1) / Real{2};
            const auto count = proxyA.GetVertexCount();
            auto mp0 = Manifold::Point{};
            auto mp1 = Manifold::Point{};
            mp0.contactFeature.typeB = vertex;
            mp0.contactFeature.indexB = b_indices_array[0];
            mp0.localPoint = proxyB.GetVertex(mp0.contactFeature.indexB);
            mp1.contactFeature.typeB = vertex;
            mp1.contactFeature.indexB = b_indices_array[1];
            mp1.localPoint = proxyB.GetVertex(mp1.contactFeature.indexB);
            if ((a_indices_array[1] - a_indices_array[0]) == 1) {
                mp0.contactFeature.typeA = face;
                mp0.contactFeature.indexA = a_indices_array[0];
                mp1.contactFeature.typeA = face;
                mp1.contactFeature.indexA = a_indices_array[0];
                const auto ln = GetFwdPerpendicular(GetUnitVector(v1 - v0));
                return Manifold::GetForFaceA(ln, lp, mp0, mp1);
            }
            if (GetModuloNext(a_indices_array[1], count) == a_indices_array[0]) {
                mp0.contactFeature.typeA = face;
                mp0.contactFeature.indexA = a_indices_array[1];
                mp1.contactFeature.typeA = face;
                mp1.contactFeature.indexA = a_indices_array[1];
                const auto ln = GetFwdPerpendicular(GetUnitVector(v0 - v1));
                return Manifold::GetForFaceA(ln, lp, mp0, mp1);
            }
            assert(false);
            break;
        }
        case 3: {
            const auto ln = UnitVec::GetLeft();
            const auto lp = Length2{};
            return Manifold::GetForFaceA(ln, lp);
        }
        default:
            break;
        }
    }

    return {};
}
#endif

const char* GetName(Manifold::Type type) noexcept
{
    switch (type) {
    case Manifold::e_unset:
        break;
    case Manifold::e_circles:
        return "circles";
    case Manifold::e_faceA:
        return "face-a";
    case Manifold::e_faceB:
        return "face-b";
    }
    assert(type == Manifold::e_unset);
    return "unset";
}

bool operator==(const Manifold::Point& lhs, const Manifold::Point& rhs) noexcept
{
    if (lhs.localPoint != rhs.localPoint) {
        return false;
    }
    if (lhs.contactFeature != rhs.contactFeature) {
        return false;
    }
    if (lhs.normalImpulse != rhs.normalImpulse) {
        return false;
    }
    if (lhs.tangentImpulse != rhs.tangentImpulse) {
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
    if (lhs.GetType() != rhs.GetType()) {
        return false;
    }
    if (lhs.GetPointCount() != rhs.GetPointCount()) {
        return false;
    }

    switch (lhs.GetType()) {
    case Manifold::e_unset:
        break;
    case Manifold::e_circles:
        if (lhs.GetLocalPoint() != rhs.GetLocalPoint()) {
            return false;
        }
        break;
    case Manifold::e_faceA:
        if (lhs.GetLocalPoint() != rhs.GetLocalPoint()) {
            return false;
        }
        if (lhs.GetLocalNormal() != rhs.GetLocalNormal()) {
            return false;
        }
        break;
    case Manifold::e_faceB:
        if (lhs.GetLocalPoint() != rhs.GetLocalPoint()) {
            return false;
        }
        if (lhs.GetLocalNormal() != rhs.GetLocalNormal()) {
            return false;
        }
        break;
    }

    const auto count = lhs.GetPointCount();
    assert(count <= 2);
    switch (count) {
    case 0:
        break;
    case 1:
        if (lhs.GetPoint(0) != rhs.GetPoint(0)) {
            return false;
        }
        break;
    case 2:
        if (lhs.GetPoint(0) != rhs.GetPoint(0)) {
            if (lhs.GetPoint(0) != rhs.GetPoint(1)) {
                return false;
            }
            if (lhs.GetPoint(1) != rhs.GetPoint(0)) {
                return false;
            }
        }
        else if (lhs.GetPoint(1) != rhs.GetPoint(1)) {
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

} // namespace playrho::d2
