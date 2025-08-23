//  MIT License
//
//  Copyright (c) 2023-2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_VEC_H_
#define _KTM_VEC_H_

#include "basic.h"
#include "../traits/type_single_extends.h"
#include "../interface/shared/iarray_util.h"
#include "../interface/shared/iarray_calc.h"
#include "../interface/shared/iarray_io.h"
#include "../interface/shared/iarray_tostring.h"
#include "../interface/vector/ivec_data.h"
#include "../interface/vector/ivec_array.h"
#include "../interface/vector/ivec_calc.h"

namespace ktm
{

template <class Child>
using vec_components =
    single_extends_t<Child, ivec_data, ivec_array, ivec_calc, iarray_tostring, iarray_io, iarray_calc, iarray_util>;

template <size_t N, typename T>
struct vec<N, T> : vec_components<vec<N, T>>
{
    using fater_type = vec_components<vec<N, T>>;
    using fater_type::fater_type;
};

} // namespace ktm

#include "../detail/vector/vec_data.inl"
#include "../detail/vector/vec_data_simd.inl"
#include "../detail/vector/vec_calc.inl"
#include "../detail/vector/vec_calc_simd.inl"

#endif