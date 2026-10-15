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

#ifndef PLAYRHO_INTERVAL_HPP
#define PLAYRHO_INTERVAL_HPP

/// @file
/// @brief Definition of the @c Interval class template and closely related code.

#include <algorithm>
#include <limits> // for std::numeric_limits
#include <initializer_list>
#include <iostream>
#include <type_traits> // for std::is_nothrow_copy_constructible_v
#include <utility> // for std::pair

// IWYU pragma: begin_exports

#include "playrho/NonNegative.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Interval template type.
/// @details This type encapsulates an interval as a min-max value range relationship.
/// @invariant The min and max values can only be the result of
///   <code>std::minmax(a, b)</code> or the special values of the "highest" and
///   "lowest" values supported by the type for this class respectively indicating
///   the "unset" value.
/// @see https://en.wikipedia.org/wiki/Interval_(mathematics)
template <typename T>
class Interval
{
public:
    static_assert(std::is_copy_constructible_v<T>);
    static_assert(std::numeric_limits<T>::is_specialized);

    /// @brief Value type.
    /// @details Alias for the type of the value that this class was template
    ///   instantiated for.
    using value_type = T;

    /// @brief Gets the "lowest" value supported by the <code>value_type</code>.
    /// @return Negative infinity if supported by the value type, limits::lowest()
    ///   otherwise.
    static constexpr value_type GetLowest()
        noexcept(noexcept(limits::infinity()) && noexcept(limits::lowest()))
    {
        return limits::has_infinity? -limits::infinity(): limits::lowest();
    }
    
    /// @brief Gets the "highest" value supported by the <code>value_type</code>.
    /// @return Positive infinity if supported by the value type, limits::max()
    ///   otherwise.
    static constexpr value_type GetHighest()
        noexcept(noexcept(limits::infinity()) && noexcept(limits::max()))
    {
        return limits::has_infinity? limits::infinity(): limits::max();
    }

    /// @brief Default constructor.
    /// @details Constructs an "unset" interval.
    /// @post <code>GetMin()</code> returns the value of <code>GetHighest()</code>.
    /// @post <code>GetMax()</code> returns the value of <code>GetLowest()</code>.
    constexpr Interval() noexcept(noexcept(std::is_nothrow_move_constructible_v<T>)) = default;
    
    /// @brief Initializing constructor.
    /// @details Constructs an interval of a single value.
    /// @post <code>GetMin()</code> returns the value of <code>v</code>.
    /// @post <code>GetMax()</code> returns the value of <code>v</code>.
    constexpr explicit Interval(const value_type& v)
        noexcept(noexcept(Interval{pair_type{v, v}})):
        Interval{pair_type{v, v}}
    {
        // Intentionally empty.
    }
    
    /// @brief Initializing constructor.
    /// @details Constructs an interval of two values.
    /// @post <code>GetMin()</code> returns min of @p a and @p b.
    /// @post <code>GetMax()</code> returns max of @p a and @p b.
    constexpr Interval(const value_type& a, const value_type& b)
        noexcept(noexcept(Interval{std::minmax(a, b)})):
        Interval{std::minmax(a, b)}
    {
        // Intentionally empty.
    }
    
    /// @brief Initializing constructor.
    /// @details Constructs an interval of the min and max of a list of values.
    /// @post <code>GetMin()</code> returns min of @p ilist.
    /// @post <code>GetMax()</code> returns max of @p ilist.
    constexpr Interval(const std::initializer_list<T>& ilist)
        noexcept(noexcept(Interval{std::minmax(ilist)})):
        Interval{std::minmax(ilist)}
    {
        // Intentionally empty.
    }

    /// @brief Gets the minimum value of this range.
    constexpr value_type GetMin() const noexcept
    {
        return m_min;
    }

    /// @brief Gets the maximum value of this range.
    constexpr value_type GetMax() const noexcept
    {
        return m_max;
    }

    /// @brief Moves the interval by the given amount.
    /// @note This function is either non-throwing or offers the "strong exception guarantee". It has no effect on the interval if it throws.
    constexpr Interval& Move(const value_type& v)
        noexcept(noexcept(*this + v) && std::is_nothrow_copy_assignable_v<Interval>)
    {
        *this = *this + v;
        return *this;
    }

    /// @brief Includes the given value into this interval.
    /// @note This function is either non-throwing or offers the "strong exception guarantee". It has no effect on the interval if it throws.
    /// @note If this value is the "unset" value then the result of this operation will be the given value.
    /// @param v Value to "include" into this value.
    /// @post This value's "min" is the minimum of the given value and this value's "min".
    constexpr Interval& Include(const value_type& v)
        noexcept(noexcept(Interval{pair_type{std::min(v, GetMin()), std::max(v, GetMax())}}) &&
                 std::is_nothrow_move_assignable_v<Interval>)
    {
        *this = Interval{pair_type{std::min(v, GetMin()), std::max(v, GetMax())}};
        return *this;
    }
    
    /// @brief Includes the given interval into this interval.
    /// @note If this value is the "unset" value then the result of this operation will be the given value.
    /// @note This function is either non-throwing or offers the "strong exception guarantee". It has no effect on the interval if it throws.
    /// @param v Value to "include" into this value.
    /// @post This value's "min" is the minimum of the given value's "min" and
    ///   this value's "min".
    constexpr Interval& Include(const Interval& v)
        noexcept(noexcept(Interval{pair_type{std::min(v.GetMin(), GetMin()), std::max(v.GetMax(), GetMax())}}) &&
                 std::is_nothrow_move_assignable_v<Interval>)
    {
        *this = Interval{pair_type{std::min(v.GetMin(), GetMin()), std::max(v.GetMax(), GetMax())}};
        return *this;
    }
    
    /// @brief Intersects this interval with the given interval.
    /// @note This function is either non-throwing or offers the "strong exception guarantee". It has no effect on the interval if it throws.
    constexpr Interval& Intersect(const Interval& v)
        noexcept(noexcept(Interval{pair_type{std::max(v.GetMin(), GetMin()), std::min(v.GetMax(), GetMax())}}) &&
                 std::is_nothrow_move_assignable_v<Interval>)
    {
        const auto min = std::max(v.GetMin(), GetMin());
        const auto max = std::min(v.GetMax(), GetMax());
        *this = (min <= max)? Interval{pair_type{min, max}}: Interval{};
        return *this;
    }
    
    /// @brief Expands this interval.
    /// @details Expands this interval by decreasing the min value if the
    ///   given value is negative, or by increasing the max value if the
    ///   given value is positive.
    /// @param v Amount to expand this interval by.
    /// @note This function is either non-throwing or offers the "strong exception guarantee". It has no effect on the interval if it throws.
    /// @warning Behavior is not specified if expanding the range by
    ///   the given amount overflows the range of the <code>value_type</code>,
    constexpr Interval& Expand(const value_type& v) noexcept(noexcept(m_min += v) && noexcept(m_max += v))
    {
        if constexpr (!limits::has_infinity) {
            if (*this == Interval{}) {
                return *this;
            }
        }
        if (v < value_type{}) {
            m_min += v;
        }
        else {
            m_max += v;
        }
        return *this;
    }
    
    /// @brief Expands equally both ends of this interval.
    /// @details Expands equally this interval by decreasing the min value and
    ///   by increasing the max value by the given amount.
    /// @note This operation has no effect if this interval is "unset".
    /// @param v Amount to expand both ends of this interval by.
    /// @note This function is either non-throwing or offers the "strong exception guarantee". It has no effect on the interval if it throws.
    /// @warning Behavior is not specified if expanding the range by
    ///   the given amount overflows the range of the <code>value_type</code>,
    constexpr Interval& ExpandEqually(const NonNegative<value_type>& v)
        noexcept(noexcept(Interval{pair_type{m_min - value_type{v}, m_max + value_type{v}}}) &&
                 std::is_nothrow_move_assignable_v<Interval>)
    {
        if constexpr (!limits::has_infinity) {
            if (*this == Interval{}) {
                return *this;
            }
        }
        const auto amount = value_type{v};
        *this = Interval{pair_type{m_min - amount, m_max + amount}};
        return *this;
    }
    
private:
    /// @brief Limits alias for the <code>value_type</code>.
    using limits = std::numeric_limits<value_type>;

    /// @brief Internal pair type.
    /// @note Uses <code>std::pair</code> since it's the most natural type given that
    ///   <code>std::minmax</code> returns it.
    using pair_type = std::pair<value_type, value_type>;
    
    /// @brief Internal pair type accepting constructor.
    constexpr explicit Interval(pair_type pair)
        noexcept(std::is_nothrow_copy_constructible_v<value_type>):
        m_min{std::get<0>(pair)}, m_max{std::get<1>(pair)}
    {
        // Intentionally empty.
    }

    /// @brief Addition operator support.
    constexpr Interval operator+(const value_type& amount)
        noexcept(noexcept(Interval{pair_type{m_min + amount, m_max + amount}}) &&
                 std::is_nothrow_move_assignable_v<Interval>)
    {
        if constexpr (!limits::has_infinity) {
            if (*this == Interval{}) {
                return *this;
            }
        }
        return Interval{pair_type{m_min + amount, m_max + amount}};
    }

    value_type m_min = GetHighest(); ///< Min value.
    value_type m_max = GetLowest(); ///< Max value.
};

// Recognize and confirm type expectations...
static_assert(std::is_nothrow_default_constructible_v<Interval<float>>);
static_assert(std::is_nothrow_copy_constructible_v<Interval<float>>);
static_assert(std::is_nothrow_copy_assignable_v<Interval<float>>);
static_assert(std::is_nothrow_move_constructible_v<Interval<float>>);
static_assert(std::is_nothrow_move_assignable_v<Interval<float>>);

/// @brief Gets the size of the given interval.
/// @details Gets the difference between the max and min values.
/// @pre The difference between the given interval's max and min is representable
///   by <code>Interval::value_type</code>.
/// @return Non-negative value unless the given interval is "unset" or invalid.
template <typename T, typename U = decltype(Interval<T>{}, (T{} - T{}))>
constexpr auto GetSize(const Interval<T>& v) noexcept(noexcept(v.GetMax() - v.GetMin()))
{
    return v.GetMax() - v.GetMin();
}

/// @brief Gets the center of the given interval.
/// @warning Behavior is not specified if the difference between the given range's
///   max and min values overflows the range of the <code>Interval::value_type</code>.
/// @relatedalso Interval
template <typename T, typename U = decltype(Interval<T>{}, ((T{} + T{}) / 2))>
constexpr auto GetCenter(const Interval<T>& v) noexcept(noexcept((v.GetMin() + v.GetMax()) / 2))
{
    // Rounding may cause issues...
    return (v.GetMin() + v.GetMax()) / 2;
}

/// @brief Checks whether two value ranges have any intersection/overlap at all.
/// @note <code>a</code> intersects with <code>b</code> if and only if any value of <code>a</code>
///   is also a value of <code>b</code>.
/// @relatedalso Interval
template <typename T, typename U = decltype(Interval<T>{}, T{} < T{}, T{} >= T{})>
constexpr bool IsIntersecting(const Interval<T>& a, const Interval<T>& b)
    noexcept(noexcept(T{} < T{}) && noexcept(T{} >= T{}))
{
    const auto maxOfMins = std::max(a.GetMin(), b.GetMin());
    const auto minOfMaxs = std::min(a.GetMax(), b.GetMax());
    return minOfMaxs >= maxOfMins;
}

/// @brief Gets the intersecting interval of two given ranges.
/// @relatedalso Interval
template <typename T>
constexpr Interval<T> GetIntersection(Interval<T> a, const Interval<T>& b) noexcept
{
    return a.Intersect(b);
}

/// @brief Determines whether the first range is entirely before the second range.
template <typename T>
constexpr bool IsEntirelyBefore(const Interval<T>& a, const Interval<T>& b)
{
    return a.GetMax() < b.GetMin();
}

/// @brief Determines whether the first range is entirely after the second range.
template <typename T>
constexpr bool IsEntirelyAfter(const Interval<T>& a, const Interval<T>& b)
{
    return a.GetMin() > b.GetMax();
}

/// @brief Determines whether the first range entirely encloses the second.
template <typename T>
constexpr bool IsEntirelyEnclosing(const Interval<T>& a, const Interval<T>& b)
{
    return a.GetMin() <= b.GetMin() && a.GetMax() >= b.GetMax();
}

/// @brief Equality operator.
/// @note Satisfies the <code>EqualityComparable</code> named requirement for Interval objects.
/// @relatedalso Interval
/// @see https://en.cppreference.com/w/cpp/named_req/EqualityComparable
template <typename T>
constexpr bool operator== (const Interval<T>& a, const Interval<T>& b) noexcept
{
    return (a.GetMin() == b.GetMin()) && (a.GetMax() == b.GetMax());
}

/// @brief Inequality operator.
/// @note Satisfies the <code>EqualityComparable</code> named requirement for Interval objects.
/// @relatedalso Interval
/// @see https://en.cppreference.com/w/cpp/named_req/EqualityComparable
template <typename T>
constexpr bool operator!= (const Interval<T>& a, const Interval<T>& b) noexcept
{
    return !(a == b);
}

/// @brief Less-than operator.
/// @note Provides a "strict weak ordering" relation.
/// @note This is a lexicographical comparison.
/// @note Obeys the <code>LessThanComparable</code> named requirement:
///   <code>for all a, !(a < a); if (a < b) then !(b < a); if (a < b) and (b < c)
///   then (a < c); with equiv = !(a < b) && !(b < a), if equiv(a, b) and equiv(b, c),
///   then equiv(a, c).</code>
/// @relatedalso Interval
/// @see https://en.wikipedia.org/wiki/Weak_ordering#Strict_weak_orderings
/// @see https://en.cppreference.com/w/cpp/named_req/LessThanComparable
template <typename T>
constexpr bool operator< (const Interval<T>& lhs, const Interval<T>& rhs) noexcept
{
    return (lhs.GetMin() < rhs.GetMin()) ||
        (lhs.GetMin() == rhs.GetMin() && lhs.GetMax() < rhs.GetMax());
}

/// @brief Less-than or equal-to operator.
/// @note Provides a "strict weak ordering" relation.
/// @note This is a lexicographical comparison.
/// @relatedalso Interval
/// @see https://en.wikipedia.org/wiki/Weak_ordering#Strict_weak_orderings
template <typename T>
constexpr bool operator<= (const Interval<T>& lhs, const Interval<T>& rhs) noexcept
{
    return (lhs.GetMin() < rhs.GetMin()) ||
        (lhs.GetMin() == rhs.GetMin() && lhs.GetMax() <= rhs.GetMax());
}

/// @brief Greater-than operator.
/// @note Provides a "strict weak ordering" relation.
/// @note This is a lexicographical comparison.
/// @relatedalso Interval
/// @see https://en.wikipedia.org/wiki/Weak_ordering#Strict_weak_orderings
template <typename T>
constexpr bool operator> (const Interval<T>& lhs, const Interval<T>& rhs) noexcept
{
    return (lhs.GetMin() > rhs.GetMin()) ||
        (lhs.GetMin() == rhs.GetMin() && lhs.GetMax() > rhs.GetMax());
}

/// @brief Greater-than or equal-to operator.
/// @note Provides a "strict weak ordering" relation.
/// @note This is a lexicographical comparison.
/// @relatedalso Interval
/// @see https://en.wikipedia.org/wiki/Weak_ordering#Strict_weak_orderings
template <typename T>
constexpr bool operator>= (const Interval<T>& lhs, const Interval<T>& rhs) noexcept
{
    return (lhs.GetMin() > rhs.GetMin()) ||
        (lhs.GetMin() == rhs.GetMin() && lhs.GetMax() >= rhs.GetMax());
}

/// @brief Output stream operator.
template <typename T>
::std::ostream& operator<< (::std::ostream& os, const Interval<T>& value)
{
    return os << '{' << value.GetMin() << "..." << value.GetMax() << '}';
}

} // namespace playrho

#endif // PLAYRHO_INTERVAL_HPP
