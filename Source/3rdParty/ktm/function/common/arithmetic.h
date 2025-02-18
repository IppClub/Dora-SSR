//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_ARITHMETIC_H_
#define _KTM_ARITHMETIC_H_

#include <cmath>
#include "../../setup.h"
#include "../../type/basic.h"

namespace ktm
{

template <typename T>
KTM_INLINE std::enable_if_t<std::is_arithmetic_v<T> && !std::is_unsigned_v<T>, T> abs(T x) noexcept
{
    if constexpr (std::is_floating_point_v<T>)
        return std::copysign(x, zero<T>);
    else
        return x < 0 ? -x : x;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_arithmetic_v<T>, T> min(T x, T y) noexcept
{
    if constexpr (std::is_floating_point_v<T>)
        return std::fmin(x, y);
    else
        return x < y ? x : y;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_arithmetic_v<T>, T> max(T x, T y) noexcept
{
    if constexpr (std::is_floating_point_v<T>)
        return std::fmax(x, y);
    else
        return x > y ? x : y;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_arithmetic_v<T>, T> clamp(T v, T min_v, T max_v) noexcept
{
    return min(max(v, min_v), max_v);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> floor(T x) noexcept
{
    return std::floor(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> ceil(T x) noexcept
{
    return std::ceil(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> round(T x) noexcept
{
    return std::round(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> fract(T x) noexcept
{
    return x - floor(x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> mod(T x, T y) noexcept
{
    return x - y * floor(x / y);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> lerp(T x, T y, T t) noexcept
{
    return x + t * (y - x);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> mix(T x, T y, T t) noexcept
{
    return lerp(x, y, t);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> step(T edge, T x) noexcept
{
    return x < edge ? zero<T> : one<T>;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> smoothstep(T edge0, T edge1, T x) noexcept
{
    const T tmp = clamp((x - edge0) / (edge1 - edge0), zero<T>, one<T>);
    return tmp * tmp * (static_cast<T>(3) - static_cast<T>(2) * tmp);
}

} // namespace ktm

#endif