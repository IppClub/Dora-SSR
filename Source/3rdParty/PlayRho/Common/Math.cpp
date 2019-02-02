/*
 * Original work Copyright (c) 2007-2009 Erin Catto http://www.box2d.org
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

#include "PlayRho/Common/Math.hpp"

namespace playrho {

Angle GetDelta(Angle a1, Angle a2) noexcept
{
    a1 = GetNormalized(a1);
    a2 = GetNormalized(a2);
    const auto a12 = a2 - a1;
    if (a12 > Pi * Radian)
    {
        // 190_deg becomes 190_deg - 360_deg = -170_deg
        return a12 - 2 * Pi * Radian;
    }
    if (a12 < -Pi * Radian)
    {
        // -200_deg becomes -200_deg + 360_deg = 100_deg
        return a12 + 2 * Pi * Radian;
    }
    return a12;
}

Length2 ComputeCentroid(const Span<const Length2>& vertices)
{
    assert(size(vertices) >= 3);
    
    auto c = Length2{} * 0_m2;
    auto area = 0_m2;
    
    // <code>pRef</code> is the reference point for forming triangles.
    // It's location doesn't change the result (except for rounding error).
    const auto pRef = Average(vertices);

    for (auto i = decltype(size(vertices)){0}; i < size(vertices); ++i)
    {
        // Triangle vertices.
        const auto p1 = pRef;
        const auto p2 = vertices[i];
        const auto p3 = vertices[GetModuloNext(i, size(vertices))];
        
        const auto e1 = p2 - p1;
        const auto e2 = p3 - p1;
        
        const auto triangleArea = Area{Cross(e1, e2) / Real(2)};
        area += triangleArea;
        
        // Area weighted centroid
        const auto aveP = (p1 + p2 + p3) / Real{3};
        c += triangleArea * aveP;
    }
    
    // Centroid
    assert((area > 0_m2) && !AlmostZero(area / SquareMeter));
    return c / area;
}

std::vector<Length2> GetCircleVertices(Length radius, unsigned slices, Angle start, Real turns)
{
    std::vector<Length2> vertices;
    if (slices > 0)
    {
        const auto integralTurns = static_cast<long int>(turns);
        const auto wholeNum = (turns == static_cast<Real>(integralTurns));
        const auto deltaAngle = (Pi * 2_rad * turns) / static_cast<Real>(slices);
        auto i = decltype(slices){0};
        while (i < slices)
        {
            const auto angleInRadians = Real{(start + (static_cast<Real>(i) * deltaAngle)) / Radian};
            const auto x = radius * cos(angleInRadians);
            const auto y = radius * sin(angleInRadians);
            vertices.emplace_back(x, y);
            ++i;
        }
        if (wholeNum)
        {
            // Ensure whole circles come back to original point EXACTLY.
            vertices.push_back(vertices[0]);
        }
        else
        {
            const auto angleInRadians = Real{(start + (static_cast<Real>(i) * deltaAngle)) / Radian};
            const auto x = radius * cos(angleInRadians);
            const auto y = radius * sin(angleInRadians);
            vertices.emplace_back(x, y);
        }
    }
    return vertices;
}

NonNegative<Area> GetAreaOfCircle(Length radius)
{
    return Area{radius * radius * Pi};
}

NonNegative<Area> GetAreaOfPolygon(Span<const Length2> vertices)
{
    // Uses the "Shoelace formula".
    // See: https://en.wikipedia.org/wiki/Shoelace_formula
    auto sum = 0_m2;
    const auto count = size(vertices);
    for (auto i = decltype(count){0}; i < count; ++i)
    {
        const auto last_v = vertices[GetModuloPrev(i, count)];
        const auto this_v = vertices[i];
        const auto next_v = vertices[GetModuloNext(i, count)];
        sum += GetX(this_v) * (GetY(next_v) - GetY(last_v));
    }
    
    // Note that using the absolute value isn't necessary for vertices in counter-clockwise
    // ordering; only needed for clockwise ordering.
    return abs(sum) / Real{2};
}

SecondMomentOfArea GetPolarMoment(Span<const Length2> vertices)
{
    assert(size(vertices) > 2);
    
    // Use formulas Ix and Iy for second moment of area of any simple polygon and apply
    // the perpendicular axis theorem on these to get the desired answer.
    //
    // See:
    // https://en.wikipedia.org/wiki/Second_moment_of_area#Any_polygon
    // https://en.wikipedia.org/wiki/Second_moment_of_area#Perpendicular_axis_theorem
    auto sum_x = SquareMeter * SquareMeter * 0;
    auto sum_y = SquareMeter * SquareMeter * 0;
    const auto count = size(vertices);
    for (auto i = decltype(count){0}; i < count; ++i)
    {
        const auto this_v = vertices[i];
        const auto next_v = vertices[GetModuloNext(i, count)];
        const auto fact_b = Cross(this_v, next_v);
        sum_x += [&]() {
            const auto fact_a = Square(GetY(this_v)) + GetY(this_v) * GetY(next_v) + Square(GetY(next_v));
            return fact_a * fact_b;
        }();
        sum_y += [&]() {
            const auto fact_a = Square(GetX(this_v)) + GetX(this_v) * GetX(next_v) + Square(GetX(next_v));
            return fact_a * fact_b;
        }();
    }
    const auto secondMomentOfAreaX = SecondMomentOfArea{sum_x};
    const auto secondMomentOfAreaY = SecondMomentOfArea{sum_y};
    return (secondMomentOfAreaX + secondMomentOfAreaY) / Real{12};
}

namespace d2 {

LinearVelocity2 GetContactRelVelocity(const Velocity velA, const Length2 relA,
                                      const Velocity velB, const Length2 relB) noexcept
{
#if 0 // Using std::fma appears to be slower!
    const auto revPerpRelB = GetRevPerpendicular(relB);
    const auto xRevPerpRelB = StripUnit(revPerpRelB.x);
    const auto yRevPerpRelB = StripUnit(revPerpRelB.y);
    const auto angVelB = StripUnit(velB.angular);
    const auto xLinVelB = StripUnit(velB.linear.x);
    const auto yLinVelB = StripUnit(velB.linear.y);
    const auto xFmaB = std::fma(xRevPerpRelB, angVelB, xLinVelB);
    const auto yFmaB = std::fma(yRevPerpRelB, angVelB, yLinVelB);
    
    const auto revPerpRelA = GetRevPerpendicular(relA);
    const auto xRevPerpRelA = StripUnit(revPerpRelA.x);
    const auto yRevPerpRelA = StripUnit(revPerpRelA.y);
    const auto angVelA = StripUnit(velA.angular);
    const auto xLinVelA = StripUnit(velA.linear.x);
    const auto yLinVelA = StripUnit(velA.linear.y);
    const auto xFmaA = std::fma(xRevPerpRelA, angVelA, xLinVelA);
    const auto yFmaA = std::fma(yRevPerpRelA, angVelA, yLinVelA);
    
    const auto deltaFmaX = xFmaB - xFmaA;
    const auto deltaFmaY = yFmaB - yFmaA;
    
    return Vec2{deltaFmaX, deltaFmaY} * MeterPerSecond;
#else
    const auto velBrot = GetRevPerpendicular(relB) * (velB.angular / Radian);
    const auto velArot = GetRevPerpendicular(relA) * (velA.angular / Radian);
    return (velB.linear + velBrot) - (velA.linear + velArot);
#endif
}

} // namespace d2

} // namespace playrho
