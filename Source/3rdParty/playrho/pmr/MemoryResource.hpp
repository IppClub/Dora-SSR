//===----------------------------------------------------------------------===//
//
// Modified work Copyright (c) Louis Langholtz https://github.com/louis-langholtz/PlayRho
//
// Modified from the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef PLAYRHO_MEMORY_RESOURCE_HPP
#define PLAYRHO_MEMORY_RESOURCE_HPP

/// @namespace playrho::pmr Name space for organizing custom allocator
///   funtionality & supporting standard libraries that don't yet provide the
///   <code>memory_resource</code> header file.
/// @see: https://en.cppreference.com/w/cpp/header/memory_resource.

#if 1 // !defined(__has_include) || !__has_include(<memory_resource>)

#include <cstddef> // for std::size_t, std::max_align_t
#include <limits> // for std::numeric_limits
#include <new> // for std::bad_array_new_length
#include <type_traits> // for std::is_copy_constructible_v

namespace playrho::pmr {

/// @brief A limited implementation of the <code>std::pmr::memory_resource</code> type.
/// @see https://en.cppreference.com/w/cpp/memory/memory_resource.
class memory_resource
{
    /// @brief Allocates memory.
    /// @see https://en.cppreference.com/w/cpp/memory/memory_resource/do_allocate.
    virtual void* do_allocate(std::size_t bytes, std::size_t alignment) = 0;

    /// @brief Deallocates memory.
    /// @see https://en.cppreference.com/w/cpp/memory/memory_resource/do_deallocate.
    virtual void do_deallocate(void* p, std::size_t bytes, std::size_t alignment) = 0;

    /// @brief Compare for equality with other resource.
    /// @see https://en.cppreference.com/w/cpp/memory/memory_resource/do_is_equal.
    virtual bool do_is_equal(const memory_resource& other) const noexcept = 0;

public:
    /// @brief Default constructor.
    memory_resource() = default;

    /// @brief Copy constructor.
    memory_resource(const memory_resource&) = default;

    /// @brief Destructor.
    virtual ~memory_resource();

    /// @brief Allocates memory.
    [[nodiscard]] void* allocate(std::size_t bytes,
                                 std::size_t alignment = alignof(std::max_align_t))
    {
        return do_allocate(bytes, alignment);
    }

    /// @brief Deallocates memory.
    void deallocate(void* p, std::size_t bytes,
                    std::size_t alignment = alignof(std::max_align_t))
    {
        do_deallocate(p, bytes, alignment);
    }

    /// @brief Compare for equality with other resource.
    bool is_equal(const memory_resource& other) const noexcept
    {
        return do_is_equal(other);
    }
};

// Confirm/recognize type traits...
static_assert(std::is_copy_assignable_v<memory_resource>);
static_assert(std::is_abstract_v<memory_resource>);

/// @brief Operator equals support.
/// @see https://en.cppreference.com/w/cpp/memory/memory_resource/operator_eq.
inline bool operator==(const memory_resource& a, const memory_resource& b) noexcept
{
    return (&a == &b) || a.is_equal(b);
}

/// @brief Operator not-equals support.
/// @see https://en.cppreference.com/w/cpp/memory/memory_resource/operator_eq.
inline bool operator!=(const memory_resource& a, const memory_resource& b) noexcept
{
    return !(a == b);
}

// global memory resources...

/// @brief Gets the new & delete using memory resource.
/// @see https://en.cppreference.com/w/cpp/memory/new_delete_resource.
memory_resource* new_delete_resource() noexcept;

/// @brief Gets the "null" memory resource.
/// @see https://en.cppreference.com/w/cpp/memory/null_memory_resource.
memory_resource* null_memory_resource() noexcept;

/// @brief Sets the default memory resource.
/// @post <code>get_default_resource</code> returns the value given.
/// @see get_default_resource.
/// @see https://en.cppreference.com/w/cpp/memory/set_default_resource.
memory_resource* set_default_resource(memory_resource* r) noexcept;

/// @brief Gets the default memory resource.
/// @see https://en.cppreference.com/w/cpp/memory/get_default_resource.
memory_resource* get_default_resource() noexcept;

/// @brief Similar to a <code>std::pmr::polymorphic_allocator</code>.
/// @note This provides something of a work around type for C++ libraries that don't yet support
///   <code>std::pmr</code> (like pre LLVM 16 and Apple Clang).
template <class T>
class polymorphic_allocator
{
    using ResourceType = memory_resource*;

    ResourceType m_resource{get_default_resource()};

public:
    using value_type = T; ///< Value type alias.

    /// @brief Initializing constructor.
    polymorphic_allocator(ResourceType resource = nullptr) noexcept:
        m_resource{resource ? resource : get_default_resource()}
    {
        // Intentionally empty.
    }

    /// @brief Copy constructor.
    polymorphic_allocator(const polymorphic_allocator&) = default;

    /// @brief Compatible value type copy constructor.
    template <class U>
    polymorphic_allocator(const polymorphic_allocator<U>& other) noexcept
        : m_resource(other.resource())
    {
        // Intentionally empty.
    }

    /// @brief Copy assignment is explicitly deleted.
    polymorphic_allocator& operator=(const polymorphic_allocator&) = delete;

    /// @brief Allocates buffer for array of @p n elements.
    [[nodiscard]] T* allocate(std::size_t n)
    {
        if (n > (std::numeric_limits<std::size_t>::max() / sizeof(T))) {
            throw std::bad_array_new_length{};
        }
        return static_cast<T*>(m_resource->allocate(n * sizeof(value_type), alignof(T)));
    }

    /// @brief Deallocates buffer @p p of array of @p n elements.
    void deallocate(T* p, std::size_t n) noexcept
    {
        m_resource->deallocate(p, n * sizeof(value_type), alignof(T));
    }

    /// @brief Gets the resource property of this instance.
    ResourceType resource() const noexcept
    {
        return m_resource;
    }

    /// @brief Equality support.
    friend bool operator==(const polymorphic_allocator& lhs, const polymorphic_allocator& rhs) noexcept
    {
        return lhs.m_resource == rhs.m_resource;
    }

    /// @brief Inequality support.
    friend bool operator!=(const polymorphic_allocator& lhs, const polymorphic_allocator& rhs) noexcept
    {
        return !(lhs == rhs);
    }
};

static_assert(std::is_default_constructible_v<polymorphic_allocator<int>>);
static_assert(std::is_copy_constructible_v<polymorphic_allocator<int>>);
static_assert(std::is_nothrow_move_constructible_v<polymorphic_allocator<int>>);
static_assert(!std::is_copy_assignable_v<polymorphic_allocator<int>>);
static_assert(!std::is_move_assignable_v<polymorphic_allocator<int>>);

/// @brief Equalality operator support.
template <class T1, class T2>
bool operator==(const pmr::polymorphic_allocator<T1>& lhs,
                const pmr::polymorphic_allocator<T2>& rhs) noexcept
{
    return lhs.resource() == rhs.resource();
}

/// @brief Inequalality operator support.
template <class T1, class T2>
inline bool operator!=(const pmr::polymorphic_allocator<T1>& lhs,
                       const pmr::polymorphic_allocator<T2>& rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Options for memory pooling.
/// @see https://en.cppreference.com/w/cpp/memory/pool_options
struct pool_options
{
    /// @brief Max blocks per chunk.
    std::size_t max_blocks_per_chunk = 0;

    /// @brief Largest required pool block.
    std::size_t largest_required_pool_block = 0;
};

}

#else

// IWYU pragma: begin_exports

#include <memory_resource>

// IWYU pragma: end_exports

namespace playrho::pmr {

// Bring this type into the current namespace...
using memory_resource = std::pmr::memory_resource; // NOLINT(misc-unused-using-decls)

// Bring these functions into the current namespace...
using std::pmr::operator==; // NOLINT(misc-unused-using-decls)
using std::pmr::new_delete_resource; // NOLINT(misc-unused-using-decls)
using std::pmr::null_memory_resource; // NOLINT(misc-unused-using-decls)
using std::pmr::set_default_resource; // NOLINT(misc-unused-using-decls)
using std::pmr::get_default_resource; // NOLINT(misc-unused-using-decls)
template <class T>
using polymorphic_allocator = std::pmr::polymorphic_allocator<T>; // NOLINT(misc-unused-using-decls)

}

#endif

#endif // PLAYRHO_MEMORY_RESOURCE_HPP
