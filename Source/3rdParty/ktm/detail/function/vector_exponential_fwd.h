//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_EXPONENTIAL_FWD_H_
#define _KTM_VECTOR_EXPONENTIAL_FWD_H_

#include <cstddef>
#include "../../traits/type_traits_ext.h"

namespace ktm
{
namespace detail
{
namespace vector_exponential_implement
{

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct sqrt;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct rsqrt;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct recip;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct cbrt;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct pow;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct exp;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct exp2;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct expm1;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct log;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct log10;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct log2;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct log1p;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct logb;

template <size_t N, typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_sqrt;

template <size_t N, typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_rsqrt;

template <size_t N, typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_recip;

} // namespace vector_exponential_implement
} // namespace detail
} // namespace ktm

#endif