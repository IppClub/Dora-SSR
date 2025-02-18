//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_RANDOM_H_
#define _KTM_RANDOM_H_

#include <cstdlib>
#include "../setup.h"
#include "../type/basic.h"
#include "common.h"

namespace ktm
{

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> lerp_rand(T min, T max) noexcept
{
    constexpr unsigned int rand_max = std::is_same_v<T, float> && 0xffffff < RAND_MAX ? 0xffffff : RAND_MAX;
    constexpr T recip_rand_max = one<T> / static_cast<T>(rand_max + 1);
    return lerp(min, max, static_cast<T>(std::rand() & rand_max) * recip_rand_max);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> gauss_rand(T mean, T deviation) noexcept
{
    T unit = sqrt(lerp_rand(epsilon<T>, one<T>));
    T theta = lerp_rand(zero<T>, tow_pi<T>);
    return unit * theta * deviation * sqrt(static_cast<T>(-2) * log(unit) * recip(unit)) + mean;
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, T> exp_rand(T lambda) noexcept
{
    return -log(one<T> - lerp_rand(zero<T>, one<T>)) * recip(lambda);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, vec<2, T>> circur_rand(T radius) noexcept
{
    T theta = lerp_rand(zero<T>, tow_pi<T>);
    return radius * vec<2, T>(cos(theta), sin(theta));
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, vec<2, T>> disk_rand(T radius) noexcept
{
    T unit = sqrt(lerp_rand(zero<T>, one<T>));
    return unit * circur_rand(radius);
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, vec<3, T>> sphere_rand(T radius) noexcept
{
    T theta = lerp_rand(zero<T>, tow_pi<T>);
    T phi = acos(lerp_rand(-one<T>, one<T>));
    T sin_phi = sin(phi);
    return radius * vec<3, T>(sin_phi * cos(theta), sin_phi * sin(theta), cos(phi));
}

template <typename T>
KTM_INLINE std::enable_if_t<std::is_floating_point_v<T>, vec<3, T>> ball_rand(T radius) noexcept
{
    T unit = cbrt(lerp_rand(zero<T>, one<T>));
    return unit * sphere_rand(radius);
}

} // namespace ktm

#endif