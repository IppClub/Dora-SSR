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

#ifndef PLAYRHO_D2_DETAIL_SHAPECONCEPT_HPP
#define PLAYRHO_D2_DETAIL_SHAPECONCEPT_HPP

/// @file
/// @brief Definition of the internal @c ShapeConcept interface class.

#include <memory> // for std::unique_ptr

#include "playrho/Filter.hpp"
#include "playrho/NonNegative.hpp"
#include "playrho/Settings.hpp" // for ChildCounter
#include "playrho/TypeInfo.hpp" // for TypeID
#include "playrho/Units.hpp" // for Length, AreaDensity

#include "playrho/d2/DistanceProxy.hpp"
#include "playrho/d2/MassData.hpp"
#include "playrho/d2/Math.hpp"

namespace playrho::d2::detail {

/// @brief Internal shape concept interface.
/// @details Provides an internal pure virtual interface for runtime value polymorphism.
struct ShapeConcept { // NOLINT(cppcoreguidelines-special-member-functions)
    virtual ~ShapeConcept() = default;

    /// @brief Clones this concept and returns a pointer to a mutable copy.
    /// @note This may throw <code>std::bad_alloc</code> or any exception that's thrown
    ///   by the constructor for the model's underlying data type.
    /// @throws std::bad_alloc if there's a failure allocating storage.
    virtual std::unique_ptr<ShapeConcept> Clone_() const = 0;

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
    virtual bool IsEqual_(const ShapeConcept& other) const noexcept = 0;

    /// @brief Gets the use type information.
    /// @return Type info of the underlying value's type.
    virtual TypeID GetType_() const noexcept = 0;

    /// @brief Gets the data for the underlying configuration.
    virtual const void* GetData_() const noexcept = 0;
};

} // namespace playrho::d2::detail

#endif // PLAYRHO_D2_DETAIL_SHAPECONCEPT_HPP
