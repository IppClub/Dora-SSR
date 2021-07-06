/*
 * Copyright (c) 2021 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COLLISION_SHAPES_RECTANGLE_HPP
#define PLAYRHO_COLLISION_SHAPES_RECTANGLE_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/Units.hpp"
#include "PlayRho/Common/InvalidArgument.hpp"
#include "PlayRho/Common/NonNegative.hpp"
#include "PlayRho/Common/Finite.hpp"
#include "PlayRho/Common/Settings.hpp"

#include "PlayRho/Dynamics/Filter.hpp"

#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/MassData.hpp"

#include <array>

namespace playrho::part {

/// @brief "Discriminator" for named template arguments.
/// @note "[This allows] the various setter types to be identical. (You cannot have multiple direct
///   base classes of the same type. Indirect base classes, on the other hand, can have types that
///   are identical to those of other bases.)"
/// @see https://flylib.com/books/en/3.401.1.126/1/
template <class Base, int D>
struct Discriminator : Base {
};

/// @brief Policy selector for named template arguments.
/// @see https://flylib.com/books/en/3.401.1.126/1/
template <class Set1, class Set2, class Set3, class Set4, class Set5, class Set6>
struct PolicySelector : Discriminator<Set1, 1>, //
                        Discriminator<Set2, 2>, //
                        Discriminator<Set3, 3>, //
                        Discriminator<Set4, 4>, //
                        Discriminator<Set5, 5>, //
                        Discriminator<Set6, 6> //
{
};

/// @brief Static rectangle.
/// @note This is meant to be used as a compile-time constant geometry policy class of a
///   <code>Compositor</code> class.
/// @see DynamicRectangle.
template <int W = 1, int H = 1, int V = 2>
class StaticRectangle
{
    using UnitVec = ::playrho::d2::UnitVec; ///< Alias for correct unit vector type.
    using DistanceProxy = ::playrho::d2::DistanceProxy; ///< Alias for correct distance proxy.
    using MassData = ::playrho::d2::MassData; ///< Alias for correct mass data.

    /// @brief Normals of the rectangle.
    static constexpr auto normals = std::array<UnitVec, 4u>{
        UnitVec::GetRight(), UnitVec::GetTop(), UnitVec::GetLeft(), UnitVec::GetBottom()};

    /// @brief Vertices of the rectangle.
    static constexpr auto vertices =
        std::array<Length2, 4u>{Length2{+(W * Meter) / 2, -(H* Meter) / 2}, //
                                Length2{+(W * Meter) / 2, +(H* Meter) / 2}, //
                                Length2{-(W * Meter) / 2, +(H* Meter) / 2}, //
                                Length2{-(W * Meter) / 2, -(H* Meter) / 2}};

    /// @brief Vertex radius of the shape.
    static constexpr auto vertexRadius = NonNegative<Length>{Real(V) * DefaultLinearSlop};

public:
    /// @brief Gets the dimensions of this rectangle.
    /// @see SetDimensions.
    constexpr Length2 GetDimensions() const noexcept
    {
        return Length2{GetX(vertices[0]) - GetX(vertices[2]),
                       GetY(vertices[2]) - GetY(vertices[0])};
    }

    /// @brief Sets the dimensions of this rectangle.
    /// @throws InvalidArgument If called to change the dimensions.
    /// @see GetDimensions.
    void SetDimensions(Length2 val)
    {
        if (GetDimensions() != val) {
            throw InvalidArgument("changing dimensions not supported");
        }
    }

    /// @brief Gets the x and y offset of this rectangle.
    /// @see SetOffset.
    constexpr Length2 GetOffset() const noexcept
    {
        return Length2{(GetX(vertices[0]) + GetX(vertices[2])) / 2,
                       (GetY(vertices[0]) + GetY(vertices[2])) / 2};
    }

    /// @brief Sets the x and y offset of this rectangle.
    /// @throws InvalidArgument If called to change the offset.
    /// @see GetOffset.
    void SetOffset(Length2 val)
    {
        if (GetOffset() != val) {
            throw InvalidArgument("changing offset not supported");
        }
    }

    /// @brief Gets the vertex radius.
    constexpr NonNegative<Length> GetVertexRadius() const noexcept
    {
        return vertexRadius;
    }

    /// @brief Gets this rectangle's vertices.
    /// @see GetNormals.
    const std::array<Length2, 4u>& GetVertices() const noexcept
    {
        return vertices;
    }

    /// @brief Gets this rectangle's normals.
    /// @see GetVertices.
    const std::array<UnitVec, 4u>& GetNormals() const noexcept
    {
        return normals;
    }

    /// @brief Gets the child count.
    /// @see GetChild.
    ChildCounter GetChildCount() const noexcept
    {
        return 1;
    }

    /// @brief Gets the "child" shape for the given shape configuration.
    DistanceProxy GetChild(ChildCounter index) const
    {
        if (index != 0) {
            throw InvalidArgument("only index of 0 is supported");
        }
        return DistanceProxy{GetVertexRadius(), static_cast<VertexCounter>(size(GetVertices())),
                             data(GetVertices()), data(GetNormals())};
    }

    /// @brief Gets the mass data for the geometry.
    MassData GetMassData(NonNegative<AreaDensity> density) const noexcept
    {
        return playrho::d2::GetMassData(vertexRadius, density, Span<const Length2>(GetVertices()));
    }

    /// @brief Sets the vertex radius for the specified child to the given value.
    /// @note This class doesn't support changing the vertex radius.
    void SetVertexRadius(ChildCounter, NonNegative<Length> value)
    {
        if (GetVertexRadius() != value) {
            throw InvalidArgument("changing vertex radius not supported");
        }
    }
};

/// @brief Dynamic rectangle.
/// @note This is meant to be used as a run-time changable geometry policy class of a
///   <code>Compositor</code> class.
/// @see StaticRectangle.
template <int W = 1, int H = 1, int V = 2>
class DynamicRectangle
{
    using UnitVec = ::playrho::d2::UnitVec; ///< Alias for correct unit vector type.
    using DistanceProxy = ::playrho::d2::DistanceProxy; ///< Alias for correct distance proxy.
    using MassData = ::playrho::d2::MassData; ///< Alias for correct mass data.

    /// @brief Normals of the rectangle.
    static constexpr auto normals = std::array<UnitVec, 4u>{
        UnitVec::GetRight(), UnitVec::GetTop(), UnitVec::GetLeft(), UnitVec::GetBottom()};

    /// @brief Vertices of the rectangle.
    std::array<Length2, 4u> vertices =
        std::array<Length2, 4u>{Length2{+(W * Meter) / 2, -(H* Meter) / 2}, //
                                Length2{+(W * Meter) / 2, +(H* Meter) / 2}, //
                                Length2{-(W * Meter) / 2, +(H* Meter) / 2}, //
                                Length2{-(W * Meter) / 2, -(H* Meter) / 2}};

    /// @brief Vertex radius of the shape.
    NonNegative<Length> vertexRadius = NonNegative<Length>{Real(V) * DefaultLinearSlop};

public:
    DynamicRectangle() = default;

    /// @brief Initializing constructor.
    DynamicRectangle(Length width, Length height, Length2 offset = Length2{})
        : vertices{Length2{+width / 2, -height / 2} + offset, //
                   Length2{+width / 2, +height / 2} + offset, //
                   Length2{-width / 2, +height / 2} + offset, //
                   Length2{-width / 2, -height / 2} + offset}
    {
        // Intentionally empty.
    }

    /// @brief Gets the dimensions of this rectangle.
    /// @see SetDimensions.
    Length2 GetDimensions() const noexcept
    {
        return Length2{GetX(vertices[0]) - GetX(vertices[2]),
                       GetY(vertices[2]) - GetY(vertices[0])};
    }

    /// @brief Sets the dimensions of this rectangle.
    /// @see GetDimensions.
    void SetDimensions(Length2 val)
    {
        const auto offset = GetOffset();
        vertices = {Length2{+GetX(val) / 2, -GetY(val) / 2} + offset, //
                    Length2{+GetX(val) / 2, +GetY(val) / 2} + offset, //
                    Length2{-GetX(val) / 2, +GetY(val) / 2} + offset, //
                    Length2{-GetX(val) / 2, -GetY(val) / 2} + offset};
    }

    /// @brief Gets the x and y offset of this rectangle.
    /// @see SetOffset.
    Length2 GetOffset() const noexcept
    {
        return Length2{(GetX(vertices[0]) + GetX(vertices[2])) / 2,
                       (GetY(vertices[0]) + GetY(vertices[2])) / 2};
    }

    /// @brief Sets the x and y offset of this rectangle.
    /// @see GetOffset.
    void SetOffset(Length2 val)
    {
        const auto dims = GetDimensions();
        vertices = {Length2{+GetX(dims) / 2, -GetY(dims) / 2} + val, //
                    Length2{+GetX(dims) / 2, +GetY(dims) / 2} + val, //
                    Length2{-GetX(dims) / 2, +GetY(dims) / 2} + val, //
                    Length2{-GetX(dims) / 2, -GetY(dims) / 2} + val};
    }

    /// @brief Gets the vertex radius.
    constexpr NonNegative<Length> GetVertexRadius() const noexcept
    {
        return vertexRadius;
    }

    /// @brief Gets this rectangle's vertices.
    /// @see GetNormals, SetDimensions, SetOffset.
    const std::array<Length2, 4u>& GetVertices() const noexcept
    {
        return vertices;
    }

    /// @brief Gets this rectangle's normals.
    /// @see GetVertices.
    const std::array<UnitVec, 4u>& GetNormals() const noexcept
    {
        return normals;
    }

    /// @brief Gets the child count.
    /// @see GetChild.
    ChildCounter GetChildCount() const noexcept
    {
        return 1;
    }

    /// @brief Gets the "child" shape for the given shape configuration.
    DistanceProxy GetChild(ChildCounter index) const
    {
        if (index != 0) {
            throw InvalidArgument("only index of 0 is supported");
        }
        return DistanceProxy{GetVertexRadius(), static_cast<VertexCounter>(size(GetVertices())),
                             data(GetVertices()), data(GetNormals())};
    }

    /// @brief Gets the mass data for the geometry.
    MassData GetMassData(NonNegative<AreaDensity> density) const noexcept
    {
        return playrho::d2::GetMassData(vertexRadius, density, Span<const Length2>(GetVertices()));
    }

    /// @brief Sets the vertex radius for the specified child to the given value.
    /// @note This class does support changing the vertex radius.
    void SetVertexRadius(ChildCounter, NonNegative<Length> value)
    {
        vertexRadius = value;
    }

    /// @brief Translates the vertices of this geometry.
    void Translate(Length2 value)
    {
        SetOffset(GetOffset() + value);
    }

    /// @brief Scales the vertices of this geometry.
    void Scale(Vec2 value)
    {
        const auto dims = GetDimensions();
        SetDimensions(Length2{GetX(dims) * GetX(value), GetY(dims) * GetY(value)});
    }
};

/// @brief Static friction.
template <int F = 0>
struct StaticFriction {
    /// @brief Friction of the shape.
    static constexpr auto friction = NonNegative<Real>(F);
};

/// @brief Dynamic friction.
template <int F = 0>
struct DynamicFriction {
    /// @brief Friction of the shape.
    NonNegative<Real> friction = NonNegative<Real>(F);
};

/// @brief Static tenths friction.
/// @note This is a special template class for achieving fractional frictions with pre C++20
///   versions of C++ that don't yet support float and double template parameters.
template <int F = 2>
struct StaticTenthsFriction {
    /// @brief Friction of the shape.
    static constexpr auto friction = NonNegative<Real>{Real(F) / Real{10}};
};

/// @brief Static restitution policy class.
template <int R = 0>
struct StaticRestitution {
    /// @brief Restitution of the shape.
    static inline const auto restitution = Finite<Real>(R);
};

/// @brief Dynamic restitution policy class.
template <int R = 0>
struct DynamicRestitution {
    /// @brief Restitution of the shape.
    Finite<Real> restitution = Finite<Real>(R);
};

/// @brief Static area density policy class.
template <int D = 0>
struct StaticAreaDensity {
    /// @brief Areal density of the shape (for use with 2D shapes).
    static constexpr auto density = NonNegative<AreaDensity>{Real(D) * KilogramPerSquareMeter};
};

/// @brief Dynamic area density policy class.
template <int D = 0>
struct DynamicAreaDensity {
    /// @brief Areal density of the shape (for use with 2D shapes).
    NonNegative<AreaDensity> density = NonNegative<AreaDensity>{Real(D) * KilogramPerSquareMeter};
};

/// @brief Static filter policy class.
template <Filter::bits_type CategoryBits = 1, Filter::bits_type MaskBits = 0xFFFF,
          Filter::index_type GroupIndex = 0>
struct StaticFilter {
    /// @brief The filter of the shape.
    static inline const auto filter = Filter{CategoryBits, MaskBits, GroupIndex};
};

/// @brief Dynamic filter policy class.
template <Filter::bits_type CategoryBits = 1, Filter::bits_type MaskBits = 0xFFFF,
          Filter::index_type GroupIndex = 0>
struct DynamicFilter {
    /// @brief The filter of the shape.
    Filter filter = Filter{CategoryBits, MaskBits, GroupIndex};
};

/// @brief Static sensor policy class.
template <bool V = false>
struct StaticSensor {
    /// @brief Sensor property of the shape.
    static constexpr auto sensor = V;
};

/// @brief Dynamic sensor policy class.
template <bool V = false>
struct DynamicSensor {
    /// @brief Sensor property of the shape.
    bool sensor = V;
};

/// @brief Default policies for the <code>Compositor</code> template class.
/// @see Compositor.
struct DefaultPolicies {
    /// @brief Alias of the geometry policy.
    using Geometry = StaticRectangle<>;

    /// @brief Alias of the density policy.
    using Density = StaticAreaDensity<>;

    /// @brief Alias of the friction policy.
    using Friction = StaticTenthsFriction<>;

    /// @brief Alias of the restitution policy.
    using Restitution = StaticRestitution<>;

    /// @brief Alias of the filter policy.
    using Filter = StaticFilter<>;

    /// @brief Alias of the sensor policy.
    using Sensor = StaticSensor<>;
};

/// @brief Sets the alias for the geometry policy.
template <class Policy>
struct GeometryIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Geometry
    using Geometry = Policy;
};

/// @brief Sets the alias for the density policy.
template <class Policy>
struct DensityIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Density
    using Density = Policy;
};

/// @brief Sets the alias for the friction policy.
template <class Policy>
struct FrictionIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Friction
    using Friction = Policy;
};

/// @brief Sets the alias for the restitution policy.
template <class Policy>
struct RestitutionIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Restitution
    using Restitution = Policy;
};

/// @brief Sets the alias for the filter policy.
template <class Policy>
struct FilterIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Filter
    using Filter = Policy;
};

/// @brief Sets the alias for the sensor policy.
template <class Policy>
struct SensorIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Sensor
    using Sensor = Policy;
};

/// @brief Default policy arguments for the <code>Compositor</code> template class.
struct DefaultPolicyArgs : virtual DefaultPolicies {
};

/// @brief A template class for compositing eligible shape types.
template <class P1 = DefaultPolicyArgs, //
          class P2 = DefaultPolicyArgs, //
          class P3 = DefaultPolicyArgs, //
          class P4 = DefaultPolicyArgs, //
          class P5 = DefaultPolicyArgs, //
          class P6 = DefaultPolicyArgs>
class Compositor : // break
                   public PolicySelector<P1, P2, P3, P4, P5, P6>::Geometry, // break
                   public PolicySelector<P1, P2, P3, P4, P5, P6>::Density, // break
                   public PolicySelector<P1, P2, P3, P4, P5, P6>::Friction, // break
                   public PolicySelector<P1, P2, P3, P4, P5, P6>::Restitution, // break
                   public PolicySelector<P1, P2, P3, P4, P5, P6>::Filter, // break
                   public PolicySelector<P1, P2, P3, P4, P5, P6>::Sensor // break
{
};

/// @brief Gets the rectangle's width and height dimensions.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetDimensions(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.GetDimensions())
{
    return arg.GetDimensions();
}

/// @brief Sets the rectangle's width and height dimensions.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetDimensions(Compositor<P1, P2, P3, P4, P5, P6>& arg, decltype(arg.GetDimensions()) value)
    -> decltype(arg.SetDimensions(value))
{
    arg.SetDimensions(value);
}

/// @brief Gets the rectangle's x and y offset.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetOffset(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.GetOffset())
{
    return arg.GetOffset();
}

/// @brief Sets the rectangle's x and y offset.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetOffset(Compositor<P1, P2, P3, P4, P5, P6>& arg, decltype(arg.GetOffset()) value)
    -> decltype(arg.SetOffset(value))
{
    arg.SetOffset(value);
}

/// @brief Gets the "child" count for the given shape configuration.
/// @return 1.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetChildCount(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.GetChildCount())
{
    return arg.GetChildCount();
}

/// @brief Gets the "child" shape for the given shape configuration.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto GetChild(const Compositor<P1, P2, P3, P4, P5, P6>& arg,
              ChildCounter index) noexcept(noexcept(arg.GetChild(index)))
    -> decltype(arg.GetChild(index))
{
    return arg.GetChild(index);
}

/// @brief Gets the density of the given shape configuration.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetDensity(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.density)
{
    return arg.density;
}

/// @brief Gets the restitution of the given shape configuration.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetRestitution(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.restitution)
{
    return arg.restitution;
}

/// @brief Gets the friction of the given shape configuration.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetFriction(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.friction)
{
    return arg.friction;
}

/// @brief Gets the filter of the given shape configuration.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetFilter(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.filter)
{
    return arg.filter;
}

/// @brief Gets the is-sensor state of the given shape configuration.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto IsSensor(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.sensor)
{
    return arg.sensor;
}

/// @brief Gets the vertex radius of the given shape configuration.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetVertexRadius(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept(
    noexcept(arg.GetVertexRadius())) -> decltype(arg.GetVertexRadius())
{
    return arg.GetVertexRadius();
}

/// @brief Gets the vertex radius of the given shape configuration.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto GetVertexRadius(const Compositor<P1, P2, P3, P4, P5, P6>& arg,
                     ChildCounter index) noexcept(noexcept(GetChild(arg, index)))
    -> decltype(GetVertexRadius(GetChild(arg, index)))
{
    return GetVertexRadius(GetChild(arg, index));
}

/// @brief Gets the mass data for the given shape configuration.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto GetMassData(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.GetMassData(GetDensity(arg)))
{
    return arg.GetMassData(GetDensity(arg));
}

/// @brief Translates the given compositor's vertices by the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6, std::size_t N>
auto Translate(Compositor<P1, P2, P3, P4, P5, P6>& arg, const Vector<Length, N>& value)
    -> decltype(arg.Translate(value))
{
    return arg.Translate(value);
}

/// @brief Scales the given compositor's vertices by the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6, std::size_t N>
auto Scale(Compositor<P1, P2, P3, P4, P5, P6>& arg, const Vector<Real, N>& value)
    -> decltype(arg.Scale(value))
{
    return arg.Scale(value);
}

/// @brief Rotates the given compositor's vertices by the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto Rotate(Compositor<P1, P2, P3, P4, P5, P6>& arg, ::playrho::d2::UnitVec value)
    -> decltype(arg.Rotate(value))
{
    return arg.Rotate(value);
}

/// @brief Gets the vertex radius of the given shape configuration.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetVertexRadius(Compositor<P1, P2, P3, P4, P5, P6>& arg, ChildCounter index,
                     decltype(arg.GetVertexRadius()) value)
    -> decltype(arg.SetVertexRadius(index, value))
{
    return arg.SetVertexRadius(index, value);
}

/// @brief Density setter.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetDensity(Compositor<P1, P2, P3, P4, P5, P6>& arg, NonNegative<AreaDensity> value)
    -> std::enable_if_t<!std::is_const_v<decltype(arg.density)>, void>
{
    arg.density = value;
}

/// @brief Filter setter.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetFilter(Compositor<P1, P2, P3, P4, P5, P6>& arg, Filter value)
    -> std::enable_if_t<!std::is_const_v<decltype(arg.filter)>, void>
{
    arg.filter = value;
}

/// @brief Sensor setter.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetSensor(Compositor<P1, P2, P3, P4, P5, P6>& arg, bool value)
    -> std::enable_if_t<!std::is_const_v<decltype(arg.sensor)>, void>
{
    arg.sensor = value;
}

/// @brief Sets friction.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetFriction(Compositor<P1, P2, P3, P4, P5, P6>& arg, Real value)
    -> std::enable_if_t<!std::is_const_v<decltype(arg.friction)>, void>
{
    arg.friction = value;
}

/// @brief Sets restitution.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetRestitution(Compositor<P1, P2, P3, P4, P5, P6>& arg, Real value)
    -> std::enable_if_t<!std::is_const_v<decltype(arg.restitution)>, void>
{
    arg.restitution = value;
}

/// @brief Equality operator.
/// @relatedalso Compositor
template <class P11, class P12, class P13, class P14, class P15, class P16, //
          class P21, class P22, class P23, class P24, class P25, class P26>
bool operator==(const Compositor<P11, P12, P13, P14, P15, P16>& lhs,
                const Compositor<P21, P22, P23, P24, P25, P26>& rhs) noexcept
{
    if (GetDensity(lhs) != GetDensity(rhs) || // force break
        GetFriction(lhs) != GetFriction(rhs) || // force break
        GetRestitution(lhs) != GetRestitution(rhs) || // force break
        GetFilter(lhs) != GetFilter(rhs) || // force break
        IsSensor(lhs) != IsSensor(rhs)) {
        return false;
    }
    const auto lhsCount = GetChildCount(lhs);
    const auto rhsCount = GetChildCount(rhs);
    if (lhsCount != rhsCount) {
        return false;
    }
    for (auto i = static_cast<decltype(lhsCount)>(0); i < lhsCount; ++i) {
        if (GetChild(lhs, i) != GetChild(rhs, i)) {
            return false;
        }
    }
    return true;
}

/// @brief Inequality operator.
/// @relatedalso Compositor
template <class P11, class P12, class P13, class P14, class P15, class P16, //
          class P21, class P22, class P23, class P24, class P25, class P26>
bool operator!=(const Compositor<P11, P12, P13, P14, P15, P16>& lhs,
                const Compositor<P21, P22, P23, P24, P25, P26>& rhs) noexcept
{
    return !(lhs == rhs);
}

} // namespace playrho::part

#endif // PLAYRHO_COLLISION_SHAPES_RECTANGLE_HPP
