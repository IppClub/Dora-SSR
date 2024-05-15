//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_TYPE_SINGLE_EXTEND_H_
#define _KTM_TYPE_SINGLE_EXTEND_H_

#include "type_traits_ext.h"

namespace ktm 
{

// type container
template<typename ...Ts>
struct type_list 
{
    static inline constexpr bool is_all_same = std::is_same_vs<Ts...>;
    static inline constexpr bool is_exist_same = std::is_exist_same_vs<Ts...>;
    template<size_t N>
    using index = std::select_idx_t<N, Ts...>;
};

// type container instance
template<typename TList, template<typename ...> class Tp>
struct type_instance;

template<template<typename ...> class Tp, typename ...Ts>
struct type_instance<type_list<Ts...>, Tp>
{
	using type = Tp<Ts...>;
};

template<typename TList, template<typename ...> class Tp>
using type_instance_t = typename type_instance<TList, Tp>::Type;

// template container
template<template<typename ...> class ...Tps>
struct template_list 
{
    static inline constexpr bool is_all_same = std::is_template_same_vs<Tps...>;
    static inline constexpr bool is_exist_same = std::is_template_exist_same_vs<Tps...>;
};

// single_extends's template
template<class Child>
struct empty_child { };

template<typename TpList, class Child, typename = std::enable_if_t<!TpList::is_exist_same>>
struct single_extends;

template<class Child>
struct single_extends<template_list<>, Child> 
{
    using fater_type = empty_child<Child>;
};

template <template<class F, class C> class Father, 
          template<class F, class C> class... Fathers,
          class Child>
struct single_extends<template_list<Father, Fathers...>, Child>  
{
    using fater_type = Father<typename single_extends<template_list<Fathers...>, Child>::fater_type, Child>;
};

template<typename TpList, class Child>
using single_extends_t = typename single_extends<TpList, Child>::fater_type;

// example:
// struct D : SingleExtends_t<TemplateList<C, B, A>, D>::type { }
// parent struct's child is D, A<D>, B<D>, C<D>
// struct D's inheritance is { D : C : B : A : Nil }

}

#endif