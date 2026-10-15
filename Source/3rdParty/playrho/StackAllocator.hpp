/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2023 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_STACKALLOCATOR_HPP
#define PLAYRHO_STACKALLOCATOR_HPP

/// @file
/// @brief Definition of the @c StackAllocator class.

#include <cstdlib> // for std::size_t

namespace playrho {

/// Stack allocator.
/// @details
/// This is a stack allocator used for fast per step allocations.
/// You must nest allocate/free pairs. The code will assert
/// if you try to interleave multiple allocate/free pairs.
/// @note This class satisfies the C++11 <code>std::unique_ptr()</code> Deleter requirement.
class StackAllocator
{
public:
    /// @brief Size type.
    using size_type = std::size_t;

    /// @brief Stack allocator configuration data.
    struct Conf
    {
        /// @brief Default preallocation size.
        static constexpr auto DefaultPreallocationSize = size_type(100 * 1024);

        /// @brief Default allocation records.
        static constexpr auto DefaultAllocationRecords = size_type(32);

        size_type preallocation_size = DefaultPreallocationSize; ///< Preallocation size.
        size_type allocation_records = DefaultAllocationRecords; ///< Allocation records.
    };

    /// @brief Gets the default configuration.
    static constexpr Conf GetDefaultConf()
    {
        return Conf{};
    }

    /// @brief Initializing constructor.
    explicit StackAllocator(const Conf& config = GetDefaultConf());

    ~StackAllocator() noexcept;

    /// @brief Copy constructor.
    StackAllocator(const StackAllocator& copy) = delete;

    StackAllocator(StackAllocator&& other) = delete;

    /// @brief Copy assignment operator.
    StackAllocator& operator= (const StackAllocator& other) = delete;

    StackAllocator& operator= (StackAllocator&& other) = delete;

    /// Allocates an aligned block of memory of the given size.
    /// @return Pointer to memory if the allocator has allocation records left,
    /// <code>nullptr</code> otherwise.
    /// @see GetEntryCount.
    void* Allocate(size_type size);

    /// @brief Frees the given pointer.
    void Free(void* p) noexcept;

    /// @brief Allocates and array of the given size number of elements.
    template <typename T>
    T* AllocateArray(size_type size)
    {
        return static_cast<T*>(Allocate(size * sizeof(T)));
    }

    /// Functional operator for freeing memory allocated by this object.
    /// @details This function frees memory (like called Free) and allows this object
    ///   to be used as deleter to <code>std::unique_ptr</code>.
    void operator()(void *p) noexcept
    {
        Free(p);
    }

    /// @brief Gets the max allocation.
    auto GetMaxAllocation() const noexcept
    {
        return m_maxAllocation;
    }

    /// Gets the current allocation record entry usage count.
    /// @return Value between 0 and the maximum number of entries possible for this allocator.
    /// @see GetMaxEntries.
    auto GetEntryCount() const noexcept
    {
        return m_entryCount;
    }

    /// Gets the current index location.
    /// @details This represents the number of bytes used (of the storage allocated at construction
    ///    time by this object). Storage remaining is calculated by subtracting this value from
    ///    <code>StackSize</code>.
    /// @return Value between 0 and <code>StackSize</code>.
    auto GetIndex() const noexcept
    {
        return m_index;
    }

    /// Gets the total number of bytes that this object has currently allocated.
    auto GetAllocation() const noexcept
    {
        return m_allocation;
    }

    /// @brief Gets the preallocated size.
    auto GetPreallocatedSize() const noexcept
    {
        return m_size;
    }

    /// @brief Gets the max entries.
    auto GetMaxEntries() const noexcept
    {
        return m_max_entries;
    }

private:

    /// @brief Allocation record.
    struct AllocationRecord
    {
        void* data; ///< Data.
        size_type size; ///< Size.
        bool usedMalloc; ///< Whether <code>malloc</code> was used.
    };

    // Set on construction...
    char* m_data{}; ///< Data.
    AllocationRecord* m_entries{}; ///< Entries.
    size_type m_size{}; ///< Size.
    size_type m_max_entries{}; ///< Max entries.

    // Dynamically updated...
    size_type m_index = 0; ///< Index.
    size_type m_allocation = 0; ///< Allocation.
    size_type m_maxAllocation = 0; ///< Max allocation.
    size_type m_entryCount = 0; ///< Entry count.
};
    
} // namespace playrho

#endif // PLAYRHO_STACKALLOCATOR_HPP
