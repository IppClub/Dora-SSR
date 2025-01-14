//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMP_FWD_H_
#define _KTM_COMP_FWD_H_

#include <cstddef>
#include <type_traits>

namespace ktm
{

template <typename T, typename = std::enable_if_t<std::is_floating_point_v<T>>>
struct comp;

}

#endif