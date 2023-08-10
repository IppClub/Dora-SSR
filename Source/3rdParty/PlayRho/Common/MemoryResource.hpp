//===----------------------------------------------------------------------===//
//
// Modified work Copyright (c) Louis Langholtz https://github.com/louis-langholtz/PlayRho
//
// Modified from the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef PLAYRHO_COMMON_MEMORY_RESOURCE_HPP
#define PLAYRHO_COMMON_MEMORY_RESOURCE_HPP

#if !defined(__has_include) || !__has_include(<memory_resource>)

#include <cstddef> // for std::size_t, std::max_align_t
#include <limits> // for std::numeric_limits
#include <new> // for std::bad_array_new_length
#include <type_traits> // for std::is_copy_constructible_v

/// @see: https://en.cppreference.com/w/cpp/header/memory_resource.
namespace playrho::pmr {

/// @see https://en.cppreference.com/w/cpp/memory/memory_resource.
class memory_resource
{
    virtual void* do_allocate(std::size_t bytes, std::size_t alignment) = 0;
    virtual void do_deallocate(void* p, std::size_t bytes, std::size_t alignment) = 0;
    virtual bool do_is_equal(const memory_resource& other) const noexcept = 0;

public:
    memory_resource() = default;
    memory_resource(const memory_resource&) = default;
    virtual ~memory_resource();

    [[nodiscard]] void* allocate(std::size_t bytes,
                                 std::size_t alignment = alignof(std::max_align_t))
    {
        return do_allocate(bytes, alignment);
    }

    void deallocate(void* p, std::size_t bytes,
                    std::size_t alignment = alignof(std::max_align_t))
    {
        do_deallocate(p, bytes, alignment);
    }

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
    using value_type = T;

    polymorphic_allocator(ResourceType resource = nullptr) noexcept:
        m_resource{resource ? resource : get_default_resource()}
    {
        // Intentionally empty.
    }

    polymorphic_allocator(const polymorphic_allocator&) = default;

    template <class U>
    polymorphic_allocator(const polymorphic_allocator<U>& other) noexcept
        : m_resource(other.resource())
    {
        // Intentionally empty.
    }

    polymorphic_allocator& operator=(const polymorphic_allocator&) = delete;

    [[nodiscard]] T* allocate(std::size_t n)
    {
        if (n > (std::numeric_limits<std::size_t>::max() / sizeof(T))) {
            throw std::bad_array_new_length{};
        }
        return static_cast<T*>(m_resource->allocate(n * sizeof(value_type), alignof(T)));
    }

    void deallocate(T* p, std::size_t n) noexcept
    {
        m_resource->deallocate(p, n * sizeof(value_type), alignof(T));
    }

    ResourceType resource() const noexcept
    {
        return m_resource;
    }

    friend bool operator==(const polymorphic_allocator& lhs, const polymorphic_allocator& rhs) noexcept
    {
        return lhs.m_resource == rhs.m_resource;
    }

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

template <class T1, class T2>
bool operator==(const pmr::polymorphic_allocator<T1>& lhs,
                const pmr::polymorphic_allocator<T2>& rhs) noexcept
{
    return lhs.resource() == rhs.resource();
}

template <class T1, class T2>
inline bool operator!=(const pmr::polymorphic_allocator<T1>& lhs,
                       const pmr::polymorphic_allocator<T2>& rhs) noexcept
{
    return !(lhs == rhs);
}

struct pool_options
{
    std::size_t max_blocks_per_chunk = 0;
    std::size_t largest_required_pool_block = 0;
};

}

#else

#include <memory_resource>

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

#endif // PLAYRHO_COMMON_MEMORY_RESOURCE_HPP
