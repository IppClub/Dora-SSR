/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_COLLISION_TIMEOFIMPACT_HPP
#define PLAYRHO_COLLISION_TIMEOFIMPACT_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/Wider.hpp"
#include "PlayRho/Common/BoundedValue.hpp"

namespace playrho {

class StepConf;
    
/// @brief Time of impact configuration.
///
/// @details These parameters effect time of impact calculations by limiting the definitions
///    of time and impact. If total radius is expressed as TR, and target depth as TD, then:
///    the max target distance is (TR - TD) + tolerance; and the min target distance is
///    (TR - TD) - tolerance.
///
/// @note Max target distance must be less than or equal to the total radius as the target
///   range has to be chosen such that the contact manifold will have a greater than zero
///   contact point count.
/// @note A max target of <code>totalRadius - DefaultLinearSlop * x</code> where
///   <code>x is <= 1</code> is increasingly slower as x goes below 1.
/// @note Min target distance needs to be significantly less than the max target distance and
///   significantly more than 0.
///
/// @sa SolvePositionConstraints
/// @sa SolveTOIPositionConstraints
///
struct ToiConf
{
    /// @brief Root iteration type.
    using root_iter_type = std::remove_const<decltype(DefaultMaxToiRootIters)>::type;
    
    /// @brief TOI iteration type.
    using toi_iter_type = std::remove_const<decltype(DefaultMaxToiIters)>::type;

    /// @brief Distance iteration type.
    using dist_iter_type = std::remove_const<decltype(DefaultMaxDistanceIters)>::type;

    /// @brief Uses the given time max value.
    PLAYRHO_CONSTEXPR inline ToiConf& UseTimeMax(Real value) noexcept;

    /// @brief Uses the given target depth value.
    PLAYRHO_CONSTEXPR inline ToiConf& UseTargetDepth(Length value) noexcept;
    
    /// @brief Uses the given tolerance value.
    PLAYRHO_CONSTEXPR inline ToiConf& UseTolerance(NonNegative<Length> value) noexcept;
    
    /// @brief Uses the given max root iterations value.
    PLAYRHO_CONSTEXPR inline ToiConf& UseMaxRootIters(root_iter_type value) noexcept;
    
    /// @brief Uses the given max TOI iterations value.
    PLAYRHO_CONSTEXPR inline ToiConf& UseMaxToiIters(toi_iter_type value) noexcept;
    
    /// @brief Uses the given max distance iterations value.
    PLAYRHO_CONSTEXPR inline ToiConf& UseMaxDistIters(dist_iter_type value) noexcept;

    /// @brief T-Max.
    Real tMax = 1;
    
    /// @brief Targeted depth of impact.
    /// @note Value must be less than twice the minimum vertex radius of any shape.
    Length targetDepth = DefaultLinearSlop * Real{3};

    /// @brief Tolerance.
    /// @details Provides a +/- range from the target depth that defines a minimum and
    ///   maximum target depth within which inclusively, time of impact calculating code
    ///   is expected to return a "touching" status.
    /// @note Use the default value unless you really know what you're doing.
    /// @note Use 0 to require a TOI at exactly the target depth. This is ill-advised.
    NonNegative<Length> tolerance = NonNegative<Length>{DefaultLinearSlop / Real{4}};
    
    /// @brief Maximum number of root finder iterations.
    /// @details This is the maximum number of iterations for calculating the 1-dimensional
    ///   root of <code>f(t) - (totalRadius - targetDepth) < tolerance</code>
    /// where <code>f(t)</code> is the distance between the shapes at time <code>t</code>,
    /// and <code>totalRadius</code> is the sum of the vertex radiuses of 2 distance proxies.
    /// @note This value never needs to be more than the number of iterations needed to
    ///    achieve full machine precision.
    root_iter_type maxRootIters = DefaultMaxToiRootIters;
    
    toi_iter_type maxToiIters = DefaultMaxToiIters; ///< Max time of impact iterations.
    
    dist_iter_type maxDistIters = DefaultMaxDistanceIters; ///< Max distance iterations.
};

PLAYRHO_CONSTEXPR inline ToiConf& ToiConf::UseTimeMax(Real value) noexcept
{
    tMax = value;
    return *this;
}

PLAYRHO_CONSTEXPR inline ToiConf& ToiConf::UseTargetDepth(Length value) noexcept
{
    targetDepth = value;
    return *this;
}

PLAYRHO_CONSTEXPR inline ToiConf& ToiConf::UseTolerance(NonNegative<Length> value) noexcept
{
    tolerance = value;
    return *this;
}

PLAYRHO_CONSTEXPR inline ToiConf& ToiConf::UseMaxRootIters(root_iter_type value) noexcept
{
    maxRootIters = value;
    return *this;
}

PLAYRHO_CONSTEXPR inline ToiConf& ToiConf::UseMaxToiIters(toi_iter_type value) noexcept
{
    maxToiIters = value;
    return *this;
}

PLAYRHO_CONSTEXPR inline ToiConf& ToiConf::UseMaxDistIters(dist_iter_type value) noexcept
{
    maxDistIters = value;
    return *this;
}

/// @brief Gets the default time of impact configuration.
/// @relatedalso ToiConf
PLAYRHO_CONSTEXPR inline auto GetDefaultToiConf()
{
    return ToiConf{};
}

/// @brief Gets the time of impact configuration for the given step configuration.
ToiConf GetToiConf(const StepConf& conf) noexcept;

/// @brief Output data for time of impact.
struct TOIOutput
{
    /// @brief Time of impact statistics.
    struct Statistics
    {
        /// @brief TOI iterations type.
        using toi_iter_type = std::remove_const<decltype(DefaultMaxToiIters)>::type;
        
        /// @brief Distance iterations type.
        using dist_iter_type = std::remove_const<decltype(DefaultMaxDistanceIters)>::type;
        
        /// @brief Root iterations type.
        using root_iter_type = std::remove_const<decltype(DefaultMaxToiRootIters)>::type;
        
        /// @brief TOI iterations sum type.
        using toi_sum_type = Wider<toi_iter_type>::type;
        
        /// @brief Distance iterations sum type.
        using dist_sum_type = Wider<dist_iter_type>::type;
        
        /// @brief Root iterations sum type.
        using root_sum_type = Wider<root_iter_type>::type;

        // 6-bytes
        toi_sum_type sum_finder_iters = 0; ///< Sum total TOI iterations.
        dist_sum_type sum_dist_iters = 0; ///< Sum total distance iterations.
        root_sum_type sum_root_iters = 0; ///< Sum total of root finder iterations.

        // 3-bytes
        toi_iter_type toi_iters = 0; ///< Time of impact iterations.
        dist_iter_type max_dist_iters = 0; ///< Max. distance iterations count.
        root_iter_type max_root_iters = 0; ///< Max. root finder iterations for all TOI iterations.
    };
    
    /// @brief State.
    enum State: std::uint8_t
    {
        /// @brief Unknown.
        /// @details Unknown state.
        /// @note This is the default initialized state.
        e_unknown,
        
        /// @brief Touching.
        /// @details Indicates that the returned time of impact for two convex polygons
        ///   is for a time at which the two polygons are within the minimum and maximum
        ///   target range inclusively.
        /// @note This is a desirable result.
        /// @note Time of impact is the time when the two convex polygons "touch".
        e_touching,
        
        /// @brief Separated.
        /// @details Indicates that the two convex polygons never actually collide
        ///   during their defined sweeps.
        /// @note This is a desirable result.
        /// @note Time of impact in this case is <code>tMax</code> (which is typically 1).
        e_separated,
        
        /// @brief Overlapped.
        /// @details Indicates that the two convex polygons are closer to each other
        ///   at the returned time than the target depth range allows for.
        /// @note Can happen if total radius of the two convex polygons is too small.
        /// @note Can happen if the tolerance is too low.
        /// @note Time of impact is the time when the two convex polygons have already
        ///   collided too much.
        e_overlapped,

        /// @brief Max root iterations.
        /// @details Got to max number of root iterations allowed.
        /// @note Can happen if the configured max number of root iterations is too low.
        /// @note Can happen if the tolerance is too small.
        e_maxRootIters,
        
        /// @brief Next after.
        /// @note Can happen if the length moved is too much bigger than the tolerance.
        e_nextAfter,
        
        /// @brief Max TOI iterations.
        e_maxToiIters,
        
        /// @brief Below minimum target.
        e_belowMinTarget,
        
        /// @brief Max distance iterations.
        /// @details Indicates that the maximum number of distance iterations was done.
        /// @note Can happen if the configured max number of distance iterations was too low.
        e_maxDistIters,
        
        e_targetDepthExceedsTotalRadius,
        e_minTargetSquaredOverflow,
        e_maxTargetSquaredOverflow,
        
        e_notFinite,
    };
    
    /// @brief Default constructor.
    TOIOutput() = default;
    
    /// @brief Initializing constructor.
    TOIOutput(Real t, Statistics s, State z) noexcept: time{t}, stats{s}, state{z} {}

    Real time = 0; ///< Time factor in range of [0,1] into the future.
    Statistics stats; ///< Statistics.
    State state = e_unknown; ///< State at time factor.
};

/// @brief Gets a human readable name for the given output state.
const char *GetName(TOIOutput::State state) noexcept;

namespace d2 {

class DistanceProxy;

/// @brief Gets the time of impact for two disjoint convex sets using the
///    Separating Axis Theorem.
///
/// @details
/// Computes the upper bound on time before two shapes penetrate too much.
/// Time is represented as a fraction between [0,<code>tMax</code>].
/// This uses a swept separating axis and may miss some intermediate,
/// non-tunneling collision.
/// If you change the time interval, you should call this function again.
///
/// @sa https://en.wikipedia.org/wiki/Hyperplane_separation_theorem
/// @pre The given sweeps are both at the same alpha-0.
/// @warning Behavior is undefined if sweeps are not at the same alpha-0.
/// @warning Behavior is undefined if the configuration's <code>tMax</code> is not
///    between 0 and 1 inclusive.
/// @note Uses Distance to compute the contact point and normal at the time of impact.
/// @note This only works for two disjoint convex sets.
///
/// @param proxyA Proxy A. The proxy's vertex count must be 1 or more.
/// @param sweepA Sweep A. Sweep of motion for shape represented by proxy A.
/// @param proxyB Proxy B. The proxy's vertex count must be 1 or more.
/// @param sweepB Sweep B. Sweep of motion for shape represented by proxy B.
/// @param conf Configuration details for on calculation. Like the targeted depth of penetration.
///
/// @return Time of impact output data.
///
/// @relatedalso ::playrho::TOIOutput
///
TOIOutput GetToiViaSat(const DistanceProxy& proxyA, const Sweep& sweepA,
                       const DistanceProxy& proxyB, const Sweep& sweepB,
                       ToiConf conf = GetDefaultToiConf());

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_TIMEOFIMPACT_HPP
