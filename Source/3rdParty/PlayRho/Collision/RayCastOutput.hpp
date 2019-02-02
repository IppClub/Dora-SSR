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

#ifndef PLAYRHO_COLLISION_RAYCASTOUTPUT_HPP
#define PLAYRHO_COLLISION_RAYCASTOUTPUT_HPP

/// @file
/// Declaration of the RayCastOutput structure and related free functions.

#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/OptionalValue.hpp"
#include "PlayRho/Collision/RayCastInput.hpp"

namespace playrho {
namespace detail {

template <std::size_t N>
struct AABB;

} // namespace detail

/// @brief Ray cast opcode enumeration.
/// @details Instructs some ray casting methods on what to do next.
enum class RayCastOpcode
{
    /// @brief End the ray-cast search for fixtures.
    /// @details Use this to stop searching for fixtures.
    Terminate,
    
    /// @brief Ignore the current fixture.
    /// @details Use this to continue searching for fixtures along the ray.
    IgnoreFixture,
    
    /// @brief Clip the ray end to the current point.
    /// @details Use this shorten the ray to the current point and to continue searching
    ///   for fixtures now along the newly shortened ray.
    ClipRay,
    
    /// @brief Reset the ray end back to the second point.
    /// @details Use this to restore the ray to its full length and to continue searching
    ///    for fixtures now along the restored full length ray.
    ResetRay
};

namespace d2 {

class Shape;
class Fixture;
class DistanceProxy;
class DynamicTree;

/// @brief Ray-cast hit data.
/// @details The ray hits at <code>p1 + fraction * (p2 - p1)</code>, where
///   <code>p1</code> and <code>p2</code> come from <code>RayCastInput</code>.
struct RayCastHit
{
    /// @brief Surface normal in world coordinates at the point of contact.
    UnitVec normal;
    
    /// @brief Fraction.
    /// @note This is a unit interval value - a value between 0 and 1 - or it's invalid.
    UnitInterval<Real> fraction = UnitInterval<Real>{0};
};

/// @brief Ray cast output.
/// @details This is a type alias for an optional <code>RayCastHit</code> instance.
/// @sa RayCast, Optional, RayCastHit
using RayCastOutput = Optional<RayCastHit>;

/// @brief Ray cast callback function.
/// @note Return 0 to terminate ray casting, or > 0 to update the segment bounding box.
using DynamicTreeRayCastCB = std::function<Real(Fixture* fixture, ChildCounter child,
                                                const RayCastInput& input)>;

/// @brief Ray cast callback function signature.
using FixtureRayCastCB = std::function<RayCastOpcode(Fixture* fixture, ChildCounter child,
                                                     Length2 point, UnitVec normal)>;

/// @defgroup RayCastGroup Ray Casting Functions
/// @brief Collection of functions that do ray casting.
/// @image html raycast.png
/// @{

/// @brief Cast a ray against a circle of a given radius at the given location.
/// @param radius Radius of the circle.
/// @param location Location in world coordinates of the circle.
/// @param input Ray-cast input parameters.
RayCastOutput RayCast(Length radius, Length2 location, const RayCastInput& input) noexcept;

/// @brief Cast a ray against the given AABB.
/// @param aabb Axis Aligned Bounding Box.
/// @param input the ray-cast input parameters.
RayCastOutput RayCast(const detail::AABB<2>& aabb, const RayCastInput& input) noexcept;

/// @brief Cast a ray against the distance proxy.
/// @param proxy Distance-proxy object (in local coordinates).
/// @param input Ray-cast input parameters.
/// @param transform Transform to be applied to the distance-proxy to get world coordinates.
/// @relatedalso DistanceProxy
RayCastOutput RayCast(const DistanceProxy& proxy, const RayCastInput& input,
                      const Transformation& transform) noexcept;

/// @brief Cast a ray against the child of the given shape.
/// @note This is a convenience function for calling the ray cast against a distance-proxy.
/// @param shape Shape.
/// @param childIndex Child index.
/// @param input the ray-cast input parameters.
/// @param transform Transform to be applied to the child of the shape.
/// @relatedalso Shape
RayCastOutput RayCast(const Shape& shape, ChildCounter childIndex,
                      const RayCastInput& input, const Transformation& transform) noexcept;

/// @brief Cast rays against the leafs in the given tree.
///
/// @note This relies on the callback to perform an exact ray-cast in the case where the
///    leaf node contains a shape.
/// @note The callback also performs collision filtering.
/// @note Performance is roughly k * log(n), where k is the number of collisions and n is the
///   number of leaf nodes in the tree.
///
/// @param tree Dynamic tree to ray cast.
/// @param input the ray-cast input data. The ray extends from <code>p1</code> to
///   <code>p1 + maxFraction * (p2 - p1)</code>.
/// @param callback A callback instance function that's called for each leaf that is hit
///   by the ray. The callback should return 0 to terminate ray casting, or greater than 0
///   to update the segment bounding box. Values less than zero are ignored.
///
/// @return <code>true</code> if terminated at the callback's request,
///   <code>false</code> otherwise.
///
bool RayCast(const DynamicTree& tree, RayCastInput input, const DynamicTreeRayCastCB& callback);

/// @brief Ray-cast the dynamic tree for all fixtures in the path of the ray.
///
/// @note The callback controls whether you get the closest point, any point, or n-points.
/// @note The ray-cast ignores shapes that contain the starting point.
///
/// @param tree Dynamic tree to ray cast.
/// @param input Ray cast input data.
/// @param callback A user implemented callback function.
///
/// @return <code>true</code> if terminated by callback, <code>false</code> otherwise.
///
bool RayCast(const DynamicTree& tree, const RayCastInput& input, FixtureRayCastCB callback);

/// @}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_RAYCASTOUTPUT_HPP

