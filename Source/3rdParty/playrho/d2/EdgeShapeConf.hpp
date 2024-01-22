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

#ifndef PLAYRHO_D2_SHAPES_EDGESHAPECONF_HPP
#define PLAYRHO_D2_SHAPES_EDGESHAPECONF_HPP

/// @file
/// @brief Definition of the @c EdgeShapeConf class and closely related code.

#include <array>

// IWYU pragma: begin_exports

#include "playrho/InvalidArgument.hpp"
#include "playrho/NonNegative.hpp"
#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp" // for Length2

#include "playrho/detail/Templates.hpp"
#include "playrho/detail/TypeInfo.hpp"

#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/NgonWithFwdNormals.hpp"
#include "playrho/d2/ShapeConf.hpp"
#include "playrho/d2/UnitVec.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief Edge shape configuration.
/// @details A line segment (edge) shape. These can be connected in chains or loops
///   to other edge shapes. The connectivity information is used to ensure correct
///   contact normals.
/// @ingroup PartsGroup
struct EdgeShapeConf : public ShapeBuilder<EdgeShapeConf>
{
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

    /// @brief Gets the default configuration.
    static inline EdgeShapeConf GetDefaultConf() noexcept
    {
        return EdgeShapeConf{};
    }

    EdgeShapeConf() noexcept = default;

    /// @brief Initializing constructor.
    EdgeShapeConf(const Length2& vA, const Length2& vB, // force line-break
                  const EdgeShapeConf& conf = GetDefaultConf()) noexcept;

    /// @brief Sets both vertices in one call.
    EdgeShapeConf& Set(const Length2& vA, const Length2& vB) noexcept;

    /// @brief Uses the given vertex radius.
    EdgeShapeConf& UseVertexRadius(NonNegative<Length> value) noexcept;

    /// @brief Translates the vertices by the given amount.
    EdgeShapeConf& Translate(const Length2& value) noexcept;

    /// @brief Scales the vertices by the given amount.
    EdgeShapeConf& Scale(const Vec2& value) noexcept;

    /// @brief Rotates the vertices by the given amount.
    EdgeShapeConf& Rotate(const UnitVec& value) noexcept;

    /// @brief Gets vertex A.
    Length2 GetVertexA() const noexcept
    {
        return ngon.GetVertices()[0];
    }

    /// @brief Gets vertex B.
    Length2 GetVertexB() const noexcept
    {
        return ngon.GetVertices()[1];
    }

    /// @brief Vertex radius.
    /// @details This is the radius from the vertex that the shape's "skin" should
    ///   extend outward by. While any edges &mdash; line segments between multiple
    ///   vertices &mdash; are straight, corners between them (the vertices) are
    ///   rounded and treated as rounded. Shapes with larger vertex radiuses compared
    ///   to edge lengths therefore will be more prone to rolling or having other
    ///   shapes more prone to roll off of them.
    NonNegativeFF<Length> vertexRadius = GetDefaultVertexRadius();

    NgonWithFwdNormals<2> ngon; ///< N-gon value of the object.
};

inline EdgeShapeConf& EdgeShapeConf::UseVertexRadius(NonNegative<Length> value) noexcept
{
    vertexRadius = value;
    return *this;
}

// Free functions...

/// @brief Equality operator.
inline bool operator==(const EdgeShapeConf& lhs, const EdgeShapeConf& rhs) noexcept
{
    return lhs.vertexRadius == rhs.vertexRadius && lhs.friction == rhs.friction &&
           lhs.restitution == rhs.restitution && lhs.density == rhs.density &&
           lhs.filter == rhs.filter && lhs.isSensor == rhs.isSensor &&
           lhs.ngon == rhs.ngon;
}

/// @brief Inequality operator.
inline bool operator!=(const EdgeShapeConf& lhs, const EdgeShapeConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the "child" count for the given shape configuration.
/// @return 1.
constexpr ChildCounter GetChildCount(const EdgeShapeConf&) noexcept
{
    return 1;
}

/// @brief Gets the "child" shape for the given shape configuration.
inline DistanceProxy GetChild(const EdgeShapeConf& arg, ChildCounter index)
{
    if (index != 0) {
        throw InvalidArgument("only index of 0 is supported");
    }
    return DistanceProxy{arg.vertexRadius, 2, // force line-break
        data(arg.ngon.GetVertices()), // explicitly decay array into pointer
        data(arg.ngon.GetNormals()) // explicitly decay array into pointer
    };
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

/// @brief Sets the vertex radius of the shape.
inline void SetVertexRadius(EdgeShapeConf& arg, NonNegative<Length> value)
{
    arg.vertexRadius = value;
}

/// @brief Sets the vertex radius of the shape for the given index.
inline void SetVertexRadius(EdgeShapeConf& arg, ChildCounter, NonNegative<Length> value)
{
    SetVertexRadius(arg, value);
}

/// @brief Gets the mass data for the given shape configuration.
inline MassData GetMassData(const EdgeShapeConf& arg)
{
    return playrho::d2::GetMassData(arg.vertexRadius, arg.density, arg.GetVertexA(),
                                    arg.GetVertexB());
}

/// @brief Translates the given shape's vertices by the given amount.
inline void Translate(EdgeShapeConf& arg, const Length2& value) noexcept
{
    arg.Translate(value);
}

/// @brief Scales the given shape's vertices by the given amount.
inline void Scale(EdgeShapeConf& arg, const Vec2& value) noexcept
{
    arg.Scale(value);
}

/// @brief Rotates the given shape's vertices by the given amount.
inline void Rotate(EdgeShapeConf& arg, const UnitVec& value) noexcept
{
    arg.Rotate(value);
}

} // namespace playrho::d2

/// @brief Type info specialization for <code>playrho::d2::EdgeShapeConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::EdgeShapeConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::EdgeShapeConf";
};

#endif // PLAYRHO_D2_SHAPES_EDGESHAPECONF_HPP
