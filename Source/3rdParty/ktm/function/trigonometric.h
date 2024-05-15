//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_TRIGONOMETRIC_H_
#define _KTM_TRIGONOMETRIC_H_

#include <cmath>
#include "../setup.h"
#include "../type/basic.h"

namespace ktm
{

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> radians(T degrees) noexcept
{
    constexpr T degrees_to_radians = pi<T> / static_cast<T>(180);
    return degrees * degrees_to_radians;
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> degrees(T radians) noexcept
{
    constexpr T radians_to_degrees = static_cast<T>(180) * one_over_pi<T>;
    return radians * radians_to_degrees;
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> acos(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::acosf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::acos(x);
    else 
        return ::acosl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> asin(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::asinf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::asin(x);
    else 
        return ::asinl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> atan(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::atanf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::atan(x);
    else 
        return ::atanl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> atan2(T x, T y) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::atan2f(x, y);
    else if constexpr(std::is_same_v<T, double>)
        return ::atan2(x, y);
    else 
        return ::atan2l(x, y); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> cos(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::cosf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::cos(x);
    else 
        return ::cosl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> sin(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::sinf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::sin(x);
    else 
        return ::sinl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> tan(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::tanf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::tan(x);
    else 
        return ::tanl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> sinc(T x) noexcept
{
    return x == zero<T> ? one<T> : sin(x) / x;
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> acosh(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::acoshf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::acosh(x);
    else 
        return ::acoshl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> asinh(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::asinhf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::asinh(x);
    else 
        return ::asinhl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> atanh(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::atanhf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::atanh(x);
    else 
        return ::atanhl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> cosh(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::coshf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::cosh(x);
    else 
        return ::coshl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> sinh(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::sinhf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::sinh(x);
    else 
        return ::sinhl(x); 
}

template<typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> tanh(T x) noexcept
{
    if constexpr(std::is_same_v<T, float>)
        return ::tanhf(x);
    else if constexpr(std::is_same_v<T, double>)
        return ::tanh(x);
    else 
        return ::tanhl(x); 
}

}

#endif