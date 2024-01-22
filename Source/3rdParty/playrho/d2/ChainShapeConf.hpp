/*
 * Original work Copyright (c) 2006-2010 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_D2_SHAPES_CHAINSHAPECONF_HPP
#define PLAYRHO_D2_SHAPES_CHAINSHAPECONF_HPP

/// @file
/// @brief Definition of the @c ChainShapeConf class and closely related code.

#include <cassert>
#include <vector>

// IWYU pragma: begin_exports

#include "playrho/NonNegative.hpp"
#include "playrho/Templates.hpp"
#include "playrho/TypeInfo.hpp"

#include "playrho/d2/ShapeConf.hpp"
#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/Math.hpp"
#include "playrho/d2/AABB.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief Chain shape configuration.
/// @details A chain shape is a free form sequence of line segments.
///   The chain has two-sided collision, so you can use inside and outside collision.
///   Therefore, you may use any winding order.
///   Since there may be many vertices, they are allocated on the memory heap.
/// @image html Chain1.png
/// @image html SelfIntersect.png
/// @warning The chain will not collide properly if there are self-intersections.
/// @ingroup PartsGroup
struct ChainShapeConf : public ShapeBuilder<ChainShapeConf>
{
    /// @invariant The normals provided are always the forward & reverse normals of each
    ///   segment of the assigned vertices.
    class VerticesWithNormals {
        std::vector<Length2> m_vertices{}; ///< Vertices
        std::vector<UnitVec> m_normals{}; ///< Normals.
    public:
        /// @brief Default constructor.
        VerticesWithNormals() noexcept = default;

        /// @brief Initializing constructor.
        VerticesWithNormals(std::vector<Length2> vertices);

        /// @brief Gets vertices this instance was constructed with.
        auto GetVertices() const noexcept -> decltype((m_vertices))
        {
            return m_vertices;
        }

        /// @brief Gets the normals of the vectors this instance was constructed with.
        auto GetNormals() const noexcept -> decltype((m_normals))
        {
            return m_normals;
        }

        /// @brief Equals operator support.
        friend auto operator==(const VerticesWithNormals& lhs, const VerticesWithNormals& rhs) noexcept -> bool
        {
            return lhs.m_vertices == rhs.m_vertices;
        }
    };

    /// @brief Default vertex radius.
    static constexpr auto DefaultVertexRadius = NonNegative<Length>{DefaultLinearSlop * Real{2}};

    /// @brief Gets the default vertex radius.
    /// @note This is just a backward compatibility interface for getting the default vertex radius.
    ///    The new way is to use <code>DefaultVertexRadius</code> directly.
    /// @return <code>DefaultVertexRadius</code>.
    static constexpr NonNegative<Length> GetDefaultVertexRadius() noexcept
    {
        return DefaultVertexRadius;
    }

    /// @brief Sets the configuration up for representing a chain of vertices as given.
    /// @note This function provides the strong exception guarantee. The state of this instance
    ///   won't change if this function throws any exception.
    /// @throws InvalidArgument if the number of vertices given is greater than <code>MaxChildCount</code>.
    /// @post <code>GetVertices()</code> returns the vertices given.
    /// @post <code>GetVertexCount()</code> returns the number of vertices given.
    /// @post <code>GetVertex(i)</code> returns the vertex <code>vertices[i]</code> for all valid indices.
    ChainShapeConf& Set(std::vector<Length2> vertices);

    /// @brief Adds the given vertex.
    ChainShapeConf& Add(const Length2& vertex);

    /// @brief Translates the vertices by the given amount.
    /// @note This function provides the strong exception guarantee. The state of this instance
    ///   won't change if this function throws any exception.
    ChainShapeConf& Translate(const Length2& value);

    /// @brief Scales the vertices by the given amount.
    /// @note This function provides the strong exception guarantee. The state of this instance
    ///   won't change if this function throws any exception.
    ChainShapeConf& Scale(const Vec2& value);

    /// @brief Rotates the vertices by the given amount.
    /// @note This function provides the strong exception guarantee. The state of this instance
    ///   won't change if this function throws any exception.
    ChainShapeConf& Rotate(const UnitVec& value);

    /// @brief Gets the "child" shape count.
    ChildCounter GetChildCount() const noexcept
    {
        // edge count = vertex count - 1
        const auto count = GetVertexCount();
        return (count > 1) ? count - 1 : count;
    }

    /// @brief Gets the "child" shape at the given index.
    DistanceProxy GetChild(ChildCounter index) const;

    /// @brief Gets the mass data.
    MassData GetMassData() const;

    /// @brief Uses the given vertex radius.
    ChainShapeConf& UseVertexRadius(NonNegative<Length> value) noexcept;

    /// @brief Gets the vertex count.
    ChildCounter GetVertexCount() const noexcept
    {
        return static_cast<ChildCounter>(size(segments.GetVertices()));
    }

    /// @brief Gets a vertex by index.
    Length2 GetVertex(ChildCounter index) const
    {
        assert(index < GetVertexCount());
        return segments.GetVertices()[index];
    }

    /// @brief Gets the normal at the given index.
    UnitVec GetNormal(ChildCounter index) const
    {
        assert(index < GetVertexCount());
        return segments.GetNormals()[index];
    }

    /// @brief Equality operator.
    friend bool operator==(const ChainShapeConf& lhs, const ChainShapeConf& rhs) noexcept
    {
        // Don't need to check normals since normals based on vertices.
        return lhs.vertexRadius == rhs.vertexRadius && lhs.friction == rhs.friction &&
               lhs.restitution == rhs.restitution && lhs.density == rhs.density &&
               lhs.filter == rhs.filter && lhs.isSensor == rhs.isSensor &&
               lhs.segments == rhs.segments;
    }

    /// @brief Inequality operator.
    friend bool operator!=(const ChainShapeConf& lhs, const ChainShapeConf& rhs) noexcept
    {
        return !(lhs == rhs);
    }

    /// @brief Vertex radius.
    /// @details This is the radius from the vertex that the shape's "skin" should
    ///   extend outward by. While any edges &mdash; line segments between multiple
    ///   vertices &mdash; are straight, corners between them (the vertices) are
    ///   rounded and treated as rounded. Shapes with larger vertex radiuses compared
    ///   to edge lengths therefore will be more prone to rolling or having other
    ///   shapes more prone to roll off of them.
    /// @note This should be a non-negative value.
    NonNegative<Length> vertexRadius = GetDefaultVertexRadius();

    VerticesWithNormals segments; ///< Vertex & normals data
};

inline ChainShapeConf& ChainShapeConf::UseVertexRadius(NonNegative<Length> value) noexcept
{
    vertexRadius = value;
    return *this;
}

// Free functions...

/// @brief Gets the child count for a given chain shape configuration.
inline ChildCounter GetChildCount(const ChainShapeConf& arg) noexcept
{
    return arg.GetChildCount();
}

/// @brief Gets the "child" shape for a given chain shape configuration.
inline DistanceProxy GetChild(const ChainShapeConf& arg, ChildCounter index)
{
    return arg.GetChild(index);
}

/// @brief Gets the mass data for a given chain shape configuration.
inline MassData GetMassData(const ChainShapeConf& arg)
{
    return arg.GetMassData();
}

/// @brief Determines whether the given shape is looped.
inline bool IsLooped(const ChainShapeConf& shape) noexcept
{
    const auto count = shape.GetVertexCount();
    return (count > 1) ? (shape.GetVertex(count - 1) == shape.GetVertex(0)) : false;
}

/// @brief Gets the next index after the given index for the given shape.
inline ChildCounter GetNextIndex(const ChainShapeConf& shape, ChildCounter index) noexcept
{
    return GetModuloNext(index, shape.GetVertexCount());
}

/// @brief Gets the vertex radius of the given shape configuration.
inline NonNegative<Length> GetVertexRadius(const ChainShapeConf& arg) noexcept
{
    return arg.vertexRadius;
}

/// @brief Gets the vertex radius of the given shape configuration.
inline NonNegative<Length> GetVertexRadius(const ChainShapeConf& arg, ChildCounter) noexcept
{
    return GetVertexRadius(arg);
}

/// @brief Sets the vertex radius of the shape.
inline void SetVertexRadius(ChainShapeConf& arg, NonNegative<Length> value) noexcept
{
    arg.vertexRadius = value;
}

/// @brief Sets the vertex radius of the shape for the given index.
inline void SetVertexRadius(ChainShapeConf& arg, ChildCounter, NonNegative<Length> value) noexcept
{
    SetVertexRadius(arg, value);
}

/// @brief Translates the given shape's vertices by the given amount.
inline void Translate(ChainShapeConf& arg, const Length2& value)
{
    arg.Translate(value);
}

/// @brief Scales the given shape's vertices by the given amount.
inline void Scale(ChainShapeConf& arg, const Vec2& value)
{
    arg.Scale(value);
}

/// @brief Rotates the given shape's vertices by the given amount.
inline void Rotate(ChainShapeConf& arg, const UnitVec& value)
{
    arg.Rotate(value);
}

/// @brief Gets an enclosing chain shape configuration for an axis aligned rectangle of the
///    given dimensions (width and height).
ChainShapeConf GetChainShapeConf(const Length2& dimensions);

/// @brief Gets an enclosing chain shape configuration for an axis aligned square of the
///    given dimension.
inline ChainShapeConf GetChainShapeConf(Length dimension)
{
    return GetChainShapeConf(Length2{dimension, dimension});
}

/// @brief Gets an enclosing chain shape configuration for the given axis aligned box.
ChainShapeConf GetChainShapeConf(const AABB& arg);

} // namespace playrho::d2

/// @brief Type info specialization for <code>playrho::d2::ChainShapeConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::ChainShapeConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::ChainShapeConf";
};

#endif // PLAYRHO_D2_SHAPES_CHAINSHAPECONF_HPP
