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

#ifndef PLAYRHO_D2_SHAPES_POLYGONSHAPECONF_HPP
#define PLAYRHO_D2_SHAPES_POLYGONSHAPECONF_HPP

/// @file
/// @brief Definition of the @c PolygonShapeConf class and closely related code.

#include <cassert> // for assert
#include <type_traits>
#include <vector>

// IWYU pragma: begin_exports

#include "playrho/InvalidArgument.hpp"
#include "playrho/Matrix.hpp" // for Mat22
#include "playrho/NonNegative.hpp"
#include "playrho/Settings.hpp"
#include "playrho/Span.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector2.hpp"

#include "playrho/detail/Templates.hpp"
#include "playrho/detail/TypeInfo.hpp"

#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/NgonWithFwdNormals.hpp"
#include "playrho/d2/ShapeConf.hpp"
#include "playrho/d2/Transformation.hpp"
#include "playrho/d2/UnitVec.hpp"
#include "playrho/d2/VertexSet.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief An n-vertex convex polygon shaped part eligible for use with a <code>Shape</code>.
/// @note The interior of the polygon geometry is to the left of each edge. The maximum number of
/// vertices this can have is defined by <code>MaxShapeVertices</code>. If all you want is a
/// rectangular part (that will only ever have 4-vertices) you may want to consider using a
/// rectangular <code>::playrho::d2::part::Compositor</code> instead.
/// @image html convex_concave.gif
/// @see Shape, ::playrho::d2::part::Compositor.
/// @ingroup PartsGroup
struct PolygonShapeConf : public ShapeBuilder<PolygonShapeConf>
{
    /// @brief Default vertex radius.
    static constexpr auto DefaultVertexRadius = NonNegative<Length>{DefaultLinearSlop * 2};

    /// @brief Gets the default vertex radius for the <code>PolygonShapeConf</code>.
    /// @note This is just a backward compatibility interface for getting the default vertex radius.
    ///    The new way is to use <code>DefaultVertexRadius</code> directly.
    /// @return <code>DefaultVertexRadius</code>.
    static constexpr NonNegative<Length> GetDefaultVertexRadius() noexcept
    {
        return DefaultVertexRadius;
    }

    /// @brief Gets the default configuration for a <code>PolygonShapeConf</code>.
    static inline PolygonShapeConf GetDefaultConf() noexcept
    {
        return PolygonShapeConf{};
    }

    PolygonShapeConf() noexcept;

    /// @brief Initializing constructor for a 4-sided box polygon.
    /// @param hx Half of the width.
    /// @param hy Half of the height.
    /// @param conf Additional configuration information.
    /// @see SetAsBox.
    PolygonShapeConf(Length hx, Length hy,
                     const PolygonShapeConf& conf = GetDefaultConf());

    /// @brief Creates a convex hull from the given array of local points.
    /// @note The size of the span must be in the range [1, <code>MaxShapeVertices</code>].
    /// @warning the points may be re-ordered, even if they form a convex polygon
    /// @warning collinear points are handled but not removed. Collinear points
    /// may lead to poor stacking behavior.
    explicit PolygonShapeConf(Span<const Length2> points,
                              const PolygonShapeConf& conf = GetDefaultConf());

    /// @brief Uses the given vertex radius.
    PolygonShapeConf& UseVertexRadius(NonNegative<Length> value) noexcept;

    /// @brief Uses the given vertices.
    PolygonShapeConf& UseVertices(const Span<const Length2>& verts);

    /// @brief Sets the vertices to represent an axis-aligned box centered on the local origin.
    /// @param hx the half-width.
    /// @param hy the half-height.
    PolygonShapeConf& SetAsBox(Length hx, Length hy);

    /// @brief Sets the vertices for the described box.
    PolygonShapeConf& SetAsBox(Length hx, Length hy, const Length2& center, Angle angle);

    /// @brief Sets the vertices to a convex hull of the given ones.
    /// @note The size of the span must be in the range [1, <code>MaxShapeVertices</code>].
    /// @warning Points may be re-ordered, even if they form a convex polygon
    /// @warning Collinear points are handled but not removed. Collinear points
    ///   may lead to poor stacking behavior.
    PolygonShapeConf& Set(Span<const Length2> points);

    /// @brief Sets the vertices to a convex hull of the given ones.
    /// @note The size of the span must be in the range [0, <code>MaxShapeVertices</code>].
    /// @note This function provides the strong exception guarantee.
    /// @warning Points may be re-ordered, even if they form a convex polygon
    /// @warning Collinear points are handled but not removed. Collinear points
    ///   may lead to poor stacking behavior.
    PolygonShapeConf& Set(const VertexSet& points);

    /// @brief Transforms the vertices by the given transformation.
    PolygonShapeConf& Transform(const Transformation& xfm);

    /// @brief Transforms the vertices by the given transformation matrix.
    /// @see https://en.wikipedia.org/wiki/Transformation_matrix
    PolygonShapeConf& Transform(const Mat22& m);

    /// @brief Translates all the vertices by the given amount.
    PolygonShapeConf& Translate(const Length2& value);

    /// @brief Scales all the vertices by the given amount.
    PolygonShapeConf& Scale(const Vec2& value);

    /// @brief Rotates all the vertices by the given amount.
    PolygonShapeConf& Rotate(const UnitVec& value);

    /// @brief Equality operator.
    friend bool operator==(const PolygonShapeConf& lhs, const PolygonShapeConf& rhs) noexcept
    {
        // Don't need to check normals nor centroid since they based on vertices.
        return lhs.vertexRadius == rhs.vertexRadius && lhs.friction == rhs.friction &&
               lhs.restitution == rhs.restitution && lhs.density == rhs.density &&
               lhs.filter == rhs.filter && lhs.isSensor == rhs.isSensor &&
               lhs.ngon == rhs.ngon;
    }

    /// @brief Inequality operator.
    friend bool operator!=(const PolygonShapeConf& lhs, const PolygonShapeConf& rhs) noexcept
    {
        return !(lhs == rhs);
    }

    /// Gets the vertex count.
    /// @return value between 0 and <code>MaxShapeVertices</code> inclusive.
    /// @see MaxShapeVertices
    VertexCounter GetVertexCount() const noexcept
    {
        return static_cast<VertexCounter>(size(ngon.GetVertices()));
    }

    /// Gets a vertex by index.
    /// @details Vertices go counter-clockwise.
    Length2 GetVertex(VertexCounter index) const
    {
        assert(0 <= index && index < GetVertexCount());
        return ngon.GetVertices()[index];
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
        return ngon.GetNormals()[index];
    }

    /// Gets the span of vertices.
    /// @details Vertices go counter-clockwise.
    Span<const Length2> GetVertices() const noexcept
    {
        return {ngon.GetVertices()};
    }

    /// @brief Gets the span of normals.
    Span<const UnitVec> GetNormals() const noexcept
    {
        return {ngon.GetNormals()};
    }

    /// @brief Vertex radius.
    /// @details This is the radius from the vertex that the shape's "skin" should
    ///   extend outward by. While any edges &mdash; line segments between multiple
    ///   vertices &mdash; are straight, corners between them (the vertices) are
    ///   rounded and treated as rounded. Shapes with larger vertex radiuses compared
    ///   to edge lengths therefore will be more prone to rolling or having other
    ///   shapes more prone to roll off of them.
    /// @note This should be a non-negative value.
    NonNegativeFF<Length> vertexRadius = GetDefaultVertexRadius();

    /// @brief N-gon data.
    NgonWithFwdNormals<> ngon;
};

// Assert some expected traits...
static_assert(std::is_default_constructible_v<PolygonShapeConf>);
static_assert(std::is_nothrow_default_constructible_v<PolygonShapeConf>);
static_assert(std::is_copy_constructible_v<PolygonShapeConf>);

inline PolygonShapeConf& PolygonShapeConf::UseVertexRadius(NonNegative<Length> value) noexcept
{
    vertexRadius = value;
    return *this;
}

// Free functions...

/// @brief Gets the "child" count for the given shape configuration.
/// @return 1.
/// @relatedalso PolygonShapeConf
constexpr ChildCounter GetChildCount(const PolygonShapeConf&) noexcept
{
    return 1;
}

/// @brief Gets the "child" shape for the given shape configuration.
/// @relatedalso PolygonShapeConf
inline DistanceProxy GetChild(const PolygonShapeConf& arg, ChildCounter index)
{
    if (index != 0) {
        throw InvalidArgument("only index of 0 is supported");
    }
    return DistanceProxy{arg.vertexRadius, arg.GetVertexCount(), data(arg.GetVertices()),
                         data(arg.GetNormals())};
}

/// @brief Gets the vertex radius of the given shape configuration.
/// @relatedalso PolygonShapeConf
inline NonNegative<Length> GetVertexRadius(const PolygonShapeConf& arg) noexcept
{
    return arg.vertexRadius;
}

/// @brief Gets the vertex radius of the given shape configuration.
/// @relatedalso PolygonShapeConf
inline NonNegative<Length> GetVertexRadius(const PolygonShapeConf& arg, ChildCounter) noexcept
{
    return GetVertexRadius(arg);
}

/// @brief Sets the vertex radius of the shape.
inline void SetVertexRadius(PolygonShapeConf& arg, NonNegative<Length> value)
{
    arg.UseVertexRadius(value);
}

/// @brief Sets the vertex radius of the shape for the given index.
inline void SetVertexRadius(PolygonShapeConf& arg, ChildCounter, NonNegative<Length> value)
{
    SetVertexRadius(arg, value);
}

/// @brief Gets the mass data for the given shape configuration.
/// @relatedalso PolygonShapeConf
inline MassData GetMassData(const PolygonShapeConf& arg)
{
    return playrho::d2::GetMassData(arg.vertexRadius, arg.density, arg.GetVertices());
}

/// @brief Transforms the given polygon configuration's vertices by the given
///   transformation matrix.
/// @see https://en.wikipedia.org/wiki/Transformation_matrix
/// @relatedalso PolygonShapeConf
inline void Transform(PolygonShapeConf& arg, const Mat22& m)
{
    arg.Transform(m);
}

/// @brief Translates the given shape configuration's vertices by the given amount.
inline void Translate(PolygonShapeConf& arg, const Length2& value)
{
    arg.Translate(value);
}

/// @brief Scales the given shape configuration's vertices by the given amount.
inline void Scale(PolygonShapeConf& arg, const Vec2& value)
{
    arg.Scale(value);
}

/// @brief Rotates the given shape configuration's vertices by the given amount.
inline void Rotate(PolygonShapeConf& arg, const UnitVec& value)
{
    arg.Rotate(value);
}

/// @brief Validates the convexity of the given collection of vertices.
/// @note This is a time consuming operation.
/// @returns <code>true</code> if the given collection of vertices is indeed convex,
///   <code>false</code> otherwise.
bool Validate(const Span<const Length2>& verts);

} // namespace playrho::d2

/// @brief Type info specialization for <code>playrho::d2::PolygonShapeConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::PolygonShapeConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::PolygonShapeConf";
};

#endif // PLAYRHO_D2_SHAPES_POLYGONSHAPECONF_HPP
