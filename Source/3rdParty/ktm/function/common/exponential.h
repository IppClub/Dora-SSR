//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_EXPONENTIAL_H_
#define _KTM_EXPONENTIAL_H_

#include <cmath>
#include "../../setup.h"
#include "../../type/basic.h"
#include "../../traits/type_traits_math.h"
#include "../../detail/function/exponential_fwd.h"

namespace ktm
{

template <size_t N, typename T>
KTM_INLINE std::enable_if_t<std::is_arithmetic_v<T>, T> pow(T x) noexcept
{
    if constexpr (N == 0)
        return one<T>;
    else
        return x * pow<N - 1>(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_arithmetic_v<T>, T> pow2(T x) noexcept
{
    return pow<2>(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_arithmetic_v<T>, T> pow5(T x) noexcept
{
    return pow<5>(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> sqrt(T x) noexcept
{
    return detail::exponential_implement::sqrt<T>::call(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> rsqrt(T x) noexcept
{
    return detail::exponential_implement::rsqrt<T>::call(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> recip(T x) noexcept
{
    return detail::exponential_implement::recip<T>::call(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> cbrt(T x) noexcept
{
    return std::cbrt(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> pow(T x, T y) noexcept
{
    return std::pow(x, y);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> exp(T x) noexcept
{
    return std::exp(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> exp2(T x) noexcept
{
    return std::exp2(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> expm1(T x) noexcept
{
    return std::expm1(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> log(T x) noexcept
{
    return std::log(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> log10(T x) noexcept
{
    return std::log10(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> log2(T x) noexcept
{
    return std::log2(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> log1p(T x) noexcept
{
    return std::log1p(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> logb(T x) noexcept
{
    return std::logb(x);
}

namespace fast
{

template <typename T>
KTM_INLINE std::enable_if_t<is_listing_type_v<type_list<float, double>, T>, T> sqrt(T x) noexcept
{
    return detail::exponential_implement::fast_sqrt<T>::call(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<is_listing_type_v<type_list<float, double>, T>, T> rsqrt(T x) noexcept
{
    return detail::exponential_implement::fast_rsqrt<T>::call(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<is_listing_type_v<type_list<float, double>, T>, T> recip(T x) noexcept
{
    return detail::exponential_implement::fast_recip<T>::call(x);
}

} // namespace fast

} // namespace ktm

#include "../../detail/function/exponential.inl"
#include "../../detail/function/exponential_simd.inl"

#endif