//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_DATA_FWD_H_
#define _KTM_VEC_DATA_FWD_H_

#include <cstddef>
#include <type_traits>

namespace ktm
{
namespace detail
{
namespace vec_data_implement
{

template <size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct vec_storage;

template <size_t OSize, size_t ISize, typename T,
          typename = std::enable_if_t<std::is_arithmetic_v<T> && OSize <= ISize>>
struct vec_swizzle;

}; // namespace vec_data_implement
} // namespace detail
} // namespace ktm

#endif