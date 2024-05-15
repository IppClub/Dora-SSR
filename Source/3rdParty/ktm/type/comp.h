//  MIT License
//
//  Copyright (c) 2024 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_COMP_H_
#define _KTM_COMP_H_

#include "vec.h"
#include "mat.h"
#include "../traits/type_single_extend.h"
#include "../interface/shared/iarray.h"
#include "../interface/complex/icomp_data.h"
#include "../interface/complex/icomp_make.h"
#include "../interface/complex/icomp_array.h"
#include "../interface/complex/icomp_calc.h"

namespace ktm
{

template<class Child>
using comp_father_type = single_extends_t<template_list<iarray, icomp_data, icomp_make, icomp_array, icomp_calc>, Child>;

template<typename T>
struct comp<T> : comp_father_type<comp<T>>
{
    using fater_type = comp_father_type<comp<T>>;
    using fater_type::fater_type;
};

}

#include "../detail/complex/comp_calc.inl"
#include "../detail/complex/comp_calc_simd.inl"

#endif