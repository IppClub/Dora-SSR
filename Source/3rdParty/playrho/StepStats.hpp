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

#ifndef PLAYRHO_STEPSTATS_HPP
#define PLAYRHO_STEPSTATS_HPP

/// @file
/// @brief Definition of the @c StepStats related classes and code.

#include <cstdint> // for std::uint32_t
#include <limits> // for std::numeric_limits
#include <type_traits> // for std::remove_const_t

// IWYU pragma: begin_exports

#include "playrho/Settings.hpp"
#include "playrho/Units.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Pre-phase per-step statistics.
struct PreStepStats {
    /// @brief Counter type.
    using counter_type = std::uint32_t;

    counter_type proxiesCreated = 0; ///< Proxies created count.
    counter_type proxiesMoved = 0; ///< Proxies moved count.
    counter_type contactsDestroyed = 0; ///< Count of contacts destroyed.
    counter_type contactsAdded = 0; ///< Count of contacts added.
    counter_type contactsUpdated = 0; ///< Count of contacts updated during update processing.
    counter_type contactsSkipped = 0; ///< Count of contacts not-needing update.
};

/// @brief Operator equal support.
constexpr auto operator==(const PreStepStats &lhs, const PreStepStats &rhs) -> bool
{
    return (lhs.proxiesCreated == rhs.proxiesCreated) && //
           (lhs.proxiesMoved == rhs.proxiesMoved) && //
           (lhs.contactsDestroyed == rhs.contactsDestroyed) && //
           (lhs.contactsAdded == rhs.contactsAdded) && //
           (lhs.contactsUpdated == rhs.contactsUpdated) && //
           (lhs.contactsSkipped == rhs.contactsSkipped);
}

/// @brief Operator not-equal support.
constexpr auto operator!=(const PreStepStats &lhs, const PreStepStats &rhs) -> bool
{
    return !(lhs == rhs);
}

/// @brief Regular-phase per-step statistics.
struct RegStepStats {
    /// @brief Counter type.
    using counter_type = std::uint32_t;

    /// @brief Min separation.
    Length minSeparation = std::numeric_limits<Length>::infinity();

    /// @brief Max incremental impulse.
    Momentum maxIncImpulse = 0_Ns;

    BodyCounter islandsFound = 0; ///< Islands found count.
    BodyCounter islandsSolved = 0; ///< Islands solved count.
    BodyCounter bodiesSlept = 0; ///< Bodies slept count.
    BodyCounter maxIslandBodies = 0; ///< Max bodies in all of the islands.
    counter_type contactsAdded = 0; ///< Contacts added count.
    counter_type contactsUpdated = 0; ///< Count of contacts updated.
    counter_type contactsSkipped = 0; ///< Count of contacts not-needing update.
    counter_type proxiesMoved = 0; ///< Proxies moved count.
    counter_type sumPosIters = 0; ///< Sum of the position iterations.
    counter_type sumVelIters = 0; ///< Sum of the velocity iterations.
};

/// @brief Operator equal support.
constexpr auto operator==(const RegStepStats &lhs, const RegStepStats &rhs) -> bool
{
    return (lhs.minSeparation == rhs.minSeparation) && //
           (lhs.maxIncImpulse == rhs.maxIncImpulse) && //
           (lhs.islandsFound == rhs.islandsFound) && //
           (lhs.islandsSolved == rhs.islandsSolved) && //
           (lhs.bodiesSlept == rhs.bodiesSlept) && //
           (lhs.maxIslandBodies == rhs.maxIslandBodies) && //
           (lhs.contactsAdded == rhs.contactsAdded) && //
           (lhs.contactsUpdated == rhs.contactsUpdated) && //
           (lhs.contactsSkipped == rhs.contactsSkipped) && //
           (lhs.proxiesMoved == rhs.proxiesMoved) && //
           (lhs.sumPosIters == rhs.sumPosIters) && //
           (lhs.sumVelIters == rhs.sumVelIters);
}

/// @brief Operator not-equal support.
constexpr auto operator!=(const RegStepStats &lhs, const RegStepStats &rhs) -> bool
{
    return !(lhs == rhs);
}

/// @brief TOI-phase per-step statistics.
struct ToiStepStats {
    /// @brief Counter type.
    using counter_type = std::uint32_t;

    /// @brief Distance iteration type.
    using dist_iter_type = std::remove_const_t<decltype(DefaultMaxDistanceIters)>;

    /// @brief TOI iteration type.
    using toi_iter_type = std::remove_const_t<decltype(DefaultMaxToiIters)>;

    /// @brief Root iteration type.
    using root_iter_type = std::remove_const_t<decltype(DefaultMaxToiRootIters)>;

    /// @brief Min separation.
    Length minSeparation = std::numeric_limits<Length>::infinity();

    /// @brief Max incremental impulse.
    Momentum maxIncImpulse = 0_Ns;

    counter_type islandsFound = 0; ///< Islands found count.
    counter_type islandsSolved = 0; ///< Islands solved count.
    counter_type contactsFound = 0; ///< Contacts found count.
    counter_type contactsAtMaxSubSteps = 0; ///< Contacts at max substeps count.
    counter_type contactsUpdatedToi = 0; ///< Contacts updated TOI count.
    counter_type contactsUpdatedTouching = 0; ///< Contacts updated touching count.
    counter_type contactsSkippedTouching = 0; ///< Contacts skipped touching count.
    counter_type contactsAdded = 0; ///< Contacts added count.
    counter_type proxiesMoved = 0; ///< Proxies moved count.
    counter_type sumPosIters = 0; ///< Sum position iterations count.
    counter_type sumVelIters = 0; ///< Sum velocity iterations count.

    dist_iter_type maxDistIters = 0; ///< Max distance iterations.
    toi_iter_type maxToiIters = 0; ///< Max TOI iterations.
    root_iter_type maxRootIters = 0; ///< Max root iterations.
};

/// @brief Operator equal support.
constexpr auto operator==(const ToiStepStats &lhs, const ToiStepStats &rhs) -> bool
{
    return (lhs.minSeparation == rhs.minSeparation) && //
           (lhs.maxIncImpulse == rhs.maxIncImpulse) && //
           (lhs.islandsFound == rhs.islandsFound) && //
           (lhs.islandsSolved == rhs.islandsSolved) && //
           (lhs.contactsFound == rhs.contactsFound) && //
           (lhs.contactsAtMaxSubSteps == rhs.contactsAtMaxSubSteps) && //
           (lhs.contactsUpdatedToi == rhs.contactsUpdatedToi) && //
           (lhs.contactsUpdatedTouching == rhs.contactsUpdatedTouching) && //
           (lhs.contactsSkippedTouching == rhs.contactsSkippedTouching) && //
           (lhs.contactsAdded == rhs.contactsAdded) && //
           (lhs.proxiesMoved == rhs.proxiesMoved) && //
           (lhs.sumPosIters == rhs.sumPosIters) && //
           (lhs.sumVelIters == rhs.sumVelIters) && //
           (lhs.maxDistIters == rhs.maxDistIters) && //
           (lhs.maxToiIters == rhs.maxToiIters) && //
           (lhs.maxRootIters == rhs.maxRootIters);
}

/// @brief Operator not-equal support.
constexpr auto operator!=(const ToiStepStats &lhs, const ToiStepStats &rhs) -> bool
{
    return !(lhs == rhs);
}

/// @brief Per-step statistics.
/// @details These are statistics output from the <code>d2::World::Step</code> function.
/// @note Efficient transfer of this data is predicated on compiler support for
///   "named-return-value-optimization" (N.R.V.O.) - a form of "copy elision".
/// @see d2::World::Step.
/// @see https://en.wikipedia.org/wiki/Return_value_optimization
/// @see https://en.cppreference.com/w/cpp/language/copy_elision
struct StepStats {
    PreStepStats pre; ///< Pre-phase step statistics.
    RegStepStats reg; ///< Reg-phase step statistics.
    ToiStepStats toi; ///< TOI-phase step statistics.
};

struct IslandStats;

/// @brief Updates regular-phase per-step statistics with island statistics.
/// @relatedalso RegStepStats
RegStepStats& Update(RegStepStats& lhs, const IslandStats& rhs) noexcept;

} // namespace playrho

#endif // PLAYRHO_STEPSTATS_HPP
