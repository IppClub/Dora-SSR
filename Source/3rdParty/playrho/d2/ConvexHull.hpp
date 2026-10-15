/*
 * Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_D2_SHAPES_CONVEXHULL_HPP
#define PLAYRHO_D2_SHAPES_CONVEXHULL_HPP

/// @file
/// @brief Definition of the @c ConvexHull class and closely related code.

#include <utility> // for std::move
#include <vector>

// IWYU pragma: begin_exports

#include "playrho/NonNegative.hpp"
#include "playrho/Settings.hpp"
#include "playrho/Templates.hpp"

#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

class VertexSet;

/// @brief Convex hull.
class ConvexHull
{
public:
    /// @brief Gets the convex hull for the given set of vertices.
    static ConvexHull Get(const VertexSet& pointSet,
                          NonNegative<Length> vertexRadius = NonNegative<Length>{DefaultLinearSlop *
                                                                                 Real{2}});

    /// @brief Gets the distance proxy for this convex hull.
    DistanceProxy GetDistanceProxy() const
    {
        return DistanceProxy{vertexRadius, static_cast<VertexCounter>(size(vertices)),
                             data(vertices), data(normals)};
    }

    /// @brief Gets the vertex radius of this convex hull.
    /// @return Non-negative distance.
    /// @see SetVertexRadius.
    NonNegative<Length> GetVertexRadius() const noexcept
    {
        return vertexRadius;
    }

    /// @brief Sets the vertex radius of this convex hull.
    /// @see GetVertexRadius.
    void SetVertexRadius(NonNegative<Length> value) noexcept
    {
        vertexRadius = value;
    }

    /// @brief Translates all the vertices by the given amount.
    ConvexHull& Translate(const Length2& value);

    /// @brief Scales all the vertices by the given amount.
    ConvexHull& Scale(const Vec2& value);

    /// @brief Rotates all the vertices by the given amount.
    ConvexHull& Rotate(const UnitVec& value);

    /// @brief Equality operator.
    friend bool operator==(const ConvexHull& lhs, const ConvexHull& rhs) noexcept
    {
        // No need to check normals - they're based on vertices.
        return lhs.vertexRadius == rhs.vertexRadius && lhs.vertices == rhs.vertices;
    }

    /// @brief Inequality operator.
    friend bool operator!=(const ConvexHull& lhs, const ConvexHull& rhs) noexcept
    {
        return !(lhs == rhs);
    }

private:
    /// @brief Initializing constructor.
    ConvexHull(std::vector<Length2> verts, std::vector<UnitVec> norms, NonNegative<Length> vr)
        : vertices{std::move(verts)}, normals{std::move(norms)}, vertexRadius{vr}
    {
    }

    /// Array of vertices.
    /// @details Consecutive vertices constitute "edges" of the polygon.
    std::vector<Length2> vertices;

    /// Normals of edges.
    /// @details
    /// These are 90-degree clockwise-rotated unit-vectors of the vectors defined by
    /// consecutive pairs of elements of vertices.
    std::vector<UnitVec> normals;

    /// @brief Vertex radius.
    ///
    /// @details This is the radius from the vertex that the shape's "skin" should
    ///   extend outward by. While any edges &mdash; line segments between multiple
    ///   vertices &mdash; are straight, corners between them (the vertices) are
    ///   rounded and treated as rounded. Shapes with larger vertex radiuses compared
    ///   to edge lengths therefore will be more prone to rolling or having other
    ///   shapes more prone to roll off of them.
    ///
    /// @note This should be a non-negative value.
    ///
    NonNegative<Length> vertexRadius;
};

} // namespace playrho::d2

#endif // PLAYRHO_D2_SHAPES_CONVEXHULL_HPP
