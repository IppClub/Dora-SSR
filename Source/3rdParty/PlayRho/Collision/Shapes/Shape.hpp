/*
 * Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COLLISION_SHAPES_SHAPE_HPP
#define PLAYRHO_COLLISION_SHAPES_SHAPE_HPP

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/TypeInfo.hpp"

#include "PlayRho/Collision/DistanceProxy.hpp"
#include "PlayRho/Collision/MassData.hpp"
#include "PlayRho/Common/NonNegative.hpp"
#include "PlayRho/Common/InvalidArgument.hpp"
#include "PlayRho/Dynamics/Filter.hpp"

#include <memory>
#include <functional>
#include <utility>
#include <stdexcept>
#include <type_traits> // for std::add_pointer_t, std::add_const_t

// Set this to 1 to use std::unique_ptr or to 0 to use std::shared_ptr.
#define SHAPE_USES_UNIQUE_PTR 1

namespace playrho {
namespace d2 {

class Shape;

// Traits...

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
///   - <code>Real GetFriction(const T&) noexcept;</code>
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
                decltype(std::is_copy_constructible<DecayedTypeIfNotSame<T, Shape>>::value)>>
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

template <class T, class = void>
struct HasRotate : std::false_type {
};

template <class T>
struct HasRotate<T, std::void_t<decltype(Rotate(std::declval<T&>(), std::declval<Angle>()))>>
    : std::true_type {
};

/// @brief Fallback friction setter that throws unless given the same value as current.
template <class T>
std::enable_if_t<IsValidShapeType<T>::value && !HasSetFriction<T>::value, void>
SetFriction(T& o, Real value)
{
    if (GetFriction(o) != value) {
        throw InvalidArgument("SetFriction to non-equivalent value not supported");
    }
}

/// @brief Fallback sensor setter that throws unless given the same value as current.
template <class T>
std::enable_if_t<IsValidShapeType<T>::value && !HasSetSensor<T>::value, void> SetSensor(T& o,
                                                                                        bool value)
{
    if (IsSensor(o) != value) {
        throw InvalidArgument("SetSensor to non-equivalent value not supported");
    }
}

/// @brief Fallback density setter that throws unless given the same value as current.
template <class T>
std::enable_if_t<IsValidShapeType<T>::value && !HasSetDensity<T>::value, void>
SetDensity(T& o, NonNegative<AreaDensity> value)
{
    if (GetDensity(o) != value) {
        throw InvalidArgument("SetDensity to non-equivalent value not supported");
    }
}

/// @brief Fallback restitution setter that throws unless given the same value as current.
template <class T>
std::enable_if_t<IsValidShapeType<T>::value && !HasSetRestitution<T>::value, void>
SetRestitution(T& o, Real value)
{
    if (GetRestitution(o) != value) {
        throw InvalidArgument("SetRestitution to non-equivalent value not supported");
    }
}

/// @brief Fallback filter setter that throws unless given the same value as current.
template <class T>
std::enable_if_t<IsValidShapeType<T>::value && !HasSetFilter<T>::value, void>
SetFilter(T& o, Filter value)
{
    if (GetFilter(o) != value) {
        throw InvalidArgument("SetFilter to non-equivalent filter not supported");
    }
}

/// @brief Fallback translate function that throws unless the given value has no effect.
template <class T>
std::enable_if_t<IsValidShapeType<T>::value && !HasTranslate<T>::value, void>
Translate(T&, Length2 value)
{
    if (Length2{} != value) {
        throw InvalidArgument("Translate non-zero amount not supported");
    }
}

/// @brief Fallback scale function that throws unless the given value has no effect.
template <class T>
std::enable_if_t<IsValidShapeType<T>::value && !HasScale<T>::value, void> Scale(T&, Vec2 value)
{
    if (Vec2{Real(1), Real(1)} != value) {
        throw InvalidArgument("Scale non-identity amount not supported");
    }
}

/// @brief Fallback rotate function that throws unless the given value has no effect.
template <class T>
std::enable_if_t<IsValidShapeType<T>::value && !HasRotate<T>::value, void> Rotate(T&,
                                                                                  UnitVec value)
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
/// @note The shape must remain in scope while the proxy is in use.
/// @throws InvalidArgument if the given index is out of range.
/// @see GetChildCount
DistanceProxy GetChild(const Shape& shape, ChildCounter index);

/// @brief Gets the mass properties of this shape using its dimensions and density.
/// @return Mass data for this shape.
MassData GetMassData(const Shape& shape) noexcept;

/// @brief Gets the coefficient of friction.
/// @return Value of 0 or higher.
/// @see SetFriction(Shape& shape, Real value).
Real GetFriction(const Shape& shape) noexcept;

/// @brief Sets the coefficient of friction.
/// @see GetFriction(const Shape& shape).
void SetFriction(Shape& shape, Real value);

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
///   <code>T</code> satisfies the requirement that <code>IsValidShapeType<T>::value == true</code>.
/// @ingroup PartsGroup
/// @see https://youtu.be/QGcVXgEVMJg
/// @see https://en.wikibooks.org/wiki/More_C%2B%2B_Idioms/Polymorphic_Value_Types
class Shape
{
public:
    /// @brief Default constructor.
    /// @post <code>has_value()</code> returns false.
    Shape() noexcept = default;

#if SHAPE_USES_UNIQUE_PTR
    /// @brief Copy constructor.
    Shape(const Shape& other) : m_self{other.m_self ? other.m_self->Clone_() : nullptr}
    {
        // Intentionally empty.
    }
#else
    /// @brief Copy constructor.
    Shape(const Shape& other) = default;
#endif

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
              typename = std::enable_if_t<std::is_copy_constructible<Tp>::value>>
    explicit Shape(T&& arg) : m_self
    {
#if SHAPE_USES_UNIQUE_PTR
        std::make_unique<Model<Tp>>(std::forward<T>(arg))
#else
        std::make_shared<Model<Tp>>(std::forward<T>(arg))
#endif
    }
    {
        // Intentionally empty.
    }

#if SHAPE_USES_UNIQUE_PTR
    /// @brief Copy assignment.
    Shape& operator=(const Shape& other)
    {
        m_self = other.m_self ? other.m_self->Clone_() : nullptr;
        return *this;
    }
#else
    /// @brief Copy assignment operator.
    Shape& operator=(const Shape& other) = default;
#endif

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
              typename = std::enable_if_t<std::is_copy_constructible<Tp>::value>>
    Shape& operator=(T&& other)
    {
        Shape(std::forward<T>(other)).swap(*this);
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

    friend MassData GetMassData(const Shape& shape) noexcept
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

    friend Real GetFriction(const Shape& shape) noexcept
    {
        return shape.m_self ? shape.m_self->GetFriction_() : Real(0);
    }

    friend void SetFriction(Shape& shape, Real value)
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
        return shape.m_self ? shape.m_self->GetDensity_() : NonNegative<AreaDensity>{0_kgpm2};
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
    /// @note Provides the interface for runtime value polymorphism.
    struct Concept {
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
        virtual MassData GetMassData_() const noexcept = 0;

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
        virtual Real GetFriction_() const noexcept = 0;

        /// @brief Sets the friction.
        virtual void SetFriction_(Real value) = 0;

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

        /// @brief Equality checking method.
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
        Model(T arg) : data{std::move(arg)} {}

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

        MassData GetMassData_() const noexcept override
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

        Real GetFriction_() const noexcept override
        {
            return GetFriction(data);
        }

        void SetFriction_(Real value) override
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

#if SHAPE_USES_UNIQUE_PTR
    std::unique_ptr<const Concept> m_self; ///< Self pointer.
#else
    std::shared_ptr<const Concept> m_self; ///< Self pointer.
#endif
};

// Related free functions...

/// @brief Test a point for containment in the given shape.
/// @param shape Shape to use for test.
/// @param point Point in local coordinates.
/// @return <code>true</code> if the given point is contained by the given shape,
///   <code>false</code> otherwise.
/// @relatedalso Shape
/// @ingroup TestPointGroup
bool TestPoint(const Shape& shape, Length2 point) noexcept;

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
    static_assert(std::is_constructible<T, RawType const&>::value,
                  "T is required to be a const lvalue reference "
                  "or a CopyConstructible type");
    auto tmp = ::playrho::d2::TypeCast<std::add_const_t<RawType>>(&value);
    if (tmp == nullptr)
        throw std::bad_cast();
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

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_SHAPES_SHAPE_HPP
