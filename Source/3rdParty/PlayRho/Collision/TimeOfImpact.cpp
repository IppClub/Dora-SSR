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

#include "PlayRho/Collision/TimeOfImpact.hpp"
#include "PlayRho/Collision/Distance.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/SeparationScenario.hpp"
#include "PlayRho/Dynamics/StepConf.hpp"
#include <algorithm>

namespace playrho {

const char *GetName(TOIOutput::State state) noexcept
{
    switch (state)
    {
        case TOIOutput::e_unknown: break;
        case TOIOutput::e_touching: return "touching";
        case TOIOutput::e_separated: return "separated";
        case TOIOutput::e_overlapped: return "overlapped";
        case TOIOutput::e_nextAfter: return "next-after";
        case TOIOutput::e_maxRootIters: return "max-root-iters";
        case TOIOutput::e_maxToiIters: return "max-toi-iters";
        case TOIOutput::e_belowMinTarget: return "below-min-target";
        case TOIOutput::e_maxDistIters: return "max-dist-iters";
        case TOIOutput::e_targetDepthExceedsTotalRadius: return "target-depth-exceeds-total-radius";
        case TOIOutput::e_minTargetSquaredOverflow: return "min-target-squared-overflow";
        case TOIOutput::e_maxTargetSquaredOverflow: return "max-target-squared-overflow";
        case TOIOutput::e_notFinite: return "not-finite";
    }
    assert(state == TOIOutput::e_unknown);
    return "unknown";
}

ToiConf GetToiConf(const StepConf& conf) noexcept
{
    return ToiConf{}
        .UseTimeMax(1)
        .UseTargetDepth(conf.targetDepth)
        .UseTolerance(conf.tolerance)
        .UseMaxRootIters(conf.maxToiRootIters)
        .UseMaxToiIters(conf.maxToiIters)
        .UseMaxDistIters(conf.maxDistanceIters);
}

namespace d2 {

TOIOutput GetToiViaSat(const DistanceProxy& proxyA, const Sweep& sweepA,
                       const DistanceProxy& proxyB, const Sweep& sweepB,
                       ToiConf conf)
{
    assert(IsValid(sweepA));
    assert(IsValid(sweepB));
    assert(sweepA.GetAlpha0() == sweepB.GetAlpha0());
    assert(conf.tMax >= 0 && conf.tMax <=1);

    // CCD via the local separating axis method. This seeks progression
    // by computing the largest time at which separation is maintained.
    
    auto stats = TOIOutput::Statistics{};
    
    const auto totalRadius = proxyA.GetVertexRadius() + proxyB.GetVertexRadius();
    if (conf.targetDepth > totalRadius)
    {
        return TOIOutput{0, stats, TOIOutput::e_targetDepthExceedsTotalRadius};
    }
    
    const auto target = totalRadius - conf.targetDepth;
    const auto maxTarget = std::max(target + conf.tolerance, 0_m);
    const auto minTarget = std::max(target - conf.tolerance, 0_m);
    
    const auto minTargetSquared = Square(minTarget);
    if (!isfinite(minTargetSquared) && isfinite(minTarget))
    {
        return TOIOutput{0, stats, TOIOutput::e_minTargetSquaredOverflow};
    }

    const auto maxTargetSquared = Square(maxTarget);
    if (!isfinite(maxTargetSquared) && isfinite(maxTarget))
    {
        return TOIOutput{0, stats, TOIOutput::e_maxTargetSquaredOverflow};
    }

    auto timeLo = Real{0}; // Will be set to value of timeHi
    auto timeLoXfA = GetTransformation(sweepA, timeLo);
    auto timeLoXfB = GetTransformation(sweepB, timeLo);

    // Prepare input for distance query.
    auto distanceConf = GetDistanceConf(conf);

    // The outer loop progressively attempts to compute new separating axes.
    // This loop terminates when an axis is repeated (no progress is made).
    while (stats.toi_iters < conf.maxToiIters)
    {
        // Get information on the distance between shapes. We can also use the results
        // to get a separating axis.
        const auto dinfo = Distance(proxyA, timeLoXfA, proxyB, timeLoXfB, distanceConf);
        ++stats.toi_iters;
        stats.sum_dist_iters += dinfo.iterations;
        stats.max_dist_iters = std::max(stats.max_dist_iters, dinfo.iterations);

        if (dinfo.state == DistanceOutput::HitMaxIters)
        {
            return TOIOutput{timeLo, stats, TOIOutput::e_maxDistIters};
        }
        assert(dinfo.state != DistanceOutput::Unknown);
        distanceConf.cache = Simplex::GetCache(dinfo.simplex.GetEdges());
        
        // Get the real distance squared between shapes at the time of timeLo.
        const auto distSquared = GetMagnitudeSquared(GetDelta(GetWitnessPoints(dinfo.simplex)));
#if 0
        if (!isfinite(distSquared))
        {
            return TOIOutput{timeLo, stats, TOIOutput::e_notFinite};
        }
#endif
        // If shapes closer at time timeLo than min-target squared, bail as overlapped.
        if (distSquared < minTargetSquared)
        {
            /// XXX maybe should return TOIOutput{timeLo, stats, TOIOutput::e_belowMinTarget}?
            return TOIOutput{timeLo, stats, TOIOutput::e_overlapped};
        }

        if (distSquared <= maxTargetSquared) // Victory!
        {
            // The two convex polygons are within the target range of each other at time timeLo!
            return TOIOutput{timeLo, stats, TOIOutput::e_touching};
        }

        // From here on, the real distance squared at time timeLo is > than maxTargetSquared

        // Initialize the separating axis.
        const auto fcn = GetSeparationScenario(distanceConf.cache.indices,
                                               proxyA, timeLoXfA, proxyB, timeLoXfB);

        // Compute the TOI on the separating axis. We do this by successively
        // resolving the deepest point. This loop is bounded by the number of vertices.
        auto timeHi = conf.tMax; // timeHi goes to values between timeLo and timeHi.
        auto timeHiXfA = GetTransformation(sweepA, timeHi);
        auto timeHiXfB = GetTransformation(sweepB, timeHi);

        auto pbIter = decltype(MaxShapeVertices){0};
        for (; pbIter < MaxShapeVertices; ++pbIter)
        {
            // Find the deepest point at timeHi. Store the witness point indices.
            const auto timeHiMinSep = FindMinSeparation(fcn, timeHiXfA, timeHiXfB);

            // Is the final configuration separated?
            if (timeHiMinSep.distance > maxTarget)
            {
                // Victory! No collision occurs within time span.
                assert(timeHi == conf.tMax);
                // Formerly this used tMax as in...
                // return TOIOutput{TOIOutput::e_separated, tMax};
                // timeHi seems more appropriate however given s2 was derived from it.
                // Meanwhile timeHi always seems equal to input.tMax at this point.
                stats.sum_finder_iters += pbIter;
                return TOIOutput{timeHi, stats, TOIOutput::e_separated};
            }

            // From here on, timeHiMinSep.distance <= maxTarget

            // Has the separation reached tolerance?
            if (timeHiMinSep.distance >= minTarget)
            {
                if (timeHi == timeLo)
                {
                    //
                    // Can't advance timeLo since timeHi already the same.
                    //
                    // This state happens when the real distance is greater than maxTarget but the
                    // timeHiMinSep distance is less than maxTarget. If function not stopped,
                    // it runs till stats.toi_iters == conf.maxToiIters and returns a failed state.
                    // Given that the function can't advance anymore, there's no need to run
                    // anymore. Additionally, given that timeLo is the same as timeHi and the real
                    // distance is separated, this function can return the separated state.
                    //
                    stats.sum_finder_iters += pbIter;
                    return TOIOutput{timeHi, stats, TOIOutput::e_separated};
                }

                // Advance the sweeps
                timeLo = timeHi;
                timeLoXfA = timeHiXfA;
                timeLoXfB = timeHiXfB;
                break;
            }

            // From here on timeHiMinSep.distance is < minTarget; i.e. at timeHi, shapes too close.

            // Compute the initial separation of the witness points.
            const auto timeLoEvalDistance = Evaluate(fcn, timeLoXfA, timeLoXfB,
                                                     timeHiMinSep.indices);

            // Check for initial overlap. Might happen if root finder runs out of iterations.
            //assert(s1 >= minTarget);
            // Check for touching
            if (timeLoEvalDistance <= maxTarget)
            {
                if (timeLoEvalDistance < minTarget)
                {
                    stats.sum_finder_iters += pbIter;
                    return TOIOutput{timeLo, stats, TOIOutput::e_belowMinTarget};
                }
                // Victory! timeLo should hold the TOI (could be 0.0).
                stats.sum_finder_iters += pbIter;
                return TOIOutput{timeLo, stats, TOIOutput::e_touching};
            }

            // Now: timeLoEvalDistance > maxTarget

            // Compute 1D root of: f(t) - target = 0
            auto a1 = timeLo;
            auto a2 = timeHi;
            auto s1 = timeLoEvalDistance;
            auto s2 = timeHiMinSep.distance;
            auto roots = decltype(conf.maxRootIters){0}; // counts # times f(t) checked
            auto t = timeLo;
            for (;;)
            {
                assert(!AlmostZero(s2 - s1));
                assert(a1 <= a2);

                auto state = TOIOutput::e_unknown;
                if (roots == conf.maxRootIters)
                {
                    state = TOIOutput::e_maxRootIters;
                }
                else if (nextafter(a1, a2) >= a2)
                {
                    state = TOIOutput::e_nextAfter;
                }
                if (state != TOIOutput::e_unknown)
                {
                    // Reached max root iterations or...
                    // Reached the limit of the Real type's precision!
                    // In this state, there's no way to make progress anymore.
                    // (a1 + a2) / 2 results in a1! So bail from function.
                    stats.sum_finder_iters += pbIter;
                    stats.sum_root_iters += roots;
                    stats.max_root_iters = std::max(stats.max_root_iters, roots);
                    return TOIOutput{t, stats, state};
                }

                // Uses secant to improve convergence & bisection to guarantee progress.
                t = IsOdd(roots)? Secant(target, a1, s1, a2, s2): Bisect(a1, a2);
                
                // Using secant method, t may equal a2 now.
                //assert(t != a1);
                ++roots;

                // If t == a1 or t == a2 then, there's a precision/rounding problem.
                // Accept that for now and keep going...

                const auto txfA = GetTransformation(sweepA, t);
                const auto txfB = GetTransformation(sweepB, t);
                const auto s = Evaluate(fcn, txfA, txfB, timeHiMinSep.indices);

                if (abs(s - target) <= conf.tolerance) // Root finding succeeded!
                {
                    assert(t != timeHi);
                    timeHi = t; // timeHi holds a tentative value for timeLo
                    timeHiXfA = txfA;
                    timeHiXfB = txfB;
                    break; // leave before roots can be == conf.maxRootIters
                }

                // Ensure we continue to bracket the root.
                if (s > target)
                {
                    a1 = t;
                    s1 = s;
                }
                else // s <= target
                {
                    a2 = t;
                    s2 = s;
                }
            }

            // Found a new timeHi: timeHi, timeHiXfA, and timeHiXfB have been updated.
            stats.sum_root_iters += roots;
            stats.max_root_iters = std::max(stats.max_root_iters, roots);
        }
        stats.sum_finder_iters += pbIter;
    }

    // stats.toi_iters == conf.maxToiIters
    // Root finder got stuck.
    // This can happen if the two shapes never actually collide within their sweeps.
    return TOIOutput{timeLo, stats, TOIOutput::e_maxToiIters};
}

} // namespace d2
} // namespace playrho
