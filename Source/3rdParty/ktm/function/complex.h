//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMPLEX_H_
#define _KTM_COMPLEX_H_

#include "../setup.h"
#include "../type/comp.h"
#include "../traits/type_traits_math.h"
#include "common.h"
#include "compare.h"
#include "geometric.h"

namespace ktm
{

template <class C>
KTM_INLINE std::enable_if_t<is_complex_v<C>, C> conjugate(const C& c) noexcept
{
    return C(-c.i, c.r);
}

template <class C>
KTM_INLINE std::enable_if_t<is_complex_v<C>, C> inverse(const C& c) noexcept
{
    C conjugate_c = conjugate(c);
    return C((*conjugate_c) * recip(length_squared(*c)));
}

template <class C>
KTM_INLINE std::enable_if_t<is_complex_v<C>, C> lerp(const C& x, const C& y, comp_traits_base_t<C> t) noexcept
{
    return C(lerp(*x, *y, t));
}

template <class C>
KTM_INLINE std::enable_if_t<is_complex_v<C>, comp_traits_base_t<C>> dot(const C& x, const C& y) noexcept
{
    return dot(*x, *y);
}

template <class C>
KTM_INLINE std::enable_if_t<is_complex_v<C>, comp_traits_base_t<C>> length(const C& c) noexcept
{
    return length(*c);
}

template <class C>
KTM_INLINE std::enable_if_t<is_complex_v<C>, C> normalize(const C& c) noexcept
{
    using T = comp_traits_base_t<C>;
    T ls = length_squared(*c);
    return ls == zero<T> ? C(zero<T>, one<T>) : C((*c) * rsqrt(ls));
}

template <class C>
KTM_NOINLINE std::enable_if_t<is_complex_v<C>, C> exp(const C& c) noexcept
{
    using T = comp_traits_base_t<C>;
    T sini = sin(c.imag());
    if (equal_zero(sini))
        return C(zero<T>, exp(c.real()) * cos(c.imag()));
    return exp(c.real()) * C(sini, cos(c.imag()));
}

template <class C>
KTM_NOINLINE std::enable_if_t<is_complex_v<C>, C> log(const C& c) noexcept
{
    using T = comp_traits_base_t<C>;
    T real = log(length_squared(*c)) / static_cast<T>(2);
    if (equal_zero(c.imag()))
        return C(zero<T>, real);
    return C(c.angle(), real);
}

template <class C>
KTM_NOINLINE std::enable_if_t<is_complex_v<C>, C> slerp_internal(const C& x, const C& y,
                                                                 comp_traits_base_t<C> t) noexcept
{
    using T = comp_traits_base_t<C>;
    T a = C::from_to(*y, *x).angle();
    T normal = a < zero<T> ? a + tow_pi<T> : a;
    return C::from_angle(t * normal) * x;
}

template <class C>
KTM_NOINLINE std::enable_if_t<is_complex_v<C>, C> slerp(const C& x, const C& y, comp_traits_base_t<C> t) noexcept
{
    using T = comp_traits_base_t<C>;
    T a = C::from_to(*y, *x).angle();
    return C::from_angle(t * a) * x;
}

template <class C>
KTM_NOINLINE std::enable_if_t<is_complex_v<C>, C> slerp_longest(const C& x, const C& y,
                                                                comp_traits_base_t<C> t) noexcept
{
    using T = comp_traits_base_t<C>;
    T a = C::from_to(*y, *x).angle();
    T normal = a < zero<T> ? a + tow_pi<T> : a - tow_pi<T>;
    return C::from_angle(t * normal) * x;
}

} // namespace ktm

#endif