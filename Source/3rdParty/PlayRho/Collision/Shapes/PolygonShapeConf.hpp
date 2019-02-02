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

#ifndef PLAYRHO_COLLISION_SHAPES_POLYGONSHAPECONF_HPP
#define PLAYRHO_COLLISION_SHAPES_POLYGONSHAPECONF_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Collision/Shapes/ShapeConf.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/MassData.hpp"
#include "PlayRho/Common/VertexSet.hpp"
#include <type_traits>
#include <vector>

namespace playrho {
namespace d2 {

/// @brief Polygon shape configuration.
/// @details A convex polygon. The interior of the polygon is to the left of each edge.
///   Polygons maximum number of vertices is defined by <code>MaxShapeVertices</code>.
///   In most cases you should not need many vertices for a convex polygon.
/// @image html convex_concave.gif
/// @note This data structure is 64-bytes large (with 4-byte Real).
/// @ingroup PartsGroup
class PolygonShapeConf: public ShapeBuilder<PolygonShapeConf>
{
public:
    /// @brief Gets the default vertex radius for the <code>PolygonShapeConf</code>.
    static PLAYRHO_CONSTEXPR inline NonNegative<Length> GetDefaultVertexRadius() noexcept
    {
        return NonNegative<Length>{DefaultLinearSlop * 2};
    }
    
    /// @brief Gets the default configuration for a <code>PolygonShapeConf</code>.
    static inline PolygonShapeConf GetDefaultConf() noexcept
    {
        return PolygonShapeConf{};
    }
    
    PolygonShapeConf();
    
    /// @brief Initializing constructor for a 4-sided box polygon.
    PolygonShapeConf(Length hx, Length hy,
                     const PolygonShapeConf& conf = GetDefaultConf()) noexcept;
    
    /// @brief Creates a convex hull from the given array of local points.
    /// @note The size of the span must be in the range [1, <code>MaxShapeVertices</code>].
    /// @warning the points may be re-ordered, even if they form a convex polygon
    /// @warning collinear points are handled but not removed. Collinear points
    /// may lead to poor stacking behavior.
    explicit PolygonShapeConf(Span<const Length2> points,
                              const PolygonShapeConf& conf = GetDefaultConf()) noexcept;
    
    /// @brief Uses the given vertex radius.
    PolygonShapeConf& UseVertexRadius(NonNegative<Length> value) noexcept;

    /// @brief Uses the given vertices.
    PolygonShapeConf& UseVertices(const std::vector<Length2>& verts) noexcept;
    
    /// @brief Sets the vertices to represent an axis-aligned box centered on the local origin.
    /// @param hx the half-width.
    /// @param hy the half-height.
    PolygonShapeConf& SetAsBox(Length hx, Length hy) noexcept;
    
    /// @brief Sets the vertices for the described box.
    PolygonShapeConf& SetAsBox(Length hx, Length hy, Length2 center, Angle angle) noexcept;
    
    /// @brief Sets the vertices to a convex hull of the given ones.
    /// @note The size of the span must be in the range [1, <code>MaxShapeVertices</code>].
    /// @warning Points may be re-ordered, even if they form a convex polygon
    /// @warning Collinear points are handled but not removed. Collinear points
    ///   may lead to poor stacking behavior.
    PolygonShapeConf& Set(Span<const Length2> verts) noexcept;
    
    /// @brief Sets the vertices to a convex hull of the given ones.
    /// @note The size of the span must be in the range [1, <code>MaxShapeVertices</code>].
    /// @warning Points may be re-ordered, even if they form a convex polygon
    /// @warning Collinear points are handled but not removed. Collinear points
    ///   may lead to poor stacking behavior.
    PolygonShapeConf& Set(const VertexSet& points) noexcept;
    
    /// @brief Transforms the vertices by the given transformation.
    PolygonShapeConf& Transform(Transformation xfm) noexcept;
    
    /// @brief Transforms the vertices by the given transformation matrix.
    /// @sa https://en.wikipedia.org/wiki/Transformation_matrix
    PolygonShapeConf& Transform(const Mat22& m) noexcept;

    /// @brief Equality operator.
    friend bool operator== (const PolygonShapeConf& lhs, const PolygonShapeConf& rhs) noexcept
    {
        // Don't need to check normals nor centroid since they based on vertices.
        return lhs.vertexRadius == rhs.vertexRadius && lhs.friction == rhs.friction
            && lhs.restitution == rhs.restitution && lhs.density == rhs.density
            && lhs.m_vertices == rhs.m_vertices;
    }
    
    /// @brief Inequality operator.
    friend bool operator!= (const PolygonShapeConf& lhs, const PolygonShapeConf& rhs) noexcept
    {
        return !(lhs == rhs);
    }
    
    /// Gets the vertex count.
    /// @return value between 0 and <code>MaxShapeVertices</code> inclusive.
    /// @see MaxShapeVertices
    VertexCounter GetVertexCount() const noexcept
    {
        return static_cast<VertexCounter>(size(m_vertices));
    }
    
    /// Gets a vertex by index.
    /// @details Vertices go counter-clockwise.
    Length2 GetVertex(VertexCounter index) const
    {
        assert(0 <= index && index < GetVertexCount());
        return m_vertices[index];
    }
    
    /// Gets a normal by index.
    /// @details
    /// These are 90-degree clockwise-rotated (outward-facing) unit-vectors of the edges defined
    /// by consecutive pairs of vertices starting with vertex 0.
    /// @param index Index of the normal to get.
    /// @return Normal for the given index.
    UnitVec GetNormal(VertexCounter index) const
    {
        assert(0 <= index && index < GetVertexCount());
        return m_normals[index];
    }
    
    /// Gets the span of vertices.
    /// @details Vertices go counter-clockwise.
    Span<const Length2> GetVertices() const noexcept
    {
        return Span<const Length2>(&m_vertices[0], GetVertexCount());
    }
    
    /// @brief Gets the span of normals.
    Span<const UnitVec> GetNormals() const noexcept
    {
        return Span<const UnitVec>(&m_normals[0], GetVertexCount());
    }
    
    /// @brief Gets the centroid.
    Length2 GetCentroid() const noexcept { return m_centroid; }
    
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
    NonNegative<Length> vertexRadius = GetDefaultVertexRadius();
    
private:
    /// @brief Array of vertices.
    /// @details Consecutive vertices constitute "edges" of the polygon.
    std::vector<Length2> m_vertices;
    
    /// @brief Normals of edges.
    /// @details These are 90-degree clockwise-rotated unit-vectors of the vectors defined
    ///   by consecutive pairs of elements of vertices.
    std::vector<UnitVec> m_normals;
    
    /// Centroid of this shape.
    Length2 m_centroid = GetInvalid<Length2>();
};

inline PolygonShapeConf& PolygonShapeConf::UseVertexRadius(NonNegative<Length> value) noexcept
{
    vertexRadius = value;
    return *this;
}

// Free functions...

/// @brief Gets the "child" count for the given shape configuration.
/// @return 1.
PLAYRHO_CONSTEXPR inline ChildCounter GetChildCount(const PolygonShapeConf&) noexcept
{
    return 1;
}

/// @brief Gets the "child" shape for the given shape configuration.
inline DistanceProxy GetChild(const PolygonShapeConf& arg, ChildCounter index)
{
    if (index != 0)
    {
        throw InvalidArgument("only index of 0 is supported");
    }
    return DistanceProxy{arg.vertexRadius, arg.GetVertexCount(),
        data(arg.GetVertices()), data(arg.GetNormals())};
}

/// @brief Gets the vertex radius of the given shape configuration.
inline NonNegative<Length> GetVertexRadius(const PolygonShapeConf& arg) noexcept
{
    return arg.vertexRadius;
}

/// @brief Gets the vertex radius of the given shape configuration.
inline NonNegative<Length> GetVertexRadius(const PolygonShapeConf& arg, ChildCounter) noexcept
{
    return GetVertexRadius(arg);
}

/// @brief Gets the mass data for the given shape configuration.
inline MassData GetMassData(const PolygonShapeConf& arg) noexcept
{
    return playrho::d2::GetMassData(arg.vertexRadius, arg.density, arg.GetVertices());
}

/// Gets the identified edge of the given polygon shape.
/// @note This must not be called for shapes with less than 2 vertices.
/// @warning Behavior is undefined if called for a shape with less than 2 vertices.
/// @relatedalso PolygonShapeConf
Length2 GetEdge(const PolygonShapeConf& shape, VertexCounter index);

/// @brief Transforms the given polygon configuration's vertices by the given
///   transformation matrix.
/// @sa https://en.wikipedia.org/wiki/Transformation_matrix
inline void Transform(PolygonShapeConf& arg, const Mat22& m) noexcept
{
    arg.Transform(m);
}

/// @brief Validates the convexity of the given collection of vertices.
/// @note This is a time consuming operation.
/// @returns <code>true</code> if the given collection of vertices is indeed convex,
///   <code>false</code> otherwise.
bool Validate(const Span<const Length2> verts);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_SHAPES_POLYGONSHAPECONF_HPP
