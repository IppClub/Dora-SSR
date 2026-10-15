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

#include "playrho/Real.hpp"
#include "playrho/ZeroToUnderOne.hpp"

#include "playrho/d2/Math.hpp" // for GetPosition
#include "playrho/d2/Sweep.hpp"

namespace playrho::d2 {

Sweep Advance0(const Sweep& sweep, const ZeroToUnderOneFF<Real> alpha) noexcept
{
    const auto beta = (alpha - sweep.alpha0) / (Real(1) - sweep.alpha0);
    return {GetPosition(sweep.pos0, sweep.pos1, beta), sweep.pos1, sweep.localCenter, alpha};
}

} // namespace playrho::d2
