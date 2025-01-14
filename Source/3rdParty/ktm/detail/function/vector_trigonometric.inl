//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_TRIGNOMETRIC_INL_
#define _KTM_VECTOR_TRIGNOMETRIC_INL_

#include "vector_trigonometric_fwd.h"
#include "../loop_util.h"
#include "../../type/vec_fwd.h"
#include "../../function/common/trigonometric.h"

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::acos
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::acos<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::asin
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::asin<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::atan
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::atan<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::atan2
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x, const V& y) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::atan2<T>, x, y);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::cos
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::cos<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::sin
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::sin<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::tan
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::tan<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::sinc
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::sinc<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::acosh
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::acosh<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::asinh
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::asinh<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::atanh
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::atanh<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::cosh
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::cosh<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::sinh
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::sinh<T>, x);
        return ret;
    }
};

template <size_t N, typename T, typename Void>
struct ktm::detail::vector_trigonometric_implement::tanh
{
    using V = vec<N, T>;

    static KTM_INLINE V call(const V& x) noexcept
    {
        V ret;
        loop_op<N, V>::call(ret, ktm::tanh<T>, x);
        return ret;
    }
};

#endif