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

#ifndef PLAYRHO_D2_DETAIL_SHAPEMODEL_HPP
#define PLAYRHO_D2_DETAIL_SHAPEMODEL_HPP

/// @file
/// @brief Definition of the @c ShapeModel class and related code.

#include <type_traits> // for std::enable_if_t, std::is_same_v
#include <utility> // for std::forward

#include "playrho/d2/detail/ShapeConcept.hpp"

namespace playrho::d2::detail {

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

/// @brief Return type for a SetFriction function taking an arbitrary type and a value.
/// @tparam T type to find function return type for.
template <class T>
using SetFrictionReturnType = decltype(SetFriction(std::declval<T&>(), std::declval<Real>()));

/// @brief Return type for a SetSensor function taking an arbitrary type and a value.
/// @tparam T type to find function return type for.
template <class T>
using SetSensorReturnType = decltype(SetSensor(std::declval<T&>(), std::declval<bool>()));

/// @brief Return type for a SetDensity function taking an arbitrary type and a value.
/// @tparam T type to find function return type for.
template <class T>
using SetDensityReturnType =
    decltype(SetDensity(std::declval<T&>(), std::declval<NonNegative<AreaDensity>>()));

/// @brief Return type for a SetRestitution function taking an arbitrary type and a value.
/// @tparam T type to find function return type for.
template <class T>
using SetRestitutionReturnType = decltype(SetRestitution(std::declval<T&>(), std::declval<Real>()));

/// @brief Return type for a SetFilter function taking an arbitrary type and a value.
/// @tparam T type to find function return type for.
template <class T>
using SetFilterReturnType = decltype(SetFilter(std::declval<T&>(), std::declval<Filter>()));

/// @brief Return type for a Translate function taking an arbitrary type and a value.
/// @tparam T type to find function return type for.
template <class T>
using TranslateReturnType = decltype(Translate(std::declval<T&>(), std::declval<Length2>()));

/// @brief Return type for a Scale function taking an arbitrary type and a value.
/// @tparam T type to find function return type for.
template <class T>
using ScaleReturnType = decltype(Scale(std::declval<T&>(), std::declval<Vec2>()));

/// @brief Return type for a Rotate function taking an arbitrary type and a value.
/// @tparam T type to find function return type for.
template <class T>
using RotateReturnType = decltype(Rotate(std::declval<T&>(), std::declval<Angle>()));

/// @brief Boolean value for whether the specified type is a valid shape type.
/// @see Shape.
template <class T>
constexpr bool IsValidShapeTypeV = IsValidShapeType<T>::value;

/// @brief Helper variable template on whether <code>SetFriction(T&, Real)</code> is found.
template <class T>
constexpr bool HasSetFrictionV = playrho::detail::is_detected_v<SetFrictionReturnType, T>;

/// @brief Helper variable template on whether <code>SetSensor(T&, bool)</code> is found.
template <class T>
constexpr bool HasSetSensorV = playrho::detail::is_detected_v<SetSensorReturnType, T>;

/// @brief Helper variable template on whether <code>SetDensity(T&, NonNegative<AreaDensity>)</code> is found.
template <class T>
constexpr bool HasSetDensityV = playrho::detail::is_detected_v<SetDensityReturnType, T>;

/// @brief Helper variable template on whether <code>SetRestitution(T&, Real)</code> is found.
template <class T>
constexpr bool HasSetRestitutionV = playrho::detail::is_detected_v<SetRestitutionReturnType, T>;

/// @brief Helper variable template on whether <code>SetFilter(T&, Filter)</code> is found.
template <class T>
constexpr bool HasSetFilterV = playrho::detail::is_detected_v<SetFilterReturnType, T>;

/// @brief Helper variable template on whether <code>Translate(T&, Length2)</code> is found.
template <class T>
constexpr bool HasTranslateV = playrho::detail::is_detected_v<TranslateReturnType, T>;

/// @brief Helper variable template on whether <code>Scale(T&, Vec2)</code> is found.
template <class T>
constexpr bool HasScaleV = playrho::detail::is_detected_v<ScaleReturnType, T>;

/// @brief Helper variable template on whether <code>Rotate(T&, Angle)</code> is found.
template <class T>
constexpr bool HasRotateV = playrho::detail::is_detected_v<RotateReturnType, T>;

/// @brief Fallback friction setter that throws unless given the same value as current.
template <class T>
auto SetFriction(T& o, NonNegative<Real> value)
    -> std::enable_if_t<IsValidShapeTypeV<T> && !HasSetFrictionV<T>, void>
{
    if (GetFriction(o) != value) {
        throw InvalidArgument("SetFriction to non-equivalent value not supported");
    }
}

/// @brief Fallback sensor setter that throws unless given the same value as current.
template <class T>
auto SetSensor(T& o, bool value)
    -> std::enable_if_t<IsValidShapeTypeV<T> && !HasSetSensorV<T>, void>
{
    if (IsSensor(o) != value) {
        throw InvalidArgument("SetSensor to non-equivalent value not supported");
    }
}

/// @brief Fallback density setter that throws unless given the same value as current.
template <class T>
auto SetDensity(T& o, NonNegative<AreaDensity> value)
    -> std::enable_if_t<IsValidShapeTypeV<T> && !HasSetDensityV<T>, void>
{
    if (GetDensity(o) != value) {
        throw InvalidArgument("SetDensity to non-equivalent value not supported");
    }
}

/// @brief Fallback restitution setter that throws unless given the same value as current.
template <class T>
auto SetRestitution(T& o, Real value)
    -> std::enable_if_t<IsValidShapeTypeV<T> && !HasSetRestitutionV<T>, void>
{
    if (GetRestitution(o) != value) {
        throw InvalidArgument("SetRestitution to non-equivalent value not supported");
    }
}

/// @brief Fallback filter setter that throws unless given the same value as current.
template <class T>
auto SetFilter(T& o, Filter value)
    -> std::enable_if_t<IsValidShapeTypeV<T> && !HasSetFilterV<T>, void>
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

/// @brief Internal model configuration concept.
/// @note Provides an implementation for runtime polymorphism for shape configuration.
template <typename T>
struct ShapeModel final : ShapeConcept {
    /// @brief Type alias for the type of the data held.
    using data_type = T;

    /// @brief Initializing constructor.
    template <typename U, std::enable_if_t<!std::is_same_v<U, ShapeModel>, int> = 0>
    explicit ShapeModel(U&& arg) noexcept(std::is_nothrow_constructible_v<T, U>)
        : data{std::forward<U>(arg)}
    {
        // Intentionally empty.
    }

    std::unique_ptr<ShapeConcept> Clone_() const override
    {
        return std::make_unique<ShapeModel>(data);
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

    bool IsEqual_(const ShapeConcept& other) const noexcept override
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

} // namespace playrho::d2::detail

#endif // PLAYRHO_D2_DETAIL_SHAPEMODEL_HPP
