/*
 * Original work Copyright (c) 2010 Erin Catto http://www.box2d.org
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

#ifndef PLAYRHO_GROWABLESTACK_HPP
#define PLAYRHO_GROWABLESTACK_HPP

/// @file
/// @brief Definition of the @c GrowableStack class template.

#include <cassert> // for assert
#include <cstring>

// IWYU pragma: begin_exports

#include "playrho/DynamicMemory.hpp"

#include "playrho/detail/Templates.hpp" // for data

// IWYU pragma: end_exports

namespace playrho {

/// This is a growable LIFO stack with an initial capacity of N.
/// If the stack size exceeds the initial capacity, the heap is used
/// to increase the size of the stack.
template <typename T, std::size_t N>
class GrowableStack
{
public:
    
    /// @brief Element type.
    using ElementType = T;

    /// @brief Count type.
    using CountType = std::size_t;

    /// @brief Gets the initial capacity.
    static constexpr CountType GetInitialCapacity() noexcept
    {
        return CountType(N);
    }
    
    /// @brief Gets the buffer growth rate.
    static constexpr CountType GetBufferGrowthRate() noexcept
    {
        return CountType{2};
    }

    GrowableStack() = default;
    
    GrowableStack(const GrowableStack& other) = delete;

    GrowableStack(GrowableStack&& other) = delete;

    ~GrowableStack() noexcept
    {
        if (m_stack != data(m_array))
        {
            Free(m_stack);
            m_stack = nullptr;
        }
    }

    GrowableStack& operator= (const GrowableStack& copy) = delete;

    GrowableStack& operator= (GrowableStack&& copy) = delete;
    
    /// @brief Pushes the given elements onto this stack.
    void push(const ElementType& element)
    {
        if (m_count == m_capacity)
        {
            const auto old = m_stack;
            m_capacity *= GetBufferGrowthRate();
            m_stack = AllocArray<T>(m_capacity);
            std::memcpy(m_stack, old, m_count * sizeof(T));
            if (old != data(m_array))
            {
                Free(old);
            }
        }

        *(m_stack + m_count) = element;
        ++m_count;
    }

    /// @brief Accesses the "top" element.
    /// @pre <code>size()</code> is greater than zero.
    ElementType top() const
    {
        assert(m_count > 0);
        return m_stack[m_count - 1];
    }

    /// @brief Pops the "top" element.
    /// @pre <code>size()</code> is greater than zero.
    void pop() noexcept
    {
        assert(m_count > 0);
        --m_count;
    }

    /// @brief Gets the current size in numbers of elements.
    constexpr CountType size() const noexcept
    {
        return m_count;
    }
    
    /// @brief Gets the capacity in number of elements.
    constexpr CountType capacity() const noexcept
    {
        return m_capacity;
    }

    /// @brief Whether this stack is empty.
    constexpr bool empty() const noexcept
    {
        return m_count == 0;
    }

private:
    ElementType m_array[N] = {}; ///< Array data.
    ElementType* m_stack = data(m_array); ///< Pointer to array of data.
    CountType m_count = 0; ///< Count of elements.
    CountType m_capacity = N; ///< Capacity for storing elements.
};

} // namespace playrho

#endif // PLAYRHO_GROWABLESTACK_HPP
