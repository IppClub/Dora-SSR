/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/Shapes/Shape.hpp"
#include <algorithm>
#include <iterator>

namespace playrho {
namespace d2 {

bool operator== (const DistanceProxy& lhs, const DistanceProxy& rhs) noexcept
{
    if (lhs.GetVertexRadius() != rhs.GetVertexRadius())
    {
        return false;
    }

    // No need to compare normals since they should be invariant to the vertices.
    const auto lhr = lhs.GetVertices();
    const auto rhr = rhs.GetVertices();
    return std::equal(cbegin(lhr), cend(lhr), cbegin(rhr), cend(rhr));
}

std::size_t FindLowestRightMostVertex(Span<const Length2> vertices)
{
    if (const auto numVertices = size(vertices); numVertices > 0)
    {
        auto i0 = decltype(numVertices){0};
        auto max_x = GetX(vertices[0]);
        for (auto i = decltype(numVertices){1}; i < numVertices; ++i)
        {
            const auto x = GetX(vertices[i]);
            if ((max_x < x) || ((max_x == x) && (GetY(vertices[i]) < GetY(vertices[i0]))))
            {
                max_x = x;
                i0 = i;
            }
        }
        return i0;
    }
    return GetInvalid<std::size_t>();
}

std::vector<Length2> GetConvexHullAsVector(Span<const Length2> vertices)
{
    auto result = std::vector<Length2>{};
    
    // Create the convex hull using the Gift wrapping algorithm
    // http://en.wikipedia.org/wiki/Gift_wrapping_algorithm
    
    const auto index0 = FindLowestRightMostVertex(vertices);
    if (index0 != GetInvalid<std::size_t>())
    {
        const auto numVertices = size(vertices);
        auto hull = std::vector<decltype(size(vertices))>();
        
        auto ih = index0;
        for (;;)
        {
            hull.push_back(ih);
            
            auto ie = decltype(numVertices){0};
            for (auto j = decltype(numVertices){1}; j < numVertices; ++j)
            {
                if (ie == ih)
                {
                    ie = j;
                    continue;
                }
                
                const auto r = vertices[ie] - vertices[ih];
                const auto v = vertices[j] - vertices[ih];
                const auto c = Cross(r, v);
                if ((c < 0_m2) || ((c == 0_m2) && (GetMagnitudeSquared(v) > GetMagnitudeSquared(r))))
                {
                    ie = j;
                }
            }
            
            ih = ie;
            if (ie == index0)
            {
                break;
            }
        }
        
        const auto count = size(hull);
        for (auto i = decltype(count){0}; i < count; ++i)
        {
            result.emplace_back(vertices[hull[i]]);
        }
    }
    
    return result;
}

bool TestPoint(const DistanceProxy& proxy, Length2 point) noexcept
{
    const auto count = proxy.GetVertexCount();
    const auto vr = proxy.GetVertexRadius();

    switch (count)
    {
        case 0:
            return false;
        case 1:
        {
            const auto v0 = proxy.GetVertex(0);
            const auto delta = point - v0;
            return GetMagnitudeSquared(delta) <= Square(vr);
        }
        default:
            break;
    }
    
    auto maxDot = -MaxFloat * Meter;
    auto maxIdx = static_cast<decltype(count)>(-1);
    for (auto i = decltype(count){0}; i < count; ++i)
    {
        const auto vi = proxy.GetVertex(i);
        const auto delta = point - vi;
        const auto dot = Dot(proxy.GetNormal(i), delta);
        if (dot > vr)
        {
            return false;
        }
        if (maxDot < dot)
        {
            maxDot = dot;
            maxIdx = i;
        }
    }
    assert(maxIdx < count);
    
    const auto v0 = proxy.GetVertex(maxIdx);
    const auto v1 = proxy.GetVertex(GetModuloNext(maxIdx, count));
    const auto edge = v1 - v0;
    if (const auto delta0 = v0 - point; Dot(edge, delta0) >= 0_m2)
    {
        // point is nearest v0 and not within edge
        return GetMagnitudeSquared(delta0) <= Square(vr);
    }
    if (const auto delta1 = point - v1; Dot(edge, delta1) >= 0_m2)
    {
        // point is nearest v1 and not within edge
        return GetMagnitudeSquared(delta1) <= Square(vr);
    }
    return true;
}

} // namespace d2
} // namespace playrho
