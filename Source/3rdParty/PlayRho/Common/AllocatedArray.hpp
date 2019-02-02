/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COMMON_ALLOCATEDARRAY_HPP
#define PLAYRHO_COMMON_ALLOCATEDARRAY_HPP

#include "PlayRho/Common/Settings.hpp"

#include <functional>

namespace playrho {

/// Allocated Array.
template <typename T, typename Deleter = std::function<void (void *)> >
class AllocatedArray
{
public:
    
    /// @brief Size type.
    using size_type = std::size_t;

    /// @brief Value type.
    using value_type = T;
    
    /// @brief Constant value type.
    using const_value_type = const value_type;
    
    /// @brief Reference type.
    using reference = value_type&;
    
    /// @brief Constant reference type.
    using const_reference = const value_type&;
    
    /// @brief Pointer type.
    using pointer = value_type*;
    
    /// @brief Constant pointer type.
    using const_pointer = const value_type*;
    
    /// @brief Difference type.
    using difference_type = std::ptrdiff_t;
    
    /// @brief Deleter type.
    using deleter_type = Deleter;

    /// @brief Iterator alias.
    using iterator = pointer;

    /// @brief Constant iterator alias.
    using const_iterator = const_pointer;

    /// @brief Initializing constructor.
    PLAYRHO_CONSTEXPR inline AllocatedArray(size_type max_size, pointer data, deleter_type deleter = noop_deleter):
        m_max_size{max_size}, m_data{data}, m_deleter{deleter}
    {
        assert(data);
    }
    
    /// @brief Destructor.
    ~AllocatedArray() noexcept
    {
        m_deleter(m_data);
        m_data = nullptr;
    }

    AllocatedArray() = delete;
    AllocatedArray(const AllocatedArray& copy) = delete;

    /// @brief Move constructor.
    AllocatedArray(AllocatedArray&& other) noexcept:
        m_max_size{other.m_max_size}, m_size{other.m_size}, m_data{other.m_data}, m_deleter{other.m_deleter}
    {
        other.m_size = 0;
        other.m_data = nullptr;
    }

    /// @brief Gets the current size of this array.
    size_type size() const noexcept { return m_size; }

    /// @brief Gets the maximum size this array can possibly get to.
    size_type max_size() const noexcept { return m_max_size; }
    
    /// @brief Determines whether this array is empty.
    bool empty() const noexcept { return size() == 0; }

    /// @brief Gets a direct pointer to this array's memory.
    pointer data() const noexcept { return m_data; }

    /// @brief Indexed operator.
    reference operator[](size_type i)
    {
        assert(i < m_size);
        return m_data[i];
    }

    /// @brief Indexed operator.
    const_reference operator[](size_type i) const
    {
        assert(i < m_size);
        return m_data[i];
    }

    /// @brief Gets the "begin" iterator value for this array.
    iterator begin() { return iterator{m_data}; }

    /// @brief Gets the "end" iterator value for this array.
    iterator end() { return iterator{m_data + size()}; }
    
    /// @brief Gets the "begin" iterator value for this array.
    const_iterator begin() const { return const_iterator{m_data}; }
    
    /// @brief Gets the "end" iterator value for this array.
    const_iterator end() const { return const_iterator{m_data + size()}; }
    
    /// @brief Gets the "begin" iterator value for this array.
    const_iterator cbegin() const { return const_iterator{m_data}; }
    
    /// @brief Gets the "end" iterator value for this array.
    const_iterator cend() const { return const_iterator{m_data + size()}; }

    /// @brief Gets a reference to the "back" element of this array.
    /// @warning Behavior is undefined if the size of this array is less than 1.
    reference back() noexcept
    {
        assert(m_size > 0);
        return m_data[m_size - 1];        
    }

    /// @brief Gets a reference to the "back" element of this array.
    /// @warning Behavior is undefined if the size of this array is less than 1.
    const_reference back() const noexcept
    {
        assert(m_size > 0);
        return m_data[m_size - 1];
    }

    /// @brief Clears this array.
    void clear() noexcept
    {
        m_size = 0;
    }

    /// @brief Push "back" the given value.
    void push_back(const_reference value)
    {
        assert(m_size < m_max_size);
        m_data[m_size] = value;
        ++m_size;
    }
    
    /// @brief Pop "back".
    void pop_back() noexcept
    {
        assert(m_size > 0);
        --m_size;
    }

private:
    
    /// @brief No-op deleter method.
    static void noop_deleter(void* /*unused*/) {}

    size_type m_max_size = 0; ///< Max size. 8-bytes.
    size_type m_size = 0; ///< Current size. 8-bytes.
    pointer m_data = nullptr; ///< Pointer to allocated data space. 8-bytes.
    deleter_type m_deleter; ///< Deleter. 8-bytes (with default Deleter).
};

}; // namespace playrho

#endif // PLAYRHO_COMMON_ALLOCATEDARRAY_HPP
