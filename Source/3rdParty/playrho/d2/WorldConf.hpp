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

#ifndef PLAYRHO_D2_WORLDCONF_HPP
#define PLAYRHO_D2_WORLDCONF_HPP

/// @file
/// @brief Declarations of the @c WorldConf class.

#include <cstdint> // for std::uint8_t

// IWYU pragma: begin_exports

#include "playrho/Interval.hpp"
#include "playrho/Positive.hpp"
#include "playrho/Settings.hpp"
#include "playrho/Units.hpp"

#include "playrho/pmr/MemoryResource.hpp" // for pmr things

// IWYU pragma: end_exports

namespace playrho::d2 {

/// @brief World configuration data.
struct WorldConf {

    /// @brief Default upstream memory resource.
    /// @warning The pointed to object must stay valid for the life of the configured world.
    static inline const auto DefaultUpstream = pmr::new_delete_resource();

    /// @brief Default vertex radius range.
    static constexpr auto DefaultVertexRadius = Interval<Positive<Length>>{ // force line-break
        Positive<Length>{::playrho::DefaultMinVertexRadius}, // force line-break
        Positive<Length>{::playrho::DefaultMaxVertexRadius} // force line-break
    };

    /// @brief Default tree capacity.
    static constexpr auto DefaultTreeCapacity = ContactCounter(4096u);

    /// @brief Default contact capacity.
    static constexpr auto DefaultContactCapacity = ContactCounter(2048u);

    /// @brief Default initial proxy capacity.
    static constexpr auto DefaultProxyCapacity = ContactCounter(1024);

    /// @brief Default initial reserve buffers capacity.
    static constexpr auto DefaultReserveBuffers = std::uint8_t(1u);

    /// @brief Default initial reserve body stack capacity.
    static constexpr auto DefaultReserveBodyStack = BodyCounter(16384u);

    /// @brief Default initial reserve body constraints capacity.
    static constexpr auto DefaultReserveBodyConstraints = BodyCounter(1024u);

    /// @brief Default initial reserve distance constraints capacity.
    static constexpr auto DefaultReserveDistanceConstraints = ContactCounter{DefaultReserveBodyConstraints * 4u};

    /// @brief Default initial reserve contact keys capacity.
    static constexpr auto DefaultReserveContactKeys = ContactCounter(1024u);

    /// @brief Default do-stats value.
    static constexpr auto DefaultDoStats = false;

    /// @brief Uses the given min vertex radius value.
    constexpr WorldConf& UseUpstream(pmr::memory_resource *value) noexcept;

    /// @brief Uses the given vertex radius range value.
    constexpr WorldConf& UseVertexRadius(const Interval<Positive<Length>>& value) noexcept;

    /// @brief Uses the given value as the initial dynamic tree size.
    constexpr WorldConf& UseTreeCapacity(ContactCounter value) noexcept;

    /// @brief Uses the given value as the initial contact capacity.
    constexpr WorldConf& UseContactCapacity(ContactCounter value) noexcept;

    /// @brief Uses the given value as the initial proxy capacity.
    constexpr WorldConf& UseProxyCapacity(ContactCounter value) noexcept;

    /// @brief Upstream memory resource.
    pmr::memory_resource *upstream = DefaultUpstream;

    /// @brief Allowable vertex radius range.
    /// @details The allowable vertex radius range that this world establishes which
    ///   shapes may be created with. Trying to create a shape having a vertex radius
    ///   outside this range will be rejected.
    /// @note This value probably should not be changed except to experiment with what
    ///    can happen.
    /// @note Making the minimum too small means some shapes could have insufficient
    ///    buffer for continuous collision.
    /// @note Making the minimum too large may create artifacts for vertex collision.
    /// @note Making the maximum too small or too large may cause numerical issues
    ///    dealing with tolerance and target depth.
    Interval<Positive<Length>> vertexRadius = DefaultVertexRadius;

    /// @brief Initial tree size.
    ContactCounter treeCapacity = DefaultTreeCapacity;

    /// @brief Initial contact capacity.
    ContactCounter contactCapacity = DefaultContactCapacity;

    /// @brief Initial proxy capacity.
    ContactCounter proxyCapacity = DefaultProxyCapacity;

    /// @brief Initial reserve contact keys capacity in #-of-elements.
    /// @note This is used as the reserve buffer #-of-elements for finding contacts. The number of
    ///   contact keys has an **upper bound** of the square of the number of bodies in the world.
    ContactCounter reserveContactKeys = DefaultReserveContactKeys;

    /// @brief Initial reserve distance constraints capacity in #-of-elements.
    /// @note This is used for reserving #-of-elements capacity for position and velocity
    ///   constraints. It's tied to the number of contacts in the world.
    ContactCounter reserveDistanceConstraints = DefaultReserveDistanceConstraints;

    /// @brief Initial reserve body stack capacity in #-of-elements.
    /// @note Max body stack #-of-elements capacity has **upper bound** of # of bodies in world.
    BodyCounter reserveBodyStack = DefaultReserveBodyStack;

    /// @brief Initial reserve body constraints capacity in #-of-elements.
    /// @note This is tied to the number of bodies in the world.
    BodyCounter reserveBodyConstraints = DefaultReserveBodyConstraints;

    /// @brief Initial reserve buffers capacity in #-of-elements.
    std::uint8_t reserveBuffers = DefaultReserveBuffers;

    /// @brief Whether to collect resource statistics or not.
    /// @note The collected statistics can help tweak the @c reserve* data members to help avoid
    ///    dynamic memory allocation during world step processing. Collecting these statistics
    ///    incurs some performance overhead however, so consider disabling this setting after
    ///    getting those data members tweaked to your needs.
    /// @see GetResourceStats(const World&).
    bool doStats = DefaultDoStats;
};

constexpr WorldConf& WorldConf::UseUpstream(pmr::memory_resource *value) noexcept
{
    upstream = value;
    return *this;
}

constexpr WorldConf& WorldConf::UseVertexRadius(const Interval<Positive<Length>>& value) noexcept
{
    vertexRadius = value;
    return *this;
}

constexpr WorldConf& WorldConf::UseTreeCapacity(ContactCounter value) noexcept
{
    treeCapacity = value;
    return *this;
}

constexpr WorldConf& WorldConf::UseContactCapacity(ContactCounter value) noexcept
{
    contactCapacity = value;
    return *this;
}

constexpr WorldConf& WorldConf::UseProxyCapacity(ContactCounter value) noexcept
{
    proxyCapacity = value;
    return *this;
}

} // namespace playrho::d2

#endif // PLAYRHO_D2_WORLDCONF_HPP
