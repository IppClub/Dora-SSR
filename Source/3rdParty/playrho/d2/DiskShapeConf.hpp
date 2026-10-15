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

#ifndef PLAYRHO_D2_SHAPES_DISKSHAPECONF_HPP
#define PLAYRHO_D2_SHAPES_DISKSHAPECONF_HPP

/// @file
/// @brief Definition of the @c DiskShapeConf class and closely related code.

// IWYU pragma: begin_exports

#include "playrho/NonNegative.hpp"
#include "playrho/Settings.hpp"
#include "playrho/TypeInfo.hpp"
#include "playrho/Vector.hpp"

#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/Math.hpp"
#include "playrho/d2/ShapeConf.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief Disk shape configuration.
///
/// @details A disk shape "is the region in a plane bounded by a circle". This is a
///   two-dimensional solid round shape. This used to be called the circle shape but
///   that's now used for hollow round shapes.
///
/// @see https://en.wikipedia.org/wiki/Disk_(mathematics)
///
/// @ingroup PartsGroup
///
struct DiskShapeConf : ShapeBuilder<DiskShapeConf> {
    /// @brief Default radius.
    static constexpr auto DefaultRadius = NonNegative<Length>{DefaultLinearSlop * 2};

    /// @brief Gets the default radius.
    /// @note This is just a backward compatibility interface for getting the default radius.
    ///    The new way is to use <code>DefaultRadius</code> directly.
    /// @return <code>DefaultRadius</code>.
    static constexpr NonNegative<Length> GetDefaultRadius() noexcept
    {
        return DefaultRadius;
    }

    constexpr DiskShapeConf() noexcept = default;

    /// @brief Initializing constructor.
    constexpr DiskShapeConf(NonNegative<Length> r) : vertexRadius{r}
    {
        // Intentionally empty.
    }

    /// @brief Uses the given value as the location.
    constexpr DiskShapeConf& UseLocation(const Length2& value) noexcept
    {
        location = value;
        return *this;
    }

    /// @brief Uses the given value as the radius.
    constexpr DiskShapeConf& UseRadius(NonNegative<Length> r) noexcept
    {
        vertexRadius = r;
        return *this;
    }

    /// @brief Translates the location by the given amount.
    constexpr DiskShapeConf& Translate(const Length2& value) noexcept
    {
        location += value;
        return *this;
    }

    /// @brief Scales the location by the given amount.
    constexpr DiskShapeConf& Scale(const Vec2& value) noexcept
    {
        location = Length2{GetX(location) * GetX(value), GetY(location) * GetY(value)};
        return *this;
    }

    /// @brief Rotates the location by the given amount.
    constexpr DiskShapeConf& Rotate(const UnitVec& value) noexcept
    {
        location = ::playrho::d2::Rotate(location, value);
        return *this;
    }

    /// @brief Gets the radius property.
    NonNegative<Length> GetRadius() const noexcept
    {
        return vertexRadius;
    }

    /// @brief Gets the location.
    Length2 GetLocation() const noexcept
    {
        return location;
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
    NonNegative<Length> vertexRadius = GetDefaultRadius();

    /// @brief Location for the disk shape to be centered at.
    Length2 location = Length2{};
};

// Free functions...

/// @brief Equality operator.
inline bool operator==(const DiskShapeConf& lhs, const DiskShapeConf& rhs) noexcept
{
    return lhs.vertexRadius == rhs.vertexRadius && lhs.friction == rhs.friction &&
           lhs.restitution == rhs.restitution && lhs.density == rhs.density &&
           lhs.filter == rhs.filter && lhs.isSensor == rhs.isSensor && lhs.location == rhs.location;
}

/// @brief Inequality operator.
inline bool operator!=(const DiskShapeConf& lhs, const DiskShapeConf& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Gets the "child" count of the given disk shape configuration.
constexpr ChildCounter GetChildCount(const DiskShapeConf&) noexcept
{
    return 1;
}

/// @brief Gets the "child" of the given disk shape configuration.
inline DistanceProxy GetChild(const DiskShapeConf& arg, ChildCounter index)
{
    if (index != 0) {
        throw InvalidArgument("only index of 0 is supported");
    }
    return DistanceProxy{arg.vertexRadius, 1, &arg.location, nullptr};
}

/// @brief Gets the vertex radius of the given shape configuration.
constexpr NonNegative<Length> GetVertexRadius(const DiskShapeConf& arg) noexcept
{
    return arg.vertexRadius;
}

/// @brief Gets the vertex radius of the given shape configuration.
constexpr NonNegative<Length> GetVertexRadius(const DiskShapeConf& arg, ChildCounter) noexcept
{
    return GetVertexRadius(arg);
}

/// @brief Sets the vertex radius of shape for the given index.
inline void SetVertexRadius(DiskShapeConf& arg, ChildCounter, NonNegative<Length> value)
{
    arg.vertexRadius = value;
}

/// @brief Gets the mass data of the given disk shape configuration.
inline MassData GetMassData(const DiskShapeConf& arg)
{
    return playrho::d2::GetMassData(arg.vertexRadius, arg.density, arg.location);
}

/// @brief Translates the given shape configuration's vertices by the given amount.
inline void Translate(DiskShapeConf& arg, const Length2& value) noexcept
{
    arg.Translate(value);
}

/// @brief Scales the given shape configuration's vertices by the given amount.
inline void Scale(DiskShapeConf& arg, const Vec2& value) noexcept
{
    arg.Scale(value);
}

/// @brief Rotates the given shape configuration's vertices by the given amount.
inline void Rotate(DiskShapeConf& arg, const UnitVec& value) noexcept
{
    arg.Rotate(value);
}

} // namespace playrho::d2

/// @brief Type info specialization for <code>playrho::d2::DiskShapeConf</code>.
template <>
struct playrho::detail::TypeInfo<playrho::d2::DiskShapeConf> {
    /// @brief Provides a null-terminated string name for the type.
    static constexpr const char* name = "d2::DiskShapeConf";
};

#endif // PLAYRHO_D2_SHAPES_DISKSHAPECONF_HPP
