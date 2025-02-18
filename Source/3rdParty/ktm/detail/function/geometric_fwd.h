//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_GEOMETRIC_FWD_H_
#define _KTM_GEOMETRIC_FWD_H_

#include <cstddef>
#include "../../traits/type_traits_ext.h"

namespace ktm
{
namespace detail
{
namespace geometric_implement
{

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct dot;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct project;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T> && (N == 2 || N == 3)>>
struct cross;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct length;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct distance;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct normalize;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct reflect;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct refract;

template <size_t N, typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_project;

template <size_t N, typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_length;

template <size_t N, typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_distance;

template <size_t N, typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_normalize;

} // namespace geometric_implement
} // namespace detail
} // namespace ktm

#endif