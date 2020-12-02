/*
 * Based on work by Jonathan Boccara and Jonathan Müller.
 * Modified work Copyright (c) 2020 Louis Langholtz https://github.com/louis-langholtz/PlayRho
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

#ifndef PLAYRHO_COMMON_INDEXINGNAMEDTYPE_HPP
#define PLAYRHO_COMMON_INDEXINGNAMEDTYPE_HPP

#include <utility>
#include <functional> // for std::hash
#include <type_traits> // for std::is_nothrow_default_constructible

namespace playrho {
namespace detail {

/// @brief An indexable, hashable, named "strong type" template class.
/// @details A template class for wrapping types into more special-purposed types. Wrapping
///   types this way is often referred to as more "strongly typing" the underlying type.
/// @note This comes from pulling together code found from various sites on the Internet.
/// @see https://www.fluentcpp.com/2016/12/08/strong-types-for-strong-interfaces/
/// @see https://foonathan.net/blog/2016/10/19/strong-typedefs.html
template <typename T, typename Tag>
class IndexingNamedType
{
public:
    /// @brief Underlying type alias.
    using underlying_type = T;

    /// @brief Default constructor.
    /// @note This causes default initialization of the underlying type.
    constexpr explicit IndexingNamedType()
    noexcept(std::is_nothrow_default_constructible<underlying_type>::value): value_{} {}

    /// @brief Copy initializing constructor.
    constexpr explicit IndexingNamedType(const underlying_type& value)
    noexcept(std::is_nothrow_copy_constructible<underlying_type>::value): value_(value) {}

    /// @brief Move initializing constructor.
    constexpr explicit IndexingNamedType(underlying_type&& value)
    noexcept(std::is_nothrow_move_constructible<underlying_type>::value):
        value_(std::move(value)) {}

    /// @brief Underlying type cast operator support.
    constexpr explicit operator underlying_type&() noexcept
    {
        return value_;
    }

    /// @brief Underlying type cast operator support.
    constexpr explicit operator const underlying_type&() const noexcept
    {
        return value_;
    }

    /// @brief Accesses the underlying value.
    constexpr underlying_type& get() noexcept
    {
        return value_;
    }

    /// @brief Accesses the underlying value.
    constexpr underlying_type const& get() const noexcept
    {
        return value_;
    }

    /// @brief Swap function.
    friend void swap(IndexingNamedType& a, IndexingNamedType& b) noexcept
    {
        using std::swap;
        swap(static_cast<underlying_type&>(a), static_cast<underlying_type&>(b));
    }

    /// @brief Equality operator.
    friend constexpr bool operator== (const IndexingNamedType& lhs, const IndexingNamedType& rhs)
    {
        return lhs.get() == rhs.get();
    }

    /// @brief Inequality operator.
    friend constexpr bool operator!= (const IndexingNamedType& lhs, const IndexingNamedType& rhs)
    {
        return lhs.get() != rhs.get();
    }

    /// @brief Less-than operator.
    friend constexpr bool operator< (const IndexingNamedType& lhs, const IndexingNamedType& rhs)
    {
        return lhs.get() < rhs.get();
    }

    /// @brief Greater-than operator.
    friend constexpr bool operator> (const IndexingNamedType& lhs, const IndexingNamedType& rhs)
    {
        return lhs.get() > rhs.get();
    }

    /// @brief Less-than-or-equal-to operator.
    friend constexpr bool operator<= (const IndexingNamedType& lhs, const IndexingNamedType& rhs)
    {
        return lhs.get() <= rhs.get();
    }

    /// @brief Greater-than-or-equal-to operator.
    friend constexpr bool operator>= (const IndexingNamedType& lhs, const IndexingNamedType& rhs)
    {
        return lhs.get() >= rhs.get();
    }

    /// @brief Hashes the value given.
    friend ::std::size_t hash(const IndexingNamedType& v) noexcept
    {
        return ::std::hash(v.get());
    }

private:
    underlying_type value_; ///< Underlying value.
};

static_assert(std::is_default_constructible<IndexingNamedType<int, struct Test>>::value, "");
static_assert(std::is_nothrow_copy_constructible<IndexingNamedType<int, struct Test>>::value, "");
static_assert(std::is_nothrow_move_constructible<IndexingNamedType<int, struct Test>>::value, "");

/// @brief Gets the underlying value.
template <typename T, typename Tag>
constexpr T& UnderlyingValue(IndexingNamedType<T, Tag>& o) noexcept
{
    return static_cast<T&>(o);
}

/// @brief Gets the underlying value.
template <typename T, typename Tag>
constexpr const T& UnderlyingValue(const IndexingNamedType<T, Tag>& o) noexcept
{
    return static_cast<const T&>(o);
}

} // namespace detail
} // namespace playrho

namespace std {

/// @brief Custom specialization of std::hash for
///   <code>::playrho::detail::IndexingNamedType</code>.
template <typename T, typename Tag>
struct hash<::playrho::detail::IndexingNamedType<T, Tag>>
{
    /// @brief Hashing functor operator.
    ::std::size_t operator()(const ::playrho::detail::IndexingNamedType<T, Tag>& v) const noexcept
    {
        return ::std::hash<T>()(v.get());;
    }
};

} // namespace std

#endif // PLAYRHO_COMMON_INDEXINGNAMEDTYPE_HPP
