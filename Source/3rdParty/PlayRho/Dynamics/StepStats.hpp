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

#ifndef PLAYRHO_DYNAMICS_STEPSTATS_HPP
#define PLAYRHO_DYNAMICS_STEPSTATS_HPP

#include "PlayRho/Common/Settings.hpp"

namespace playrho {
    
    /// @brief Pre-phase per-step statistics.
    /// @note This data structure is 24-bytes large (on at least one 64-bit platform).
    struct PreStepStats
    {
        /// @brief Counter type.
        using counter_type = std::uint32_t;

        counter_type proxiesMoved = 0; ///< Proxies moved count.
        counter_type destroyed = 0; ///< Count of contacts destroyed.
        counter_type added = 0; ///< Count of contacts added.
        counter_type ignored = 0; ///< Count of contacts ignored during update processing.
        counter_type updated = 0; ///< Count of contacts updated (during update processing).
        counter_type skipped = 0; ///< Count of contacts Skipped (during update processing).
    };
    
    /// @brief Regular-phase per-step statistics.
    /// @note This data structure is 32-bytes large (on at least one 64-bit platform with
    ///   4-byte Real type).
    struct RegStepStats
    {
        /// @brief Counter type.
        using counter_type = std::uint32_t;

        /// @brief Min separation.
        Length minSeparation = std::numeric_limits<Length>::infinity();

        /// @brief Max incremental impulse.
        Momentum maxIncImpulse = 0;
        
        BodyCounter islandsFound = 0; ///< Islands found count.
        BodyCounter islandsSolved = 0; ///< Islands solved count.
        counter_type contactsAdded = 0; ///< Contacts added count.
        counter_type bodiesSlept = 0; ///< Bodies slept count.
        counter_type proxiesMoved = 0; ///< Proxies moved count.
        counter_type sumPosIters = 0; ///< Sum of the position iterations.
        counter_type sumVelIters = 0; ///< Sum of the velocity iterations.
    };
    
    /// @brief TOI-phase per-step statistics.
    /// @note This data structure is 60-bytes large (on at least one 64-bit platform with
    ///   4-byte Real type).
    struct ToiStepStats
    {
        /// @brief Counter type.
        using counter_type = std::uint32_t;

        /// @brief Min separation.
        Length minSeparation = std::numeric_limits<Length>::infinity();

        /// @brief Max incremental impulse.
        Momentum maxIncImpulse = 0;
        
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
        counter_type maxSimulContacts = 0; ///< Max contacts occurring simultaneously.
        
        /// @brief Distance iteration type.
        using dist_iter_type = std::remove_const<decltype(DefaultMaxDistanceIters)>::type;

        /// @brief TOI iteration type.
        using toi_iter_type = std::remove_const<decltype(DefaultMaxToiIters)>::type;
        
        /// @brief Root iteration type.
        using root_iter_type = std::remove_const<decltype(DefaultMaxToiRootIters)>::type;
        
        dist_iter_type maxDistIters = 0; ///< Max distance iterations.
        toi_iter_type maxToiIters = 0; ///< Max TOI iterations.
        root_iter_type maxRootIters = 0; ///< Max root iterations.
    };
    
    /// @brief Per-step statistics.
    ///
    /// @details These are statistics output from the <code>d2::World::Step</code> method.
    /// @note This data structure is 116-bytes large (on at least one 64-bit platform with
    ///   4-byte Real type).
    /// @note Efficient transfer of this data is predicated on compiler support for
    ///   "named-return-value-optimization" (N.R.V.O.) - a form of "copy elision".
    ///
    /// @sa d2::World::Step.
    /// @sa https://en.wikipedia.org/wiki/Return_value_optimization
    /// @sa http://en.cppreference.com/w/cpp/language/copy_elision
    ///
    struct StepStats
    {
        PreStepStats pre; ///< Pre-phase step statistics.
        RegStepStats reg; ///< Reg-phase step statistics.
        ToiStepStats toi; ///< TOI-phase step statistics.
    };
    
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_STEPSTATS_HPP
