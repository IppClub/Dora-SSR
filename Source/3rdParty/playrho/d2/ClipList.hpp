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

#ifndef PLAYRHO_D2_CLIPLIST_HPP
#define PLAYRHO_D2_CLIPLIST_HPP

/// @file
/// @brief Structures and functions used for computing clip lists.

// IWYU pragma: begin_exports

#include "playrho/ArrayList.hpp"
#include "playrho/ContactFeature.hpp"
#include "playrho/Settings.hpp"

#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief Clip vertex.
/// @details Used for computing contact manifolds.
struct ClipVertex
{
    Length2 v; ///< Vertex of edge or polygon.
    ContactFeature cf; ///< Contact feature information.
};

/// @brief Clip list for <code>ClipSegmentToLine</code>.
/// @see ClipSegmentToLine.
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

}

#endif /* PLAYRHO_D2_CLIPLIST_HPP */
