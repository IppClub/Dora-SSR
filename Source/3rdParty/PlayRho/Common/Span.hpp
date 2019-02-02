/*
 * Copyright (c) 2017 Louis Langholtz https://github.com/louis-langholtz/PlayRho
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

#ifndef PLAYRHO_COMMON_SPAN_HPP
#define PLAYRHO_COMMON_SPAN_HPP

#include "PlayRho/Defines.hpp"
#include "PlayRho/Common/Templates.hpp"

#include <cstddef>
#include <cassert>
#include <type_traits>
#include <iterator>
#include <vector>

namespace playrho {
    
    /// @brief A C++ encapsulation of an array and its size.
    ///
    /// @note This is conceptually like the Guideline Support Library's span template class.
    /// @sa http://open-std.org/JTC1/SC22/WG21/docs/papers/2016/p0122r1.pdf
    ///
    template <typename T>
    class Span
    {
    public:
        
        /// @brief Data type.
        using data_type = T;

        /// @brief Pointer type.
        using pointer = data_type*;
        
        /// @brief Constant pointer type.
        using const_pointer = const data_type *;

        /// @brief Size type.
        using size_type = std::size_t;
        
        Span() = default;
        
        /// @brief Copy constructor.
        Span(const Span& copy) = default;
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Span(pointer array, size_type size) noexcept:
            m_array{array}, m_size{size}
        {
        }
        
        /// @brief Initializing constructor.
        template <std::size_t SIZE>
        PLAYRHO_CONSTEXPR inline Span(data_type (&array)[SIZE]) noexcept: m_array{&array[0]}, m_size{SIZE} {}
        
        /// @brief Initializing constructor.
        template <typename U, typename = std::enable_if_t< !std::is_array<U>::value > >
        PLAYRHO_CONSTEXPR inline Span(U& value) noexcept:
        m_array{detail::Data(value)}, m_size{detail::Size(value)} {}
        
        /// @brief Initializing constructor.
        PLAYRHO_CONSTEXPR inline Span(std::initializer_list<T> list) noexcept:
            m_array{list.begin()}, m_size{list.size()} {}

        /// @brief Gets the "begin" iterator value.
        pointer begin() const noexcept { return m_array; }

        /// @brief Gets the "begin" iterator value.
        const_pointer cbegin() const noexcept { return m_array; }
        
        /// @brief Gets the "end" iterator value.
        pointer end() const noexcept { return m_array + m_size; }
        
        /// @brief Gets the "end" iterator value.
        const_pointer cend() const noexcept { return m_array + m_size; }

        /// @brief Accesses the indexed element.
        data_type& operator[](size_type index) noexcept
        {
            assert(index < m_size);
            return m_array[index];
        }
        
        /// @brief Accesses the indexed element.
        const data_type& operator[](size_type index) const noexcept
        {
            assert(index < m_size);
            return m_array[index];
        }

        /// @brief Gets the size of this span.
        PLAYRHO_CONSTEXPR size_type size() const noexcept { return m_size; }
        
        /// @brief Direct access to data.
        pointer data() const noexcept { return m_array; }
        
        /// @brief Checks whether this span is empty.
        PLAYRHO_CONSTEXPR bool empty() const noexcept { return m_size == 0; }

    private:
        pointer m_array = nullptr; ///< Pointer to array of data.
        size_type m_size = 0; ///< Size of array of data.
    };
    
} // namespace playrho

#endif // PLAYRHO_COMMON_SPAN_HPP
