//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_QUATERNION_H_
#define _KTM_QUATERNION_H_

#include "../setup.h"
#include "../type/quat.h"
#include "../traits/type_traits_math.h"
#include "common.h"
#include "compare.h"
#include "geometric.h"

namespace ktm
{

template <class Q>
KTM_INLINE std::enable_if_t<is_quaternion_v<Q>, Q> conjugate(const Q& q) noexcept
{
    return Q(-q.i, -q.j, -q.k, q.r);
}

template <class Q>
KTM_INLINE std::enable_if_t<is_quaternion_v<Q>, Q> inverse(const Q& q) noexcept
{
    Q conjugate_q = conjugate(q);
    return Q((*conjugate_q) * recip(length_squared(*q)));
}

template <class Q>
KTM_INLINE std::enable_if_t<is_quaternion_v<Q>, Q> lerp(const Q& p, const Q& q, quat_traits_base_t<Q> t) noexcept
{
    return Q(lerp(*p, *q, t));
}

template <class Q>
KTM_INLINE std::enable_if_t<is_quaternion_v<Q>, quat_traits_base_t<Q>> dot(const Q& p, const Q& q) noexcept
{
    return dot(*p, *q);
}

template <class Q>
KTM_INLINE std::enable_if_t<is_quaternion_v<Q>, quat_traits_base_t<Q>> length(const Q& q) noexcept
{
    return length(*q);
}

template <class Q>
KTM_INLINE std::enable_if_t<is_quaternion_v<Q>, Q> normalize(const Q& q) noexcept
{
    using T = quat_traits_base_t<Q>;
    T ls = length_squared(*q);
    return ls == zero<T> ? Q(zero<T>, zero<T>, zero<T>, one<T>) : Q((*q) * rsqrt(ls));
}

template <class Q>
KTM_NOINLINE std::enable_if_t<is_quaternion_v<Q>, Q> exp(const Q& q) noexcept
{
    using T = quat_traits_base_t<Q>;
    vec<3, T> q_imag = q.imag();
    T angle = length(q_imag);
    if (equal_zero(angle))
        return Q(zero<T>, zero<T>, zero<T>, exp(q.real()));
    vec<3, T> axis = normalize(q_imag);
    Q unit = Q::real_imag(cos(angle), sin(angle) * axis);
    return exp(q.real()) * unit;
}

template <class Q>
KTM_NOINLINE std::enable_if_t<is_quaternion_v<Q>, Q> log(const Q& q) noexcept
{
    using T = quat_traits_base_t<Q>;
    T real = log(length_squared(*q)) / static_cast<T>(2);
    vec<3, T> q_imag = q.imag();
    if (equal_zero(q_imag))
        return Q(zero<T>, zero<T>, zero<T>, real);
    vec<3, T> imag = acos(q.real() / length(q)) * normalize(q_imag);
    return Q::real_imag(real, imag);
}

template <class Q>
KTM_NOINLINE std::enable_if_t<is_quaternion_v<Q>, Q> slerp_internal(const Q& x, const Q& y,
                                                                    quat_traits_base_t<Q> t) noexcept
{
    using T = quat_traits_base_t<Q>;
    T s = one<T> - t;
    T a = static_cast<T>(2) * atan2(length(x - y), length(x + y)); // angel
    T r = one<T> / sinc(a);
    return normalize(Q(sinc(s * a) * r * s * (*x) + sinc(t * a) * r * t * (*y)));
}

template <class Q>
KTM_NOINLINE std::enable_if_t<is_quaternion_v<Q>, Q> slerp(const Q& x, const Q& y, quat_traits_base_t<Q> t) noexcept
{
    if (dot(x, y) >= 0)
        return slerp_internal(x, y, t);
    return slerp_internal(x, -y, t);
}

template <class Q>
KTM_NOINLINE std::enable_if_t<is_quaternion_v<Q>, Q> slerp_longest(const Q& x, const Q& y,
                                                                   quat_traits_base_t<Q> t) noexcept
{
    if (dot(x, y) >= 0)
        return slerp_internal(x, -y, t);
    return slerp_internal(x, y, t);
}

} // namespace ktm

#endif