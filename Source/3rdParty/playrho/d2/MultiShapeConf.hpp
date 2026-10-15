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

#ifndef PLAYRHO_D2_SHAPES_MULTISHAPECONF_HPP
#define PLAYRHO_D2_SHAPES_MULTISHAPECONF_HPP

/// @file
/// @brief Definition of the @c MultiShapeConf class and closely related code.

#include <vector>

// IWYU pragma: begin_exports

#include "playrho/InvalidArgument.hpp"
#include "playrho/TypeInfo.hpp"

#include "playrho/d2/ConvexHull.hpp"
#include "playrho/d2/ShapeConf.hpp"
#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief The "multi-shape" shape configuration.
/// @details Composes zero or more convex shapes into what can be a concave shape.
/// @ingroup PartsGroup
struct MultiShapeConf : public ShapeBuilder<MultiShapeConf> {
    /// @brief Default vertex radius.
    static constexpr auto DefaultVertexRadius = NonNegative<Length>{DefaultLinearSlop * 2};

    /// @brief Gets the default vertex radius for the <code>MultiShapeConf</code>.
    /// @note This is just a backward compatibility interface for getting the default vertex radius.
    ///    The new way is to use <code>DefaultVertexRadius</code> directly.
    /// @return <code>DefaultVertexRadius</code>.
    static constexpr NonNegative<Length> GetDefaultVertexRadius() noexcept
    {
        return DefaultVertexRadius;
    }

    /// @brief Gets the default configuration for a <code>MultiShapeConf</code>.
    static inline MultiShapeConf GetDefaultConf() noexcept
    {
        return MultiShapeConf{};
    }

    /// Creates a convex hull from the given set of local points.
    /// The size of the set must be in the range [1, <code>MaxShapeVertices</code>].
    /// @warning the points may be re-ordered, even if they form a convex polygon
    /// @warning collinear points are handled but not removed. Collinear points
    ///   may lead to poor stacking behavior.
    MultiShapeConf&
    AddConvexHull(const VertexSet& pointSet,
                  NonNegative<Length> vertexRadius = GetDefaultVertexRadius());

    /// @brief Translates all the vertices by the given amount.
    MultiShapeConf& Translate(const Length2& value);

    /// @brief Scales all the vertices by the given amount.
    MultiShapeConf& Scale(const Vec2& value);

    /// @brief Rotates all the vertices by the given amount.
    MultiShapeConf& Rotate(const UnitVec& value);

    std::vector<ConvexHull> children; ///< Children.
};

// Free functions...

/// @brief Equality operator.
inline bool operator==(const MultiShapeConf& lhs, const MultiShapeConf& rhs) noexcept
{
    return lhs.friction == rhs.friction && lhs.restitution == rhs.restitution &&
           lhs.density == rhs.density && lhs.filter == rhs.filter && lhs.isSensor == rhs.isSensor &&
           lhs.children == rhs.children;
}

/// @brief Inequality operator.
inline bool operator!=(const MultiShapeConf& lhs, const MultiShapeConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the "child" count for the given shape configuration.
inline ChildCounter GetChildCount(const MultiShapeConf& arg) noexcept
{
    return static_cast<ChildCounter>(std::size(arg.children));
}

/// @brief Gets the "child" shape for the given shape configuration.
inline DistanceProxy GetChild(const MultiShapeConf& arg, ChildCounter index)
{
    if (index >= GetChildCount(arg)) {
        throw InvalidArgument("index out of range");
    }
    return arg.children[index].GetDistanceProxy();
}

/// @brief Gets the mass data for the given shape configuration.
MassData GetMassData(const MultiShapeConf& arg);

/// @brief Gets the vertex radius of the given shape configuration.
inline NonNegative<Length> GetVertexRadius(const MultiShapeConf& arg, ChildCounter index)
{
    if (index >= GetChildCount(arg)) {
        throw InvalidArgument("index out of range");
    }
    return arg.children[index].GetVertexRadius();
}

/// @brief Sets the vertex radius of shape for the given index.
inline void SetVertexRadius(MultiShapeConf& arg, ChildCounter index, NonNegative<Length> value)
{
    if (index >= GetChildCount(arg)) {
        throw InvalidArgument("index out of range");
    }
    arg.children[index].SetVertexRadius(value);
}

/// @brief Translates the given shape configuration's vertices by the given amount.
inline void Translate(MultiShapeConf& arg, const Length2& value)
{
    arg.Translate(value);
}

/// @brief Scales the given shape configuration's vertices by the given amount.
inline void Scale(MultiShapeConf& arg, const Vec2& value)
{
    arg.Scale(value);
}

/// @brief Rotates the given shape configuration's vertices by the given amount.
inline void Rotate(MultiShapeConf& arg, const UnitVec& value)
{
    arg.Rotate(value);
}

} // namespace playrho::d2

/// @brief Type info specialization for <code>playrho::d2::MultiShapeConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::MultiShapeConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::MultiShapeConf";
};

#endif // PLAYRHO_D2_SHAPES_MULTISHAPECONF_HPP
