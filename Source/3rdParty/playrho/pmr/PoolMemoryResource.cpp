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

#include <algorithm> // for std::find_if
#include <cassert> // for assert
#include <sstream> // for std::ostringstream
#include <utility> // for std::exchange

#include "playrho/DynamicMemory.hpp"
#include "playrho/Math.hpp" // for ToSigned

#include "playrho/pmr/PoolMemoryResource.hpp"

namespace playrho::pmr {

static_assert(PoolMemoryOptions{}.reserveBuffers == 0u);
static_assert(PoolMemoryOptions{}.reserveBytes == 0u);
static_assert(PoolMemoryOptions{}.limitBuffers == static_cast<std::size_t>(-1));

/// @brief Signed size type.
using ssize_t = std::make_signed_t<std::size_t>;

/// @brief Buffer record for @c PoolMemoryResource.
class PoolMemoryResource::BufferRecord
{
    void* pointer{};
    std::size_t size_bytes{};
    std::size_t align_bytes{};
public:

    /// @brief Default constructor.
    BufferRecord() noexcept = default;

    /// @brief Initializing constructor.
    BufferRecord(void* p, std::size_t n, std::size_t a)
        : pointer{p},
          size_bytes{n},
          align_bytes{a}
    {
        // Intentionally empty.
    }

    /// @brief Copy construction is explicitly deleted.
    BufferRecord(const BufferRecord& other) = delete;

    /// @brief Move constructor.
    BufferRecord(BufferRecord&& other) noexcept
        : pointer(std::exchange(other.pointer, nullptr)),
          size_bytes(std::exchange(other.size_bytes, 0u)),
          align_bytes(std::exchange(other.align_bytes, 0u))
    {
        // Intentionally empty.
    }

    /// @brief Destructor.
    ~BufferRecord() = default;

    /// @brief Copy assignment is explicitly deleted.
    BufferRecord& operator=(const BufferRecord& other) = delete;

    /// @brief Move assignment support.
    BufferRecord& operator=(BufferRecord&& other) noexcept
    {
        if (this != &other) {
            pointer = std::exchange(other.pointer, pointer);
            size_bytes = std::exchange(other.size_bytes, size_bytes);
            align_bytes = std::exchange(other.align_bytes, align_bytes);
        }
        return *this;
    }

    /// @brief Assignment function.
    BufferRecord& assign(void* p, std::size_t n, std::size_t a) noexcept
    {
        pointer = p;
        size_bytes = n;
        align_bytes = a;
        return *this;
    }

    /// @brief Access to underlying pointer.
    void *data() const noexcept
    {
        return pointer;
    }

    /// @brief Size of the underlying buffer in bytes.
    std::size_t size() const noexcept
    {
        return static_cast<std::size_t>(std::abs(ssize()));
    }

    /// @brief Signed size of the underlying buffer in bytes.
    ssize_t ssize() const noexcept
    {
        return ToSigned(size_bytes);
    }

    /// @brief Alignment of the underlying buffer in bytes.
    std::size_t alignment() const noexcept
    {
        return align_bytes;
    }

    /// @brief Whether for memory which is allocated currently.
    bool is_allocated() const noexcept
    {
        return ssize() < 0;
    }

    /// @brief Allocate this buffer record.
    void allocate() noexcept
    {
        assert(!is_allocated());
        size_bytes = static_cast<std::size_t>(-abs(ssize()));
    }

    /// @brief Deallocate this buffer record.
    void deallocate() noexcept
    {
        assert(is_allocated());
        size_bytes = size();
    }
};

namespace {

PoolMemoryOptions Validate(const PoolMemoryOptions& options)
{
    if (options.reserveBuffers > options.limitBuffers) {
        throw std::length_error{"pre-allocation would exceed buffers limit"};
    }

    if (options.reserveBytes > PoolMemoryResource::GetMaxNumBytes()) {
        throw std::bad_array_new_length{};
    }
    return options;
}

std::vector<PoolMemoryResource::BufferRecord>
GetBuffers(const PoolMemoryOptions& options, memory_resource* upstream)
{
    std::vector<PoolMemoryResource::BufferRecord> buffers;
    buffers.resize(options.reserveBuffers);
    for (auto i = std::size_t{0}; i < options.reserveBuffers; ++i) {
        auto* p = static_cast<void*>(nullptr);
        try {
            p = upstream->allocate(options.reserveBytes, alignof(std::max_align_t)); // could throw!
        }
        catch (...) {
            // Attempt to cleanup by deallocating any memory already allocated...
            for (--i; i < std::size_t(-1); --i) {
                auto& buffer = buffers[i];
                try {
                    upstream->deallocate(buffer.data(), buffer.size(), buffer.alignment());
                }
                catch (...) {
                    std::terminate();
                }
            }
            throw; // rethrow original exception
        }
        buffers[i].assign(p, options.reserveBytes, alignof(std::max_align_t));
    }
    return buffers;
}

}

std::size_t PoolMemoryResource::GetMaxNumBytes() noexcept
{
    return static_cast<std::size_t>(std::numeric_limits<ssize_t>::max());
}

PoolMemoryResource::PoolMemoryResource(const PoolMemoryOptions& options, memory_resource* upstream)
    : m_options{Validate(options)},
      m_upstream{upstream ? upstream : new_delete_resource()},
      m_buffers{GetBuffers(m_options, m_upstream)}
{
    // Intentionally empty
}

PoolMemoryResource::~PoolMemoryResource() noexcept
{
    for (auto&& buffer: m_buffers) {
        // Deallocate should not throw in this context of having previously allocated
        // this memory. If it does, fail fast! It signifies a significant logic error.
        // In which case, this code and that of the upstream resource needs to be
        // inspected and likely needs to be updated.
        m_upstream->deallocate(buffer.data(), buffer.size(), buffer.alignment());
        buffer = BufferRecord{};
    }
}

PoolMemoryResource::Stats PoolMemoryResource::GetStats() const noexcept
{
    Stats stats;
    stats.numBuffers = m_buffers.size();
    for (const auto& buffer: m_buffers) {
        const auto bytes = buffer.size();
        stats.maxBytes = std::max(stats.maxBytes, bytes);
        stats.totalBytes += bytes;
        if (buffer.is_allocated()) {
            ++stats.allocatedBuffers;
        }
    }
    return stats;
}

void *PoolMemoryResource::do_allocate(std::size_t num_bytes, std::size_t alignment)
{
    if (num_bytes > GetMaxNumBytes()) {
        throw std::bad_array_new_length{};
    }
    for (auto&& buffer: m_buffers) {
        if (!buffer.is_allocated()) {
            const auto fit = (num_bytes <= buffer.size()) && (alignment <= buffer.alignment());
            if (!fit && !m_options.releasable) {
                continue;
            }
            if (!fit) {
                m_upstream->deallocate(buffer.data(), buffer.size(), buffer.alignment());
                buffer = BufferRecord{};
                auto* p = m_upstream->allocate(num_bytes, alignment); // could throw!
                buffer.assign(p, num_bytes, alignment);
            }
            buffer.allocate();
            return buffer.data();
        }
    }
    if (m_buffers.size() >= m_options.limitBuffers) {
        std::ostringstream os;
        os << "allocate ";
        os << num_bytes;
        os << "b, aligned to ";
        os << alignment;
        os << "b, would exceed buffer count limit, stats=";
        os << GetStats();
        throw std::length_error{os.str()};
    }
    auto& buffer = m_buffers.emplace_back(); // could throw!
    auto* p = static_cast<void*>(nullptr);
    try {
        p = m_upstream->allocate(num_bytes, alignment); // could throw!
    }
    catch (...) {
        m_buffers.pop_back();
        throw;
    }
    buffer.assign(p, num_bytes, alignment);
    buffer.allocate();
    return buffer.data();
}

void PoolMemoryResource::do_deallocate(void *p, std::size_t num_bytes, std::size_t alignment)
{
    const auto it = std::find_if(begin(m_buffers), end(m_buffers), [p](const auto& buffer){
        return p == buffer.data();
    });
    if (it == end(m_buffers)) {
        throw std::logic_error{"called to deallocate block not known by this allocator"};
    }
    if (num_bytes > it->size()) {
        throw std::logic_error{"deallocation size greater-than size originally allocated"};
    }
    if (alignment > it->alignment()) {
        std::ostringstream os;
        os << "deallocation alignment (";
        os << alignment;
        os << "), greater-than alignment originally allocated (";
        os << it->alignment();
        os << ")";
        throw std::logic_error{os.str()};
    }
    if (it->is_allocated()) {
        it->deallocate();
    }
}

bool PoolMemoryResource::do_is_equal(const playrho::pmr::memory_resource &other) const noexcept
{
    return &other == this;
}

std::ostream& operator<<(std::ostream& os, const PoolMemoryResource::Stats& stats)
{
    os << "{";
    os << "total-bytes=" << stats.totalBytes;
    os << ", num-buffers=" << stats.numBuffers;
    os << ", allocated-bufs=" << stats.allocatedBuffers;
    os << "}";
    return os;
}

}
