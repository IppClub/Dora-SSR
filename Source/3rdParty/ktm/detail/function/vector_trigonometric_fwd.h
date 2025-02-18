//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_TRIGNOMETRIC_FWD_H_
#define _KTM_VECTOR_TRIGNOMETRIC_FWD_H_

#include <cstddef>
#include "../../traits/type_traits_ext.h"

namespace ktm
{
namespace detail
{
namespace vector_trigonometric_implement
{

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct acos;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct asin;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct atan;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct atan2;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct cos;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct sin;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct tan;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct sinc;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct acosh;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct asinh;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct atanh;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct cosh;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct sinh;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct tanh;

} // namespace vector_trigonometric_implement
} // namespace detail
} // namespace ktm

#endif