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
#include <utility>
#include <typeinfo> // for std::bad_cast
#include <type_traits> // for std::add_pointer_t, std::add_const_t

// IWYU pragma: begin_exports

#include "playrho/InvalidArgument.hpp"
#include "playrho/Filter.hpp"
#include "playrho/NonNegative.hpp"
#include "playrho/Settings.hpp" // for ChildCounter
#include "playrho/Templates.hpp" // for DecayedTypeIfNotSame
#include "playrho/TypeInfo.hpp"

#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/Math.hpp"

#include "playrho/d2/detail/ShapeConcept.hpp"
#include "playrho/d2/detail/ShapeModel.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

class Shape;

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
    Shape(const Shape& other) : m_impl{other.m_impl ? other.m_impl->Clone_() : nullptr}
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
    explicit Shape(T&& arg) : m_impl{std::make_unique<detail::ShapeModel<Tp>>(std::forward<T>(arg))}
    {
        // Intentionally empty.
    }

    /// @brief Copy assignment.
    Shape& operator=(const Shape& other)
    {
        m_impl = other.m_impl ? other.m_impl->Clone_() : nullptr;
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
        std::swap(m_impl, other.m_impl);
    }

    /// @brief Checks whether this instance contains a value.
    bool has_value() const noexcept
    {
        return static_cast<bool>(m_impl);
    }

    friend ChildCounter GetChildCount(const Shape& shape) noexcept
    {
        return shape.m_impl ? shape.m_impl->GetChildCount_() : static_cast<ChildCounter>(0);
    }

    friend DistanceProxy GetChild(const Shape& shape, ChildCounter index)
    {
        if (!shape.m_impl) {
            throw InvalidArgument("index out of range");
        }
        return shape.m_impl->GetChild_(index);
    }

    friend MassData GetMassData(const Shape& shape)
    {
        return shape.m_impl ? shape.m_impl->GetMassData_() : MassData{};
    }

    friend NonNegative<Length> GetVertexRadius(const Shape& shape, ChildCounter idx)
    {
        if (!shape.m_impl) {
            throw InvalidArgument("index out of range");
        }
        return shape.m_impl->GetVertexRadius_(idx);
    }

    friend void SetVertexRadius(Shape& shape, ChildCounter idx, NonNegative<Length> value)
    {
        if (shape.m_impl) {
            auto copy = shape.m_impl->Clone_();
            copy->SetVertexRadius_(idx, value);
            shape.m_impl = std::move(copy);
        }
    }

    friend NonNegativeFF<Real> GetFriction(const Shape& shape) noexcept
    {
        return shape.m_impl ? shape.m_impl->GetFriction_() : NonNegativeFF<Real>();
    }

    friend void SetFriction(Shape& shape, NonNegative<Real> value)
    {
        if (shape.m_impl) {
            auto copy = shape.m_impl->Clone_();
            copy->SetFriction_(value);
            shape.m_impl = std::move(copy);
        }
    }

    friend Real GetRestitution(const Shape& shape) noexcept
    {
        return shape.m_impl ? shape.m_impl->GetRestitution_() : Real(0);
    }

    friend void SetRestitution(Shape& shape, Real value)
    {
        if (shape.m_impl) {
            auto copy = shape.m_impl->Clone_();
            copy->SetRestitution_(value);
            shape.m_impl = std::move(copy);
        }
    }

    friend NonNegative<AreaDensity> GetDensity(const Shape& shape) noexcept
    {
        return shape.m_impl ? shape.m_impl->GetDensity_() : DefaultDensity;
    }

    friend void SetDensity(Shape& shape, NonNegative<AreaDensity> value)
    {
        if (shape.m_impl) {
            auto copy = shape.m_impl->Clone_();
            copy->SetDensity_(value);
            shape.m_impl = std::move(copy);
        }
    }

    friend Filter GetFilter(const Shape& shape) noexcept
    {
        return shape.m_impl ? shape.m_impl->GetFilter_() : Filter{};
    }

    friend void SetFilter(Shape& shape, Filter value)
    {
        if (shape.m_impl) {
            auto copy = shape.m_impl->Clone_();
            copy->SetFilter_(value);
            shape.m_impl = std::move(copy);
        }
    }

    friend bool IsSensor(const Shape& shape) noexcept
    {
        return shape.m_impl ? shape.m_impl->IsSensor_() : false;
    }

    friend void SetSensor(Shape& shape, bool value)
    {
        if (shape.m_impl) {
            auto copy = shape.m_impl->Clone_();
            copy->SetSensor_(value);
            shape.m_impl = std::move(copy);
        }
    }

    friend void Translate(Shape& shape, const Length2& value)
    {
        if (shape.m_impl) {
            auto copy = shape.m_impl->Clone_();
            copy->Translate_(value);
            shape.m_impl = std::move(copy);
        }
    }

    friend void Scale(Shape& shape, const Vec2& value)
    {
        if (shape.m_impl) {
            auto copy = shape.m_impl->Clone_();
            copy->Scale_(value);
            shape.m_impl = std::move(copy);
        }
    }

    friend void Rotate(Shape& shape, const UnitVec& value)
    {
        if (shape.m_impl) {
            auto copy = shape.m_impl->Clone_();
            copy->Rotate_(value);
            shape.m_impl = std::move(copy);
        }
    }

    friend const void* GetData(const Shape& shape) noexcept
    {
        return shape.m_impl ? shape.m_impl->GetData_() : nullptr;
    }

    friend TypeID GetType(const Shape& shape) noexcept
    {
        return shape.m_impl ? shape.m_impl->GetType_() : GetTypeID<void>();
    }

    template <typename T>
    friend std::add_pointer_t<std::add_const_t<T>> TypeCast(const Shape* value) noexcept;

    friend bool operator==(const Shape& lhs, const Shape& rhs) noexcept
    {
        return (lhs.m_impl == rhs.m_impl) ||
               ((lhs.m_impl && rhs.m_impl) && (lhs.m_impl->IsEqual_(*rhs.m_impl)));
    }

    friend bool operator!=(const Shape& lhs, const Shape& rhs) noexcept
    {
        return !(lhs == rhs);
    }

private:
    std::unique_ptr<const detail::ShapeConcept> m_impl; ///< Pointer to implementation.
};

// Related non-member functions...

template <typename T>
std::add_pointer_t<std::add_const_t<T>> TypeCast(const Shape* value) noexcept
{
    static_assert(!std::is_reference<T>::value, "T may not be a reference.");
    using ReturnType = std::add_pointer_t<std::add_const_t<T>>;
    if (value && value->m_impl && (GetType(*value) == GetTypeID<T>())) {
        return static_cast<ReturnType>(value->m_impl->GetData_());
    }
    return nullptr;
}

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

/// @brief Gets whether the given entity is in the is-destroyed state.
/// @relatedalso Shape
inline auto IsDestroyed(const Shape &value) noexcept -> bool
{
    return !value.has_value();
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
