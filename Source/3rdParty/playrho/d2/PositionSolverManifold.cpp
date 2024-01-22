/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
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

#include "playrho/Math.hpp" // for Dot
#include "playrho/Vector2.hpp" // for Length2

#include "playrho/d2/Math.hpp"
#include "playrho/d2/PositionSolverManifold.hpp"
#include "playrho/d2/UnitVec.hpp"

namespace playrho::d2 {

namespace {

/// @brief Gets the position solver manifold in world coordinates for a circles-type manifold.
/// @param xfA Transformation for body A.
/// @param lp Local point. Location of shape A in local coordinates.
/// @param xfB Transformation for body B.
/// @param plp Point's local point. Location of shape B in local coordinates.
/// @note The returned separation is the magnitude of the positional difference of the two points.
///   This is always a non-negative amount.
inline PositionSolverManifold GetForCircles(const Transformation& xfA, const Length2& lp,
                                            const Transformation& xfB, const Length2& plp)
{
    const auto pointA = Transform(lp, xfA);
    const auto pointB = Transform(plp, xfB);
    const auto delta = pointB - pointA; // The edge from pointA to pointB
    const auto normal = GetUnitVector(delta, UnitVec::GetZero()); // The direction of the edge.
    const auto midpoint = (pointA + pointB) / Real{2};
    const auto separation = Dot(delta, normal); // The length of edge without doing sqrt again.
    return PositionSolverManifold{normal, midpoint, separation};
}

/// @brief Gets the position solver manifold in world coordinates for a face-a-type manifold.
/// @param xfA Transformation for shape A.
/// @param lp Local point. Location for shape A in local coordinates.
/// @param ln Local normal for shape A to be transformed into a world normal based on the
///   transformation for shape A.
/// @param xfB Transformation for shape B.
/// @param plp Point's local point. Location for shape B in local coordinates.
/// @return Separation is the dot-product of the positional difference between the two points in
///   the direction of the world normal.
inline PositionSolverManifold GetForFaceA(const Transformation& xfA, const Length2& lp, const UnitVec& ln,
                                          const Transformation& xfB, const Length2& plp)
{
    const auto planePoint = Transform(lp, xfA);
    const auto normal = Rotate(ln, xfA.q);
    const auto clipPoint = Transform(plp, xfB);
    const auto separation = Dot(clipPoint - planePoint, normal);
    return PositionSolverManifold{normal, clipPoint, separation};
}

/// @brief Gets the position solver manifold in world coordinates for a face-b-type manifold.
/// @param xfB Transformation for body B.
/// @param lp Local point.
/// @param ln Local normal for shape B to be transformed into a world normal based on the
///   transformation for shape B.
/// @param xfA Transformation for body A.
/// @param plp Point's local point. Location for shape A in local coordinates.
/// @return Separation is the dot-product of the positional difference between the two points in
///   the direction of the world normal.
inline PositionSolverManifold GetForFaceB(const Transformation& xfB, const Length2& lp, const UnitVec& ln,
                                          const Transformation& xfA, const Length2& plp)
{
    const auto planePoint = Transform(lp, xfB);
    const auto normal = Rotate(ln, xfB.q);
    const auto clipPoint = Transform(plp, xfA);
    const auto separation = Dot(clipPoint - planePoint, normal);
    // Negate normal to ensure the PSM normal points from A to B
    return PositionSolverManifold{-normal, clipPoint, separation};
}

} // unnamed namespace

// Documented here and in declaration because Doxygen seems to be unable to see this
// function's declaration Doxygen documentation. Not sure why.

/// @brief Gets the normal-point-separation data in world coordinates for the given inputs.
/// @note The returned normal is in the direction of shape A to shape B.
/// @note The returned separation distance does not account for vertex radiuses. It's simply
///   the separation between the points of the manifold. To account for the vertex radiuses,
///   the total vertex radius must be subtracted from this separation distance.
PositionSolverManifold GetPSM(const Manifold& manifold, Manifold::size_type index,
                              const Transformation& xfA, const Transformation& xfB)
{
    switch (manifold.GetType()) {
    case Manifold::e_circles:
        return GetForCircles(xfA, manifold.GetLocalPoint(),
                             xfB, manifold.GetPoint(index).localPoint);
    case Manifold::e_faceA:
        return GetForFaceA(xfA, manifold.GetLocalPoint(), manifold.GetLocalNormal(),
                           xfB, manifold.GetPoint(index).localPoint);
    case Manifold::e_faceB:
        return GetForFaceB(xfB, manifold.GetLocalPoint(), manifold.GetLocalNormal(),
                           xfA, manifold.GetPoint(index).localPoint);
    case Manifold::e_unset:
        break;
    }
    assert(manifold.GetType() == Manifold::e_unset);
    return PositionSolverManifold{UnitVec(), InvalidLength2, Invalid<Length>};
}

} // namespace playrho::d2
