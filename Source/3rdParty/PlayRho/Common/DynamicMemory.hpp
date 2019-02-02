/*
 * Original work Copyright (c) 2006-2009 Erin Catto http://www.box2d.org
 * Modified work Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COMMON_DYNAMICMEMORY_HPP
#define PLAYRHO_COMMON_DYNAMICMEMORY_HPP

#include "PlayRho/Defines.hpp"
#include <cstddef>

namespace playrho
{
    // Memory Allocation
    
    /// @brief Allocates memory.
    /// @note Implement this function to use your own memory allocator.
    void* Alloc(std::size_t size);
    
    /// @brief Allocates memory.
    template <typename T>
    T* Alloc(std::size_t size)
    {
        return static_cast<T*>(Alloc(size * sizeof(T)));
    }
    
    /// @brief Reallocates memory.
    /// @note Implement this function to use your own memory allocator.
    void* Realloc(void* ptr, std::size_t new_size);
    
    /// @brief Reallocates memory.
    template <typename T>
    T* Realloc(T* ptr, std::size_t size)
    {
        return static_cast<T*>(Realloc(static_cast<void *>(ptr), size * sizeof(T)));
    }
    
    /// @brief Frees memory.
    /// @note If you implement <code>Alloc</code>, you should also implement this function.
    void Free(void* mem);

} // namespace playrho

#endif // PLAYRHO_COMMON_DYNAMICMEMORY_HPP
