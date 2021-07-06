/*
 * Original work Copyright (c) 2007-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Dynamics/Contacts/ConstraintSolverConf.hpp"

namespace playrho {

namespace {

template <class T>
constexpr auto cfloor(T v) noexcept
{
    assert(isfinite(v));
    return T((v >= T{}) ? static_cast<std::int64_t>(v) : static_cast<std::int64_t>(v) - 1);
}

/// @brief Constant expression enhanced floor function.
/// @note Unlike <code>std::floor</code>, this function is only defined for finite values.
/// @see https://en.cppreference.com/w/cpp/numeric/math/floor
#if defined(USE_BOOST_UNITS)
template <class Unit>
constexpr auto cfloor(const boost::units::quantity<Unit, Real>& v) noexcept
{
    using quantity = boost::units::quantity<Unit, Real>;
    return quantity::from_value(cfloor(v.value()));
}
#endif

} // namespace

Angle GetNormalized(Angle value) noexcept
{
    constexpr auto twoPi = Real(2) * Pi;
    constexpr auto rTwoPi = Real(1) / twoPi;
    auto angleInRadians = Real{value / Radian};
#if NORMALIZE_ANGLE_VIA_FMOD_MODULO
    // Note: std::fmod appears slower than std::trunc.
    //   See Benchmark ModuloViaFmod for data.
    angleInRadians = ModuloViaFmod(angleInRadians, twoPi);
    if (angleInRadians >= Pi) {
        // 190_deg becomes 190_deg - 360_deg = -170_deg
        angleInRadians -= Pi * 2;
    }
    else if (angleInRadians < -Pi) {
        // -200_deg becomes -200_deg + 360_deg = 100_deg
        angleInRadians += Pi * 2;
    }
    return angleInRadians * Radian;
#elif NORMALIZE_ANGLE_VIA_TRUNC_MODULO // previous way
    // Note: std::trunc appears more than twice as fast as std::fmod.
    //   See Benchmark ModuloViaTrunc for data.
    angleInRadians = ModuloViaTrunc(angleInRadians, twoPi);
    if (angleInRadians >= Pi) {
        // 190_deg becomes 190_deg - 360_deg = -170_deg
        angleInRadians -= Pi * 2;
    }
    else if (angleInRadians < -Pi) {
        // -200_deg becomes -200_deg + 360_deg = 100_deg
        angleInRadians += Pi * 2;
    }
    return angleInRadians * Radian;
#elif NORMALIZE_ANGLE_VIA_TWICE_TRUNC_MODULO
    // ((a % 360) + 540) % 360 - 180
    constexpr auto threePi = Pi * Real(3);
    return (ModuloViaTrunc((ModuloViaTrunc(angleInRadians, twoPi) + threePi), twoPi) - Pi) * 1_rad;
#elif NORMALIZE_ANGLE_VIA_CFLOOR
    // Fails with infinity
    // Fails with GetNormalized(angleInRadians * 1_rad)==GetNormalized(GetNormalized(angleInRadians
    // * 1_rad))
    //   for GetNormalized(angleInRadians * 1_rad)==-3.1415926535897936
    // GetNormalized(nextafter(+Pi * 1_rad, +Pi * 0_rad)) == -3.1415926535897936
    // GetNormalized(+Pi) == -3.1415926535897931
    // Eliminating a +Pi results in GetNormalized(GetNormalized(a)) != GetNormalized(a)
    //   at least for some double values like
    const auto shiftedAngleInRadians = angleInRadians + Pi;
    return ((shiftedAngleInRadians - twoPi * cfloor(shiftedAngleInRadians * rTwoPi)) - Pi) * 1_rad;
#else // newest & fastest way...
    // Note: Using this instead of NORMALIZE_ANGLE_VIA_TRUNC_MODULO requires changes to
    // World_Longer.TilesComesToRest unit test numbers.
    angleInRadians = angleInRadians - trunc(angleInRadians * rTwoPi) * twoPi;
    if (angleInRadians >= Pi) {
        // 190_deg becomes 190_deg - 360_deg = -170_deg
        angleInRadians -= Pi * 2;
    }
    else if (angleInRadians < -Pi) {
        // -200_deg becomes -200_deg + 360_deg = 100_deg
        angleInRadians += Pi * 2;
    }
    return angleInRadians * Radian;
#endif
}

Angle GetShortestDelta(Angle a0, Angle a1) noexcept
{
    // Note: atan2(sin(x-y), cos(x-y)) is probably the most accurate, albeit slowest
    // See https://stackoverflow.com/a/2007279/7410358
#if USE_SLOWER_ALGORITHM
    a0 = GetNormalized(a0);
    a1 = GetNormalized(a1);
    const auto a01 = a1 - a0;
    if (a01 > Pi * Radian) {
        // 190_deg becomes 190_deg - 360_deg = -170_deg
        return a01 - 2 * Pi * Radian;
    }
    if (a01 < -Pi * Radian) {
        // -200_deg becomes -200_deg + 360_deg = 100_deg
        return a01 + 2 * Pi * Radian;
    }
    return a01;
#elif USE_FASTER_ALGORITHM
    constexpr auto onePi = playrho::Pi * 1;
    constexpr auto twoPi = playrho::Pi * 2;
    constexpr auto threePi = playrho::Pi * 3;
    const auto da = playrho::Real{(a1 - a0) / playrho::Radian};
    return (ModuloViaTrunc(ModuloViaTrunc(da, twoPi) + threePi, twoPi) - onePi) * 1_rad;
#elif USE_ALMOST_FASTEST_ALGORITHM
    constexpr auto twoPi = Pi * 2;
    const auto da = ModuloViaTrunc(Real{(a1 - a0) / 1_rad}, twoPi);
    return (ModuloViaTrunc(2 * da, twoPi) - da) * 1_rad;
#else // use newest & fastest way...
    constexpr auto twoPi = Real(2) * Pi;
    constexpr auto rTwoPi = Real(1) / twoPi;
    const auto diff = a1 - a0;
    const auto da = diff - trunc(diff * rTwoPi) * twoPi;
    const auto two_da = da * 2;
    return (two_da - (trunc(two_da * rTwoPi) * twoPi)) - da;
#endif
}

Real Normalize(Vec2& vector)
{
    const auto length = GetMagnitude(vector);
    if (!AlmostZero(length)) {
        const auto invLength = Real{1} / length;
        vector[0] *= invLength;
        vector[1] *= invLength;
        return length;
    }
    return 0;
}

Length2 ComputeCentroid(const Span<const Length2>& vertices)
{
    assert(size(vertices) >= 3);

    auto c = Length2{} * 0_m2;
    auto area = 0_m2;

    // <code>pRef</code> is the reference point for forming triangles.
    // It's location doesn't change the result (except for rounding error).
    const auto pRef = Average(vertices);

    for (auto i = decltype(size(vertices)){0}; i < size(vertices); ++i) {
        // Triangle vertices.
        const auto p1 = pRef;
        const auto p2 = vertices[i];
        const auto p3 = vertices[GetModuloNext(i, size(vertices))];

        const auto e1 = p2 - p1;
        const auto e2 = p3 - p1;

        constexpr auto RealInverseOfTwo = Real{1} / Real{2};
        const auto triangleArea = Area{Cross(e1, e2) * RealInverseOfTwo};
        area += triangleArea;

        // Area weighted centroid
        constexpr auto RealInverseOfThree = Real{1} / Real{3};
        const auto aveP = (p1 + p2 + p3) * RealInverseOfThree;
        c += triangleArea * aveP;
    }

    // Centroid
    assert((area > 0_m2) && !AlmostZero(area / SquareMeter));
    return c / area;
}

std::vector<Length2> GetCircleVertices(Length radius, unsigned slices, Angle start, Real turns)
{
    std::vector<Length2> vertices;
    if (slices > 0) {
        const auto integralTurns = static_cast<long int>(turns);
        const auto wholeNum = (turns == static_cast<Real>(integralTurns));
        const auto deltaAngle = (Pi * 2_rad * turns) / static_cast<Real>(slices);
        auto i = decltype(slices){0};
        while (i < slices) {
            const auto angleInRadians =
                Real{(start + (static_cast<Real>(i) * deltaAngle)) / Radian};
            const auto x = radius * cos(angleInRadians);
            const auto y = radius * sin(angleInRadians);
            vertices.emplace_back(x, y);
            ++i;
        }
        if (wholeNum) {
            // Ensure whole circles come back to original point EXACTLY.
            vertices.push_back(vertices[0]);
        }
        else {
            const auto angleInRadians =
                Real{(start + (static_cast<Real>(i) * deltaAngle)) / Radian};
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
    for (auto i = decltype(count){0}; i < count; ++i) {
        const auto last_v = vertices[GetModuloPrev(i, count)];
        const auto this_v = vertices[i];
        const auto next_v = vertices[GetModuloNext(i, count)];
        sum += GetX(this_v) * (GetY(next_v) - GetY(last_v));
    }

    // Note that using the absolute value isn't necessary for vertices in counter-clockwise
    // ordering; only needed for clockwise ordering.
    constexpr auto RealInverseOfTwo = Real{1} / Real{2};
    return abs(sum) * RealInverseOfTwo;
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
    for (auto i = decltype(count){0}; i < count; ++i) {
        const auto this_v = vertices[i];
        const auto next_v = vertices[GetModuloNext(i, count)];
        const auto fact_b = Cross(this_v, next_v);
        sum_x += [&]() {
            const auto fact_a =
                Square(GetY(this_v)) + GetY(this_v) * GetY(next_v) + Square(GetY(next_v));
            return fact_a * fact_b;
        }();
        sum_y += [&]() {
            const auto fact_a =
                Square(GetX(this_v)) + GetX(this_v) * GetX(next_v) + Square(GetX(next_v));
            return fact_a * fact_b;
        }();
    }
    const auto secondMomentOfAreaX = SecondMomentOfArea{sum_x};
    const auto secondMomentOfAreaY = SecondMomentOfArea{sum_y};
    constexpr auto RealInverseOfTwelve = Real{1} / Real{12};
    return (secondMomentOfAreaX + secondMomentOfAreaY) * RealInverseOfTwelve;
}

namespace d2 {

Position GetPosition(Position pos0, Position pos1, Real beta) noexcept
{
    assert(IsValid(pos0));
    assert(IsValid(pos1));
    assert(IsValid(beta));

    // Note: have to be careful how this is done.
    //   If pos0 == pos1 then return value should always be equal to pos0 too.
    //   But if Real is float, pos0 * (1 - beta) + pos1 * beta can fail this requirement.
    //   Meanwhile, pos0 + (pos1 - pos0) * beta always works.

    // pos0 * (1 - beta) + pos1 * beta
    // pos0 - pos0 * beta + pos1 * beta
    // pos0 + (pos1 * beta - pos0 * beta)
    // pos0 + (pos1 - pos0) * beta

//#define USE_NORMALIZATION_FOR_ANGULAR_LERP 1
#if USE_NORMALIZATION_FOR_ANGULAR_LERP
    constexpr auto twoPi = Real(2) * Pi;
    constexpr auto rTwoPi = Real(1) / twoPi;
    const auto da = pos1.angular - pos0.angular;
    const auto na = pos0.angular + (da - twoPi * cfloor((da + Pi * 1_rad) * rTwoPi)) * beta;
    return {pos0.linear + (pos1.linear - pos0.linear) * beta,
            na - twoPi * cfloor((na + Pi * 1_rad) * rTwoPi)};
#elif USE_GETSHORTESTDELTA_FOR_ANGULAR_LERP
    // ~25% slower than USE_NORMALIZATION_FOR_ANGULAR_LERP
    return Position{pos0.linear + (pos1.linear - pos0.linear) * beta,
                    pos0.angular + GetShortestDelta(pos0.angular, pos1.angular) * beta};
#else
    // More than twice as fast as USE_NORMALIZATION_FOR_ANGULAR_LERP
    return pos0 + (pos1 - pos0) * beta;
#endif
}

Position Cap(Position pos, const ConstraintSolverConf& conf)
{
    if (const auto lsquared = GetMagnitudeSquared(pos.linear);
        lsquared > Square(conf.maxLinearCorrection)) {
        pos.linear *= conf.maxLinearCorrection / sqrt(lsquared);
    }
    pos.angular = std::clamp(pos.angular, -conf.maxAngularCorrection, +conf.maxAngularCorrection);
    return pos;
}

LinearVelocity2 GetContactRelVelocity(const Velocity velA, const Length2 relA, const Velocity velB,
                                      const Length2 relB) noexcept
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
