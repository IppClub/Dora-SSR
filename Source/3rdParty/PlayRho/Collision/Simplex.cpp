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

#include "PlayRho/Collision/Simplex.hpp"

namespace playrho {
namespace d2 {

IndexPair3 GetIndexPairs(const SimplexEdges& collection) noexcept
{
    auto list = IndexPair3{{InvalidIndexPair, InvalidIndexPair, InvalidIndexPair}};
    switch (size(collection))
    {
        case 3: list[2] = collection[2].GetIndexPair(); // fall through
        case 2: list[1] = collection[1].GetIndexPair(); // fall through
        case 1: list[0] = collection[0].GetIndexPair(); // fall through
    }
    return list;
}

Length2 CalcSearchDirection(const SimplexEdges& simplexEdges) noexcept
{
    switch (size(simplexEdges))
    {
        case 1:
        {
            return -GetPointDelta(simplexEdges[0]);
        }
        case 2:
        {
            const auto e12 = GetPointDelta(simplexEdges[1]) - GetPointDelta(simplexEdges[0]);
            const auto e0 = GetPointDelta(simplexEdges[0]);
            const auto sgn = Cross(e12, -e0);
            // If sgn > 0, then origin is left of e12, else origin is right of e12.
            return (sgn > 0_m2)? GetRevPerpendicular(e12): GetFwdPerpendicular(e12);
        }
        default:
            break;
    }
    assert(size(simplexEdges) < 4);
    return Length2{0_m, 0_m};
}

Simplex Simplex::Get(const SimplexEdge& s0) noexcept
{
    return Simplex{{s0}, {1}};
}

Simplex Simplex::Get(const SimplexEdge& s0, const SimplexEdge& s1) noexcept
{
    assert(s0.GetIndexPair() != s1.GetIndexPair() || s0 == s1);

    // Solves the given line segment simplex using barycentric coordinates.
    //
    // p = a1 * w1 + a2 * w2
    // a1 + a2 = 1
    //
    // The vector from the origin to the closest point on the line is
    // perpendicular to the line.
    // e12 = w2 - w1
    // dot(p, e) = 0
    // a1 * dot(w1, e) + a2 * dot(w2, e) = 0
    //
    // 2-by-2 linear system
    // [1      1     ][a1] = [1]
    // [w1.e12 w2.e12][a2] = [0]
    //
    // Define
    // d12_1 =  dot(w2, e12)
    // d12_2 = -dot(w1, e12)
    // d12_sum = d12_1 + d12_2
    //
    // Solution
    // a1 = d12_1 / d12_sum
    // a2 = d12_2 / d12_sum

    const auto w1 = GetPointDelta(s0);
    const auto w2 = GetPointDelta(s1);
    const auto e12 = w2 - w1;
    
    // w1 region
    const auto d12_2 = -Dot(w1, e12);
    if (d12_2 <= 0_m2)
    {
        // a2 <= 0, so we clamp it to 0
        return Simplex{{s0}, {1}};
    }
    
    // w2 region
    const auto d12_1 = Dot(w2, e12);
    if (d12_1 <= 0_m2)
    {
        // a1 <= 0, so we clamp it to 0
        return Simplex{{s1}, {1}};
    }
    
    // Must be in e12 region.
    const auto inv_sum = Real{1} / (d12_1 + d12_2);
    return Simplex{{s0, s1}, {d12_1 * inv_sum, d12_2 * inv_sum}};
}

Simplex Simplex::Get(const SimplexEdge& s0, const SimplexEdge& s1, const SimplexEdge& s2) noexcept
{
    // Solves the given 3-edge simplex.
    //
    // Possible regions:
    // - points[2]
    // - edge points[0]-points[2]
    // - edge points[1]-points[2]
    // - inside the triangle

    const auto w1 = GetPointDelta(s0);
    const auto w2 = GetPointDelta(s1);
    const auto w3 = GetPointDelta(s2);
    
    // Edge12
    // [1      1     ][a1] = [1]
    // [w1.e12 w2.e12][a2] = [0]
    // a3 = 0
    const auto e12 = w2 - w1;
    const auto d12_1 = Dot(w2, e12);
    const auto d12_2 = -Dot(w1, e12);
    
    // Edge13
    // [1      1     ][a1] = [1]
    // [w1.e13 w3.e13][a3] = [0]
    // a2 = 0
    const auto e13 = w3 - w1;
    const auto d13_1 = Dot(w3, e13);
    const auto d13_2 = -Dot(w1, e13);
    
    // Edge23
    // [1      1     ][a2] = [1]
    // [w2.e23 w3.e23][a3] = [0]
    // a1 = 0
    const auto e23 = w3 - w2;
    const auto d23_1 = Dot(w3, e23);
    const auto d23_2 = -Dot(w2, e23);
    
    // w1 region
    if ((d12_2 <= 0_m2) && (d13_2 <= 0_m2))
    {
        return Simplex{{s0}, {1}};
    }
    
    // w2 region
    if ((d12_1 <= 0_m2) && (d23_2 <= 0_m2))
    {
        return Simplex{{s1}, {1}};
    }
    
    // w3 region
    if ((d13_1 <= 0_m2) && (d23_1 <= 0_m2))
    {
        return Simplex{{s2}, {1}};
    }

    // Triangle123
    const auto n123 = Cross(e12, e13);

    // e12
    const auto cp_w1_w2 = Cross(w1, w2);
    const auto d123_3 = n123 * cp_w1_w2;
    if ((d12_1 > 0_m2) && (d12_2 > 0_m2) && (d123_3 <= 0 * SquareMeter * SquareMeter))
    {
        const auto inv_sum = Real{1} / (d12_1 + d12_2);
        return Simplex{{s0, s1}, {d12_1 * inv_sum, d12_2 * inv_sum}};
    }
    
    // e13
    const auto cp_w3_w1 = Cross(w3, w1);
    const auto d123_2 = n123 * cp_w3_w1;
    if ((d13_1 > 0_m2) && (d13_2 > 0_m2) && (d123_2 <= 0 * SquareMeter * SquareMeter))
    {
        const auto inv_sum = Real{1} / (d13_1 + d13_2);
        return Simplex{{s0, s2}, {d13_1 * inv_sum, d13_2 * inv_sum}};
    }
    
    // e23
    const auto cp_w2_w3 = Cross(w2, w3);
    const auto d123_1 = n123 * cp_w2_w3;
    if ((d23_1 > 0_m2) && (d23_2 > 0_m2) && (d123_1 <= 0 * SquareMeter * SquareMeter))
    {
        const auto inv_sum = Real{1} / (d23_1 + d23_2);
        return Simplex{{s2, s1}, {d23_2 * inv_sum, d23_1 * inv_sum}};
    }
    
    // Must be in triangle123
    const auto inv_sum = Real{1} / (d123_1 + d123_2 + d123_3);
    return Simplex{{s0, s1, s2}, {d123_1 * inv_sum, d123_2 * inv_sum, d123_3 * inv_sum}};
}

Simplex Simplex::Get(const SimplexEdges& edges) noexcept
{
    const auto count = edges.size();
    assert(count < 4);
    switch (count)
    {
        case 1: return Get(edges[0]);
        case 2: return Get(edges[0], edges[1]);
        case 3: return Get(edges[0], edges[1], edges[2]);
        default: break; // should be zero in this case
    }
    return Simplex{};
}

Real Simplex::CalcMetric(const SimplexEdges& simplexEdges)
{
    assert(simplexEdges.size() < 4);
    switch (simplexEdges.size())
    {
        case 1: return Real{0};
        case 2:
        {
            const auto delta = GetPointDelta(simplexEdges[1]) - GetPointDelta(simplexEdges[0]);
            return StripUnit(GetMagnitude(delta)); // Length
        }
        case 3:
        {
            const auto delta10 = GetPointDelta(simplexEdges[1]) - GetPointDelta(simplexEdges[0]);
            const auto delta20 = GetPointDelta(simplexEdges[2]) - GetPointDelta(simplexEdges[0]);
            return StripUnit(Cross(delta10, delta20)); // Area
        }
        default: break; // should be zero in this case
    }
    return Real{0};
}

} // namespace d2
} // namespace playrho
