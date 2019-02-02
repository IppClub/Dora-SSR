/*
 * Original work Copyright (c) 2006-2010 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_COLLISION_SHAPES_EDGESHAPECONF_HPP
#define PLAYRHO_COLLISION_SHAPES_EDGESHAPECONF_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Collision/Shapes/ShapeConf.hpp"
#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/MassData.hpp"

namespace playrho {
namespace d2 {

/// @brief Edge shape configuration.
///
/// @details A line segment (edge) shape. These can be connected in chains or loops
///   to other edge shapes. The connectivity information is used to ensure correct
///   contact normals.
///
/// @note This data structure is 56-bytes.
///
/// @ingroup PartsGroup
///
class EdgeShapeConf: public ShapeBuilder<EdgeShapeConf>
{
public:
    /// @brief Gets the default vertex radius.
    static PLAYRHO_CONSTEXPR inline NonNegative<Length> GetDefaultVertexRadius() noexcept
    {
        return NonNegative<Length>{DefaultLinearSlop * Real{2}};
    }
    
    /// @brief Gets the default configuration.
    static inline EdgeShapeConf GetDefaultConf() noexcept
    {
        return EdgeShapeConf{};
    }

    EdgeShapeConf() = default;
    
    /// @brief Initializing constructor.
    EdgeShapeConf(Length2 vA, Length2 vB, const EdgeShapeConf& conf = GetDefaultConf()) noexcept;
    
    /// @brief Sets both vertices in one call.
    EdgeShapeConf& Set(Length2 vA, Length2 vB) noexcept;
    
    /// @brief Uses the given vertex radius.
    EdgeShapeConf& UseVertexRadius(NonNegative<Length> value) noexcept;
    
    /// @brief Transforms both vertices by the given transformation matrix.
    /// @sa https://en.wikipedia.org/wiki/Transformation_matrix
    EdgeShapeConf& Transform(const Mat22& m) noexcept;

    /// @brief Gets vertex A.
    Length2 GetVertexA() const noexcept
    {
        return m_vertices[0];
    }
    
    /// @brief Gets vertex B.
    Length2 GetVertexB() const noexcept
    {
        return m_vertices[1];
    }
    
    /// @brief Gets the "child" shape.
    DistanceProxy GetChild() const noexcept
    {
        return DistanceProxy{vertexRadius, 2, m_vertices, m_normals};
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
    Length2 m_vertices[2] = {Length2{}, Length2{}}; ///< Vertices
    UnitVec m_normals[2] = {UnitVec{}, UnitVec{}}; ///< Normals.
};

inline EdgeShapeConf& EdgeShapeConf::UseVertexRadius(NonNegative<Length> value) noexcept
{
    vertexRadius = value;
    return *this;
}

// Free functions...

/// @brief Equality operator.
inline bool operator== (const EdgeShapeConf& lhs, const EdgeShapeConf& rhs) noexcept
{
    return lhs.vertexRadius == rhs.vertexRadius && lhs.friction == rhs.friction
        && lhs.restitution == rhs.restitution && lhs.density == rhs.density
        && lhs.GetVertexA() == rhs.GetVertexA() && lhs.GetVertexB() == rhs.GetVertexB();
}

/// @brief Inequality operator.
inline bool operator!= (const EdgeShapeConf& lhs, const EdgeShapeConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the "child" count for the given shape configuration.
/// @return 1.
PLAYRHO_CONSTEXPR inline ChildCounter GetChildCount(const EdgeShapeConf&) noexcept
{
    return 1;
}

/// @brief Gets the "child" shape for the given shape configuration.
inline DistanceProxy GetChild(const EdgeShapeConf& arg, ChildCounter index)
{
    if (index != 0)
    {
        throw InvalidArgument("only index of 0 is supported");
    }
    return arg.GetChild();
}

/// @brief Gets the vertex radius of the given shape configuration.
inline NonNegative<Length> GetVertexRadius(const EdgeShapeConf& arg) noexcept
{
    return arg.vertexRadius;
}

/// @brief Gets the vertex radius of the given shape configuration.
inline NonNegative<Length> GetVertexRadius(const EdgeShapeConf& arg, ChildCounter) noexcept
{
    return GetVertexRadius(arg);
}

/// @brief Gets the mass data for the given shape configuration.
inline MassData GetMassData(const EdgeShapeConf& arg) noexcept
{
    return playrho::d2::GetMassData(arg.vertexRadius, arg.density,
                                    arg.GetVertexA(), arg.GetVertexB());
}

/// @brief Transforms the given shape configuration's vertices by the given transformation matrix.
/// @sa https://en.wikipedia.org/wiki/Transformation_matrix
inline void Transform(EdgeShapeConf& arg, const Mat22& m) noexcept
{
    arg.Transform(m);
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_SHAPES_EDGESHAPECONF_HPP
