/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_D2_DISTANCE_HPP
#define PLAYRHO_D2_DISTANCE_HPP

#include <cstdint> // for std::uint8_t
#include <utility> // for std::pair
#include <type_traits> // for std::remove_const_t

// IWYU pragma: begin_exports

#include "playrho/Settings.hpp" // for DefaultMaxDistanceIters

#include "playrho/d2/DistanceConf.hpp"
#include "playrho/d2/Math.hpp"
#include "playrho/d2/Simplex.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Pair of <code>Length2</code> values.
/// @note Uses <code>std::pair</code> because this is a pair and also because
///   <code>std::pair</code> has more support for constant expressions.
using PairLength2 = std::pair<Length2, Length2>;

namespace d2 {

class DistanceProxy;
struct Transformation;

/// @brief Gets the witness points of the given simplex.
PairLength2 GetWitnessPoints(const Simplex& simplex) noexcept;

/// @brief Gets the delta to go from the first element to the second.
constexpr Length2 GetDelta(PairLength2 arg) noexcept
{
    return std::get<1>(arg) - std::get<0>(arg);
}

/// @brief Distance Output.
struct DistanceOutput {
    /// @brief State of the distance output.
    enum State : std::uint8_t {
        Unknown,
        UnfitSearchDir,
        HitMaxIters,
        MaxPoints,
        DuplicateIndexPair,
    };

    /// @brief Iteration type.
    using iteration_type = std::remove_const_t<decltype(DefaultMaxDistanceIters)>;

    Simplex simplex; ///< Simplex.
    iteration_type iterations = 0; ///< Count of iterations performed to return result.
    State state = Unknown; ///< Termination state.
};

/// @brief Determines the closest points between two shapes using an iterative method.
/// @image html distance.png
/// @note Supports any combination of convex shapes.
/// @note Uses the G.J.K. (GJK) algorithm: "a method for determining the minimum distance
///   between two convex sets".
/// @note On the first call, <code>size(conf.cache.indices)</code> should be zero.
/// @param proxyA Proxy A.
/// @param transformA Transform of A.
/// @param proxyB Proxy B.
/// @param transformB Transform of B.
/// @param conf Configuration to use including the simplex cache for assisting the determination.
/// @relatedalso DistanceProxy
/// @return Closest points between the two shapes, the count of iterations it took to determine
///   them, and the reason iterations stopped. The iteration count will always be greater than zero
///   unless <code>DefaultMaxDistanceIters</code> is zero.
/// @see https://en.wikipedia.org/wiki/Gilbert%2DJohnson%2DKeerthi_distance_algorithm
/// @see GetMaxSeparation.
DistanceOutput Distance(const DistanceProxy& proxyA, const Transformation& transformA,
                        const DistanceProxy& proxyB, const Transformation& transformB,
                        DistanceConf conf = DistanceConf{});

/// @brief Determine if two generic shapes overlap.
///
/// @note The returned touching state information typically agrees with that returned from
///   the <code>CollideShapes</code> function. This is not always the case however
///   especially when the separation or overlap distance is closer to zero.
///
/// @relatedalso DistanceProxy
///
Area TestOverlap(const DistanceProxy& proxyA, const Transformation& xfA,
                 const DistanceProxy& proxyB, const Transformation& xfB,
                 DistanceConf conf = DistanceConf{});

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_D2_DISTANCE_HPP
