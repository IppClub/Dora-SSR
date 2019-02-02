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

#ifndef PLAYRHO_DYNAMICS_MOVEMENTCONF_HPP
#define PLAYRHO_DYNAMICS_MOVEMENTCONF_HPP

#include "PlayRho/Common/Units.hpp"

namespace playrho {

class StepConf;

/// @brief Movement configuration.
struct MovementConf
{
    Length maxTranslation; ///< Maximum translation.
    Angle maxRotation; ///< Maximum rotation.
};

/// @brief Gets the movement configuration from the given value.
/// @return The <code>maxTranslation</code> and <code>maxRotation</code> fields
///   of the given value respectively are returned.
/// @relatedalso StepConf
MovementConf GetMovementConf(const StepConf& conf) noexcept;

} // namespace playrho

#endif // PLAYRHO_DYNAMICS_MOVEMENTCONF_HPP
