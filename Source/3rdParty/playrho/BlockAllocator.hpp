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

#ifndef PLAYRHO_BLOCKALLOCATOR_HPP
#define PLAYRHO_BLOCKALLOCATOR_HPP

/// @file
/// @brief Definition of the <code>BlockAllocator</code> class and closely related code.

#include <cstdlib> // for std::size_t
#include <iterator> // for std::size

namespace playrho {

    /// Block allocator.
    ///
    /// This is a small object allocator used for allocating small
    ///   objects that persist for more than one time step.
    /// @see http://www.codeproject.com/useritems/Small_Block_Allocator.asp
    ///
    class BlockAllocator
    {
    public:
        /// @brief Size type.
        using size_type = std::size_t;

        /// @brief Chunk array increment.
        static constexpr auto ChunkArrayIncrement = size_type{128};

        /// @brief Allocator block sizes array data.
        static constexpr std::size_t AllocatorBlockSizes[] =
        {
            16u, 32u, 64u, 96u, 128u, 160u, 192u, 224u, 256u, 320u, 384u, 448u, 512u, 640u,
        };

        /// @brief Chunk size.
        static constexpr auto ChunkSize = size_type{16 * 1024};
        
        /// @brief Max block size (before using external allocator).
        static constexpr size_type GetMaxBlockSize() noexcept
        {
            return AllocatorBlockSizes[std::size(AllocatorBlockSizes) - 1];
        }
        
        /// @brief Chunk array increment.
        static constexpr size_type GetChunkArrayIncrement() noexcept
        {
            return ChunkArrayIncrement;
        }
        
        BlockAllocator();
        
        BlockAllocator(const BlockAllocator& other) = delete;

        BlockAllocator(BlockAllocator&& other) = delete;

        ~BlockAllocator() noexcept;
        
        BlockAllocator& operator= (const BlockAllocator& other) = delete;

        BlockAllocator& operator= (BlockAllocator&& other) = delete;

        /// Allocates memory.
        /// @details Allocates uninitialized storage.
        ///   Uses <code>Alloc</code> if the size is larger than <code>GetMaxBlockSize()</code>.
        ///   Otherwise looks for an appropriately sized block from the free list.
        ///   Failing that, <code>Alloc</code> is used to grow the free list from which
        ///   memory is returned.
        /// @return Non-null pointer if asked to make non-zero sized allocation,
        ///   <code>nullptr</code> otherwise.
        /// @throws std::bad_alloc If unable to allocate non-zero size of memory.
        /// @see Alloc.
        void* Allocate(size_type n);

        /// @brief Allocates an array.
        /// @throws std::bad_alloc If unable to allocate non-zero elements of non-zero size.
        template <typename T>
        T* AllocateArray(size_type n)
        {
            return static_cast<T*>(Allocate(n * sizeof(T)));
        }
        
        /// @brief Frees memory.
        /// @details This will use free if the size is larger than <code>GetMaxBlockSize()</code>.
        void Free(void* p, size_type n);
        
        /// Clears this allocator.
        /// @note This resets the chunk-count back to zero.
        void Clear();
        
        /// @brief Gets the chunk count.
        auto GetChunkCount() const noexcept
        {
            return m_chunkCount;
        }

    private:
        struct Chunk;
        struct Block;
        
        size_type m_chunkCount = 0; ///< Chunk count.
        size_type m_chunkSpace = GetChunkArrayIncrement(); ///< Chunk space.
        Chunk* m_chunks = nullptr; ///< Chunks array.
        Block* m_freeLists[std::size(AllocatorBlockSizes)] = {}; ///< Free lists.
    };
    
    /// Block deallocator.
    struct BlockDeallocator
    {
        /// @brief Size type.
        using size_type = BlockAllocator::size_type;

        BlockDeallocator() = default;

        /// @brief Initializing constructor.
        constexpr BlockDeallocator(BlockAllocator* a, size_type n) noexcept:
            allocator{a}, nelem{n}
        {
            // Intentionally empty.
        }

        /// @brief Default operator.
        void operator()(void *p) const noexcept
        {
            allocator->Free(p, nelem);
        }

        BlockAllocator* allocator = nullptr; ///< Allocator pointer.
        size_type nelem = 0u; ///< Number of elements.
    };
    
    /// @brief <code>BlockAllocator</code> equality operator.
    inline bool operator==(const BlockAllocator& a, const BlockAllocator& b)
    {
        return &a == &b;
    }
    
    /// @brief <code>BlockAllocator</code> inequality operator.
    inline bool operator!=(const BlockAllocator& a, const BlockAllocator& b)
    {
        return &a != &b;
    }
    
} // namespace playrho

#endif // PLAYRHO_BLOCKALLOCATOR_HPP
