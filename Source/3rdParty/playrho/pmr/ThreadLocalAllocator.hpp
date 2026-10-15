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

#ifndef PLAYRHO_THREAD_LOCAL_ALLOCATOR_HPP
#define PLAYRHO_THREAD_LOCAL_ALLOCATOR_HPP

#include <cstddef> // for std::size_t, std::max_align_t
#include <limits> // for std::numeric_limits
#include <new> // for std::bad_array_new_length
#include <tuple>
#include <type_traits> // for std::is_base_of_v

#include "playrho/pmr/MemoryResource.hpp"

// Support PlayRho/Export.hpp being a generated file that may not exist...
#if !defined(__has_include) || !__has_include(<PlayRho/Export.hpp>)
#ifndef PLAYRHO_EXPORT
#define PLAYRHO_EXPORT
#endif
#else // !defined(__has_include) || !__has_include(<PlayRho/Export.hpp>)
#include "playrho/Export.hpp"
#endif // !defined(__has_include) || !__has_include(<PlayRho/Export.hpp>)

namespace playrho {

/// @brief Thread local "stateless" allocator.
/// @note This is meant to meet the allocator named requirements.
/// @note Being a "stateless" allocator, means that objects of this type do not have
///    any *non-static* data members - i.e. instances themselves don't have any state.
/// @warning Behavior is not specified if memory allocated by this class is ever used
///   or deallocated by a different thread.
/// @tparam T cv-unqualified object type of each array element that the instantiated
///   allocator will allocate buffers for.
/// @tparam MemoryResource The <code>pmr::memory_resource</code> derived type that the
///   instantiated allocator will use to allocate and deallocate buffers from and to.
/// @tparam MemoryResourceArgs Zero or more default constructable functor types for
///   passing compile-time arguments for construction of the memory resource object.
/// @see https://en.cppreference.com/w/cpp/named_req/Allocator.
template <class T, class MemoryResource, class... MemoryResourceArgs>
class ThreadLocalAllocator
{
public:
    static_assert(std::is_base_of_v<pmr::memory_resource, MemoryResource>);
    static_assert(std::conjunction_v<std::is_invocable<MemoryResourceArgs>...>);
    static_assert(std::is_constructible_v<MemoryResource, decltype(MemoryResourceArgs{}())...>);

    /// @brief Value type of this class.
    /// @note This is a required alias of the allocator named requirement.
    using value_type = T;

    /// @brief Resource type.
    using resource_type = MemoryResource;

    /// @brief Resource argument functors.
    /// @details This is the list of zero or more types providing arguments for constructing
    ///   the resource type.
    using resource_args = std::tuple<MemoryResourceArgs...>;

    /// @brief Max size usable by instances of this allocator.
    /// @return Max value of <code>std::size_t</code> divided by size of this allocator's
    ///   value type.
    static constexpr auto max_size() noexcept -> std::size_t
    {
        return std::numeric_limits<std::size_t>::max() / sizeof(T);
    }

    /// @brief Gets the underlying memory resource for this class.
    static PLAYRHO_EXPORT auto resource() -> MemoryResource*
    {
        static thread_local MemoryResource singleton{MemoryResourceArgs{}()...};
        return &singleton;
    }

    /// @brief Default constructor.
    ThreadLocalAllocator() = default;

    /// @brief Copy constructor.
    template <class U>
    ThreadLocalAllocator(const ThreadLocalAllocator<U, MemoryResource, MemoryResourceArgs...>&)
    {
        // Intentionally empty.
    }

    /// @brief Allocate interface function.
    /// @note Calls underlying resource's allocate function if given size is not too large for
    ///   this class.
    /// @throws std::bad_array_new_length if given a size greater than <code>max_size()</code>.
    [[nodiscard]] T* allocate(std::size_t n)
    {
        if (n > max_size()) {
            throw std::bad_array_new_length{};
        }
        return static_cast<T*>(resource()->allocate(n * sizeof(T), alignof(T)));
    }

    /// @brief Deallocate interface function.
    void deallocate(T* p, std::size_t n)
    {
        resource()->deallocate(p, n * sizeof(T), alignof(T));
    }

    /// @brief Equality support.
    /// @return true.
    friend bool operator==(const ThreadLocalAllocator& /*lhs*/,
                           const ThreadLocalAllocator& /*rhs*/) noexcept
    {
        return true;
    }

    /// @brief Inequality support.
    /// @return false.
    friend bool operator!=(const ThreadLocalAllocator& lhs, const ThreadLocalAllocator& rhs) noexcept
    {
        return !(lhs == rhs);
    }
};

}

#endif // PLAYRHO_THREAD_LOCAL_ALLOCATOR_HPP
