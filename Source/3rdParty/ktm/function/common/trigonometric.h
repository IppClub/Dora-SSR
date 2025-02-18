//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_TRIGONOMETRIC_H_
#define _KTM_TRIGONOMETRIC_H_

#include <cmath>
#include "../../setup.h"
#include "../../type/basic.h"

namespace ktm
{

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> radians(T degrees) noexcept
{
    constexpr T degrees_to_radians = pi<T> / static_cast<T>(180);
    return degrees * degrees_to_radians;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> degrees(T radians) noexcept
{
    constexpr T radians_to_degrees = static_cast<T>(180) * recip_pi<T>;
    return radians * radians_to_degrees;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> acos(T x) noexcept
{
    return std::acos(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> asin(T x) noexcept
{
    return std::asin(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> atan(T x) noexcept
{
    return std::atan(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> atan2(T x, T y) noexcept
{
    return std::atan2(x, y);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> cos(T x) noexcept
{
    return std::cos(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> sin(T x) noexcept
{
    return std::sin(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> tan(T x) noexcept
{
    return std::tan(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> sinc(T x) noexcept
{
    return x == zero<T> ? one<T> : sin(x) / x;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> acosh(T x) noexcept
{
    return std::acosh(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> asinh(T x) noexcept
{
    return std::asinh(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> atanh(T x) noexcept
{
    return std::atanh(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> cosh(T x) noexcept
{
    return std::cosh(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> sinh(T x) noexcept
{
    return std::sinh(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> tanh(T x) noexcept
{
    return std::tanh(x);
}

} // namespace ktm

#endif