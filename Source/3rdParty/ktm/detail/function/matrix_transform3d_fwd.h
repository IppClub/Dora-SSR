//  MIT License
//
//  Copyright (c) 2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_MATRIX_TRANSFORM_3D_FWD_H_
#define _KTM_MATRIX_TRANSFORM_3D_FWD_H_

#include "../../setup.h"
#include "../../type/vec_fwd.h"
#include "../../type/mat_fwd.h"

namespace ktm
{
namespace detail
{
namespace matrix_transform3d_implement
{

template<typename T>
KTM_NOINLINE std::enable_if_t<std::is_floating_point_v<T>> rotate3d_normal(mat<4, 4, T>& out,
    T sin_theta, T cos_theta, const vec<3, T>& normal, const vec<3, T>* normal_start_ptr = nullptr) noexcept;
    
}
}
}

#endif