/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COLLISION_SHAPES_MULTISHAPECONF_HPP
#define PLAYRHO_COLLISION_SHAPES_MULTISHAPECONF_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Collision/Shapes/ShapeConf.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/MassData.hpp"
#include <vector>

namespace playrho {
namespace d2 {

class VertexSet;

/// @brief Convex hull.
class ConvexHull
{
public:
    
    /// @brief Gets the convex hull for the given set of vertices.
    static ConvexHull Get(const VertexSet& pointSet, NonNegative<Length> vertexRadius =
                          NonNegative<Length>{DefaultLinearSlop * Real{2}});
    
    /// @brief Gets the distance proxy for this convex hull.
    DistanceProxy GetDistanceProxy() const
    {
        return DistanceProxy{
            vertexRadius, static_cast<VertexCounter>(size(vertices)),
            data(vertices), data(normals)
        };
    }
    
    /// @brief Gets the vertex radius of this convex hull.
    /// @return Non-negative distance.
    NonNegative<Length> GetVertexRadius() const noexcept
    {
        return vertexRadius;
    }
    
    /// @brief Transforms all the vertices by the given transformation matrix.
    /// @sa https://en.wikipedia.org/wiki/Transformation_matrix
    ConvexHull& Transform(const Mat22& m) noexcept;

    /// @brief Equality operator.
    friend bool operator== (const ConvexHull& lhs, const ConvexHull& rhs) noexcept
    {
        // No need to check normals - they're based on vertices.
        return lhs.vertexRadius == rhs.vertexRadius && lhs.vertices == rhs.vertices;
    }
    
    /// @brief Inequality operator.
    friend bool operator!= (const ConvexHull& lhs, const ConvexHull& rhs) noexcept
    {
        return !(lhs == rhs);
    }
    
private:
    /// @brief Initializing constructor.
    ConvexHull(std::vector<Length2> verts, std::vector<UnitVec> norms,
               NonNegative<Length> vr):
        vertices{verts}, normals{norms}, vertexRadius{vr}
    {}
    
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

/// @brief The "multi-shape" shape configuration.
/// @details Composes zero or more convex shapes into what can be a concave shape.
/// @ingroup PartsGroup
struct MultiShapeConf: public ShapeBuilder<MultiShapeConf>
{
    /// @brief Gets the default vertex radius for the <code>MultiShapeConf</code>.
    static PLAYRHO_CONSTEXPR inline NonNegative<Length> GetDefaultVertexRadius() noexcept
    {
        return NonNegative<Length>{DefaultLinearSlop * 2};
    }
    
    /// @brief Gets the default configuration for a <code>MultiShapeConf</code>.
    static inline MultiShapeConf GetDefaultConf() noexcept
    {
        return MultiShapeConf{};
    }
    
    inline MultiShapeConf():
        ShapeBuilder{ShapeConf{}}
    {
        // Intentionally empty.
    }
    
    /// Creates a convex hull from the given set of local points.
    /// The size of the set must be in the range [1, <code>MaxShapeVertices</code>].
    /// @warning the points may be re-ordered, even if they form a convex polygon
    /// @warning collinear points are handled but not removed. Collinear points
    ///   may lead to poor stacking behavior.
    MultiShapeConf& AddConvexHull(const VertexSet& pointSet, NonNegative<Length> vertexRadius =
                                  GetDefaultVertexRadius()) noexcept;
    
    /// @brief Transforms the vertices of all the children by the given transformation matrix.
    /// @sa https://en.wikipedia.org/wiki/Transformation_matrix
    MultiShapeConf& Transform(const Mat22& m) noexcept;

    std::vector<ConvexHull> children; ///< Children.
};

// Free functions...

/// @brief Equality operator.
inline bool operator== (const MultiShapeConf& lhs, const MultiShapeConf& rhs) noexcept
{
    return lhs.friction == rhs.friction && lhs.restitution == rhs.restitution
        && lhs.density == rhs.density && lhs.children == rhs.children;
}

/// @brief Inequality operator.
inline bool operator!= (const MultiShapeConf& lhs, const MultiShapeConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the "child" count for the given shape configuration.
inline ChildCounter GetChildCount(const MultiShapeConf& arg) noexcept
{
    return static_cast<ChildCounter>(size(arg.children));
}

/// @brief Gets the "child" shape for the given shape configuration.
inline DistanceProxy GetChild(const MultiShapeConf& arg, ChildCounter index)
{
    if (index >= GetChildCount(arg))
    {
        throw InvalidArgument("index out of range");
    }
    return arg.children[index].GetDistanceProxy();
}

/// @brief Gets the mass data for the given shape configuration.
MassData GetMassData(const MultiShapeConf& arg) noexcept;

/// @brief Gets the vertex radius of the given shape configuration.
inline NonNegative<Length> GetVertexRadius(const MultiShapeConf& arg, ChildCounter index)
{
    if (index >= GetChildCount(arg))
    {
        throw InvalidArgument("index out of range");
    }
    return arg.children[index].GetVertexRadius();
}

/// @brief Transforms the given multi shape configuration by the given
///   transformation matrix.
/// @sa https://en.wikipedia.org/wiki/Transformation_matrix
inline void Transform(MultiShapeConf& arg, const Mat22& m) noexcept
{
    arg.Transform(m);
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_SHAPES_MULTISHAPECONF_HPP
