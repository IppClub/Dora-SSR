//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _STD_TYPE_TRAITS_EXT_H_
#define _STD_TYPE_TRAITS_EXT_H_

#include <cstddef>
#include <type_traits>

namespace std
{

// select the type, if true select the former, otherwise select the latter
template <bool E, typename TT, typename FT>
struct select_if;

template <typename TT, typename FT>
struct select_if<true, TT, FT>
{
    using type = TT;
};

template <typename TT, typename FT>
struct select_if<false, TT, FT>
{
    using type = FT;
};

template <bool E, typename TT, typename FT>
using select_if_t = typename select_if<E, TT, FT>::type;

// select the type, select by index
template <size_t N, typename... Ts>
struct select_idx;

template <size_t N, typename T, typename... Ts>
struct select_idx<N, T, Ts...>
{
    using type = typename select_idx<N - 1, Ts...>::type;
};

template <typename T, typename... Ts>
struct select_idx<0, T, Ts...>
{
    using type = T;
};

template <size_t N, typename... Ts>
using select_idx_t = typename select_idx<N, Ts...>::type;

// comparing multiple types, if they are all the same, is true, otherwise, is false
template <class... Tps>
inline bool is_same_vs;

template <class Tp1, class Tp2, class... Tps>
inline constexpr bool is_same_vs<Tp1, Tp2, Tps...> = is_same_vs<Tp1, Tp2> && is_same_vs<Tp2, Tps...>;

template <class Tp, class Up>
inline constexpr bool is_same_vs<Tp, Up> = is_same_v<Tp, Up>;

template <class Tp>
inline constexpr bool is_same_vs<Tp> = true;

template <>
inline constexpr bool is_same_vs<> = true;

// comparing multiple types, if same type exists in them, is true, otherwise, is false
template <class... Tps>
inline bool is_exist_same_vs;

template <class Tp, class... Tps>
inline constexpr bool is_exist_same_vs<Tp, Tps...> = (is_same_v<Tp, Tps> || ...) || is_exist_same_vs<Tps...>;

template <class Tp>
inline constexpr bool is_exist_same_vs<Tp> = false;

template <>
inline constexpr bool is_exist_same_vs<> = false;

// comparing tow templates
template <template <typename...> class Tp, template <typename...> class Up>
struct is_template_same : false_type
{
};

template <template <typename...> class Tp>
struct is_template_same<Tp, Tp> : true_type
{
};

template <template <typename...> class Tp, template <typename...> class Up>
inline constexpr bool is_template_same_v = is_template_same<Tp, Up>::value;

// comparing multiple templates, if they are all the same, is true, otherwise, is false
template <template <typename...> class... Tps>
inline bool is_template_same_vs;

template <template <typename...> class Tp1, template <typename...> class Tp2, template <typename...> class... Tps>
inline constexpr bool is_template_same_vs<Tp1, Tp2, Tps...> =
    is_template_same_vs<Tp1, Tp2> && is_template_same_vs<Tp2, Tps...>;

template <template <typename...> class Tp, template <typename...> class Up>
inline constexpr bool is_template_same_vs<Tp, Up> = is_template_same_v<Tp, Up>;

template <template <typename...> class Tp>
inline constexpr bool is_template_same_vs<Tp> = true;

template <>
inline constexpr bool is_template_same_vs<> = true;

// comparing multiple templates, if same template exists in them, is true, otherwise, is false
template <template <typename...> class... Tps>
inline bool is_template_exist_same_vs;

template <template <typename...> class Tp, template <typename...> class... Tps>
inline constexpr bool is_template_exist_same_vs<Tp, Tps...> =
    (is_template_same_v<Tp, Tps> || ...) || is_template_exist_same_vs<Tps...>;

template <template <typename...> class Tp>
inline constexpr bool is_template_exist_same_vs<Tp> = false;

template <>
inline constexpr bool is_template_exist_same_vs<> = false;

} // namespace std

#endif