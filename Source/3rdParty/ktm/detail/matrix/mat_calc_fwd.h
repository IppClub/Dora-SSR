//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MAT_CALC_FWD_H_ 
#define _KTM_MAT_CALC_FWD_H_

#include <cstddef>
#include <type_traits>

namespace ktm
{
namespace detail
{
    
namespace mat_opt_implement
{
template<size_t Row, size_t Col, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct mat_mul_vec;

template<size_t Row, size_t Col, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct vec_mul_mat;

template<size_t Row, size_t Col, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct mat_mul_mat;

template<size_t Row, size_t Col, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct add;

template<size_t Row, size_t Col, typename T, typename = std::enable_if_t<std::is_arithmetic_v<T>>>
struct minus;

}
}
}

#endif
