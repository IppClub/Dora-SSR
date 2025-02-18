//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_ARRAY_CALC_FWD_H_
#define _KTM_ARRAY_CALC_FWD_H_

#include <array>

namespace ktm
{
namespace detail
{
namespace array_calc_implement
{

template <typename T, size_t N, typename = void>
struct add;

template <typename T, size_t N, typename = void>
struct sub;

template <typename T, size_t N, typename = void>
struct neg;

template <typename T, size_t N, typename = void>
struct mul;

template <typename T, size_t N, typename = void>
struct div;

template <typename T, size_t N, typename = void>
struct madd;

template <typename T, size_t N, typename = void>
struct add_scalar;

template <typename T, size_t N, typename = void>
struct sub_scalar;

template <typename T, size_t N, typename = void>
struct mul_scalar;

template <typename T, size_t N, typename = void>
struct div_scalar;

template <typename T, size_t N, typename = void>
struct madd_scalar;

} // namespace array_calc_implement
} // namespace detail
} // namespace ktm

#endif
