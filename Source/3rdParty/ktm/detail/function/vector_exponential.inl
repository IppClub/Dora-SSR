//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_EXPONENTIAL_INL_
#define _KTM_VECTOR_EXPONENTIAL_INL_

#include "vector_exponential_fwd.h"
#include "../loop_util.h"
#include "../../type/vec_fwd.h"
#include "../../function/common/exponential.h"

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::sqrt
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::sqrt<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::rsqrt
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::rsqrt<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::recip
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::recip<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::cbrt
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::cbrt<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::pow
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::pow<T>, x, y);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::exp
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::exp<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::exp2
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::exp2<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::expm1
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::expm1<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::log
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::log<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::log10
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::log10<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::log2
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::log2<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::log1p
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::log1p<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::logb
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::logb<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::fast_sqrt
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::fast::sqrt<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::fast_rsqrt
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::fast::rsqrt<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_exponential_implement::fast_recip
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::fast::recip<T>, x);
        return ret;
    }
};

#endif