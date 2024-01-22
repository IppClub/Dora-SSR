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

#ifndef PLAYRHO_ISLANDSTATS_HPP
#define PLAYRHO_ISLANDSTATS_HPP

/// @file
/// @brief Definition of the @c IslandStats class.

#include <limits> // for std::numeric_limits

// IWYU pragma: begin_exports

#include "playrho/Units.hpp"
#include "playrho/Settings.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Island solver statistics.
struct IslandStats
{
    Length minSeparation = std::numeric_limits<Length>::infinity(); ///< Minimum separation.
    Momentum maxIncImpulse = 0_Ns; ///< Maximum incremental impulse.
    BodyCounter bodiesSlept = 0; ///< Bodies slept.
    ContactCounter contactsUpdated = 0; ///< Contacts updated.
    ContactCounter contactsSkipped = 0; ///< Contacts skipped.
    bool solved = false; ///< Whether position constraints solved.
    TimestepIters positionIters = 0; ///< Position iterations actually performed.
    TimestepIters velocityIters = 0; ///< Velocity iterations actually performed.

    /// @brief Increment contacts updated.
    constexpr IslandStats& IncContactsUpdated(ContactCounter value) noexcept
    {
        contactsUpdated += value;
        return *this;
    }

    /// @brief Increment contacts skipped.
    constexpr IslandStats& IncContactsSkipped(ContactCounter value) noexcept
    {
        contactsSkipped += value;
        return *this;
    }
};

} // namespace playrho

#endif // PLAYRHO_ISLANDSTATS_HPP
