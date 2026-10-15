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

#ifndef PLAYRHO_STATS_RESOURCE_HPP
#define PLAYRHO_STATS_RESOURCE_HPP

#include <cstddef> // for std::size_t

// IWYU pragma: begin_exports

#include "playrho/pmr/MemoryResource.hpp"

// IWYU pragma: end_exports

namespace playrho::pmr {

/// @brief Statistics memory resource.
/// @details Forwards allocation and deallocation calls to the configured upstream
///   memory resource, and collects statistics on successful calls.
class StatsResource final: public memory_resource
{
public:
    /// @brief Statistics collected.
    struct Stats {
        /// @brief Number of blocks currently allocated.
        std::size_t blocksAllocated{};

        /// @brief Number of bytes currently allocated.
        std::size_t bytesAllocated{};

        /// @brief Maximum number of blocks allocated at any time.
        std::size_t maxBlocksAllocated{};

        /// @brief Maximum number of bytes allocated at any time.
        std::size_t maxBytesAllocated{};

        /// @brief Maximum byte size of any allocation.
        std::size_t maxBytes{};

        /// @brief Maximum alignment size of any allocation.
        std::size_t maxAlignment{};
    };

    /// @brief Initializing constructor.
    /// @post <code>upstream_resource()</code> returns the resource given.
    StatsResource(memory_resource* resource = new_delete_resource()) noexcept
        : m_upstream{resource}
    {
        // Intentionally empty.
    }

    /// @brief Gets the currently collected statistics.
    Stats GetStats() const noexcept
    {
        return m_stats;
    }

    /// @brief Returns a pointer to the upstream resource set on construction.
    pmr::memory_resource* upstream_resource() const noexcept
    {
        return m_upstream;
    }

private:
    void *do_allocate(std::size_t bytes, std::size_t alignment) override;

    void do_deallocate(void *p, std::size_t bytes, std::size_t alignment) override;

    bool do_is_equal(const playrho::pmr::memory_resource &other) const noexcept override
    {
        return this == &other;
    }

    memory_resource* m_upstream{new_delete_resource()};
    Stats m_stats;
};

}

#endif // PLAYRHO_STATS_RESOURCE_HPP
