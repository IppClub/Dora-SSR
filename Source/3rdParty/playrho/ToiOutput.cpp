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

#include "playrho/ToiOutput.hpp"

#include <cassert>

namespace playrho {

const char* GetName(ToiOutput::State state) noexcept
{
    switch (state) {
    case ToiOutput::e_unknown:
        break;
    case ToiOutput::e_touching:
        return "touching";
    case ToiOutput::e_separated:
        return "separated";
    case ToiOutput::e_overlapped:
        return "overlapped";
    case ToiOutput::e_nextAfter:
        return "next-after";
    case ToiOutput::e_maxRootIters:
        return "max-root-iters";
    case ToiOutput::e_maxToiIters:
        return "max-toi-iters";
    case ToiOutput::e_belowMinTarget:
        return "below-min-target";
    case ToiOutput::e_maxDistIters:
        return "max-dist-iters";
    case ToiOutput::e_targetDepthExceedsTotalRadius:
        return "target-depth-exceeds-total-radius";
    case ToiOutput::e_minTargetSquaredOverflow:
        return "min-target-squared-overflow";
    case ToiOutput::e_maxTargetSquaredOverflow:
        return "max-target-squared-overflow";
    case ToiOutput::e_notFinite:
        return "not-finite";
    }
    assert(state == ToiOutput::e_unknown);
    return "unknown";
}

} // namespace playrho
