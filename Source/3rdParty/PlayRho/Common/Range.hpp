/*
 * Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COMMON_RANGE_HPP
#define PLAYRHO_COMMON_RANGE_HPP

#include "PlayRho/Defines.hpp"
#include <cstddef>

namespace playrho {
    
    /// @brief Template range value class.
    template <typename IT>
    class Range
    {
    public:
        /// @brief Iterator type.
        using iterator_type = IT;

        /// @brief Value type alias.
        using value_type = decltype(*std::declval<iterator_type>());

        /// @brief Default constructor.
        constexpr Range() noexcept = default;

        /// @brief Initializing constructor.
        constexpr Range(iterator_type iter_begin, iterator_type iter_end) noexcept:
        	m_begin{iter_begin}, m_end{iter_end}
        {
            // Intentionally empty.
        }

        /// @brief Gets the "begin" index value.
        constexpr iterator_type begin() const noexcept
        {
            return m_begin;
        }

        /// @brief Gets the "end" index value.
        constexpr iterator_type end() const noexcept
        {
            return m_end;
        }

        /// @brief Whether this range is empty.
        constexpr bool empty() const noexcept
        {
            return m_begin == m_end;
        }

    private:
        iterator_type m_begin{}; ///< Begin iterator.
        iterator_type m_end{}; ///< End iterator.
    };

    /// @brief Template sized range value class.
    template <typename IT>
    class SizedRange: public Range<IT>
    {
    public:
        /// @brief Size type.
        using size_type = std::size_t;

        /// @brief Default constructor.
        constexpr SizedRange() noexcept = default;

        /// @brief Initializing constructor.
        constexpr SizedRange(typename Range<IT>::iterator_type iter_begin,
                             typename Range<IT>::iterator_type iter_end,
                             size_type size) noexcept:
        	Range<IT>{iter_begin, iter_end}, m_size{size}
        {
            // Intentionally empty.
        }

        /// @brief Gets the size of this range.
        constexpr size_type size() const noexcept
        {
            return m_size;
        }

    private:
        size_type m_size{}; ///< Size in number of elements in the range.
    };

} // namespace playrho

#endif // PLAYRHO_COMMON_RANGE_HPP
