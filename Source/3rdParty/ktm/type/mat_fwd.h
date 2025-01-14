//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MAT_FWD_H_
#define _KTM_MAT_FWD_H_

#include <cstddef>
#include <type_traits>

namespace ktm
{

template <size_t Row, size_t Col, typename T,
          typename = std::enable_if_t<(Row > 1) && (Col > 1) && std::is_arithmetic_v<T>>>
struct mat;

}

#endif