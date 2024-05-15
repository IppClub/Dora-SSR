//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_EXPONENTIAL_H_
#define _KTM_EXPONENTIAL_H_

#include <cmath>
#include "../setup.h"
#include "../type/basic.h"

namespace ktm
{

template<size_t N, typename T>
KTM_INLINE std::enable_if_t<std::is_arithmetic_v<T>, T> pow(T x) noexcept
{
    if constexpr(N == 0)
        return one<T>;
    else
        return x * pow<N - 1>(x);
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_arithmetic_v<T>, T> pow2(T x) noexcept
{
    return pow<2>(x);
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_arithmetic_v<T>, T> pow5(T x) noexcept
{
    return pow<5>(x);
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> exp(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::expf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::exp(x);
    else 
        return ::expl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> exp2(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::exp2f(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::exp2(x);
    else 
        return ::exp2l(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> expm1(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::expm1f(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::expm1(x);
    else 
        return ::expm1l(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> log(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::logf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::log(x);
    else 
        return ::logl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> log10(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::log10f(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::log10(x);
    else 
        return ::log10l(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> log2(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::log2f(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::log2(x);
    else 
        return ::log2l(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> log1p(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::log1pf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::log1p(x);
    else 
        return ::log1pl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> logb(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::logbf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::logb(x);
    else 
        return ::logbl(x); 
}

}

#endif