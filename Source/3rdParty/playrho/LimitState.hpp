/*
 * Original work Copyright (c) 2006-2011 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_LIMITSTATE_HPP
#define PLAYRHO_LIMITSTATE_HPP

/// @file
/// @brief Definition of the @c LimitState enumeration and closely related code.

namespace playrho {

/// @brief Limit state.
/// @note Only used by joints that implement some notion of a limited range.
enum class LimitState
{
    /// @brief Inactive limit.
    e_inactiveLimit,

    /// @brief At-lower limit.
    e_atLowerLimit,

    /// @brief At-upper limit.
    e_atUpperLimit,

    /// @brief Equal limit.
    /// @details Equal limit is used to indicate that a joint's upper and lower limits
    ///   are approximately the same.
    e_equalLimits
};

/// @brief Provides a human readable C-style string uniquely identifying the given limit state.
const char* ToString(LimitState val) noexcept;

} // namespace playrho

#endif // PLAYRHO_LIMITSTATE_HPP
