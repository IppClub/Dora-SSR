/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#include "PlayRho/Common/StackAllocator.hpp"
#include "PlayRho/Common/Math.hpp"
#include "PlayRho/Common/DynamicMemory.hpp"

#include <memory>

using namespace playrho;

namespace {

inline std::size_t alignment_size(std::size_t size)
{
    PLAYRHO_CONSTEXPR const auto one = static_cast<std::size_t>(1u);
    return (size < one)? one: (size < sizeof(std::max_align_t))?
        static_cast<std::size_t>(NextPowerOfTwo(size - one)): alignof(std::max_align_t);
};

} // anonymous namespace

StackAllocator::StackAllocator(Conf config) noexcept:
    m_data{static_cast<decltype(m_data)>(Alloc(config.preallocation_size))},
    m_entries{static_cast<AllocationRecord*>(Alloc(config.allocation_records * sizeof(AllocationRecord)))},
    m_size{config.preallocation_size},
    m_max_entries{config.allocation_records}
{
    // Intentionally empty.
}

StackAllocator::~StackAllocator() noexcept
{
    assert(m_index == 0);
    assert(m_entryCount == 0);
    playrho::Free(m_entries);
    playrho::Free(m_data);
}

void* StackAllocator::Allocate(size_type size) noexcept
{
    assert(m_index <= m_size);

    if (m_entryCount < m_max_entries)
    {
        auto entry = m_entries + m_entryCount;
        
        const auto available = m_size - m_index;
        if (size > (available / sizeof(std::max_align_t)) * sizeof(std::max_align_t))
        {
            entry->data = static_cast<decltype(entry->data)>(Alloc(size));
            entry->usedMalloc = true;
        }
        else
        {
            auto ptr = static_cast<void*>(m_data + m_index);
            auto space = available;
            entry->data = std::align(alignment_size(size), size, ptr, space);
            entry->usedMalloc = false;
            size += (available - space);
            m_index += size;
        }

        entry->size = size;
        m_allocation += size;
        m_maxAllocation = std::max(m_maxAllocation, m_allocation);
        ++m_entryCount;

        return entry->data;
    }
    return nullptr;
}

void StackAllocator::Free(void* p) noexcept
{
    if (p)
    {
        assert(m_entryCount > 0);
        const auto entry = m_entries + m_entryCount - 1;
        assert(p == entry->data);
        if (entry->usedMalloc)
        {
            playrho::Free(p);
        }
        else
        {
            assert(m_index >= entry->size);
            m_index -= entry->size;
        }
        assert(m_allocation >= entry->size);
        m_allocation -= entry->size;
        --m_entryCount;
    }
}
