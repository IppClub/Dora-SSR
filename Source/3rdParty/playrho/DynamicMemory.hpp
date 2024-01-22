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

#ifndef PLAYRHO_DYNAMICMEMORY_HPP
#define PLAYRHO_DYNAMICMEMORY_HPP

/// @file
/// @brief Dynamic memory allocation helpers.

#include <cstddef>
#include <limits> // for std::numeric_limits
#include <new>

namespace playrho {

/// @brief Allocates memory.
/// @note One can change this function to use ones own memory allocator. Be sure to conform
///   to this function's interface: throw a <code>std::bad_alloc</code> exception if
///   unable to allocate non-zero sized memory and return a null pointer if the requested
///   size is zero. This is done to ensure that the behavior is not implementation defined
///   unlike <code>std::malloc</code>.
/// @throws std::bad_alloc If unable to allocate non-zero sized memory.
/// @return Non-null pointer if size is not zero else <code>nullptr</code>. Pointer must be
///   deallocated with <code>Free(void*)</code> or one of the <code>Realloc</code> functions.
/// @see Free, Realloc, ReallocArray.
void* Alloc(std::size_t size);

/// @brief Allocates memory for an array.
/// @throws std::bad_alloc If unable to allocate non-zero sized memory.
/// @return Non-null pointer if size is not zero else <code>nullptr</code>. Pointer must be
///   deallocated with <code>Free(void*)</code> or one of the <code>Realloc</code> functions.
/// @see Free, Alloc, ReallocArray.
template <typename T>
T* AllocArray(std::size_t size)
{
    return static_cast<T*>(Alloc(size * sizeof(T)));
}

/// @brief Reallocates memory.
/// @note One can change this function to use ones own memory allocator. Be sure to conform
///   to this function's interface: throw a <code>std::bad_alloc</code> exception if
///   unable to allocate non-zero sized memory, return a null pointer if the requested
///   size is zero, and free old memory if the new size is zero. This is done to ensure
///   that the behavior is not implementation defined unlike <code>std::realloc</code>.
/// @note If the new size for memory is zero, then the old memory is freed.
/// @throws std::bad_alloc If unable to reallocate non-zero sized memory. Pointer must be
///   deallocated with <code>Free(void*)</code> or one of the <code>Realloc</code> functions.
/// @return Non-null pointer if size is not zero else <code>nullptr</code>.
/// @see Alloc, Free.
void* Realloc(void* ptr, std::size_t size);

/// @brief Reallocates memory for an array.
/// @param ptr Pointer to the old memory.
/// @param count Count of elements to reallocate for. This value must be less than the value
///   of <code>std::numeric_limits<std::size_t>::max() / sizeof(T)</code> or an exception will
///   be thrown.
/// @note If the new size for memory is zero, then the old memory is freed.
/// @throws std::bad_alloc If unable to reallocate non-zero sized memory.
/// @return Non-null pointer if count is not zero else <code>nullptr</code>. Pointer must be
///   deallocated with <code>Free(void*)</code> or one of the <code>Realloc</code> functions.
/// @see Realloc, Free.
template <typename T>
T* ReallocArray(T* ptr, std::size_t count)
{
    // Ensure no overflow
    constexpr auto maxCount = std::numeric_limits<std::size_t>::max() / sizeof(T);
    if (count >= maxCount) {
        throw std::bad_array_new_length{};
    }
    return static_cast<T*>(Realloc(static_cast<void*>(ptr), count * sizeof(T)));
}

/// @brief Frees memory.
/// @note If you change <code>Alloc</code>, consider also changing this function.
/// @see Alloc, AllocArray, Realloc, ReallocArray.
void Free(void* mem);

} // namespace playrho

#endif // PLAYRHO_DYNAMICMEMORY_HPP
