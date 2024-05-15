//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMMON_FWD_H_
#define _KTM_COMMON_FWD_H_

#include <cstddef>
#include "../../traits/type_traits_ext.h"

namespace ktm
{
namespace detail
{
namespace common_implement
{

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct reduce_add;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct reduce_min;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct reduce_max;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T> && !std::is_unsigned_v<T>>>
struct abs;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct min;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct max;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct clamp;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct floor;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct ceil;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct round;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct sqrt;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct rsqrt;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct recip;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct fract;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct mod;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct lerp;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct mix;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct step;

template<size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct smoothstep;

template<size_t N, typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_sqrt;

template<size_t N, typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_rsqrt;

template<size_t N, typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_recip;

}
}
}

#endif
