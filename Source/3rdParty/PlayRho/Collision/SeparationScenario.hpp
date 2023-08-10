/*
 * Original work Copyright (c) 2007-2009 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_COLLISION_SEPARATIONFINDER_HPP
#define PLAYRHO_COLLISION_SEPARATIONFINDER_HPP

#include <variant>

#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Collision/IndexPair.hpp"

namespace playrho {
namespace d2 {

class DistanceProxy;
struct Transformation;

/// Points separation scenario.
struct SeparationScenarioPoints {
    /// Axis. @details Directional vector of the axis of separation.
    UnitVec axis;
};

/// Face A separation scenario.
struct SeparationScenarioFaceA {
    /// Axis. @details Directional vector of the axis of separation.
    UnitVec axis;

    /// @brief Local point.
    Length2 localPoint{};
};

/// Face B separation scenario.
struct SeparationScenarioFaceB {
    /// Axis. @details Directional vector of the axis of separation.
    UnitVec axis;

    /// @brief Local point.
    Length2 localPoint{};
};

/// Separation scenario.
using SeparationScenario = std::variant<
    SeparationScenarioPoints, SeparationScenarioFaceA, SeparationScenarioFaceB
>;

// Free functions...

/// @brief Gets a separation finder for the given inputs.
///
/// @warning Behavior is undefined if given less than one index pair or more than three.
///
/// @param indices Collection of 1 to 3 index pairs. A points-type finder will be
///    returned if given 1 index pair. A face-type finder will be returned otherwise.
/// @param proxyA Proxy A.
/// @param xfA Transformation A.
/// @param proxyB Proxy B.
/// @param xfB Transformation B.
///
SeparationScenario GetSeparationScenario(IndexPair3 indices,
                                         const DistanceProxy& proxyA,
                                         const Transformation& xfA,
                                         const DistanceProxy& proxyB,
                                         const Transformation& xfB);

/// @brief Finds the minimum separation.
/// @return indexes of proxy A's and proxy B's vertices that have the minimum
///    distance between them and what that distance is.
LengthIndexPair FindMinSeparation(const SeparationScenario& scenario,
                                  const DistanceProxy& proxyA,
                                  const Transformation& xfA,
                                  const DistanceProxy& proxyB,
                                  const Transformation& xfB);

/// Evaluates the separation of the identified proxy vertices at the given time factor.
///
/// @param scenario Separation scenario to evaluate.
/// @param indexPair Indexes of the proxy A and proxy B vertexes.
/// @param xfA Transformation A.
/// @param xfB Transformation B.
///
/// @return Separation distance which will be negative when the given transforms put the
///    vertices on the opposite sides of the separating axis.
///
Length Evaluate(const SeparationScenario& scenario,
                const DistanceProxy& proxyA,
                const Transformation& xfA,
                const DistanceProxy& proxyB,
                const Transformation& xfB,
                IndexPair indexPair);

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_COLLISION_SEPARATIONFINDER_HPP
