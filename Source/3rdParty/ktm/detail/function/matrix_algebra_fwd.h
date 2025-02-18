//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_ALGEBRA_FWD_H_
#define _KTM_MATRIX_ALGEBRA_FWD_H_

#include <cstddef>
#include <type_traits>

namespace ktm
{
namespace detail
{
namespace matrix_algebra_implement
{

template <size_t Row, size_t Col, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct transpose;

template <size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct diagonal;

template <size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct determinant;

template <size_t N, typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct inverse;

} // namespace matrix_algebra_implement
} // namespace detail
} // namespace ktm

#endif
