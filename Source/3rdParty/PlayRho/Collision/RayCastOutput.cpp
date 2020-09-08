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

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/GrowableStack.hpp"
#include "PlayRho/Collision/RayCastOutput.hpp"
#include "PlayRho/Collision/RayCastInput.hpp"
#include "PlayRho/Collision/AABB.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/DynamicTree.hpp"
#include "PlayRho/Dynamics/Fixture.hpp"
#include "PlayRho/Dynamics/Body.hpp"
#include <utility>

namespace playrho {
namespace d2 {

RayCastOutput RayCast(Length radius, Length2 location, const RayCastInput& input) noexcept
{
    // Collision Detection in Interactive 3D Environments by Gino van den Bergen
    // From Section 3.1.2
    // x = s + a * r
    // norm(x) = radius
    
    const auto s = input.p1 - location;
    const auto b = GetMagnitudeSquared(s) - Square(radius);
    
    // Solve quadratic equation.
    const auto raySegment = input.p2 - input.p1; // Length2
    const auto c =  Dot(s, raySegment); // Area
    const auto rr = GetMagnitudeSquared(raySegment); // Area
    const auto sigma = Real{(Square(c) - rr * b) / (SquareMeter * SquareMeter)};
    
    // Check for negative discriminant and short segment.
    if ((sigma < Real{0}) || AlmostZero(Real{rr / SquareMeter}))
    {
        return RayCastOutput{};
    }
    
    // Find the point of intersection of the line with the circle.
    const auto a = -(c + sqrt(sigma) * SquareMeter);
    const auto fraction = Real{a / rr};

    // Is the intersection point on the segment?
    if ((fraction >= Real{0}) && (fraction <= input.maxFraction))
    {
        const auto normal = GetUnitVector(s + fraction * raySegment, UnitVec::GetZero());
        return RayCastOutput{{normal, fraction}};
    }
    
    return RayCastOutput{};
}

RayCastOutput RayCast(const AABB& aabb, const RayCastInput& input) noexcept
{
    // From Real-time Collision Detection, p179.

    auto normal = UnitVec{};
    auto tmin = -MaxFloat;
    auto tmax = MaxFloat;
    
    const auto p1 = input.p1;
    const auto pDelta = input.p2 - input.p1;
    for (auto i = decltype(pDelta.max_size()){0}; i < pDelta.max_size(); ++i)
    {
        const auto p1i = p1[i];
        const auto pdi = pDelta[i];
        const auto range = aabb.ranges[i];

        if (AlmostZero(pdi))
        {
            // Parallel.
            if ((p1i < range.GetMin()) || (p1i > range.GetMax()))
            {
                return RayCastOutput{};
            }
        }
        else
        {
            const auto reciprocalOfPdi = Real{1} / pdi;
            auto t1 = Real{(range.GetMin() - p1i) * reciprocalOfPdi};
            auto t2 = Real{(range.GetMax() - p1i) * reciprocalOfPdi};
            auto s = -1; // Sign of the normal vector.
            if (t1 > t2)
            {
                std::swap(t1, t2);
                s = 1;
            }
            if (tmin < t1)
            {
                normal = (i == 0)?
                    ((s < 0)? UnitVec::GetLeft(): UnitVec::GetRight()):
                    ((s < 0)? UnitVec::GetBottom(): UnitVec::GetTop());
                tmin = t1; // Push the min up
            }
            tmax = std::min(tmax, t2); // Pull the max down
            if (tmin > tmax)
            {
                return RayCastOutput{};
            }
        }
    };
    
    // Does the ray start inside the box?
    // Does the ray intersect beyond the max fraction?
    if ((tmin < 0) || (tmin > input.maxFraction))
    {
        return RayCastOutput{};
    }
    
    // Intersection.
    return RayCastOutput{{normal, tmin}};
}

RayCastOutput RayCast(const DistanceProxy& proxy, const RayCastInput& input,
                      const Transformation& transform) noexcept
{
    const auto vertexCount = proxy.GetVertexCount();
    assert(vertexCount > 0);

    const auto radius = proxy.GetVertexRadius();
    auto v0 = proxy.GetVertex(0);
    if (vertexCount == 1)
    {
        return RayCast(radius, Transform(v0, transform), input);
    }

    // Uses algorithm described at http://stackoverflow.com/a/565282/7410358
    //
    // The SO author gave the algorithm the following credit:
    //   "Intersection of two lines in three-space" by Ronald Goldman,
    //     published in Graphics Gems, page 304.

    // Solve for p + t r = q + u s
    
    // p is input.p1
    // q is the offset vertex
    // s is vertexDelta
    // r is rayDelta
    // t = (q - p) x s / (r x s)
    // u = (q - p) x r / (r x s)

    // Put the ray into the polygon's frame of reference.
    const auto transformedInput = RayCastInput{
        InverseTransform(input.p1, transform),
        InverseTransform(input.p2, transform),
        input.maxFraction
    };
    const auto ray0 = transformedInput.p1;
    const auto ray = transformedInput.p2 - transformedInput.p1; // Ray delta (p2 - p1)
    
    auto minT = nextafter(Real{input.maxFraction}, Real(2));
    auto normalFound = GetInvalid<UnitVec>();
    
    for (auto i = decltype(vertexCount){0}; i < vertexCount; ++i)
    {
        const auto circleResult = RayCast(radius, v0, transformedInput);
        if (circleResult.has_value() && (minT > circleResult->fraction))
        {
            minT = circleResult->fraction;
            normalFound = circleResult->normal;
        }

        const auto v1 = proxy.GetVertex(GetModuloNext(i, vertexCount));
        const auto edge = v1 - v0; // Vertex delta
        const auto ray_cross_edge = Cross(ray, edge);
        
        if (!AlmostZero(Real{ray_cross_edge / SquareMeter}))
        {
            const auto normal = proxy.GetNormal(i);
            const auto offset = normal * radius;
            const auto v0off = v0 + offset;
            const auto q_sub_p = v0off - ray0;
            
            const auto reciprocalRayCrossEdge = Real{1} / ray_cross_edge;

            // t = ((q - p) x s) / (r x s)
            const auto t = Cross(q_sub_p, edge) * reciprocalRayCrossEdge;
            
            // u = ((q - p) x r) / (r x s)
            const auto u = Cross(q_sub_p, ray) * reciprocalRayCrossEdge;

            if ((t >= 0) && (t <= 1) && (u >= 0) && (u <= 1))
            {
                // The two lines meet at the point p + t r = q + u s
                if (minT > t)
                {
                    minT = t;
                    normalFound = normal;
                }
            }
            else
            {
                // The two line segments are not parallel but do not intersect.
            }
        }
        else
        {
            // The two lines are parallel, ignored.
        }
        
        v0 = v1;
    }
    
    if (minT <= input.maxFraction)
    {
        return RayCastOutput{{Rotate(normalFound, transform.q), minT}};
    }
    return RayCastOutput{};
}

RayCastOutput RayCast(const Shape& shape, ChildCounter childIndex,
                      const RayCastInput& input, const Transformation& transform) noexcept
{
    return RayCast(GetChild(shape, childIndex), input, transform);
}

bool RayCast(const DynamicTree& tree, RayCastInput input, const DynamicTreeRayCastCB& callback)
{    
    const auto v = GetRevPerpendicular(GetUnitVector(input.p2 - input.p1, UnitVec::GetZero()));
    const auto abs_v = abs(v);
    auto segmentAABB = d2::GetAABB(input);
    
    GrowableStack<ContactCounter, 256> stack;
    stack.push(tree.GetRootIndex());
    while (!empty(stack))
    {
        const auto index = stack.top();
        stack.pop();
        if (index == DynamicTree::GetInvalidSize())
        {
            continue;
        }
        
        const auto aabb = tree.GetAABB(index);
        if (!TestOverlap(aabb, segmentAABB))
        {
            continue;
        }
        
        // Separating axis for segment (Gino, p80).
        // |dot(v, p1 - ctr)| > dot(|v|, extents)
        const auto center = GetCenter(aabb);
        const auto extents = GetExtents(aabb);
        const auto separation = abs(Dot(v, input.p1 - center)) - Dot(abs_v, extents);
        if (separation > 0_m)
        {
            continue;
        }
        
        if (DynamicTree::IsBranch(tree.GetHeight(index)))
        {
            const auto branchData = tree.GetBranchData(index);
            stack.push(branchData.child1);
            stack.push(branchData.child2);
        }
        else
        {
            assert(DynamicTree::IsLeaf(tree.GetHeight(index)));
            const auto leafData = tree.GetLeafData(index);
            const auto value = callback(leafData.fixture, leafData.childIndex, input);
            if (value == 0)
            {
                return true; // Callback has terminated the ray cast.
            }
            if (value > 0)
            {
                // Update segment bounding box.
                input.maxFraction = value;
                segmentAABB = d2::GetAABB(input);
            }
        }
    }
    return false;
}

bool RayCast(const DynamicTree& tree, const RayCastInput& rci, FixtureRayCastCB callback)
{
    return RayCast(tree, rci, [callback](Fixture* fixture, ChildCounter index, const RayCastInput& input) {
        const auto output = RayCast(GetChild(fixture->GetShape(), index), input,
                                    fixture->GetBody()->GetTransformation());
        if (output.has_value())
        {
            const auto fraction = output->fraction;
            assert(fraction >= 0 && fraction <= 1);
            
            // Here point can be calculated these two ways:
            //   (1) point = p1 * (1 - fraction) + p2 * fraction
            //   (2) point = p1 + (p2 - p1) * fraction.
            //
            // The first way however suffers from the fact that:
            //     a * (1 - fraction) + a * fraction != a
            // for all values of a and fraction between 0 and 1 when a and fraction are
            // floating point types.
            // This leads to the posibility that (p1 == p2) && (point != p1 || point != p2),
            // which may be pretty surprising to the callback. So this way SHOULD NOT be used.
            //
            // The second way, does not have this problem.
            //
            const auto point = input.p1 + (input.p2 - input.p1) * fraction;
            const auto opcode = callback(fixture, index, point, output->normal);
            switch (opcode)
            {
                case RayCastOpcode::Terminate: return Real{0};
                case RayCastOpcode::IgnoreFixture: return Real{-1};
                case RayCastOpcode::ClipRay: return Real{fraction};
                case RayCastOpcode::ResetRay: return Real{input.maxFraction};
            }
        }
        return Real{input.maxFraction};
    });
}

} // namespace d2
} // namespace playrho
