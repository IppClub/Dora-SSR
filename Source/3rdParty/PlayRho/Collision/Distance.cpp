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

#include "PlayRho/Collision/Distance.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/Simplex.hpp"
#include "PlayRho/Collision/TimeOfImpact.hpp"

namespace playrho {
namespace d2 {
namespace {

inline bool HasKey(IndexPair3 pairs, IndexPair key)
{
    return pairs[0] == key || pairs[1] == key || pairs[2] == key;
}

inline SimplexEdge GetSimplexEdge(const DistanceProxy& proxyA,
                                  const Transformation& xfA,
                                  VertexCounter idxA,
                                  const DistanceProxy& proxyB,
                                  const Transformation& xfB,
                                  VertexCounter idxB)
{
    const auto wA = Transform(proxyA.GetVertex(idxA), xfA);
    const auto wB = Transform(proxyB.GetVertex(idxB), xfB);
    return SimplexEdge{wA, idxA, wB, idxB};
}

inline SimplexEdges GetSimplexEdges(const IndexPair3 indexPairs,
                                    const DistanceProxy& proxyA, const Transformation& xfA,
                                    const DistanceProxy& proxyB, const Transformation& xfB)
{
    /// @brief Size type.
    using size_type = std::remove_const<decltype(MaxSimplexEdges)>::type;

    auto simplexEdges = SimplexEdges{};
    const auto count = GetNumValidIndices(indexPairs);
    switch (count)
    {
        case 3:
            simplexEdges[2] = GetSimplexEdge(proxyA, xfA, std::get<0>(indexPairs[2]),
                                             proxyB, xfB, std::get<1>(indexPairs[2]));
            [[fallthrough]];
        case 2:
            simplexEdges[1] = GetSimplexEdge(proxyA, xfA, std::get<0>(indexPairs[1]),
                                             proxyB, xfB, std::get<1>(indexPairs[1]));
            [[fallthrough]];
        case 1:
            simplexEdges[0] = GetSimplexEdge(proxyA, xfA, std::get<0>(indexPairs[0]),
                                             proxyB, xfB, std::get<1>(indexPairs[0]));
    }
    simplexEdges.size(static_cast<size_type>(count));
    return simplexEdges;
}

} // namespace

DistanceConf GetDistanceConf(const ToiConf& conf) noexcept
{
    auto distanceConf = DistanceConf{};
    distanceConf.maxIterations = conf.maxDistIters;
    return distanceConf;
}

PairLength2 GetWitnessPoints(const Simplex& simplex) noexcept
{
    auto pointA = Length2{};
    auto pointB = Length2{};

    const auto numEdges = std::size(simplex);
    for (auto i = decltype(numEdges){0}; i < numEdges; ++i)
    {
        const auto e = simplex.GetSimplexEdge(i);
        const auto c = simplex.GetCoefficient(i);

        pointA += e.GetPointA() * c;
        pointB += e.GetPointB() * c;
    }
#if 0
    // In the 3-simplex case, pointA and pointB are usually equal.
    // XXX: Sometimes in the 3-simplex case, pointA is slightly different than pointB. Why??
    if (size == 3 && pointA != pointB)
    {
        std::cout << "odd: " << pointA << " != " << pointB;
        std::cout << std::endl;
    }
#endif
    return PairLength2{pointA, pointB};
}

DistanceOutput Distance(const DistanceProxy& proxyA, const Transformation& transformA,
                        const DistanceProxy& proxyB, const Transformation& transformB,
                        DistanceConf conf)
{
    using playrho::IsFull;
    
    assert(proxyA.GetVertexCount() > 0);
    assert(IsValid(transformA.p));
    assert(proxyB.GetVertexCount() > 0);
    assert(IsValid(transformB.p));

    auto savedIndices = conf.cache.indices;

    // Initialize the simplex.
    auto simplexEdges = GetSimplexEdges(savedIndices, proxyA, transformA, proxyB, transformB);

    // Compute the new simplex metric, if it is substantially different than
    // old metric then flush the simplex.
    if (size(simplexEdges) > 1)
    {
        const auto metric1 = conf.cache.metric;
        const auto metric2 = Simplex::CalcMetric(simplexEdges);
        if ((metric2 < (metric1 / 2)) || (metric2 > (metric1 * 2)) || (metric2 < 0) || AlmostZero(metric2))
        {
            simplexEdges.clear();
        }
    }

    if (empty(simplexEdges))
    {
        simplexEdges.push_back(GetSimplexEdge(proxyA, transformA, 0, proxyB, transformB, 0));
        savedIndices = IndexPair3{{IndexPair{0, 0}, InvalidIndexPair, InvalidIndexPair}};
    }

    auto simplex = Simplex{};
    auto state = DistanceOutput::HitMaxIters;

#if defined(DO_COMPUTE_CLOSEST_POINT)
    auto distanceSqr1 = MaxFloat;
#endif

    // Main iteration loop.
    auto iter = decltype(conf.maxIterations){0};
    while (iter < conf.maxIterations)
    {
        ++iter;
        
        simplex = Simplex::Get(simplexEdges);
        simplexEdges = simplex.GetEdges();

        // If have max simplex edges (3), then the origin is in corresponding triangle.
        if (IsFull(simplexEdges))
        {
            state = DistanceOutput::MaxPoints;
            break;
        }

#if defined(DO_COMPUTE_CLOSEST_POINT)
        // Compute closest point.
        const auto p = GetClosestPoint(simplexEdges);
        const auto distanceSqr2 = GetMagnitudeSquared(p);

        // Ensure progress
        if (distanceSqr2 >= distanceSqr1)
        {
            //break;
        }
        distanceSqr1 = distanceSqr2;
#endif
        // Get search direction.
        const auto d = CalcSearchDirection(simplexEdges);
        assert(IsValid(d));

        // Ensure the search direction is numerically fit.
        if (AlmostZero(StripUnit(GetMagnitudeSquared(d))))
        {
            state = DistanceOutput::UnfitSearchDir;

            // The origin is probably contained by a line segment
            // or triangle. Thus the shapes are overlapped.

            // We can't return zero here even though there may be overlap.
            // In case the simplex is a point, segment, or triangle it is difficult
            // to determine if the origin is contained in the CSO or very close to it.
            break;
        }

        // Compute a tentative new simplex edge using support points.
        const auto indexA = GetSupportIndex(proxyA, InverseRotate(-d, transformA.q));
        const auto indexB = GetSupportIndex(proxyB, InverseRotate(d, transformB.q));

        // Check for duplicate support points. This is the main termination criteria.
        // If there's a duplicate support point, code must exit loop to avoid cycling.
        if (HasKey(savedIndices, IndexPair{indexA, indexB}))
        {
            state = DistanceOutput::DuplicateIndexPair;
            break;
        }

        // New edge is ok and needed.
        simplexEdges.push_back(GetSimplexEdge(proxyA, transformA, indexA, proxyB, transformB, indexB));
        savedIndices = GetIndexPairs(simplexEdges);
    }

    // Note: simplexEdges is same here as simplex.GetSimplexEdges().
    // GetWitnessPoints(simplex), iter, Simplex::GetCache(simplexEdges)
    return DistanceOutput{simplex, iter, state};
}

Area TestOverlap(const DistanceProxy& proxyA, const Transformation& xfA,
                 const DistanceProxy& proxyB, const Transformation& xfB,
                 DistanceConf conf)
{
    const auto distanceInfo = Distance(proxyA, xfA, proxyB, xfB, conf);
    assert(distanceInfo.state != DistanceOutput::Unknown && distanceInfo.state != DistanceOutput::HitMaxIters);
    
    const auto witnessPoints = GetWitnessPoints(distanceInfo.simplex);
    const auto distanceSquared = GetMagnitudeSquared(GetDelta(witnessPoints));
    const auto totalRadiusSquared = Square(proxyA.GetVertexRadius() + proxyB.GetVertexRadius());
    return totalRadiusSquared - distanceSquared;
}

} // namespace d2
} // namespace playrho
