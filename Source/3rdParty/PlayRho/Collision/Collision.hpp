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

#ifndef PLAYRHO_COLLISION_COLLISION_HPP
#define PLAYRHO_COLLISION_COLLISION_HPP

/// @file
/// Structures and functions used for computing contact points, distance
/// queries, and TOI queries.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/ArrayList.hpp"
#include "PlayRho/Collision/ContactFeature.hpp"

#include <array>
#include <type_traits>

namespace playrho {

/// @brief Point state enumeration.
/// @note This is used for determining the state of contact points.
enum class PointState
{
    NullState, ///< point does not exist
    AddState, ///< point was added in the update
    PersistState, ///< point persisted across the update
    RemoveState ///< point was removed in the update
};

/// @brief Point states.
/// @details The states pertain to the transition from an old manifold to a new manifold.
///   So state 1 is either persist or remove while state 2 is either add or persist.
struct PointStates
{
    /// @brief State 1.
    PointState state1[MaxManifoldPoints] = {PointState::NullState, PointState::NullState};
    
    /// @brief State 2.
    PointState state2[MaxManifoldPoints] = {PointState::NullState, PointState::NullState};
};

namespace d2 {

class Manifold;

/// @brief Computes the point states given two manifolds.
PointStates GetPointStates(const Manifold& manifold1, const Manifold& manifold2) noexcept;

/// @brief Clip vertex.
/// @details Used for computing contact manifolds.
/// @note This data structure is 12-bytes large (on at least one 64-bit platform).
struct ClipVertex
{
    Length2 v; ///< Vertex of edge or polygon. 8-bytes.
    ContactFeature cf; ///< Contact feature information. 4-bytes.
};

/// @brief Clip list for <code>ClipSegmentToLine</code>.
/// @sa ClipSegmentToLine.
/// @note This data structure is at least 24-bytes large.
using ClipList = ArrayList<ClipVertex, MaxManifoldPoints>;

/// Clipping for contact manifolds.
/// @details This returns an array of points from the given line that are inside of the plane as
///   defined by a given normal and offset.
/// @param vIn Clip list of two points defining the line.
/// @param normal Normal of the plane with which to determine intersection.
/// @param offset Offset of the plane with which to determine intersection.
/// @param indexA Index of vertex A.
/// @return List of zero one or two clip points.
ClipList ClipSegmentToLine(const ClipList& vIn, const UnitVec& normal, Length offset,
                           ContactFeature::Index indexA);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_COLLISION_HPP
