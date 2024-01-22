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

#ifndef PLAYRHO_ARRAYLIST_HPP
#define PLAYRHO_ARRAYLIST_HPP

/// @file
/// @brief Definition of the <code>ArrayList</code> class and closely related functions.

#include <array>
#include <cassert> // for assert
#include <cstdlib> // for std::size_t
#include <initializer_list>
#include <type_traits>
#include <utility> // for std::move

// IWYU pragma: begin_exports

#include "playrho/LengthError.hpp"
#include "playrho/Span.hpp"
#include "playrho/Templates.hpp" // for Equal

// IWYU pragma: end_exports

namespace playrho {

/// @brief Array list.
/// @details This is a <code>std::array</code> backed <code>std::vector</code> like container. It
///   provides vector like behavior whose max size is capped at the size given by the template max
///   size parameter without using dynamic storage.
template <typename T, std::size_t MAXSIZE, typename SIZE_TYPE = std::size_t>
class ArrayList
{
public:
    /// @brief Size type.
    using size_type = SIZE_TYPE;

    /// @brief Value type.
    using value_type = T;

    /// @brief Reference type.
    using reference = value_type&;

    /// @brief Constant reference type.
    using const_reference = const value_type&;

    /// @brief Pointer type.
    using pointer = value_type*;

    /// @brief Constant pointer type.
    using const_pointer = const value_type*;

    /// @brief Iterator type.
    using iterator = value_type*;

    /// @brief Constant iterator type.
    using const_iterator = const value_type*;

    /// @brief Default constructor.
    /// @note Some older versions of gcc have issues with this being defaulted.
    constexpr ArrayList() noexcept = default;

    /// @brief Copy constructor.
    constexpr ArrayList(const ArrayList& other)
        noexcept(std::is_nothrow_copy_assignable_v<T>) = default;

    /// @brief Initializing constructor from initializer list.
    /// @throws LengthError if operation would exceed <code>max_size()</code>.
    /// @see max_size.
    constexpr ArrayList(std::initializer_list<value_type> list)
    {
        if (!(list.size() <= max_size())) {
            throw LengthError("operation would exceed max_size()");
        }
        for (auto&& elem : list) {
            push_back(elem);
        }
    }

    /// @brief Initializing constructor.
    constexpr ArrayList(const Span<const value_type>& list)
    {
        if (!(list.size() <= max_size())) {
            throw LengthError("operation would exceed max_size()");
        }
        for (auto&& elem : list) {
            push_back(elem);
        }
    }

    /// @brief Initializing constructor from other sized <code>ArrayList</code>.
    template <std::size_t COPY_MAXSIZE,
              typename = std::enable_if_t<COPY_MAXSIZE < MAXSIZE>>
    constexpr explicit ArrayList(const ArrayList<T, COPY_MAXSIZE, SIZE_TYPE>& copy)
              noexcept(std::is_nothrow_copy_assignable_v<T>)
    {
        for (auto&& elem : copy) {
            push_back(elem);
        }
    }

    /// @brief Initializing constructor from C-style arrays.
    template <std::size_t SIZE, typename = std::enable_if_t<SIZE <= MAXSIZE>>
    constexpr explicit ArrayList(value_type (&value)[SIZE])
        noexcept(std::is_nothrow_copy_assignable_v<T>)
    {
        for (auto&& elem : value) {
            push_back(elem);
        }
    }

    /// @brief Initializing constructor from C++ <code>std::array</code>.
    template <std::size_t SIZE, typename = std::enable_if_t<SIZE <= MAXSIZE>>
    constexpr explicit ArrayList(const std::array<T, SIZE> &value)
        noexcept(std::is_nothrow_copy_assignable_v<T>)
    {
        for (auto&& elem : value) {
            push_back(elem);
        }
    }

    /// @brief Copy assignment.
    constexpr auto operator=(const ArrayList& other)
        noexcept(std::is_nothrow_copy_assignable_v<T>) -> ArrayList& = default;

    /// @brief Assigns the given values to this.
    /// @return Reference to this instance.
    /// @throws LengthError if operation would exceed <code>max_size()</code>.
    /// @post <code>size()</code> is <code>size(value)</code>.
    /// @see max_size.
    constexpr auto operator=(const Span<const value_type>& other)
        -> ArrayList&
    {
        if (!(other.size() <= max_size())) {
            throw LengthError("operation would exceed max_size()");
        }
        clear();
        for (auto&& elem : other) {
            push_back(elem);
        }
        return *this;
    }

    /// @brief Assignment operator.
    template <std::size_t COPY_MAXSIZE, typename COPY_SIZE_TYPE,
              typename = std::enable_if_t<COPY_MAXSIZE <= MAXSIZE>>
    ArrayList& operator=(const ArrayList<T, COPY_MAXSIZE, COPY_SIZE_TYPE>& copy)
        noexcept(std::is_nothrow_copy_assignable_v<T>)
    {
        m_size = static_cast<SIZE_TYPE>(size(copy));
        for (auto&& elem : copy) {
            push_back(elem);
        }
        return *this;
    }

    /// @brief Copy assignment from C++ <code>std::array</code>.
    template <std::size_t SIZE, typename = std::enable_if_t<SIZE <= MAXSIZE>>
    constexpr auto operator=(const std::array<T, SIZE> &other)
        noexcept(std::is_nothrow_copy_assignable_v<T>) -> ArrayList&
    {
        for (auto&& elem : other) {
            push_back(elem);
        }
    }

    /// @brief Sets the size to the given value.
    /// @pre @p value is less-than or equal-to <code>max_size()</code>.
    /// @post <code>size()</code> returns the value given.
    /// @see size(), max_size.
    constexpr void size(size_type value) noexcept
    {
        assert(value <= max_size());
        m_size = value;
    }

    /// @brief Resets size to zero.
    /// @post <code>size()</code> returns zero.
    /// @see size().
    constexpr void clear() noexcept
    {
        m_size = 0;
    }

    /// @brief Gets whether this object has no elements.
    /// @return true if <code>size()</code> is zero, false otherwise.
    /// @see size().
    constexpr bool empty() const noexcept
    {
        return m_size == 0;
    }

    /// @brief Accesses element at given index.
    /// @pre @p index is less than <code>max_size()</code>.
    /// @see max_size.
    reference operator[](size_type index) noexcept
    {
        assert(index < max_size());
        return m_elements[index]; // NOLINT(cppcoreguidelines-pro-bounds-constant-array-index)
    }

    /// @brief Accesses element at given index.
    /// @pre @p index is less than <code>max_size()</code>.
    /// @see max_size.
    constexpr const_reference operator[](size_type index) const noexcept
    {
        assert(index < max_size());
        return m_elements[index]; // NOLINT(cppcoreguidelines-pro-bounds-constant-array-index)
    }

    /// Gets the size of this collection.
    /// @details This is the number of elements that have been added to this collection.
    /// @return Value between 0 and the maximum size for this collection.
    /// @see max_size.
    constexpr size_type size() const noexcept
    {
        return m_size;
    }

    /// @brief Gets the maximum size that this collection can be.
    /// @details This is the maximum number of elements that can be contained in this collection.
    /// @see size.
    constexpr size_type max_size() const noexcept
    {
        return MAXSIZE;
    }

    /// @brief Gets pointer to underlying data array.
    /// @return Non-null pointer to underlying data.
    constexpr pointer data() noexcept
    {
        return m_elements.data();
    }

    /// @brief Gets pointer to underlying data array.
    /// @return Non-null pointer to underlying data.
    constexpr const_pointer data() const noexcept
    {
        return m_elements.data();
    }

    /// @brief Gets iterator for beginning of array.
    /// @see end.
    constexpr iterator begin() noexcept
    {
        return data();
    }

    /// @brief Gets iterator for ending of array.
    /// @see begin.
    constexpr iterator end() noexcept
    {
        return data() + size();
    }

    /// @brief Gets iterator for beginning of array.
    /// @see end.
    constexpr const_iterator begin() const noexcept
    {
        return data();
    }

    /// @brief Gets iterator for ending of array.
    /// @see begin.
    constexpr const_iterator end() const noexcept
    {
        return data() + size();
    }

    /// @brief Unconditionally pushes given value onto back.
    /// @pre <code>size()</code> is less than <code>max_size()</code>.
    /// @post <code>size()</code> is one greater than before.
    /// @post <code>empty()</code> returns false.
    /// @see max_size.
    constexpr void push_back(value_type value) noexcept(std::is_nothrow_move_assignable_v<T>)
    {
        assert(m_size < max_size());
        m_elements[m_size] = std::move(value); // NOLINT(cppcoreguidelines-pro-bounds-constant-array-index)
        ++m_size;
    }

    /// @brief Adds given value if space available.
    /// @post On successful addition, <code>size()</code> returns value one greater than before.
    /// @return true if value was added, false otherwise.
    /// @see max_size.
    constexpr bool add(value_type value) noexcept(std::is_nothrow_move_assignable_v<T>)
    {
        if (m_size < max_size()) {
            this->push_back(std::move(value));
            return true;
        }
        return false;
    }

private:
    size_type m_size = size_type{0}; ///< Indication of the number of elements in array.
    std::array<value_type, MAXSIZE> m_elements = {}; ///< Buffer for array.
};

// Assert some expected traits...
static_assert(std::is_nothrow_default_constructible_v<ArrayList<int, 1>>);
static_assert(std::is_nothrow_copy_constructible_v<ArrayList<int, 1>>);
static_assert(std::is_nothrow_copy_assignable_v<ArrayList<int, 1>>);
static_assert(std::is_nothrow_constructible_v<ArrayList<int, 1>, std::array<int, 1>>);
static_assert(std::is_nothrow_assignable_v<ArrayList<int, 1>, std::array<int, 1>>);

/// @brief Equality operator support.
template <typename T, std::size_t LhsSize, std::size_t RhsSize>
constexpr auto operator==(const ArrayList<T, LhsSize> &lhs,
                          const ArrayList<T, RhsSize> &rhs) noexcept
{
    if (lhs.size() != rhs.size()) {
        return false;
    }
    return Equal(lhs.begin(), lhs.end(), rhs.begin(), rhs.end());
}

/// @brief Inequality operator support.
template <typename T, std::size_t LhsSize, std::size_t RhsSize>
constexpr auto operator!=(const ArrayList<T, LhsSize> &lhs,
                          const ArrayList<T, RhsSize> &rhs) noexcept
{
    return !(lhs == rhs);
}

/// @brief Appends the given value onto back.
/// @return Reference to this instance.
/// @throws LengthError if <code>size()</code> is not less than <code>max_size()</code>.
/// @post <code>size()</code> is one greater than before.
/// @post <code>empty()</code> returns false.
/// @see max_size.
template <typename T, std::size_t S>
constexpr ArrayList<T, S>& operator+=(ArrayList<T, S>& lhs, T rhs)
{
    if (!(lhs.size() < lhs.max_size())) {
        throw LengthError("operation would exceed max_size()");
    }
    lhs.push_back(std::move(rhs));
    return lhs;
}

/// @brief Appends the given values onto back.
/// @return Reference to this instance.
/// @throws LengthError if operation would exceed <code>max_size()</code>.
/// @post <code>size()</code> is <code>size(value)</code> greater than before.
/// @post <code>empty()</code> returns false.
/// @see max_size.
template <typename T, std::size_t S, class U>
constexpr auto operator+=(ArrayList<T, S>& lhs, U&& rhs)
    -> decltype(rhs.begin(), rhs.end(), rhs.size(), lhs)
{
    if (!(lhs.size() + rhs.size() <= lhs.max_size())) {
        throw LengthError{"operation would exceed max_size"};
    }
    for (auto&& v: std::forward<U>(rhs)) {
        lhs.push_back(std::move(v));
    }
    return lhs;
}

} /* namespace playrho */

/// Tuple size specialization for <code>ArrayList</code> classes.
template <class T, std::size_t N, typename SIZE_TYPE>
class std::tuple_size<playrho::ArrayList<T, N, SIZE_TYPE>> : public integral_constant<std::size_t, N>
{
    // Intentionally empty.
};

#endif // PLAYRHO_ARRAYLIST_HPP
