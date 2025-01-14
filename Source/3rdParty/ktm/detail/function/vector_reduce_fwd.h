//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VECTOR_REDUCE_FWD_H_
#define _KTM_VECTOR_REDUCE_FWD_H_

#include <cstddef>
#include "../../traits/type_traits_ext.h"

namespace ktm
{
namespace detail
{
namespace vector_reduce_implement
{

template <size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct reduce_add;

template <size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct reduce_min;

template <size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct reduce_max;

} // namespace vector_reduce_implement
} // namespace detail
} // namespace ktm

#endif