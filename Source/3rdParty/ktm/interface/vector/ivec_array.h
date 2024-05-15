//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_I_VEC_ARRAY_H_
#define _KTM_I_VEC_ARRAY_H_

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include <array>

namespace ktm
{

template<class Father, class Child>
struct ivec_array;

template<class Father, size_t N, typename T>
struct ivec_array<Father, vec<N, T>> : Father
{
    using Father::Father;
    using array_type = std::array<T, N>;
};
}

#endif