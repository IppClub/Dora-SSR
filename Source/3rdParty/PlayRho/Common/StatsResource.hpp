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

#ifndef PLAYRHO_COMMON_STATS_RESOURCE_HPP
#define PLAYRHO_COMMON_STATS_RESOURCE_HPP

#include "PlayRho/Common/MemoryResource.hpp"

namespace playrho::pmr {

class StatsResource final: public memory_resource
{
public:
    struct Stats {
        std::size_t blocksAllocated{};
        std::size_t bytesAllocated{};
        std::size_t maxBlocksAllocated{};
        std::size_t maxBytesAllocated{};
        std::size_t maxBytes{};
        std::size_t maxAlignment{};
    };

    Stats GetStats() const noexcept
    {
        return m_stats;
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

#endif // PLAYRHO_COMMON_STATS_RESOURCE_HPP
