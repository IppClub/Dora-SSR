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

#ifndef PLAYRHO_COLLISION_SHAPESEPARATION_HPP
#define PLAYRHO_COLLISION_SHAPESEPARATION_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Collision/IndexPair.hpp"

namespace playrho {
namespace d2 {

class DistanceProxy;

/// @brief Gets the max separation information.
/// @note Prefer using this function - over the <code>GetMaxSeparation</code>
///   function that takes a stopping length - when it's already known that the two
///   convex shapes' AABBs overlap.
/// @return Index of the vertex and normal from <code>proxy1</code>,
///   index of the vertex from <code>proxy2</code> (that had the maximum separation
///   distance from each other in the direction of that normal), and the maximal distance.
SeparationInfo GetMaxSeparation(const DistanceProxy& proxy1, Transformation xf1,
                                const DistanceProxy& proxy2, Transformation xf2);

/// @brief Gets the max separation information.
/// @return Index of the vertex and normal from <code>proxy1</code>,
///   index of the vertex from <code>proxy2</code> (that had the maximum separation
///   distance from each other in the direction of that normal), and the maximal distance.
SeparationInfo GetMaxSeparation(const DistanceProxy& proxy1, Transformation xf1,
                                const DistanceProxy& proxy2, Transformation xf2,
                                Length stop);

/// @brief Gets the max separation information for the first four vertices of the two
///   given shapes.
/// @details This is a version of the get-max-separation functions that is optimized for
///   two quadrilateral (4-sided) polygons.
/// @return Index of the vertex and normal from <code>proxy1</code>,
///   index of the vertex from <code>proxy2</code> (that had the maximum separation
///   distance from each other in the direction of that normal), and the maximal distance.
SeparationInfo GetMaxSeparation4x4(const DistanceProxy& proxy1, Transformation xf1,
                                   const DistanceProxy& proxy2, Transformation xf2);

/// @brief Gets the max separation information.
/// @return Index of the vertex and normal from <code>proxy1</code>,
///   index of the vertex from <code>proxy2</code> (that had the maximum separation
///   distance from each other in the direction of that normal), and the maximal distance.
SeparationInfo GetMaxSeparation(const DistanceProxy& proxy1,
                                const DistanceProxy& proxy2,
                                Length stop = MaxFloat * Meter);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_SHAPESEPARATION_HPP
