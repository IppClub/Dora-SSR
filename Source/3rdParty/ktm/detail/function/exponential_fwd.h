//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_EXPONENTIAL_FWD_H_
#define _KTM_EXPONENTIAL_FWD_H_

#include "../../traits/type_traits_ext.h"

namespace ktm
{
namespace detail
{
namespace exponential_implement
{

template <typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct sqrt;

template <typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct rsqrt;

template <typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct recip;

template <typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_sqrt;

template <typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_rsqrt;

template <typename T, typename = std::enable_if_t<std::is_exist_same_vs<float, double, T>>>
struct fast_recip;

} // namespace exponential_implement
} // namespace detail
} // namespace ktm

#endif