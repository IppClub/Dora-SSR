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

#ifndef PLAYRHO_DYNAMICS_WORLDCONF_HPP
#define PLAYRHO_DYNAMICS_WORLDCONF_HPP

/// @file
/// Declarations of the WorldConf class.

#include "PlayRho/Common/MemoryResource.hpp" // for pmr things
#include "PlayRho/Common/Settings.hpp"

namespace playrho {
namespace d2 {

/// @brief World configuration data.
struct WorldConf {

    static inline const auto DefaultUpstream = pmr::new_delete_resource();

    /// @brief Default min vertex radius.
    static constexpr auto DefaultMinVertexRadius = ::playrho::DefaultMinVertexRadius;

    /// @brief Default max vertex radius.
    static constexpr auto DefaultMaxVertexRadius = ::playrho::DefaultMaxVertexRadius;

    /// @brief Default tree capacity.
    static constexpr auto DefaultTreeCapacity = ContactCounter(4096u);

    /// @brief Default contact capacity.
    static constexpr auto DefaultContactCapacity = ContactCounter(2048u);

    /// @brief Default initial proxy capacity.
    static constexpr auto DefaultProxyCapacity = ContactCounter(1024);

    /// @brief Default initial reserve body stack capacity.
    static constexpr auto DefaultReserveBodyStack = BodyCounter(16384u);

    /// @brief Default initial reserve body constraints capacity.
    static constexpr auto DefaultReserveBodyConstraints = BodyCounter(1024u);

    /// @brief Default initial reserve distance constraints capacity.
    static constexpr auto DefaultReserveDistanceConstraints = DefaultReserveBodyConstraints * 4u;

    /// @brief Default initial reserve contact keys capacity.
    static constexpr auto DefaultReserveContactKeys = ContactCounter(1024u);

    /// @brief Uses the given min vertex radius value.
    constexpr WorldConf& UseUpstream(pmr::memory_resource *value) noexcept;

    /// @brief Uses the given min vertex radius value.
    constexpr WorldConf& UseMinVertexRadius(Positive<Length> value) noexcept;

    /// @brief Uses the given max vertex radius value.
    constexpr WorldConf& UseMaxVertexRadius(Positive<Length> value) noexcept;

    /// @brief Uses the given value as the initial dynamic tree size.
    constexpr WorldConf& UseTreeCapacity(ContactCounter value) noexcept;

    /// @brief Uses the given value as the initial contact capacity.
    constexpr WorldConf& UseContactCapacity(ContactCounter value) noexcept;

    /// @brief Uses the given value as the initial proxy capacity.
    constexpr WorldConf& UseProxyCapacity(ContactCounter value) noexcept;

    /// @brief Upstream memory resource.
    pmr::memory_resource *upstream = DefaultUpstream;

    /// @brief Minimum vertex radius.
    /// @details This is the minimum vertex radius that this world establishes which bodies
    ///    shall allow fixtures to be created with. Trying to create a fixture with a shape
    ///    having a smaller vertex radius shall be rejected with a <code>nullptr</code>
    ///    returned value.
    /// @note This value probably should not be changed except to experiment with what
    ///    can happen.
    /// @note Making it smaller means some shapes could have insufficient buffer for
    ///    continuous collision.
    /// @note Making it larger may create artifacts for vertex collision.
    Positive<Length> minVertexRadius = DefaultMinVertexRadius;

    /// @brief Maximum vertex radius.
    /// @details This is the maximum vertex radius that this world establishes which bodies
    ///    shall allow fixtures to be created with. Trying to create a fixture with a shape
    ///    having a larger vertex radius shall be rejected with a <code>nullptr</code>
    ///    returned value.
    Positive<Length> maxVertexRadius = DefaultMaxVertexRadius;

    /// @brief Initial tree size.
    ContactCounter treeCapacity = DefaultTreeCapacity;

    /// @brief Initial contact capacity.
    ContactCounter contactCapacity = DefaultContactCapacity;

    /// @brief Initial proxy capacity.
    ContactCounter proxyCapacity = DefaultProxyCapacity;

    /// @brief Reserve body stack capacity.
    BodyCounter reserveBodyStack = DefaultReserveBodyStack;

    /// @brief Reserve body constraints capacity.
    BodyCounter reserveBodyConstraints = DefaultReserveBodyConstraints;

    /// @brief Reserve distance constraints capacity.
    BodyCounter reserveDistanceConstraints = DefaultReserveDistanceConstraints;

    /// @brief Reserve contact keys capacity.
    ContactCounter reserveContactKeys = DefaultReserveContactKeys;
};

constexpr WorldConf& WorldConf::UseUpstream(pmr::memory_resource *value) noexcept
{
    upstream = value;
    return *this;
}

constexpr WorldConf& WorldConf::UseMinVertexRadius(Positive<Length> value) noexcept
{
    minVertexRadius = value;
    return *this;
}

constexpr WorldConf& WorldConf::UseMaxVertexRadius(Positive<Length> value) noexcept
{
    maxVertexRadius = value;
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

} // namespace d2
} // namespace playrho

#endif // PLAYRHO_DYNAMICS_WORLDCONF_HPP
