//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_BASIC_H_
#define _KTM_BASIC_H_

#include <type_traits>
#include <limits>

namespace ktm
{

template <typename T>
inline constexpr std::enable_if_t<std::is_arithmetic_v<T>, T> zero = static_cast<T>(0);

template <typename T>
inline constexpr std::enable_if_t<std::is_arithmetic_v<T>, T> one = static_cast<T>(1);

template <typename T>
inline constexpr std::enable_if_t<std::is_arithmetic_v<T>, T> epsilon = std::numeric_limits<T>::epsilon();

template <typename T>
inline constexpr std::enable_if_t<std::is_floating_point_v<T>, T> euler =
    static_cast<T>(2.71828182845904523536028747135266249775724709369996);

template <typename T>
inline constexpr std::enable_if_t<std::is_floating_point_v<T>, T> pi =
    static_cast<T>(3.14159265358979323846264338327950288419716939937511);

template <typename T>
inline constexpr std::enable_if_t<std::is_floating_point_v<T>, T> tow_pi = static_cast<T>(2) * pi<T>;

template <typename T>
inline constexpr std::enable_if_t<std::is_floating_point_v<T>, T> half_pi = static_cast<T>(0.5) * pi<T>;

template <typename T>
inline constexpr std::enable_if_t<std::is_floating_point_v<T>, T> recip_pi = one<T> / pi<T>;

template <typename T>
inline constexpr std::enable_if_t<std::is_floating_point_v<T>, T> sqrt_tow =
    static_cast<T>(1.41421356237309504880168872420969807856967187537695);

template <typename T>
inline constexpr std::enable_if_t<std::is_floating_point_v<T>, T> rsqrt_tow = one<T> / sqrt_tow<T>;

} // namespace ktm

#endif