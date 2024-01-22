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

#ifndef PLAYRHO_D2_MASSDATA_HPP
#define PLAYRHO_D2_MASSDATA_HPP

/// @file
/// @brief Declaration of the <code>MassData</code> structure and associated free functions.

#include <cstdlib> // for std::size_t

// IWYU pragma: begin_exports

#include "playrho/NonNegative.hpp"
#include "playrho/Span.hpp"
#include "playrho/Units.hpp"
#include "playrho/Vector.hpp"
#include "playrho/Vector2.hpp"

// IWYU pragma: end_exports

namespace playrho::detail {

/// @brief Mass data.
/// @details This holds the mass data computed for a shape.
template <std::size_t N>
struct MassData
{
    /// @brief Default mass.
    static constexpr auto DefaultMass = NonNegative<Mass>{0_kg};

    /// @brief Default rotational inertia (I).
    static constexpr auto DefaultI = NonNegative<RotInertia>{0 * 1_m2 * 1_kg / SquareRadian};

    /// @brief Position of the shape's centroid relative to the shape's origin.
    Vector<Length, N> center = Vector<Length, N>{};

    /// @brief Mass of the shape in kilograms.
    NonNegative<Mass> mass = DefaultMass;

    /// @brief Rotational inertia, a.k.a. moment of inertia.
    /// @details This is the rotational inertia of the shape about the local origin.
    /// @see https://en.wikipedia.org/wiki/Moment_of_inertia
    NonNegative<RotInertia> I = DefaultI;
};

// Free functions...

/// @brief Equality operator for mass data.
/// @relatedalso MassData
template <std::size_t N>
constexpr bool operator== (MassData<N> lhs, MassData<N> rhs)
{
    return lhs.center == rhs.center && lhs.mass == rhs.mass && lhs.I == rhs.I;
}

/// @brief Inequality operator for mass data.
/// @relatedalso MassData
template <std::size_t N>
constexpr bool operator!= (MassData<N> lhs, MassData<N> rhs)
{
    return !(lhs == rhs);
}

} // namespace playrho::detail

namespace playrho::d2 {

/// @brief Mass data alias for 2-D objects.
using MassData = ::playrho::detail::MassData<2>;

/// @brief Computes the mass data for a circular shape.
/// @param r Radius of the circular shape.
/// @param density Areal density of mass.
/// @param location Location of the center of the shape.
MassData GetMassData(Length r, NonNegative<AreaDensity> density, const Length2& location);

/// @brief Computes the mass data for a linear shape.
/// @param r Radius of the vertices of the linear shape.
/// @param density Areal density of mass.
/// @param v0 Location of vertex zero.
/// @param v1 Location of vertex one.
MassData GetMassData(Length r, NonNegative<AreaDensity> density, // force line-break
                     const Length2& v0, const Length2& v1);

/// @brief Gets the mass data for the given collection of vertices with the given
///    properties.
MassData GetMassData(Length vertexRadius, NonNegative<AreaDensity> density,
                     Span<const Length2> vertices);

} // namespace playrho::d2

#endif // PLAYRHO_D2_MASSDATA_HPP
