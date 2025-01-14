//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_QUAT_H_
#define _KTM_QUAT_H_

#include "vec.h"
#include "mat.h"
#include "../traits/type_single_extends.h"
#include "../interface/shared/iarray_util.h"
#include "../interface/shared/iarray_calc.h"
#include "../interface/shared/iarray_io.h"
#include "../interface/quaternion/iquat_data.h"
#include "../interface/quaternion/iquat_make.h"
#include "../interface/quaternion/iquat_array.h"
#include "../interface/quaternion/iquat_mul.h"

namespace ktm
{

template <class Child>
using quat_father_type = single_extends_t<Child, iquat_data, iquat_make, iquat_array, iquat_mul, iarray_io,
                                          iarray_madd_scalar, iarray_mul_scalar, iarray_add, iarray_util>;

template <typename T>
struct quat<T> : quat_father_type<quat<T>>
{
    using fater_type = quat_father_type<quat<T>>;
    using fater_type::fater_type;
};

} // namespace ktm

#include "../detail/quaternion/quat_mul.inl"
#include "../detail/quaternion/quat_mul_simd.inl"

#endif