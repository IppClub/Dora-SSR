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

#ifndef PLAYRHO_POOL_ALLOCATOR_HPP
#define PLAYRHO_POOL_ALLOCATOR_HPP

#include <cstddef> // for std::size_t, std::byte
#include <memory> // for std::unique_ptr
#include <ostream>
#include <type_traits> // for std::make_signed_t
#include <utility> // for std::pair
#include <vector>

#include "playrho/Math.hpp"
#include "playrho/pmr/MemoryResource.hpp"

namespace playrho::pmr {

/// @brief Configurable options.
struct PoolMemoryOptions
{
    /// @brief Reserver buffers.
    /// @note This is the initial number of buffers to reserve space for on construction.
    std::size_t reserveBuffers{};

    /// @brief Reserve bytes.
    /// @note This is the initial size of any buffers reserved on construction. If zero,
    ///   no-memory is pre-allocated for these buffers.
    std::size_t reserveBytes{};

    /// @brief Limit on number of buffers.
    /// @note This limit is used by <code>do_allocate</code>.
    /// @note Needs to be 2+ for supporting post-construction push/emplace increases in container
    ///   capacity.
    /// @see do_allocate.
    std::size_t limitBuffers{static_cast<std::size_t>(-1)};

    /// @brief Whether buffers are releasable when unused and a bigger space is needed.
    bool releasable{true};
};

/// @brief Operator equals support.
constexpr bool operator==(const PoolMemoryOptions& lhs, const PoolMemoryOptions& rhs) noexcept
{
    return (lhs.reserveBuffers == rhs.reserveBuffers) // force line-break
        && (lhs.reserveBytes == rhs.reserveBytes) // force line-break
        && (lhs.limitBuffers == rhs.limitBuffers) // force line-break
        && (lhs.releasable == rhs.releasable);
}

/// @brief Operator not-equals support.
constexpr bool operator!=(const PoolMemoryOptions& lhs, const PoolMemoryOptions& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Pool memory resource.
/// @note This is a memory pooling implementation of a <code>memory_resource</code>.
///  It is similar to <code>std::pmr::unsynchronized_pool_resource</code>.
/// @see https://en.cppreference.com/w/cpp/memory/unsynchronized_pool_resource
class PoolMemoryResource final: public memory_resource
{
public:
    /// @brief Statistics data.
    struct Stats
    {
        /// @brief Number of buffer elements.
        /// @note This is same as <code>size(m_buffers)</code>.
        std::size_t numBuffers{};

        /// @brief Max bytes capacity of any buffer element.
        std::size_t maxBytes{};

        /// @brief Total bytes capacity of all buffer elements.
        std::size_t totalBytes{};

        /// @brief Count of buffers in the "allocated" (i.e. in-use-by-caller) state.
        std::size_t allocatedBuffers{};

        /// @brief Operator equals support.
        friend bool operator==(const Stats& lhs, const Stats& rhs) noexcept
        {
            return (lhs.numBuffers == rhs.numBuffers) // force line-break
                && (lhs.maxBytes == rhs.maxBytes) // force line-break
                && (lhs.totalBytes == rhs.totalBytes) // force line-break
                && (lhs.allocatedBuffers == rhs.allocatedBuffers);
        }

        /// @brief Operator not-equals support.
        friend bool operator!=(const Stats& lhs, const Stats& rhs) noexcept
        {
            return !(lhs == rhs);
        }
    };

    class BufferRecord;

    /// @brief Gets the maximum number of bytes supported for any allocations this class does.
    /// @see PoolMemoryResource(const Options& options), do_allocate.
    static std::size_t GetMaxNumBytes() noexcept;

    /// @brief Default and initializing constructor.
    /// @note Constructs an instance with the given options such that <code>options.reserveBuffers</code>
    ///    buffers are pre-allocated with <code>options.reserveBytes</code> bytes and are immediately
    ///    available for <code>do_allocate</code> calls.
    /// @pre Upstream memory resource won't throw any exceptions if called to deallocate buffers
    ///    it's previously allocated.
    /// @post <code>GetOptions()</code> returns the given options.
    /// @throws std::length_error if <code>options.reserveBuffers > options.limitBuffers</code>.
    /// @throws std::bad_array_new_length if <code>options.reserveBytes > GetMaxNumBytes()</code>.
    /// @throws std::bad_alloc if an allocation of <code>options.reserveBytes</code> fails for any of
    ///   the <code>options.reserveBuffers</code> buffers.
    PoolMemoryResource(const PoolMemoryOptions& options = {}, memory_resource* upstream = nullptr);

    /// @brief Upstream initializing constructor.
    /// @pre Upstream memory resource won't throw any exceptions if called to deallocate buffers
    ///    it's previously allocated.
    PoolMemoryResource(memory_resource* upstream): PoolMemoryResource(PoolMemoryOptions{}, upstream)
    {
        // Intentionally empty.
    }

    /// @brief Copy construction deleted!
    PoolMemoryResource(const PoolMemoryResource& other) = delete;

    /// @brief Moves construction deleted!
    PoolMemoryResource(PoolMemoryResource&& other) = delete;

    /// @brief Destructor.
    /// @note Deallocates the allocated memory.
    /// @warning Terminates if upstream resource throws on deallocating any memory.
    ~PoolMemoryResource() noexcept override;

    /// @brief Copy assignment deleted!
    PoolMemoryResource& operator=(const PoolMemoryResource& other) = delete;

    /// @brief Moves assignment deleted!
    PoolMemoryResource& operator=(PoolMemoryResource&& other) = delete;

    /// @brief Gets the options used by this instance.
    /// @see PoolMemoryResource(const Options&, memory_resource*).
    PoolMemoryOptions GetOptions() const noexcept
    {
        return m_options;
    }

    /// @brief Gets the current statistics.
    Stats GetStats() const noexcept;

    /// @brief Gets the upstream resource.
    memory_resource* GetUpstream() const noexcept
    {
        return m_upstream;
    }

    /// @brief Do the requested allocation.
    /// @note Setting <code>Options::limitBuffers</code> to 1 can help identify code that's not reserving
    ///   enough capacity ahead of time to avoid having to move data over to new buffers whenever
    ///   existing capacity runs out by causing <code>std::length</code> to get thrown then instead.
    /// @note This function provides the strong exception guarantee. The state of the instance will be
    ///   unchanged if an exception is thrown.
    /// @throws std::bad_array_new_length if <code>num_bytes</code> is greater than
    ///   <code>GetMaxNumBytes()</code>.
    /// @throws std::length_error If called with no deallocated buffers available and the number of
    ///   allocated buffers has reached (or exceeded)  <code>Options::limitBuffers</code>.
    void *do_allocate(std::size_t num_bytes, std::size_t alignment) override;

    /// @brief Do the requested deallocation.
    void do_deallocate(void *p, std::size_t num_bytes, std::size_t alignment) override;

    /// @brief Do an equality comparison with the given instance.
    /// @return <code>true</code> if the address of the other instance is the same as the address of this instance,
    ///   <code>false</code> otherwise.
    bool do_is_equal(const memory_resource &other) const noexcept override;

private:
    /// @brief Options used by this instance.
    PoolMemoryOptions m_options;

    /// @brief Upstream memory provider.
    memory_resource* m_upstream{new_delete_resource()};

    /// @brief Container of allocated and "deallocated" buffers.
    /// @note Buffers are not actually released until this instance's destruction.
    std::vector<BufferRecord> m_buffers;
};

/// @brief Provide output streaming support for <code>PoolMemoryResource::Stats</code>.
std::ostream& operator<<(std::ostream& os, const PoolMemoryResource::Stats& stats);

}

#endif // PLAYRHO_POOL_ALLOCATOR_HPP
