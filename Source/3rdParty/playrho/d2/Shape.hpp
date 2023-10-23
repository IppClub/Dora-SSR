/*
 * Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * Erin Catto's http://www.box2d.org was the origin for this software.
 * TypeCast code originated from the LLVM Project https://llvm.org/LICENSE.txt.
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

#ifndef PLAYRHO_D2_SHAPES_SHAPE_HPP
#define PLAYRHO_D2_SHAPES_SHAPE_HPP

/// @file
/// @brief Definition of the @c Shape class and closely related code.

#include <memory>
#include <functional>
#include <utility>
#include <stdexcept>
#include <type_traits> // for std::add_pointer_t, std::add_const_t

#include "playrho/InvalidArgument.hpp"
#include "playrho/Filter.hpp"
#include "playrho/NonNegative.hpp"
#include "playrho/TypeInfo.hpp"

#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/Math.hpp"

namespace playrho::d2 {

class Shape;

// Traits...

namespace detail {

/// @brief An "is valid shape type" trait.
/// @note This is the general false template type.
template <typename T, class = void>
struct IsValidShapeType : std::false_type {
};

/// @brief An "is valid shape type" trait.
/// @note This is the specialized true template type.
/// @note A shape can be constructed from or have its value set to any value whose type
///   <code>T</code> has at least the following function definitions available for it:
///   - <code>bool operator==(const T& lhs, const T& rhs) noexcept;</code>
///   - <code>ChildCounter GetChildCount(const T&) noexcept;</code>
///   - <code>DistanceProxy GetChild(const T&, ChildCounter index);</code>
///   - <code>MassData GetMassData(const T&) noexcept;</code>
///   - <code>NonNegative<Length> GetVertexRadius(const T&, ChildCounter idx);</code>
///   - <code>NonNegative<AreaDensity> GetDensity(const T&) noexcept;</code>
///   - <code>NonNegative<Real> GetFriction(const T&) noexcept;</code>
///   - <code>Real GetRestitution(const T&) noexcept;</code>
/// @see Shape
template <typename T>
struct IsValidShapeType<
    T,
    std::void_t<decltype(GetChildCount(std::declval<T>())), //
                decltype(GetChild(std::declval<T>(), std::declval<ChildCounter>())), //
                decltype(GetMassData(std::declval<T>())), //
                decltype(GetVertexRadius(std::declval<T>(), std::declval<ChildCounter>())), //
                decltype(GetDensity(std::declval<T>())), //
                decltype(GetFriction(std::declval<T>())), //
                decltype(GetRestitution(std::declval<T>())), //
                decltype(std::declval<T>() == std::declval<T>()), //
                decltype(std::declval<DecayedTypeIfNotSame<T, Shape>>()),
                decltype(std::is_constructible_v<DecayedTypeIfNotSame<T, Shape>, T>)>>
    : std::true_type {
};

template <class T, class = void>
struct HasSetFriction : std::false_type {
};

template <class T>
struct HasSetFriction<T,
                      std::void_t<decltype(SetFriction(std::declval<T&>(), std::declval<Real>()))>>
    : std::true_type {
};

template <class T, class = void>
struct HasSetSensor : std::false_type {
};

template <class T>
struct HasSetSensor<T, std::void_t<decltype(SetSensor(std::declval<T&>(), std::declval<bool>()))>>
    : std::true_type {
};

template <class T, class = void>
struct HasSetDensity : std::false_type {
};

template <class T>
struct HasSetDensity<T, std::void_t<decltype(SetDensity(std::declval<T&>(),
                                                        std::declval<NonNegative<AreaDensity>>()))>>
    : std::true_type {
};

template <class T, class = void>
struct HasSetRestitution : std::false_type {
};

template <class T>
struct HasSetRestitution<
    T, std::void_t<decltype(SetRestitution(std::declval<T&>(), std::declval<Real>()))>>
    : std::true_type {
};

template <class T, class = void>
struct HasSetFilter : std::false_type {
};

template <class T>
struct HasSetFilter<T, std::void_t<decltype(SetFilter(std::declval<T&>(), std::declval<Filter>()))>>
    : std::true_type {
};

template <class T, class = void>
struct HasTranslate : std::false_type {
};

template <class T>
struct HasTranslate<T,
                    std::void_t<decltype(Translate(std::declval<T&>(), std::declval<Length2>()))>>
    : std::true_type {
};

template <class T, class = void>
struct HasScale : std::false_type {
};

template <class T>
struct HasScale<T, std::void_t<decltype(Scale(std::declval<T&>(), std::declval<Vec2>()))>>
    : std::true_type {
};

/// @brief Type trait for not finding a <code>Rotate(T&, Angle)</code> function.
/// @details A @c UnaryTypeTrait providing the member constant @c value equal to @c false for
///   the given type for which no <code>Rotate</code> function is found taking it and an @c Angle.
/// @tparam T type to check.
/// @see https://en.cppreference.com/w/cpp/named_req/UnaryTypeTrait.
template <class T, class = void>
struct HasRotate : std::false_type {
};

/// @brief Type trait for finding a <code>Rotate(T&, Angle)</code> function.
/// @details A @c UnaryTypeTrait providing the member constant @c value equal to @c true for
///   the given type for which a <code>Rotate</code> function is found taking it and an @c Angle.
/// @tparam T type to check.
/// @see https://en.cppreference.com/w/cpp/named_req/UnaryTypeTrait.
template <class T>
struct HasRotate<T, std::void_t<decltype(Rotate(std::declval<T&>(), std::declval<Angle>()))>>
    : std::true_type {
};

}

/// @brief Boolean value for whether the specified type is a valid shape type.
/// @see Shape.
template <class T>
inline constexpr bool IsValidShapeTypeV = detail::IsValidShapeType<T>::value;

/// @brief Helper variable template on whether <code>SetFriction(T&, Real)</code> is found.
template <class T>
inline constexpr bool HasSetFrictionV = detail::HasSetFriction<T>::value;

/// @brief Helper variable template on whether <code>SetSensor(T&, bool)</code> is found.
template <class T>
inline constexpr bool HasSetSensorV = detail::HasSetSensor<T>::value;

/// @brief Helper variable template on whether <code>SetDensity(T&, NonNegative<AreaDensity>)</code> is found.
template <class T>
inline constexpr bool HasSetDensityV = detail::HasSetDensity<T>::value;

/// @brief Helper variable template on whether <code>SetRestitution(T&, Real)</code> is found.
template <class T>
inline constexpr bool HasSetRestitutionV = detail::HasSetRestitution<T>::value;

/// @brief Helper variable template on whether <code>SetFilter(T&, Filter)</code> is found.
template <class T>
inline constexpr bool HasSetFilterV = detail::HasSetFilter<T>::value;

/// @brief Helper variable template on whether <code>Translate(T&, Length2)</code> is found.
template <class T>
inline constexpr bool HasTranslateV = detail::HasTranslate<T>::value;

/// @brief Helper variable template on whether <code>Scale(T&, Vec2)</code> is found.
template <class T>
inline constexpr bool HasScaleV = detail::HasScale<T>::value;

/// @brief Helper variable template on whether <code>Rotate(T&, Angle)</code> is found.
template <class T>
inline constexpr bool HasRotateV = detail::HasRotate<T>::value;

/// @brief Fallback friction setter that throws unless given the same value as current.
template <class T>
std::enable_if_t<IsValidShapeTypeV<T> && !HasSetFrictionV<T>, void>
SetFriction(T& o, NonNegative<Real> value)
{
    if (GetFriction(o) != value) {
        throw InvalidArgument("SetFriction to non-equivalent value not supported");
    }
}

/// @brief Fallback sensor setter that throws unless given the same value as current.
template <class T>
std::enable_if_t<IsValidShapeTypeV<T> && !HasSetSensorV<T>, void>
SetSensor(T& o, bool value)
{
    if (IsSensor(o) != value) {
        throw InvalidArgument("SetSensor to non-equivalent value not supported");
    }
}

/// @brief Fallback density setter that throws unless given the same value as current.
template <class T>
std::enable_if_t<IsValidShapeTypeV<T> && !HasSetDensityV<T>, void>
SetDensity(T& o, NonNegative<AreaDensity> value)
{
    if (GetDensity(o) != value) {
        throw InvalidArgument("SetDensity to non-equivalent value not supported");
    }
}

/// @brief Fallback restitution setter that throws unless given the same value as current.
template <class T>
std::enable_if_t<IsValidShapeTypeV<T> && !HasSetRestitutionV<T>, void>
SetRestitution(T& o, Real value)
{
    if (GetRestitution(o) != value) {
        throw InvalidArgument("SetRestitution to non-equivalent value not supported");
    }
}

/// @brief Fallback filter setter that throws unless given the same value as current.
template <class T>
std::enable_if_t<IsValidShapeTypeV<T> && !HasSetFilterV<T>, void>
SetFilter(T& o, Filter value)
{
    if (GetFilter(o) != value) {
        throw InvalidArgument("SetFilter to non-equivalent filter not supported");
    }
}

/// @brief Fallback translate function that throws unless the given value has no effect.
template <class T>
auto Translate(T&, const Length2& value)
    -> std::enable_if_t<IsValidShapeTypeV<T> && !HasTranslateV<T>, void>
{
    if (Length2{} != value) {
        throw InvalidArgument("Translate non-zero amount not supported");
    }
}

/// @brief Fallback scale function that throws unless the given value has no effect.
template <class T>
auto Scale(T&, const Vec2& value)
    -> std::enable_if_t<IsValidShapeTypeV<T> && !HasScaleV<T>, void>
{
    if (Vec2{Real(1), Real(1)} != value) {
        throw InvalidArgument("Scale non-identity amount not supported");
    }
}

/// @brief Fallback rotate function that throws unless the given value has no effect.
template <class T>
auto Rotate(T&, const UnitVec& value)
    -> std::enable_if_t<IsValidShapeTypeV<T> && !HasRotateV<T>, void>
{
    if (UnitVec::GetRight() != value) {
        throw InvalidArgument("Rotate non-zero amount not supported");
    }
}

// Forward declare functions.
// Note that these may be friend functions but that declaring these within the class that
// they're to be friends of, doesn't also insure that they're found within the namespace
// in terms of lookup.

/// @brief Gets the number of child primitives of the shape.
/// @return Non-negative count.
ChildCounter GetChildCount(const Shape& shape) noexcept;

/// @brief Gets the "child" for the given index.
/// @param shape Shape to get "child" shape of.
/// @param index Index to a child element of the shape. Value must be less
///   than the number of child primitives of the shape.
/// @warning The shape must remain in scope while the proxy is in use!
/// @throws InvalidArgument if the given index is out of range.
/// @see GetChildCount
DistanceProxy GetChild(const Shape& shape, ChildCounter index);

/// @brief Getting the "child" for a temporary is deleted to prevent dangling references.
DistanceProxy GetChild(Shape&& shape, ChildCounter index) = delete;

/// @brief Gets the mass properties of this shape using its dimensions and density.
/// @return Mass data for this shape.
MassData GetMassData(const Shape& shape);

/// @brief Gets the coefficient of friction.
/// @return Value of 0 or higher.
/// @see SetFriction(Shape& shape, NonNegative<Real> value).
NonNegativeFF<Real> GetFriction(const Shape& shape) noexcept;

/// @brief Sets the coefficient of friction.
/// @see GetFriction(const Shape& shape).
void SetFriction(Shape& shape, NonNegative<Real> value);

/// @brief Gets the coefficient of restitution value of the given shape.
/// @see SetRestitution(Shape& shape, Real value).
Real GetRestitution(const Shape& shape) noexcept;

/// @brief Sets the coefficient of restitution value of the given shape.
/// @see GetRestitution(const Shape& shape).
void SetRestitution(Shape& shape, Real value);

/// @brief Gets the density of the given shape.
/// @return Non-negative density (in mass per area).
/// @see SetDensity(Shape& shape, NonNegative<AreaDensity> value).
NonNegative<AreaDensity> GetDensity(const Shape& shape) noexcept;

/// @brief Sets the density of the given shape.
/// @see GetDensity.
void SetDensity(Shape& shape, NonNegative<AreaDensity> value);

/// @brief Gets the vertex radius of the indexed child of the given shape.
/// @details This gets the radius from the vertex that the shape's "skin" should
///   extend outward by. While any edges - line segments between multiple vertices -
///   are straight, corners between them (the vertices) are rounded and treated
///   as rounded. Shapes with larger vertex radiuses compared to edge lengths
///   therefore will be more prone to rolling or having other shapes more prone
///   to roll off of them. Here's an image of a shape configured via a
///   <code>PolygonShapeConf</code> with it's skin drawn:
/// @param shape Shape to get child's vertex radius for.
/// @param idx Child index to get vertex radius for.
/// @image html SkinnedPolygon.png
/// @see UseVertexRadius
/// @throws InvalidArgument if the child index is not less than the child count.
NonNegative<Length> GetVertexRadius(const Shape& shape, ChildCounter idx);

/// @brief Sets the vertex radius of the indexed child of the given shape.
/// @image html SkinnedPolygon.png
/// @throws InvalidArgument if the vertex radius cannot be set to the specified value.
/// @see GetVertexRadius(const Shape& shape, ChildCounter idx).
void SetVertexRadius(Shape& shape, ChildCounter idx, NonNegative<Length> value);

/// @brief Gets the filter value for the given shape.
/// @return Filter for the given shape or the default filter is the shape has no value.
/// @see SetFilter(Shape& shape, Filter value);.
Filter GetFilter(const Shape& shape) noexcept;

/// @brief Sets the filter value for the given shape.
/// @see GetFilter(const Shape& shape).
void SetFilter(Shape& shape, Filter value);

/// @brief Gets whether or not the given shape is a sensor.
/// @see SetSensor(Shape& shape, bool value).
bool IsSensor(const Shape& shape) noexcept;

/// @brief Sets whether or not the given shape is a sensor.
/// @see IsSensor(const Shape& shape).
void SetSensor(Shape& shape, bool value);

/// @brief Translates all of the given shape's vertices by the given amount.
/// @note This may throw <code>std::bad_alloc</code> or any exception that's thrown
///   by the constructor for the model's underlying data type.
/// @throws std::bad_alloc if there's a failure allocating storage.
void Translate(Shape& shape, const Length2& value);

/// @brief Scales all of the given shape's vertices by the given amount.
/// @note This may throw <code>std::bad_alloc</code> or any exception that's thrown
///   by the constructor for the model's underlying data type.
/// @throws std::bad_alloc if there's a failure allocating storage.
void Scale(Shape& shape, const Vec2& value);

/// @brief Rotates all of the given shape's vertices by the given amount.
/// @note This may throw <code>std::bad_alloc</code> or any exception that's thrown
///   by the constructor for the model's underlying data type.
/// @throws std::bad_alloc if there's a failure allocating storage.
void Rotate(Shape& shape, const UnitVec& value);

/// @brief Gets a pointer to the underlying data.
/// @note Provided for introspective purposes like visitation.
const void* GetData(const Shape& shape) noexcept;

/// @brief Gets the type info of the use of the given shape.
/// @note This is not the same as calling <code>GetTypeID<Shape>()</code>.
/// @return Type info of the underlying value's type.
TypeID GetType(const Shape& shape) noexcept;

/// @brief Converts the given shape into its current configuration value.
/// @note The design for this was based off the design of the C++17 <code>std::any</code>
///   class and its associated <code>std::any_cast</code> function. The code for this is based
///   off of the <code>std::any</code> code from the LLVM Project.
/// @see https://llvm.org/
/// @see GetType(const Shape&)
template <typename T>
std::add_pointer_t<std::add_const_t<T>> TypeCast(const Shape* value) noexcept;

/// @brief Equality operator for shape to shape comparisons.
bool operator==(const Shape& lhs, const Shape& rhs) noexcept;

/// @brief Inequality operator for shape to shape comparisons.
bool operator!=(const Shape& lhs, const Shape& rhs) noexcept;

// Now define the shape class...

/// @defgroup PartsGroup Shape Classes
/// @brief Classes for configuring shapes with material properties.
/// @details These are classes that specify physical characteristics of: geometry, mass,
///   friction, density and restitution. They've historically been called shape classes
///   but are now &mdash; with the other properties like friction and density having been
///   moved into them &mdash; maybe better thought of as "parts".

/// @example Shape.cpp
/// This is the <code>googletest</code> based unit testing file for the interfaces to
///   <code>playrho::d2::Shape</code>.

/// @brief Shape.
/// @details A shape is used for collision detection. You can create a shape from any
///   supporting type. Shapes are conceptually made up of zero or more convex child shapes
///   where each child shape is made up of zero or more vertices and an associated radius
///   called its "vertex radius" or "skin".
/// @note This class's design provides a "polymorphic value type" offering polymorphism
///   without public inheritance. This is based on a technique that's described by Sean Parent
///   in his January 2017 Norwegian Developers Conference London talk "Better Code: Runtime
///   Polymorphism". With this implementation, different shapes types can be had by constructing
///   instances of this class with the different types that provide the required support.
///   Different shapes of a given type meanwhile are had by providing different values for the
///   type.
/// @note A shape can be constructed from or have its value set to any value whose type
///   <code>T</code> satisfies the requirement that <code>IsValidShapeTypeV<T> == true</code>.
/// @ingroup PartsGroup
/// @see https://youtu.be/QGcVXgEVMJg
/// @see https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Polymorphic_Value_Types
class Shape
{
public:
    /// @brief Default density of a default-constructed, or otherwise value-less, shape.
    static constexpr auto DefaultDensity = NonNegative<AreaDensity>{0_kgpm2};

    /// @brief Default constructor.
    /// @post <code>has_value()</code> returns false.
    Shape() noexcept = default;

    /// @brief Copy constructor.
    Shape(const Shape& other) : m_self{other.m_self ? other.m_self->Clone_() : nullptr}
    {
        // Intentionally empty.
    }

    /// @brief Move constructor.
    Shape(Shape&& other) noexcept = default;

    /// @brief Initializing constructor for alternative types.
    /// @param arg Value to construct a shape instance for.
    /// @note See the class notes section for an explanation of requirements on a type
    ///   <code>T</code> for its values to be fully valid candidates for this function.
    /// @note The <code>IsValidShapeType</code> trait is intentionally not used to eliminate
    ///   this function from resolution so that the compiler may offer insight into exactly
    ///   which requirements are not met by the given type.
    /// @post <code>has_value()</code> returns true.
    /// @throws std::bad_alloc if there's a failure allocating storage.
    template <typename T, typename Tp = DecayedTypeIfNotSame<T, Shape>,
              typename = std::enable_if_t<std::is_constructible_v<Tp, T>>>
    explicit Shape(T&& arg) : m_self{std::make_unique<Model<Tp>>(std::forward<T>(arg))}
    {
        // Intentionally empty.
    }

    /// @brief Copy assignment.
    Shape& operator=(const Shape& other)
    {
        m_self = other.m_self ? other.m_self->Clone_() : nullptr;
        return *this;
    }

    /// @brief Move assignment operator.
    Shape& operator=(Shape&& other) = default;

    /// @brief Move assignment operator for alternative types.
    /// @note See the class notes section for an explanation of requirements on a type
    ///   <code>T</code> for its values to be fully valid candidates for this function.
    /// @note The <code>IsValidShapeType</code> trait is intentionally not used to eliminate
    ///   this function from resolution so that the compiler may offer insight into exactly
    ///   which requirements are not met by the given type.
    /// @post <code>has_value()</code> returns true.
    template <typename T, typename Tp = DecayedTypeIfNotSame<T, Shape>,
              typename = std::enable_if_t<std::is_constructible_v<Tp, T>>>
    Shape& operator=(T&& arg)
    {
        Shape(std::forward<T>(arg)).swap(*this);
        return *this;
    }

    /// @brief Swap support.
    void swap(Shape& other) noexcept
    {
        std::swap(m_self, other.m_self);
    }

    /// @brief Checks whether this instance contains a value.
    bool has_value() const noexcept
    {
        return static_cast<bool>(m_self);
    }

    friend ChildCounter GetChildCount(const Shape& shape) noexcept
    {
        return shape.m_self ? shape.m_self->GetChildCount_() : static_cast<ChildCounter>(0);
    }

    friend DistanceProxy GetChild(const Shape& shape, ChildCounter index)
    {
        if (!shape.m_self) {
            throw InvalidArgument("index out of range");
        }
        return shape.m_self->GetChild_(index);
    }

    friend MassData GetMassData(const Shape& shape)
    {
        return shape.m_self ? shape.m_self->GetMassData_() : MassData{};
    }

    friend NonNegative<Length> GetVertexRadius(const Shape& shape, ChildCounter idx)
    {
        if (!shape.m_self) {
            throw InvalidArgument("index out of range");
        }
        return shape.m_self->GetVertexRadius_(idx);
    }

    friend void SetVertexRadius(Shape& shape, ChildCounter idx, NonNegative<Length> value)
    {
        if (shape.m_self) {
            auto copy = shape.m_self->Clone_();
            copy->SetVertexRadius_(idx, value);
            shape.m_self = std::move(copy);
        }
    }

    friend NonNegativeFF<Real> GetFriction(const Shape& shape) noexcept
    {
        return shape.m_self ? shape.m_self->GetFriction_() : NonNegativeFF<Real>();
    }

    friend void SetFriction(Shape& shape, NonNegative<Real> value)
    {
        if (shape.m_self) {
            auto copy = shape.m_self->Clone_();
            copy->SetFriction_(value);
            shape.m_self = std::move(copy);
        }
    }

    friend Real GetRestitution(const Shape& shape) noexcept
    {
        return shape.m_self ? shape.m_self->GetRestitution_() : Real(0);
    }

    friend void SetRestitution(Shape& shape, Real value)
    {
        if (shape.m_self) {
            auto copy = shape.m_self->Clone_();
            copy->SetRestitution_(value);
            shape.m_self = std::move(copy);
        }
    }

    friend NonNegative<AreaDensity> GetDensity(const Shape& shape) noexcept
    {
        return shape.m_self ? shape.m_self->GetDensity_() : DefaultDensity;
    }

    friend void SetDensity(Shape& shape, NonNegative<AreaDensity> value)
    {
        if (shape.m_self) {
            auto copy = shape.m_self->Clone_();
            copy->SetDensity_(value);
            shape.m_self = std::move(copy);
        }
    }

    friend Filter GetFilter(const Shape& shape) noexcept
    {
        return shape.m_self ? shape.m_self->GetFilter_() : Filter{};
    }

    friend void SetFilter(Shape& shape, Filter value)
    {
        if (shape.m_self) {
            auto copy = shape.m_self->Clone_();
            copy->SetFilter_(value);
            shape.m_self = std::move(copy);
        }
    }

    friend bool IsSensor(const Shape& shape) noexcept
    {
        return shape.m_self ? shape.m_self->IsSensor_() : false;
    }

    friend void SetSensor(Shape& shape, bool value)
    {
        if (shape.m_self) {
            auto copy = shape.m_self->Clone_();
            copy->SetSensor_(value);
            shape.m_self = std::move(copy);
        }
    }

    friend void Translate(Shape& shape, const Length2& value)
    {
        if (shape.m_self) {
            auto copy = shape.m_self->Clone_();
            copy->Translate_(value);
            shape.m_self = std::move(copy);
        }
    }

    friend void Scale(Shape& shape, const Vec2& value)
    {
        if (shape.m_self) {
            auto copy = shape.m_self->Clone_();
            copy->Scale_(value);
            shape.m_self = std::move(copy);
        }
    }

    friend void Rotate(Shape& shape, const UnitVec& value)
    {
        if (shape.m_self) {
            auto copy = shape.m_self->Clone_();
            copy->Rotate_(value);
            shape.m_self = std::move(copy);
        }
    }

    friend const void* GetData(const Shape& shape) noexcept
    {
        return shape.m_self ? shape.m_self->GetData_() : nullptr;
    }

    friend TypeID GetType(const Shape& shape) noexcept
    {
        return shape.m_self ? shape.m_self->GetType_() : GetTypeID<void>();
    }

    template <typename T>
    friend std::add_pointer_t<std::add_const_t<T>> TypeCast(const Shape* value) noexcept;

    friend bool operator==(const Shape& lhs, const Shape& rhs) noexcept
    {
        return (lhs.m_self == rhs.m_self) ||
               ((lhs.m_self && rhs.m_self) && (*lhs.m_self == *rhs.m_self));
    }

    friend bool operator!=(const Shape& lhs, const Shape& rhs) noexcept
    {
        return !(lhs == rhs);
    }

private:
    /// @brief Internal configuration concept.
    /// @details Provides an internal pure virtual interface for the runtime value polymorphism.
    struct Concept { // NOLINT(cppcoreguidelines-special-member-functions)
        virtual ~Concept() = default;

        /// @brief Clones this concept and returns a pointer to a mutable copy.
        /// @note This may throw <code>std::bad_alloc</code> or any exception that's thrown
        ///   by the constructor for the model's underlying data type.
        /// @throws std::bad_alloc if there's a failure allocating storage.
        virtual std::unique_ptr<Concept> Clone_() const = 0;

        /// @brief Gets the "child" count.
        virtual ChildCounter GetChildCount_() const noexcept = 0;

        /// @brief Gets the "child" specified by the given index.
        virtual DistanceProxy GetChild_(ChildCounter index) const = 0;

        /// @brief Gets the mass data.
        virtual MassData GetMassData_() const = 0;

        /// @brief Gets the vertex radius.
        /// @param idx Child index to get vertex radius for.
        virtual NonNegative<Length> GetVertexRadius_(ChildCounter idx) const = 0;

        /// @brief Sets the vertex radius.
        /// @param idx Child index to set vertex radius for.
        /// @param value Value to set the vertex radius to.
        virtual void SetVertexRadius_(ChildCounter idx, NonNegative<Length> value) = 0;

        /// @brief Gets the density.
        virtual NonNegative<AreaDensity> GetDensity_() const noexcept = 0;

        /// @brief Sets the density.
        virtual void SetDensity_(NonNegative<AreaDensity>) noexcept = 0;

        /// @brief Gets the friction.
        virtual NonNegativeFF<Real> GetFriction_() const noexcept = 0;

        /// @brief Sets the friction.
        virtual void SetFriction_(NonNegative<Real> value) = 0;

        /// @brief Gets the restitution.
        virtual Real GetRestitution_() const noexcept = 0;

        /// @brief Sets the restitution.
        virtual void SetRestitution_(Real value) = 0;

        /// @brief Gets the filter.
        /// @see SetFilter_.
        virtual Filter GetFilter_() const noexcept = 0;

        /// @brief Sets the filter.
        /// @see GetFilter_.
        virtual void SetFilter_(Filter value) = 0;

        /// @brief Gets whether or not this shape is a sensor.
        /// @see SetSensor_.
        virtual bool IsSensor_() const noexcept = 0;

        /// @brief Sets whether or not this shape is a sensor.
        /// @see IsSensor_.
        virtual void SetSensor_(bool value) = 0;

        /// @brief Translates all of the shape's vertices by the given amount.
        virtual void Translate_(const Length2& value) = 0;

        /// @brief Scales all of the shape's vertices by the given amount.
        virtual void Scale_(const Vec2& value) = 0;

        /// @brief Rotates all of the shape's vertices by the given amount.
        virtual void Rotate_(const UnitVec& value) = 0;

        /// @brief Equality checking function.
        virtual bool IsEqual_(const Concept& other) const noexcept = 0;

        /// @brief Gets the use type information.
        /// @return Type info of the underlying value's type.
        virtual TypeID GetType_() const noexcept = 0;

        /// @brief Gets the data for the underlying configuration.
        virtual const void* GetData_() const noexcept = 0;

        /// @brief Equality operator.
        friend bool operator==(const Concept& lhs, const Concept& rhs) noexcept
        {
            return lhs.IsEqual_(rhs);
        }

        /// @brief Inequality operator.
        friend bool operator!=(const Concept& lhs, const Concept& rhs) noexcept
        {
            return !(lhs == rhs);
        }
    };

    /// @brief Internal model configuration concept.
    /// @note Provides an implementation for runtime polymorphism for shape configuration.
    template <typename T>
    struct Model final : Concept {
        /// @brief Type alias for the type of the data held.
        using data_type = T;

        /// @brief Initializing constructor.
        template <typename U, std::enable_if_t<!std::is_same_v<U, Model>, int> = 0>
        explicit Model(U&& arg) noexcept(std::is_nothrow_constructible_v<T, U>)
            : data{std::forward<U>(arg)}
        {
            // Intentionally empty.
        }

        std::unique_ptr<Concept> Clone_() const override
        {
            return std::make_unique<Model>(data);
        }

        ChildCounter GetChildCount_() const noexcept override
        {
            return GetChildCount(data);
        }

        DistanceProxy GetChild_(ChildCounter index) const override
        {
            return GetChild(data, index);
        }

        MassData GetMassData_() const override
        {
            return GetMassData(data);
        }

        NonNegative<Length> GetVertexRadius_(ChildCounter idx) const override
        {
            return GetVertexRadius(data, idx);
        }

        void SetVertexRadius_(ChildCounter idx, NonNegative<Length> value) override
        {
            SetVertexRadius(data, idx, value);
        }

        NonNegative<AreaDensity> GetDensity_() const noexcept override
        {
            return GetDensity(data);
        }

        void SetDensity_(NonNegative<AreaDensity> value) noexcept override
        {
            SetDensity(data, value);
        }

        NonNegativeFF<Real> GetFriction_() const noexcept override
        {
            return GetFriction(data);
        }

        void SetFriction_(NonNegative<Real> value) override
        {
            SetFriction(data, value);
        }

        Real GetRestitution_() const noexcept override
        {
            return GetRestitution(data);
        }

        void SetRestitution_(Real value) override
        {
            SetRestitution(data, value);
        }

        Filter GetFilter_() const noexcept override
        {
            return GetFilter(data);
        }

        void SetFilter_(Filter value) override
        {
            SetFilter(data, value);
        }

        bool IsSensor_() const noexcept override
        {
            return IsSensor(data);
        }

        void SetSensor_(bool value) override
        {
            SetSensor(data, value);
        }

        void Translate_(const Length2& value) override
        {
            Translate(data, value);
        }

        void Scale_(const Vec2& value) override
        {
            Scale(data, value);
        }

        void Rotate_(const UnitVec& value) override
        {
            Rotate(data, value);
        }

        bool IsEqual_(const Concept& other) const noexcept override
        {
            // Would be preferable to do this without using any kind of RTTI system.
            // But how would that be done?
            return (GetType_() == other.GetType_()) &&
                   (data == *static_cast<const T*>(other.GetData_()));
        }

        TypeID GetType_() const noexcept override
        {
            return GetTypeID<data_type>();
        }

        const void* GetData_() const noexcept override
        {
            // Note address of "data" not necessarily same as address of "this" since
            // base class is virtual.
            return &data;
        }

        data_type data; ///< Data.
    };

    std::unique_ptr<const Concept> m_self; ///< Self pointer.
};

// Related free functions...

/// @brief Test a point for containment in the given shape.
/// @param shape Shape to use for test.
/// @param point Point in local coordinates.
/// @return <code>true</code> if the given point is contained by the given shape,
///   <code>false</code> otherwise.
/// @relatedalso Shape
/// @ingroup TestPointGroup
bool TestPoint(const Shape& shape, const Length2& point) noexcept;

/// @brief Gets the vertex count for the specified child of the given shape.
/// @relatedalso Shape
inline VertexCounter GetVertexCount(const Shape& shape, ChildCounter index)
{
    return GetChild(shape, index).GetVertexCount();
}

/// @brief Casts the specified instance into the template specified type.
/// @throws std::bad_cast If the template specified type is not the type of data underlying
///   the given instance.
/// @see GetType(const Shape&)
/// @relatedalso Shape
template <typename T>
inline T TypeCast(const Shape& value)
{
    using RawType = std::remove_cv_t<std::remove_reference_t<T>>;
    static_assert(std::is_constructible_v<T, RawType const&>,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<std::add_const_t<RawType>>(&value);
    if (!tmp) {
        throw std::bad_cast();
    }
    return static_cast<T>(*tmp);
}

template <typename T>
inline std::add_pointer_t<std::add_const_t<T>> TypeCast(const Shape* value) noexcept
{
    static_assert(!std::is_reference<T>::value, "T may not be a reference.");
    using ReturnType = std::add_pointer_t<std::add_const_t<T>>;
    if (value && value->m_self && (GetType(*value) == GetTypeID<T>())) {
        return static_cast<ReturnType>(value->m_self->GetData_());
    }
    return nullptr;
}

/// @brief Whether contact calculations should be performed between the two instances.
/// @return <code>true</code> if contact calculations should be performed between these
///   two instances; <code>false</code> otherwise.
/// @relatedalso Shape
inline bool ShouldCollide(const Shape& a, const Shape& b) noexcept
{
    return ShouldCollide(GetFilter(a), GetFilter(b));
}

} // namespace playrho::d2

#endif // PLAYRHO_D2_SHAPES_SHAPE_HPP
