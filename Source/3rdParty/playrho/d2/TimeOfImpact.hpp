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

#ifndef PLAYRHO_D2_TIMEOFIMPACT_HPP
#define PLAYRHO_D2_TIMEOFIMPACT_HPP

// IWYU pragma: begin_exports

#include "playrho/ToiConf.hpp"
#include "playrho/ToiOutput.hpp"

// IWYU pragma: end_exports

namespace playrho::d2 {

class DistanceProxy;
struct Sweep;

/// @brief Gets the time of impact for two disjoint convex sets using the
///    Separating Axis Theorem.
///
/// @details
/// Computes the upper bound on time before two shapes penetrate too much.
/// Time is represented as a fraction between [0,<code>timeMax</code>].
/// This uses a swept separating axis and may miss some intermediate,
/// non-tunneling collision.
/// If you change the time interval, you should call this function again.
///
/// @see https://en.wikipedia.org/wiki/Hyperplane_separation_theorem
/// @pre The given sweeps are both at the same alpha-0.
/// @warning Behavior is not specified if sweeps are not at the same alpha-0.
/// @note Uses Distance to compute the contact point and normal at the time of impact.
/// @note This only works for two disjoint convex sets.
///
/// @param proxyA Proxy A. The proxy's vertex count must be 1 or more.
/// @param sweepA Sweep A. Sweep of motion for shape represented by proxy A.
/// @param proxyB Proxy B. The proxy's vertex count must be 1 or more.
/// @param sweepB Sweep B. Sweep of motion for shape represented by proxy B.
/// @param conf Configuration details for on calculation. Like the targeted depth of penetration.
///
/// @return Time of impact output data.
///
/// @relatedalso ::playrho::ToiOutput
///
ToiOutput GetToiViaSat(const DistanceProxy& proxyA, const Sweep& sweepA,
                       const DistanceProxy& proxyB, const Sweep& sweepB,
                       const ToiConf& conf = GetDefaultToiConf());

} // namespace playrho::d2

#endif // PLAYRHO_D2_TIMEOFIMPACT_HPP
