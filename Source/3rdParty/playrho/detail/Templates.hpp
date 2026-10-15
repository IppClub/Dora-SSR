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

#ifndef PLAYRHO_DETAIL_TEMPLATES_HPP
#define PLAYRHO_DETAIL_TEMPLATES_HPP

/// @file
/// @brief Low-level declarations for general class & function templates.

// IWYU pragma: private, include "playrho/Templates.hpp"

#include <algorithm>
#include <iterator>
#include <type_traits>
#include <utility> // for std::declval

namespace playrho {

// Bring standard customization points into the namespace...
using std::begin; // NOLINT(misc-unused-using-decls)
using std::cbegin; // NOLINT(misc-unused-using-decls)
using std::cend; // NOLINT(misc-unused-using-decls)
using std::data; // NOLINT(misc-unused-using-decls)
using std::empty; // NOLINT(misc-unused-using-decls)
using std::end; // NOLINT(misc-unused-using-decls)
using std::size; // NOLINT(misc-unused-using-decls)
using std::swap; // NOLINT(misc-unused-using-decls)

namespace detail {

/// @brief Low-level implementation of the is-iterable default value trait.
template <class T, class = void>
struct IsIterable : std::false_type {
};

/// @brief Low-level implementation of the is-iterable true value trait.
template <class T>
struct IsIterable<
    T, std::void_t<decltype(begin(std::declval<T>())), decltype(end(std::declval<T>())),
                   decltype(++std::declval<decltype(begin(std::declval<T&>()))&>()),
                   decltype(*begin(std::declval<T>()))>> : std::true_type {
};

/// @brief Low-level implementation of the is-reverse-iterable default value trait.
template <class T, class = void>
struct IsReverseIterable : std::false_type {
};

/// @brief Low-level implementation of the is-reverse-iterable true value trait.
template <class T>
struct IsReverseIterable<
    T, std::void_t<decltype(rbegin(std::declval<T>())), decltype(rend(std::declval<T>())),
                   decltype(++std::declval<decltype(rbegin(std::declval<T&>()))&>()),
                   decltype(*rbegin(std::declval<T>()))>> : std::true_type {
};

/// @brief Template for determining if the given type is an equality comparable type.
/// @note This isn't exactly the same as the "EqualityComparable" named requirement.
/// @see https://en.cppreference.com/w/cpp/named_req/EqualityComparable
template <class T1, class T2, class = void>
struct IsEqualityComparable : std::false_type {
};

/// @brief Template specialization for equality comparable types.
template <class T1, class T2>
struct IsEqualityComparable<T1, T2, std::void_t<decltype(T1{} == T2{})>> : std::true_type {
};

/// @brief Template for determining if the given type is an inequality comparable type.
template <class T1, class T2, class = void>
struct IsInequalityComparable : std::false_type {
};

/// @brief Template specialization for inequality comparable types.
template <class T1, class T2>
struct IsInequalityComparable<T1, T2, std::void_t<decltype(T1{} != T2{})>> : std::true_type {
};

/// @brief Template for determining if the given types are addable.
template <class T1, class T2 = T1, class = void>
struct IsAddable : std::false_type {
};

/// @brief Template specializing for addable types.
template <class T1, class T2>
struct IsAddable<T1, T2, std::void_t<decltype(T1{} + T2{})>> : std::true_type {
};

/// @brief Template for determining if the given types are multipliable.
template <class T1, class T2, class = void>
struct IsMultipliable : std::false_type {
};

/// @brief Template specializing for multipliable types.
template <class T1, class T2>
struct IsMultipliable<T1, T2, std::void_t<decltype(T1{} * T2{})>> : std::true_type {
};

/// @brief Template for determining if the given types are divisable.
template <class T1, class T2, class = void>
struct IsDivisable : std::false_type {
};

/// @brief Template specializing for divisable types.
template <class T1, class T2>
struct IsDivisable<T1, T2, std::void_t<decltype(T1{} / T2{})>> : std::true_type {
};

/// @brief Template for determining if the given type is an "arithmetic" type.
/// @note In the context of this library, "arithmetic" types are all types which
///   have +, -, *, / arithmetic operator support.
template <class T, class = void>
struct IsArithmetic : std::false_type {
};

/// @brief Template specialization for valid/acceptable "arithmetic" types.
template <class T>
struct IsArithmetic<T, std::void_t<decltype(T{} + T{}), decltype(T{} - T{}), decltype(T{} * T{}),
                                   decltype(T{} / T{})>> : std::true_type {
};

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
    template <typename T>
    static constexpr auto check(T*) ->
        typename std::is_convertible<decltype(std::declval<T>()(std::declval<Args>()...)), Return>::type;

    /// @brief Declaration of check function for non-supporting types given to template.
    template <typename>
    static constexpr std::false_type check(...);

    /// @brief Type alias for given template parameters.
    using type = decltype(check<Type>(nullptr)); // NOLINT(cppcoreguidelines-pro-type-vararg)

public:
    /// Whether or not the given type has the specified functor.
    static constexpr auto value = type::value;
};

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

/// @brief None such type.
/// @see https://en.cppreference.com/w/cpp/experimental/is_detected
struct nonesuch {
    nonesuch() = delete;
    ~nonesuch() = delete;
    nonesuch(nonesuch const&) = delete;
    void operator=(nonesuch const&) = delete;
};

/// @brief Detector class template.
/// @see https://en.cppreference.com/w/cpp/experimental/is_detected
template<class Default, class AlwaysVoid, template<class...> class Op, class... Args>
struct detector
{
    /// @brief Value type.
    using value_t = std::false_type;

    /// @brief Default type.
    using type = Default;
};

/// @brief Detected class template specialized for successful detection.
/// @see https://en.cppreference.com/w/cpp/experimental/is_detected
template<class Default, template<class...> class Op, class... Args>
struct detector<Default, std::void_t<Op<Args...>>, Op, Args...>
{
    /// @brief Value type.
    using value_t = std::true_type;

    /// @brief Specialized type.
    using type = Op<Args...>;
};

/// @brief Is-detected value type.
/// @see https://en.cppreference.com/w/cpp/experimental/is_detected
template<template<class...> class Op, class... Args>
using is_detected = typename detector<nonesuch, void, Op, Args...>::value_t;

/// @brief Is-detected-value.
/// @see https://en.cppreference.com/w/cpp/experimental/is_detected
template< template<class...> class Op, class... Args >
constexpr bool is_detected_v = is_detected<Op, Args...>::value;

/// @brief Is narrowing conversion implementation true trait.
/// @see https://stackoverflow.com/a/67603594/7410358.
template<typename From, typename To, typename = void>
struct is_narrowing_conversion_impl : std::true_type {};

/// @brief Is narrowing conversion implementation false trait.
/// @see https://stackoverflow.com/a/67603594/7410358.
template<typename From, typename To>
struct is_narrowing_conversion_impl<From, To, std::void_t<decltype(To{std::declval<From>()})>> : std::false_type {};

/// @brief Is narrowing conversion trait.
/// @see https://stackoverflow.com/a/67603594/7410358.
template<typename From, typename To>
struct is_narrowing_conversion : is_narrowing_conversion_impl<From, To> {};

} // namespace detail

} // namespace playrho

#endif // PLAYRHO_DETAIL_TEMPLATES_HPP
