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

#ifndef PLAYRHO_D2_PART_COMPOSITOR_HPP
#define PLAYRHO_D2_PART_COMPOSITOR_HPP

#include <array>
#include <type_traits> // for std::enable_if_t

// IWYU pragma: begin_exports

#include "playrho/Units.hpp"
#include "playrho/InvalidArgument.hpp"
#include "playrho/NonNegative.hpp"
#include "playrho/Finite.hpp"
#include "playrho/Settings.hpp"

#include "playrho/Filter.hpp"

#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/Math.hpp"

// IWYU pragma: end_exports

namespace playrho::d2::part {

namespace detail {

/// @brief Member rotate return type.
template <class T>
using MemberRotateReturnType = decltype(std::declval<T&>().Rotate(UnitVec{}));

/// @brief Helper variable template on whether <code>Rotate(T&, Angle)</code> is found.
template <class T>
inline constexpr bool HasMemberRotateV = playrho::detail::is_detected_v<MemberRotateReturnType, T>;

/// @brief Member scale return type.
template <class T>
using MemberScaleReturnType = decltype(std::declval<T&>().Scale(Vec2{}));

/// @brief Helper variable template on whether <code>Scale(T&, Vec2)</code> is found.
template <class T>
inline constexpr bool HasMemberScaleV = playrho::detail::is_detected_v<MemberScaleReturnType, T>;

/// @brief Member translate return type.
template <class T>
using MemberTranslateReturnType = decltype(std::declval<T&>().Translate(Length2{}));

/// @brief Helper variable template on whether <code>Scale(T&, Vec2)</code> is found.
template <class T>
inline constexpr bool HasMemberTranslateV = playrho::detail::is_detected_v<MemberTranslateReturnType, T>;

}

/// @brief "Discriminator" for named template arguments.
/// @note "[This allows] the various setter types to be identical. (You cannot have multiple direct
///   base classes of the same type. Indirect base classes, on the other hand, can have types that
///   are identical to those of other bases.)"
/// @note This class is not intended for standalone use.
/// @tparam Base Class to derive from - as a "mixin".
/// @tparam D Unique index of the discriminator within a derived class that can then possibly inherit
///   from multiple discriminators.
/// @see https://flylib.com/books/en/3.401.1.126/1/
template <class Base, int D>
struct Discriminator : Base {
};

/// @brief Policy selector for named template arguments for the <code>Compositor</code> host class
/// template.
/// @note This class is not intended for standalone use.
/// @see Compositor.
template <class Set1, class Set2, class Set3, class Set4, class Set5, class Set6>
struct PolicySelector : Discriminator<Set1, 1>, // NOLINT(readability-magic-numbers,cppcoreguidelines-avoid-magic-numbers)
                        Discriminator<Set2, 2>, // NOLINT(readability-magic-numbers,cppcoreguidelines-avoid-magic-numbers)
                        Discriminator<Set3, 3>, // NOLINT(readability-magic-numbers,cppcoreguidelines-avoid-magic-numbers)
                        Discriminator<Set4, 4>, // NOLINT(readability-magic-numbers,cppcoreguidelines-avoid-magic-numbers)
                        Discriminator<Set5, 5>, // NOLINT(readability-magic-numbers,cppcoreguidelines-avoid-magic-numbers)
                        Discriminator<Set6, 6>  // NOLINT(readability-magic-numbers,cppcoreguidelines-avoid-magic-numbers)
{
};

/// @brief Static rectangle.
/// @details Provides a rectangular compile-time static class implementation of the geometry policy
/// of the <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @code
/// // Here's an example use of this class for a 3m-wide by 2m-high rectangular part...
/// auto comp = Compositor<GeometryIs<StaticRectangle<3, 2>>>{};
/// @endcode
/// @see DynamicRectangle, Compositor.
template <int W = 1, int H = 1, int V = 2>
class StaticRectangle
{
    using UnitVec = ::playrho::d2::UnitVec; ///< Alias for correct unit vector type.
    using DistanceProxy = ::playrho::d2::DistanceProxy; ///< Alias for correct distance proxy.
    using MassData = ::playrho::d2::MassData; ///< Alias for correct mass data.

    /// @brief Normals of the rectangle.
    static constexpr auto normals = std::array<UnitVec, 4u>{
        UnitVec::GetRight(), UnitVec::GetUp(), UnitVec::GetLeft(), UnitVec::GetDown()};

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
/// @details Provides a rectangular runtime-time configurable class implementation of the geometry
/// policy of the <code>Compositor</code> host class template. Unlike the
/// <code>StaticRectangle</code>, this class can have width, height, vertex-radius, and offset
/// set at runtime.
/// @note This class is not intended for standalone use.
/// @code
/// // Here's an example use of this class for a 3m-wide by 2m-high rectangular part...
/// auto comp = Compositor<GeometryIs<DynamicRectangle<3, 2>>>{};
/// @endcode
/// @see StaticRectangle, Compositor.
template <int W = 1, int H = 1, int V = 2>
class DynamicRectangle
{
    using UnitVec = ::playrho::d2::UnitVec; ///< Alias for correct unit vector type.
    using DistanceProxy = ::playrho::d2::DistanceProxy; ///< Alias for correct distance proxy.
    using MassData = ::playrho::d2::MassData; ///< Alias for correct mass data.

    /// @brief Normals of the rectangle.
    static constexpr auto normals = std::array<UnitVec, 4u>{
        UnitVec::GetRight(), UnitVec::GetUp(), UnitVec::GetLeft(), UnitVec::GetDown()};

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
    DynamicRectangle(Length width, Length height, const Length2& offset = Length2{})
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
    void SetDimensions(const Length2& val)
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
    void SetOffset(const Length2& val)
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
    void Translate(const Length2& value)
    {
        SetOffset(GetOffset() + value);
    }

    /// @brief Scales the vertices of this geometry.
    void Scale(const Vec2& value)
    {
        const auto dims = GetDimensions();
        SetDimensions(Length2{GetX(dims) * GetX(value), GetY(dims) * GetY(value)});
    }
};

/// @brief Static friction.
/// @details Provides a compile-time static class implementation of the friction policy of the
///   <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see DynamicFriction, Compositor.
template <int F = 0>
struct StaticFriction {
    /// @brief Friction of the shape.
    static constexpr auto friction = NonNegative<Real>(F);
};

/// @brief Dynamic friction.
/// @details Provides a runtime-time configurable class implementation of the friction policy of the
///   <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see StaticFriction, Compositor.
template <int F = 0>
struct DynamicFriction {
    /// @brief Friction of the shape.
    NonNegative<Real> friction = NonNegative<Real>(F);
};

/// @brief Static tenths friction.
/// @details Provides a compile-time static class implementation of the friction policy of the
///   <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @note This is a special template class for achieving fractional frictions with pre C++20
///   versions of C++ that don't yet support float and double template parameters.
/// @see StaticFriction, DynamicFriction, Compositor.
template <int F = 2>
struct StaticTenthsFriction {
    /// @brief Friction of the shape.
    static constexpr auto friction = NonNegative<Real>{Real(F) / Real{10}};
};

/// @brief Static restitution policy class.
/// @details Provides a compile-time static class implementation of the restitution policy of the
///   <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see DynamicRestitution, Compositor.
template <int R = 0>
struct StaticRestitution {
    /// @brief Restitution of the shape.
    static inline const auto restitution = Finite<Real>(Real(R));
};

/// @brief Dynamic restitution policy class.
/// @details Provides a runtime-time configurable class implementation of the restitution policy of
/// the <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see StaticRestitution, Compositor.
template <int R = 0>
struct DynamicRestitution {
    /// @brief Restitution of the shape.
    Finite<Real> restitution = Finite<Real>(R);
};

/// @brief Static area density policy class.
/// @details Provides a compile-time static class implementation of the density policy of the
/// <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see DynamicAreaDensity, Compositor.
template <int D = 0>
struct StaticAreaDensity {
    /// @brief Areal density of the shape (for use with 2D shapes).
    static constexpr auto density = NonNegative<AreaDensity>{Real(D) * KilogramPerSquareMeter};
};

/// @brief Dynamic area density policy class.
/// @details Provides a runtime-time configurable class implementation of the density policy of
/// the <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see StaticAreaDensity, Compositor.
template <int D = 0>
struct DynamicAreaDensity {
    /// @brief Areal density of the shape (for use with 2D shapes).
    NonNegative<AreaDensity> density = NonNegative<AreaDensity>{Real(D) * KilogramPerSquareMeter};
};

/// @brief Static filter policy class.
/// @details Provides a compile-time static class implementation of the filter policy of the
/// <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see DynamicFilter, Compositor.
template <Filter::bits_type CategoryBits = Filter::DefaultCategoryBits, //
          Filter::bits_type MaskBits = Filter::DefaultMaskBits, //
          Filter::index_type GroupIndex = Filter::DefaultGroupIndex>
struct StaticFilter {
    /// @brief The filter of the shape.
    static inline const auto filter = Filter{CategoryBits, MaskBits, GroupIndex};
};

/// @brief Dynamic filter policy class.
/// @details Provides a runtime-time configurable class implementation of the filter policy of the
/// <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see StaticFilter, Compositor.
template <Filter::bits_type CategoryBits = Filter::DefaultCategoryBits, //
          Filter::bits_type MaskBits = Filter::DefaultMaskBits, //
          Filter::index_type GroupIndex = Filter::DefaultGroupIndex>
struct DynamicFilter {
    /// @brief The filter of the shape.
    Filter filter = Filter{CategoryBits, MaskBits, GroupIndex};
};

/// @brief Static sensor policy class.
/// @details Provides a compile-time static class implementation of the sensor policy of the
/// <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see DynamicSensor, Compositor.
template <bool V = false>
struct StaticSensor {
    /// @brief Sensor property of the shape.
    static constexpr auto sensor = V;
};

/// @brief Dynamic sensor policy class.
/// @details Provides a runtime-time configurable class implementation of the sensor policy of the
/// <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see StaticSensor, Compositor.
template <bool V = false>
struct DynamicSensor {
    /// @brief Sensor property of the shape.
    bool sensor = V;
};

/// @brief Default policy class implementations for the <code>Compositor</code> host class template.
/// @note This class is not intended for standalone use.
/// @see Compositor.
struct DefaultPolicies {
    /// @brief Alias to the implementing class for the geometry policy.
    using Geometry = StaticRectangle<>;

    /// @brief Alias to the implementing class for the density policy.
    using Density = StaticAreaDensity<>;

    /// @brief Alias for the friction policy.
    using Friction = StaticTenthsFriction<>;

    /// @brief Alias to the implementing class for the restitution policy.
    using Restitution = StaticRestitution<>;

    /// @brief Alias to the implementing class for the filter policy.
    using Filter = StaticFilter<>;

    /// @brief Alias to the implementing class for the sensor policy.
    using Sensor = StaticSensor<>;
};

/// @brief Sets the implementing class of the <code>Compositor</code> geometry policy.
/// @note This class is not intended for standalone use.
/// @note Deliberately uses virtual inheritance of the <code>DefaultPolicies</code> base class in
/// order to properly ensure the intended override of the alias.
/// @see Compositor.
template <class Policy>
struct GeometryIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Geometry
    using Geometry = Policy;
};

/// @brief Sets the implementing class of the <code>Compositor</code> density policy.
/// @note This class is not intended for standalone use.
/// @note Deliberately uses virtual inheritance of the <code>DefaultPolicies</code> base class in
/// order to properly ensure the intended override of the alias.
/// @see Compositor.
template <class Policy>
struct DensityIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Density
    using Density = Policy;
};

/// @brief Sets the implementing class of the <code>Compositor</code> friction policy.
/// @note This class is not intended for standalone use.
/// @note Deliberately uses virtual inheritance of the <code>DefaultPolicies</code> base class in
/// order to properly ensure the intended override of the alias.
/// @see Compositor.
template <class Policy>
struct FrictionIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Friction
    using Friction = Policy;
};

/// @brief Sets the implementing class of the <code>Compositor</code> restitution policy.
/// @note This class is not intended for standalone use.
/// @note Deliberately uses virtual inheritance of the <code>DefaultPolicies</code> base class in
/// order to properly ensure the intended override of the alias.
/// @see Compositor.
template <class Policy>
struct RestitutionIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Restitution
    using Restitution = Policy;
};

/// @brief Sets the implementing class of the <code>Compositor</code> filter policy.
/// @note This class is not intended for standalone use.
/// @note Deliberately uses virtual inheritance of the <code>DefaultPolicies</code> base class in
/// order to properly ensure the intended override of the alias.
/// @see Compositor.
template <class Policy>
struct FilterIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Filter
    using Filter = Policy;
};

/// @brief Sets the implementing class of the <code>Compositor</code> sensor policy.
/// @note This class is not intended for standalone use.
/// @note Deliberately uses virtual inheritance of the <code>DefaultPolicies</code> base class in
/// order to properly ensure the intended override of the alias.
/// @see Compositor.
template <class Policy>
struct SensorIs : virtual DefaultPolicies {
    /// @copydoc DefaultPolicies::Sensor
    using Sensor = Policy;
};

/// @brief Default policy arguments for the <code>Compositor</code> template class.
/// @note This class is not intended for standalone use.
/// @note Deliberately uses virtual inheritance of the <code>DefaultPolicies</code> base class in
/// order to properly ensure the intended behavior.
/// @see Compositor.
struct DefaultPolicyArgs : virtual DefaultPolicies {
};

/// @example Compositor.cpp
/// This is the <code>googletest</code> based unit testing file for uses of the
///   <code>playrho::d2::part::Compositor</code> class template.

/// @brief A class template for compositing shaped part types eligible for use with classes like
/// the <code>::playrho::d2::Shape</code> class.
/// @note This is a host class template that defines geometry, density, friction, restitution,
/// filter, and sensor policies and that is setup to use default implementations of these per the
/// <code>DefaultPolicies</code> class. Use any number of the six policy setter classes -
/// <code>GeometryIs</code>, <code>DensityIs</code>, <code>RestitutionIs</code>,
/// <code>FrictionIs</code>, <code>SensorIs</code>, <code>FilterIs</code> (as a named template class
/// argument) - to override these defaults that you'd like to change.
/// @ingroup PartsGroup
/// @code
/// // Here's an example use of this class for a defaulted, enitrely static, rectangular part...
/// auto comp0 = Compositor<>{};
///
/// // Here's an example use of this class for a fully runtime settable rectangular part...
/// auto comp1 = Compositor<GeometryIs<DynamicRectangle<>>, //
///                         DensityIs<DynamicAreaDensity<>>, //
///                         RestitutionIs<DynamicRestitution<>>, //
///                         FrictionIs<DynamicFriction<>>, //
///                         SensorIs<DynamicSensor<>>, //
///                         FilterIs<DynamicFilter<>>>{};
/// @endcode
/// @see ::playrho::d2::Shape, DefaultPolicies, GeometryIs, DensityIs, FrictionIs, RestitutionIs,
/// FilterIs, SensorIs.
/// @see https://en.wikipedia.org/wiki/Modern_C%2B%2B_Design#Policy-based_design
/// @see https://flylib.com/books/en/3.401.1.126/1/
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
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member function of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetDimensions(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.GetDimensions())
{
    return arg.GetDimensions();
}

/// @brief Sets the rectangle's width and height dimensions.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member function of this same name and accepting the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetDimensions(Compositor<P1, P2, P3, P4, P5, P6>& arg, decltype(arg.GetDimensions()) value)
    -> decltype(arg.SetDimensions(value))
{
    arg.SetDimensions(value);
}

/// @brief Gets the rectangle's x and y offset.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member function of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetOffset(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.GetOffset())
{
    return arg.GetOffset();
}

/// @brief Sets the rectangle's x and y offset.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member function of this same name and accepting the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetOffset(Compositor<P1, P2, P3, P4, P5, P6>& arg, decltype(arg.GetOffset()) value)
    -> decltype(arg.SetOffset(value))
{
    arg.SetOffset(value);
}

/// @brief Gets the "child" count for the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member function of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetChildCount(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.GetChildCount())
{
    return arg.GetChildCount();
}

/// @brief Gets the "child" shape for the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member function of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto GetChild(const Compositor<P1, P2, P3, P4, P5, P6>& arg,
              ChildCounter index) noexcept(noexcept(arg.GetChild(index)))
    -> decltype(arg.GetChild(index))
{
    return arg.GetChild(index);
}

/// @brief Gets the density of the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member variable of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetDensity(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.density)
{
    return arg.density;
}

/// @brief Gets the restitution of the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member variable of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetRestitution(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.restitution)
{
    return arg.restitution;
}

/// @brief Gets the friction of the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member variable of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetFriction(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.friction)
{
    return arg.friction;
}

/// @brief Gets the filter of the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member variable of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetFilter(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.filter)
{
    return arg.filter;
}

/// @brief Gets the is-sensor state of the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member variable of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto IsSensor(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.sensor)
{
    return arg.sensor;
}

/// @brief Gets the vertex radius of the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member function of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
constexpr auto GetVertexRadius(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept(
    noexcept(arg.GetVertexRadius())) -> decltype(arg.GetVertexRadius())
{
    return arg.GetVertexRadius();
}

/// @brief Gets the vertex radius of the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member function of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto GetVertexRadius(const Compositor<P1, P2, P3, P4, P5, P6>& arg,
                     ChildCounter index) noexcept(noexcept(GetChild(arg, index)))
    -> decltype(GetVertexRadius(GetChild(arg, index)))
{
    return GetVertexRadius(GetChild(arg, index));
}

/// @brief Gets the mass data for the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member function of this same name.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto GetMassData(const Compositor<P1, P2, P3, P4, P5, P6>& arg) noexcept
    -> decltype(arg.GetMassData(GetDensity(arg)))
{
    return arg.GetMassData(GetDensity(arg));
}

/// @brief Translates the given compositor's vertices by the given value.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member function of this same name and accepting the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto Translate(Compositor<P1, P2, P3, P4, P5, P6>& arg, const Length2& value)
    -> std::enable_if_t<detail::HasMemberTranslateV<decltype(arg)>, void>
{
    return arg.Translate(value);
}

/// @brief No-op translation function.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   not having a member function of this same name and accepting the given value.
/// @throw InvalidArgument if value not zero.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto Translate(Compositor<P1, P2, P3, P4, P5, P6>& arg, const Length2& value)
    -> std::enable_if_t<!detail::HasMemberTranslateV<decltype(arg)>, void>
{
    if (Length2{} != value) {
        throw InvalidArgument("Translate non-zero amount not supported");
    }
}

/// @brief Scales the given compositor's vertices by the given value.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   having a member function of this same name and accepting the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto Scale(Compositor<P1, P2, P3, P4, P5, P6>& arg, const Vec2& value)
    -> std::enable_if_t<detail::HasMemberScaleV<decltype(arg)>, void>
{
    arg.Scale(value);
}

/// @brief No-op scale function.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   not having a member function of this same name and accepting the given value.
/// @throw InvalidArgument if value not the identity vector.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto Scale(Compositor<P1, P2, P3, P4, P5, P6>& arg, const Vec2& value)
    -> std::enable_if_t<!detail::HasMemberScaleV<decltype(arg)>, void>
{
    if (Vec2{Real(1), Real(1)} != value) {
        throw InvalidArgument("Scale non-identity amount not supported");
    }
}

/// @brief Rotates the given compositor's vertices by the given value.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   having a member function of this same name and accepting the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto Rotate(Compositor<P1, P2, P3, P4, P5, P6>& arg, ::playrho::d2::UnitVec value)
    -> std::enable_if_t<detail::HasMemberRotateV<decltype(arg)>, void>
{
    arg.Rotate(value);
}

/// @brief No-op rotate function.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   not having a member function of this same name and accepting the given value.
/// @throw InvalidArgument if value not the right direction.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto Rotate(Compositor<P1, P2, P3, P4, P5, P6>& arg, ::playrho::d2::UnitVec value)
    -> std::enable_if_t<!detail::HasMemberRotateV<decltype(arg)>, void>
{
    if (UnitVec::GetRight() != value) {
        throw InvalidArgument("Rotate non-zero amount not supported");
    }
}

/// @brief Gets the vertex radius of the given shape configuration.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   having a member function of this same name and accepting the given index and value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetVertexRadius(Compositor<P1, P2, P3, P4, P5, P6>& arg, ChildCounter index,
                     decltype(arg.GetVertexRadius()) value)
    -> decltype(arg.SetVertexRadius(index, value))
{
    return arg.SetVertexRadius(index, value);
}

/// @brief Density setter.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
/// having a member variable of this same name and accepting the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetDensity(Compositor<P1, P2, P3, P4, P5, P6>& arg, NonNegative<AreaDensity> value)
    -> std::enable_if_t<!std::is_const_v<decltype(arg.density)>, void>
{
    arg.density = value;
}

/// @brief No-op density setter.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   not having a member variable of this same name and accepting the given value.
/// @throw InvalidArgument if value different from existing.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetDensity(Compositor<P1, P2, P3, P4, P5, P6>& arg, NonNegative<AreaDensity> value)
    -> std::enable_if_t<std::is_const_v<decltype(arg.density)>, void>
{
    if (GetDensity(arg) != value) {
        throw InvalidArgument("SetDensity to non-equivalent value not supported");
    }
}

/// @brief Filter setter.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   having a member variable of this same name and accepting the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetFilter(Compositor<P1, P2, P3, P4, P5, P6>& arg, Filter value)
    -> std::enable_if_t<!std::is_const_v<decltype(arg.filter)>, void>
{
    arg.filter = value;
}

/// @brief No-op filter setter.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   having a member variable of this same name and accepting the given value.
/// @throw InvalidArgument if value different from existing.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetFilter(Compositor<P1, P2, P3, P4, P5, P6>& arg, Filter value)
    -> std::enable_if_t<std::is_const_v<decltype(arg.filter)>, void>
{
    if (GetFilter(arg) != value) {
        throw InvalidArgument("SetFilter to non-equivalent filter not supported");
    }
}

/// @brief Sensor setter.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   having a member variable of this same name and accepting the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetSensor(Compositor<P1, P2, P3, P4, P5, P6>& arg, bool value)
    -> std::enable_if_t<!std::is_const_v<decltype(arg.sensor)>, void>
{
    arg.sensor = value;
}

/// @brief No-op sensor setter.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   not having a member variable of this same name and accepting the given value.
/// @throw InvalidArgument if value different from existing.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetSensor(Compositor<P1, P2, P3, P4, P5, P6>& arg, bool value)
    -> std::enable_if_t<std::is_const_v<decltype(arg.sensor)>, void>
{
    if (IsSensor(arg) != value) {
        throw InvalidArgument("SetSensor to non-equivalent value not supported");
    }
}

/// @brief Sets friction.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   having a member variable of this same name and accepting the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetFriction(Compositor<P1, P2, P3, P4, P5, P6>& arg, NonNegative<Real> value)
    -> std::enable_if_t<!std::is_const_v<decltype(arg.friction)>, void>
{
    arg.friction = value;
}

/// @brief No-op friction setting function.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   not having a member variable of this same name and accepting the given value.
/// @throw InvalidArgument if value different from existing.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetFriction(Compositor<P1, P2, P3, P4, P5, P6>& arg, NonNegative<Real> value)
    -> std::enable_if_t<std::is_const_v<decltype(arg.friction)>, void>
{
    if (GetFriction(arg) != value) {
        throw InvalidArgument("SetFriction to non-equivalent value not supported");
    }
}

/// @brief Sets restitution.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   having a member variable of this same name and accepting the given value.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetRestitution(Compositor<P1, P2, P3, P4, P5, P6>& arg, Real value)
    -> std::enable_if_t<!std::is_const_v<decltype(arg.restitution)>, void>
{
    arg.restitution = value;
}

/// @brief No-op restitution setting function.
/// @note By way of SFINAE, this function is only available from overload resolution for objects
///   not having a member variable of this same name and accepting the given value.
/// @throw InvalidArgument if value different from existing.
/// @relatedalso Compositor
template <class P1, class P2, class P3, class P4, class P5, class P6>
auto SetRestitution(Compositor<P1, P2, P3, P4, P5, P6>& arg, Real value)
    -> std::enable_if_t<std::is_const_v<decltype(arg.restitution)>, void>
{
    if (GetRestitution(arg) != value) {
        throw InvalidArgument("SetRestitution to non-equivalent value not supported");
    }
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
    using IndexType = std::remove_cv_t<decltype(lhsCount)>;
    for (auto i = static_cast<IndexType>(0); i < lhsCount; ++i) {
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

} // namespace playrho::d2::part

#endif // PLAYRHO_D2_PART_COMPOSITOR_HPP
