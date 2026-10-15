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

#ifndef PLAYRHO_D2_DISTANCE_CONF_HPP
#define PLAYRHO_D2_DISTANCE_CONF_HPP

/// @file
/// @brief Definition of the @c DistanceConf class and closely related code.

#include <type_traits> // for std::remove_const_t

// IWYU pragma: begin_exports

#include "playrho/Settings.hpp"

#include "playrho/d2/Simplex.hpp"

// IWYU pragma: end_exports

namespace playrho {

struct ToiConf;
struct StepConf;

namespace d2 {

/// @brief Distance Configuration.
/// @details Configuration information for calling GJK distance functions.
struct DistanceConf {
    /// @brief Iteration type.
    using iteration_type = std::remove_const_t<decltype(DefaultMaxDistanceIters)>;

    Simplex::Cache cache; ///< Cache.
    iteration_type maxIterations = DefaultMaxDistanceIters; ///< Max iterations.
};

/// @brief Gets the distance configuration for the given time of impact configuration.
/// @relatedalso DistanceConf
DistanceConf GetDistanceConf(const ToiConf& conf) noexcept;

/// @brief Gets the distance configuration for the given step configuration.
/// @relatedalso DistanceConf
DistanceConf GetDistanceConf(const StepConf& conf) noexcept;

} // namespace d2

} // namespace playrho

#endif // PLAYRHO_D2_DISTANCE_CONF_HPP
