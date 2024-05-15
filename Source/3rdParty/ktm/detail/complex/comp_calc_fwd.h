//  MIT License
//
//  Copyright (c) 2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMP_CALC_FWD_H_
#define _KTM_COMP_CALC_FWD_H_

#include <type_traits>

namespace ktm
{
namespace detail
{
namespace comp_calc_implement
{

template<typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct mul;

template<typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct mul_to_self;

template<typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct act;

}
}
}

#endif