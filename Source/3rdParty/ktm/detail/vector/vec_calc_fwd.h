//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_CALC_FWD_INL_ 
#define _KTM_VEC_CALC_FWD_INL_

#include <cstddef>
#include <type_traits>

namespace ktm
{
namespace detail
{
namespace vec_calc_implement
{
    
template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct add;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct add_to_self;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct minus;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct minus_to_self; 

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct mul;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct mul_to_self;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct div;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct div_to_self; 

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct opposite;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct add_scalar;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct add_scalar_to_self;  

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct minus_scalar;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct minus_scalar_to_self;  

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct mul_scalar;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct mul_scalar_to_self;  

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct div_scalar;

template<size_t N, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct div_scalar_to_self;

}
}
}

#endif
