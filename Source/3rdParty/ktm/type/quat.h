//  MIT License
//
//  Copyright (c) 2023 有个小小杜
//
//  Created by 有个小小杜
//

#ifndef _KTM_QUAT_H_
#define _KTM_QUAT_H_

#include "vec.h"
#include "mat.h"
#include "../traits/type_single_extend.h"
#include "../interface/shared/iarray.h"
#include "../interface/quaternion/iquat_data.h"
#include "../interface/quaternion/iquat_make.h"
#include "../interface/quaternion/iquat_array.h"
#include "../interface/quaternion/iquat_calc.h"

namespace ktm
{

template<class Child>
using quat_father_type = single_extends_t<template_list<iarray, iquat_data, iquat_make, iquat_array, iquat_calc>, Child>;

template<typename T>
struct quat<T> : quat_father_type<quat<T>>
{
    using fater_type = quat_father_type<quat<T>>;
    using fater_type::fater_type;
};

}

#include "../detail/quaternion/quat_calc.inl"
#include "../detail/quaternion/quat_calc_simd.inl"

#endif