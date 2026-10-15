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

#ifndef PLAYRHO_TEMPLATES_HPP
#define PLAYRHO_TEMPLATES_HPP

/// @file
/// @brief Definitions of miscellaneous template related code.

#include <cstdlib> // for std::size_t
#include <type_traits> // for std::enable_if_t

// IWYU pragma: begin_exports

#include "playrho/detail/Templates.hpp"

// IWYU pragma: end_exports

namespace playrho {

/// @brief Determines if the given value is valid, using the equality operator.
/// @details Any value for which the comparison of that value with itself is @c true
///   is considered valid by this function, and any value for which this comparison is
///   @c false is said to be not valid. If this seems like an odd algorithm, be aware
///   that this is essentially how floating point @c NaN (not-a-number) works.
/// @see https://en.wikipedia.org/wiki/NaN
template <typename T>
constexpr auto IsValid(const T& value) noexcept -> bool
{
    // Note: This is not necessarily a no-op!! But it is a "constexpr".
    //
    // From http://en.cppreference.com/w/cpp/numeric/math/isnan:
    //   "Another way to test if a floating-point value is NaN is
    //    to compare it with itself:
    //      bool is_nan(double x) { return x != x; }
    //
    // So for all T, for which isnan() is implemented, this should work
    // correctly and quite usefully!
    //
    return value == value; // NOLINT(misc-redundant-expression)
}

/// @brief Determines if the given value is valid.
constexpr auto IsValid(std::size_t value) noexcept -> bool
{
    return value != static_cast<std::size_t>(-1);
}

// Other templates.

/// @brief Determines whether the given type is an iterable type.
template <class T>
inline constexpr bool IsIterableV = detail::IsIterable<T>::value;

/// @brief Determines whether the given type is a reverse iterable type.
template <class T>
inline constexpr bool IsReverseIterableV = detail::IsReverseIterable<T>::value;

/// @brief Determines whether the given types are equality comparable.
template <class T1, class T2 = T1>
inline constexpr bool IsEqualityComparableV = detail::IsEqualityComparable<T1, T2>::value;

/// @brief Determines whether the given types are inequality comparable.
template <class T1, class T2 = T1>
inline constexpr bool IsInequalityComparableV = detail::IsInequalityComparable<T1, T2>::value;

/// @brief Determines whether the given type is an addable type.
template <class T1, class T2 = T1>
inline constexpr bool IsAddableV = detail::IsAddable<T1, T2>::value;

/// @brief Determines whether the given type is a multipliable type.
template <class T1, class T2 = T1>
inline constexpr bool IsMultipliableV = detail::IsMultipliable<T1, T2>::value;

/// @brief Determines whether the given type is a divisible type.
template <class T1, class T2 = T1>
inline constexpr bool IsDivisableV = detail::IsDivisable<T1, T2>::value;

/// @brief Determines whether the given type is an arithmetic type.
template< class T >
inline constexpr bool IsArithmeticV = detail::IsArithmetic<T>::value;

/// @brief Wrapper for reversing ranged-for loop ordering.
/// @warning This won't lifetime extend the iterable variable!
/// @see https://stackoverflow.com/a/28139075/7410358
template <typename T>
struct ReversionWrapper {
    /// @brief Reference to underlying iterable.
    T& iterable; // NOLINT(cppcoreguidelines-avoid-const-or-ref-data-members)
};

/// @brief Begin function for getting a reversed order iterator.
template <typename T>
auto begin(ReversionWrapper<T> w)
{
    return std::rbegin(w.iterable);
}

/// @brief End function for getting a reversed order iterator.
template <typename T>
auto end(ReversionWrapper<T> w)
{
    return std::rend(w.iterable);
}

/// @brief Gets a reversed order iterated wrapper.
/// @see https://stackoverflow.com/a/28139075/7410358
template <typename T>
std::enable_if_t<IsReverseIterableV<T>, ReversionWrapper<T>> Reverse(T&& iterable)
{
    return {std::forward<T>(iterable)};
}

/// @brief Alias for pulling the <code>max_size</code> constomization point into the
///   playrho namesapce.
using detail::max_size;

/// @brief Alias for pulling the <code>IsFull</code> constomization point into the
///   playrho namesapce.
using detail::IsFull;

/// @brief Function object for performing lexicographical less-than
///   comparisons of containers.
/// @see https://en.cppreference.com/w/cpp/algorithm/lexicographical_compare
/// @see https://en.cppreference.com/w/cpp/utility/functional/less
template <typename T>
struct LexicographicalLess {
    /// @brief Checks whether the first argument is lexicographically less-than the
    ///   second argument.
    constexpr auto operator()(const T& lhs, const T& rhs) const ->
        decltype(std::lexicographical_compare(begin(lhs), end(lhs), begin(rhs), end(rhs)), true)
    {
        using std::less;
        using ElementType = std::decay_t<decltype(*begin(lhs))>;
        return std::lexicographical_compare(begin(lhs), end(lhs), begin(rhs), end(rhs),
                                            less<ElementType>{});
    }
};

/// @brief Function object for performing lexicographical greater-than
///   comparisons of containers.
/// @see https://en.cppreference.com/w/cpp/algorithm/lexicographical_compare
/// @see https://en.cppreference.com/w/cpp/utility/functional/greater
template <typename T>
struct LexicographicalGreater {
    /// @brief Checks whether the first argument is lexicographically greater-than the
    ///   second argument.
    constexpr auto operator()(const T& lhs, const T& rhs) const ->
        decltype(std::lexicographical_compare(begin(lhs), end(lhs), begin(rhs), end(rhs)), true)
    {
        using std::greater;
        using ElementType = std::decay_t<decltype(*begin(lhs))>;
        return std::lexicographical_compare(begin(lhs), end(lhs), begin(rhs), end(rhs),
                                            greater<ElementType>{});
    }
};

/// @brief Function object for performing lexicographical less-than or equal-to
///   comparisons of containers.
/// @see https://en.cppreference.com/w/cpp/algorithm/lexicographical_compare
/// @see https://en.cppreference.com/w/cpp/utility/functional/less_equal
template <typename T>
struct LexicographicalLessEqual {
    /// @brief Checks whether the first argument is lexicographically less-than or
    ///   equal-to the second argument.
    constexpr auto operator()(const T& lhs, const T& rhs) const ->
        decltype(std::mismatch(begin(lhs), end(lhs), begin(rhs), end(rhs)), true)
    {
        using std::get;
        using std::less;
        using std::mismatch;
        using ElementType = std::decay_t<decltype(*begin(lhs))>;
        const auto lhsEnd = end(lhs);
        const auto diff = mismatch(begin(lhs), lhsEnd, begin(rhs), end(rhs));
        return (get<0>(diff) == lhsEnd) || less<ElementType>{}(*get<0>(diff), *get<1>(diff));
    }
};

/// @brief Function object for performing lexicographical greater-than or equal-to
///   comparisons of containers.
/// @see https://en.cppreference.com/w/cpp/algorithm/lexicographical_compare
/// @see https://en.cppreference.com/w/cpp/utility/functional/greater_equal
template <typename T>
struct LexicographicalGreaterEqual {
    /// @brief Checks whether the first argument is lexicographically greater-than or
    ///   equal-to the second argument.
    constexpr auto operator()(const T& lhs, const T& rhs) const ->
        decltype(std::mismatch(begin(lhs), end(lhs), begin(rhs), end(rhs)), true)
    {
        using std::get;
        using std::greater;
        using std::mismatch;
        using ElementType = std::decay_t<decltype(*begin(lhs))>;
        const auto lhsEnd = end(lhs);
        const auto diff = mismatch(begin(lhs), lhsEnd, begin(rhs), end(rhs));
        return (get<0>(diff) == lhsEnd) || greater<ElementType>{}(*get<0>(diff), *get<1>(diff));
    }
};

/// @brief Convenience template function for erasing first found value from container.
/// @return <code>true</code> if value was found and erased, <code>false</code> otherwise.
/// @see EraseAll.
template <typename T, typename U>
auto EraseFirst(T& container, const U& value)
    -> decltype(container.erase(find(begin(container), end(container), value)) != end(container))
{
    const auto endIt = end(container);
    const auto it = find(begin(container), endIt, value);
    if (it != endIt) {
        container.erase(it);
        return true;
    }
    return false;
}

/// @brief Convenience template function for erasing specified value from container.
/// @note This basically is the C++20 <code>std::erase</code> function.
/// @return Count of elements erased.
/// @see EraseFirst.
template <typename T, typename U>
auto EraseAll(T& container, const U& value)
    -> decltype(distance(container.erase(remove(begin(container), end(container), value),
                                         end(container)),
                         end(container)))
{
    const auto itEnd = end(container);
    const auto it = remove(begin(container), itEnd, value);
    const auto count = distance(it, itEnd);
    container.erase(it, itEnd);
    return count;
}

/// @brief Has nullary functor type alias.
/// @see HasUnaryFunctor.
template <typename Type, typename Return>
using HasNullaryFunctor = detail::HasFunctor<Type, Return()>;

/// @brief Has unary functor type alias.
/// @see HasNullaryFunctor.
template <typename Type, typename Return, typename Arg>
using HasUnaryFunctor = detail::HasFunctor<Type, Return(Arg)>;

/// @brief Decayed type if not same as the checked type.
/// @note This is done separately from other checks to ensure order of compiler's SFINAE
///   processing and to ensure elimination of check class before attempting to process other
///   checks like is_copy_constructible_v. This prevents a compiler error that started showing
///   up in gcc-9.
template <typename Type, typename Check, typename DecayedType = std::decay_t<Type>>
using DecayedTypeIfNotSame = std::enable_if_t<!std::is_same_v<DecayedType, Check>, DecayedType>;

/// @brief A pre-C++20 constant expression implementation of <code>std::equal</code>.
/// @see https://en.cppreference.com/w/cpp/algorithm/equal
template <class InputIt1, class InputIt2>
constexpr auto Equal(InputIt1 first1, InputIt1 last1,
                     InputIt2 first2, InputIt2 last2)
    -> decltype(first1 == last1, first2 == last2, ++first1, ++first2, *first1 == *first2)
{
    while (true) {
        if ((first1 == last1) && (first2 == last2)) {
            return true;
        }
        if ((first1 == last1) || (first2 == last2)) {
            return false;
        }
        if (!(*first1 == *first2)) {
            return false;
        }
        ++first1;
        ++first2;
    }
}

} // namespace playrho

#endif // PLAYRHO_TEMPLATES_HPP
