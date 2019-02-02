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

#ifndef PLAYRHO_COLLISION_RAYCASTINPUT_HPP
#define PLAYRHO_COLLISION_RAYCASTINPUT_HPP

/// @file
/// Declaration of the RayCastInput struct.

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/BoundedValue.hpp"

namespace playrho {
namespace detail {

/// @brief Ray-cast input data for N-dimensions.
/// @note The ray extends from <code>p1</code> to <code>p1 + maxFraction * (p2 - p1)</code>.
template <std::size_t N>
struct RayCastInput
{
    Vector<Length, N> p1; ///< Point 1.
    Vector<Length, N> p2; ///< Point 2.
    
    /// @brief Max fraction.
    /// @details Unit interval value - a value between 0 and 1 inclusive.
    UnitInterval<Real> maxFraction = UnitInterval<Real>{0};
};

} // namespace detail

namespace d2 {

/// @brief Ray cast input data for 2-dimensions.
using RayCastInput = playrho::detail::RayCastInput<2>;

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_RAYCASTINPUT_HPP
