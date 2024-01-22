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

#ifndef PLAYRHO_SPAN_HPP
#define PLAYRHO_SPAN_HPP

/// @file
/// @brief Definition of the @c Span class template.

#include <cstddef>
#include <cassert>
#include <initializer_list>
#include <type_traits>
#include <utility> // for std::forward

// IWYU pragma: begin_exports

#include "playrho/Templates.hpp" // for Equal

// IWYU pragma: end_exports

namespace playrho {

/// @brief An encapsulation of an array and its size.
/// @note This class is like the C++20 <code>std::span</code> class.
/// @note This is also like the Guideline Support Library's span template class.
/// @todo Consider replacing uses of this class with C++20 <code>std::span</code> if/when
///   this project shifts to C++20.
/// @see https://en.cppreference.com/w/cpp/container/span/span
/// @see http://open-std.org/JTC1/SC22/WG21/docs/papers/2016/p0122r1.pdf
template <typename T>
class Span
{
public:
    /// @brief Data type.
    using data_type = T;

    /// @brief Pointer type.
    using pointer = data_type*;

    /// @brief Constant pointer type.
    using const_pointer = const data_type*;

    /// @brief Size type.
    using size_type = std::size_t;

    constexpr Span() noexcept = default;

    /// @brief Initializing constructor.
    constexpr Span(pointer array, size_type size) noexcept : m_array{array}, m_size{size} {}

    /// @brief Initializing constructor.
    constexpr Span(std::initializer_list<T> list) noexcept
        : m_array{list.begin()}, m_size{list.size()}
    {
    }

    /// @brief Initializing constructor.
    template <std::size_t SIZE>
    constexpr Span(data_type (&array)[SIZE]) noexcept : m_array{&array[0]}, m_size{SIZE}
    {
    }

    /// @brief Initializing constructor.
    template <typename U,
              typename = std::enable_if_t<
                  !std::is_array_v<U> &&
                  std::is_same_v<decltype(pointer{::playrho::data(std::declval<U>())}), pointer>>>
    constexpr Span(U&& value) noexcept
        : m_array{::playrho::data(std::forward<U>(value))}, m_size{::playrho::size(std::forward<U>(value))}
    {
    }

    /// @brief Gets the "begin" iterator value.
    constexpr pointer begin() const noexcept
    {
        return m_array;
    }

    /// @brief Gets the "end" iterator value.
    constexpr pointer end() const noexcept
    {
        return m_array + m_size;
    }

    /// @brief Accesses the indexed element.
    constexpr data_type& operator[](size_type index) const noexcept
    {
        assert(index < m_size);
        return m_array[index];
    }

    /// @brief Gets the size of this span.
    constexpr size_type size() const noexcept
    {
        return m_size;
    }

    /// @brief Direct access to data.
    constexpr pointer data() const noexcept
    {
        return m_array;
    }

    /// @brief Checks whether this span is empty.
    constexpr bool empty() const noexcept
    {
        return m_size == 0;
    }

private:
    pointer m_array = nullptr; ///< Pointer to array of data.
    size_type m_size = 0; ///< Size of array of data.
};

/// @brief Equality operator support.
template <typename T>
constexpr auto operator==(const Span<T> &lhs, const Span<T> &rhs) noexcept
{
    if (lhs.size() != rhs.size()) {
        return false;
    }
    return Equal(lhs.begin(), lhs.end(), rhs.begin(), rhs.end());
}

/// @brief Inequality operator support.
template <typename T>
constexpr auto operator!=(const Span<T> &lhs, const Span<T> &rhs) noexcept
{
    return !(lhs == rhs);
}

} // namespace playrho

#endif // PLAYRHO_SPAN_HPP
