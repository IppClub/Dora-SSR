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

#ifndef PLAYRHO_D2_POINTSTATES_HPP
#define PLAYRHO_D2_POINTSTATES_HPP

/// @file
/// @brief Structures and functions used for computing before and after like point
///   oriented collision response states.

// IWYU pragma: begin_exports

#include "playrho/Settings.hpp"
#include "playrho/PointState.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

class Manifold;

/// @brief Point states.
/// @details The states pertain to the transition from an old manifold to a new manifold.
///   So state 1 is either persist or remove while state 2 is either add or persist.
/// @see Manifold, GetPointStates.
struct PointStates
{
    /// @brief State 1.
    /// @details States for the first manifold.
    PointState state1[MaxManifoldPoints] = {PointState::Null, PointState::Null};
    
    /// @brief State 2.
    /// @details States after the second manifold.
    PointState state2[MaxManifoldPoints] = {PointState::Null, PointState::Null};
};

/// @brief Computes the _before_ and _after_ like point states given two manifolds.
/// @note This can be useful for analyzing collision responses like in the world's pre-solve
///   contact event listener.
PointStates GetPointStates(const Manifold& manifold1, const Manifold& manifold2) noexcept;

}

#endif // PLAYRHO_D2_POINTSTATES_HPP
