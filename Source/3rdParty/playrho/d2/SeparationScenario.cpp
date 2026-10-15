/*
 * Original work Copyright (c) 2007-2009 Erin Catto http://www.box2d.org
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

#include "playrho/d2/SeparationScenario.hpp"
#include "playrho/d2/DistanceProxy.hpp"

namespace playrho {
namespace d2 {
namespace {

LengthIndexPair FindMinSeparation(const SeparationScenarioPoints& scenario,
                                  const DistanceProxy& proxyA,
                                  const Transformation& xfA,
                                  const DistanceProxy& proxyB,
                                  const Transformation& xfB)
{
    const auto dirA = InverseRotate(+scenario.axis, xfA.q);
    const auto dirB = InverseRotate(-scenario.axis, xfB.q);
    const auto indexA = GetSupportIndex(proxyA, dirA);
    const auto indexB = GetSupportIndex(proxyB, dirB);
    const auto pointA = Transform(proxyA.GetVertex(indexA), xfA);
    const auto pointB = Transform(proxyB.GetVertex(indexB), xfB);
    const auto delta = pointB - pointA;
    return LengthIndexPair{Dot(delta, scenario.axis), IndexPair{indexA, indexB}};
}

LengthIndexPair FindMinSeparation(const SeparationScenarioFaceA& scenario,
                                  const Transformation& xfA,
                                  const DistanceProxy& proxyB,
                                  const Transformation& xfB)
{
    const auto normal = Rotate(scenario.axis, xfA.q);
    const auto indexA = InvalidVertex;
    const auto pointA = Transform(scenario.localPoint, xfA);
    const auto dir = InverseRotate(-normal, xfB.q);
    const auto indexB = GetSupportIndex(proxyB, dir);
    const auto pointB = Transform(proxyB.GetVertex(indexB), xfB);
    const auto delta = pointB - pointA;
    return LengthIndexPair{Dot(delta, normal), IndexPair{indexA, indexB}};
}

LengthIndexPair FindMinSeparation(const SeparationScenarioFaceB& scenario,
                                  const DistanceProxy& proxyA,
                                  const Transformation& xfA,
                                  const Transformation& xfB)
{
    const auto normal = Rotate(scenario.axis, xfB.q);
    const auto dir = InverseRotate(-normal, xfA.q);
    const auto indexA = GetSupportIndex(proxyA, dir);
    const auto pointA = Transform(proxyA.GetVertex(indexA), xfA);
    const auto indexB = InvalidVertex;
    const auto pointB = Transform(scenario.localPoint, xfB);
    const auto delta = pointA - pointB;
    return LengthIndexPair{Dot(delta, normal), IndexPair{indexA, indexB}};
}

Length Evaluate(const SeparationScenarioPoints& scenario,
                const DistanceProxy& proxyA,
                const Transformation& xfA,
                const DistanceProxy& proxyB,
                const Transformation& xfB,
                IndexPair indexPair)
{
    const auto pointA = Transform(proxyA.GetVertex(std::get<0>(indexPair)), xfA);
    const auto pointB = Transform(proxyB.GetVertex(std::get<1>(indexPair)), xfB);
    const auto delta = pointB - pointA;
    return Dot(delta, scenario.axis);
}

Length Evaluate(const SeparationScenarioFaceA& scenario,
                const Transformation& xfA,
                const DistanceProxy& proxyB,
                const Transformation& xfB,
                IndexPair indexPair)
{
    const auto normal = Rotate(scenario.axis, xfA.q);
    const auto pointA = Transform(scenario.localPoint, xfA);
    const auto pointB = Transform(proxyB.GetVertex(std::get<1>(indexPair)), xfB);
    const auto delta = pointB - pointA;
    return Dot(delta, normal);
}

Length Evaluate(const SeparationScenarioFaceB& scenario,
                const DistanceProxy& proxyA,
                const Transformation& xfA,
                const Transformation& xfB,
                IndexPair indexPair)
{
    const auto normal = Rotate(scenario.axis, xfB.q);
    const auto pointB = Transform(scenario.localPoint, xfB);
    const auto pointA = Transform(proxyA.GetVertex(std::get<0>(indexPair)), xfA);
    const auto delta = pointA - pointB;
    return Dot(delta, normal);
}

enum class SeparationScenarioType {
    Points,
    FaceA,
    FaceB,
};

constexpr SeparationScenarioType GetSeparationScenarioType(IndexPair3 indices)
{
    return (GetNumValidIndices(indices) < 2u)
               ? SeparationScenarioType::Points
               : ((std::get<0>(indices[0]) == std::get<0>(indices[1]))
                   ? SeparationScenarioType::FaceB : SeparationScenarioType::FaceA);
}

// helper type for the visitor
template<class... Ts>
struct overloaded : Ts... { using Ts::operator()...; };

// explicit deduction guide (not needed as of C++20)
template<class... Ts>
overloaded(Ts...) -> overloaded<Ts...>;

} // namespace

SeparationScenario GetSeparationScenario(IndexPair3 indices, const DistanceProxy& proxyA,
                                         const Transformation& xfA, const DistanceProxy& proxyB,
                                         const Transformation& xfB)
{
    assert(!empty(indices));
    assert(proxyA.GetVertexCount() > 0);
    assert(proxyB.GetVertexCount() > 0);
    const auto type = GetSeparationScenarioType(indices);
    switch (type) {
    case SeparationScenarioType::FaceB: {
        const auto ip0 = indices[0];
        const auto ip1 = indices[1];
        // Two points on B and one on A.
        const auto localPointB1 = proxyB.GetVertex(std::get<1>(ip0));
        const auto localPointB2 = proxyB.GetVertex(std::get<1>(ip1));
        const auto axis = GetUnitVector(GetFwdPerpendicular(localPointB2 - localPointB1), UnitVec::GetZero());
        const auto normal = Rotate(axis, xfB.q);
        const auto localPoint = (localPointB1 + localPointB2) / Real{2};
        const auto pointB = Transform(localPoint, xfB);
        const auto localPointA = proxyA.GetVertex(std::get<0>(ip0));
        const auto pointA = Transform(localPointA, xfA);
        const auto deltaPoint = pointA - pointB;
        const auto axisIt = (Dot(deltaPoint, normal) < 0_m) ? -axis : axis;
        return SeparationScenarioFaceB{axisIt, localPoint};
    }
    case SeparationScenarioType::FaceA: {
        const auto ip0 = indices[0];
        const auto ip1 = indices[1];
        // Two points on A and one or two points on B.
        const auto localPointA1 = proxyA.GetVertex(std::get<0>(ip0));
        const auto localPointA2 = proxyA.GetVertex(std::get<0>(ip1));
        const auto axis = GetUnitVector(GetFwdPerpendicular(localPointA2 - localPointA1), UnitVec::GetZero());
        const auto normal = Rotate(axis, xfA.q);
        const auto localPoint = (localPointA1 + localPointA2) / Real{2};
        const auto pointA = Transform(localPoint, xfA);
        const auto localPointB = proxyB.GetVertex(std::get<1>(ip0));
        const auto pointB = Transform(localPointB, xfB);
        const auto deltaPoint = pointB - pointA;
        const auto axisIt = (Dot(deltaPoint, normal) < 0_m) ? -axis : axis;
        return SeparationScenarioFaceA{axisIt, localPoint};
    }
    case SeparationScenarioType::Points:
        break;
    }
    assert(type == SeparationScenarioType::Points);
    const auto ip0 = indices[0];
    const auto localPointA = proxyA.GetVertex(std::get<0>(ip0));
    const auto localPointB = proxyB.GetVertex(std::get<1>(ip0));
    const auto pointA = Transform(localPointA, xfA);
    const auto pointB = Transform(localPointB, xfB);
    const auto axis = GetUnitVector(pointB - pointA, UnitVec::GetZero());
    return SeparationScenarioPoints{axis};
}

LengthIndexPair FindMinSeparation(const SeparationScenario& scenario,
                                  const DistanceProxy& proxyA,
                                  const Transformation& xfA,
                                  const DistanceProxy& proxyB,
                                  const Transformation& xfB)
{
    return std::visit(overloaded{
        [&](const SeparationScenarioFaceA& arg) { return FindMinSeparation(arg, xfA, proxyB, xfB); },
        [&](const SeparationScenarioFaceB& arg) { return FindMinSeparation(arg, proxyA, xfA, xfB); },
        [&](const SeparationScenarioPoints& arg) { return FindMinSeparation(arg, proxyA, xfA, proxyB, xfB); },
    }, scenario);
}

Length Evaluate(const SeparationScenario& scenario,
                const DistanceProxy& proxyA,
                const Transformation& xfA,
                const DistanceProxy& proxyB,
                const Transformation& xfB,
                IndexPair indexPair)
{
    return std::visit(overloaded{
        [&](const SeparationScenarioFaceA& arg) { return Evaluate(arg, xfA, proxyB, xfB, indexPair); },
        [&](const SeparationScenarioFaceB& arg) { return Evaluate(arg, proxyA, xfA, xfB, indexPair); },
        [&](const SeparationScenarioPoints& arg) { return Evaluate(arg, proxyA, xfA, proxyB, xfB, indexPair); },
    }, scenario);
}

} // namespace d2
} // namespace playrho
