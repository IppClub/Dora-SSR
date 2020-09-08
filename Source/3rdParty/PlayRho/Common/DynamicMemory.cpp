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

#include "PlayRho/Common/DynamicMemory.hpp"

#include <cstdlib>

namespace playrho {

    // Memory allocators. Modify these to use your own allocator.
    void* Alloc(std::size_t size)
    {
        if (size) {
            const auto memory = std::malloc(size);
            if (!memory) {
                throw std::bad_alloc{};
            }
            return memory;
        }
        return nullptr;
    }

    void* Realloc(void* ptr, std::size_t size)
    {
        if (size) {
            const auto memory = std::realloc(ptr, size);
             if (!memory) {
                 throw std::bad_alloc{};
             }
             return memory;
        }
        Free(ptr);
        return nullptr;
    }

    void Free(void* mem)
    {
        std::free(mem);
    }

} // namespace playrho
