/*
 * Original work Copyright (c) 2006-2010 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_COLLISION_SHAPES_CHAINSHAPECONF_HPP
#define PLAYRHO_COLLISION_SHAPES_CHAINSHAPECONF_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Collision/Shapes/ShapeConf.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/MassData.hpp"
#include "PlayRho/Collision/AABB.hpp"
#include <vector>

namespace playrho {
namespace d2 {

/// @brief Chain shape configuration.
///
/// @details A chain shape is a free form sequence of line segments.
/// The chain has two-sided collision, so you can use inside and outside collision.
/// Therefore, you may use any winding order.
/// Since there may be many vertices, they are allocated on the memory heap.
///
/// @image html Chain1.png
/// @image html SelfIntersect.png
///
/// @warning The chain will not collide properly if there are self-intersections.
///
/// @ingroup PartsGroup
///
class ChainShapeConf: public ShapeBuilder<ChainShapeConf>
{
public:
    /// @brief Gets the default vertex radius.
    static PLAYRHO_CONSTEXPR inline NonNegative<Length> GetDefaultVertexRadius() noexcept
    {
        return NonNegative<Length>{DefaultLinearSlop * Real{2}};
    }

    /// @brief Default constructor.
    ChainShapeConf();
    
    /// @brief Sets the configuration up for representing a chain of vertices as given.
    ChainShapeConf& Set(std::vector<Length2> arg);
    
    /// @brief Adds the given vertex.
    ChainShapeConf& Add(Length2 vertex);
    
    /// @brief Transforms all the vertices by the given transformation matrix.
    /// @note This updates the normals too.
    /// @sa https://en.wikipedia.org/wiki/Transformation_matrix
    ChainShapeConf& Transform(const Mat22& m) noexcept;

    /// @brief Gets the "child" shape count.
    ChildCounter GetChildCount() const noexcept
    {
        // edge count = vertex count - 1
        const auto count = GetVertexCount();
        return (count > 1)? count - 1: count;
    }

    /// @brief Gets the "child" shape at the given index.
    DistanceProxy GetChild(ChildCounter index) const;
    
    /// @brief Gets the mass data.
    MassData GetMassData() const noexcept;
    
    /// @brief Uses the given vertex radius.
    ChainShapeConf& UseVertexRadius(NonNegative<Length> value) noexcept;

    /// @brief Gets the vertex count.
    ChildCounter GetVertexCount() const noexcept
    {
        return static_cast<ChildCounter>(size(m_vertices));
    }
    
    /// @brief Gets a vertex by index.
    Length2 GetVertex(ChildCounter index) const
    {
        assert((0 <= index) && (index < GetVertexCount()));
        return m_vertices[index];
    }
    
    /// @brief Gets the normal at the given index.
    UnitVec GetNormal(ChildCounter index) const
    {
        assert((0 <= index) && (index < GetVertexCount()));
        return m_normals[index];
    }
    
    /// @brief Equality operator.
    friend bool operator== (const ChainShapeConf& lhs, const ChainShapeConf& rhs) noexcept
    {
        // Don't need to check normals since normals based on vertices.
        return lhs.vertexRadius == rhs.vertexRadius && lhs.friction == rhs.friction
            && lhs.restitution == rhs.restitution && lhs.density == rhs.density
            && lhs.m_vertices == rhs.m_vertices;
    }
    
    /// @brief Inequality operator.
    friend bool operator!= (const ChainShapeConf& lhs, const ChainShapeConf& rhs) noexcept
    {
        return !(lhs == rhs);
    }
    
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
    /// @brief Resets the normals based on the current vertices.
    void ResetNormals();

    std::vector<Length2> m_vertices; ///< Vertices.
    std::vector<UnitVec> m_normals; ///< Normals.
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
inline MassData GetMassData(const ChainShapeConf& arg) noexcept
{
    return arg.GetMassData();
}

/// @brief Determines whether the given shape is looped.
inline bool IsLooped(const ChainShapeConf& shape) noexcept
{
    const auto count = shape.GetVertexCount();
    return (count > 1)? (shape.GetVertex(count - 1) == shape.GetVertex(0)): false;
}

/// @brief Gets the next index after the given index for the given shape.
inline ChildCounter GetNextIndex(const ChainShapeConf& shape, ChildCounter index) noexcept
{
    return GetModuloNext(index, shape.GetVertexCount());
}

/// @brief Gets the vertex radius of the given shape configuration.
inline NonNegative<Length> GetVertexRadius(const ChainShapeConf& arg)
{
    return arg.vertexRadius;
}

/// @brief Gets the vertex radius of the given shape configuration.
inline NonNegative<Length> GetVertexRadius(const ChainShapeConf& arg, ChildCounter)
{
    return GetVertexRadius(arg);
}

/// @brief Transforms the given chain shape configuration's vertices by the given
///   transformation matrix.
/// @sa https://en.wikipedia.org/wiki/Transformation_matrix
inline void Transform(ChainShapeConf& arg, const Mat22& m) noexcept
{
    arg.Transform(m);
}

/// @brief Gets an enclosing chain shape configuration for an axis aligned rectangle of the
///    given dimensions (width and height).
ChainShapeConf GetChainShapeConf(Length2 dimensions);

/// @brief Gets an enclosing chain shape configuration for an axis aligned square of the
///    given dimension.
inline ChainShapeConf GetChainShapeConf(Length dimension)
{
    return GetChainShapeConf(Length2{dimension, dimension});
}

/// @brief Gets an enclosing chain shape configuration for the given axis aligned box.
ChainShapeConf GetChainShapeConf(const AABB& arg);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_SHAPES_CHAINSHAPECONF_HPP
