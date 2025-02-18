//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_FWD_H_
#define _KTM_VEC_FWD_H_

#include <cstddef>
#include <type_traits>

namespace ktm
{

template <size_t N, typename T, typename = std::enable_if_t<(N > 1) && std::is_arithmetic_v<T>>>
struct vec;

}

#endif