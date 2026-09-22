//  MIT License
//
//  Copyright (c) 2023-2026 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_STATIC_CONTAINER_H_
#define _KTM_STATIC_CONTAINER_H_

#include "type_traits_ext.h"

namespace ktm
{

// type container
template <typename... Ts>
struct type_list
{
private:
    template <typename TList>
    struct append;

    template <typename... Us>
    struct append<type_list<Us...>>
    {
        using type = type_list<Ts..., Us...>;
    };

public:
    static inline constexpr bool is_all_same = is_same_vs<Ts...>;
    static inline constexpr bool is_exist_same = is_exist_same_vs<Ts...>;

    template <typename... Us>
    using add_t = type_list<Ts..., Us...>;

    template <typename TList>
    using append_t = typename append<TList>::type;
};

// template container
template <template <typename...> class... Tps>
struct template_list
{
private:
    template <typename TpList>
    struct append;

    template <template <typename...> class... Ups>
    struct append<template_list<Ups...>>
    {
        using type = template_list<Tps..., Ups...>;
    };

public:
    static inline constexpr bool is_all_same = is_template_same_vs<Tps...>;
    static inline constexpr bool is_exist_same = is_template_exist_same_vs<Tps...>;

    template <template <typename...> class... Ups>
    using add_t = template_list<Tps..., Ups...>;

    template <typename TpList>
    using append_t = typename append<TpList>::type;
};

} // namespace ktm

#endif