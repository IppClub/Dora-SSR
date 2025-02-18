//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_TYPE_TRAITS_FUNCTION_H_
#define _KTM_TYPE_TRAITS_FUNCTION_H_

#include <utility>
#include "type_traits_ext.h"

namespace ktm
{

template <typename T>
struct function_traits;

template <typename R, typename... Ps>
struct function_traits<R (*)(Ps...)>
{
    using return_type = R;
    template <size_t N>
    using param_type = std::select_idx_t<N, Ps...>;
    static inline constexpr size_t param_num = sizeof...(Ps);
    static inline constexpr bool is_const = false;
};

template <typename R, typename ClassT, typename... Ps>
struct function_traits<R (ClassT::*)(Ps...)>
{
    using return_type = R;
    template <size_t N>
    using param_type = std::select_idx_t<N, Ps...>;
    static inline constexpr size_t param_num = sizeof...(Ps);
    static inline constexpr bool is_const = false;
};

template <typename R, typename ClassT, typename... Ps>
struct function_traits<R (ClassT::*)(Ps...) const>
{
    using return_type = R;
    template <size_t N>
    using param_type = std::select_idx_t<N, Ps...>;
    static inline constexpr size_t param_num = sizeof...(Ps);
    static inline constexpr bool is_const = true;
};

template <typename R, typename... Ps>
struct function_traits<R (*)(Ps...) noexcept> : function_traits<R (*)(Ps...)>
{
};

template <typename R, typename ClassT, typename... Ps>
struct function_traits<R (ClassT::*)(Ps...) noexcept> : function_traits<R (ClassT::*)(Ps...)>
{
};

template <typename R, typename ClassT, typename... Ps>
struct function_traits<R (ClassT::*)(Ps...) const noexcept> : function_traits<R (ClassT::*)(Ps...) const>
{
};

template <typename T>
using function_traits_return_t = typename function_traits<T>::return_type;

template <typename T, size_t N>
using function_traits_param_t = typename function_traits<T>::template param_type<N>;

template <typename T>
inline constexpr size_t function_traits_param_n = function_traits<T>::param_num;

template <typename T>
inline constexpr bool function_traits_const_v = function_traits<T>::is_const;

template <typename Tp, typename Up, size_t... Ns>
inline constexpr bool is_same_function_traits(std::index_sequence<Ns...>) noexcept
{
    return (std::is_same_v<function_traits_param_t<Tp, Ns>, function_traits_param_t<Up, Ns>> && ...);
}

template <typename Tp, typename Up>
inline constexpr bool is_same_function_traits() noexcept
{
    if constexpr (!std::is_same_v<function_traits_return_t<Tp>, function_traits_return_t<Up>>)
        return false;
    else if constexpr (function_traits_param_n<Tp> != function_traits_param_n<Up>)
        return false;
    else if constexpr (function_traits_const_v<Tp> != function_traits_const_v<Up>)
        return false;

    return is_same_function_traits<Tp, Up>(std::make_index_sequence<function_traits_param_n<Tp>>());
}

template <typename Tp, typename Up>
inline constexpr bool is_same_function_traits_v = is_same_function_traits<Tp, Up>();

} // namespace ktm

#endif