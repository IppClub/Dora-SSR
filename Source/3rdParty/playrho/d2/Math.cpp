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

#include <cassert> // for assert

#include "playrho/ConstraintSolverConf.hpp"

#include "playrho/d2/Math.hpp"

namespace playrho::d2 {

Position GetPosition(const Position& pos0, const Position& pos1, Real beta) noexcept
{
    assert(IsValid(pos0));
    assert(IsValid(pos1));

    // Note: have to be careful how this is done.
    //   If pos0 == pos1 then return value should always be equal to pos0 too.
    //   But if Real is float, pos0 * (1 - beta) + pos1 * beta can fail this requirement.
    //   Meanwhile, pos0 + (pos1 - pos0) * beta always works.

    // pos0 * (1 - beta) + pos1 * beta
    // pos0 - pos0 * beta + pos1 * beta
    // pos0 + (pos1 * beta - pos0 * beta)
    // pos0 + (pos1 - pos0) * beta

//#define USE_NORMALIZATION_FOR_ANGULAR_LERP 1
#if defined(USE_NORMALIZATION_FOR_ANGULAR_LERP)
    constexpr auto twoPi = Real(2) * Pi;
    constexpr auto rTwoPi = Real(1) / twoPi;
    const auto da = pos1.angular - pos0.angular;
    const auto na = pos0.angular + (da - twoPi * cfloor((da + Pi * 1_rad) * rTwoPi)) * beta;
    return {pos0.linear + (pos1.linear - pos0.linear) * beta,
            na - twoPi * cfloor((na + Pi * 1_rad) * rTwoPi)};
#elif defined(USE_GETSHORTESTDELTA_FOR_ANGULAR_LERP)
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

LinearVelocity2 GetContactRelVelocity(const Velocity& velA, const Length2& relA, const Velocity& velB,
                                      const Length2& relB) noexcept
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

std::vector<UnitVec> GetFwdNormalsVector(const std::vector<Length2>& vertices)
{
    auto normals = std::vector<UnitVec>();
    const auto count = static_cast<VertexCounter>(size(vertices));
    normals.reserve(count);
    if (count > 1) {
        // Compute normals.
        for (auto i = decltype(count){0}; i < count; ++i) {
            const auto nextIndex = GetModuloNext(i, count);
            const auto edge = vertices[nextIndex] - vertices[i];
            normals.push_back(GetUnitVector(GetFwdPerpendicular(edge)));
        }
    }
    else if (count == 1) {
        normals.emplace_back();
    }
    return normals;
}

} // namespace playrho::d2
