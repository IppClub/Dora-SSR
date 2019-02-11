/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COLLISION_SHAPES_SHAPECONF_HPP
#define PLAYRHO_COLLISION_SHAPES_SHAPECONF_HPP

#include "PlayRho/Common/Units.hpp"
#include "PlayRho/Common/BoundedValue.hpp"
#include "PlayRho/Common/Settings.hpp"

namespace playrho {
namespace d2 {

/// @brief Base configuration for initializing shapes.
/// @note This is a nested base value class for initializing shapes.
struct BaseShapeConf
{
    /// @brief Friction coefficient.
    ///
    /// @note This must be a value between 0 and +infinity. It is safer however to
    ///   keep the value below the square root of the max value of a Real.
    /// @note This is usually in the range [0,1].
    /// @note The square-root of the product of this value multiplied by a touching
    ///   fixture's friction becomes the friction coefficient for the contact.
    ///
    NonNegative<Real> friction = NonNegative<Real>{Real{2} / Real{10}};
    
    /// @brief Restitution (elasticity) of the associated shape.
    ///
    /// @note This should be a valid finite value.
    /// @note This is usually in the range [0,1].
    ///
    Finite<Real> restitution = Finite<Real>{0};
    
    /// @brief Area density of the associated shape.
    ///
    /// @note This must be a non-negative value.
    /// @note Use 0 to indicate that the shape's associated mass should be 0.
    ///
    NonNegative<AreaDensity> density = NonNegative<AreaDensity>{0_kgpm2};
};

/// @brief Builder configuration structure.
/// @details This is a builder structure of chainable methods for building a shape
///   configuration.
/// @note This is a templated nested value class for initializing shapes that
///   uses the Curiously Recurring Template Pattern (CRTP) to provide method chaining
///   via static polymorphism.
/// @sa https://en.wikipedia.org/wiki/Curiously_recurring_template_pattern
template <typename ConcreteConf>
struct ShapeBuilder: BaseShapeConf
{
    // Note: don't use 'using ShapeConf::ShapeConf' here as it doesn't work in this context!
    
    /// @brief Default constructor.
    PLAYRHO_CONSTEXPR inline ShapeBuilder() = default;

    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline explicit ShapeBuilder(const BaseShapeConf& value) noexcept:
        BaseShapeConf{value}
    {
        // Intentionally empty.
    }
    
    /// @brief Uses the given friction.
    PLAYRHO_CONSTEXPR inline ConcreteConf& UseFriction(NonNegative<Real> value) noexcept;
    
    /// @brief Uses the given restitution.
    PLAYRHO_CONSTEXPR inline ConcreteConf& UseRestitution(Finite<Real> value) noexcept;
    
    /// @brief Uses the given density.
    PLAYRHO_CONSTEXPR inline ConcreteConf& UseDensity(NonNegative<AreaDensity> value) noexcept;
};

template <typename ConcreteConf>
PLAYRHO_CONSTEXPR inline ConcreteConf&
ShapeBuilder<ConcreteConf>::UseFriction(NonNegative<Real> value) noexcept
{
    friction = value;
    return static_cast<ConcreteConf&>(*this);
}

template <typename ConcreteConf>
PLAYRHO_CONSTEXPR inline ConcreteConf&
ShapeBuilder<ConcreteConf>::UseRestitution(Finite<Real> value) noexcept
{
    restitution = value;
    return static_cast<ConcreteConf&>(*this);
}

template <typename ConcreteConf>
PLAYRHO_CONSTEXPR inline ConcreteConf&
ShapeBuilder<ConcreteConf>::UseDensity(NonNegative<AreaDensity> value) noexcept
{
    density = value;
    return static_cast<ConcreteConf&>(*this);
}

/// @brief Shape configuration structure.
struct ShapeConf: public ShapeBuilder<ShapeConf>
{
    using ShapeBuilder::ShapeBuilder;
};

// Free functions...

/// @brief Gets the density of the given shape configuration.
PLAYRHO_CONSTEXPR inline NonNegative<AreaDensity> GetDensity(const BaseShapeConf& arg) noexcept
{
    return arg.density;
}

/// @brief Gets the restitution of the given shape configuration.
PLAYRHO_CONSTEXPR inline Finite<Real> GetRestitution(const BaseShapeConf& arg) noexcept
{
    return arg.restitution;
}

/// @brief Gets the friction of the given shape configuration.
PLAYRHO_CONSTEXPR inline NonNegative<Real> GetFriction(const BaseShapeConf& arg) noexcept
{
    return arg.friction;
}

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_SHAPES_SHAPECONF_HPP
