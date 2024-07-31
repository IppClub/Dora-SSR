//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMP_H_
#define _KTM_COMP_H_

#include "vec.h"
#include "mat.h"
#include "../traits/type_single_extends.h"
#include "../interface/shared/iarray_util.h"
#include "../interface/shared/iarray_calc.h"
#include "../interface/shared/iarray_io.h"
#include "../interface/complex/icomp_data.h"
#include "../interface/complex/icomp_make.h"
#include "../interface/complex/icomp_array.h"
#include "../interface/complex/icomp_mul.h"

namespace ktm
{

template <class Child>
using comp_father_type = single_extends_t<Child, icomp_data, icomp_make, icomp_array, icomp_mul, 
    iarray_io, iarray_madd_scalar, iarray_mul_scalar, iarray_add, iarray_util>;

template<typename T>
struct comp<T> : comp_father_type<comp<T>>
{
    using fater_type = comp_father_type<comp<T>>;
    using fater_type::fater_type;
};

}

#include "../detail/complex/comp_mul.inl"
#include "../detail/complex/comp_mul_simd.inl"

#endif