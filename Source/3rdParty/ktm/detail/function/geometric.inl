//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_GEOMETRIC_INL_
#define _KTM_GEOMETRIC_INL_

#include "geometric_fwd.h"
#include "../../type/basic.h"
#include "../../type/vec_fwd.h"
#include "../../function/common.h"

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::dot
{
    using V = vec<N, T>;

    static KTM_INLINE T call(const V& x, const V& y) noexcept { return ktm::reduce_add(x * y); }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::project
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        return dot<N, T>::call(x, y) / dot<N, T>::call(y, y) * y;
    }
};

template <typename T>
struct ktm::detail::geometric_implement::cross<2, T>
{
    using V = vec<2, T>;
    using RetV = vec<3, T>;

    static KTM_INLINE RetV call(const V& x, const V& y) noexcept
    {
        return RetV(zero<T>, zero<T>, x[0] * y[1] - x[1] * y[0]);
    }
};

template <typename T>
struct ktm::detail::geometric_implement::cross<3, T>
{
    using V = vec<3, T>;

    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        return V(x[1] * y[2] - x[2] * y[1], x[2] * y[0] - x[0] * y[2], x[0] * y[1] - x[1] * y[0]);
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::length
{
    using V = vec<N, T>;

    static KTM_INLINE T call(const V& x) noexcept { return ktm::sqrt(dot<N, T>::call(x, x)); }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::distance
{
    using V = vec<N, T>;

    static KTM_INLINE T call(const V& x, const V& y) noexcept { return length<N, T>::call(x - y); }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::normalize
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept { return ktm::rsqrt(dot<N, T>::call(x, x)) * x; }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::reflect
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x, const V& n) noexcept { return x - 2 * dot<N, T>::call(x, n) * n; }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::refract
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x, const V& n, T eta) noexcept
    {
        const T d = dot<N, T>::call(x, n);
        const T k = one<T> - eta * eta * (one<T> - d * d);
        return k >= zero<T> ? eta * x - (eta * d + ktm::sqrt(k)) * n : V();
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::fast_project
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        return dot<N, T>::call(x, y) * ktm::fast::recip(dot<N, T>::call(y, y)) * y;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::fast_length
{
    using V = vec<N, T>;

    static KTM_INLINE T call(const V& x) noexcept { return ktm::fast::sqrt(dot<N, T>::call(x, x)); }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::fast_distance
{
    using V = vec<N, T>;

    static KTM_INLINE T call(const V& x, const V& y) noexcept { return fast_length<N, T>::call(x - y); }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::geometric_implement::fast_normalize
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept { return ktm::fast::rsqrt(dot<N, T>::call(x, x)) * x; }
};

#endif