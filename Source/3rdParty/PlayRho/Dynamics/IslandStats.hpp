/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_DYNAMICS_ISLANDSTATS_HPP
#define PLAYRHO_DYNAMICS_ISLANDSTATS_HPP

#include "PlayRho/Common/Units.hpp"
#include "PlayRho/Common/Settings.hpp"

namespace playrho {

/// @brief Island solver statistics.
struct IslandStats
{
    Length minSeparation = std::numeric_limits<Length>::infinity(); ///< Minimum separation.
    Momentum maxIncImpulse = 0; ///< Maximum incremental impulse.
    BodyCounter bodiesSlept = 0; ///< Bodies slept.
    ContactCounter contactsUpdated = 0; ///< Contacts updated.
    ContactCounter contactsSkipped = 0; ///< Contacts skipped.
    bool solved = false; ///< Solved. <code>true</code> if position constraints solved, <code>false</code> otherwise.
    TimestepIters positionIterations = 0; ///< Position iterations actually performed.
    TimestepIters velocityIterations = 0; ///< Velocity iterations actually performed.
};

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_ISLANDSTATS_HPP
