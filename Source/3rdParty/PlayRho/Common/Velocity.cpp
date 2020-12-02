/*
 * Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#include "PlayRho/Common/Velocity.hpp"
#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Dynamics/Contacts/VelocityConstraint.hpp"

namespace playrho {
namespace d2 {

Velocity Cap(Velocity velocity, Time h, const MovementConf& conf) noexcept
{
    const auto translation = h * velocity.linear;
    const auto lsquared = GetMagnitudeSquared(translation);
    if (lsquared > Square(conf.maxTranslation)) {
        // Scale back linear velocity so max translation not exceeded.
        const auto ratio = conf.maxTranslation / sqrt(lsquared);
        velocity.linear *= ratio;
    }

    const auto absRotation = abs(h * velocity.angular);
    if (absRotation > conf.maxRotation) {
        // Scale back angular velocity so max rotation not exceeded.
        const auto ratio = conf.maxRotation / absRotation;
        velocity.angular *= ratio;
    }

    return velocity;
}

} // namespace d2
} // namespace playrho
