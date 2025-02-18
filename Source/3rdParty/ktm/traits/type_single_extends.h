//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_TYPE_SINGLE_EXTENDS_H_
#define _KTM_TYPE_SINGLE_EXTENDS_H_

#include "type_traits_function.h"

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
    static inline constexpr bool is_all_same = std::is_same_vs<Ts...>;
    static inline constexpr bool is_exist_same = std::is_exist_same_vs<Ts...>;

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
    static inline constexpr bool is_all_same = std::is_template_same_vs<Tps...>;
    static inline constexpr bool is_exist_same = std::is_template_exist_same_vs<Tps...>;

    template <template <typename...> class... Ups>
    using add_t = template_list<Tps..., Ups...>;

    template <typename TpList>
    using append_t = typename append<TpList>::type;
};

// empty_child template
template <class Child>
struct empty_child
{
protected:
    inline constexpr Child* child_ptr() noexcept { return static_cast<Child*>(this); }

    inline constexpr const Child* child_ptr() const noexcept { return static_cast<const Child*>(this); }
};

// package extends's interface template
template <template <class F, class C> class... Interfaces>
struct package_interface;

template <>
struct package_interface<>
{
    template <class Child>
    using type = empty_child<Child>;
};

template <template <class F, class C> class Interface, template <class F, class C> class... Interfaces>
struct package_interface<Interface, Interfaces...>
{
    template <class Child>
    using type = Interface<typename package_interface<Interfaces...>::template type<Child>, Child>;
};

// combine interfaces as new interface template
template <template <class F, class C> class... Interfaces>
struct combine_interface;

template <template <class F, class C> class Interface1, template <class F, class C> class Interface2>
struct combine_interface<Interface1, Interface2>
{
    template <typename Father, typename Child>
    using type = Interface1<Interface2<Father, Child>, Child>;
};

template <template <class F, class C> class Interface1, template <class F, class C> class Interface2,
          template <class F, class C> class... Interfaces>
struct combine_interface<Interface1, Interface2, Interfaces...>
{
    template <typename Father, typename Child>
    using type = Interface1<typename combine_interface<Interface2, Interfaces...>::template type<Father, Child>, Child>;
};

// extract interfaces as template list from package interfaces
template <typename T>
struct extract_interface;

template <class Child>
struct extract_interface<empty_child<Child>>
{
    using type = template_list<>;
};

template <template <class F, class C> class Interface, class Father, class Child>
struct extract_interface<Interface<Father, Child>>
{
    using type = typename template_list<Interface>::template append_t<typename extract_interface<Father>::type>;
};

// single extends's template
template <typename PkgInterface, typename = std::enable_if_t<!extract_interface<PkgInterface>::type::is_exist_same>>
struct single_extends
{
    using type = PkgInterface;
};

template <class Child, template <class F, class C> class... Fathers>
using single_extends_t = typename single_extends<typename package_interface<Fathers...>::template type<Child>>::type;

// example:
// struct D : single_extends_t<D, C, B, A> { }
// struct D's inheritance is { D : C : B : A : empty_child }

} // namespace ktm

#define KTM_CRTP_INTERFACE_REGISTER(interface, implement)                                                     \
    template <typename ImplClass>                                                                             \
    static inline constexpr auto interface_check_##implement(int)                                             \
        ->std::enable_if_t<                                                                                   \
            ktm::is_same_function_traits_v<decltype(&ImplClass::interface), decltype(&ImplClass::implement)>, \
            std::true_type>;                                                                                  \
    template <typename ImplClass>                                                                             \
    static inline constexpr std::false_type interface_check_##implement(...);
#define KTM_CRTP_INTERFACE_IMPLEMENT(impl_class, implement) decltype(interface_check_##implement<impl_class>(0))::value

#endif