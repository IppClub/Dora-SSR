//  MIT License
//
//  Copyright (c) 2023-2026 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_SINGLE_EXTENDS_H_
#define _KTM_SINGLE_EXTENDS_H_

#include "../setup.h"
#include "static_container.h"
#include "type_traits_function.h"

namespace ktm
{

// empty_base template
template <class Child>
struct empty_base
{
protected:
    KTM_CORE_FUNC constexpr Child* child_ptr() noexcept { return static_cast<Child*>(this); }

    KTM_CORE_FUNC constexpr const Child* child_ptr() const noexcept { return static_cast<const Child*>(this); }
};

// package extends's interface template
template <template <class F, class C> class... Interfaces>
struct package_interface;

template <>
struct package_interface<>
{
    template <class Child>
    using type = empty_base<Child>;
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
struct extract_interface<empty_base<Child>>
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
// struct D's inheritance is { D : C : B : A : empty_base }

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