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

#ifndef PLAYRHO_TOIOUTPUT_HPP
#define PLAYRHO_TOIOUTPUT_HPP

/// @file
/// @brief Definitions of @c ToiOutput class and closely related code.

#include <cstdint> // for std::uint8_t
#include <type_traits> // for std::remove_const_t

// IWYU pragma: begin_exports

#include "playrho/Real.hpp"
#include "playrho/Settings.hpp"
#include "playrho/UnitInterval.hpp"
#include "playrho/WiderType.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Output data for time of impact.
struct ToiOutput {
    /// @brief Time of impact statistics.
    struct Statistics {
        /// @brief TOI iterations type.
        using toi_iter_type = std::remove_const_t<decltype(DefaultMaxToiIters)>;

        /// @brief Distance iterations type.
        using dist_iter_type = std::remove_const_t<decltype(DefaultMaxDistanceIters)>;

        /// @brief Root iterations type.
        using root_iter_type = std::remove_const_t<decltype(DefaultMaxToiRootIters)>;

        /// @brief TOI iterations sum type.
        using toi_sum_type = WiderType<toi_iter_type>;

        /// @brief Distance iterations sum type.
        using dist_sum_type = WiderType<dist_iter_type>;

        /// @brief Root iterations sum type.
        using root_sum_type = WiderType<root_iter_type>;

        toi_sum_type sum_finder_iters = 0; ///< Sum total TOI iterations.
        dist_sum_type sum_dist_iters = 0; ///< Sum total distance iterations.
        root_sum_type sum_root_iters = 0; ///< Sum total of root finder iterations.

        toi_iter_type toi_iters = 0; ///< Time of impact iterations.
        dist_iter_type max_dist_iters = 0; ///< Max. distance iterations count.
        root_iter_type max_root_iters = 0; ///< Max. root finder iterations for all TOI iterations.
    };

    /// @brief State.
    enum State : std::uint8_t {
        /// @brief Unknown.
        /// @details Unknown state.
        /// @note This is the default initialized state.
        e_unknown,

        /// @brief Touching.
        /// @details Indicates that the returned time of impact for two convex polygons
        ///   is for a time at which the two polygons are within the minimum and maximum
        ///   target range inclusively.
        /// @note This is a desirable result.
        /// @note Time of impact is the time when the two convex polygons "touch".
        e_touching,

        /// @brief Separated.
        /// @details Indicates that the two convex polygons never actually collide
        ///   during their defined sweeps.
        /// @note This is a desirable result.
        /// @note Time of impact in this case is <code>timeMax</code> (which is typically 1).
        e_separated,

        /// @brief Overlapped.
        /// @details Indicates that the two convex polygons are closer to each other
        ///   at the returned time than the target depth range allows for.
        /// @note Can happen if total radius of the two convex polygons is too small.
        /// @note Can happen if the tolerance is too low.
        /// @note Time of impact is the time when the two convex polygons have already
        ///   collided too much.
        e_overlapped,

        /// @brief Max root iterations.
        /// @details Got to max number of root iterations allowed.
        /// @note Can happen if the configured max number of root iterations is too low.
        /// @note Can happen if the tolerance is too small.
        e_maxRootIters,

        /// @brief Next after.
        /// @note Can happen if the length moved is too much bigger than the tolerance.
        e_nextAfter,

        /// @brief Max TOI iterations.
        e_maxToiIters,

        /// @brief Below minimum target.
        e_belowMinTarget,

        /// @brief Max distance iterations.
        /// @details Indicates that the maximum number of distance iterations was done.
        /// @note Can happen if the configured max number of distance iterations was too low.
        e_maxDistIters,

        e_targetDepthExceedsTotalRadius,
        e_minTargetSquaredOverflow,
        e_maxTargetSquaredOverflow,

        e_notFinite,
    };

    /// @brief Default constructor.
    ToiOutput() = default;

    /// @brief Initializing constructor.
    ToiOutput(UnitIntervalFF<Real> t, Statistics s, State z) noexcept : time{t}, stats{s}, state{z} {}

    UnitIntervalFF<Real> time{}; ///< Time factor in range of [0,1] into the future.
    Statistics stats; ///< Statistics.
    State state = e_unknown; ///< State at time factor.
};

/// @brief Gets a human readable name for the given output state.
const char* GetName(ToiOutput::State state) noexcept;

} // namespace playrho

#endif // PLAYRHO_TOIOUTPUT_HPP
