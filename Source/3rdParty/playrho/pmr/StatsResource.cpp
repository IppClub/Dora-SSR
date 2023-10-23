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

#include <algorithm> // for std::max
#include <cassert> // for assert

#include "playrho/pmr/StatsResource.hpp"

namespace playrho::pmr {

void *StatsResource::do_allocate(std::size_t bytes, std::size_t alignment)
{
    assert(m_upstream != nullptr);
    // Don't update statistics if allocate throws.
    const auto p = m_upstream->allocate(bytes, alignment);
    auto stats = m_stats;
    ++stats.blocksAllocated;
    stats.bytesAllocated += bytes;
    stats.maxBlocksAllocated = std::max(stats.maxBlocksAllocated, stats.blocksAllocated);
    stats.maxBytesAllocated = std::max(stats.maxBytesAllocated, stats.bytesAllocated);
    stats.maxBytes = std::max(stats.maxBytes, bytes);
    stats.maxAlignment = std::max(stats.maxAlignment, alignment);
    m_stats = stats;
    return p;
}

void StatsResource::do_deallocate(void *p, std::size_t bytes, std::size_t alignment)
{
    assert(m_upstream != nullptr);
    // Don't update statistics if deallocate throws.
    m_upstream->deallocate(p, bytes, alignment);
    auto stats = m_stats;
    --stats.blocksAllocated;
    stats.bytesAllocated -= bytes;
    m_stats = stats;
}

}
