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

#ifndef PLAYRHO_COMMON_TEMPLATES_HPP
#define PLAYRHO_COMMON_TEMPLATES_HPP

#include "PlayRho/Defines.hpp"

#include <algorithm>
#include <functional>
#include <iterator>
#include <limits>
#include <type_traits>
#include <tuple>
#include <utility>

namespace playrho {

// Bring standard customization points into the namespace...
using std::begin;
using std::end;
using std::cbegin;
using std::cend;
using std::size;
using std::empty;
using std::data;
using std::swap;

namespace detail {

/// @brief Low-level implementation of the is-iterable default value trait.
template<class T, class = void>
struct IsIterableImpl: std::false_type {};

/// @brief Low-level implementation of the is-iterable true value trait.
template<class T>
struct IsIterableImpl<T, std::void_t<
    decltype(begin(std::declval<T>())),
    decltype(end(std::declval<T>())),
    decltype(++std::declval<decltype(begin(std::declval<T&>()))&>()),
    decltype(*begin(std::declval<T>()))
    >>:
    std::true_type
{};

/// @brief Gets the maximum size of the given container.
template <class T>
constexpr auto max_size(const T& arg) -> decltype(arg.max_size())
{
    return arg.max_size();
}

/// @brief Checks whether the given container is full.
template <class T>
constexpr auto IsFull(const T& arg) -> decltype(size(arg) == max_size(arg))
{
    return size(arg) == max_size(arg);
}

/// @brief Internal helper template function to avoid confusion for use within classes
///   that define their own <code>data()</code> method.
template <typename T>
static auto Data(T& v)
{
    using ::playrho::data;
    return data(v);
}

/// @brief Internal helper template function to avoid confusion for use within classes
///   that define their own <code>size()</code> method.
template <typename T>
static auto Size(T& v)
{
    using ::playrho::size;
    return size(v);
}

} // namespace detail
    
/// @brief "Not used" annotator.
template<class... T> void NOT_USED(T&&...){}

/// @brief Gets an invalid value for the type.
/// @tparam T Type to get an invalid value for.
/// @note Specialize this function for the types which have an invalid value concept.
/// @see IsValid.
template <typename T>
constexpr T GetInvalid() noexcept
{
    static_assert(sizeof(T) == 0, "No available specialization");
}

/// @brief Determines if the given value is valid.
/// @see GetInvalid.
template <typename T>
constexpr bool IsValid(const T& value) noexcept
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
    return value == value;
}

// GetInvalid template specializations.

/// @brief Gets an invalid value for the float type.
template <>
constexpr float GetInvalid() noexcept
{
    return std::numeric_limits<float>::signaling_NaN();
}

/// @brief Gets an invalid value for the double type.
template <>
constexpr double GetInvalid() noexcept
{
    return std::numeric_limits<double>::signaling_NaN();
}

/// @brief Gets an invalid value for the long double type.
template <>
constexpr long double GetInvalid() noexcept
{
    return std::numeric_limits<long double>::signaling_NaN();
}

/// @brief Gets an invalid value for the std::size_t type.
template <>
constexpr std::size_t GetInvalid() noexcept
{
    return static_cast<std::size_t>(-1);
}

// IsValid template specializations.

/// @brief Determines if the given value is valid.
template <>
constexpr bool IsValid(const std::size_t& value) noexcept
{
    return value != GetInvalid<std::size_t>();
}

// Other templates.

/// @brief Template for determining if the given type is an equality comparable type.
/// @note This isn't exactly the same as the "EqualityComparable" named requirement.
/// @see https://en.cppreference.com/w/cpp/named_req/EqualityComparable
template<class T1, class T2, class = void>
struct IsEqualityComparable: std::false_type {};

/// @brief Template specialization for equality comparable types.
template<class T1, class T2>
struct IsEqualityComparable<T1, T2, std::void_t<decltype(T1{} == T2{})> >: std::true_type {};

/// @brief Template for determining if the given type is an inequality comparable type.
template<class T1, class T2, class = void>
struct IsInequalityComparable: std::false_type {};

/// @brief Template specialization for inequality comparable types.
template<class T1, class T2>
struct IsInequalityComparable<T1, T2, std::void_t<decltype(T1{} != T2{})> >: std::true_type {};

/// @brief Template for determining if the given types are addable.
template<class T1, class T2 = T1, class = void>
struct IsAddable: std::false_type {};

/// @brief Template specializing for addable types.
template<class T1, class T2>
struct IsAddable<T1, T2, std::void_t<decltype(T1{} + T2{})> >: std::true_type {};

/// @brief Template for determining if the given types are multipliable.
template<class T1, class T2, class = void>
struct IsMultipliable: std::false_type {};

/// @brief Template specializing for multipliable types.
template<class T1, class T2>
struct IsMultipliable<T1, T2, std::void_t<decltype(T1{} * T2{})> >: std::true_type {};

/// @brief Template for determining if the given types are divisable.
template<class T1, class T2, class = void>
struct IsDivisable: std::false_type {};

/// @brief Template specializing for divisable types.
template<class T1, class T2>
struct IsDivisable<T1, T2, std::void_t<decltype(T1{} / T2{})> >: std::true_type {};

/// @brief Template for determining if the given type is an "arithmetic" type.
/// @note In the context of this library, "arithmetic" types are all types which
///   have +, -, *, / arithmetic operator support.
template<class T, class = void>
struct IsArithmetic: std::false_type {};

/// @brief Template specialization for valid/acceptable "arithmetic" types.
template<class T>
struct IsArithmetic<T, std::void_t<
    decltype(T{} + T{}), decltype(T{} - T{}), decltype(T{} * T{}), decltype(T{} / T{})
> >: std::true_type {};

/// @brief Determines whether the given type is an iterable type.
template<class T>
using IsIterable = typename detail::IsIterableImpl<T>;

/// @brief Has-type trait template class.
/// @note This is from Piotr Skotnicki's answer on the <em>StackOverflow</em> website
///   to the question of: "How do I find out if a tuple contains a type?".
/// @see https://stackoverflow.com/a/25958302/7410358
template <typename T, typename Tuple>
struct HasType;

/// @brief Has-type trait template class specialized for <code>std::tuple</code> classes.
/// @note This is from Piotr Skotnicki's answer on the <em>StackOverflow</em> website
///   to the question of: "How do I find out if a tuple contains a type?".
/// @see https://stackoverflow.com/a/25958302/7410358
template <typename T>
struct HasType<T, std::tuple<>> : std::false_type {};

/// @brief Has-type trait true class.
/// @note This is from Piotr Skotnicki's answer on the <em>StackOverflow</em> website
///   to the question of: "How do I find out if a tuple contains a type?".
/// @see https://stackoverflow.com/a/25958302/7410358
template <typename T, typename... Ts>
struct HasType<T, std::tuple<T, Ts...>> : std::true_type {};

/// @brief Has-type trait template super class.
/// @note This is from Piotr Skotnicki's answer on the <em>StackOverflow</em> website
///   to the question of: "How do I find out if a tuple contains a type?".
/// @see https://stackoverflow.com/a/25958302/7410358
template <typename T, typename U, typename... Ts>
struct HasType<T, std::tuple<U, Ts...>> : HasType<T, std::tuple<Ts...>> {};

/// @brief Tuple contains type alias.
/// @details Alias in case the trait itself should be <code>std::true_type</code> or
///   <code>std::false_type</code>.
/// @note This is from Piotr Skotnicki's answer on the <em>StackOverflow</em> website
///   to the question of: "How do I find out if a tuple contains a type?".
/// @see https://stackoverflow.com/a/25958302/7410358
template <typename T, typename Tuple>
using TupleContainsType = typename HasType<T, Tuple>::type;

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
struct LexicographicalLess
{
    /// @brief Checks whether the first argument is lexicographically less-than the
    ///   second argument.
    constexpr bool operator()(const T& lhs, const T& rhs) const
    {
        using std::less;
        using ElementType = decltype(*begin(lhs));
        return std::lexicographical_compare(begin(lhs), end(lhs), begin(rhs), end(rhs),
                                            less<ElementType>{});
    }
};

/// @brief Function object for performing lexicographical greater-than
///   comparisons of containers.
/// @see https://en.cppreference.com/w/cpp/algorithm/lexicographical_compare
/// @see https://en.cppreference.com/w/cpp/utility/functional/greater
template <typename T>
struct LexicographicalGreater
{
    /// @brief Checks whether the first argument is lexicographically greater-than the
    ///   second argument.
    constexpr bool operator()(const T& lhs, const T& rhs) const
    {
        using std::greater;
        using ElementType = decltype(*begin(lhs));
        return std::lexicographical_compare(begin(lhs), end(lhs), begin(rhs), end(rhs),
                                            greater<ElementType>{});
    }
};

/// @brief Function object for performing lexicographical less-than or equal-to
///   comparisons of containers.
/// @see https://en.cppreference.com/w/cpp/algorithm/lexicographical_compare
/// @see https://en.cppreference.com/w/cpp/utility/functional/less_equal
template <typename T>
struct LexicographicalLessEqual
{
    /// @brief Checks whether the first argument is lexicographically less-than or
    ///   equal-to the second argument.
    constexpr bool operator()(const T& lhs, const T& rhs) const
    {
        using std::mismatch;
        using std::less;
        using std::get;
        using ElementType = decltype(*begin(lhs));
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
struct LexicographicalGreaterEqual
{
    /// @brief Checks whether the first argument is lexicographically greater-than or
    ///   equal-to the second argument.
    constexpr bool operator()(const T& lhs, const T& rhs) const
    {
        using std::mismatch;
        using std::greater;
        using std::get;
        using ElementType = decltype(*begin(lhs));
        const auto lhsEnd = end(lhs);
        const auto diff = mismatch(begin(lhs), lhsEnd, begin(rhs), end(rhs));
        return (get<0>(diff) == lhsEnd) || greater<ElementType>{}(*get<0>(diff), *get<1>(diff));
    }
};

/// @brief Convenience template function for erasing first found value from container.
/// @return <code>true</code> if value was found and erased, <code>false</code> otherwise.
/// @see EraseAll.
template <typename T, typename U>
auto EraseFirst(T& container, const U& value) ->
    decltype(container.erase(find(begin(container), end(container), value)) != end(container))
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
auto EraseAll(T& container, const U& value) ->
    decltype(distance(container.erase(remove(begin(container), end(container), value), end(container)), end(container)))
{
    const auto itEnd = end(container);
    const auto it = remove(begin(container), itEnd, value);
    const auto count = distance(it, itEnd);
    container.erase(it, itEnd);
    return count;
}

/// @brief Has-functor trait template fallback class.
/// @note This is based off the answer by "jrok" on the <em>StackOverflow</em> website
///   to the question of: "Check if a class has a member function of a given signature".
/// @see https://stackoverflow.com/a/16824239/7410358
template <typename, typename T>
struct HasFunctor {
    static_assert(std::integral_constant<T, false>::value,
                  "Second template parameter needs to be of function type.");
};

/// @brief Has-functor trait template class.
/// @note This is based off the answer by "jrok" on the <em>StackOverflow</em> website
///   to the question of: "Check if a class has a member function of a given signature".
/// @see https://stackoverflow.com/a/16824239/7410358
template <typename Type, typename Return, typename... Args>
struct HasFunctor<Type, Return(Args...)> {
private:
    /// @brief Declaration of check function for supporting types given to template.
    template<typename T>
    static constexpr auto check(T*)
    -> typename std::is_same<decltype(std::declval<T>()(std::declval<Args>()...)),Return>::type;

    /// @brief Declaration of check function for non-supporting types given to template.
    template<typename>
    static constexpr std::false_type check(...);

    /// @brief Type alias for given template parameters.
    using type = decltype(check<Type>(0));

public:
    /// Whether or not the given type has the specified functor.
    static constexpr auto value = type::value;
};

/// @brief Has nullary functor type alias.
/// @see HasUnaryFunctor.
template <typename Type, typename Return>
using HasNullaryFunctor = HasFunctor<Type,Return()>;

/// @brief Has unary functor type alias.
/// @see HasNullaryFunctor.
template <typename Type, typename Return, typename Arg>
using HasUnaryFunctor = HasFunctor<Type,Return(Arg)>;

} // namespace playrho

#endif // PLAYRHO_COMMON_TEMPLATES_HPP
